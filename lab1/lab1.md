## lab0.5
#### 练习1：使用GDB验证启动流程
为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到`0x80200000`）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？

答：RISC-V 硬件加电后的初始指令从复位地址 `0x1000` 开始。
```
0x1000: auipc	t0,0x0 # 将20位的立即数0x0符号扩展为32位，然后将其加到PC的高20位中，生成一个32位的地址，结果存储到寄存器 t0 中
0x1004:	addi	a1,t0,32 # 将寄存器 t0 的值加上立即数32，结果存储在寄存器 a1 中
0x1008:	csrr	a0,mhartid # 将控制和状态寄存器 mhartid 的值读取并保存当前处理器的 ID 到寄存器 a0 中
0x100c:	ld	t0,24(t0) # 从内存地址 t0 + 24 处加载一个64位的值到寄存器 t0 中，那个地址保存的值就是0x80000000
0x1010:	jr	t0 # 无条件跳转到寄存器 t0 中存储的地址
```
PC 被设置为复位地址 `0x1000`，开始执行复位代码。复位代码执行完成后，将 PC 设置为固件的加载地址 `0x80000000`，开始执行固件代码，并且将操作系统内核加载到内存中的预定位置 `0x80200000`。固件代码执行完成后，将 PC 设置为 `0x80200000`，跳转到操作系统内核的入口点，开始执行内核代码。

## lab1
#### 练习1：理解内核启动中的程序入口操作
阅读 `kern/init/entry.S`内容代码，结合操作系统内核启动流程，说明指令 `la sp, bootstacktop` 完成了什么操作，目的是什么？`tail kern_init` 完成了什么操作，目的是什么？

答：`la sp, bootstacktop`将标签 `bootstacktop` 的地址加载到寄存器 `sp` 中，目的是初始化栈指针寄存器`sp` 为指向内核启动栈的顶部，为栈分配内存空间。
`tail kern_init`跳转到 `kern_init` 函数，目的是传递控制权给 `kern_init`，开始执行内核代码。
#### 练习2：完善中断处理 （需要编程）
请编程完善`trap.c`中的中断处理函数`trap`，在对时钟中断进行处理的部分填写`kern/trap/trap.c`函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用`print_ticks`子程序，向屏幕上打印一行文字”100 ticks”，在打印完10行后调用`sbi.h`中的`shut_down()`函数关机。

要求完成问题1提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程和定时器中断中断处理的流程。实现要求的部分代码后，运行整个系统，大约每1秒会输出一次”100 ticks”，输出10行。

答：
实现过程：首先调用`clock_set_next_event`函数，设置下一次时钟中断的时间，`ticks`自增1。如果`ticks`为100的倍数，就调用`print_ticks`打印`ticks`，`num`自增1。如果`num`等于10，就调用`sbi_shutdown`函数关机。

定时器中断处理流程：在`kern/driver/clock.c`中，`clock_init`使能时钟中断，并设置第一个时钟中断事件，初始化一个定时器。当定时器到达时间时，会触发一次时钟中断，处理器接收到信号后，会执行中断服务程序（ISR），根据 `stvec` 寄存器中保存的地址跳转到中断处理程序的入口点，即`kern/trap/trapentry.S`的 `__alltraps`。`__alltraps` 调用 `SAVE_ALL` 来保存上下文，然后跳转到 `trap` 函数。在 `kern/trap/trap.c` 中，`trap` 函数实际上把中断处理、异常处理的工作分发给了`interrupt_handler`、`exception_handler`，这些函数再根据中断或异常的不同类型来处理。对于时钟中断，`interrupt_handler`函数会设置下一次时钟中断事件，并累加计数器，进行相关处理。中断处理程序执行完毕后，`__trapret` 会调用 `RESTORE_ALL` 宏恢复保存的上下文，然后使用 `sret` 指令从中断中返回，恢复到中断发生前的执行状态。

修改代码：
```
clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
if (++ticks % TICK_NUM == 0) {
    print_ticks();
    if(++num == 10)
        sbi_shutdown();
}
```
运行`make qemu`，输出如下：
```
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
100 ticks
```

#### 扩展练习 Challenge1：描述与理解中断流程
回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中`mov a0，sp`的目的是什么？`SAVE_ALL`中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？请说明理由。

