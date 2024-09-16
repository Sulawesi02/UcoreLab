
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
    80200024:	54e000ef          	jal	ra,80200572 <memset>

    cons_init();  // init the console
    80200028:	14e000ef          	jal	ra,80200176 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002c:	00001597          	auipc	a1,0x1
    80200030:	99c58593          	addi	a1,a1,-1636 # 802009c8 <etext+0x2>
    80200034:	00001517          	auipc	a0,0x1
    80200038:	9b450513          	addi	a0,a0,-1612 # 802009e8 <etext+0x22>
    8020003c:	030000ef          	jal	ra,8020006c <cprintf>

    print_kerninfo();
    80200040:	062000ef          	jal	ra,802000a2 <print_kerninfo>

    // grade_backtrace();

    //trap.h的函数，初始化中断
    idt_init();  // init interrupt descriptor table
    80200044:	142000ef          	jal	ra,80200186 <idt_init>

    // rdtime in mbare mode crashes
    //clock.h的函数，初始化时钟中断
    clock_init();  // init clock interrupt
    80200048:	0ea000ef          	jal	ra,80200132 <clock_init>

    //intr.h的函数，使能中断
    intr_enable();  // enable irq interrupt
    8020004c:	134000ef          	jal	ra,80200180 <intr_enable>
    
    while (1)
        ;
    80200050:	a001                	j	80200050 <kern_init+0x44>

0000000080200052 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200052:	1141                	addi	sp,sp,-16
    80200054:	e022                	sd	s0,0(sp)
    80200056:	e406                	sd	ra,8(sp)
    80200058:	842e                	mv	s0,a1
    cons_putc(c);
    8020005a:	11e000ef          	jal	ra,80200178 <cons_putc>
    (*cnt)++;
    8020005e:	401c                	lw	a5,0(s0)
}
    80200060:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200062:	2785                	addiw	a5,a5,1
    80200064:	c01c                	sw	a5,0(s0)
}
    80200066:	6402                	ld	s0,0(sp)
    80200068:	0141                	addi	sp,sp,16
    8020006a:	8082                	ret

000000008020006c <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006e:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200072:	8e2a                	mv	t3,a0
    80200074:	f42e                	sd	a1,40(sp)
    80200076:	f832                	sd	a2,48(sp)
    80200078:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd850513          	addi	a0,a0,-40 # 80200052 <cputch>
    80200082:	004c                	addi	a1,sp,4
    80200084:	869a                	mv	a3,t1
    80200086:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200088:	ec06                	sd	ra,24(sp)
    8020008a:	e0ba                	sd	a4,64(sp)
    8020008c:	e4be                	sd	a5,72(sp)
    8020008e:	e8c2                	sd	a6,80(sp)
    80200090:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200092:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200094:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200096:	55a000ef          	jal	ra,802005f0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009a:	60e2                	ld	ra,24(sp)
    8020009c:	4512                	lw	a0,4(sp)
    8020009e:	6125                	addi	sp,sp,96
    802000a0:	8082                	ret

00000000802000a2 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a2:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a4:	00001517          	auipc	a0,0x1
    802000a8:	94c50513          	addi	a0,a0,-1716 # 802009f0 <etext+0x2a>
void print_kerninfo(void) {
    802000ac:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ae:	fbfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b2:	00000597          	auipc	a1,0x0
    802000b6:	f5a58593          	addi	a1,a1,-166 # 8020000c <kern_init>
    802000ba:	00001517          	auipc	a0,0x1
    802000be:	95650513          	addi	a0,a0,-1706 # 80200a10 <etext+0x4a>
    802000c2:	fabff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c6:	00001597          	auipc	a1,0x1
    802000ca:	90058593          	addi	a1,a1,-1792 # 802009c6 <etext>
    802000ce:	00001517          	auipc	a0,0x1
    802000d2:	96250513          	addi	a0,a0,-1694 # 80200a30 <etext+0x6a>
    802000d6:	f97ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000da:	00004597          	auipc	a1,0x4
    802000de:	f3658593          	addi	a1,a1,-202 # 80204010 <edata>
    802000e2:	00001517          	auipc	a0,0x1
    802000e6:	96e50513          	addi	a0,a0,-1682 # 80200a50 <etext+0x8a>
    802000ea:	f83ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ee:	00004597          	auipc	a1,0x4
    802000f2:	f3a58593          	addi	a1,a1,-198 # 80204028 <end>
    802000f6:	00001517          	auipc	a0,0x1
    802000fa:	97a50513          	addi	a0,a0,-1670 # 80200a70 <etext+0xaa>
    802000fe:	f6fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200102:	00004597          	auipc	a1,0x4
    80200106:	32558593          	addi	a1,a1,805 # 80204427 <end+0x3ff>
    8020010a:	00000797          	auipc	a5,0x0
    8020010e:	f0278793          	addi	a5,a5,-254 # 8020000c <kern_init>
    80200112:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200116:	43f7d593          	srai	a1,a5,0x3f
}
    8020011a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011c:	3ff5f593          	andi	a1,a1,1023
    80200120:	95be                	add	a1,a1,a5
    80200122:	85a9                	srai	a1,a1,0xa
    80200124:	00001517          	auipc	a0,0x1
    80200128:	96c50513          	addi	a0,a0,-1684 # 80200a90 <etext+0xca>
}
    8020012c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012e:	f3fff06f          	j	8020006c <cprintf>

0000000080200132 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200132:	1141                	addi	sp,sp,-16
    80200134:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    // sie这个CSR可以单独使能/禁用某个来源的中断。默认时钟中断是关闭的
    // 所以我们要在初始化的时候，使能时钟中断
    set_csr(sie, MIP_STIP);
    80200136:	02000793          	li	a5,32
    8020013a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013e:	c0102573          	rdtime	a0
    cprintf("++ setup timer interrupts\n");
}

