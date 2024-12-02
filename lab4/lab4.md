# OS LAB4 实验报告
---
## 练习

对实验报告的要求：
 - 基于markdown格式来完成，以文本方式为主
 - 填写各个基本练习中要求完成的报告内容
 - 完成实验后，请分析ucore_lab中提供的参考答案，并请在实验报告中说明你的实现与参考答案的区别
 - 列出你认为本实验中重要的知识点，以及与对应的OS原理中的知识点，并简要说明你对二者的含义，关系，差异等方面的理解（也可能出现实验中的知识点没有对应的原理知识点）
 - 列出你认为OS原理中很重要，但在实验中没有对应上的知识点

 ---
#### 练习0：填写已有实验
本实验依赖实验2/3。请把你做的实验2/3的代码填入本实验中代码中有“LAB2”,“LAB3”的注释相应部分。

---
#### 练习1：分配并初始化一个进程控制块（需要编码）
alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。
>【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。

##### 实验代码
将`state`设为新建状态`PROC_UNINIT`；

将`pid`设为`-1`，表示尚未分配PID；

将`cr3`设置为全局变量`boot_cr3`，使用内核页目录表的基址；

其余变量，指针初始化为`NULL`，变量初始化为`0`。
```c
proc->state = PROC_UNINIT;
proc->pid = -1;
proc->runs = 0;
proc->kstack = 0;
proc->need_resched = 0;
proc->parent = NULL;
proc->mm = NULL;
memset(&(proc->context), 0, sizeof(struct context));
proc->tf = NULL;
proc->cr3 = boot_cr3;
proc->flags = 0;
memset(proc->name, 0, PROC_NAME_LEN + 1);
```

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
- 请说明`proc_struct`中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

##### 回答问题
成员变量含义和作用：
- `struct context context`：保存进程执行的上下文，也就是关键的几个寄存器的值。用于进程切换中还原之前的运行状态。在通过proc_run切换到CPU上运行时，需要调用switch_to将原进程的寄存器保存，以便下次切换回去时读出，保持之前的状态。
- `struct trapframe *tf`：保存了进程的中断帧（32个通用寄存器、异常相关的寄存器）。在进程从用户空间跳转到内核空间时，系统调用会改变寄存器的值。我们可以通过调整中断帧来使的系统调用返回特定的值。比如可以利用s0和s1传递线程执行的函数和参数；在创建子线程时，会将中断帧中的a0设为0。

---
#### 练习2：为新创建的内核线程分配资源（需要编码）
创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：
- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

请在实验报告中简要说明你的设计实现过程。请回答如下问题：
- 请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。

##### 实验代码
根据ucore代码注释进行函数调用和参数补充，另外添加了一些必要步骤
- `proc->parent = current;`设定父线程，使父子线程关联，提供清晰的层级结构
- `nr_process++`插入PCB后将线程数量+1
```c
// 1. 调用 alloc_proc 分配一个 proc_struct(PCB)
    proc = alloc_proc();

    // 2. 调用 setup_kstack 为子进程分配内核栈
    proc->parent = current;// 设定父线程
    setup_kstack(proc);

    // 3. 调用 copy_mm 复制或共享 mm（取决于 clone_flag）
    copy_mm(clone_flags, proc);

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
    //proc->state = PROC_RUNNABLE;

    // 7. 将子进程的 pid 设置为 ret 的返回值
    ret = proc->pid;
```

##### 回答问题
`ucore`能做到给每个新`fork`的线程一个唯一的id。在这里通过`get_pid`分配id，它的原理是对于一个可能分配出去的`last_id`，遍历线程链表，判断是否有id与之相等的线程，如果有，则将`last_id`自增1，且保证自增之后不会与当前查询过的线程id冲突，并且其不会超过最大的线程数，重新从头开始遍历链表。如果没有，则更新下一个可能冲突的线程id。

通过这种算法，只有一个id在与所有线程链表中的id均不相同时才能分配出去，所以可以做到给每个新`fork`的线程一个唯一的id。

---
#### 练习3：编写proc_run 函数（需要编码）
proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
- 允许中断。