答：在`kern/driver/clock.c`中，`clock_init`使能时钟中断，并设置第一个时钟中断事件，初始化一个定时器。当定时器到达时间时，会触发一次时钟中断，处理器接收到信号后，会执行中断服务程序（ISR），根据 `stvec` 寄存器中保存的地址跳转到中断处理程序的入口点，即`kern/trap/trapentry.S`的 `__alltraps`。`__alltraps` 调用 `SAVE_ALL` 来保存上下文，然后跳转到 `trap` 函数。在 `kern/trap/trap.c` 中，`trap` 函数实际上把中断处理、异常处理的工作分发给了`interrupt_handler`、`exception_handler`，这些函数再根据中断或异常的不同类型来处理。中断处理程序执行完毕后，`__trapret` 会调用 `RESTORE_ALL` 宏恢复保存的上下文，然后使用 `sret` 指令从中断中返回，恢复到中断发生前的执行状态。

`mov a0, sp` 将当前栈指针 `sp` 的值保存到 `a0` 寄存器中。根据 RISC-V 的调用约定，`a0~a7`寄存器用于存储函数参数，中断处理程序 `trap` 可以从 `a0` 寄存器中读取当前栈指针的值。
    
`SAVE_ALL` 中寄存器保存在栈中的位置是通过栈指针的偏移量和寄存器的顺序来确定的。`addi sp, sp, -36 * REGBYTES` 指令将栈指针 `sp` 向低地址方向移动 `36 * REGBYTES` 字节，这样为保存32个通用寄存器和4个与中断有关的CSR分配了足够的空间。

每个中断不要保存所有寄存器，在恢复上下文的代码中，4个与中断有关的CSR只恢复 `status` 和 `epc` 寄存器，而不恢复 `badaddr` 和 `cause` 寄存器，这是因为status 寄存器保存了程序在中断发生时的状态；epc 寄存器：保存了中断发生时的程序计数器（PC）值；badaddr 寄存器保存了导致异常的地址； cause 寄存器保存了异常的原因。在中断处理完成后，异常发生的地址以及原因通常不再需要，所以可以不用恢复这两个寄存器。
#### 扩增练习 Challenge2：理解上下文切换机制
回答：在`trapentry.S`中汇编代码 `csrw sscratch, sp`；`csrrw s0, sscratch, x0`实现了什么操作，目的是什么？`save all`里面保存了`stval scause`这些CSR，而在`restore all`里面却不还原它们？那这样store的意义何在呢？

答：`csrw sscratch, sp`将当前的栈指针 `sp` 的值写入`sscratch`寄存器。`sscratch`寄存器是一个用于存储临时数据的CSR寄存器。目的是保存当前的栈指针，以便在处理中断时能够通过该值恢复中断发生时的栈状态。

`csrrw s0, sscratch, x0`将`sscratch`寄存器的值读入`s0`寄存器，并将`x0`寄存器的值（0）写入到`sscratch`寄存器中。 目的是清空`sscratch`寄存器，确保如果发生嵌套中断时，可以通过`sscratch`寄存器判断中断是来自内核态的。

在中断处理完毕后，`stval`和`scause`的值不再有意义。因为它们只是记录了中断发生时的错误信息，而一旦中断处理完毕，这些信息就不需要恢复到原来的状态。
#### 扩展练习Challenge3：完善异常中断
编程完善在触发一条非法指令异常`mret`和，在 `kern/trap/trap.c`的异常处理函数中捕获，并对其进行处理，简单输出异常类型和异常指令触发地址，即“Illegal instruction caught at 0x(地址)”，“ebreak caught at 0x（地址）”与“Exception type:Illegal instruction"，“Exception type: breakpoint”。

答：修改代码：
```
// lab1/kern/trap/trap.c

case CAUSE_ILLEGAL_INSTRUCTION:
             // 非法指令异常处理
             /* LAB1 CHALLENGE3   2213410 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
            tf->epc += 4;
            break;
        case CAUSE_BREAKPOINT:
            //断点异常处理
            /* LAB1 CHALLLENGE3   2213410 :  */
            /*(1)输出指令异常类型（ breakpoint）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type: breakpoint\n");
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
            tf->epc += 4;
            break;


// kern/init/init.c

intr_enable(); // enable irq interrupt

asm("mret");// 测试非法指令异常
asm("ebreak");// 测试断点异常

while (1)
        ;
```
运行`make qemu`，输出如下：
```
sbi_emulate_csr_read: hartid0: invalid csr_num=0x302
Exception type:Illegal instruction
Illegal instruction caught at 0x0000000080200050
Exception type: breakpoint
ebreak caught at 0x0000000080200054
```