//设置时钟中断：timer的数值变为当前时间 + timebase 后，触发一次时钟中断
//对于QEMU, timer增加1，过去了10^-7 s， 也就是100ns
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200142:	67e1                	lui	a5,0x18
    80200144:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200148:	953e                	add	a0,a0,a5
    8020014a:	045000ef          	jal	ra,8020098e <sbi_set_timer>
}
    8020014e:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200150:	00004797          	auipc	a5,0x4
    80200154:	ec07b823          	sd	zero,-304(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200158:	00001517          	auipc	a0,0x1
    8020015c:	96850513          	addi	a0,a0,-1688 # 80200ac0 <etext+0xfa>
}
    80200160:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200162:	f0bff06f          	j	8020006c <cprintf>

0000000080200166 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200166:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	01d0006f          	j	8020098e <sbi_set_timer>

0000000080200176 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200176:	8082                	ret

0000000080200178 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200178:	0ff57513          	andi	a0,a0,255
    8020017c:	7f60006f          	j	80200972 <sbi_console_putchar>

0000000080200180 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt, 设置sstatus的Supervisor中断使能位 */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
     * presently executing in the kernel */
    //约定：若中断前处于S态，sscratch为0
    //若中断前处于U态，sscratch存储内核栈地址
    //那么之后就可以通过sscratch的数值判断是内核态产生的中断还是用户态产生的中断
    //我们现在是内核态所以给sscratch置零
    write_csr(sscratch, 0);
    80200186:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    //我们保证__alltraps的地址是四字节对齐的，将__alltraps这个符号的地址直接写到stvec寄存器
    write_csr(stvec, &__alltraps);
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	31678793          	addi	a5,a5,790 # 802004a0 <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
}
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	a2050513          	addi	a0,a0,-1504 # 80200bc0 <etext+0x1fa>
void print_regs(struct pushregs *gpr) {
    802001a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	ec3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	a2850513          	addi	a0,a0,-1496 # 80200bd8 <etext+0x212>
    802001b8:	eb5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	a3250513          	addi	a0,a0,-1486 # 80200bf0 <etext+0x22a>
    802001c6:	ea7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	a3c50513          	addi	a0,a0,-1476 # 80200c08 <etext+0x242>
    802001d4:	e99ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	a4650513          	addi	a0,a0,-1466 # 80200c20 <etext+0x25a>
    802001e2:	e8bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	a5050513          	addi	a0,a0,-1456 # 80200c38 <etext+0x272>
    802001f0:	e7dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	a5a50513          	addi	a0,a0,-1446 # 80200c50 <etext+0x28a>
    802001fe:	e6fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	a6450513          	addi	a0,a0,-1436 # 80200c68 <etext+0x2a2>
    8020020c:	e61ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	a6e50513          	addi	a0,a0,-1426 # 80200c80 <etext+0x2ba>
    8020021a:	e53ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	a7850513          	addi	a0,a0,-1416 # 80200c98 <etext+0x2d2>
    80200228:	e45ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	a8250513          	addi	a0,a0,-1406 # 80200cb0 <etext+0x2ea>
    80200236:	e37ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	a8c50513          	addi	a0,a0,-1396 # 80200cc8 <etext+0x302>
    80200244:	e29ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	a9650513          	addi	a0,a0,-1386 # 80200ce0 <etext+0x31a>
    80200252:	e1bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	aa050513          	addi	a0,a0,-1376 # 80200cf8 <etext+0x332>
    80200260:	e0dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	aaa50513          	addi	a0,a0,-1366 # 80200d10 <etext+0x34a>
    8020026e:	dffff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	ab450513          	addi	a0,a0,-1356 # 80200d28 <etext+0x362>
    8020027c:	df1ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	abe50513          	addi	a0,a0,-1346 # 80200d40 <etext+0x37a>
    8020028a:	de3ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	ac850513          	addi	a0,a0,-1336 # 80200d58 <etext+0x392>
    80200298:	dd5ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	ad250513          	addi	a0,a0,-1326 # 80200d70 <etext+0x3aa>
    802002a6:	dc7ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	adc50513          	addi	a0,a0,-1316 # 80200d88 <etext+0x3c2>
    802002b4:	db9ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	ae650513          	addi	a0,a0,-1306 # 80200da0 <etext+0x3da>
    802002c2:	dabff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	af050513          	addi	a0,a0,-1296 # 80200db8 <etext+0x3f2>
    802002d0:	d9dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	afa50513          	addi	a0,a0,-1286 # 80200dd0 <etext+0x40a>
    802002de:	d8fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	b0450513          	addi	a0,a0,-1276 # 80200de8 <etext+0x422>
    802002ec:	d81ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	b0e50513          	addi	a0,a0,-1266 # 80200e00 <etext+0x43a>
    802002fa:	d73ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	b1850513          	addi	a0,a0,-1256 # 80200e18 <etext+0x452>
    80200308:	d65ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	b2250513          	addi	a0,a0,-1246 # 80200e30 <etext+0x46a>
    80200316:	d57ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	b2c50513          	addi	a0,a0,-1236 # 80200e48 <etext+0x482>
    80200324:	d49ff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	b3650513          	addi	a0,a0,-1226 # 80200e60 <etext+0x49a>
    80200332:	d3bff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	b4050513          	addi	a0,a0,-1216 # 80200e78 <etext+0x4b2>
    80200340:	d2dff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	b4a50513          	addi	a0,a0,-1206 # 80200e90 <etext+0x4ca>
    8020034e:	d1fff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	7c6c                	ld	a1,248(s0)
}
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	b5050513          	addi	a0,a0,-1200 # 80200ea8 <etext+0x4e2>
}
    80200360:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	d0bff06f          	j	8020006c <cprintf>

