
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	0040006f          	j	8020000c <kern_init>

000000008020000c <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000c:	00004517          	auipc	a0,0x4
    80200010:	00450513          	addi	a0,a0,4 # 80204010 <edata>
    80200014:	00004617          	auipc	a2,0x4
    80200018:	01460613          	addi	a2,a2,20 # 80204028 <end>
int kern_init(void) {
    8020001c:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001e:	8e09                	sub	a2,a2,a0
    80200020:	4581                	li	a1,0
int kern_init(void) {
    80200022:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200024:	5e2000ef          	jal	ra,80200606 <memset>

    cons_init();  // init the console
    80200028:	154000ef          	jal	ra,8020017c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	a3458593          	addi	a1,a1,-1484 # 80200a60 <etext+0x6>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	a4c50513          	addi	a0,a0,-1460 # 80200a80 <etext+0x26>
    8020003c:	036000ef          	jal	ra,80200072 <cprintf>

    print_kerninfo();
    80200040:	068000ef          	jal	ra,802000a8 <print_kerninfo>

    // grade_backtrace();

    //trap.h的函数，初始化中断
    idt_init();  // init interrupt descriptor table
    80200044:	148000ef          	jal	ra,8020018c <idt_init>

    // rdtime in mbare mode crashes
    //clock.h的函数，初始化时钟中断
    clock_init();  // init clock interrupt
    80200048:	0f0000ef          	jal	ra,80200138 <clock_init>

    //intr.h的函数，使能中断
    intr_enable();  // enable irq interrupt
    8020004c:	13a000ef          	jal	ra,80200186 <intr_enable>
    
    asm("mret");// 测试非法指令异常
    80200050:	30200073          	mret
    asm("ebreak");// 测试断点异常
    80200054:	9002                	ebreak

    while (1)
        ;
    80200056:	a001                	j	80200056 <kern_init+0x4a>

0000000080200058 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200058:	1141                	addi	sp,sp,-16
    8020005a:	e022                	sd	s0,0(sp)
    8020005c:	e406                	sd	ra,8(sp)
    8020005e:	842e                	mv	s0,a1
    cons_putc(c);
    80200060:	11e000ef          	jal	ra,8020017e <cons_putc>
    (*cnt)++;
    80200064:	401c                	lw	a5,0(s0)
}
    80200066:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200068:	2785                	addiw	a5,a5,1
    8020006a:	c01c                	sw	a5,0(s0)
}
    8020006c:	6402                	ld	s0,0(sp)
    8020006e:	0141                	addi	sp,sp,16
    80200070:	8082                	ret

0000000080200072 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200072:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200074:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200078:	8e2a                	mv	t3,a0
    8020007a:	f42e                	sd	a1,40(sp)
    8020007c:	f832                	sd	a2,48(sp)
    8020007e:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200080:	00000517          	auipc	a0,0x0
    80200084:	fd850513          	addi	a0,a0,-40 # 80200058 <cputch>
    80200088:	004c                	addi	a1,sp,4
    8020008a:	869a                	mv	a3,t1
    8020008c:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    8020008e:	ec06                	sd	ra,24(sp)
    80200090:	e0ba                	sd	a4,64(sp)
    80200092:	e4be                	sd	a5,72(sp)
    80200094:	e8c2                	sd	a6,80(sp)
    80200096:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200098:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    8020009a:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009c:	5e8000ef          	jal	ra,80200684 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000a0:	60e2                	ld	ra,24(sp)
    802000a2:	4512                	lw	a0,4(sp)
    802000a4:	6125                	addi	sp,sp,96
    802000a6:	8082                	ret

00000000802000a8 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a8:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000aa:	00001517          	auipc	a0,0x1
    802000ae:	9de50513          	addi	a0,a0,-1570 # 80200a88 <etext+0x2e>
void print_kerninfo(void) {
    802000b2:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b4:	fbfff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b8:	00000597          	auipc	a1,0x0
    802000bc:	f5458593          	addi	a1,a1,-172 # 8020000c <kern_init>
    802000c0:	00001517          	auipc	a0,0x1
    802000c4:	9e850513          	addi	a0,a0,-1560 # 80200aa8 <etext+0x4e>
    802000c8:	fabff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000cc:	00001597          	auipc	a1,0x1
    802000d0:	98e58593          	addi	a1,a1,-1650 # 80200a5a <etext>
    802000d4:	00001517          	auipc	a0,0x1
    802000d8:	9f450513          	addi	a0,a0,-1548 # 80200ac8 <etext+0x6e>
    802000dc:	f97ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000e0:	00004597          	auipc	a1,0x4
    802000e4:	f3058593          	addi	a1,a1,-208 # 80204010 <edata>
    802000e8:	00001517          	auipc	a0,0x1
    802000ec:	a0050513          	addi	a0,a0,-1536 # 80200ae8 <etext+0x8e>
    802000f0:	f83ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f4:	00004597          	auipc	a1,0x4
    802000f8:	f3458593          	addi	a1,a1,-204 # 80204028 <end>
    802000fc:	00001517          	auipc	a0,0x1
    80200100:	a0c50513          	addi	a0,a0,-1524 # 80200b08 <etext+0xae>
    80200104:	f6fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200108:	00004597          	auipc	a1,0x4
    8020010c:	31f58593          	addi	a1,a1,799 # 80204427 <end+0x3ff>
    80200110:	00000797          	auipc	a5,0x0
    80200114:	efc78793          	addi	a5,a5,-260 # 8020000c <kern_init>
    80200118:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011c:	43f7d593          	srai	a1,a5,0x3f
}
    80200120:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200122:	3ff5f593          	andi	a1,a1,1023
    80200126:	95be                	add	a1,a1,a5
    80200128:	85a9                	srai	a1,a1,0xa
    8020012a:	00001517          	auipc	a0,0x1
    8020012e:	9fe50513          	addi	a0,a0,-1538 # 80200b28 <etext+0xce>
}
    80200132:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200134:	f3fff06f          	j	80200072 <cprintf>

0000000080200138 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200138:	1141                	addi	sp,sp,-16
    8020013a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    // sie这个CSR可以单独使能/禁用某个来源的中断。默认时钟中断是关闭的
    // 所以我们要在初始化的时候，使能时钟中断
    set_csr(sie, MIP_STIP);
    8020013c:	02000793          	li	a5,32
    80200140:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200144:	c0102573          	rdtime	a0
    cprintf("++ setup timer interrupts\n");
}