##### 代码实现
阅读并理解`kern\schedule\sched.c`中的`schedule`函数：
```c
// 进程调度与进程切换
void schedule(void) {
    bool intr_flag;// 保存当前中断状态，确保在调度期间中段禁用，避免调度被打断
    list_entry_t *le, *last;// 进程链表迭代器，分别用于遍历进程和保存当前进程位置
    struct proc_struct *next = NULL;// 指向下一个要运行的进程

    // 保存当前中断状态，并禁止中断
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;// 表示当前进程不需被重新调度
        // 判断当前进程是否为空闲进程，是则从头遍历，否则从当前遍历
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);
        // 若未找到，则将next设为空闲进程，保证系统不会无进程可运行
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        // 上下文切换
        next->runs ++;// 选中进程的运行次数+1
        //若选中进程不是当前运行进程，则调用 proc_run(next) 进行上下文切换，切换到 next。
        if (next != current) {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);// 恢复中断
}
```
并结合代码中给出的注释
```c
        /*
         * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们。
         * 宏或函数：
         *   local_intr_save():        禁用中断
         *   local_intr_restore():     启用中断
         *   lcr3():                   修改 CR3 寄存器的值
         *   switch_to():              在两个进程之间进行上下文切换
         */
```
编写以下代码：
```c
bool intr_flag;// 保存当前中断状态
// 声明两个进程指针，prev为当前进程，next为即将切换到的进程
struct proc_struct *prev = current, *next = proc;
local_intr_save(intr_flag);// 保存中断状态并禁止中断
{
    // 切换当前进程为即将调度的进程
    current = proc;
    // 切换页目录（CR3寄存器修改为next进程的页目录基址）
    lcr3(next->cr3);
    // 执行上下文切换，将当前进程的上下文保存到prev，下一进程的上下文切换到current
    switch_to(&(prev->context), &(next->context));
}
local_intr_restore(intr_flag);// 恢复中断
```
请回答如下问题：
- 在本实验的执行过程中，创建且运行了几个内核线程？

##### 回答问题
实验创建并运行了两个内核线程，分别为：0号线程idleproc和1号线程initproc。
完成代码编写后，编译并运行代码：make qemu


---
#### 扩展练习 Challenge：
- 说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？

##### 回答问题
相关代码如下：
```c
// 检查当前中断状态，若启用了全局中断，则禁用中断并返回1；否则返回0
static inline bool __intr_save(void) {
    // 读取sstatus寄存器中的SIE位（全局中断使能位），判断中断是否启用
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();// 禁用中断
        return 1;
    }
    return 0;
}

// 恢复中断状态，如果flag为1，则启用中断
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

// 保存当前中断状态，并将状态赋值给变量x
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)

// 根据flag恢复中断状态
#define local_intr_restore(x) __intr_restore(x);
```
- 想要保存中断状态并禁用中断时，调用宏`local_intr_save`，展开后执行`__intr_save`来读取`sstatus`寄存器，获取`SIE（全局中断使能位）`的值，判断  是否被置位（中断是否被启用）。
    - 如果该位为1，则说明中断是启用状态，能进行使用。此时调用`intr_disable`将该位置0（禁用中断），并返回1，表示原先中断是启用的。
    - 如果该位为0，则说明原先中断就未启用，直接返回0，表示原先中断是禁用的。
> 返回值表示中断之前的状态（1为启用，0为禁用），供后续恢复时使用。

- 想要恢复中断状态时，调用宏`local_intr_restore`，展开后执行`__intr_restore`，此时判断`flag`的值。
    - 如果其值为1，说明中断原先是启用的，则需要调用`intr_enable`将`sstatus`寄存器的`SIE`置为1，表示中断恢复为启用状态。
    - 如果其值为0，表示原先中断为禁用状态，继续保持禁用状态。

- 在实际代码中，`local_intr_save(intr_flag)`和`local_intr_restore(intr_flag)`的调用如下：
```c
bool intr_flag;
local_intr_save(intr_flag);   // 保存当前中断状态，并禁用中断

/******临界区代码，确保不会被中断干扰******/

local_intr_restore(intr_flag); // 恢复中断状态

```
`local_intr_save`：
- 读取当前中断状态并保存到 intr_flag 中。
- 如果中断启用，则禁用中断。

`local_intr_restore`：
- 根据 intr_flag 恢复中断状态：
    - 如果之前启用了中断（intr_flag=1），则重新启用。
    - 如果之前禁用了中断（intr_flag=0），则保持禁用。