0000000080200366 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200366:	1141                	addi	sp,sp,-16
    80200368:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    8020036a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036e:	00001517          	auipc	a0,0x1
    80200372:	b5250513          	addi	a0,a0,-1198 # 80200ec0 <etext+0x4fa>
void print_trapframe(struct trapframe *tf) {
    80200376:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200378:	cf5ff0ef          	jal	ra,8020006c <cprintf>
    print_regs(&tf->gpr);
    8020037c:	8522                	mv	a0,s0
    8020037e:	e1bff0ef          	jal	ra,80200198 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200382:	10043583          	ld	a1,256(s0)
    80200386:	00001517          	auipc	a0,0x1
    8020038a:	b5250513          	addi	a0,a0,-1198 # 80200ed8 <etext+0x512>
    8020038e:	cdfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200392:	10843583          	ld	a1,264(s0)
    80200396:	00001517          	auipc	a0,0x1
    8020039a:	b5a50513          	addi	a0,a0,-1190 # 80200ef0 <etext+0x52a>
    8020039e:	ccfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a2:	11043583          	ld	a1,272(s0)
    802003a6:	00001517          	auipc	a0,0x1
    802003aa:	b6250513          	addi	a0,a0,-1182 # 80200f08 <etext+0x542>
    802003ae:	cbfff0ef          	jal	ra,8020006c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	11843583          	ld	a1,280(s0)
}
    802003b6:	6402                	ld	s0,0(sp)
    802003b8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	00001517          	auipc	a0,0x1
    802003be:	b6650513          	addi	a0,a0,-1178 # 80200f20 <etext+0x55a>
}
    802003c2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c4:	ca9ff06f          	j	8020006c <cprintf>

00000000802003c8 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c8:	11853783          	ld	a5,280(a0)
    802003cc:	577d                	li	a4,-1
    802003ce:	8305                	srli	a4,a4,0x1
    802003d0:	8ff9                	and	a5,a5,a4
    switch (cause) {
    802003d2:	472d                	li	a4,11
    802003d4:	06f76f63          	bltu	a4,a5,80200452 <interrupt_handler+0x8a>
    802003d8:	00000717          	auipc	a4,0x0
    802003dc:	70470713          	addi	a4,a4,1796 # 80200adc <etext+0x116>
    802003e0:	078a                	slli	a5,a5,0x2
    802003e2:	97ba                	add	a5,a5,a4
    802003e4:	439c                	lw	a5,0(a5)
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ea:	00000517          	auipc	a0,0x0
    802003ee:	78650513          	addi	a0,a0,1926 # 80200b70 <etext+0x1aa>
    802003f2:	c7bff06f          	j	8020006c <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f6:	00000517          	auipc	a0,0x0
    802003fa:	75a50513          	addi	a0,a0,1882 # 80200b50 <etext+0x18a>
    802003fe:	c6fff06f          	j	8020006c <cprintf>
            cprintf("User software interrupt\n");
    80200402:	00000517          	auipc	a0,0x0
    80200406:	70e50513          	addi	a0,a0,1806 # 80200b10 <etext+0x14a>
    8020040a:	c63ff06f          	j	8020006c <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040e:	00000517          	auipc	a0,0x0
    80200412:	72250513          	addi	a0,a0,1826 # 80200b30 <etext+0x16a>
    80200416:	c57ff06f          	j	8020006c <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    8020041a:	00000517          	auipc	a0,0x0
    8020041e:	78650513          	addi	a0,a0,1926 # 80200ba0 <etext+0x1da>
    80200422:	c4bff06f          	j	8020006c <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200426:	1141                	addi	sp,sp,-16
    80200428:	e406                	sd	ra,8(sp)
            clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
    8020042a:	d3dff0ef          	jal	ra,80200166 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    8020042e:	00004797          	auipc	a5,0x4
    80200432:	bf278793          	addi	a5,a5,-1038 # 80204020 <ticks>
    80200436:	639c                	ld	a5,0(a5)
    80200438:	06400713          	li	a4,100
    8020043c:	0785                	addi	a5,a5,1
    8020043e:	02e7f733          	remu	a4,a5,a4
    80200442:	00004697          	auipc	a3,0x4
    80200446:	bcf6bf23          	sd	a5,-1058(a3) # 80204020 <ticks>
    8020044a:	c711                	beqz	a4,80200456 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020044c:	60a2                	ld	ra,8(sp)
    8020044e:	0141                	addi	sp,sp,16
    80200450:	8082                	ret
            print_trapframe(tf);
    80200452:	f15ff06f          	j	80200366 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200456:	06400593          	li	a1,100
    8020045a:	00000517          	auipc	a0,0x0
    8020045e:	73650513          	addi	a0,a0,1846 # 80200b90 <etext+0x1ca>
    80200462:	c0bff0ef          	jal	ra,8020006c <cprintf>
                if(++num == 10)
    80200466:	00004797          	auipc	a5,0x4
    8020046a:	baa78793          	addi	a5,a5,-1110 # 80204010 <edata>
    8020046e:	639c                	ld	a5,0(a5)
    80200470:	4729                	li	a4,10
    80200472:	0785                	addi	a5,a5,1
    80200474:	00004697          	auipc	a3,0x4
    80200478:	b8f6be23          	sd	a5,-1124(a3) # 80204010 <edata>
    8020047c:	fce798e3          	bne	a5,a4,8020044c <interrupt_handler+0x84>
}
    80200480:	60a2                	ld	ra,8(sp)
    80200482:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200484:	5260006f          	j	802009aa <sbi_shutdown>

