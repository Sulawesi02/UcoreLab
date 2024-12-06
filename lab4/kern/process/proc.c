#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - 分配一个proc_struct并初始化proc_struct的所有字段
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {

    //LAB4:EXERCISE1 ：2213408
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */

    proc->state = PROC_UNINIT;// 初始化进程状态为新建状态
    proc->pid = -1;          // 初始化进程 ID，通常由全局变量或计数器生成,-1表示尚未分配PID
    proc->runs = 0;          // 初始化运行次数为0
    proc->kstack = 0;        // 初始化线程的内核栈
    proc->need_resched = 0;  // 重新调度布尔值
    proc->parent = NULL;     // 父进程
    proc->mm = NULL;         // 内存管理
    memset(&(proc->context), 0, sizeof(struct context));// 初始化上下文结构，清空寄存器值
    proc->tf = NULL;         // 初始化陷阱帧为空
    proc->cr3 = boot_cr3;    // CR3寄存器：页目录表PDT的基址
    proc->flags = 0;         // 进程标志
    memset(proc->name, 0, PROC_NAME_LEN + 1);
    }
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}


// proc_run - 使进程“proc”在cpu上运行(将CPU的控制从当前进程切换到另一个进程，并执行上下文切换)
// 注意:在调用 switch_to 之前，应该加载 "proc" 的新页目录表（PDT）的基地址。
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 ：2213408
        /*
         * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们。
         * 宏或函数：
         *   local_intr_save():        禁用中断
         *   local_intr_restore():     启用中断
         *   lcr3():                   修改 CR3 寄存器的值
         *   switch_to():              在两个进程之间进行上下文切换
         */
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;

        // 禁用中断，确保在上下文切换的过程中不会被中断打断。
        local_intr_save(intr_flag);
        {
            // 将 current 更新为新的进程 proc，即切换当前进程。
            current = proc;
            // 修改 CR3 寄存器的值，CR3 存储着页目录的物理地址，指向当前进程的页表。
            // 在切换到新进程时，必须更新 CR3，以便 CPU 使用新进程的页表进行地址映射。
            lcr3(next->cr3);
            // 执行上下文切换
            // 保存当前进程的状态，恢复新进程的状态，继续执行新进程。
            switch_to(&(prev->context), &(next->context));
        }
        // 恢复中断，允许中断再次发生，确保进程切换后的正常运行。
        local_intr_restore(intr_flag);
    }
}

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function

// kernel_thread 函数的意义在于封装和定制，为创建内核线程提供一个简化和特定用途的接口。
// kernel_thread 函数通过调用 do_fork 函数最终完成了内核线程的创建工作