//设置时钟中断：timer的数值变为当前时间 + timebase 后，触发一次时钟中断
//对于QEMU, timer增加1，过去了10^-7 s， 也就是100ns
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200148:	67e1                	lui	a5,0x18
    8020014a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    8020014e:	953e                	add	a0,a0,a5
    80200150:	0d3000ef          	jal	ra,80200a22 <sbi_set_timer>
}
    80200154:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200156:	00004797          	auipc	a5,0x4
    8020015a:	ec07b523          	sd	zero,-310(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015e:	00001517          	auipc	a0,0x1
    80200162:	9fa50513          	addi	a0,a0,-1542 # 80200b58 <etext+0xfe>
}
    80200166:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200168:	f0bff06f          	j	80200072 <cprintf>

000000008020016c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020016c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200170:	67e1                	lui	a5,0x18
    80200172:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200176:	953e                	add	a0,a0,a5
    80200178:	0ab0006f          	j	80200a22 <sbi_set_timer>

000000008020017c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020017c:	8082                	ret

000000008020017e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020017e:	0ff57513          	andi	a0,a0,255
    80200182:	0850006f          	j	80200a06 <sbi_console_putchar>

0000000080200186 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt, 设置sstatus的Supervisor中断使能位 */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200186:	100167f3          	csrrsi	a5,sstatus,2
    8020018a:	8082                	ret

000000008020018c <idt_init>:
     * presently executing in the kernel */
    //约定：若中断前处于S态，sscratch为0
    //若中断前处于U态，sscratch存储内核栈地址
    //那么之后就可以通过sscratch的数值判断是内核态产生的中断还是用户态产生的中断
    //我们现在是内核态所以给sscratch置零
    write_csr(sscratch, 0);
    8020018c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    //我们保证__alltraps的地址是四字节对齐的，将__alltraps这个符号的地址直接写到stvec寄存器
    write_csr(stvec, &__alltraps);
    80200190:	00000797          	auipc	a5,0x0
    80200194:	3a478793          	addi	a5,a5,932 # 80200534 <__alltraps>
    80200198:	10579073          	csrw	stvec,a5
}
    8020019c:	8082                	ret

000000008020019e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    802001a0:	1141                	addi	sp,sp,-16
    802001a2:	e022                	sd	s0,0(sp)
    802001a4:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a6:	00001517          	auipc	a0,0x1
    802001aa:	b4a50513          	addi	a0,a0,-1206 # 80200cf0 <etext+0x296>