0000000080200488 <trap>:
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    //scause的最高位是1，说明trap是由中断引起的
    if ((intptr_t)tf->cause < 0) {
    80200488:	11853783          	ld	a5,280(a0)
    8020048c:	0007c863          	bltz	a5,8020049c <trap+0x14>
    switch (tf->cause) {
    80200490:	472d                	li	a4,11
    80200492:	00f76363          	bltu	a4,a5,80200498 <trap+0x10>
 * trap - handles or dispatches an exception/interrupt. if and when trap()
 * returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) { trap_dispatch(tf); }
    80200496:	8082                	ret
            print_trapframe(tf);
    80200498:	ecfff06f          	j	80200366 <print_trapframe>
        interrupt_handler(tf);
    8020049c:	f2dff06f          	j	802003c8 <interrupt_handler>

00000000802004a0 <__alltraps>:

    .globl __alltraps

.align(2) #中断入口点 __alltraps必须四字节对齐
__alltraps:
    SAVE_ALL #保存上下文
    802004a0:	14011073          	csrw	sscratch,sp
    802004a4:	712d                	addi	sp,sp,-288
    802004a6:	e002                	sd	zero,0(sp)
    802004a8:	e406                	sd	ra,8(sp)
    802004aa:	ec0e                	sd	gp,24(sp)
    802004ac:	f012                	sd	tp,32(sp)
    802004ae:	f416                	sd	t0,40(sp)
    802004b0:	f81a                	sd	t1,48(sp)
    802004b2:	fc1e                	sd	t2,56(sp)
    802004b4:	e0a2                	sd	s0,64(sp)
    802004b6:	e4a6                	sd	s1,72(sp)
    802004b8:	e8aa                	sd	a0,80(sp)
    802004ba:	ecae                	sd	a1,88(sp)
    802004bc:	f0b2                	sd	a2,96(sp)
    802004be:	f4b6                	sd	a3,104(sp)
    802004c0:	f8ba                	sd	a4,112(sp)
    802004c2:	fcbe                	sd	a5,120(sp)
    802004c4:	e142                	sd	a6,128(sp)
    802004c6:	e546                	sd	a7,136(sp)
    802004c8:	e94a                	sd	s2,144(sp)
    802004ca:	ed4e                	sd	s3,152(sp)
    802004cc:	f152                	sd	s4,160(sp)
    802004ce:	f556                	sd	s5,168(sp)
    802004d0:	f95a                	sd	s6,176(sp)
    802004d2:	fd5e                	sd	s7,184(sp)
    802004d4:	e1e2                	sd	s8,192(sp)
    802004d6:	e5e6                	sd	s9,200(sp)
    802004d8:	e9ea                	sd	s10,208(sp)
    802004da:	edee                	sd	s11,216(sp)
    802004dc:	f1f2                	sd	t3,224(sp)
    802004de:	f5f6                	sd	t4,232(sp)
    802004e0:	f9fa                	sd	t5,240(sp)
    802004e2:	fdfe                	sd	t6,248(sp)
    802004e4:	14001473          	csrrw	s0,sscratch,zero
    802004e8:	100024f3          	csrr	s1,sstatus
    802004ec:	14102973          	csrr	s2,sepc
    802004f0:	143029f3          	csrr	s3,stval
    802004f4:	14202a73          	csrr	s4,scause
    802004f8:	e822                	sd	s0,16(sp)
    802004fa:	e226                	sd	s1,256(sp)
    802004fc:	e64a                	sd	s2,264(sp)
    802004fe:	ea4e                	sd	s3,272(sp)
    80200500:	ee52                	sd	s4,280(sp)

    move  a0, sp #传递参数。
    80200502:	850a                	mv	a0,sp
    #按照RISCV calling convention, a0寄存器传递参数给接下来调用的函数trap。
    #trap是trap.c里面的一个C语言函数，也就是我们的中断处理程序
    jal trap 
    80200504:	f85ff0ef          	jal	ra,80200488 <trap>

0000000080200508 <__trapret>:
    #trap函数指向完之后，会回到这里向下继续执行__trapret里面的内容，RESTORE_ALL,sret

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200508:	6492                	ld	s1,256(sp)
    8020050a:	6932                	ld	s2,264(sp)
    8020050c:	10049073          	csrw	sstatus,s1
    80200510:	14191073          	csrw	sepc,s2
    80200514:	60a2                	ld	ra,8(sp)
    80200516:	61e2                	ld	gp,24(sp)
    80200518:	7202                	ld	tp,32(sp)
    8020051a:	72a2                	ld	t0,40(sp)
    8020051c:	7342                	ld	t1,48(sp)
    8020051e:	73e2                	ld	t2,56(sp)
    80200520:	6406                	ld	s0,64(sp)
    80200522:	64a6                	ld	s1,72(sp)
    80200524:	6546                	ld	a0,80(sp)
    80200526:	65e6                	ld	a1,88(sp)
    80200528:	7606                	ld	a2,96(sp)
    8020052a:	76a6                	ld	a3,104(sp)
    8020052c:	7746                	ld	a4,112(sp)
    8020052e:	77e6                	ld	a5,120(sp)
    80200530:	680a                	ld	a6,128(sp)
    80200532:	68aa                	ld	a7,136(sp)
    80200534:	694a                	ld	s2,144(sp)
    80200536:	69ea                	ld	s3,152(sp)
    80200538:	7a0a                	ld	s4,160(sp)
    8020053a:	7aaa                	ld	s5,168(sp)
    8020053c:	7b4a                	ld	s6,176(sp)
    8020053e:	7bea                	ld	s7,184(sp)
    80200540:	6c0e                	ld	s8,192(sp)
    80200542:	6cae                	ld	s9,200(sp)
    80200544:	6d4e                	ld	s10,208(sp)
    80200546:	6dee                	ld	s11,216(sp)
    80200548:	7e0e                	ld	t3,224(sp)
    8020054a:	7eae                	ld	t4,232(sp)
    8020054c:	7f4e                	ld	t5,240(sp)
    8020054e:	7fee                	ld	t6,248(sp)
    80200550:	6142                	ld	sp,16(sp)
    # return from supervisor call
    80200552:	10200073          	sret

0000000080200556 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    80200556:	872a                	mv	a4,a0
    size_t cnt = 0;
    80200558:	4501                	li	a0,0
    while (cnt < len && *s ++ != '\0') {
    8020055a:	e589                	bnez	a1,80200564 <strnlen+0xe>
    8020055c:	a811                	j	80200570 <strnlen+0x1a>
        cnt ++;
    8020055e:	0505                	addi	a0,a0,1
    while (cnt < len && *s ++ != '\0') {
    80200560:	00a58763          	beq	a1,a0,8020056e <strnlen+0x18>
    80200564:	00a707b3          	add	a5,a4,a0
    80200568:	0007c783          	lbu	a5,0(a5)
    8020056c:	fbed                	bnez	a5,8020055e <strnlen+0x8>
    }
    return cnt;
}
    8020056e:	8082                	ret
    80200570:	8082                	ret

0000000080200572 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200572:	ca01                	beqz	a2,80200582 <memset+0x10>
    80200574:	962a                	add	a2,a2,a0
    char *p = s;
    80200576:	87aa                	mv	a5,a0
        *p ++ = c;
    80200578:	0785                	addi	a5,a5,1
    8020057a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    8020057e:	fec79de3          	bne	a5,a2,80200578 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200582:	8082                	ret

0000000080200584 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200584:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200588:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    8020058a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020058e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    80200590:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    80200594:	f022                	sd	s0,32(sp)
    80200596:	ec26                	sd	s1,24(sp)
    80200598:	e84a                	sd	s2,16(sp)
    8020059a:	f406                	sd	ra,40(sp)
    8020059c:	e44e                	sd	s3,8(sp)
    8020059e:	84aa                	mv	s1,a0
    802005a0:	892e                	mv	s2,a1
    802005a2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005a6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005a8:	03067e63          	bleu	a6,a2,802005e4 <printnum+0x60>
    802005ac:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005ae:	00805763          	blez	s0,802005bc <printnum+0x38>
    802005b2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005b4:	85ca                	mv	a1,s2
    802005b6:	854e                	mv	a0,s3
    802005b8:	9482                	jalr	s1
        while (-- width > 0)
    802005ba:	fc65                	bnez	s0,802005b2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005bc:	1a02                	slli	s4,s4,0x20
    802005be:	020a5a13          	srli	s4,s4,0x20
    802005c2:	00001797          	auipc	a5,0x1
    802005c6:	97678793          	addi	a5,a5,-1674 # 80200f38 <etext+0x572>
}
    802005ca:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005cc:	9a3e                	add	s4,s4,a5
    802005ce:	000a4503          	lbu	a0,0(s4)
}
    802005d2:	70a2                	ld	ra,40(sp)
    802005d4:	69a2                	ld	s3,8(sp)
    802005d6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005d8:	85ca                	mv	a1,s2
    802005da:	8326                	mv	t1,s1
}
    802005dc:	6942                	ld	s2,16(sp)
    802005de:	64e2                	ld	s1,24(sp)
    802005e0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802005e2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    802005e4:	03065633          	divu	a2,a2,a6
    802005e8:	8722                	mv	a4,s0
    802005ea:	f9bff0ef          	jal	ra,80200584 <printnum>
    802005ee:	b7f9                	j	802005bc <printnum+0x38>

