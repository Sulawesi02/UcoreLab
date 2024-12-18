# OS LAB5 实验报告
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
本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

在`lab5/kern/process/proc.c`中：
- 在`alloc_proc`函数中增加：
```c
proc->wait_state = 0; // 初始化进程的等待状态
proc->cptr = NULL;    // Child Pointer 表示当前进程的子进程
proc->optr = NULL;    // Older Sibling Pointer 表示当前进程的上一个兄弟进程
proc->yptr = NULL;    // Younger Sibling Pointer 表示当前进程的下一个兄弟进程
```
- 修改`do_fork`函数中的要求5：将proc_struct插入hash_list&&proc_list，设置进程的关系链接
```c
bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);
```
---
#### 练习1：加载应用程序并执行（需要编码）
`do_execv`函数调用`load_icode`（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充`load_icode`的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

- 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

##### 代码部分
1. 将用户栈指针`sp`设置为用户栈的栈顶地址`USTACKTOP`。
2. 将异常程序计数器`epc`设置为ELF文件中记录的程序入口地址，当用户程序开始执行时，`epc`表示要执行的第一条指令地址。
3. 将`sstatus`的`SPP`位清零，代表异常来自用户态，之后需要返回用户态；将`SPIE`位清零，表示不启用中断。
```c
tf->gpr.sp = USTACKTOP;
tf->epc = elf->e_entry;
tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
```
##### 执行流程
1. 在`init_main`中通过`kernel_thread`调用`do_fork`创建并唤醒线程，使其执行函数`user_main`，这时该线程状态已经为`PROC_RUNNABLE`，表明该线程开始运行。
2. 在`user_main`中通过宏`KERNEL_EXECVE`，调用`kernel_execve`。
3. 在`kernel_execve`中执行`ebreak`，发生断点异常，转到`__alltraps`，转到`trap`，再到`trap_dispatch`，然后到`exception_handler`，最后到`CAUSE_BREAKPOINT处`。
4. 在`CAUSE_BREAKPOINT`处调用`syscall`。
5. 在`syscall`中根据参数，确定执行`sys_exec`，调用`do_execve`。
6. 在`do_execve`中调用`load_icode`，加载文件。
7. 加载完毕后一路返回，直到`__alltraps`的末尾，接着执行`__trapret`后的内容，到`sret`，表示退出S态，回到用户态执行，这时开始执行用户的应用程序。
---
#### 练习2：父进程复制自己的内存空间给子进程（需要编码）
创建子进程的函数`do_fork`在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过`copy_range`函数（位于kern/mm/pmm.c中）实现的，请补充`copy_range`的实现，确保能够正确执行。

请在实验报告中简要说明你的设计实现过程。

- 如何设计实现`Copy on Write`机制？给出概要设计，鼓励给出详细设计。
> Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

##### 代码部分
首先获取源地址和目的地址对应的内核虚拟地址，然后拷贝内存，最后将拷贝完成的页插入到页表中。
```c
uintptr_t* src = page2kva(page);
uintptr_t* dst = page2kva(npage);
memcpy(dst, src, PGSIZE);
ret = page_insert(to, npage, start, perm);
```

##### COW设计
- 在`fork`时，将父线程的所有页表项设置为只读，在新线程的结构中只复制栈和虚拟内存的页表，不为其分配新的页。
- 切换到子线程执行时，如果子线程需要修改一页的内容，会访问页表，由于该页不允许被修改，所以会引发异常。
- 异常处理部分，遇到该类异常，重新分配一块空间，将访问的页面复制进去，更新子线程的页表项。

---
#### 练习3：阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）
请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：

- 请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？

- 请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）
##### 函数分析
1. fork：通过发起系统调用执行`do_fork`函数。用于创建并唤醒线程，可以通过sys_fork或者kernel_thread调用。
- 初始化一个新线程
- 为新线程分配内核栈空间
- 为新线程分配新的虚拟内存或与其他线程共享虚拟内存
- 获取原线程的上下文与中断帧，设置当前线程的上下文与中断帧
- 将新线程插入哈希表和链表中
- 唤醒新线程
- 返回线程id
2. exec：通过发起系统调用执行`do_execve`函数。用于创建用户空间，加载用户程序，可以通过`sys_exec`调用。
- 回收当前线程的虚拟内存空间
- 为当前线程分配新的虚拟内存空间并加载应用程序
3. wait：通过发起系统调用执行`do_wait`函数。用于等待线程完成，可以通过sys_wait或者init_main调用。
- 查找状态为`PROC_ZOMBIE`的子线程；如果查询到拥有子线程的线程，则设置线程状态并切换线程；如果线程已退出，则调用`do_exit`
- 将线程从哈希表和链表中删除
- 释放线程资源
4. exit：通过发起系统调用执行`do_exit`函数。用于退出线程，可以通过`sys_exit`、`trap`、`do_execve`、`do_wait`调用。具体执行内容：
- 如果当前线程的虚拟内存没有用于其他线程，则销毁该虚拟内存
- 将当前线程状态设为`PROC_ZOMBIE`，唤醒该线程的父线程
- 调用`schedule`切换到其他线程

##### 执行流程
1. 系统调用部分在内核态进行，用户程序的执行在用户态进行
2. 内核态通过系统调用结束后的sret指令切换到用户态，用户态通过发起系统调用产生ebreak异常切换到内核态
3. 内核态执行的结果通过`kernel_execve_ret`将中断帧添加到线程的内核栈中，从而将结果返回给用户

##### 生命周期图
```c
    //                 +-------------+
    //            +--> |	 none 	  |
    //            |    +-------------+       ---+
    //            |          | alloc_proc	    |
    //            |          V				    |
    //            |    +-------------+			|
    //            |    | PROC_UNINIT |			|---> do_fork
    //            |    +-------------+			|
    //   do_wait  |         | wakeup_proc		|
    //            |         V			   	 ---+
    //            |    +-------------+    do_wait 	  +-------------+
    //            |    |PROC_RUNNABLE| <------------> |PROC_SLEEPING|
    //            |    +-------------+    wake_up     +-------------+
    //            |         | do_exit
    //            |         V
    //            |    +-------------+
    //            +--- | PROC_ZOMBIE |
    //                 +-------------+
```
---
#### 扩展练习 Challenge
1. 实现 Copy on Write （COW）机制
给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。
2. 说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？