void print_regs(struct pushregs *gpr) {
    802001ae:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001b0:	ec3ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b4:	640c                	ld	a1,8(s0)
    802001b6:	00001517          	auipc	a0,0x1
    802001ba:	b5250513          	addi	a0,a0,-1198 # 80200d08 <etext+0x2ae>
    802001be:	eb5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c2:	680c                	ld	a1,16(s0)
    802001c4:	00001517          	auipc	a0,0x1
    802001c8:	b5c50513          	addi	a0,a0,-1188 # 80200d20 <etext+0x2c6>
    802001cc:	ea7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001d0:	6c0c                	ld	a1,24(s0)
    802001d2:	00001517          	auipc	a0,0x1
    802001d6:	b6650513          	addi	a0,a0,-1178 # 80200d38 <etext+0x2de>
    802001da:	e99ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001de:	700c                	ld	a1,32(s0)
    802001e0:	00001517          	auipc	a0,0x1
    802001e4:	b7050513          	addi	a0,a0,-1168 # 80200d50 <etext+0x2f6>
    802001e8:	e8bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001ec:	740c                	ld	a1,40(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	b7a50513          	addi	a0,a0,-1158 # 80200d68 <etext+0x30e>
    802001f6:	e7dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001fa:	780c                	ld	a1,48(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	b8450513          	addi	a0,a0,-1148 # 80200d80 <etext+0x326>
    80200204:	e6fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200208:	7c0c                	ld	a1,56(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	b8e50513          	addi	a0,a0,-1138 # 80200d98 <etext+0x33e>
    80200212:	e61ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200216:	602c                	ld	a1,64(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	b9850513          	addi	a0,a0,-1128 # 80200db0 <etext+0x356>
    80200220:	e53ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200224:	642c                	ld	a1,72(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	ba250513          	addi	a0,a0,-1118 # 80200dc8 <etext+0x36e>
    8020022e:	e45ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200232:	682c                	ld	a1,80(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	bac50513          	addi	a0,a0,-1108 # 80200de0 <etext+0x386>
    8020023c:	e37ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200240:	6c2c                	ld	a1,88(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	bb650513          	addi	a0,a0,-1098 # 80200df8 <etext+0x39e>
    8020024a:	e29ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020024e:	702c                	ld	a1,96(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	bc050513          	addi	a0,a0,-1088 # 80200e10 <etext+0x3b6>
    80200258:	e1bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020025c:	742c                	ld	a1,104(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	bca50513          	addi	a0,a0,-1078 # 80200e28 <etext+0x3ce>
    80200266:	e0dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020026a:	782c                	ld	a1,112(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	bd450513          	addi	a0,a0,-1068 # 80200e40 <etext+0x3e6>
    80200274:	dffff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200278:	7c2c                	ld	a1,120(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	bde50513          	addi	a0,a0,-1058 # 80200e58 <etext+0x3fe>
    80200282:	df1ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200286:	604c                	ld	a1,128(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	be850513          	addi	a0,a0,-1048 # 80200e70 <etext+0x416>
    80200290:	de3ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200294:	644c                	ld	a1,136(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	bf250513          	addi	a0,a0,-1038 # 80200e88 <etext+0x42e>
    8020029e:	dd5ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a2:	684c                	ld	a1,144(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	bfc50513          	addi	a0,a0,-1028 # 80200ea0 <etext+0x446>
    802002ac:	dc7ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002b0:	6c4c                	ld	a1,152(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	c0650513          	addi	a0,a0,-1018 # 80200eb8 <etext+0x45e>
    802002ba:	db9ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002be:	704c                	ld	a1,160(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	c1050513          	addi	a0,a0,-1008 # 80200ed0 <etext+0x476>
    802002c8:	dabff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002cc:	744c                	ld	a1,168(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	c1a50513          	addi	a0,a0,-998 # 80200ee8 <etext+0x48e>
    802002d6:	d9dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002da:	784c                	ld	a1,176(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	c2450513          	addi	a0,a0,-988 # 80200f00 <etext+0x4a6>
    802002e4:	d8fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e8:	7c4c                	ld	a1,184(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	c2e50513          	addi	a0,a0,-978 # 80200f18 <etext+0x4be>
    802002f2:	d81ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f6:	606c                	ld	a1,192(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	c3850513          	addi	a0,a0,-968 # 80200f30 <etext+0x4d6>
    80200300:	d73ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200304:	646c                	ld	a1,200(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	c4250513          	addi	a0,a0,-958 # 80200f48 <etext+0x4ee>
    8020030e:	d65ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200312:	686c                	ld	a1,208(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	c4c50513          	addi	a0,a0,-948 # 80200f60 <etext+0x506>
    8020031c:	d57ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200320:	6c6c                	ld	a1,216(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	c5650513          	addi	a0,a0,-938 # 80200f78 <etext+0x51e>
    8020032a:	d49ff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020032e:	706c                	ld	a1,224(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	c6050513          	addi	a0,a0,-928 # 80200f90 <etext+0x536>
    80200338:	d3bff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020033c:	746c                	ld	a1,232(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	c6a50513          	addi	a0,a0,-918 # 80200fa8 <etext+0x54e>
    80200346:	d2dff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020034a:	786c                	ld	a1,240(s0)
    8020034c:	00001517          	auipc	a0,0x1
    80200350:	c7450513          	addi	a0,a0,-908 # 80200fc0 <etext+0x566>
    80200354:	d1fff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	7c6c                	ld	a1,248(s0)
}
    8020035a:	6402                	ld	s0,0(sp)
    8020035c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035e:	00001517          	auipc	a0,0x1
    80200362:	c7a50513          	addi	a0,a0,-902 # 80200fd8 <etext+0x57e>
}
    80200366:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200368:	d0bff06f          	j	80200072 <cprintf>

000000008020036c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020036c:	1141                	addi	sp,sp,-16
    8020036e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200372:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200374:	00001517          	auipc	a0,0x1
    80200378:	c7c50513          	addi	a0,a0,-900 # 80200ff0 <etext+0x596>
void print_trapframe(struct trapframe *tf) {
    8020037c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020037e:	cf5ff0ef          	jal	ra,80200072 <cprintf>
    print_regs(&tf->gpr);
    80200382:	8522                	mv	a0,s0
    80200384:	e1bff0ef          	jal	ra,8020019e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200388:	10043583          	ld	a1,256(s0)
    8020038c:	00001517          	auipc	a0,0x1
    80200390:	c7c50513          	addi	a0,a0,-900 # 80201008 <etext+0x5ae>
    80200394:	cdfff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200398:	10843583          	ld	a1,264(s0)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	c8450513          	addi	a0,a0,-892 # 80201020 <etext+0x5c6>
    802003a4:	ccfff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a8:	11043583          	ld	a1,272(s0)
    802003ac:	00001517          	auipc	a0,0x1
    802003b0:	c8c50513          	addi	a0,a0,-884 # 80201038 <etext+0x5de>
    802003b4:	cbfff0ef          	jal	ra,80200072 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	11843583          	ld	a1,280(s0)
}
    802003bc:	6402                	ld	s0,0(sp)
    802003be:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c0:	00001517          	auipc	a0,0x1
    802003c4:	c9050513          	addi	a0,a0,-880 # 80201050 <etext+0x5f6>
}
    802003c8:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ca:	ca9ff06f          	j	80200072 <cprintf>

00000000802003ce <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003ce:	11853783          	ld	a5,280(a0)
    802003d2:	577d                	li	a4,-1
    802003d4:	8305                	srli	a4,a4,0x1
    802003d6:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d8:	472d                	li	a4,11
    802003da:	06f76f63          	bltu	a4,a5,80200458 <interrupt_handler+0x8a>
    802003de:	00000717          	auipc	a4,0x0
    802003e2:	79670713          	addi	a4,a4,1942 # 80200b74 <etext+0x11a>
    802003e6:	078a                	slli	a5,a5,0x2
    802003e8:	97ba                	add	a5,a5,a4
    802003ea:	439c                	lw	a5,0(a5)
    802003ec:	97ba                	add	a5,a5,a4
    802003ee:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003f0:	00001517          	auipc	a0,0x1
    802003f4:	8b050513          	addi	a0,a0,-1872 # 80200ca0 <etext+0x246>
    802003f8:	c7bff06f          	j	80200072 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	88450513          	addi	a0,a0,-1916 # 80200c80 <etext+0x226>
    80200404:	c6fff06f          	j	80200072 <cprintf>
            cprintf("User software interrupt\n");
    80200408:	00001517          	auipc	a0,0x1
    8020040c:	83850513          	addi	a0,a0,-1992 # 80200c40 <etext+0x1e6>
    80200410:	c63ff06f          	j	80200072 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200414:	00001517          	auipc	a0,0x1
    80200418:	84c50513          	addi	a0,a0,-1972 # 80200c60 <etext+0x206>
    8020041c:	c57ff06f          	j	80200072 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200420:	00001517          	auipc	a0,0x1
    80200424:	8b050513          	addi	a0,a0,-1872 # 80200cd0 <etext+0x276>
    80200428:	c4bff06f          	j	80200072 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020042c:	1141                	addi	sp,sp,-16
    8020042e:	e406                	sd	ra,8(sp)
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
    80200430:	d3dff0ef          	jal	ra,8020016c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    80200434:	00004797          	auipc	a5,0x4
    80200438:	bec78793          	addi	a5,a5,-1044 # 80204020 <ticks>
    8020043c:	639c                	ld	a5,0(a5)
    8020043e:	06400713          	li	a4,100
    80200442:	0785                	addi	a5,a5,1
    80200444:	02e7f733          	remu	a4,a5,a4
    80200448:	00004697          	auipc	a3,0x4
    8020044c:	bcf6bc23          	sd	a5,-1064(a3) # 80204020 <ticks>
    80200450:	c711                	beqz	a4,8020045c <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200452:	60a2                	ld	ra,8(sp)
    80200454:	0141                	addi	sp,sp,16
    80200456:	8082                	ret
            print_trapframe(tf);
    80200458:	f15ff06f          	j	8020036c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020045c:	06400593          	li	a1,100
    80200460:	00001517          	auipc	a0,0x1
    80200464:	86050513          	addi	a0,a0,-1952 # 80200cc0 <etext+0x266>
    80200468:	c0bff0ef          	jal	ra,80200072 <cprintf>
                if(++num == 10)
    8020046c:	00004797          	auipc	a5,0x4
    80200470:	ba478793          	addi	a5,a5,-1116 # 80204010 <edata>
    80200474:	639c                	ld	a5,0(a5)
    80200476:	4729                	li	a4,10
    80200478:	0785                	addi	a5,a5,1
    8020047a:	00004697          	auipc	a3,0x4
    8020047e:	b8f6bb23          	sd	a5,-1130(a3) # 80204010 <edata>
    80200482:	fce798e3          	bne	a5,a4,80200452 <interrupt_handler+0x84>
}
    80200486:	60a2                	ld	ra,8(sp)
    80200488:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    8020048a:	5b40006f          	j	80200a3e <sbi_shutdown>

000000008020048e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020048e:	11853783          	ld	a5,280(a0)
    80200492:	472d                	li	a4,11
    80200494:	02f76863          	bltu	a4,a5,802004c4 <exception_handler+0x36>
    80200498:	4705                	li	a4,1
    8020049a:	00f71733          	sll	a4,a4,a5
    8020049e:	6785                	lui	a5,0x1
    802004a0:	17cd                	addi	a5,a5,-13
    802004a2:	8ff9                	and	a5,a5,a4
    802004a4:	ef99                	bnez	a5,802004c2 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
    802004a6:	1141                	addi	sp,sp,-16
    802004a8:	e022                	sd	s0,0(sp)
    802004aa:	e406                	sd	ra,8(sp)
    802004ac:	00877793          	andi	a5,a4,8
    802004b0:	842a                	mv	s0,a0
    802004b2:	e3b1                	bnez	a5,802004f6 <exception_handler+0x68>
    802004b4:	8b11                	andi	a4,a4,4
    802004b6:	eb09                	bnez	a4,802004c8 <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b8:	6402                	ld	s0,0(sp)
    802004ba:	60a2                	ld	ra,8(sp)
    802004bc:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004be:	eafff06f          	j	8020036c <print_trapframe>
    802004c2:	8082                	ret
    802004c4:	ea9ff06f          	j	8020036c <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");
    802004c8:	00000517          	auipc	a0,0x0
    802004cc:	6e050513          	addi	a0,a0,1760 # 80200ba8 <etext+0x14e>
    802004d0:	ba3ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("Illegal instruction caught at 0x%016llx\n", tf->epc);
    802004d4:	10843583          	ld	a1,264(s0)
    802004d8:	00000517          	auipc	a0,0x0
    802004dc:	6f850513          	addi	a0,a0,1784 # 80200bd0 <etext+0x176>
    802004e0:	b93ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4;
    802004e4:	10843783          	ld	a5,264(s0)
}
    802004e8:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    802004ea:	0791                	addi	a5,a5,4
    802004ec:	10f43423          	sd	a5,264(s0)
}
    802004f0:	6402                	ld	s0,0(sp)
    802004f2:	0141                	addi	sp,sp,16
    802004f4:	8082                	ret
            cprintf("Exception type: breakpoint\n");
    802004f6:	00000517          	auipc	a0,0x0
    802004fa:	70a50513          	addi	a0,a0,1802 # 80200c00 <etext+0x1a6>
    802004fe:	b75ff0ef          	jal	ra,80200072 <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
    80200502:	10843583          	ld	a1,264(s0)
    80200506:	00000517          	auipc	a0,0x0
    8020050a:	71a50513          	addi	a0,a0,1818 # 80200c20 <etext+0x1c6>
    8020050e:	b65ff0ef          	jal	ra,80200072 <cprintf>
            tf->epc += 4;
    80200512:	10843783          	ld	a5,264(s0)
}
    80200516:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
    80200518:	0791                	addi	a5,a5,4
    8020051a:	10f43423          	sd	a5,264(s0)
}
    8020051e:	6402                	ld	s0,0(sp)
    80200520:	0141                	addi	sp,sp,16
    80200522:	8082                	ret

0000000080200524 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    //scause的最高位是1，说明trap是由中断引起的
    if ((intptr_t)tf->cause < 0) {
    80200524:	11853783          	ld	a5,280(a0)
    80200528:	0007c463          	bltz	a5,80200530 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    8020052c:	f63ff06f          	j	8020048e <exception_handler>
        interrupt_handler(tf);
    80200530:	e9fff06f          	j	802003ce <interrupt_handler>

0000000080200534 <__alltraps>:

    .globl __alltraps

.align(2) #中断入口点 __alltraps必须四字节对齐
__alltraps:
    SAVE_ALL #保存上下文
    80200534:	14011073          	csrw	sscratch,sp
    80200538:	712d                	addi	sp,sp,-288
    8020053a:	e002                	sd	zero,0(sp)
    8020053c:	e406                	sd	ra,8(sp)
    8020053e:	ec0e                	sd	gp,24(sp)
    80200540:	f012                	sd	tp,32(sp)
    80200542:	f416                	sd	t0,40(sp)
    80200544:	f81a                	sd	t1,48(sp)
    80200546:	fc1e                	sd	t2,56(sp)
    80200548:	e0a2                	sd	s0,64(sp)
    8020054a:	e4a6                	sd	s1,72(sp)
    8020054c:	e8aa                	sd	a0,80(sp)
    8020054e:	ecae                	sd	a1,88(sp)
    80200550:	f0b2                	sd	a2,96(sp)
    80200552:	f4b6                	sd	a3,104(sp)
    80200554:	f8ba                	sd	a4,112(sp)
    80200556:	fcbe                	sd	a5,120(sp)
    80200558:	e142                	sd	a6,128(sp)
    8020055a:	e546                	sd	a7,136(sp)
    8020055c:	e94a                	sd	s2,144(sp)
    8020055e:	ed4e                	sd	s3,152(sp)
    80200560:	f152                	sd	s4,160(sp)
    80200562:	f556                	sd	s5,168(sp)
    80200564:	f95a                	sd	s6,176(sp)
    80200566:	fd5e                	sd	s7,184(sp)
    80200568:	e1e2                	sd	s8,192(sp)
    8020056a:	e5e6                	sd	s9,200(sp)
    8020056c:	e9ea                	sd	s10,208(sp)
    8020056e:	edee                	sd	s11,216(sp)
    80200570:	f1f2                	sd	t3,224(sp)
    80200572:	f5f6                	sd	t4,232(sp)
    80200574:	f9fa                	sd	t5,240(sp)
    80200576:	fdfe                	sd	t6,248(sp)
    80200578:	14001473          	csrrw	s0,sscratch,zero
    8020057c:	100024f3          	csrr	s1,sstatus
    80200580:	14102973          	csrr	s2,sepc
    80200584:	143029f3          	csrr	s3,stval
    80200588:	14202a73          	csrr	s4,scause
    8020058c:	e822                	sd	s0,16(sp)
    8020058e:	e226                	sd	s1,256(sp)
    80200590:	e64a                	sd	s2,264(sp)
    80200592:	ea4e                	sd	s3,272(sp)
    80200594:	ee52                	sd	s4,280(sp)

    move  a0, sp #传递参数。
    80200596:	850a                	mv	a0,sp
    #按照RISCV calling convention, a0寄存器传递参数给接下来调用的函数trap。
    #trap是trap.c里面的一个C语言函数，也就是我们的中断处理程序
    jal trap 
    80200598:	f8dff0ef          	jal	ra,80200524 <trap>

000000008020059c <__trapret>:
    #trap函数指向完之后，会回到这里向下继续执行__trapret里面的内容，RESTORE_ALL,sret

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020059c:	6492                	ld	s1,256(sp)
    8020059e:	6932                	ld	s2,264(sp)
    802005a0:	10049073          	csrw	sstatus,s1
    802005a4:	14191073          	csrw	sepc,s2
    802005a8:	60a2                	ld	ra,8(sp)
    802005aa:	61e2                	ld	gp,24(sp)
    802005ac:	7202                	ld	tp,32(sp)
    802005ae:	72a2                	ld	t0,40(sp)
    802005b0:	7342                	ld	t1,48(sp)
    802005b2:	73e2                	ld	t2,56(sp)
    802005b4:	6406                	ld	s0,64(sp)
    802005b6:	64a6                	ld	s1,72(sp)
    802005b8:	6546                	ld	a0,80(sp)
    802005ba:	65e6                	ld	a1,88(sp)
    802005bc:	7606                	ld	a2,96(sp)
    802005be:	76a6                	ld	a3,104(sp)
    802005c0:	7746                	ld	a4,112(sp)
    802005c2:	77e6                	ld	a5,120(sp)
    802005c4:	680a                	ld	a6,128(sp)
    802005c6:	68aa                	ld	a7,136(sp)
    802005c8:	694a                	ld	s2,144(sp)
    802005ca:	69ea                	ld	s3,152(sp)
    802005cc:	7a0a                	ld	s4,160(sp)
    802005ce:	7aaa                	ld	s5,168(sp)
    802005d0:	7b4a                	ld	s6,176(sp)
    802005d2:	7bea                	ld	s7,184(sp)
    802005d4:	6c0e                	ld	s8,192(sp)
    802005d6:	6cae                	ld	s9,200(sp)
    802005d8:	6d4e                	ld	s10,208(sp)
    802005da:	6dee                	ld	s11,216(sp)
    802005dc:	7e0e                	ld	t3,224(sp)
    802005de:	7eae                	ld	t4,232(sp)
    802005e0:	7f4e                	ld	t5,240(sp)
    802005e2:	7fee                	ld	t6,248(sp)
    802005e4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    802005e6:	10200073          	sret

00000000802005ea <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    802005ea:	872a                	mv	a4,a0
    size_t cnt = 0;
    802005ec:	4501                	li	a0,0
    while (cnt < len && *s ++ != '\0') {
    802005ee:	e589                	bnez	a1,802005f8 <strnlen+0xe>
    802005f0:	a811                	j	80200604 <strnlen+0x1a>
        cnt ++;
    802005f2:	0505                	addi	a0,a0,1
    while (cnt < len && *s ++ != '\0') {
    802005f4:	00a58763          	beq	a1,a0,80200602 <strnlen+0x18>
    802005f8:	00a707b3          	add	a5,a4,a0
    802005fc:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0x801ff000>
    80200600:	fbed                	bnez	a5,802005f2 <strnlen+0x8>
    }
    return cnt;
}
    80200602:	8082                	ret
    80200604:	8082                	ret

0000000080200606 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200606:	ca01                	beqz	a2,80200616 <memset+0x10>
    80200608:	962a                	add	a2,a2,a0
    char *p = s;
    8020060a:	87aa                	mv	a5,a0
        *p ++ = c;
    8020060c:	0785                	addi	a5,a5,1
    8020060e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200612:	fec79de3          	bne	a5,a2,8020060c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200616:	8082                	ret

0000000080200618 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200618:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020061c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020061e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200622:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200624:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200628:	f022                	sd	s0,32(sp)
    8020062a:	ec26                	sd	s1,24(sp)
    8020062c:	e84a                	sd	s2,16(sp)
    8020062e:	f406                	sd	ra,40(sp)
    80200630:	e44e                	sd	s3,8(sp)
    80200632:	84aa                	mv	s1,a0
    80200634:	892e                	mv	s2,a1
    80200636:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    8020063a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    8020063c:	03067e63          	bleu	a6,a2,80200678 <printnum+0x60>
    80200640:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    80200642:	00805763          	blez	s0,80200650 <printnum+0x38>
    80200646:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200648:	85ca                	mv	a1,s2
    8020064a:	854e                	mv	a0,s3
    8020064c:	9482                	jalr	s1
        while (-- width > 0)
    8020064e:	fc65                	bnez	s0,80200646 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    80200650:	1a02                	slli	s4,s4,0x20
    80200652:	020a5a13          	srli	s4,s4,0x20
    80200656:	00001797          	auipc	a5,0x1
    8020065a:	a1278793          	addi	a5,a5,-1518 # 80201068 <etext+0x60e>
}
    8020065e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200660:	9a3e                	add	s4,s4,a5
    80200662:	000a4503          	lbu	a0,0(s4)
}
    80200666:	70a2                	ld	ra,40(sp)
    80200668:	69a2                	ld	s3,8(sp)
    8020066a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020066c:	85ca                	mv	a1,s2
    8020066e:	8326                	mv	t1,s1
}
    80200670:	6942                	ld	s2,16(sp)
    80200672:	64e2                	ld	s1,24(sp)
    80200674:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200676:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200678:	03065633          	divu	a2,a2,a6
    8020067c:	8722                	mv	a4,s0
    8020067e:	f9bff0ef          	jal	ra,80200618 <printnum>
    80200682:	b7f9                	j	80200650 <printnum+0x38>

0000000080200684 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200684:	7119                	addi	sp,sp,-128
    80200686:	f4a6                	sd	s1,104(sp)
    80200688:	f0ca                	sd	s2,96(sp)
    8020068a:	ecce                	sd	s3,88(sp)
    8020068c:	e8d2                	sd	s4,80(sp)
    8020068e:	e4d6                	sd	s5,72(sp)
    80200690:	e0da                	sd	s6,64(sp)
    80200692:	fc5e                	sd	s7,56(sp)
    80200694:	f06a                	sd	s10,32(sp)
    80200696:	fc86                	sd	ra,120(sp)
    80200698:	f8a2                	sd	s0,112(sp)
    8020069a:	f862                	sd	s8,48(sp)
    8020069c:	f466                	sd	s9,40(sp)
    8020069e:	ec6e                	sd	s11,24(sp)
    802006a0:	892a                	mv	s2,a0
    802006a2:	84ae                	mv	s1,a1
    802006a4:	8d32                	mv	s10,a2
    802006a6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006a8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    802006ac:	5b7d                	li	s6,-1
    802006ae:	00001a97          	auipc	s5,0x1
    802006b2:	9eea8a93          	addi	s5,s5,-1554 # 8020109c <etext+0x642>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802006b6:	00001b97          	auipc	s7,0x1
    802006ba:	bc2b8b93          	addi	s7,s7,-1086 # 80201278 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006be:	000d4503          	lbu	a0,0(s10)
    802006c2:	001d0413          	addi	s0,s10,1
    802006c6:	01350a63          	beq	a0,s3,802006da <vprintfmt+0x56>
            if (ch == '\0') {
    802006ca:	c121                	beqz	a0,8020070a <vprintfmt+0x86>
            putch(ch, putdat);
    802006cc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006ce:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    802006d0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    802006d2:	fff44503          	lbu	a0,-1(s0)
    802006d6:	ff351ae3          	bne	a0,s3,802006ca <vprintfmt+0x46>
    802006da:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    802006de:	02000793          	li	a5,32
        lflag = altflag = 0;
    802006e2:	4c81                	li	s9,0
    802006e4:	4881                	li	a7,0
        width = precision = -1;
    802006e6:	5c7d                	li	s8,-1
    802006e8:	5dfd                	li	s11,-1
    802006ea:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006ee:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006f0:	fdd6059b          	addiw	a1,a2,-35
    802006f4:	0ff5f593          	andi	a1,a1,255
    802006f8:	00140d13          	addi	s10,s0,1
    802006fc:	04b56263          	bltu	a0,a1,80200740 <vprintfmt+0xbc>
    80200700:	058a                	slli	a1,a1,0x2
    80200702:	95d6                	add	a1,a1,s5
    80200704:	4194                	lw	a3,0(a1)
    80200706:	96d6                	add	a3,a3,s5
    80200708:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020070a:	70e6                	ld	ra,120(sp)
    8020070c:	7446                	ld	s0,112(sp)
    8020070e:	74a6                	ld	s1,104(sp)
    80200710:	7906                	ld	s2,96(sp)
    80200712:	69e6                	ld	s3,88(sp)
    80200714:	6a46                	ld	s4,80(sp)
    80200716:	6aa6                	ld	s5,72(sp)
    80200718:	6b06                	ld	s6,64(sp)
    8020071a:	7be2                	ld	s7,56(sp)
    8020071c:	7c42                	ld	s8,48(sp)
    8020071e:	7ca2                	ld	s9,40(sp)
    80200720:	7d02                	ld	s10,32(sp)
    80200722:	6de2                	ld	s11,24(sp)
    80200724:	6109                	addi	sp,sp,128
    80200726:	8082                	ret
            padc = '0';
    80200728:	87b2                	mv	a5,a2
            goto reswitch;
    8020072a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020072e:	846a                	mv	s0,s10
    80200730:	00140d13          	addi	s10,s0,1
    80200734:	fdd6059b          	addiw	a1,a2,-35
    80200738:	0ff5f593          	andi	a1,a1,255
    8020073c:	fcb572e3          	bleu	a1,a0,80200700 <vprintfmt+0x7c>
            putch('%', putdat);
    80200740:	85a6                	mv	a1,s1
    80200742:	02500513          	li	a0,37
    80200746:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200748:	fff44783          	lbu	a5,-1(s0)
    8020074c:	8d22                	mv	s10,s0
    8020074e:	f73788e3          	beq	a5,s3,802006be <vprintfmt+0x3a>
    80200752:	ffed4783          	lbu	a5,-2(s10)
    80200756:	1d7d                	addi	s10,s10,-1
    80200758:	ff379de3          	bne	a5,s3,80200752 <vprintfmt+0xce>
    8020075c:	b78d                	j	802006be <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    8020075e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    80200762:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200766:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200768:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    8020076c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200770:	02d86463          	bltu	a6,a3,80200798 <vprintfmt+0x114>
                ch = *fmt;
    80200774:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200778:	002c169b          	slliw	a3,s8,0x2
    8020077c:	0186873b          	addw	a4,a3,s8
    80200780:	0017171b          	slliw	a4,a4,0x1
    80200784:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200786:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020078a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020078c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200790:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200794:	fed870e3          	bleu	a3,a6,80200774 <vprintfmt+0xf0>
            if (width < 0)
    80200798:	f40ddce3          	bgez	s11,802006f0 <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020079c:	8de2                	mv	s11,s8
    8020079e:	5c7d                	li	s8,-1
    802007a0:	bf81                	j	802006f0 <vprintfmt+0x6c>
            if (width < 0)
    802007a2:	fffdc693          	not	a3,s11
    802007a6:	96fd                	srai	a3,a3,0x3f
    802007a8:	00ddfdb3          	and	s11,s11,a3
    802007ac:	00144603          	lbu	a2,1(s0)
    802007b0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802007b2:	846a                	mv	s0,s10
            goto reswitch;
    802007b4:	bf35                	j	802006f0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    802007b6:	000a2c03          	lw	s8,0(s4)
            goto process_precision;
    802007ba:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802007be:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    802007c0:	846a                	mv	s0,s10
            goto process_precision;
    802007c2:	bfd9                	j	80200798 <vprintfmt+0x114>
    if (lflag >= 2) {
    802007c4:	4705                	li	a4,1
    802007c6:	008a0593          	addi	a1,s4,8
    802007ca:	01174463          	blt	a4,a7,802007d2 <vprintfmt+0x14e>
    else if (lflag) {
    802007ce:	1a088e63          	beqz	a7,8020098a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    802007d2:	000a3603          	ld	a2,0(s4)
    802007d6:	46c1                	li	a3,16
    802007d8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    802007da:	2781                	sext.w	a5,a5
    802007dc:	876e                	mv	a4,s11
    802007de:	85a6                	mv	a1,s1
    802007e0:	854a                	mv	a0,s2
    802007e2:	e37ff0ef          	jal	ra,80200618 <printnum>
            break;
    802007e6:	bde1                	j	802006be <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007e8:	000a2503          	lw	a0,0(s4)
    802007ec:	85a6                	mv	a1,s1
    802007ee:	0a21                	addi	s4,s4,8
    802007f0:	9902                	jalr	s2
            break;
    802007f2:	b5f1                	j	802006be <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007f4:	4705                	li	a4,1
    802007f6:	008a0593          	addi	a1,s4,8
    802007fa:	01174463          	blt	a4,a7,80200802 <vprintfmt+0x17e>
    else if (lflag) {
    802007fe:	18088163          	beqz	a7,80200980 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200802:	000a3603          	ld	a2,0(s4)
    80200806:	46a9                	li	a3,10
    80200808:	8a2e                	mv	s4,a1
    8020080a:	bfc1                	j	802007da <vprintfmt+0x156>
            goto reswitch;
    8020080c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200810:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200812:	846a                	mv	s0,s10
            goto reswitch;
    80200814:	bdf1                	j	802006f0 <vprintfmt+0x6c>
            putch(ch, putdat);
    80200816:	85a6                	mv	a1,s1
    80200818:	02500513          	li	a0,37
    8020081c:	9902                	jalr	s2
            break;
    8020081e:	b545                	j	802006be <vprintfmt+0x3a>
            lflag ++;
    80200820:	00144603          	lbu	a2,1(s0)
    80200824:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200826:	846a                	mv	s0,s10
            goto reswitch;
    80200828:	b5e1                	j	802006f0 <vprintfmt+0x6c>
    if (lflag >= 2) {
    8020082a:	4705                	li	a4,1
    8020082c:	008a0593          	addi	a1,s4,8
    80200830:	01174463          	blt	a4,a7,80200838 <vprintfmt+0x1b4>
    else if (lflag) {
    80200834:	14088163          	beqz	a7,80200976 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    80200838:	000a3603          	ld	a2,0(s4)
    8020083c:	46a1                	li	a3,8
    8020083e:	8a2e                	mv	s4,a1
    80200840:	bf69                	j	802007da <vprintfmt+0x156>
            putch('0', putdat);
    80200842:	03000513          	li	a0,48
    80200846:	85a6                	mv	a1,s1
    80200848:	e03e                	sd	a5,0(sp)
    8020084a:	9902                	jalr	s2
            putch('x', putdat);
    8020084c:	85a6                	mv	a1,s1
    8020084e:	07800513          	li	a0,120
    80200852:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200854:	0a21                	addi	s4,s4,8
            goto number;
    80200856:	6782                	ld	a5,0(sp)
    80200858:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020085a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    8020085e:	bfb5                	j	802007da <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200860:	000a3403          	ld	s0,0(s4)
    80200864:	008a0713          	addi	a4,s4,8
    80200868:	e03a                	sd	a4,0(sp)
    8020086a:	14040263          	beqz	s0,802009ae <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    8020086e:	0fb05763          	blez	s11,8020095c <vprintfmt+0x2d8>
    80200872:	02d00693          	li	a3,45
    80200876:	0cd79163          	bne	a5,a3,80200938 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020087a:	00044783          	lbu	a5,0(s0)
    8020087e:	0007851b          	sext.w	a0,a5
    80200882:	cf85                	beqz	a5,802008ba <vprintfmt+0x236>
    80200884:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200888:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020088c:	000c4563          	bltz	s8,80200896 <vprintfmt+0x212>
    80200890:	3c7d                	addiw	s8,s8,-1
    80200892:	036c0263          	beq	s8,s6,802008b6 <vprintfmt+0x232>
                    putch('?', putdat);
    80200896:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200898:	0e0c8e63          	beqz	s9,80200994 <vprintfmt+0x310>
    8020089c:	3781                	addiw	a5,a5,-32
    8020089e:	0ef47b63          	bleu	a5,s0,80200994 <vprintfmt+0x310>
                    putch('?', putdat);
    802008a2:	03f00513          	li	a0,63
    802008a6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008a8:	000a4783          	lbu	a5,0(s4)
    802008ac:	3dfd                	addiw	s11,s11,-1
    802008ae:	0a05                	addi	s4,s4,1
    802008b0:	0007851b          	sext.w	a0,a5
    802008b4:	ffe1                	bnez	a5,8020088c <vprintfmt+0x208>
            for (; width > 0; width --) {
    802008b6:	01b05963          	blez	s11,802008c8 <vprintfmt+0x244>
    802008ba:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    802008bc:	85a6                	mv	a1,s1
    802008be:	02000513          	li	a0,32
    802008c2:	9902                	jalr	s2
            for (; width > 0; width --) {
    802008c4:	fe0d9be3          	bnez	s11,802008ba <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008c8:	6a02                	ld	s4,0(sp)
    802008ca:	bbd5                	j	802006be <vprintfmt+0x3a>
    if (lflag >= 2) {
    802008cc:	4705                	li	a4,1
    802008ce:	008a0c93          	addi	s9,s4,8
    802008d2:	01174463          	blt	a4,a7,802008da <vprintfmt+0x256>
    else if (lflag) {
    802008d6:	08088d63          	beqz	a7,80200970 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    802008da:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    802008de:	0a044d63          	bltz	s0,80200998 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    802008e2:	8622                	mv	a2,s0
    802008e4:	8a66                	mv	s4,s9
    802008e6:	46a9                	li	a3,10
    802008e8:	bdcd                	j	802007da <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008ea:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008ee:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008f0:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008f2:	41f7d69b          	sraiw	a3,a5,0x1f
    802008f6:	8fb5                	xor	a5,a5,a3
    802008f8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008fc:	02d74163          	blt	a4,a3,8020091e <vprintfmt+0x29a>
    80200900:	00369793          	slli	a5,a3,0x3
    80200904:	97de                	add	a5,a5,s7
    80200906:	639c                	ld	a5,0(a5)
    80200908:	cb99                	beqz	a5,8020091e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    8020090a:	86be                	mv	a3,a5
    8020090c:	00000617          	auipc	a2,0x0
    80200910:	78c60613          	addi	a2,a2,1932 # 80201098 <etext+0x63e>
    80200914:	85a6                	mv	a1,s1
    80200916:	854a                	mv	a0,s2
    80200918:	0ce000ef          	jal	ra,802009e6 <printfmt>
    8020091c:	b34d                	j	802006be <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020091e:	00000617          	auipc	a2,0x0
    80200922:	76a60613          	addi	a2,a2,1898 # 80201088 <etext+0x62e>
    80200926:	85a6                	mv	a1,s1
    80200928:	854a                	mv	a0,s2
    8020092a:	0bc000ef          	jal	ra,802009e6 <printfmt>
    8020092e:	bb41                	j	802006be <vprintfmt+0x3a>
                p = "(null)";
    80200930:	00000417          	auipc	s0,0x0
    80200934:	75040413          	addi	s0,s0,1872 # 80201080 <etext+0x626>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200938:	85e2                	mv	a1,s8
    8020093a:	8522                	mv	a0,s0
    8020093c:	e43e                	sd	a5,8(sp)
    8020093e:	cadff0ef          	jal	ra,802005ea <strnlen>
    80200942:	40ad8dbb          	subw	s11,s11,a0
    80200946:	01b05b63          	blez	s11,8020095c <vprintfmt+0x2d8>
    8020094a:	67a2                	ld	a5,8(sp)
    8020094c:	00078a1b          	sext.w	s4,a5
    80200950:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200952:	85a6                	mv	a1,s1
    80200954:	8552                	mv	a0,s4
    80200956:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200958:	fe0d9ce3          	bnez	s11,80200950 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020095c:	00044783          	lbu	a5,0(s0)
    80200960:	00140a13          	addi	s4,s0,1
    80200964:	0007851b          	sext.w	a0,a5
    80200968:	d3a5                	beqz	a5,802008c8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    8020096a:	05e00413          	li	s0,94
    8020096e:	bf39                	j	8020088c <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200970:	000a2403          	lw	s0,0(s4)
    80200974:	b7ad                	j	802008de <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200976:	000a6603          	lwu	a2,0(s4)
    8020097a:	46a1                	li	a3,8
    8020097c:	8a2e                	mv	s4,a1
    8020097e:	bdb1                	j	802007da <vprintfmt+0x156>
    80200980:	000a6603          	lwu	a2,0(s4)
    80200984:	46a9                	li	a3,10
    80200986:	8a2e                	mv	s4,a1
    80200988:	bd89                	j	802007da <vprintfmt+0x156>
    8020098a:	000a6603          	lwu	a2,0(s4)
    8020098e:	46c1                	li	a3,16
    80200990:	8a2e                	mv	s4,a1
    80200992:	b5a1                	j	802007da <vprintfmt+0x156>
                    putch(ch, putdat);
    80200994:	9902                	jalr	s2
    80200996:	bf09                	j	802008a8 <vprintfmt+0x224>
                putch('-', putdat);
    80200998:	85a6                	mv	a1,s1
    8020099a:	02d00513          	li	a0,45
    8020099e:	e03e                	sd	a5,0(sp)
    802009a0:	9902                	jalr	s2
                num = -(long long)num;
    802009a2:	6782                	ld	a5,0(sp)
    802009a4:	8a66                	mv	s4,s9
    802009a6:	40800633          	neg	a2,s0
    802009aa:	46a9                	li	a3,10
    802009ac:	b53d                	j	802007da <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    802009ae:	03b05163          	blez	s11,802009d0 <vprintfmt+0x34c>
    802009b2:	02d00693          	li	a3,45
    802009b6:	f6d79de3          	bne	a5,a3,80200930 <vprintfmt+0x2ac>
                p = "(null)";
    802009ba:	00000417          	auipc	s0,0x0
    802009be:	6c640413          	addi	s0,s0,1734 # 80201080 <etext+0x626>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009c2:	02800793          	li	a5,40
    802009c6:	02800513          	li	a0,40
    802009ca:	00140a13          	addi	s4,s0,1
    802009ce:	bd6d                	j	80200888 <vprintfmt+0x204>
    802009d0:	00000a17          	auipc	s4,0x0
    802009d4:	6b1a0a13          	addi	s4,s4,1713 # 80201081 <etext+0x627>
    802009d8:	02800513          	li	a0,40
    802009dc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    802009e0:	05e00413          	li	s0,94
    802009e4:	b565                	j	8020088c <vprintfmt+0x208>

00000000802009e6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009e6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009e8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009ec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009ee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009f0:	ec06                	sd	ra,24(sp)
    802009f2:	f83a                	sd	a4,48(sp)
    802009f4:	fc3e                	sd	a5,56(sp)
    802009f6:	e0c2                	sd	a6,64(sp)
    802009f8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009fa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009fc:	c89ff0ef          	jal	ra,80200684 <vprintfmt>
}
    80200a00:	60e2                	ld	ra,24(sp)
    80200a02:	6161                	addi	sp,sp,80
    80200a04:	8082                	ret

0000000080200a06 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200a06:	00003797          	auipc	a5,0x3
    80200a0a:	5fa78793          	addi	a5,a5,1530 # 80204000 <bootstacktop>
    __asm__ volatile (
    80200a0e:	6398                	ld	a4,0(a5)
    80200a10:	4781                	li	a5,0
    80200a12:	88ba                	mv	a7,a4
    80200a14:	852a                	mv	a0,a0
    80200a16:	85be                	mv	a1,a5
    80200a18:	863e                	mv	a2,a5
    80200a1a:	00000073          	ecall
    80200a1e:	87aa                	mv	a5,a0
}
    80200a20:	8082                	ret

0000000080200a22 <sbi_set_timer>:

//当time寄存器(rdtime的返回值)为stime_value的时候触发一个时钟中断
void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    80200a22:	00003797          	auipc	a5,0x3
    80200a26:	5f678793          	addi	a5,a5,1526 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200a2a:	6398                	ld	a4,0(a5)
    80200a2c:	4781                	li	a5,0
    80200a2e:	88ba                	mv	a7,a4
    80200a30:	852a                	mv	a0,a0
    80200a32:	85be                	mv	a1,a5
    80200a34:	863e                	mv	a2,a5
    80200a36:	00000073          	ecall
    80200a3a:	87aa                	mv	a5,a0
}
    80200a3c:	8082                	ret

0000000080200a3e <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a3e:	00003797          	auipc	a5,0x3
    80200a42:	5ca78793          	addi	a5,a5,1482 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    80200a46:	6398                	ld	a4,0(a5)
    80200a48:	4781                	li	a5,0
    80200a4a:	88ba                	mv	a7,a4
    80200a4c:	853e                	mv	a0,a5
    80200a4e:	85be                	mv	a1,a5
    80200a50:	863e                	mv	a2,a5
    80200a52:	00000073          	ecall
    80200a56:	87aa                	mv	a5,a0
    80200a58:	8082                	ret