// kernel_thread 是一个 特化的线程创建接口，其核心作用是：
// （1）为内核线程的创建预设参数和上下文。
// （2）简化调用流程，隐藏复杂的 do_fork 参数和细节。
// （3）提供一种创建内核线程的通用方法。
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    // （1）内核线程不像用户进程那样由用户态切换而来，需要内核显式设置初始上下文。
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));

    // 初始化设置内核线程的参数和函数指针
    tf.gpr.s0 = (uintptr_t)fn;  // s0 寄存器保存函数指针
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数

    // 设置 trapframe 中的 status 寄存器（SSTATUS）:主要用于管理当前处理器上下文
    // SSTATUS_SPP：Supervisor Previous Privilege（设置为 supervisor 管理模式，因为这是一个内核线程）
    // SSTATUS_SPIE：Supervisor Previous Interrupt Enable（设置为启用中断，因为这是一个内核线程）
    // SSTATUS_SIE：Supervisor Interrupt Enable（设置为禁用中断，因为我们不希望该线程被中断）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;

    // 将入口点（epc）设置为 kernel_thread_entry 函数，作用实际上是将pc指针指向它(*trapentry.S会用到)
    tf.epc = (uintptr_t)kernel_thread_entry;

    // 使用 do_fork 创建一个新进程（内核线程），这样才真正用设置的tf创建新进程。
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    // 在上面分配的内核栈上分配出一片空间来保存trapframe
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    // 将trapframe中的a0寄存器（返回值）设置为0，说明这个进程是一个子进程
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 将上下文中的ra设置为了forkret函数的入口，并且把trapframe放在上下文的栈顶
    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork       为新子进程创建父进程
 * @clone_flags: 用于指导如何克隆子进程的标志位
 * @stack:       父进程的用户栈指针。如果 stack == 0，则表示创建一个内核线程。
 * @tf:          中断帧信息，将被复制到子进程的 proc->tf 中
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 ：2213408
    /*
     * 一些有用的宏、函数和定义，你可以在下面的实现中使用。
     * 宏或函数：
     *   alloc_proc：   创建一个进程结构体并初始化字段（lab4:exercise1 中实现）
     *   setup_kstack： 为进程分配一个大小为 KSTACKPAGE 的内核栈
     *   copy_mm：      根据 clone_flags，复制或共享当前进程的 mm
     *                  如果 clone_flags & CLONE_VM，则共享；否则复制
     *   copy_thread：  在进程的内核栈顶设置 trapframe，并设置进程的内核入口点和栈
     *   hash_proc：    将进程添加到哈希链表 `hash_list`
     *   get_pid：      分配一个唯一的进程 PID
     *   wakeup_proc：  设置 proc->state = PROC_RUNNABLE
     * 变量：
     *   proc_list：    进程集合的链表
     *   nr_process：   当前进程数量
     */

    // 1. 调用 alloc_proc 分配一个 proc_struct(PCB)
    proc = alloc_proc();
    if (proc == NULL) {
        goto fork_out;
    }
    // 2. 调用 setup_kstack 为子进程分配内核栈
    proc->parent = current;// 设定父线程
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;
    }


    // 3. 调用 copy_mm 复制或共享 mm（取决于 clone_flag）
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }


    // 4. 调用 copy_thread 在子进程的 proc_struct 中设置 trapframe 和上下文
    copy_thread(proc, stack, tf);

    // 5. 将 proc_struct 插入到 hash_list 和 proc_list 中
    int pid = get_pid();
    proc->pid = pid;
    hash_proc(proc);// 将新创建的进程插入到一个哈希表中，用于快速查找。
    list_add(&proc_list, &(proc->list_link));// 将新进程插入全局进程链表 proc_list 中，用于顺序管理所有进程。
    nr_process++;// 增加全局进程计数器，记录当前系统中活跃进程的总数。

    // 6. 调用 wakeup_proc 将子进程状态设置为 RUNNABLE
    wakeup_proc(proc);

    // 7. 将返回值设为字线程 id
    ret = proc->pid;
    

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// 初始化idleproc（内核第一个线程，称为空闲线程）。 
// 创建 init_main 线程（内核第二个线程，用于系统初始化）。
void
proc_init(void) {
    int i;

    // 初始化全局链表 proc_list 和哈希表 hash_list
    // proc_list：用于管理所有的进程，方便遍历或调度。
    // hash_list：哈希表，用于快速查找进程（如通过 PID）。
    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    // 调用 alloc_proc 分配并初始化空闲线程 idleproc
    if ((idleproc = alloc_proc()) == NULL) {
        // 分配失败，触发panic终止程序，说明内核初始化失败。
        panic("cannot alloc idleproc.\n");
    }

    // 通过逐个字段对比预期值和实际值，确认 alloc_proc 是否正确初始化了进程控制块。
    int *context_mem = (int*) kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");

    }
    
    // 初始化设置空闲线程 idleproc
    idleproc->pid = 0;                       // 设置进程 ID 为 0
    idleproc->state = PROC_RUNNABLE;         // 设置状态为可运行
    idleproc->kstack = (uintptr_t)bootstack; // 指定内核栈指针
    idleproc->need_resched = 1;              // 设置需要调度的标志，schedule 函数切换其他进程
    set_proc_name(idleproc, "idle");         // 设置名称为 "idle"
    nr_process++;                            // 增加全局进程计数

    current = idleproc;                      // 设置当前进程为 `idleproc`


    // 创建 init_main 线程
    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }
    // 通过 find_proc 获取新线程的控制块，并设置其名称为 "init"。
    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    // 最终断言，确保 idleproc 和 initproc 均被正确初始化。
    // idleproc 的 PID 是 0，initproc 的 PID 是 1，这是内核进程初始化的基本假设。
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - kern_init结束时，第一个内核线程 idleproc 将执行以下操作
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {// need_resched 为真则需要重新调度
            schedule();// 切换到其他进程
        }
    }
}