00000000802005f0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802005f0:	7119                	addi	sp,sp,-128
    802005f2:	f4a6                	sd	s1,104(sp)
    802005f4:	f0ca                	sd	s2,96(sp)
    802005f6:	ecce                	sd	s3,88(sp)
    802005f8:	e8d2                	sd	s4,80(sp)
    802005fa:	e4d6                	sd	s5,72(sp)
    802005fc:	e0da                	sd	s6,64(sp)
    802005fe:	fc5e                	sd	s7,56(sp)
    80200600:	f06a                	sd	s10,32(sp)
    80200602:	fc86                	sd	ra,120(sp)
    80200604:	f8a2                	sd	s0,112(sp)
    80200606:	f862                	sd	s8,48(sp)
    80200608:	f466                	sd	s9,40(sp)
    8020060a:	ec6e                	sd	s11,24(sp)
    8020060c:	892a                	mv	s2,a0
    8020060e:	84ae                	mv	s1,a1
    80200610:	8d32                	mv	s10,a2
    80200612:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200614:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200618:	5b7d                	li	s6,-1
    8020061a:	00001a97          	auipc	s5,0x1
    8020061e:	952a8a93          	addi	s5,s5,-1710 # 80200f6c <etext+0x5a6>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200622:	00001b97          	auipc	s7,0x1
    80200626:	b26b8b93          	addi	s7,s7,-1242 # 80201148 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020062a:	000d4503          	lbu	a0,0(s10)
    8020062e:	001d0413          	addi	s0,s10,1
    80200632:	01350a63          	beq	a0,s3,80200646 <vprintfmt+0x56>
            if (ch == '\0') {
    80200636:	c121                	beqz	a0,80200676 <vprintfmt+0x86>
            putch(ch, putdat);
    80200638:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020063a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020063c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020063e:	fff44503          	lbu	a0,-1(s0)
    80200642:	ff351ae3          	bne	a0,s3,80200636 <vprintfmt+0x46>
    80200646:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020064a:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020064e:	4c81                	li	s9,0
    80200650:	4881                	li	a7,0
        width = precision = -1;
    80200652:	5c7d                	li	s8,-1
    80200654:	5dfd                	li	s11,-1
    80200656:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    8020065a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020065c:	fdd6059b          	addiw	a1,a2,-35
    80200660:	0ff5f593          	andi	a1,a1,255
    80200664:	00140d13          	addi	s10,s0,1
    80200668:	04b56263          	bltu	a0,a1,802006ac <vprintfmt+0xbc>
    8020066c:	058a                	slli	a1,a1,0x2
    8020066e:	95d6                	add	a1,a1,s5
    80200670:	4194                	lw	a3,0(a1)
    80200672:	96d6                	add	a3,a3,s5
    80200674:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200676:	70e6                	ld	ra,120(sp)
    80200678:	7446                	ld	s0,112(sp)
    8020067a:	74a6                	ld	s1,104(sp)
    8020067c:	7906                	ld	s2,96(sp)
    8020067e:	69e6                	ld	s3,88(sp)
    80200680:	6a46                	ld	s4,80(sp)
    80200682:	6aa6                	ld	s5,72(sp)
    80200684:	6b06                	ld	s6,64(sp)
    80200686:	7be2                	ld	s7,56(sp)
    80200688:	7c42                	ld	s8,48(sp)
    8020068a:	7ca2                	ld	s9,40(sp)
    8020068c:	7d02                	ld	s10,32(sp)
    8020068e:	6de2                	ld	s11,24(sp)
    80200690:	6109                	addi	sp,sp,128
    80200692:	8082                	ret
            padc = '0';
    80200694:	87b2                	mv	a5,a2
            goto reswitch;
    80200696:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020069a:	846a                	mv	s0,s10
    8020069c:	00140d13          	addi	s10,s0,1
    802006a0:	fdd6059b          	addiw	a1,a2,-35
    802006a4:	0ff5f593          	andi	a1,a1,255
    802006a8:	fcb572e3          	bleu	a1,a0,8020066c <vprintfmt+0x7c>
            putch('%', putdat);
    802006ac:	85a6                	mv	a1,s1
    802006ae:	02500513          	li	a0,37
    802006b2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006b4:	fff44783          	lbu	a5,-1(s0)
    802006b8:	8d22                	mv	s10,s0
    802006ba:	f73788e3          	beq	a5,s3,8020062a <vprintfmt+0x3a>
    802006be:	ffed4783          	lbu	a5,-2(s10)
    802006c2:	1d7d                	addi	s10,s10,-1
    802006c4:	ff379de3          	bne	a5,s3,802006be <vprintfmt+0xce>
    802006c8:	b78d                	j	8020062a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802006ca:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802006ce:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006d2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802006d4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802006d8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802006dc:	02d86463          	bltu	a6,a3,80200704 <vprintfmt+0x114>
                ch = *fmt;
    802006e0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    802006e4:	002c169b          	slliw	a3,s8,0x2
    802006e8:	0186873b          	addw	a4,a3,s8
    802006ec:	0017171b          	slliw	a4,a4,0x1
    802006f0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    802006f2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    802006f6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802006f8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    802006fc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200700:	fed870e3          	bleu	a3,a6,802006e0 <vprintfmt+0xf0>
            if (width < 0)
    80200704:	f40ddce3          	bgez	s11,8020065c <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200708:	8de2                	mv	s11,s8
    8020070a:	5c7d                	li	s8,-1
    8020070c:	bf81                	j	8020065c <vprintfmt+0x6c>
            if (width < 0)
    8020070e:	fffdc693          	not	a3,s11
    80200712:	96fd                	srai	a3,a3,0x3f
    80200714:	00ddfdb3          	and	s11,s11,a3
    80200718:	00144603          	lbu	a2,1(s0)
    8020071c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020071e:	846a                	mv	s0,s10
            goto reswitch;
    80200720:	bf35                	j	8020065c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200722:	000a2c03          	lw	s8,0(s4)
            goto process_precision;
    80200726:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020072a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020072c:	846a                	mv	s0,s10
            goto process_precision;
    8020072e:	bfd9                	j	80200704 <vprintfmt+0x114>
    if (lflag >= 2) {
    80200730:	4705                	li	a4,1
    80200732:	008a0593          	addi	a1,s4,8
    80200736:	01174463          	blt	a4,a7,8020073e <vprintfmt+0x14e>
    else if (lflag) {
    8020073a:	1a088e63          	beqz	a7,802008f6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8020073e:	000a3603          	ld	a2,0(s4)
    80200742:	46c1                	li	a3,16
    80200744:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200746:	2781                	sext.w	a5,a5
    80200748:	876e                	mv	a4,s11
    8020074a:	85a6                	mv	a1,s1
    8020074c:	854a                	mv	a0,s2
    8020074e:	e37ff0ef          	jal	ra,80200584 <printnum>
            break;
    80200752:	bde1                	j	8020062a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200754:	000a2503          	lw	a0,0(s4)
    80200758:	85a6                	mv	a1,s1
    8020075a:	0a21                	addi	s4,s4,8
    8020075c:	9902                	jalr	s2
            break;
    8020075e:	b5f1                	j	8020062a <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200760:	4705                	li	a4,1
    80200762:	008a0593          	addi	a1,s4,8
    80200766:	01174463          	blt	a4,a7,8020076e <vprintfmt+0x17e>
    else if (lflag) {
    8020076a:	18088163          	beqz	a7,802008ec <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    8020076e:	000a3603          	ld	a2,0(s4)
    80200772:	46a9                	li	a3,10
    80200774:	8a2e                	mv	s4,a1
    80200776:	bfc1                	j	80200746 <vprintfmt+0x156>
            goto reswitch;
    80200778:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020077c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020077e:	846a                	mv	s0,s10
            goto reswitch;
    80200780:	bdf1                	j	8020065c <vprintfmt+0x6c>
            putch(ch, putdat);
    80200782:	85a6                	mv	a1,s1
    80200784:	02500513          	li	a0,37
    80200788:	9902                	jalr	s2
            break;
    8020078a:	b545                	j	8020062a <vprintfmt+0x3a>
            lflag ++;
    8020078c:	00144603          	lbu	a2,1(s0)
    80200790:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200792:	846a                	mv	s0,s10
            goto reswitch;
    80200794:	b5e1                	j	8020065c <vprintfmt+0x6c>
    if (lflag >= 2) {
    80200796:	4705                	li	a4,1
    80200798:	008a0593          	addi	a1,s4,8
    8020079c:	01174463          	blt	a4,a7,802007a4 <vprintfmt+0x1b4>
    else if (lflag) {
    802007a0:	14088163          	beqz	a7,802008e2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007a4:	000a3603          	ld	a2,0(s4)
    802007a8:	46a1                	li	a3,8
    802007aa:	8a2e                	mv	s4,a1
    802007ac:	bf69                	j	80200746 <vprintfmt+0x156>
            putch('0', putdat);
    802007ae:	03000513          	li	a0,48
    802007b2:	85a6                	mv	a1,s1
    802007b4:	e03e                	sd	a5,0(sp)
    802007b6:	9902                	jalr	s2
            putch('x', putdat);
    802007b8:	85a6                	mv	a1,s1
    802007ba:	07800513          	li	a0,120
    802007be:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802007c0:	0a21                	addi	s4,s4,8
            goto number;
    802007c2:	6782                	ld	a5,0(sp)
    802007c4:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802007c6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802007ca:	bfb5                	j	80200746 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007cc:	000a3403          	ld	s0,0(s4)
    802007d0:	008a0713          	addi	a4,s4,8
    802007d4:	e03a                	sd	a4,0(sp)
    802007d6:	14040263          	beqz	s0,8020091a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802007da:	0fb05763          	blez	s11,802008c8 <vprintfmt+0x2d8>
    802007de:	02d00693          	li	a3,45
    802007e2:	0cd79163          	bne	a5,a3,802008a4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007e6:	00044783          	lbu	a5,0(s0)
    802007ea:	0007851b          	sext.w	a0,a5
    802007ee:	cf85                	beqz	a5,80200826 <vprintfmt+0x236>
    802007f0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007f4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f8:	000c4563          	bltz	s8,80200802 <vprintfmt+0x212>
    802007fc:	3c7d                	addiw	s8,s8,-1
    802007fe:	036c0263          	beq	s8,s6,80200822 <vprintfmt+0x232>
                    putch('?', putdat);
    80200802:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200804:	0e0c8e63          	beqz	s9,80200900 <vprintfmt+0x310>
    80200808:	3781                	addiw	a5,a5,-32
    8020080a:	0ef47b63          	bleu	a5,s0,80200900 <vprintfmt+0x310>
                    putch('?', putdat);
    8020080e:	03f00513          	li	a0,63
    80200812:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200814:	000a4783          	lbu	a5,0(s4)
    80200818:	3dfd                	addiw	s11,s11,-1
    8020081a:	0a05                	addi	s4,s4,1
    8020081c:	0007851b          	sext.w	a0,a5
    80200820:	ffe1                	bnez	a5,802007f8 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200822:	01b05963          	blez	s11,80200834 <vprintfmt+0x244>
    80200826:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200828:	85a6                	mv	a1,s1
    8020082a:	02000513          	li	a0,32
    8020082e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200830:	fe0d9be3          	bnez	s11,80200826 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200834:	6a02                	ld	s4,0(sp)
    80200836:	bbd5                	j	8020062a <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200838:	4705                	li	a4,1
    8020083a:	008a0c93          	addi	s9,s4,8
    8020083e:	01174463          	blt	a4,a7,80200846 <vprintfmt+0x256>
    else if (lflag) {
    80200842:	08088d63          	beqz	a7,802008dc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200846:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    8020084a:	0a044d63          	bltz	s0,80200904 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020084e:	8622                	mv	a2,s0
    80200850:	8a66                	mv	s4,s9
    80200852:	46a9                	li	a3,10
    80200854:	bdcd                	j	80200746 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200856:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020085a:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020085c:	0a21                	addi	s4,s4,8
            if (err < 0) {
    8020085e:	41f7d69b          	sraiw	a3,a5,0x1f
    80200862:	8fb5                	xor	a5,a5,a3
    80200864:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200868:	02d74163          	blt	a4,a3,8020088a <vprintfmt+0x29a>
    8020086c:	00369793          	slli	a5,a3,0x3
    80200870:	97de                	add	a5,a5,s7
    80200872:	639c                	ld	a5,0(a5)
    80200874:	cb99                	beqz	a5,8020088a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200876:	86be                	mv	a3,a5
    80200878:	00000617          	auipc	a2,0x0
    8020087c:	6f060613          	addi	a2,a2,1776 # 80200f68 <etext+0x5a2>
    80200880:	85a6                	mv	a1,s1
    80200882:	854a                	mv	a0,s2
    80200884:	0ce000ef          	jal	ra,80200952 <printfmt>
    80200888:	b34d                	j	8020062a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    8020088a:	00000617          	auipc	a2,0x0
    8020088e:	6ce60613          	addi	a2,a2,1742 # 80200f58 <etext+0x592>
    80200892:	85a6                	mv	a1,s1
    80200894:	854a                	mv	a0,s2
    80200896:	0bc000ef          	jal	ra,80200952 <printfmt>
    8020089a:	bb41                	j	8020062a <vprintfmt+0x3a>
                p = "(null)";
    8020089c:	00000417          	auipc	s0,0x0
    802008a0:	6b440413          	addi	s0,s0,1716 # 80200f50 <etext+0x58a>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008a4:	85e2                	mv	a1,s8
    802008a6:	8522                	mv	a0,s0
    802008a8:	e43e                	sd	a5,8(sp)
    802008aa:	cadff0ef          	jal	ra,80200556 <strnlen>
    802008ae:	40ad8dbb          	subw	s11,s11,a0
    802008b2:	01b05b63          	blez	s11,802008c8 <vprintfmt+0x2d8>
    802008b6:	67a2                	ld	a5,8(sp)
    802008b8:	00078a1b          	sext.w	s4,a5
    802008bc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802008be:	85a6                	mv	a1,s1
    802008c0:	8552                	mv	a0,s4
    802008c2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008c4:	fe0d9ce3          	bnez	s11,802008bc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008c8:	00044783          	lbu	a5,0(s0)
    802008cc:	00140a13          	addi	s4,s0,1
    802008d0:	0007851b          	sext.w	a0,a5
    802008d4:	d3a5                	beqz	a5,80200834 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802008d6:	05e00413          	li	s0,94
    802008da:	bf39                	j	802007f8 <vprintfmt+0x208>
        return va_arg(*ap, int);
    802008dc:	000a2403          	lw	s0,0(s4)
    802008e0:	b7ad                	j	8020084a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    802008e2:	000a6603          	lwu	a2,0(s4)
    802008e6:	46a1                	li	a3,8
    802008e8:	8a2e                	mv	s4,a1
    802008ea:	bdb1                	j	80200746 <vprintfmt+0x156>
    802008ec:	000a6603          	lwu	a2,0(s4)
    802008f0:	46a9                	li	a3,10
    802008f2:	8a2e                	mv	s4,a1
    802008f4:	bd89                	j	80200746 <vprintfmt+0x156>
    802008f6:	000a6603          	lwu	a2,0(s4)
    802008fa:	46c1                	li	a3,16
    802008fc:	8a2e                	mv	s4,a1
    802008fe:	b5a1                	j	80200746 <vprintfmt+0x156>
                    putch(ch, putdat);
    80200900:	9902                	jalr	s2
    80200902:	bf09                	j	80200814 <vprintfmt+0x224>
                putch('-', putdat);
    80200904:	85a6                	mv	a1,s1
    80200906:	02d00513          	li	a0,45
    8020090a:	e03e                	sd	a5,0(sp)
    8020090c:	9902                	jalr	s2
                num = -(long long)num;
    8020090e:	6782                	ld	a5,0(sp)
    80200910:	8a66                	mv	s4,s9
    80200912:	40800633          	neg	a2,s0
    80200916:	46a9                	li	a3,10
    80200918:	b53d                	j	80200746 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    8020091a:	03b05163          	blez	s11,8020093c <vprintfmt+0x34c>
    8020091e:	02d00693          	li	a3,45
    80200922:	f6d79de3          	bne	a5,a3,8020089c <vprintfmt+0x2ac>
                p = "(null)";
    80200926:	00000417          	auipc	s0,0x0
    8020092a:	62a40413          	addi	s0,s0,1578 # 80200f50 <etext+0x58a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020092e:	02800793          	li	a5,40
    80200932:	02800513          	li	a0,40
    80200936:	00140a13          	addi	s4,s0,1
    8020093a:	bd6d                	j	802007f4 <vprintfmt+0x204>
    8020093c:	00000a17          	auipc	s4,0x0
    80200940:	615a0a13          	addi	s4,s4,1557 # 80200f51 <etext+0x58b>
    80200944:	02800513          	li	a0,40
    80200948:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020094c:	05e00413          	li	s0,94
    80200950:	b565                	j	802007f8 <vprintfmt+0x208>

0000000080200952 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200952:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200954:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200958:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020095a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020095c:	ec06                	sd	ra,24(sp)
    8020095e:	f83a                	sd	a4,48(sp)
    80200960:	fc3e                	sd	a5,56(sp)
    80200962:	e0c2                	sd	a6,64(sp)
    80200964:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200966:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200968:	c89ff0ef          	jal	ra,802005f0 <vprintfmt>
}
    8020096c:	60e2                	ld	ra,24(sp)
    8020096e:	6161                	addi	sp,sp,80
    80200970:	8082                	ret

0000000080200972 <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    80200972:	00003797          	auipc	a5,0x3
    80200976:	68e78793          	addi	a5,a5,1678 # 80204000 <bootstacktop>
    __asm__ volatile (
    8020097a:	6398                	ld	a4,0(a5)
    8020097c:	4781                	li	a5,0
    8020097e:	88ba                	mv	a7,a4
    80200980:	852a                	mv	a0,a0
    80200982:	85be                	mv	a1,a5
    80200984:	863e                	mv	a2,a5
    80200986:	00000073          	ecall
    8020098a:	87aa                	mv	a5,a0
}
    8020098c:	8082                	ret

000000008020098e <sbi_set_timer>:

//当time寄存器(rdtime的返回值)为stime_value的时候触发一个时钟中断
void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    8020098e:	00003797          	auipc	a5,0x3
    80200992:	68a78793          	addi	a5,a5,1674 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    80200996:	6398                	ld	a4,0(a5)
    80200998:	4781                	li	a5,0
    8020099a:	88ba                	mv	a7,a4
    8020099c:	852a                	mv	a0,a0
    8020099e:	85be                	mv	a1,a5
    802009a0:	863e                	mv	a2,a5
    802009a2:	00000073          	ecall
    802009a6:	87aa                	mv	a5,a0
}
    802009a8:	8082                	ret

00000000802009aa <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009aa:	00003797          	auipc	a5,0x3
    802009ae:	65e78793          	addi	a5,a5,1630 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009b2:	6398                	ld	a4,0(a5)
    802009b4:	4781                	li	a5,0
    802009b6:	88ba                	mv	a7,a4
    802009b8:	853e                	mv	a0,a5
    802009ba:	85be                	mv	a1,a5
    802009bc:	863e                	mv	a2,a5
    802009be:	00000073          	ecall
    802009c2:	87aa                	mv	a5,a0
    802009c4:	8082                	ret
