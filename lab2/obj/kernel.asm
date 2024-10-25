
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	56c010ef          	jal	ra,ffffffffc02015ba <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201ad8 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	08b000ef          	jal	ra,ffffffffc02008f4 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	58e010ef          	jal	ra,ffffffffc0201638 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	55a010ef          	jal	ra,ffffffffc0201638 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020013e:	00006317          	auipc	t1,0x6
ffffffffc0200142:	2d230313          	addi	t1,t1,722 # ffffffffc0206410 <is_panic>
ffffffffc0200146:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020014a:	715d                	addi	sp,sp,-80
ffffffffc020014c:	ec06                	sd	ra,24(sp)
ffffffffc020014e:	e822                	sd	s0,16(sp)
ffffffffc0200150:	f436                	sd	a3,40(sp)
ffffffffc0200152:	f83a                	sd	a4,48(sp)
ffffffffc0200154:	fc3e                	sd	a5,56(sp)
ffffffffc0200156:	e0c2                	sd	a6,64(sp)
ffffffffc0200158:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020015a:	02031c63          	bnez	t1,ffffffffc0200192 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020015e:	4785                	li	a5,1
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	00006717          	auipc	a4,0x6
ffffffffc0200166:	2af72723          	sw	a5,686(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016a:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020016c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020016e:	85aa                	mv	a1,a0
ffffffffc0200170:	00002517          	auipc	a0,0x2
ffffffffc0200174:	98850513          	addi	a0,a0,-1656 # ffffffffc0201af8 <etext+0x20>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201c10 <etext+0x138>
ffffffffc020018e:	f29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200192:	2d2000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200196:	4501                	li	a0,0
ffffffffc0200198:	132000ef          	jal	ra,ffffffffc02002ca <kmonitor>
ffffffffc020019c:	bfed                	j	ffffffffc0200196 <__panic+0x58>

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00002517          	auipc	a0,0x2
ffffffffc02001a4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0201b48 <etext+0x70>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	9b250513          	addi	a0,a0,-1614 # ffffffffc0201b68 <etext+0x90>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	91658593          	addi	a1,a1,-1770 # ffffffffc0201ad8 <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	9be50513          	addi	a0,a0,-1602 # ffffffffc0201b88 <etext+0xb0>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0201ba8 <etext+0xd0>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	28658593          	addi	a1,a1,646 # ffffffffc0206470 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201bc8 <etext+0xf0>
ffffffffc02001fa:	ebdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00006597          	auipc	a1,0x6
ffffffffc0200202:	67158593          	addi	a1,a1,1649 # ffffffffc020686f <end+0x3ff>
ffffffffc0200206:	00000797          	auipc	a5,0x0
ffffffffc020020a:	e3078793          	addi	a5,a5,-464 # ffffffffc0200036 <kern_init>
ffffffffc020020e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200212:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200218:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021c:	95be                	add	a1,a1,a5
ffffffffc020021e:	85a9                	srai	a1,a1,0xa
ffffffffc0200220:	00002517          	auipc	a0,0x2
ffffffffc0200224:	9c850513          	addi	a0,a0,-1592 # ffffffffc0201be8 <etext+0x110>
}
ffffffffc0200228:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020022a:	e8dff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020022e <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022e:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200230:	00002617          	auipc	a2,0x2
ffffffffc0200234:	8e860613          	addi	a2,a2,-1816 # ffffffffc0201b18 <etext+0x40>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201b30 <etext+0x58>
void print_stackframe(void) {
ffffffffc0200244:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200246:	ef9ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020024a <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020024c:	00002617          	auipc	a2,0x2
ffffffffc0200250:	aac60613          	addi	a2,a2,-1364 # ffffffffc0201cf8 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	ac458593          	addi	a1,a1,-1340 # ffffffffc0201d18 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	ac450513          	addi	a0,a0,-1340 # ffffffffc0201d20 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	ac660613          	addi	a2,a2,-1338 # ffffffffc0201d30 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	ae658593          	addi	a1,a1,-1306 # ffffffffc0201d58 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	aa650513          	addi	a0,a0,-1370 # ffffffffc0201d20 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0201d68 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	afa58593          	addi	a1,a1,-1286 # ffffffffc0201d88 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0201d20 <commands+0x108>
ffffffffc020029e:	e19ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc02002a2:	60a2                	ld	ra,8(sp)
ffffffffc02002a4:	4501                	li	a0,0
ffffffffc02002a6:	0141                	addi	sp,sp,16
ffffffffc02002a8:	8082                	ret

ffffffffc02002aa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002aa:	1141                	addi	sp,sp,-16
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002ae:	ef1ff0ef          	jal	ra,ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
ffffffffc02002b4:	4501                	li	a0,0
ffffffffc02002b6:	0141                	addi	sp,sp,16
ffffffffc02002b8:	8082                	ret

ffffffffc02002ba <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ba:	1141                	addi	sp,sp,-16
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002be:	f71ff0ef          	jal	ra,ffffffffc020022e <print_stackframe>
    return 0;
}
ffffffffc02002c2:	60a2                	ld	ra,8(sp)
ffffffffc02002c4:	4501                	li	a0,0
ffffffffc02002c6:	0141                	addi	sp,sp,16
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002ca:	7115                	addi	sp,sp,-224
ffffffffc02002cc:	e962                	sd	s8,144(sp)
ffffffffc02002ce:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002d0:	00002517          	auipc	a0,0x2
ffffffffc02002d4:	99050513          	addi	a0,a0,-1648 # ffffffffc0201c60 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002d8:	ed86                	sd	ra,216(sp)
ffffffffc02002da:	e9a2                	sd	s0,208(sp)
ffffffffc02002dc:	e5a6                	sd	s1,200(sp)
ffffffffc02002de:	e1ca                	sd	s2,192(sp)
ffffffffc02002e0:	fd4e                	sd	s3,184(sp)
ffffffffc02002e2:	f952                	sd	s4,176(sp)
ffffffffc02002e4:	f556                	sd	s5,168(sp)
ffffffffc02002e6:	f15a                	sd	s6,160(sp)
ffffffffc02002e8:	ed5e                	sd	s7,152(sp)
ffffffffc02002ea:	e566                	sd	s9,136(sp)
ffffffffc02002ec:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	dc9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002f2:	00002517          	auipc	a0,0x2
ffffffffc02002f6:	99650513          	addi	a0,a0,-1642 # ffffffffc0201c88 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00002c97          	auipc	s9,0x2
ffffffffc020030c:	910c8c93          	addi	s9,s9,-1776 # ffffffffc0201c18 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00002997          	auipc	s3,0x2
ffffffffc0200314:	9a098993          	addi	s3,s3,-1632 # ffffffffc0201cb0 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00002917          	auipc	s2,0x2
ffffffffc020031c:	9a090913          	addi	s2,s2,-1632 # ffffffffc0201cb8 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00002b17          	auipc	s6,0x2
ffffffffc0200326:	99eb0b13          	addi	s6,s6,-1634 # ffffffffc0201cc0 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00002a97          	auipc	s5,0x2
ffffffffc020032e:	9eea8a93          	addi	s5,s5,-1554 # ffffffffc0201d18 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	68e010ef          	jal	ra,ffffffffc02019c4 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	254010ef          	jal	ra,ffffffffc020159c <strchr>
ffffffffc020034c:	c925                	beqz	a0,ffffffffc02003bc <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
ffffffffc0200352:	00040023          	sb	zero,0(s0)
ffffffffc0200356:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200358:	f5fd                	bnez	a1,ffffffffc0200346 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc020035a:	dce9                	beqz	s1,ffffffffc0200334 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020035c:	6582                	ld	a1,0(sp)
ffffffffc020035e:	00002d17          	auipc	s10,0x2
ffffffffc0200362:	8bad0d13          	addi	s10,s10,-1862 # ffffffffc0201c18 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	206010ef          	jal	ra,ffffffffc0201572 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	1f2010ef          	jal	ra,ffffffffc0201572 <strcmp>
ffffffffc0200384:	f57d                	bnez	a0,ffffffffc0200372 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200386:	00141793          	slli	a5,s0,0x1
ffffffffc020038a:	97a2                	add	a5,a5,s0
ffffffffc020038c:	078e                	slli	a5,a5,0x3
ffffffffc020038e:	97e6                	add	a5,a5,s9
ffffffffc0200390:	6b9c                	ld	a5,16(a5)
ffffffffc0200392:	8662                	mv	a2,s8
ffffffffc0200394:	002c                	addi	a1,sp,8
ffffffffc0200396:	fff4851b          	addiw	a0,s1,-1
ffffffffc020039a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020039c:	f8055ce3          	bgez	a0,ffffffffc0200334 <kmonitor+0x6a>
}
ffffffffc02003a0:	60ee                	ld	ra,216(sp)
ffffffffc02003a2:	644e                	ld	s0,208(sp)
ffffffffc02003a4:	64ae                	ld	s1,200(sp)
ffffffffc02003a6:	690e                	ld	s2,192(sp)
ffffffffc02003a8:	79ea                	ld	s3,184(sp)
ffffffffc02003aa:	7a4a                	ld	s4,176(sp)
ffffffffc02003ac:	7aaa                	ld	s5,168(sp)
ffffffffc02003ae:	7b0a                	ld	s6,160(sp)
ffffffffc02003b0:	6bea                	ld	s7,152(sp)
ffffffffc02003b2:	6c4a                	ld	s8,144(sp)
ffffffffc02003b4:	6caa                	ld	s9,136(sp)
ffffffffc02003b6:	6d0a                	ld	s10,128(sp)
ffffffffc02003b8:	612d                	addi	sp,sp,224
ffffffffc02003ba:	8082                	ret
        if (*buf == '\0') {
ffffffffc02003bc:	00044783          	lbu	a5,0(s0)
ffffffffc02003c0:	dfc9                	beqz	a5,ffffffffc020035a <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc02003c2:	03448863          	beq	s1,s4,ffffffffc02003f2 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc02003c6:	00349793          	slli	a5,s1,0x3
ffffffffc02003ca:	0118                	addi	a4,sp,128
ffffffffc02003cc:	97ba                	add	a5,a5,a4
ffffffffc02003ce:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d2:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003d6:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003d8:	e591                	bnez	a1,ffffffffc02003e4 <kmonitor+0x11a>
ffffffffc02003da:	b749                	j	ffffffffc020035c <kmonitor+0x92>
            buf ++;
ffffffffc02003dc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003de:	00044583          	lbu	a1,0(s0)
ffffffffc02003e2:	ddad                	beqz	a1,ffffffffc020035c <kmonitor+0x92>
ffffffffc02003e4:	854a                	mv	a0,s2
ffffffffc02003e6:	1b6010ef          	jal	ra,ffffffffc020159c <strchr>
ffffffffc02003ea:	d96d                	beqz	a0,ffffffffc02003dc <kmonitor+0x112>
ffffffffc02003ec:	00044583          	lbu	a1,0(s0)
ffffffffc02003f0:	bf91                	j	ffffffffc0200344 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003f2:	45c1                	li	a1,16
ffffffffc02003f4:	855a                	mv	a0,s6
ffffffffc02003f6:	cc1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02003fa:	b7f1                	j	ffffffffc02003c6 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003fc:	6582                	ld	a1,0(sp)
ffffffffc02003fe:	00002517          	auipc	a0,0x2
ffffffffc0200402:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201ce0 <commands+0xc8>
ffffffffc0200406:	cb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc020040a:	b72d                	j	ffffffffc0200334 <kmonitor+0x6a>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	67a010ef          	jal	ra,ffffffffc0201a9e <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	96650513          	addi	a0,a0,-1690 # ffffffffc0201d98 <commands+0x180>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	6520106f          	j	ffffffffc0201a9e <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	62c0106f          	j	ffffffffc0201a82 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	6600106f          	j	ffffffffc0201aba <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0201eb0 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	a3450513          	addi	a0,a0,-1484 # ffffffffc0201ec8 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0201ee0 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	a4850513          	addi	a0,a0,-1464 # ffffffffc0201ef8 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	a5250513          	addi	a0,a0,-1454 # ffffffffc0201f10 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0201f28 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	a6650513          	addi	a0,a0,-1434 # ffffffffc0201f40 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	a7050513          	addi	a0,a0,-1424 # ffffffffc0201f58 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0201f70 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201f88 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0201fa0 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	a9850513          	addi	a0,a0,-1384 # ffffffffc0201fb8 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	aa250513          	addi	a0,a0,-1374 # ffffffffc0201fd0 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	aac50513          	addi	a0,a0,-1364 # ffffffffc0201fe8 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0202000 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0202018 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	aca50513          	addi	a0,a0,-1334 # ffffffffc0202030 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	ad450513          	addi	a0,a0,-1324 # ffffffffc0202048 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	ade50513          	addi	a0,a0,-1314 # ffffffffc0202060 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	ae850513          	addi	a0,a0,-1304 # ffffffffc0202078 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	af250513          	addi	a0,a0,-1294 # ffffffffc0202090 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	afc50513          	addi	a0,a0,-1284 # ffffffffc02020a8 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	b0650513          	addi	a0,a0,-1274 # ffffffffc02020c0 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	b1050513          	addi	a0,a0,-1264 # ffffffffc02020d8 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02020f0 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0202108 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0202120 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	b3850513          	addi	a0,a0,-1224 # ffffffffc0202138 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	b4250513          	addi	a0,a0,-1214 # ffffffffc0202150 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0202168 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0202180 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0202198 <commands+0x580>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02021b0 <commands+0x598>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	b5e50513          	addi	a0,a0,-1186 # ffffffffc02021c8 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021e0 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02021f8 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0202210 <commands+0x5f8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	6f870713          	addi	a4,a4,1784 # ffffffffc0201db4 <commands+0x19c>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	77a50513          	addi	a0,a0,1914 # ffffffffc0201e48 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	74e50513          	addi	a0,a0,1870 # ffffffffc0201e28 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	70250513          	addi	a0,a0,1794 # ffffffffc0201de8 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	77650513          	addi	a0,a0,1910 # ffffffffc0201e68 <commands+0x250>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	76650513          	addi	a0,a0,1894 # ffffffffc0201e90 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	6d250513          	addi	a0,a0,1746 # ffffffffc0201e08 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	73450513          	addi	a0,a0,1844 # ffffffffc0201e80 <commands+0x268>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020082a:	100027f3          	csrr	a5,sstatus
ffffffffc020082e:	8b89                	andi	a5,a5,2
ffffffffc0200830:	eb89                	bnez	a5,ffffffffc0200842 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200832:	00006797          	auipc	a5,0x6
ffffffffc0200836:	c2678793          	addi	a5,a5,-986 # ffffffffc0206458 <pmm_manager>
ffffffffc020083a:	639c                	ld	a5,0(a5)
ffffffffc020083c:	0187b303          	ld	t1,24(a5)
ffffffffc0200840:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200842:	1141                	addi	sp,sp,-16
ffffffffc0200844:	e406                	sd	ra,8(sp)
ffffffffc0200846:	e022                	sd	s0,0(sp)
ffffffffc0200848:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020084a:	c1bff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020084e:	00006797          	auipc	a5,0x6
ffffffffc0200852:	c0a78793          	addi	a5,a5,-1014 # ffffffffc0206458 <pmm_manager>
ffffffffc0200856:	639c                	ld	a5,0(a5)
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	6f9c                	ld	a5,24(a5)
ffffffffc020085c:	9782                	jalr	a5
ffffffffc020085e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200864:	8522                	mv	a0,s0
ffffffffc0200866:	60a2                	ld	ra,8(sp)
ffffffffc0200868:	6402                	ld	s0,0(sp)
ffffffffc020086a:	0141                	addi	sp,sp,16
ffffffffc020086c:	8082                	ret

ffffffffc020086e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020086e:	100027f3          	csrr	a5,sstatus
ffffffffc0200872:	8b89                	andi	a5,a5,2
ffffffffc0200874:	eb89                	bnez	a5,ffffffffc0200886 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200876:	00006797          	auipc	a5,0x6
ffffffffc020087a:	be278793          	addi	a5,a5,-1054 # ffffffffc0206458 <pmm_manager>
ffffffffc020087e:	639c                	ld	a5,0(a5)
ffffffffc0200880:	0207b303          	ld	t1,32(a5)
ffffffffc0200884:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200886:	1101                	addi	sp,sp,-32
ffffffffc0200888:	ec06                	sd	ra,24(sp)
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	e426                	sd	s1,8(sp)
ffffffffc020088e:	842a                	mv	s0,a0
ffffffffc0200890:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200892:	bd3ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200896:	00006797          	auipc	a5,0x6
ffffffffc020089a:	bc278793          	addi	a5,a5,-1086 # ffffffffc0206458 <pmm_manager>
ffffffffc020089e:	639c                	ld	a5,0(a5)
ffffffffc02008a0:	85a6                	mv	a1,s1
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	739c                	ld	a5,32(a5)
ffffffffc02008a6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008a8:	6442                	ld	s0,16(sp)
ffffffffc02008aa:	60e2                	ld	ra,24(sp)
ffffffffc02008ac:	64a2                	ld	s1,8(sp)
ffffffffc02008ae:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02008b0:	bafff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc02008b4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008b4:	100027f3          	csrr	a5,sstatus
ffffffffc02008b8:	8b89                	andi	a5,a5,2
ffffffffc02008ba:	eb89                	bnez	a5,ffffffffc02008cc <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02008bc:	00006797          	auipc	a5,0x6
ffffffffc02008c0:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0206458 <pmm_manager>
ffffffffc02008c4:	639c                	ld	a5,0(a5)
ffffffffc02008c6:	0287b303          	ld	t1,40(a5)
ffffffffc02008ca:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc02008cc:	1141                	addi	sp,sp,-16
ffffffffc02008ce:	e406                	sd	ra,8(sp)
ffffffffc02008d0:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02008d2:	b93ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02008d6:	00006797          	auipc	a5,0x6
ffffffffc02008da:	b8278793          	addi	a5,a5,-1150 # ffffffffc0206458 <pmm_manager>
ffffffffc02008de:	639c                	ld	a5,0(a5)
ffffffffc02008e0:	779c                	ld	a5,40(a5)
ffffffffc02008e2:	9782                	jalr	a5
ffffffffc02008e4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02008e6:	b79ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02008ea:	8522                	mv	a0,s0
ffffffffc02008ec:	60a2                	ld	ra,8(sp)
ffffffffc02008ee:	6402                	ld	s0,0(sp)
ffffffffc02008f0:	0141                	addi	sp,sp,16
ffffffffc02008f2:	8082                	ret

ffffffffc02008f4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02008f4:	00002797          	auipc	a5,0x2
ffffffffc02008f8:	d9478793          	addi	a5,a5,-620 # ffffffffc0202688 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008fc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02008fe:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200900:	00002517          	auipc	a0,0x2
ffffffffc0200904:	92850513          	addi	a0,a0,-1752 # ffffffffc0202228 <commands+0x610>
void pmm_init(void) {
ffffffffc0200908:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020090a:	00006717          	auipc	a4,0x6
ffffffffc020090e:	b4f73723          	sd	a5,-1202(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0200912:	e822                	sd	s0,16(sp)
ffffffffc0200914:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200916:	00006417          	auipc	s0,0x6
ffffffffc020091a:	b4240413          	addi	s0,s0,-1214 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020091e:	f98ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200922:	601c                	ld	a5,0(s0)
ffffffffc0200924:	679c                	ld	a5,8(a5)
ffffffffc0200926:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200928:	57f5                	li	a5,-3
ffffffffc020092a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020092c:	00002517          	auipc	a0,0x2
ffffffffc0200930:	91450513          	addi	a0,a0,-1772 # ffffffffc0202240 <commands+0x628>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200934:	00006717          	auipc	a4,0x6
ffffffffc0200938:	b2f73623          	sd	a5,-1236(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020093c:	f7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200940:	46c5                	li	a3,17
ffffffffc0200942:	06ee                	slli	a3,a3,0x1b
ffffffffc0200944:	40100613          	li	a2,1025
ffffffffc0200948:	16fd                	addi	a3,a3,-1
ffffffffc020094a:	0656                	slli	a2,a2,0x15
ffffffffc020094c:	07e005b7          	lui	a1,0x7e00
ffffffffc0200950:	00002517          	auipc	a0,0x2
ffffffffc0200954:	90850513          	addi	a0,a0,-1784 # ffffffffc0202258 <commands+0x640>
ffffffffc0200958:	f5eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020095c:	777d                	lui	a4,0xfffff
ffffffffc020095e:	00007797          	auipc	a5,0x7
ffffffffc0200962:	b1178793          	addi	a5,a5,-1263 # ffffffffc020746f <end+0xfff>
ffffffffc0200966:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200968:	00088737          	lui	a4,0x88
ffffffffc020096c:	00006697          	auipc	a3,0x6
ffffffffc0200970:	aae6b623          	sd	a4,-1364(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200974:	4601                	li	a2,0
ffffffffc0200976:	00006717          	auipc	a4,0x6
ffffffffc020097a:	aef73923          	sd	a5,-1294(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020097e:	4681                	li	a3,0
ffffffffc0200980:	00006897          	auipc	a7,0x6
ffffffffc0200984:	a9888893          	addi	a7,a7,-1384 # ffffffffc0206418 <npage>
ffffffffc0200988:	00006597          	auipc	a1,0x6
ffffffffc020098c:	ae058593          	addi	a1,a1,-1312 # ffffffffc0206468 <pages>
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200990:	4805                	li	a6,1
ffffffffc0200992:	fff80537          	lui	a0,0xfff80
ffffffffc0200996:	a011                	j	ffffffffc020099a <pmm_init+0xa6>
ffffffffc0200998:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020099a:	97b2                	add	a5,a5,a2
ffffffffc020099c:	07a1                	addi	a5,a5,8
ffffffffc020099e:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02009a2:	0008b703          	ld	a4,0(a7)
ffffffffc02009a6:	0685                	addi	a3,a3,1
ffffffffc02009a8:	02860613          	addi	a2,a2,40
ffffffffc02009ac:	00a707b3          	add	a5,a4,a0
ffffffffc02009b0:	fef6e4e3          	bltu	a3,a5,ffffffffc0200998 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009b4:	6190                	ld	a2,0(a1)
ffffffffc02009b6:	00271793          	slli	a5,a4,0x2
ffffffffc02009ba:	97ba                	add	a5,a5,a4
ffffffffc02009bc:	fec006b7          	lui	a3,0xfec00
ffffffffc02009c0:	078e                	slli	a5,a5,0x3
ffffffffc02009c2:	96b2                	add	a3,a3,a2
ffffffffc02009c4:	96be                	add	a3,a3,a5
ffffffffc02009c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02009ca:	08f6e863          	bltu	a3,a5,ffffffffc0200a5a <pmm_init+0x166>
ffffffffc02009ce:	00006497          	auipc	s1,0x6
ffffffffc02009d2:	a9248493          	addi	s1,s1,-1390 # ffffffffc0206460 <va_pa_offset>
ffffffffc02009d6:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc02009d8:	45c5                	li	a1,17
ffffffffc02009da:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009dc:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc02009de:	04b6e963          	bltu	a3,a1,ffffffffc0200a30 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02009e2:	601c                	ld	a5,0(s0)
ffffffffc02009e4:	7b9c                	ld	a5,48(a5)
ffffffffc02009e6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02009e8:	00002517          	auipc	a0,0x2
ffffffffc02009ec:	90850513          	addi	a0,a0,-1784 # ffffffffc02022f0 <commands+0x6d8>
ffffffffc02009f0:	ec6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02009f4:	00004697          	auipc	a3,0x4
ffffffffc02009f8:	60c68693          	addi	a3,a3,1548 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02009fc:	00006797          	auipc	a5,0x6
ffffffffc0200a00:	a2d7b223          	sd	a3,-1500(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a04:	c02007b7          	lui	a5,0xc0200
ffffffffc0200a08:	06f6e563          	bltu	a3,a5,ffffffffc0200a72 <pmm_init+0x17e>
ffffffffc0200a0c:	609c                	ld	a5,0(s1)
}
ffffffffc0200a0e:	6442                	ld	s0,16(sp)
ffffffffc0200a10:	60e2                	ld	ra,24(sp)
ffffffffc0200a12:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a14:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a16:	8e9d                	sub	a3,a3,a5
ffffffffc0200a18:	00006797          	auipc	a5,0x6
ffffffffc0200a1c:	a2d7bc23          	sd	a3,-1480(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a20:	00002517          	auipc	a0,0x2
ffffffffc0200a24:	8f050513          	addi	a0,a0,-1808 # ffffffffc0202310 <commands+0x6f8>
ffffffffc0200a28:	8636                	mv	a2,a3
}
ffffffffc0200a2a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200a2c:	e8aff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200a30:	6785                	lui	a5,0x1
ffffffffc0200a32:	17fd                	addi	a5,a5,-1
ffffffffc0200a34:	96be                	add	a3,a3,a5
ffffffffc0200a36:	77fd                	lui	a5,0xfffff
ffffffffc0200a38:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200a3a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200a3e:	04e7f663          	bleu	a4,a5,ffffffffc0200a8a <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200a42:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200a44:	97aa                	add	a5,a5,a0
ffffffffc0200a46:	00279513          	slli	a0,a5,0x2
ffffffffc0200a4a:	953e                	add	a0,a0,a5
ffffffffc0200a4c:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200a4e:	8d95                	sub	a1,a1,a3
ffffffffc0200a50:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200a52:	81b1                	srli	a1,a1,0xc
ffffffffc0200a54:	9532                	add	a0,a0,a2
ffffffffc0200a56:	9782                	jalr	a5
ffffffffc0200a58:	b769                	j	ffffffffc02009e2 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200a5a:	00002617          	auipc	a2,0x2
ffffffffc0200a5e:	82e60613          	addi	a2,a2,-2002 # ffffffffc0202288 <commands+0x670>
ffffffffc0200a62:	06e00593          	li	a1,110
ffffffffc0200a66:	00002517          	auipc	a0,0x2
ffffffffc0200a6a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02022b0 <commands+0x698>
ffffffffc0200a6e:	ed0ff0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200a72:	00002617          	auipc	a2,0x2
ffffffffc0200a76:	81660613          	addi	a2,a2,-2026 # ffffffffc0202288 <commands+0x670>
ffffffffc0200a7a:	08900593          	li	a1,137
ffffffffc0200a7e:	00002517          	auipc	a0,0x2
ffffffffc0200a82:	83250513          	addi	a0,a0,-1998 # ffffffffc02022b0 <commands+0x698>
ffffffffc0200a86:	eb8ff0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200a8a:	00002617          	auipc	a2,0x2
ffffffffc0200a8e:	83660613          	addi	a2,a2,-1994 # ffffffffc02022c0 <commands+0x6a8>
ffffffffc0200a92:	06b00593          	li	a1,107
ffffffffc0200a96:	00002517          	auipc	a0,0x2
ffffffffc0200a9a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02022e0 <commands+0x6c8>
ffffffffc0200a9e:	ea0ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200aa2 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200aa2:	00006797          	auipc	a5,0x6
ffffffffc0200aa6:	99678793          	addi	a5,a5,-1642 # ffffffffc0206438 <free_area>
ffffffffc0200aaa:	e79c                	sd	a5,8(a5)
ffffffffc0200aac:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aae:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ab2:	8082                	ret

ffffffffc0200ab4 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ab4:	00006517          	auipc	a0,0x6
ffffffffc0200ab8:	99456503          	lwu	a0,-1644(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200abc:	8082                	ret

ffffffffc0200abe <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200abe:	715d                	addi	sp,sp,-80
ffffffffc0200ac0:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ac2:	00006917          	auipc	s2,0x6
ffffffffc0200ac6:	97690913          	addi	s2,s2,-1674 # ffffffffc0206438 <free_area>
ffffffffc0200aca:	00893783          	ld	a5,8(s2)
ffffffffc0200ace:	e486                	sd	ra,72(sp)
ffffffffc0200ad0:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad2:	fc26                	sd	s1,56(sp)
ffffffffc0200ad4:	f44e                	sd	s3,40(sp)
ffffffffc0200ad6:	f052                	sd	s4,32(sp)
ffffffffc0200ad8:	ec56                	sd	s5,24(sp)
ffffffffc0200ada:	e85a                	sd	s6,16(sp)
ffffffffc0200adc:	e45e                	sd	s7,8(sp)
ffffffffc0200ade:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ae0:	2d278363          	beq	a5,s2,ffffffffc0200da6 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ae4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200ae8:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200aea:	8b05                	andi	a4,a4,1
ffffffffc0200aec:	2c070163          	beqz	a4,ffffffffc0200dae <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200af0:	4401                	li	s0,0
ffffffffc0200af2:	4481                	li	s1,0
ffffffffc0200af4:	a031                	j	ffffffffc0200b00 <best_fit_check+0x42>
ffffffffc0200af6:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200afa:	8b09                	andi	a4,a4,2
ffffffffc0200afc:	2a070963          	beqz	a4,ffffffffc0200dae <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200b00:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b04:	679c                	ld	a5,8(a5)
ffffffffc0200b06:	2485                	addiw	s1,s1,1
ffffffffc0200b08:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b0a:	ff2796e3          	bne	a5,s2,ffffffffc0200af6 <best_fit_check+0x38>
ffffffffc0200b0e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b10:	da5ff0ef          	jal	ra,ffffffffc02008b4 <nr_free_pages>
ffffffffc0200b14:	37351d63          	bne	a0,s3,ffffffffc0200e8e <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b18:	4505                	li	a0,1
ffffffffc0200b1a:	d11ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200b1e:	8a2a                	mv	s4,a0
ffffffffc0200b20:	3a050763          	beqz	a0,ffffffffc0200ece <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b24:	4505                	li	a0,1
ffffffffc0200b26:	d05ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200b2a:	89aa                	mv	s3,a0
ffffffffc0200b2c:	38050163          	beqz	a0,ffffffffc0200eae <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b30:	4505                	li	a0,1
ffffffffc0200b32:	cf9ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200b36:	8aaa                	mv	s5,a0
ffffffffc0200b38:	30050b63          	beqz	a0,ffffffffc0200e4e <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b3c:	293a0963          	beq	s4,s3,ffffffffc0200dce <best_fit_check+0x310>
ffffffffc0200b40:	28aa0763          	beq	s4,a0,ffffffffc0200dce <best_fit_check+0x310>
ffffffffc0200b44:	28a98563          	beq	s3,a0,ffffffffc0200dce <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b48:	000a2783          	lw	a5,0(s4)
ffffffffc0200b4c:	2a079163          	bnez	a5,ffffffffc0200dee <best_fit_check+0x330>
ffffffffc0200b50:	0009a783          	lw	a5,0(s3)
ffffffffc0200b54:	28079d63          	bnez	a5,ffffffffc0200dee <best_fit_check+0x330>
ffffffffc0200b58:	411c                	lw	a5,0(a0)
ffffffffc0200b5a:	28079a63          	bnez	a5,ffffffffc0200dee <best_fit_check+0x330>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b5e:	00006797          	auipc	a5,0x6
ffffffffc0200b62:	90a78793          	addi	a5,a5,-1782 # ffffffffc0206468 <pages>
ffffffffc0200b66:	639c                	ld	a5,0(a5)
ffffffffc0200b68:	00001717          	auipc	a4,0x1
ffffffffc0200b6c:	7e870713          	addi	a4,a4,2024 # ffffffffc0202350 <commands+0x738>
ffffffffc0200b70:	630c                	ld	a1,0(a4)
ffffffffc0200b72:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b76:	870d                	srai	a4,a4,0x3
ffffffffc0200b78:	02b70733          	mul	a4,a4,a1
ffffffffc0200b7c:	00002697          	auipc	a3,0x2
ffffffffc0200b80:	da468693          	addi	a3,a3,-604 # ffffffffc0202920 <nbase>
ffffffffc0200b84:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b86:	00006697          	auipc	a3,0x6
ffffffffc0200b8a:	89268693          	addi	a3,a3,-1902 # ffffffffc0206418 <npage>
ffffffffc0200b8e:	6294                	ld	a3,0(a3)
ffffffffc0200b90:	06b2                	slli	a3,a3,0xc
ffffffffc0200b92:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b94:	0732                	slli	a4,a4,0xc
ffffffffc0200b96:	26d77c63          	bleu	a3,a4,ffffffffc0200e0e <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9a:	40f98733          	sub	a4,s3,a5
ffffffffc0200b9e:	870d                	srai	a4,a4,0x3
ffffffffc0200ba0:	02b70733          	mul	a4,a4,a1
ffffffffc0200ba4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ba6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ba8:	42d77363          	bleu	a3,a4,ffffffffc0200fce <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bac:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bb0:	878d                	srai	a5,a5,0x3
ffffffffc0200bb2:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bb6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bb8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bba:	3ed7fa63          	bleu	a3,a5,ffffffffc0200fae <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200bbe:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bc0:	00093c03          	ld	s8,0(s2)
ffffffffc0200bc4:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bc8:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200bcc:	00006797          	auipc	a5,0x6
ffffffffc0200bd0:	8727ba23          	sd	s2,-1932(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200bd4:	00006797          	auipc	a5,0x6
ffffffffc0200bd8:	8727b223          	sd	s2,-1948(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200bdc:	00006797          	auipc	a5,0x6
ffffffffc0200be0:	8607a623          	sw	zero,-1940(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200be4:	c47ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200be8:	3a051363          	bnez	a0,ffffffffc0200f8e <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200bec:	4585                	li	a1,1
ffffffffc0200bee:	8552                	mv	a0,s4
ffffffffc0200bf0:	c7fff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc0200bf4:	4585                	li	a1,1
ffffffffc0200bf6:	854e                	mv	a0,s3
ffffffffc0200bf8:	c77ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p2);
ffffffffc0200bfc:	4585                	li	a1,1
ffffffffc0200bfe:	8556                	mv	a0,s5
ffffffffc0200c00:	c6fff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(nr_free == 3);
ffffffffc0200c04:	01092703          	lw	a4,16(s2)
ffffffffc0200c08:	478d                	li	a5,3
ffffffffc0200c0a:	36f71263          	bne	a4,a5,ffffffffc0200f6e <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c0e:	4505                	li	a0,1
ffffffffc0200c10:	c1bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c14:	89aa                	mv	s3,a0
ffffffffc0200c16:	32050c63          	beqz	a0,ffffffffc0200f4e <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c1a:	4505                	li	a0,1
ffffffffc0200c1c:	c0fff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c20:	8aaa                	mv	s5,a0
ffffffffc0200c22:	30050663          	beqz	a0,ffffffffc0200f2e <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c26:	4505                	li	a0,1
ffffffffc0200c28:	c03ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c2c:	8a2a                	mv	s4,a0
ffffffffc0200c2e:	2e050063          	beqz	a0,ffffffffc0200f0e <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	bf7ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c38:	2a051b63          	bnez	a0,ffffffffc0200eee <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200c3c:	4585                	li	a1,1
ffffffffc0200c3e:	854e                	mv	a0,s3
ffffffffc0200c40:	c2fff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c44:	00893783          	ld	a5,8(s2)
ffffffffc0200c48:	1f278363          	beq	a5,s2,ffffffffc0200e2e <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	bddff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c52:	54a99e63          	bne	s3,a0,ffffffffc02011ae <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200c56:	4505                	li	a0,1
ffffffffc0200c58:	bd3ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c5c:	52051963          	bnez	a0,ffffffffc020118e <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200c60:	01092783          	lw	a5,16(s2)
ffffffffc0200c64:	50079563          	bnez	a5,ffffffffc020116e <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200c68:	854e                	mv	a0,s3
ffffffffc0200c6a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c6c:	00005797          	auipc	a5,0x5
ffffffffc0200c70:	7d87b623          	sd	s8,1996(a5) # ffffffffc0206438 <free_area>
ffffffffc0200c74:	00005797          	auipc	a5,0x5
ffffffffc0200c78:	7d77b623          	sd	s7,1996(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200c7c:	00005797          	auipc	a5,0x5
ffffffffc0200c80:	7d67a623          	sw	s6,1996(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200c84:	bebff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p1);
ffffffffc0200c88:	4585                	li	a1,1
ffffffffc0200c8a:	8556                	mv	a0,s5
ffffffffc0200c8c:	be3ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_page(p2);
ffffffffc0200c90:	4585                	li	a1,1
ffffffffc0200c92:	8552                	mv	a0,s4
ffffffffc0200c94:	bdbff0ef          	jal	ra,ffffffffc020086e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c98:	4515                	li	a0,5
ffffffffc0200c9a:	b91ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200c9e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ca0:	4a050763          	beqz	a0,ffffffffc020114e <best_fit_check+0x690>
ffffffffc0200ca4:	651c                	ld	a5,8(a0)
ffffffffc0200ca6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ca8:	8b85                	andi	a5,a5,1
ffffffffc0200caa:	48079263          	bnez	a5,ffffffffc020112e <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cae:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cb0:	00093b03          	ld	s6,0(s2)
ffffffffc0200cb4:	00893a83          	ld	s5,8(s2)
ffffffffc0200cb8:	00005797          	auipc	a5,0x5
ffffffffc0200cbc:	7927b023          	sd	s2,1920(a5) # ffffffffc0206438 <free_area>
ffffffffc0200cc0:	00005797          	auipc	a5,0x5
ffffffffc0200cc4:	7927b023          	sd	s2,1920(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200cc8:	b63ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200ccc:	44051163          	bnez	a0,ffffffffc020110e <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200cd0:	4589                	li	a1,2
ffffffffc0200cd2:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200cd6:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200cda:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200cde:	00005797          	auipc	a5,0x5
ffffffffc0200ce2:	7607a523          	sw	zero,1898(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200ce6:	b89ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200cea:	8562                	mv	a0,s8
ffffffffc0200cec:	4585                	li	a1,1
ffffffffc0200cee:	b81ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cf2:	4511                	li	a0,4
ffffffffc0200cf4:	b37ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200cf8:	3e051b63          	bnez	a0,ffffffffc02010ee <best_fit_check+0x630>
ffffffffc0200cfc:	0309b783          	ld	a5,48(s3)
ffffffffc0200d00:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200d02:	8b85                	andi	a5,a5,1
ffffffffc0200d04:	3c078563          	beqz	a5,ffffffffc02010ce <best_fit_check+0x610>
ffffffffc0200d08:	0389a703          	lw	a4,56(s3)
ffffffffc0200d0c:	4789                	li	a5,2
ffffffffc0200d0e:	3cf71063          	bne	a4,a5,ffffffffc02010ce <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200d12:	4505                	li	a0,1
ffffffffc0200d14:	b17ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d18:	8a2a                	mv	s4,a0
ffffffffc0200d1a:	38050a63          	beqz	a0,ffffffffc02010ae <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200d1e:	4509                	li	a0,2
ffffffffc0200d20:	b0bff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d24:	36050563          	beqz	a0,ffffffffc020108e <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200d28:	354c1363          	bne	s8,s4,ffffffffc020106e <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200d2c:	854e                	mv	a0,s3
ffffffffc0200d2e:	4595                	li	a1,5
ffffffffc0200d30:	b3fff0ef          	jal	ra,ffffffffc020086e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d34:	4515                	li	a0,5
ffffffffc0200d36:	af5ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d3a:	89aa                	mv	s3,a0
ffffffffc0200d3c:	30050963          	beqz	a0,ffffffffc020104e <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200d40:	4505                	li	a0,1
ffffffffc0200d42:	ae9ff0ef          	jal	ra,ffffffffc020082a <alloc_pages>
ffffffffc0200d46:	2e051463          	bnez	a0,ffffffffc020102e <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200d4a:	01092783          	lw	a5,16(s2)
ffffffffc0200d4e:	2c079063          	bnez	a5,ffffffffc020100e <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d52:	4595                	li	a1,5
ffffffffc0200d54:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d56:	00005797          	auipc	a5,0x5
ffffffffc0200d5a:	6f77a923          	sw	s7,1778(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200d5e:	00005797          	auipc	a5,0x5
ffffffffc0200d62:	6d67bd23          	sd	s6,1754(a5) # ffffffffc0206438 <free_area>
ffffffffc0200d66:	00005797          	auipc	a5,0x5
ffffffffc0200d6a:	6d57bd23          	sd	s5,1754(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200d6e:	b01ff0ef          	jal	ra,ffffffffc020086e <free_pages>
    return listelm->next;
ffffffffc0200d72:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d76:	01278963          	beq	a5,s2,ffffffffc0200d88 <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d7a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d7e:	679c                	ld	a5,8(a5)
ffffffffc0200d80:	34fd                	addiw	s1,s1,-1
ffffffffc0200d82:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d84:	ff279be3          	bne	a5,s2,ffffffffc0200d7a <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200d88:	26049363          	bnez	s1,ffffffffc0200fee <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200d8c:	e06d                	bnez	s0,ffffffffc0200e6e <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200d8e:	60a6                	ld	ra,72(sp)
ffffffffc0200d90:	6406                	ld	s0,64(sp)
ffffffffc0200d92:	74e2                	ld	s1,56(sp)
ffffffffc0200d94:	7942                	ld	s2,48(sp)
ffffffffc0200d96:	79a2                	ld	s3,40(sp)
ffffffffc0200d98:	7a02                	ld	s4,32(sp)
ffffffffc0200d9a:	6ae2                	ld	s5,24(sp)
ffffffffc0200d9c:	6b42                	ld	s6,16(sp)
ffffffffc0200d9e:	6ba2                	ld	s7,8(sp)
ffffffffc0200da0:	6c02                	ld	s8,0(sp)
ffffffffc0200da2:	6161                	addi	sp,sp,80
ffffffffc0200da4:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200da6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200da8:	4401                	li	s0,0
ffffffffc0200daa:	4481                	li	s1,0
ffffffffc0200dac:	b395                	j	ffffffffc0200b10 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200dae:	00001697          	auipc	a3,0x1
ffffffffc0200db2:	5aa68693          	addi	a3,a3,1450 # ffffffffc0202358 <commands+0x740>
ffffffffc0200db6:	00001617          	auipc	a2,0x1
ffffffffc0200dba:	5b260613          	addi	a2,a2,1458 # ffffffffc0202368 <commands+0x750>
ffffffffc0200dbe:	11200593          	li	a1,274
ffffffffc0200dc2:	00001517          	auipc	a0,0x1
ffffffffc0200dc6:	5be50513          	addi	a0,a0,1470 # ffffffffc0202380 <commands+0x768>
ffffffffc0200dca:	b74ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200dce:	00001697          	auipc	a3,0x1
ffffffffc0200dd2:	64a68693          	addi	a3,a3,1610 # ffffffffc0202418 <commands+0x800>
ffffffffc0200dd6:	00001617          	auipc	a2,0x1
ffffffffc0200dda:	59260613          	addi	a2,a2,1426 # ffffffffc0202368 <commands+0x750>
ffffffffc0200dde:	0de00593          	li	a1,222
ffffffffc0200de2:	00001517          	auipc	a0,0x1
ffffffffc0200de6:	59e50513          	addi	a0,a0,1438 # ffffffffc0202380 <commands+0x768>
ffffffffc0200dea:	b54ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200dee:	00001697          	auipc	a3,0x1
ffffffffc0200df2:	65268693          	addi	a3,a3,1618 # ffffffffc0202440 <commands+0x828>
ffffffffc0200df6:	00001617          	auipc	a2,0x1
ffffffffc0200dfa:	57260613          	addi	a2,a2,1394 # ffffffffc0202368 <commands+0x750>
ffffffffc0200dfe:	0df00593          	li	a1,223
ffffffffc0200e02:	00001517          	auipc	a0,0x1
ffffffffc0200e06:	57e50513          	addi	a0,a0,1406 # ffffffffc0202380 <commands+0x768>
ffffffffc0200e0a:	b34ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e0e:	00001697          	auipc	a3,0x1
ffffffffc0200e12:	67268693          	addi	a3,a3,1650 # ffffffffc0202480 <commands+0x868>
ffffffffc0200e16:	00001617          	auipc	a2,0x1
ffffffffc0200e1a:	55260613          	addi	a2,a2,1362 # ffffffffc0202368 <commands+0x750>
ffffffffc0200e1e:	0e100593          	li	a1,225
ffffffffc0200e22:	00001517          	auipc	a0,0x1
ffffffffc0200e26:	55e50513          	addi	a0,a0,1374 # ffffffffc0202380 <commands+0x768>
ffffffffc0200e2a:	b14ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e2e:	00001697          	auipc	a3,0x1
ffffffffc0200e32:	6da68693          	addi	a3,a3,1754 # ffffffffc0202508 <commands+0x8f0>
ffffffffc0200e36:	00001617          	auipc	a2,0x1
ffffffffc0200e3a:	53260613          	addi	a2,a2,1330 # ffffffffc0202368 <commands+0x750>
ffffffffc0200e3e:	0fa00593          	li	a1,250
ffffffffc0200e42:	00001517          	auipc	a0,0x1
ffffffffc0200e46:	53e50513          	addi	a0,a0,1342 # ffffffffc0202380 <commands+0x768>
ffffffffc0200e4a:	af4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e4e:	00001697          	auipc	a3,0x1
ffffffffc0200e52:	5aa68693          	addi	a3,a3,1450 # ffffffffc02023f8 <commands+0x7e0>
ffffffffc0200e56:	00001617          	auipc	a2,0x1
ffffffffc0200e5a:	51260613          	addi	a2,a2,1298 # ffffffffc0202368 <commands+0x750>
ffffffffc0200e5e:	0dc00593          	li	a1,220
ffffffffc0200e62:	00001517          	auipc	a0,0x1
ffffffffc0200e66:	51e50513          	addi	a0,a0,1310 # ffffffffc0202380 <commands+0x768>
ffffffffc0200e6a:	ad4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == 0);
ffffffffc0200e6e:	00001697          	auipc	a3,0x1
ffffffffc0200e72:	7ca68693          	addi	a3,a3,1994 # ffffffffc0202638 <commands+0xa20>
ffffffffc0200e76:	00001617          	auipc	a2,0x1
ffffffffc0200e7a:	4f260613          	addi	a2,a2,1266 # ffffffffc0202368 <commands+0x750>
ffffffffc0200e7e:	15400593          	li	a1,340
ffffffffc0200e82:	00001517          	auipc	a0,0x1
ffffffffc0200e86:	4fe50513          	addi	a0,a0,1278 # ffffffffc0202380 <commands+0x768>
ffffffffc0200e8a:	ab4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e8e:	00001697          	auipc	a3,0x1
ffffffffc0200e92:	50a68693          	addi	a3,a3,1290 # ffffffffc0202398 <commands+0x780>
ffffffffc0200e96:	00001617          	auipc	a2,0x1
ffffffffc0200e9a:	4d260613          	addi	a2,a2,1234 # ffffffffc0202368 <commands+0x750>
ffffffffc0200e9e:	11500593          	li	a1,277
ffffffffc0200ea2:	00001517          	auipc	a0,0x1
ffffffffc0200ea6:	4de50513          	addi	a0,a0,1246 # ffffffffc0202380 <commands+0x768>
ffffffffc0200eaa:	a94ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200eae:	00001697          	auipc	a3,0x1
ffffffffc0200eb2:	52a68693          	addi	a3,a3,1322 # ffffffffc02023d8 <commands+0x7c0>
ffffffffc0200eb6:	00001617          	auipc	a2,0x1
ffffffffc0200eba:	4b260613          	addi	a2,a2,1202 # ffffffffc0202368 <commands+0x750>
ffffffffc0200ebe:	0db00593          	li	a1,219
ffffffffc0200ec2:	00001517          	auipc	a0,0x1
ffffffffc0200ec6:	4be50513          	addi	a0,a0,1214 # ffffffffc0202380 <commands+0x768>
ffffffffc0200eca:	a74ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ece:	00001697          	auipc	a3,0x1
ffffffffc0200ed2:	4ea68693          	addi	a3,a3,1258 # ffffffffc02023b8 <commands+0x7a0>
ffffffffc0200ed6:	00001617          	auipc	a2,0x1
ffffffffc0200eda:	49260613          	addi	a2,a2,1170 # ffffffffc0202368 <commands+0x750>
ffffffffc0200ede:	0da00593          	li	a1,218
ffffffffc0200ee2:	00001517          	auipc	a0,0x1
ffffffffc0200ee6:	49e50513          	addi	a0,a0,1182 # ffffffffc0202380 <commands+0x768>
ffffffffc0200eea:	a54ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200eee:	00001697          	auipc	a3,0x1
ffffffffc0200ef2:	5f268693          	addi	a3,a3,1522 # ffffffffc02024e0 <commands+0x8c8>
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	47260613          	addi	a2,a2,1138 # ffffffffc0202368 <commands+0x750>
ffffffffc0200efe:	0f700593          	li	a1,247
ffffffffc0200f02:	00001517          	auipc	a0,0x1
ffffffffc0200f06:	47e50513          	addi	a0,a0,1150 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f0a:	a34ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f0e:	00001697          	auipc	a3,0x1
ffffffffc0200f12:	4ea68693          	addi	a3,a3,1258 # ffffffffc02023f8 <commands+0x7e0>
ffffffffc0200f16:	00001617          	auipc	a2,0x1
ffffffffc0200f1a:	45260613          	addi	a2,a2,1106 # ffffffffc0202368 <commands+0x750>
ffffffffc0200f1e:	0f500593          	li	a1,245
ffffffffc0200f22:	00001517          	auipc	a0,0x1
ffffffffc0200f26:	45e50513          	addi	a0,a0,1118 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f2a:	a14ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f2e:	00001697          	auipc	a3,0x1
ffffffffc0200f32:	4aa68693          	addi	a3,a3,1194 # ffffffffc02023d8 <commands+0x7c0>
ffffffffc0200f36:	00001617          	auipc	a2,0x1
ffffffffc0200f3a:	43260613          	addi	a2,a2,1074 # ffffffffc0202368 <commands+0x750>
ffffffffc0200f3e:	0f400593          	li	a1,244
ffffffffc0200f42:	00001517          	auipc	a0,0x1
ffffffffc0200f46:	43e50513          	addi	a0,a0,1086 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f4a:	9f4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f4e:	00001697          	auipc	a3,0x1
ffffffffc0200f52:	46a68693          	addi	a3,a3,1130 # ffffffffc02023b8 <commands+0x7a0>
ffffffffc0200f56:	00001617          	auipc	a2,0x1
ffffffffc0200f5a:	41260613          	addi	a2,a2,1042 # ffffffffc0202368 <commands+0x750>
ffffffffc0200f5e:	0f300593          	li	a1,243
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	41e50513          	addi	a0,a0,1054 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f6a:	9d4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 3);
ffffffffc0200f6e:	00001697          	auipc	a3,0x1
ffffffffc0200f72:	58a68693          	addi	a3,a3,1418 # ffffffffc02024f8 <commands+0x8e0>
ffffffffc0200f76:	00001617          	auipc	a2,0x1
ffffffffc0200f7a:	3f260613          	addi	a2,a2,1010 # ffffffffc0202368 <commands+0x750>
ffffffffc0200f7e:	0f100593          	li	a1,241
ffffffffc0200f82:	00001517          	auipc	a0,0x1
ffffffffc0200f86:	3fe50513          	addi	a0,a0,1022 # ffffffffc0202380 <commands+0x768>
ffffffffc0200f8a:	9b4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f8e:	00001697          	auipc	a3,0x1
ffffffffc0200f92:	55268693          	addi	a3,a3,1362 # ffffffffc02024e0 <commands+0x8c8>
ffffffffc0200f96:	00001617          	auipc	a2,0x1
ffffffffc0200f9a:	3d260613          	addi	a2,a2,978 # ffffffffc0202368 <commands+0x750>
ffffffffc0200f9e:	0ec00593          	li	a1,236
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	3de50513          	addi	a0,a0,990 # ffffffffc0202380 <commands+0x768>
ffffffffc0200faa:	994ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fae:	00001697          	auipc	a3,0x1
ffffffffc0200fb2:	51268693          	addi	a3,a3,1298 # ffffffffc02024c0 <commands+0x8a8>
ffffffffc0200fb6:	00001617          	auipc	a2,0x1
ffffffffc0200fba:	3b260613          	addi	a2,a2,946 # ffffffffc0202368 <commands+0x750>
ffffffffc0200fbe:	0e300593          	li	a1,227
ffffffffc0200fc2:	00001517          	auipc	a0,0x1
ffffffffc0200fc6:	3be50513          	addi	a0,a0,958 # ffffffffc0202380 <commands+0x768>
ffffffffc0200fca:	974ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fce:	00001697          	auipc	a3,0x1
ffffffffc0200fd2:	4d268693          	addi	a3,a3,1234 # ffffffffc02024a0 <commands+0x888>
ffffffffc0200fd6:	00001617          	auipc	a2,0x1
ffffffffc0200fda:	39260613          	addi	a2,a2,914 # ffffffffc0202368 <commands+0x750>
ffffffffc0200fde:	0e200593          	li	a1,226
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	39e50513          	addi	a0,a0,926 # ffffffffc0202380 <commands+0x768>
ffffffffc0200fea:	954ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(count == 0);
ffffffffc0200fee:	00001697          	auipc	a3,0x1
ffffffffc0200ff2:	63a68693          	addi	a3,a3,1594 # ffffffffc0202628 <commands+0xa10>
ffffffffc0200ff6:	00001617          	auipc	a2,0x1
ffffffffc0200ffa:	37260613          	addi	a2,a2,882 # ffffffffc0202368 <commands+0x750>
ffffffffc0200ffe:	15300593          	li	a1,339
ffffffffc0201002:	00001517          	auipc	a0,0x1
ffffffffc0201006:	37e50513          	addi	a0,a0,894 # ffffffffc0202380 <commands+0x768>
ffffffffc020100a:	934ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc020100e:	00001697          	auipc	a3,0x1
ffffffffc0201012:	53268693          	addi	a3,a3,1330 # ffffffffc0202540 <commands+0x928>
ffffffffc0201016:	00001617          	auipc	a2,0x1
ffffffffc020101a:	35260613          	addi	a2,a2,850 # ffffffffc0202368 <commands+0x750>
ffffffffc020101e:	14800593          	li	a1,328
ffffffffc0201022:	00001517          	auipc	a0,0x1
ffffffffc0201026:	35e50513          	addi	a0,a0,862 # ffffffffc0202380 <commands+0x768>
ffffffffc020102a:	914ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020102e:	00001697          	auipc	a3,0x1
ffffffffc0201032:	4b268693          	addi	a3,a3,1202 # ffffffffc02024e0 <commands+0x8c8>
ffffffffc0201036:	00001617          	auipc	a2,0x1
ffffffffc020103a:	33260613          	addi	a2,a2,818 # ffffffffc0202368 <commands+0x750>
ffffffffc020103e:	14200593          	li	a1,322
ffffffffc0201042:	00001517          	auipc	a0,0x1
ffffffffc0201046:	33e50513          	addi	a0,a0,830 # ffffffffc0202380 <commands+0x768>
ffffffffc020104a:	8f4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020104e:	00001697          	auipc	a3,0x1
ffffffffc0201052:	5ba68693          	addi	a3,a3,1466 # ffffffffc0202608 <commands+0x9f0>
ffffffffc0201056:	00001617          	auipc	a2,0x1
ffffffffc020105a:	31260613          	addi	a2,a2,786 # ffffffffc0202368 <commands+0x750>
ffffffffc020105e:	14100593          	li	a1,321
ffffffffc0201062:	00001517          	auipc	a0,0x1
ffffffffc0201066:	31e50513          	addi	a0,a0,798 # ffffffffc0202380 <commands+0x768>
ffffffffc020106a:	8d4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 + 4 == p1);
ffffffffc020106e:	00001697          	auipc	a3,0x1
ffffffffc0201072:	58a68693          	addi	a3,a3,1418 # ffffffffc02025f8 <commands+0x9e0>
ffffffffc0201076:	00001617          	auipc	a2,0x1
ffffffffc020107a:	2f260613          	addi	a2,a2,754 # ffffffffc0202368 <commands+0x750>
ffffffffc020107e:	13900593          	li	a1,313
ffffffffc0201082:	00001517          	auipc	a0,0x1
ffffffffc0201086:	2fe50513          	addi	a0,a0,766 # ffffffffc0202380 <commands+0x768>
ffffffffc020108a:	8b4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020108e:	00001697          	auipc	a3,0x1
ffffffffc0201092:	55268693          	addi	a3,a3,1362 # ffffffffc02025e0 <commands+0x9c8>
ffffffffc0201096:	00001617          	auipc	a2,0x1
ffffffffc020109a:	2d260613          	addi	a2,a2,722 # ffffffffc0202368 <commands+0x750>
ffffffffc020109e:	13800593          	li	a1,312
ffffffffc02010a2:	00001517          	auipc	a0,0x1
ffffffffc02010a6:	2de50513          	addi	a0,a0,734 # ffffffffc0202380 <commands+0x768>
ffffffffc02010aa:	894ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02010ae:	00001697          	auipc	a3,0x1
ffffffffc02010b2:	51268693          	addi	a3,a3,1298 # ffffffffc02025c0 <commands+0x9a8>
ffffffffc02010b6:	00001617          	auipc	a2,0x1
ffffffffc02010ba:	2b260613          	addi	a2,a2,690 # ffffffffc0202368 <commands+0x750>
ffffffffc02010be:	13700593          	li	a1,311
ffffffffc02010c2:	00001517          	auipc	a0,0x1
ffffffffc02010c6:	2be50513          	addi	a0,a0,702 # ffffffffc0202380 <commands+0x768>
ffffffffc02010ca:	874ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02010ce:	00001697          	auipc	a3,0x1
ffffffffc02010d2:	4c268693          	addi	a3,a3,1218 # ffffffffc0202590 <commands+0x978>
ffffffffc02010d6:	00001617          	auipc	a2,0x1
ffffffffc02010da:	29260613          	addi	a2,a2,658 # ffffffffc0202368 <commands+0x750>
ffffffffc02010de:	13500593          	li	a1,309
ffffffffc02010e2:	00001517          	auipc	a0,0x1
ffffffffc02010e6:	29e50513          	addi	a0,a0,670 # ffffffffc0202380 <commands+0x768>
ffffffffc02010ea:	854ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02010ee:	00001697          	auipc	a3,0x1
ffffffffc02010f2:	48a68693          	addi	a3,a3,1162 # ffffffffc0202578 <commands+0x960>
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	27260613          	addi	a2,a2,626 # ffffffffc0202368 <commands+0x750>
ffffffffc02010fe:	13400593          	li	a1,308
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	27e50513          	addi	a0,a0,638 # ffffffffc0202380 <commands+0x768>
ffffffffc020110a:	834ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020110e:	00001697          	auipc	a3,0x1
ffffffffc0201112:	3d268693          	addi	a3,a3,978 # ffffffffc02024e0 <commands+0x8c8>
ffffffffc0201116:	00001617          	auipc	a2,0x1
ffffffffc020111a:	25260613          	addi	a2,a2,594 # ffffffffc0202368 <commands+0x750>
ffffffffc020111e:	12800593          	li	a1,296
ffffffffc0201122:	00001517          	auipc	a0,0x1
ffffffffc0201126:	25e50513          	addi	a0,a0,606 # ffffffffc0202380 <commands+0x768>
ffffffffc020112a:	814ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p0));
ffffffffc020112e:	00001697          	auipc	a3,0x1
ffffffffc0201132:	43268693          	addi	a3,a3,1074 # ffffffffc0202560 <commands+0x948>
ffffffffc0201136:	00001617          	auipc	a2,0x1
ffffffffc020113a:	23260613          	addi	a2,a2,562 # ffffffffc0202368 <commands+0x750>
ffffffffc020113e:	11f00593          	li	a1,287
ffffffffc0201142:	00001517          	auipc	a0,0x1
ffffffffc0201146:	23e50513          	addi	a0,a0,574 # ffffffffc0202380 <commands+0x768>
ffffffffc020114a:	ff5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != NULL);
ffffffffc020114e:	00001697          	auipc	a3,0x1
ffffffffc0201152:	40268693          	addi	a3,a3,1026 # ffffffffc0202550 <commands+0x938>
ffffffffc0201156:	00001617          	auipc	a2,0x1
ffffffffc020115a:	21260613          	addi	a2,a2,530 # ffffffffc0202368 <commands+0x750>
ffffffffc020115e:	11e00593          	li	a1,286
ffffffffc0201162:	00001517          	auipc	a0,0x1
ffffffffc0201166:	21e50513          	addi	a0,a0,542 # ffffffffc0202380 <commands+0x768>
ffffffffc020116a:	fd5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(nr_free == 0);
ffffffffc020116e:	00001697          	auipc	a3,0x1
ffffffffc0201172:	3d268693          	addi	a3,a3,978 # ffffffffc0202540 <commands+0x928>
ffffffffc0201176:	00001617          	auipc	a2,0x1
ffffffffc020117a:	1f260613          	addi	a2,a2,498 # ffffffffc0202368 <commands+0x750>
ffffffffc020117e:	10000593          	li	a1,256
ffffffffc0201182:	00001517          	auipc	a0,0x1
ffffffffc0201186:	1fe50513          	addi	a0,a0,510 # ffffffffc0202380 <commands+0x768>
ffffffffc020118a:	fb5fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020118e:	00001697          	auipc	a3,0x1
ffffffffc0201192:	35268693          	addi	a3,a3,850 # ffffffffc02024e0 <commands+0x8c8>
ffffffffc0201196:	00001617          	auipc	a2,0x1
ffffffffc020119a:	1d260613          	addi	a2,a2,466 # ffffffffc0202368 <commands+0x750>
ffffffffc020119e:	0fe00593          	li	a1,254
ffffffffc02011a2:	00001517          	auipc	a0,0x1
ffffffffc02011a6:	1de50513          	addi	a0,a0,478 # ffffffffc0202380 <commands+0x768>
ffffffffc02011aa:	f95fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02011ae:	00001697          	auipc	a3,0x1
ffffffffc02011b2:	37268693          	addi	a3,a3,882 # ffffffffc0202520 <commands+0x908>
ffffffffc02011b6:	00001617          	auipc	a2,0x1
ffffffffc02011ba:	1b260613          	addi	a2,a2,434 # ffffffffc0202368 <commands+0x750>
ffffffffc02011be:	0fd00593          	li	a1,253
ffffffffc02011c2:	00001517          	auipc	a0,0x1
ffffffffc02011c6:	1be50513          	addi	a0,a0,446 # ffffffffc0202380 <commands+0x768>
ffffffffc02011ca:	f75fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02011ce <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02011ce:	1141                	addi	sp,sp,-16
ffffffffc02011d0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011d2:	18058063          	beqz	a1,ffffffffc0201352 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02011d6:	00259693          	slli	a3,a1,0x2
ffffffffc02011da:	96ae                	add	a3,a3,a1
ffffffffc02011dc:	068e                	slli	a3,a3,0x3
ffffffffc02011de:	96aa                	add	a3,a3,a0
ffffffffc02011e0:	02d50d63          	beq	a0,a3,ffffffffc020121a <best_fit_free_pages+0x4c>
ffffffffc02011e4:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02011e6:	8b85                	andi	a5,a5,1
ffffffffc02011e8:	14079563          	bnez	a5,ffffffffc0201332 <best_fit_free_pages+0x164>
ffffffffc02011ec:	651c                	ld	a5,8(a0)
ffffffffc02011ee:	8385                	srli	a5,a5,0x1
ffffffffc02011f0:	8b85                	andi	a5,a5,1
ffffffffc02011f2:	14079063          	bnez	a5,ffffffffc0201332 <best_fit_free_pages+0x164>
ffffffffc02011f6:	87aa                	mv	a5,a0
ffffffffc02011f8:	a809                	j	ffffffffc020120a <best_fit_free_pages+0x3c>
ffffffffc02011fa:	6798                	ld	a4,8(a5)
ffffffffc02011fc:	8b05                	andi	a4,a4,1
ffffffffc02011fe:	12071a63          	bnez	a4,ffffffffc0201332 <best_fit_free_pages+0x164>
ffffffffc0201202:	6798                	ld	a4,8(a5)
ffffffffc0201204:	8b09                	andi	a4,a4,2
ffffffffc0201206:	12071663          	bnez	a4,ffffffffc0201332 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc020120a:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020120e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201212:	02878793          	addi	a5,a5,40
ffffffffc0201216:	fed792e3          	bne	a5,a3,ffffffffc02011fa <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc020121a:	2581                	sext.w	a1,a1
ffffffffc020121c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020121e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201222:	4789                	li	a5,2
ffffffffc0201224:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201228:	00005697          	auipc	a3,0x5
ffffffffc020122c:	21068693          	addi	a3,a3,528 # ffffffffc0206438 <free_area>
ffffffffc0201230:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201232:	669c                	ld	a5,8(a3)
ffffffffc0201234:	9db9                	addw	a1,a1,a4
ffffffffc0201236:	00005717          	auipc	a4,0x5
ffffffffc020123a:	20b72923          	sw	a1,530(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020123e:	08d78f63          	beq	a5,a3,ffffffffc02012dc <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201242:	fe878713          	addi	a4,a5,-24
ffffffffc0201246:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201248:	4801                	li	a6,0
ffffffffc020124a:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020124e:	00e56a63          	bltu	a0,a4,ffffffffc0201262 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201252:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {// 到达链表末尾
ffffffffc0201254:	02d70563          	beq	a4,a3,ffffffffc020127e <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201258:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020125a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020125e:	fee57ae3          	bleu	a4,a0,ffffffffc0201252 <best_fit_free_pages+0x84>
ffffffffc0201262:	00080663          	beqz	a6,ffffffffc020126e <best_fit_free_pages+0xa0>
ffffffffc0201266:	00005817          	auipc	a6,0x5
ffffffffc020126a:	1cb83923          	sd	a1,466(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020126e:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201270:	e390                	sd	a2,0(a5)
ffffffffc0201272:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201274:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201276:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201278:	02d59163          	bne	a1,a3,ffffffffc020129a <best_fit_free_pages+0xcc>
ffffffffc020127c:	a091                	j	ffffffffc02012c0 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc020127e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201280:	f114                	sd	a3,32(a0)
ffffffffc0201282:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201284:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201286:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201288:	00d70563          	beq	a4,a3,ffffffffc0201292 <best_fit_free_pages+0xc4>
ffffffffc020128c:	4805                	li	a6,1
ffffffffc020128e:	87ba                	mv	a5,a4
ffffffffc0201290:	b7e9                	j	ffffffffc020125a <best_fit_free_pages+0x8c>
ffffffffc0201292:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201294:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201296:	02d78163          	beq	a5,a3,ffffffffc02012b8 <best_fit_free_pages+0xea>
        if (p + p->property == base) {// 前面的空闲块与当前块连续
ffffffffc020129a:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc020129e:	fe858613          	addi	a2,a1,-24
        if (p + p->property == base) {// 前面的空闲块与当前块连续
ffffffffc02012a2:	02081713          	slli	a4,a6,0x20
ffffffffc02012a6:	9301                	srli	a4,a4,0x20
ffffffffc02012a8:	00271793          	slli	a5,a4,0x2
ffffffffc02012ac:	97ba                	add	a5,a5,a4
ffffffffc02012ae:	078e                	slli	a5,a5,0x3
ffffffffc02012b0:	97b2                	add	a5,a5,a2
ffffffffc02012b2:	02f50e63          	beq	a0,a5,ffffffffc02012ee <best_fit_free_pages+0x120>
ffffffffc02012b6:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02012b8:	fe878713          	addi	a4,a5,-24
ffffffffc02012bc:	00d78d63          	beq	a5,a3,ffffffffc02012d6 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02012c0:	490c                	lw	a1,16(a0)
ffffffffc02012c2:	02059613          	slli	a2,a1,0x20
ffffffffc02012c6:	9201                	srli	a2,a2,0x20
ffffffffc02012c8:	00261693          	slli	a3,a2,0x2
ffffffffc02012cc:	96b2                	add	a3,a3,a2
ffffffffc02012ce:	068e                	slli	a3,a3,0x3
ffffffffc02012d0:	96aa                	add	a3,a3,a0
ffffffffc02012d2:	04d70063          	beq	a4,a3,ffffffffc0201312 <best_fit_free_pages+0x144>
}
ffffffffc02012d6:	60a2                	ld	ra,8(sp)
ffffffffc02012d8:	0141                	addi	sp,sp,16
ffffffffc02012da:	8082                	ret
ffffffffc02012dc:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02012de:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02012e2:	e398                	sd	a4,0(a5)
ffffffffc02012e4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02012e6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02012e8:	ed1c                	sd	a5,24(a0)
}
ffffffffc02012ea:	0141                	addi	sp,sp,16
ffffffffc02012ec:	8082                	ret
            p->property += base->property;// 合并大小
ffffffffc02012ee:	491c                	lw	a5,16(a0)
ffffffffc02012f0:	0107883b          	addw	a6,a5,a6
ffffffffc02012f4:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02012f8:	57f5                	li	a5,-3
ffffffffc02012fa:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02012fe:	01853803          	ld	a6,24(a0)
ffffffffc0201302:	7118                	ld	a4,32(a0)
            base = p;// 更新base指向合并后的页面
ffffffffc0201304:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201306:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020130a:	659c                	ld	a5,8(a1)
ffffffffc020130c:	01073023          	sd	a6,0(a4)
ffffffffc0201310:	b765                	j	ffffffffc02012b8 <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201312:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201316:	ff078693          	addi	a3,a5,-16
ffffffffc020131a:	9db9                	addw	a1,a1,a4
ffffffffc020131c:	c90c                	sw	a1,16(a0)
ffffffffc020131e:	5775                	li	a4,-3
ffffffffc0201320:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201324:	6398                	ld	a4,0(a5)
ffffffffc0201326:	679c                	ld	a5,8(a5)
}
ffffffffc0201328:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020132a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020132c:	e398                	sd	a4,0(a5)
ffffffffc020132e:	0141                	addi	sp,sp,16
ffffffffc0201330:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201332:	00001697          	auipc	a3,0x1
ffffffffc0201336:	31668693          	addi	a3,a3,790 # ffffffffc0202648 <commands+0xa30>
ffffffffc020133a:	00001617          	auipc	a2,0x1
ffffffffc020133e:	02e60613          	addi	a2,a2,46 # ffffffffc0202368 <commands+0x750>
ffffffffc0201342:	09600593          	li	a1,150
ffffffffc0201346:	00001517          	auipc	a0,0x1
ffffffffc020134a:	03a50513          	addi	a0,a0,58 # ffffffffc0202380 <commands+0x768>
ffffffffc020134e:	df1fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc0201352:	00001697          	auipc	a3,0x1
ffffffffc0201356:	31e68693          	addi	a3,a3,798 # ffffffffc0202670 <commands+0xa58>
ffffffffc020135a:	00001617          	auipc	a2,0x1
ffffffffc020135e:	00e60613          	addi	a2,a2,14 # ffffffffc0202368 <commands+0x750>
ffffffffc0201362:	09200593          	li	a1,146
ffffffffc0201366:	00001517          	auipc	a0,0x1
ffffffffc020136a:	01a50513          	addi	a0,a0,26 # ffffffffc0202380 <commands+0x768>
ffffffffc020136e:	dd1fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201372 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201372:	c555                	beqz	a0,ffffffffc020141e <best_fit_alloc_pages+0xac>
    if (n > nr_free) {
ffffffffc0201374:	00005597          	auipc	a1,0x5
ffffffffc0201378:	0c458593          	addi	a1,a1,196 # ffffffffc0206438 <free_area>
ffffffffc020137c:	0105a883          	lw	a7,16(a1)
ffffffffc0201380:	02089793          	slli	a5,a7,0x20
ffffffffc0201384:	9381                	srli	a5,a5,0x20
ffffffffc0201386:	08a7e963          	bltu	a5,a0,ffffffffc0201418 <best_fit_alloc_pages+0xa6>
    list_entry_t *le = &free_list;
ffffffffc020138a:	87ae                	mv	a5,a1
    struct Page *page = NULL;
ffffffffc020138c:	4681                	li	a3,0
    return listelm->next;
ffffffffc020138e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201390:	02b78363          	beq	a5,a1,ffffffffc02013b6 <best_fit_alloc_pages+0x44>
        if (p->property >= n) {
ffffffffc0201394:	ff87a703          	lw	a4,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201398:	fe878813          	addi	a6,a5,-24
        if (p->property >= n) {
ffffffffc020139c:	02071613          	slli	a2,a4,0x20
ffffffffc02013a0:	9201                	srli	a2,a2,0x20
ffffffffc02013a2:	fea666e3          	bltu	a2,a0,ffffffffc020138e <best_fit_alloc_pages+0x1c>
            if(page == NULL || page->property > p->property)
ffffffffc02013a6:	c681                	beqz	a3,ffffffffc02013ae <best_fit_alloc_pages+0x3c>
ffffffffc02013a8:	4a90                	lw	a2,16(a3)
ffffffffc02013aa:	fec772e3          	bleu	a2,a4,ffffffffc020138e <best_fit_alloc_pages+0x1c>
ffffffffc02013ae:	679c                	ld	a5,8(a5)
                page = p;
ffffffffc02013b0:	86c2                	mv	a3,a6
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013b2:	feb791e3          	bne	a5,a1,ffffffffc0201394 <best_fit_alloc_pages+0x22>
    if (page != NULL) {
ffffffffc02013b6:	ca85                	beqz	a3,ffffffffc02013e6 <best_fit_alloc_pages+0x74>
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b8:	7298                	ld	a4,32(a3)
    return listelm->prev;
ffffffffc02013ba:	6e90                	ld	a2,24(a3)
        if (page->property > n) {
ffffffffc02013bc:	4a8c                	lw	a1,16(a3)
ffffffffc02013be:	0005081b          	sext.w	a6,a0
    prev->next = next;
ffffffffc02013c2:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02013c4:	e310                	sd	a2,0(a4)
ffffffffc02013c6:	02059713          	slli	a4,a1,0x20
ffffffffc02013ca:	9301                	srli	a4,a4,0x20
ffffffffc02013cc:	00e56f63          	bltu	a0,a4,ffffffffc02013ea <best_fit_alloc_pages+0x78>
        nr_free -= n;
ffffffffc02013d0:	410888bb          	subw	a7,a7,a6
ffffffffc02013d4:	00005797          	auipc	a5,0x5
ffffffffc02013d8:	0717aa23          	sw	a7,116(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc02013dc:	57f5                	li	a5,-3
ffffffffc02013de:	00868713          	addi	a4,a3,8
ffffffffc02013e2:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02013e6:	8536                	mv	a0,a3
ffffffffc02013e8:	8082                	ret
            struct Page *p = page + n;
ffffffffc02013ea:	00251713          	slli	a4,a0,0x2
ffffffffc02013ee:	972a                	add	a4,a4,a0
ffffffffc02013f0:	070e                	slli	a4,a4,0x3
ffffffffc02013f2:	9736                	add	a4,a4,a3
            p->property = page->property - n;
ffffffffc02013f4:	410585bb          	subw	a1,a1,a6
ffffffffc02013f8:	cb0c                	sw	a1,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013fa:	00870513          	addi	a0,a4,8
ffffffffc02013fe:	4589                	li	a1,2
ffffffffc0201400:	40b5302f          	amoor.d	zero,a1,(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201404:	660c                	ld	a1,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0201406:	01870513          	addi	a0,a4,24
    prev->next = next->prev = elm;
ffffffffc020140a:	0107a883          	lw	a7,16(a5)
ffffffffc020140e:	e188                	sd	a0,0(a1)
ffffffffc0201410:	e608                	sd	a0,8(a2)
    elm->next = next;
ffffffffc0201412:	f30c                	sd	a1,32(a4)
    elm->prev = prev;
ffffffffc0201414:	ef10                	sd	a2,24(a4)
ffffffffc0201416:	bf6d                	j	ffffffffc02013d0 <best_fit_alloc_pages+0x5e>
        return NULL;
ffffffffc0201418:	4681                	li	a3,0
}
ffffffffc020141a:	8536                	mv	a0,a3
ffffffffc020141c:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc020141e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201420:	00001697          	auipc	a3,0x1
ffffffffc0201424:	25068693          	addi	a3,a3,592 # ffffffffc0202670 <commands+0xa58>
ffffffffc0201428:	00001617          	auipc	a2,0x1
ffffffffc020142c:	f4060613          	addi	a2,a2,-192 # ffffffffc0202368 <commands+0x750>
ffffffffc0201430:	06b00593          	li	a1,107
ffffffffc0201434:	00001517          	auipc	a0,0x1
ffffffffc0201438:	f4c50513          	addi	a0,a0,-180 # ffffffffc0202380 <commands+0x768>
best_fit_alloc_pages(size_t n) {
ffffffffc020143c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020143e:	d01fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0201442 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201442:	1141                	addi	sp,sp,-16
ffffffffc0201444:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201446:	c1fd                	beqz	a1,ffffffffc020152c <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0201448:	00259693          	slli	a3,a1,0x2
ffffffffc020144c:	96ae                	add	a3,a3,a1
ffffffffc020144e:	068e                	slli	a3,a3,0x3
ffffffffc0201450:	96aa                	add	a3,a3,a0
ffffffffc0201452:	02d50463          	beq	a0,a3,ffffffffc020147a <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201456:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201458:	87aa                	mv	a5,a0
ffffffffc020145a:	8b05                	andi	a4,a4,1
ffffffffc020145c:	e709                	bnez	a4,ffffffffc0201466 <best_fit_init_memmap+0x24>
ffffffffc020145e:	a07d                	j	ffffffffc020150c <best_fit_init_memmap+0xca>
ffffffffc0201460:	6798                	ld	a4,8(a5)
ffffffffc0201462:	8b05                	andi	a4,a4,1
ffffffffc0201464:	c745                	beqz	a4,ffffffffc020150c <best_fit_init_memmap+0xca>
        p->flags = p->property = 0; //将标志和属性初始化
ffffffffc0201466:	0007a823          	sw	zero,16(a5)
ffffffffc020146a:	0007b423          	sd	zero,8(a5)
ffffffffc020146e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201472:	02878793          	addi	a5,a5,40
ffffffffc0201476:	fed795e3          	bne	a5,a3,ffffffffc0201460 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc020147a:	2581                	sext.w	a1,a1
ffffffffc020147c:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020147e:	4789                	li	a5,2
ffffffffc0201480:	00850713          	addi	a4,a0,8
ffffffffc0201484:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201488:	00005697          	auipc	a3,0x5
ffffffffc020148c:	fb068693          	addi	a3,a3,-80 # ffffffffc0206438 <free_area>
ffffffffc0201490:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201492:	669c                	ld	a5,8(a3)
ffffffffc0201494:	9db9                	addw	a1,a1,a4
ffffffffc0201496:	00005717          	auipc	a4,0x5
ffffffffc020149a:	fab72923          	sw	a1,-78(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020149e:	04d78a63          	beq	a5,a3,ffffffffc02014f2 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02014a2:	fe878713          	addi	a4,a5,-24
ffffffffc02014a6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014a8:	4801                	li	a6,0
ffffffffc02014aa:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02014ae:	00e56a63          	bltu	a0,a4,ffffffffc02014c2 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc02014b2:	6798                	ld	a4,8(a5)
            if (list_next(le) == &free_list) {
ffffffffc02014b4:	02d70563          	beq	a4,a3,ffffffffc02014de <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014b8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02014ba:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02014be:	fee57ae3          	bleu	a4,a0,ffffffffc02014b2 <best_fit_init_memmap+0x70>
ffffffffc02014c2:	00080663          	beqz	a6,ffffffffc02014ce <best_fit_init_memmap+0x8c>
ffffffffc02014c6:	00005717          	auipc	a4,0x5
ffffffffc02014ca:	f6b73923          	sd	a1,-142(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02014ce:	6398                	ld	a4,0(a5)
}
ffffffffc02014d0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02014d2:	e390                	sd	a2,0(a5)
ffffffffc02014d4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02014d6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014d8:	ed18                	sd	a4,24(a0)
ffffffffc02014da:	0141                	addi	sp,sp,16
ffffffffc02014dc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02014de:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02014e0:	f114                	sd	a3,32(a0)
ffffffffc02014e2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02014e4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02014e6:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02014e8:	00d70e63          	beq	a4,a3,ffffffffc0201504 <best_fit_init_memmap+0xc2>
ffffffffc02014ec:	4805                	li	a6,1
ffffffffc02014ee:	87ba                	mv	a5,a4
ffffffffc02014f0:	b7e9                	j	ffffffffc02014ba <best_fit_init_memmap+0x78>
}
ffffffffc02014f2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02014f4:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02014f8:	e398                	sd	a4,0(a5)
ffffffffc02014fa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014fc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014fe:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201500:	0141                	addi	sp,sp,16
ffffffffc0201502:	8082                	ret
ffffffffc0201504:	60a2                	ld	ra,8(sp)
ffffffffc0201506:	e290                	sd	a2,0(a3)
ffffffffc0201508:	0141                	addi	sp,sp,16
ffffffffc020150a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020150c:	00001697          	auipc	a3,0x1
ffffffffc0201510:	16c68693          	addi	a3,a3,364 # ffffffffc0202678 <commands+0xa60>
ffffffffc0201514:	00001617          	auipc	a2,0x1
ffffffffc0201518:	e5460613          	addi	a2,a2,-428 # ffffffffc0202368 <commands+0x750>
ffffffffc020151c:	04a00593          	li	a1,74
ffffffffc0201520:	00001517          	auipc	a0,0x1
ffffffffc0201524:	e6050513          	addi	a0,a0,-416 # ffffffffc0202380 <commands+0x768>
ffffffffc0201528:	c17fe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc020152c:	00001697          	auipc	a3,0x1
ffffffffc0201530:	14468693          	addi	a3,a3,324 # ffffffffc0202670 <commands+0xa58>
ffffffffc0201534:	00001617          	auipc	a2,0x1
ffffffffc0201538:	e3460613          	addi	a2,a2,-460 # ffffffffc0202368 <commands+0x750>
ffffffffc020153c:	04700593          	li	a1,71
ffffffffc0201540:	00001517          	auipc	a0,0x1
ffffffffc0201544:	e4050513          	addi	a0,a0,-448 # ffffffffc0202380 <commands+0x768>
ffffffffc0201548:	bf7fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020154c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020154c:	c185                	beqz	a1,ffffffffc020156c <strnlen+0x20>
ffffffffc020154e:	00054783          	lbu	a5,0(a0)
ffffffffc0201552:	cf89                	beqz	a5,ffffffffc020156c <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201554:	4781                	li	a5,0
ffffffffc0201556:	a021                	j	ffffffffc020155e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201558:	00074703          	lbu	a4,0(a4)
ffffffffc020155c:	c711                	beqz	a4,ffffffffc0201568 <strnlen+0x1c>
        cnt ++;
ffffffffc020155e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201560:	00f50733          	add	a4,a0,a5
ffffffffc0201564:	fef59ae3          	bne	a1,a5,ffffffffc0201558 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201568:	853e                	mv	a0,a5
ffffffffc020156a:	8082                	ret
    size_t cnt = 0;
ffffffffc020156c:	4781                	li	a5,0
}
ffffffffc020156e:	853e                	mv	a0,a5
ffffffffc0201570:	8082                	ret

ffffffffc0201572 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201572:	00054783          	lbu	a5,0(a0)
ffffffffc0201576:	0005c703          	lbu	a4,0(a1)
ffffffffc020157a:	cb91                	beqz	a5,ffffffffc020158e <strcmp+0x1c>
ffffffffc020157c:	00e79c63          	bne	a5,a4,ffffffffc0201594 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201580:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201582:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201586:	0585                	addi	a1,a1,1
ffffffffc0201588:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020158c:	fbe5                	bnez	a5,ffffffffc020157c <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020158e:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201590:	9d19                	subw	a0,a0,a4
ffffffffc0201592:	8082                	ret
ffffffffc0201594:	0007851b          	sext.w	a0,a5
ffffffffc0201598:	9d19                	subw	a0,a0,a4
ffffffffc020159a:	8082                	ret

ffffffffc020159c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020159c:	00054783          	lbu	a5,0(a0)
ffffffffc02015a0:	cb91                	beqz	a5,ffffffffc02015b4 <strchr+0x18>
        if (*s == c) {
ffffffffc02015a2:	00b79563          	bne	a5,a1,ffffffffc02015ac <strchr+0x10>
ffffffffc02015a6:	a809                	j	ffffffffc02015b8 <strchr+0x1c>
ffffffffc02015a8:	00b78763          	beq	a5,a1,ffffffffc02015b6 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02015ac:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02015ae:	00054783          	lbu	a5,0(a0)
ffffffffc02015b2:	fbfd                	bnez	a5,ffffffffc02015a8 <strchr+0xc>
    }
    return NULL;
ffffffffc02015b4:	4501                	li	a0,0
}
ffffffffc02015b6:	8082                	ret
ffffffffc02015b8:	8082                	ret

ffffffffc02015ba <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02015ba:	ca01                	beqz	a2,ffffffffc02015ca <memset+0x10>
ffffffffc02015bc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02015be:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02015c0:	0785                	addi	a5,a5,1
ffffffffc02015c2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02015c6:	fec79de3          	bne	a5,a2,ffffffffc02015c0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02015ca:	8082                	ret

ffffffffc02015cc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02015cc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015d0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02015d2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015d6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02015d8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02015dc:	f022                	sd	s0,32(sp)
ffffffffc02015de:	ec26                	sd	s1,24(sp)
ffffffffc02015e0:	e84a                	sd	s2,16(sp)
ffffffffc02015e2:	f406                	sd	ra,40(sp)
ffffffffc02015e4:	e44e                	sd	s3,8(sp)
ffffffffc02015e6:	84aa                	mv	s1,a0
ffffffffc02015e8:	892e                	mv	s2,a1
ffffffffc02015ea:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02015ee:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02015f0:	03067e63          	bleu	a6,a2,ffffffffc020162c <printnum+0x60>
ffffffffc02015f4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02015f6:	00805763          	blez	s0,ffffffffc0201604 <printnum+0x38>
ffffffffc02015fa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02015fc:	85ca                	mv	a1,s2
ffffffffc02015fe:	854e                	mv	a0,s3
ffffffffc0201600:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201602:	fc65                	bnez	s0,ffffffffc02015fa <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201604:	1a02                	slli	s4,s4,0x20
ffffffffc0201606:	020a5a13          	srli	s4,s4,0x20
ffffffffc020160a:	00001797          	auipc	a5,0x1
ffffffffc020160e:	25e78793          	addi	a5,a5,606 # ffffffffc0202868 <error_string+0x38>
ffffffffc0201612:	9a3e                	add	s4,s4,a5
}
ffffffffc0201614:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201616:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020161a:	70a2                	ld	ra,40(sp)
ffffffffc020161c:	69a2                	ld	s3,8(sp)
ffffffffc020161e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201620:	85ca                	mv	a1,s2
ffffffffc0201622:	8326                	mv	t1,s1
}
ffffffffc0201624:	6942                	ld	s2,16(sp)
ffffffffc0201626:	64e2                	ld	s1,24(sp)
ffffffffc0201628:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020162a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020162c:	03065633          	divu	a2,a2,a6
ffffffffc0201630:	8722                	mv	a4,s0
ffffffffc0201632:	f9bff0ef          	jal	ra,ffffffffc02015cc <printnum>
ffffffffc0201636:	b7f9                	j	ffffffffc0201604 <printnum+0x38>

ffffffffc0201638 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201638:	7119                	addi	sp,sp,-128
ffffffffc020163a:	f4a6                	sd	s1,104(sp)
ffffffffc020163c:	f0ca                	sd	s2,96(sp)
ffffffffc020163e:	e8d2                	sd	s4,80(sp)
ffffffffc0201640:	e4d6                	sd	s5,72(sp)
ffffffffc0201642:	e0da                	sd	s6,64(sp)
ffffffffc0201644:	fc5e                	sd	s7,56(sp)
ffffffffc0201646:	f862                	sd	s8,48(sp)
ffffffffc0201648:	f06a                	sd	s10,32(sp)
ffffffffc020164a:	fc86                	sd	ra,120(sp)
ffffffffc020164c:	f8a2                	sd	s0,112(sp)
ffffffffc020164e:	ecce                	sd	s3,88(sp)
ffffffffc0201650:	f466                	sd	s9,40(sp)
ffffffffc0201652:	ec6e                	sd	s11,24(sp)
ffffffffc0201654:	892a                	mv	s2,a0
ffffffffc0201656:	84ae                	mv	s1,a1
ffffffffc0201658:	8d32                	mv	s10,a2
ffffffffc020165a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020165c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020165e:	00001a17          	auipc	s4,0x1
ffffffffc0201662:	07aa0a13          	addi	s4,s4,122 # ffffffffc02026d8 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201666:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020166a:	00001c17          	auipc	s8,0x1
ffffffffc020166e:	1c6c0c13          	addi	s8,s8,454 # ffffffffc0202830 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201672:	000d4503          	lbu	a0,0(s10)
ffffffffc0201676:	02500793          	li	a5,37
ffffffffc020167a:	001d0413          	addi	s0,s10,1
ffffffffc020167e:	00f50e63          	beq	a0,a5,ffffffffc020169a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201682:	c521                	beqz	a0,ffffffffc02016ca <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201684:	02500993          	li	s3,37
ffffffffc0201688:	a011                	j	ffffffffc020168c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020168a:	c121                	beqz	a0,ffffffffc02016ca <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020168c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020168e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201690:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201692:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201696:	ff351ae3          	bne	a0,s3,ffffffffc020168a <vprintfmt+0x52>
ffffffffc020169a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020169e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016a2:	4981                	li	s3,0
ffffffffc02016a4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02016a6:	5cfd                	li	s9,-1
ffffffffc02016a8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016aa:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02016ae:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02016b4:	0ff6f693          	andi	a3,a3,255
ffffffffc02016b8:	00140d13          	addi	s10,s0,1
ffffffffc02016bc:	20d5e563          	bltu	a1,a3,ffffffffc02018c6 <vprintfmt+0x28e>
ffffffffc02016c0:	068a                	slli	a3,a3,0x2
ffffffffc02016c2:	96d2                	add	a3,a3,s4
ffffffffc02016c4:	4294                	lw	a3,0(a3)
ffffffffc02016c6:	96d2                	add	a3,a3,s4
ffffffffc02016c8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02016ca:	70e6                	ld	ra,120(sp)
ffffffffc02016cc:	7446                	ld	s0,112(sp)
ffffffffc02016ce:	74a6                	ld	s1,104(sp)
ffffffffc02016d0:	7906                	ld	s2,96(sp)
ffffffffc02016d2:	69e6                	ld	s3,88(sp)
ffffffffc02016d4:	6a46                	ld	s4,80(sp)
ffffffffc02016d6:	6aa6                	ld	s5,72(sp)
ffffffffc02016d8:	6b06                	ld	s6,64(sp)
ffffffffc02016da:	7be2                	ld	s7,56(sp)
ffffffffc02016dc:	7c42                	ld	s8,48(sp)
ffffffffc02016de:	7ca2                	ld	s9,40(sp)
ffffffffc02016e0:	7d02                	ld	s10,32(sp)
ffffffffc02016e2:	6de2                	ld	s11,24(sp)
ffffffffc02016e4:	6109                	addi	sp,sp,128
ffffffffc02016e6:	8082                	ret
    if (lflag >= 2) {
ffffffffc02016e8:	4705                	li	a4,1
ffffffffc02016ea:	008a8593          	addi	a1,s5,8
ffffffffc02016ee:	01074463          	blt	a4,a6,ffffffffc02016f6 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02016f2:	26080363          	beqz	a6,ffffffffc0201958 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02016f6:	000ab603          	ld	a2,0(s5)
ffffffffc02016fa:	46c1                	li	a3,16
ffffffffc02016fc:	8aae                	mv	s5,a1
ffffffffc02016fe:	a06d                	j	ffffffffc02017a8 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201700:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201704:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201706:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201708:	b765                	j	ffffffffc02016b0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020170a:	000aa503          	lw	a0,0(s5)
ffffffffc020170e:	85a6                	mv	a1,s1
ffffffffc0201710:	0aa1                	addi	s5,s5,8
ffffffffc0201712:	9902                	jalr	s2
            break;
ffffffffc0201714:	bfb9                	j	ffffffffc0201672 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201716:	4705                	li	a4,1
ffffffffc0201718:	008a8993          	addi	s3,s5,8
ffffffffc020171c:	01074463          	blt	a4,a6,ffffffffc0201724 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201720:	22080463          	beqz	a6,ffffffffc0201948 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201724:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201728:	24044463          	bltz	s0,ffffffffc0201970 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020172c:	8622                	mv	a2,s0
ffffffffc020172e:	8ace                	mv	s5,s3
ffffffffc0201730:	46a9                	li	a3,10
ffffffffc0201732:	a89d                	j	ffffffffc02017a8 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201734:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201738:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020173a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020173c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201740:	8fb5                	xor	a5,a5,a3
ffffffffc0201742:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201746:	1ad74363          	blt	a4,a3,ffffffffc02018ec <vprintfmt+0x2b4>
ffffffffc020174a:	00369793          	slli	a5,a3,0x3
ffffffffc020174e:	97e2                	add	a5,a5,s8
ffffffffc0201750:	639c                	ld	a5,0(a5)
ffffffffc0201752:	18078d63          	beqz	a5,ffffffffc02018ec <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201756:	86be                	mv	a3,a5
ffffffffc0201758:	00001617          	auipc	a2,0x1
ffffffffc020175c:	1c060613          	addi	a2,a2,448 # ffffffffc0202918 <error_string+0xe8>
ffffffffc0201760:	85a6                	mv	a1,s1
ffffffffc0201762:	854a                	mv	a0,s2
ffffffffc0201764:	240000ef          	jal	ra,ffffffffc02019a4 <printfmt>
ffffffffc0201768:	b729                	j	ffffffffc0201672 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020176a:	00144603          	lbu	a2,1(s0)
ffffffffc020176e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201770:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201772:	bf3d                	j	ffffffffc02016b0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201774:	4705                	li	a4,1
ffffffffc0201776:	008a8593          	addi	a1,s5,8
ffffffffc020177a:	01074463          	blt	a4,a6,ffffffffc0201782 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020177e:	1e080263          	beqz	a6,ffffffffc0201962 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201782:	000ab603          	ld	a2,0(s5)
ffffffffc0201786:	46a1                	li	a3,8
ffffffffc0201788:	8aae                	mv	s5,a1
ffffffffc020178a:	a839                	j	ffffffffc02017a8 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020178c:	03000513          	li	a0,48
ffffffffc0201790:	85a6                	mv	a1,s1
ffffffffc0201792:	e03e                	sd	a5,0(sp)
ffffffffc0201794:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201796:	85a6                	mv	a1,s1
ffffffffc0201798:	07800513          	li	a0,120
ffffffffc020179c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020179e:	0aa1                	addi	s5,s5,8
ffffffffc02017a0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02017a4:	6782                	ld	a5,0(sp)
ffffffffc02017a6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017a8:	876e                	mv	a4,s11
ffffffffc02017aa:	85a6                	mv	a1,s1
ffffffffc02017ac:	854a                	mv	a0,s2
ffffffffc02017ae:	e1fff0ef          	jal	ra,ffffffffc02015cc <printnum>
            break;
ffffffffc02017b2:	b5c1                	j	ffffffffc0201672 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017b4:	000ab603          	ld	a2,0(s5)
ffffffffc02017b8:	0aa1                	addi	s5,s5,8
ffffffffc02017ba:	1c060663          	beqz	a2,ffffffffc0201986 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02017be:	00160413          	addi	s0,a2,1
ffffffffc02017c2:	17b05c63          	blez	s11,ffffffffc020193a <vprintfmt+0x302>
ffffffffc02017c6:	02d00593          	li	a1,45
ffffffffc02017ca:	14b79263          	bne	a5,a1,ffffffffc020190e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017ce:	00064783          	lbu	a5,0(a2)
ffffffffc02017d2:	0007851b          	sext.w	a0,a5
ffffffffc02017d6:	c905                	beqz	a0,ffffffffc0201806 <vprintfmt+0x1ce>
ffffffffc02017d8:	000cc563          	bltz	s9,ffffffffc02017e2 <vprintfmt+0x1aa>
ffffffffc02017dc:	3cfd                	addiw	s9,s9,-1
ffffffffc02017de:	036c8263          	beq	s9,s6,ffffffffc0201802 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02017e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017e4:	18098463          	beqz	s3,ffffffffc020196c <vprintfmt+0x334>
ffffffffc02017e8:	3781                	addiw	a5,a5,-32
ffffffffc02017ea:	18fbf163          	bleu	a5,s7,ffffffffc020196c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02017ee:	03f00513          	li	a0,63
ffffffffc02017f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017f4:	0405                	addi	s0,s0,1
ffffffffc02017f6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02017fa:	3dfd                	addiw	s11,s11,-1
ffffffffc02017fc:	0007851b          	sext.w	a0,a5
ffffffffc0201800:	fd61                	bnez	a0,ffffffffc02017d8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201802:	e7b058e3          	blez	s11,ffffffffc0201672 <vprintfmt+0x3a>
ffffffffc0201806:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201808:	85a6                	mv	a1,s1
ffffffffc020180a:	02000513          	li	a0,32
ffffffffc020180e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201810:	e60d81e3          	beqz	s11,ffffffffc0201672 <vprintfmt+0x3a>
ffffffffc0201814:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201816:	85a6                	mv	a1,s1
ffffffffc0201818:	02000513          	li	a0,32
ffffffffc020181c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020181e:	fe0d94e3          	bnez	s11,ffffffffc0201806 <vprintfmt+0x1ce>
ffffffffc0201822:	bd81                	j	ffffffffc0201672 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201824:	4705                	li	a4,1
ffffffffc0201826:	008a8593          	addi	a1,s5,8
ffffffffc020182a:	01074463          	blt	a4,a6,ffffffffc0201832 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020182e:	12080063          	beqz	a6,ffffffffc020194e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201832:	000ab603          	ld	a2,0(s5)
ffffffffc0201836:	46a9                	li	a3,10
ffffffffc0201838:	8aae                	mv	s5,a1
ffffffffc020183a:	b7bd                	j	ffffffffc02017a8 <vprintfmt+0x170>
ffffffffc020183c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201840:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201844:	846a                	mv	s0,s10
ffffffffc0201846:	b5ad                	j	ffffffffc02016b0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201848:	85a6                	mv	a1,s1
ffffffffc020184a:	02500513          	li	a0,37
ffffffffc020184e:	9902                	jalr	s2
            break;
ffffffffc0201850:	b50d                	j	ffffffffc0201672 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201852:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201856:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020185a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020185c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020185e:	e40dd9e3          	bgez	s11,ffffffffc02016b0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201862:	8de6                	mv	s11,s9
ffffffffc0201864:	5cfd                	li	s9,-1
ffffffffc0201866:	b5a9                	j	ffffffffc02016b0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201868:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020186c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201870:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201872:	bd3d                	j	ffffffffc02016b0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201874:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201878:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020187c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020187e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201882:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201886:	fcd56ce3          	bltu	a0,a3,ffffffffc020185e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020188a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020188c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201890:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201894:	0196873b          	addw	a4,a3,s9
ffffffffc0201898:	0017171b          	slliw	a4,a4,0x1
ffffffffc020189c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02018a0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02018a4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02018a8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018ac:	fcd57fe3          	bleu	a3,a0,ffffffffc020188a <vprintfmt+0x252>
ffffffffc02018b0:	b77d                	j	ffffffffc020185e <vprintfmt+0x226>
            if (width < 0)
ffffffffc02018b2:	fffdc693          	not	a3,s11
ffffffffc02018b6:	96fd                	srai	a3,a3,0x3f
ffffffffc02018b8:	00ddfdb3          	and	s11,s11,a3
ffffffffc02018bc:	00144603          	lbu	a2,1(s0)
ffffffffc02018c0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018c2:	846a                	mv	s0,s10
ffffffffc02018c4:	b3f5                	j	ffffffffc02016b0 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02018c6:	85a6                	mv	a1,s1
ffffffffc02018c8:	02500513          	li	a0,37
ffffffffc02018cc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02018ce:	fff44703          	lbu	a4,-1(s0)
ffffffffc02018d2:	02500793          	li	a5,37
ffffffffc02018d6:	8d22                	mv	s10,s0
ffffffffc02018d8:	d8f70de3          	beq	a4,a5,ffffffffc0201672 <vprintfmt+0x3a>
ffffffffc02018dc:	02500713          	li	a4,37
ffffffffc02018e0:	1d7d                	addi	s10,s10,-1
ffffffffc02018e2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02018e6:	fee79de3          	bne	a5,a4,ffffffffc02018e0 <vprintfmt+0x2a8>
ffffffffc02018ea:	b361                	j	ffffffffc0201672 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02018ec:	00001617          	auipc	a2,0x1
ffffffffc02018f0:	01c60613          	addi	a2,a2,28 # ffffffffc0202908 <error_string+0xd8>
ffffffffc02018f4:	85a6                	mv	a1,s1
ffffffffc02018f6:	854a                	mv	a0,s2
ffffffffc02018f8:	0ac000ef          	jal	ra,ffffffffc02019a4 <printfmt>
ffffffffc02018fc:	bb9d                	j	ffffffffc0201672 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02018fe:	00001617          	auipc	a2,0x1
ffffffffc0201902:	00260613          	addi	a2,a2,2 # ffffffffc0202900 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201906:	00001417          	auipc	s0,0x1
ffffffffc020190a:	ffb40413          	addi	s0,s0,-5 # ffffffffc0202901 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020190e:	8532                	mv	a0,a2
ffffffffc0201910:	85e6                	mv	a1,s9
ffffffffc0201912:	e032                	sd	a2,0(sp)
ffffffffc0201914:	e43e                	sd	a5,8(sp)
ffffffffc0201916:	c37ff0ef          	jal	ra,ffffffffc020154c <strnlen>
ffffffffc020191a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020191e:	6602                	ld	a2,0(sp)
ffffffffc0201920:	01b05d63          	blez	s11,ffffffffc020193a <vprintfmt+0x302>
ffffffffc0201924:	67a2                	ld	a5,8(sp)
ffffffffc0201926:	2781                	sext.w	a5,a5
ffffffffc0201928:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020192a:	6522                	ld	a0,8(sp)
ffffffffc020192c:	85a6                	mv	a1,s1
ffffffffc020192e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201930:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201932:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201934:	6602                	ld	a2,0(sp)
ffffffffc0201936:	fe0d9ae3          	bnez	s11,ffffffffc020192a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020193a:	00064783          	lbu	a5,0(a2)
ffffffffc020193e:	0007851b          	sext.w	a0,a5
ffffffffc0201942:	e8051be3          	bnez	a0,ffffffffc02017d8 <vprintfmt+0x1a0>
ffffffffc0201946:	b335                	j	ffffffffc0201672 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201948:	000aa403          	lw	s0,0(s5)
ffffffffc020194c:	bbf1                	j	ffffffffc0201728 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020194e:	000ae603          	lwu	a2,0(s5)
ffffffffc0201952:	46a9                	li	a3,10
ffffffffc0201954:	8aae                	mv	s5,a1
ffffffffc0201956:	bd89                	j	ffffffffc02017a8 <vprintfmt+0x170>
ffffffffc0201958:	000ae603          	lwu	a2,0(s5)
ffffffffc020195c:	46c1                	li	a3,16
ffffffffc020195e:	8aae                	mv	s5,a1
ffffffffc0201960:	b5a1                	j	ffffffffc02017a8 <vprintfmt+0x170>
ffffffffc0201962:	000ae603          	lwu	a2,0(s5)
ffffffffc0201966:	46a1                	li	a3,8
ffffffffc0201968:	8aae                	mv	s5,a1
ffffffffc020196a:	bd3d                	j	ffffffffc02017a8 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020196c:	9902                	jalr	s2
ffffffffc020196e:	b559                	j	ffffffffc02017f4 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201970:	85a6                	mv	a1,s1
ffffffffc0201972:	02d00513          	li	a0,45
ffffffffc0201976:	e03e                	sd	a5,0(sp)
ffffffffc0201978:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020197a:	8ace                	mv	s5,s3
ffffffffc020197c:	40800633          	neg	a2,s0
ffffffffc0201980:	46a9                	li	a3,10
ffffffffc0201982:	6782                	ld	a5,0(sp)
ffffffffc0201984:	b515                	j	ffffffffc02017a8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201986:	01b05663          	blez	s11,ffffffffc0201992 <vprintfmt+0x35a>
ffffffffc020198a:	02d00693          	li	a3,45
ffffffffc020198e:	f6d798e3          	bne	a5,a3,ffffffffc02018fe <vprintfmt+0x2c6>
ffffffffc0201992:	00001417          	auipc	s0,0x1
ffffffffc0201996:	f6f40413          	addi	s0,s0,-145 # ffffffffc0202901 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020199a:	02800513          	li	a0,40
ffffffffc020199e:	02800793          	li	a5,40
ffffffffc02019a2:	bd1d                	j	ffffffffc02017d8 <vprintfmt+0x1a0>

ffffffffc02019a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019ae:	ec06                	sd	ra,24(sp)
ffffffffc02019b0:	f83a                	sd	a4,48(sp)
ffffffffc02019b2:	fc3e                	sd	a5,56(sp)
ffffffffc02019b4:	e0c2                	sd	a6,64(sp)
ffffffffc02019b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02019b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019ba:	c7fff0ef          	jal	ra,ffffffffc0201638 <vprintfmt>
}
ffffffffc02019be:	60e2                	ld	ra,24(sp)
ffffffffc02019c0:	6161                	addi	sp,sp,80
ffffffffc02019c2:	8082                	ret

ffffffffc02019c4 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02019c4:	715d                	addi	sp,sp,-80
ffffffffc02019c6:	e486                	sd	ra,72(sp)
ffffffffc02019c8:	e0a2                	sd	s0,64(sp)
ffffffffc02019ca:	fc26                	sd	s1,56(sp)
ffffffffc02019cc:	f84a                	sd	s2,48(sp)
ffffffffc02019ce:	f44e                	sd	s3,40(sp)
ffffffffc02019d0:	f052                	sd	s4,32(sp)
ffffffffc02019d2:	ec56                	sd	s5,24(sp)
ffffffffc02019d4:	e85a                	sd	s6,16(sp)
ffffffffc02019d6:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02019d8:	c901                	beqz	a0,ffffffffc02019e8 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02019da:	85aa                	mv	a1,a0
ffffffffc02019dc:	00001517          	auipc	a0,0x1
ffffffffc02019e0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0202918 <error_string+0xe8>
ffffffffc02019e4:	ed2fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02019e8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019ea:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02019ec:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02019ee:	4aa9                	li	s5,10
ffffffffc02019f0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02019f2:	00004b97          	auipc	s7,0x4
ffffffffc02019f6:	61eb8b93          	addi	s7,s7,1566 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02019fa:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02019fe:	f30fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a02:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a04:	00054b63          	bltz	a0,ffffffffc0201a1a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a08:	00a95b63          	ble	a0,s2,ffffffffc0201a1e <readline+0x5a>
ffffffffc0201a0c:	029a5463          	ble	s1,s4,ffffffffc0201a34 <readline+0x70>
        c = getchar();
ffffffffc0201a10:	f1efe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a14:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a16:	fe0559e3          	bgez	a0,ffffffffc0201a08 <readline+0x44>
            return NULL;
ffffffffc0201a1a:	4501                	li	a0,0
ffffffffc0201a1c:	a099                	j	ffffffffc0201a62 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201a1e:	03341463          	bne	s0,s3,ffffffffc0201a46 <readline+0x82>
ffffffffc0201a22:	e8b9                	bnez	s1,ffffffffc0201a78 <readline+0xb4>
        c = getchar();
ffffffffc0201a24:	f0afe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201a28:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a2a:	fe0548e3          	bltz	a0,ffffffffc0201a1a <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a2e:	fea958e3          	ble	a0,s2,ffffffffc0201a1e <readline+0x5a>
ffffffffc0201a32:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a34:	8522                	mv	a0,s0
ffffffffc0201a36:	eb4fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201a3a:	009b87b3          	add	a5,s7,s1
ffffffffc0201a3e:	00878023          	sb	s0,0(a5)
ffffffffc0201a42:	2485                	addiw	s1,s1,1
ffffffffc0201a44:	bf6d                	j	ffffffffc02019fe <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a46:	01540463          	beq	s0,s5,ffffffffc0201a4e <readline+0x8a>
ffffffffc0201a4a:	fb641ae3          	bne	s0,s6,ffffffffc02019fe <readline+0x3a>
            cputchar(c);
ffffffffc0201a4e:	8522                	mv	a0,s0
ffffffffc0201a50:	e9afe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201a54:	00004517          	auipc	a0,0x4
ffffffffc0201a58:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206010 <edata>
ffffffffc0201a5c:	94aa                	add	s1,s1,a0
ffffffffc0201a5e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201a62:	60a6                	ld	ra,72(sp)
ffffffffc0201a64:	6406                	ld	s0,64(sp)
ffffffffc0201a66:	74e2                	ld	s1,56(sp)
ffffffffc0201a68:	7942                	ld	s2,48(sp)
ffffffffc0201a6a:	79a2                	ld	s3,40(sp)
ffffffffc0201a6c:	7a02                	ld	s4,32(sp)
ffffffffc0201a6e:	6ae2                	ld	s5,24(sp)
ffffffffc0201a70:	6b42                	ld	s6,16(sp)
ffffffffc0201a72:	6ba2                	ld	s7,8(sp)
ffffffffc0201a74:	6161                	addi	sp,sp,80
ffffffffc0201a76:	8082                	ret
            cputchar(c);
ffffffffc0201a78:	4521                	li	a0,8
ffffffffc0201a7a:	e70fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201a7e:	34fd                	addiw	s1,s1,-1
ffffffffc0201a80:	bfbd                	j	ffffffffc02019fe <readline+0x3a>

ffffffffc0201a82 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201a82:	00004797          	auipc	a5,0x4
ffffffffc0201a86:	58678793          	addi	a5,a5,1414 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201a8a:	6398                	ld	a4,0(a5)
ffffffffc0201a8c:	4781                	li	a5,0
ffffffffc0201a8e:	88ba                	mv	a7,a4
ffffffffc0201a90:	852a                	mv	a0,a0
ffffffffc0201a92:	85be                	mv	a1,a5
ffffffffc0201a94:	863e                	mv	a2,a5
ffffffffc0201a96:	00000073          	ecall
ffffffffc0201a9a:	87aa                	mv	a5,a0
}
ffffffffc0201a9c:	8082                	ret

ffffffffc0201a9e <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201a9e:	00005797          	auipc	a5,0x5
ffffffffc0201aa2:	98a78793          	addi	a5,a5,-1654 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201aa6:	6398                	ld	a4,0(a5)
ffffffffc0201aa8:	4781                	li	a5,0
ffffffffc0201aaa:	88ba                	mv	a7,a4
ffffffffc0201aac:	852a                	mv	a0,a0
ffffffffc0201aae:	85be                	mv	a1,a5
ffffffffc0201ab0:	863e                	mv	a2,a5
ffffffffc0201ab2:	00000073          	ecall
ffffffffc0201ab6:	87aa                	mv	a5,a0
}
ffffffffc0201ab8:	8082                	ret

ffffffffc0201aba <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201aba:	00004797          	auipc	a5,0x4
ffffffffc0201abe:	54678793          	addi	a5,a5,1350 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201ac2:	639c                	ld	a5,0(a5)
ffffffffc0201ac4:	4501                	li	a0,0
ffffffffc0201ac6:	88be                	mv	a7,a5
ffffffffc0201ac8:	852a                	mv	a0,a0
ffffffffc0201aca:	85aa                	mv	a1,a0
ffffffffc0201acc:	862a                	mv	a2,a0
ffffffffc0201ace:	00000073          	ecall
ffffffffc0201ad2:	852a                	mv	a0,a0
ffffffffc0201ad4:	2501                	sext.w	a0,a0
ffffffffc0201ad6:	8082                	ret
