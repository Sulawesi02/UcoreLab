
bin/kernel：     文件格式 elf64-littleriscv


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
ffffffffc020004e:	77e010ef          	jal	ra,ffffffffc02017cc <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	c9a50513          	addi	a0,a0,-870 # ffffffffc0201cf0 <etext+0x6>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	546010ef          	jal	ra,ffffffffc02015b0 <pmm_init>

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
ffffffffc02000aa:	7a0010ef          	jal	ra,ffffffffc020184a <vprintfmt>
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
ffffffffc02000de:	76c010ef          	jal	ra,ffffffffc020184a <vprintfmt>
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
ffffffffc0200174:	ba050513          	addi	a0,a0,-1120 # ffffffffc0201d10 <etext+0x26>
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
ffffffffc020018a:	32250513          	addi	a0,a0,802 # ffffffffc02024a8 <commands+0x678>
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
ffffffffc02001a4:	bc050513          	addi	a0,a0,-1088 # ffffffffc0201d60 <etext+0x76>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	bca50513          	addi	a0,a0,-1078 # ffffffffc0201d80 <etext+0x96>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	b2858593          	addi	a1,a1,-1240 # ffffffffc0201cea <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	bd650513          	addi	a0,a0,-1066 # ffffffffc0201da0 <etext+0xb6>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	be250513          	addi	a0,a0,-1054 # ffffffffc0201dc0 <etext+0xd6>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	28658593          	addi	a1,a1,646 # ffffffffc0206470 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	bee50513          	addi	a0,a0,-1042 # ffffffffc0201de0 <etext+0xf6>
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
ffffffffc0200224:	be050513          	addi	a0,a0,-1056 # ffffffffc0201e00 <etext+0x116>
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
ffffffffc0200234:	b0060613          	addi	a2,a2,-1280 # ffffffffc0201d30 <etext+0x46>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0201d48 <etext+0x5e>
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
ffffffffc0200250:	cc460613          	addi	a2,a2,-828 # ffffffffc0201f10 <commands+0xe0>
ffffffffc0200254:	00002597          	auipc	a1,0x2
ffffffffc0200258:	cdc58593          	addi	a1,a1,-804 # ffffffffc0201f30 <commands+0x100>
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	cdc50513          	addi	a0,a0,-804 # ffffffffc0201f38 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	cde60613          	addi	a2,a2,-802 # ffffffffc0201f48 <commands+0x118>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	cfe58593          	addi	a1,a1,-770 # ffffffffc0201f70 <commands+0x140>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0201f38 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00002617          	auipc	a2,0x2
ffffffffc020028a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0201f80 <commands+0x150>
ffffffffc020028e:	00002597          	auipc	a1,0x2
ffffffffc0200292:	d1258593          	addi	a1,a1,-750 # ffffffffc0201fa0 <commands+0x170>
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	ca250513          	addi	a0,a0,-862 # ffffffffc0201f38 <commands+0x108>
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
ffffffffc02002d4:	ba850513          	addi	a0,a0,-1112 # ffffffffc0201e78 <commands+0x48>
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
ffffffffc02002f6:	bae50513          	addi	a0,a0,-1106 # ffffffffc0201ea0 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00002c97          	auipc	s9,0x2
ffffffffc020030c:	b28c8c93          	addi	s9,s9,-1240 # ffffffffc0201e30 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00002997          	auipc	s3,0x2
ffffffffc0200314:	bb898993          	addi	s3,s3,-1096 # ffffffffc0201ec8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00002917          	auipc	s2,0x2
ffffffffc020031c:	bb890913          	addi	s2,s2,-1096 # ffffffffc0201ed0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00002b17          	auipc	s6,0x2
ffffffffc0200326:	bb6b0b13          	addi	s6,s6,-1098 # ffffffffc0201ed8 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00002a97          	auipc	s5,0x2
ffffffffc020032e:	c06a8a93          	addi	s5,s5,-1018 # ffffffffc0201f30 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	0a1010ef          	jal	ra,ffffffffc0201bd6 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	466010ef          	jal	ra,ffffffffc02017ae <strchr>
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
ffffffffc0200362:	ad2d0d13          	addi	s10,s10,-1326 # ffffffffc0201e30 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	418010ef          	jal	ra,ffffffffc0201784 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	404010ef          	jal	ra,ffffffffc0201784 <strcmp>
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
ffffffffc02003e6:	3c8010ef          	jal	ra,ffffffffc02017ae <strchr>
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
ffffffffc0200402:	afa50513          	addi	a0,a0,-1286 # ffffffffc0201ef8 <commands+0xc8>
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
ffffffffc0200424:	08d010ef          	jal	ra,ffffffffc0201cb0 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0201fb0 <commands+0x180>
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
ffffffffc020044c:	0650106f          	j	ffffffffc0201cb0 <sbi_set_timer>

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
ffffffffc0200456:	03f0106f          	j	ffffffffc0201c94 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	0730106f          	j	ffffffffc0201ccc <sbi_console_getchar>

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
ffffffffc0200488:	c4450513          	addi	a0,a0,-956 # ffffffffc02020c8 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	c4c50513          	addi	a0,a0,-948 # ffffffffc02020e0 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	c5650513          	addi	a0,a0,-938 # ffffffffc02020f8 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	c6050513          	addi	a0,a0,-928 # ffffffffc0202110 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	c6a50513          	addi	a0,a0,-918 # ffffffffc0202128 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	c7450513          	addi	a0,a0,-908 # ffffffffc0202140 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	c7e50513          	addi	a0,a0,-898 # ffffffffc0202158 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	c8850513          	addi	a0,a0,-888 # ffffffffc0202170 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	c9250513          	addi	a0,a0,-878 # ffffffffc0202188 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	c9c50513          	addi	a0,a0,-868 # ffffffffc02021a0 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	ca650513          	addi	a0,a0,-858 # ffffffffc02021b8 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	cb050513          	addi	a0,a0,-848 # ffffffffc02021d0 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	cba50513          	addi	a0,a0,-838 # ffffffffc02021e8 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	cc450513          	addi	a0,a0,-828 # ffffffffc0202200 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	cce50513          	addi	a0,a0,-818 # ffffffffc0202218 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	cd850513          	addi	a0,a0,-808 # ffffffffc0202230 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	ce250513          	addi	a0,a0,-798 # ffffffffc0202248 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	cec50513          	addi	a0,a0,-788 # ffffffffc0202260 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	cf650513          	addi	a0,a0,-778 # ffffffffc0202278 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	d0050513          	addi	a0,a0,-768 # ffffffffc0202290 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	d0a50513          	addi	a0,a0,-758 # ffffffffc02022a8 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	d1450513          	addi	a0,a0,-748 # ffffffffc02022c0 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	d1e50513          	addi	a0,a0,-738 # ffffffffc02022d8 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	d2850513          	addi	a0,a0,-728 # ffffffffc02022f0 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	d3250513          	addi	a0,a0,-718 # ffffffffc0202308 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	d3c50513          	addi	a0,a0,-708 # ffffffffc0202320 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	d4650513          	addi	a0,a0,-698 # ffffffffc0202338 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	d5050513          	addi	a0,a0,-688 # ffffffffc0202350 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	d5a50513          	addi	a0,a0,-678 # ffffffffc0202368 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	d6450513          	addi	a0,a0,-668 # ffffffffc0202380 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	d6e50513          	addi	a0,a0,-658 # ffffffffc0202398 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	d7450513          	addi	a0,a0,-652 # ffffffffc02023b0 <commands+0x580>
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
ffffffffc0200656:	d7650513          	addi	a0,a0,-650 # ffffffffc02023c8 <commands+0x598>
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
ffffffffc020066e:	d7650513          	addi	a0,a0,-650 # ffffffffc02023e0 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	d7e50513          	addi	a0,a0,-642 # ffffffffc02023f8 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	d8650513          	addi	a0,a0,-634 # ffffffffc0202410 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	d8a50513          	addi	a0,a0,-630 # ffffffffc0202428 <commands+0x5f8>
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
ffffffffc02006bc:	00002717          	auipc	a4,0x2
ffffffffc02006c0:	91070713          	addi	a4,a4,-1776 # ffffffffc0201fcc <commands+0x19c>
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
ffffffffc02006ce:	00002517          	auipc	a0,0x2
ffffffffc02006d2:	99250513          	addi	a0,a0,-1646 # ffffffffc0202060 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	96650513          	addi	a0,a0,-1690 # ffffffffc0202040 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00002517          	auipc	a0,0x2
ffffffffc02006ea:	91a50513          	addi	a0,a0,-1766 # ffffffffc0202000 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00002517          	auipc	a0,0x2
ffffffffc02006f6:	98e50513          	addi	a0,a0,-1650 # ffffffffc0202080 <commands+0x250>
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
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	97e50513          	addi	a0,a0,-1666 # ffffffffc02020a8 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00002517          	auipc	a0,0x2
ffffffffc020073a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0202020 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00002517          	auipc	a0,0x2
ffffffffc0200750:	94c50513          	addi	a0,a0,-1716 # ffffffffc0202098 <commands+0x268>
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

ffffffffc020082a <buddy_system_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define MEM_BEGIN 0xffffffffc020f318

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <buddy_system_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, buddy_system_check functions!
static void
buddy_system_check(void) {
ffffffffc0200846:	715d                	addi	sp,sp,-80
    // basic_check();
    cprintf("=============================复杂测试开始=============================\n");
ffffffffc0200848:	00002517          	auipc	a0,0x2
ffffffffc020084c:	cb850513          	addi	a0,a0,-840 # ffffffffc0202500 <commands+0x6d0>
buddy_system_check(void) {
ffffffffc0200850:	e0a2                	sd	s0,64(sp)
ffffffffc0200852:	e486                	sd	ra,72(sp)
ffffffffc0200854:	fc26                	sd	s1,56(sp)
ffffffffc0200856:	f84a                	sd	s2,48(sp)
ffffffffc0200858:	f44e                	sd	s3,40(sp)
ffffffffc020085a:	f052                	sd	s4,32(sp)
ffffffffc020085c:	ec56                	sd	s5,24(sp)
ffffffffc020085e:	e85a                	sd	s6,16(sp)
ffffffffc0200860:	e45e                	sd	s7,8(sp)
ffffffffc0200862:	e062                	sd	s8,0(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200864:	00006417          	auipc	s0,0x6
ffffffffc0200868:	bd440413          	addi	s0,s0,-1068 # ffffffffc0206438 <free_area>
    cprintf("=============================复杂测试开始=============================\n");
ffffffffc020086c:	84bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200870:	641c                	ld	a5,8(s0)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    // 计算当前空闲块数目和空闲页数目
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200872:	4c878e63          	beq	a5,s0,ffffffffc0200d4e <buddy_system_check+0x508>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200876:	ff07b703          	ld	a4,-16(a5)
ffffffffc020087a:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020087c:	8b05                	andi	a4,a4,1
ffffffffc020087e:	5e070563          	beqz	a4,ffffffffc0200e68 <buddy_system_check+0x622>
    int count = 0, total = 0;
ffffffffc0200882:	4481                	li	s1,0
ffffffffc0200884:	4901                	li	s2,0
ffffffffc0200886:	a031                	j	ffffffffc0200892 <buddy_system_check+0x4c>
ffffffffc0200888:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020088c:	8b09                	andi	a4,a4,2
ffffffffc020088e:	5c070d63          	beqz	a4,ffffffffc0200e68 <buddy_system_check+0x622>
        count ++, total += p->property;
ffffffffc0200892:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200896:	679c                	ld	a5,8(a5)
ffffffffc0200898:	2905                	addiw	s2,s2,1
ffffffffc020089a:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020089c:	fe8796e3          	bne	a5,s0,ffffffffc0200888 <buddy_system_check+0x42>
ffffffffc02008a0:	89a6                	mv	s3,s1
    }
    assert(total == nr_free_pages());
ffffffffc02008a2:	4cf000ef          	jal	ra,ffffffffc0201570 <nr_free_pages>
ffffffffc02008a6:	5f351163          	bne	a0,s3,ffffffffc0200e88 <buddy_system_check+0x642>
    cprintf("空闲块数目为: %d\n", count);
ffffffffc02008aa:	85ca                	mv	a1,s2
ffffffffc02008ac:	00002517          	auipc	a0,0x2
ffffffffc02008b0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02025b8 <commands+0x788>
ffffffffc02008b4:	803ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("空闲页数目为: %d\n", total);
ffffffffc02008b8:	85a6                	mv	a1,s1
ffffffffc02008ba:	00002517          	auipc	a0,0x2
ffffffffc02008be:	d1650513          	addi	a0,a0,-746 # ffffffffc02025d0 <commands+0x7a0>
ffffffffc02008c2:	ff4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    // cprintf("-----------------------------Step 3: 边界条件测试 - 超出可用块请求-----\n");
    // struct Page *p4 = alloc_pages(MAX_INIT_PAGES + 1);  // 请求超过最大块
    // assert(p4 == NULL);
    // cprintf("分配超过最大块失败，空闲页数目为: %d\n", nr_free);
    // Step 4: 随机分配和释放测试
    cprintf("-----------------------------Step 4: 随机分配和释放测试---------------\n");
ffffffffc02008c6:	00002517          	auipc	a0,0x2
ffffffffc02008ca:	d2250513          	addi	a0,a0,-734 # ffffffffc02025e8 <commands+0x7b8>
ffffffffc02008ce:	fe8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p5请求4095页\n");
ffffffffc02008d2:	00002517          	auipc	a0,0x2
ffffffffc02008d6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0202640 <commands+0x810>
ffffffffc02008da:	fdcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p5 = alloc_pages(4095);   // 请求 4095 页
ffffffffc02008de:	6505                	lui	a0,0x1
ffffffffc02008e0:	157d                	addi	a0,a0,-1
ffffffffc02008e2:	405000ef          	jal	ra,ffffffffc02014e6 <alloc_pages>
ffffffffc02008e6:	6404                	ld	s1,8(s0)
ffffffffc02008e8:	892a                	mv	s2,a0
    int i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02008ea:	04848963          	beq	s1,s0,ffffffffc020093c <buddy_system_check+0xf6>
ffffffffc02008ee:	ff04b983          	ld	s3,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc02008f2:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc02008f6:	00002a97          	auipc	s5,0x2
ffffffffc02008fa:	daaa8a93          	addi	s5,s5,-598 # ffffffffc02026a0 <commands+0x870>
ffffffffc02008fe:	0019d993          	srli	s3,s3,0x1
ffffffffc0200902:	0019f993          	andi	s3,s3,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200906:	00002a17          	auipc	s4,0x2
ffffffffc020090a:	ccaa0a13          	addi	s4,s4,-822 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc020090e:	00099a63          	bnez	s3,ffffffffc0200922 <buddy_system_check+0xdc>
ffffffffc0200912:	ab1d                	j	ffffffffc0200e48 <buddy_system_check+0x602>
ffffffffc0200914:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200918:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
ffffffffc020091c:	8b89                	andi	a5,a5,2
ffffffffc020091e:	52078563          	beqz	a5,ffffffffc0200e48 <buddy_system_check+0x602>
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200922:	85ce                	mv	a1,s3
ffffffffc0200924:	8556                	mv	a0,s5
ffffffffc0200926:	f90ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc020092a:	ff84a583          	lw	a1,-8(s1)
ffffffffc020092e:	8552                	mv	a0,s4
        i+=1;
ffffffffc0200930:	2985                	addiw	s3,s3,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200932:	f84ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200936:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200938:	fc849ee3          	bne	s1,s0,ffffffffc0200914 <buddy_system_check+0xce>
    }
    cprintf("--------------------------------------------\n");
ffffffffc020093c:	00002517          	auipc	a0,0x2
ffffffffc0200940:	d1c50513          	addi	a0,a0,-740 # ffffffffc0202658 <commands+0x828>
ffffffffc0200944:	f72ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p6请求4094页\n");
ffffffffc0200948:	00002517          	auipc	a0,0x2
ffffffffc020094c:	d4050513          	addi	a0,a0,-704 # ffffffffc0202688 <commands+0x858>
ffffffffc0200950:	f66ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p6 = alloc_pages(4094);   // 请求 4094 页
ffffffffc0200954:	6505                	lui	a0,0x1
ffffffffc0200956:	1579                	addi	a0,a0,-2
ffffffffc0200958:	38f000ef          	jal	ra,ffffffffc02014e6 <alloc_pages>
ffffffffc020095c:	6404                	ld	s1,8(s0)
ffffffffc020095e:	89aa                	mv	s3,a0
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200960:	04848963          	beq	s1,s0,ffffffffc02009b2 <buddy_system_check+0x16c>
ffffffffc0200964:	ff04ba03          	ld	s4,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200968:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc020096c:	00002b17          	auipc	s6,0x2
ffffffffc0200970:	d34b0b13          	addi	s6,s6,-716 # ffffffffc02026a0 <commands+0x870>
ffffffffc0200974:	001a5a13          	srli	s4,s4,0x1
ffffffffc0200978:	001a7a13          	andi	s4,s4,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc020097c:	00002a97          	auipc	s5,0x2
ffffffffc0200980:	c54a8a93          	addi	s5,s5,-940 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200984:	000a1a63          	bnez	s4,ffffffffc0200998 <buddy_system_check+0x152>
ffffffffc0200988:	a145                	j	ffffffffc0200e28 <buddy_system_check+0x5e2>
ffffffffc020098a:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc020098e:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
ffffffffc0200992:	8b89                	andi	a5,a5,2
ffffffffc0200994:	48078a63          	beqz	a5,ffffffffc0200e28 <buddy_system_check+0x5e2>
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200998:	85d2                	mv	a1,s4
ffffffffc020099a:	855a                	mv	a0,s6
ffffffffc020099c:	f1aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc02009a0:	ff84a583          	lw	a1,-8(s1)
ffffffffc02009a4:	8556                	mv	a0,s5
        i+=1;
ffffffffc02009a6:	2a05                	addiw	s4,s4,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc02009a8:	f0eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009ac:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009ae:	fc849ee3          	bne	s1,s0,ffffffffc020098a <buddy_system_check+0x144>
    }
    cprintf("--------------------------------------------\n");
ffffffffc02009b2:	00002517          	auipc	a0,0x2
ffffffffc02009b6:	ca650513          	addi	a0,a0,-858 # ffffffffc0202658 <commands+0x828>
ffffffffc02009ba:	efcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p7请求4093页\n");
ffffffffc02009be:	00002517          	auipc	a0,0x2
ffffffffc02009c2:	d1250513          	addi	a0,a0,-750 # ffffffffc02026d0 <commands+0x8a0>
ffffffffc02009c6:	ef0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p7 = alloc_pages(4093);   // 请求 4093 页
ffffffffc02009ca:	6505                	lui	a0,0x1
ffffffffc02009cc:	1575                	addi	a0,a0,-3
ffffffffc02009ce:	319000ef          	jal	ra,ffffffffc02014e6 <alloc_pages>
ffffffffc02009d2:	6404                	ld	s1,8(s0)
ffffffffc02009d4:	8a2a                	mv	s4,a0
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009d6:	04848963          	beq	s1,s0,ffffffffc0200a28 <buddy_system_check+0x1e2>
ffffffffc02009da:	ff04ba83          	ld	s5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc02009de:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc02009e2:	00002b17          	auipc	s6,0x2
ffffffffc02009e6:	cbeb0b13          	addi	s6,s6,-834 # ffffffffc02026a0 <commands+0x870>
ffffffffc02009ea:	001ada93          	srli	s5,s5,0x1
ffffffffc02009ee:	001afa93          	andi	s5,s5,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc02009f2:	00002b97          	auipc	s7,0x2
ffffffffc02009f6:	bdeb8b93          	addi	s7,s7,-1058 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc02009fa:	000a9a63          	bnez	s5,ffffffffc0200a0e <buddy_system_check+0x1c8>
ffffffffc02009fe:	a129                	j	ffffffffc0200e08 <buddy_system_check+0x5c2>
ffffffffc0200a00:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a04:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
ffffffffc0200a08:	8b89                	andi	a5,a5,2
ffffffffc0200a0a:	3e078f63          	beqz	a5,ffffffffc0200e08 <buddy_system_check+0x5c2>
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200a0e:	85d6                	mv	a1,s5
ffffffffc0200a10:	855a                	mv	a0,s6
ffffffffc0200a12:	ea4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200a16:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200a1a:	855e                	mv	a0,s7
        i+=1;
ffffffffc0200a1c:	2a85                	addiw	s5,s5,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200a1e:	e98ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200a22:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a24:	fc849ee3          	bne	s1,s0,ffffffffc0200a00 <buddy_system_check+0x1ba>
    }
    cprintf("--------------------------------------------\n");
ffffffffc0200a28:	00002517          	auipc	a0,0x2
ffffffffc0200a2c:	c3050513          	addi	a0,a0,-976 # ffffffffc0202658 <commands+0x828>
ffffffffc0200a30:	e86ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p8请求2000页\n");
ffffffffc0200a34:	00002517          	auipc	a0,0x2
ffffffffc0200a38:	cb450513          	addi	a0,a0,-844 # ffffffffc02026e8 <commands+0x8b8>
ffffffffc0200a3c:	e7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p8 = alloc_pages(2000);   // 请求 2000 页
ffffffffc0200a40:	7d000513          	li	a0,2000
ffffffffc0200a44:	2a3000ef          	jal	ra,ffffffffc02014e6 <alloc_pages>
ffffffffc0200a48:	6404                	ld	s1,8(s0)
ffffffffc0200a4a:	8aaa                	mv	s5,a0
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a4c:	04848963          	beq	s1,s0,ffffffffc0200a9e <buddy_system_check+0x258>
ffffffffc0200a50:	ff04bb03          	ld	s6,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a54:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200a58:	00002b97          	auipc	s7,0x2
ffffffffc0200a5c:	c48b8b93          	addi	s7,s7,-952 # ffffffffc02026a0 <commands+0x870>
ffffffffc0200a60:	001b5b13          	srli	s6,s6,0x1
ffffffffc0200a64:	001b7b13          	andi	s6,s6,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200a68:	00002c17          	auipc	s8,0x2
ffffffffc0200a6c:	b68c0c13          	addi	s8,s8,-1176 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200a70:	000b1a63          	bnez	s6,ffffffffc0200a84 <buddy_system_check+0x23e>
ffffffffc0200a74:	ae95                	j	ffffffffc0200de8 <buddy_system_check+0x5a2>
ffffffffc0200a76:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a7a:	fe848613          	addi	a2,s1,-24
        assert(PageProperty(p));
ffffffffc0200a7e:	8b89                	andi	a5,a5,2
ffffffffc0200a80:	36078463          	beqz	a5,ffffffffc0200de8 <buddy_system_check+0x5a2>
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200a84:	85da                	mv	a1,s6
ffffffffc0200a86:	855e                	mv	a0,s7
ffffffffc0200a88:	e2eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200a8c:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200a90:	8562                	mv	a0,s8
        i+=1;
ffffffffc0200a92:	2b05                	addiw	s6,s6,1
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200a94:	e22ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200a98:	6484                	ld	s1,8(s1)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a9a:	fc849ee3          	bne	s1,s0,ffffffffc0200a76 <buddy_system_check+0x230>
    }
    cprintf("--------------------------------------------\n");
ffffffffc0200a9e:	00002517          	auipc	a0,0x2
ffffffffc0200aa2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0202658 <commands+0x828>
ffffffffc0200aa6:	e10ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("测试一下释放p6和p7，它们会不会错误合并\n");
ffffffffc0200aaa:	00002517          	auipc	a0,0x2
ffffffffc0200aae:	c5650513          	addi	a0,a0,-938 # ffffffffc0202700 <commands+0x8d0>
ffffffffc0200ab2:	e04ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    // 释放 p6
    cprintf("释放p6\n");
ffffffffc0200ab6:	00002517          	auipc	a0,0x2
ffffffffc0200aba:	c8a50513          	addi	a0,a0,-886 # ffffffffc0202740 <commands+0x910>
ffffffffc0200abe:	df8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p6, 4094);
ffffffffc0200ac2:	6585                	lui	a1,0x1
ffffffffc0200ac4:	854e                	mv	a0,s3
ffffffffc0200ac6:	15f9                	addi	a1,a1,-2
ffffffffc0200ac8:	263000ef          	jal	ra,ffffffffc020152a <free_pages>
ffffffffc0200acc:	6404                	ld	s1,8(s0)
    le = &free_list;
    count = 0, total = 0;
ffffffffc0200ace:	4b01                	li	s6,0
ffffffffc0200ad0:	4981                	li	s3,0
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ad2:	06848063          	beq	s1,s0,ffffffffc0200b32 <buddy_system_check+0x2ec>
ffffffffc0200ad6:	ff04b983          	ld	s3,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200ada:	fe848613          	addi	a2,s1,-24
    count = 0, total = 0;
ffffffffc0200ade:	4b01                	li	s6,0
ffffffffc0200ae0:	0019d993          	srli	s3,s3,0x1
ffffffffc0200ae4:	0019f993          	andi	s3,s3,1
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200ae8:	00002c17          	auipc	s8,0x2
ffffffffc0200aec:	bb8c0c13          	addi	s8,s8,-1096 # ffffffffc02026a0 <commands+0x870>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200af0:	00002b97          	auipc	s7,0x2
ffffffffc0200af4:	ae0b8b93          	addi	s7,s7,-1312 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200af8:	00099b63          	bnez	s3,ffffffffc0200b0e <buddy_system_check+0x2c8>
ffffffffc0200afc:	a4f1                	j	ffffffffc0200dc8 <buddy_system_check+0x582>
ffffffffc0200afe:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200b02:	fe848613          	addi	a2,s1,-24
        i+=1;
ffffffffc0200b06:	89ba                	mv	s3,a4
        assert(PageProperty(p));
ffffffffc0200b08:	8b89                	andi	a5,a5,2
ffffffffc0200b0a:	2a078f63          	beqz	a5,ffffffffc0200dc8 <buddy_system_check+0x582>
        count ++, total += p->property;
ffffffffc0200b0e:	ff84a783          	lw	a5,-8(s1)
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200b12:	85ce                	mv	a1,s3
ffffffffc0200b14:	8562                	mv	a0,s8
        count ++, total += p->property;
ffffffffc0200b16:	01678b3b          	addw	s6,a5,s6
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200b1a:	d9cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200b1e:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200b22:	855e                	mv	a0,s7
ffffffffc0200b24:	d92ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200b28:	6484                	ld	s1,8(s1)
        i+=1;
ffffffffc0200b2a:	0019871b          	addiw	a4,s3,1
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b2e:	fc8498e3          	bne	s1,s0,ffffffffc0200afe <buddy_system_check+0x2b8>
    }
    cprintf("释放p6后，空闲块数目为: %d\n", count);
ffffffffc0200b32:	85ce                	mv	a1,s3
ffffffffc0200b34:	00002517          	auipc	a0,0x2
ffffffffc0200b38:	c1c50513          	addi	a0,a0,-996 # ffffffffc0202750 <commands+0x920>
ffffffffc0200b3c:	d7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p6后，空闲页数目为: %d\n\n", total);
ffffffffc0200b40:	85da                	mv	a1,s6
ffffffffc0200b42:	00002517          	auipc	a0,0x2
ffffffffc0200b46:	c3650513          	addi	a0,a0,-970 # ffffffffc0202778 <commands+0x948>
ffffffffc0200b4a:	d6cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    // 释放 p7
    cprintf("释放p7\n");
ffffffffc0200b4e:	00002517          	auipc	a0,0x2
ffffffffc0200b52:	c5250513          	addi	a0,a0,-942 # ffffffffc02027a0 <commands+0x970>
ffffffffc0200b56:	d60ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p7, 4093);
ffffffffc0200b5a:	6585                	lui	a1,0x1
ffffffffc0200b5c:	15f5                	addi	a1,a1,-3
ffffffffc0200b5e:	8552                	mv	a0,s4
ffffffffc0200b60:	1cb000ef          	jal	ra,ffffffffc020152a <free_pages>
ffffffffc0200b64:	6404                	ld	s1,8(s0)
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b66:	1e848863          	beq	s1,s0,ffffffffc0200d56 <buddy_system_check+0x510>
ffffffffc0200b6a:	ff04b983          	ld	s3,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200b6e:	fe848613          	addi	a2,s1,-24
    count = 0, total = 0;
ffffffffc0200b72:	4a01                	li	s4,0
ffffffffc0200b74:	0019d993          	srli	s3,s3,0x1
ffffffffc0200b78:	0019f993          	andi	s3,s3,1
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200b7c:	00002b97          	auipc	s7,0x2
ffffffffc0200b80:	b24b8b93          	addi	s7,s7,-1244 # ffffffffc02026a0 <commands+0x870>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200b84:	00002b17          	auipc	s6,0x2
ffffffffc0200b88:	a4cb0b13          	addi	s6,s6,-1460 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200b8c:	00099b63          	bnez	s3,ffffffffc0200ba2 <buddy_system_check+0x35c>
ffffffffc0200b90:	ac21                	j	ffffffffc0200da8 <buddy_system_check+0x562>
ffffffffc0200b92:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200b96:	fe848613          	addi	a2,s1,-24
        i+=1;
ffffffffc0200b9a:	89ba                	mv	s3,a4
        assert(PageProperty(p));
ffffffffc0200b9c:	8b89                	andi	a5,a5,2
ffffffffc0200b9e:	20078563          	beqz	a5,ffffffffc0200da8 <buddy_system_check+0x562>
        count ++, total += p->property;
ffffffffc0200ba2:	ff84a783          	lw	a5,-8(s1)
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200ba6:	85ce                	mv	a1,s3
ffffffffc0200ba8:	855e                	mv	a0,s7
        count ++, total += p->property;
ffffffffc0200baa:	01478a3b          	addw	s4,a5,s4
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200bae:	d08ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200bb2:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200bb6:	855a                	mv	a0,s6
ffffffffc0200bb8:	cfeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200bbc:	6484                	ld	s1,8(s1)
        i+=1;
ffffffffc0200bbe:	0019871b          	addiw	a4,s3,1
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bc2:	fc8498e3          	bne	s1,s0,ffffffffc0200b92 <buddy_system_check+0x34c>
    }
    cprintf("释放p7后，空闲块数目为: %d\n", count);
ffffffffc0200bc6:	85ce                	mv	a1,s3
ffffffffc0200bc8:	00002517          	auipc	a0,0x2
ffffffffc0200bcc:	be850513          	addi	a0,a0,-1048 # ffffffffc02027b0 <commands+0x980>
ffffffffc0200bd0:	ce6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p7后，空闲页数目为: %d\n\n", total);
ffffffffc0200bd4:	85d2                	mv	a1,s4
ffffffffc0200bd6:	00002517          	auipc	a0,0x2
ffffffffc0200bda:	c0250513          	addi	a0,a0,-1022 # ffffffffc02027d8 <commands+0x9a8>
ffffffffc0200bde:	cd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("没有合并，测试成功\n\n");
ffffffffc0200be2:	00002517          	auipc	a0,0x2
ffffffffc0200be6:	c1e50513          	addi	a0,a0,-994 # ffffffffc0202800 <commands+0x9d0>
ffffffffc0200bea:	cccff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("--------------------------------------------\n");
ffffffffc0200bee:	00002517          	auipc	a0,0x2
ffffffffc0200bf2:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0202658 <commands+0x828>
ffffffffc0200bf6:	cc0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    // 释放 p5
    cprintf("释放p5\n");
ffffffffc0200bfa:	00002517          	auipc	a0,0x2
ffffffffc0200bfe:	c2650513          	addi	a0,a0,-986 # ffffffffc0202820 <commands+0x9f0>
ffffffffc0200c02:	cb4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p5, 4095);
ffffffffc0200c06:	6585                	lui	a1,0x1
ffffffffc0200c08:	15fd                	addi	a1,a1,-1
ffffffffc0200c0a:	854a                	mv	a0,s2
ffffffffc0200c0c:	11f000ef          	jal	ra,ffffffffc020152a <free_pages>
ffffffffc0200c10:	6404                	ld	s1,8(s0)
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c12:	14848563          	beq	s1,s0,ffffffffc0200d5c <buddy_system_check+0x516>
ffffffffc0200c16:	ff04b903          	ld	s2,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200c1a:	fe848613          	addi	a2,s1,-24
    count = 0, total = 0;
ffffffffc0200c1e:	4981                	li	s3,0
ffffffffc0200c20:	00195913          	srli	s2,s2,0x1
ffffffffc0200c24:	00197913          	andi	s2,s2,1
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200c28:	00002b17          	auipc	s6,0x2
ffffffffc0200c2c:	a78b0b13          	addi	s6,s6,-1416 # ffffffffc02026a0 <commands+0x870>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200c30:	00002a17          	auipc	s4,0x2
ffffffffc0200c34:	9a0a0a13          	addi	s4,s4,-1632 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200c38:	00091b63          	bnez	s2,ffffffffc0200c4e <buddy_system_check+0x408>
ffffffffc0200c3c:	a2b1                	j	ffffffffc0200d88 <buddy_system_check+0x542>
ffffffffc0200c3e:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200c42:	fe848613          	addi	a2,s1,-24
        i+=1;
ffffffffc0200c46:	893a                	mv	s2,a4
        assert(PageProperty(p));
ffffffffc0200c48:	8b89                	andi	a5,a5,2
ffffffffc0200c4a:	12078f63          	beqz	a5,ffffffffc0200d88 <buddy_system_check+0x542>
        count ++, total += p->property;
ffffffffc0200c4e:	ff84a783          	lw	a5,-8(s1)
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200c52:	85ca                	mv	a1,s2
ffffffffc0200c54:	855a                	mv	a0,s6
        count ++, total += p->property;
ffffffffc0200c56:	013789bb          	addw	s3,a5,s3
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200c5a:	c5cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200c5e:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200c62:	8552                	mv	a0,s4
ffffffffc0200c64:	c52ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200c68:	6484                	ld	s1,8(s1)
        i+=1;
ffffffffc0200c6a:	0019071b          	addiw	a4,s2,1
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c6e:	fc8498e3          	bne	s1,s0,ffffffffc0200c3e <buddy_system_check+0x3f8>
    }
    cprintf("释放p5后，空闲块数目为: %d\n", count);
ffffffffc0200c72:	85ca                	mv	a1,s2
ffffffffc0200c74:	00002517          	auipc	a0,0x2
ffffffffc0200c78:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0202830 <commands+0xa00>
ffffffffc0200c7c:	c3aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p5后，空闲页数目为: %d\n\n", total);
ffffffffc0200c80:	85ce                	mv	a1,s3
ffffffffc0200c82:	00002517          	auipc	a0,0x2
ffffffffc0200c86:	bd650513          	addi	a0,a0,-1066 # ffffffffc0202858 <commands+0xa28>
ffffffffc0200c8a:	c2cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("--------------------------------------------\n");
ffffffffc0200c8e:	00002517          	auipc	a0,0x2
ffffffffc0200c92:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0202658 <commands+0x828>
ffffffffc0200c96:	c20ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    // 释放 p8
    cprintf("释放p\n");
ffffffffc0200c9a:	00002517          	auipc	a0,0x2
ffffffffc0200c9e:	be650513          	addi	a0,a0,-1050 # ffffffffc0202880 <commands+0xa50>
ffffffffc0200ca2:	c14ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p8, 2000);
ffffffffc0200ca6:	7d000593          	li	a1,2000
ffffffffc0200caa:	8556                	mv	a0,s5
ffffffffc0200cac:	07f000ef          	jal	ra,ffffffffc020152a <free_pages>
ffffffffc0200cb0:	6404                	ld	s1,8(s0)
    le = &free_list;
    count = 0, total = 0;
    i=1;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cb2:	0a848863          	beq	s1,s0,ffffffffc0200d62 <buddy_system_check+0x51c>
ffffffffc0200cb6:	ff04b903          	ld	s2,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200cba:	fe848613          	addi	a2,s1,-24
    count = 0, total = 0;
ffffffffc0200cbe:	4981                	li	s3,0
ffffffffc0200cc0:	00195913          	srli	s2,s2,0x1
ffffffffc0200cc4:	00197913          	andi	s2,s2,1
        assert(PageProperty(p));
        count ++, total += p->property;
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200cc8:	00002a97          	auipc	s5,0x2
ffffffffc0200ccc:	9d8a8a93          	addi	s5,s5,-1576 # ffffffffc02026a0 <commands+0x870>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200cd0:	00002a17          	auipc	s4,0x2
ffffffffc0200cd4:	900a0a13          	addi	s4,s4,-1792 # ffffffffc02025d0 <commands+0x7a0>
        assert(PageProperty(p));
ffffffffc0200cd8:	00091a63          	bnez	s2,ffffffffc0200cec <buddy_system_check+0x4a6>
ffffffffc0200cdc:	a071                	j	ffffffffc0200d68 <buddy_system_check+0x522>
ffffffffc0200cde:	ff04b783          	ld	a5,-16(s1)
        struct Page *p = le2page(le, page_link);
ffffffffc0200ce2:	fe848613          	addi	a2,s1,-24
        i+=1;
ffffffffc0200ce6:	893a                	mv	s2,a4
        assert(PageProperty(p));
ffffffffc0200ce8:	8b89                	andi	a5,a5,2
ffffffffc0200cea:	cfbd                	beqz	a5,ffffffffc0200d68 <buddy_system_check+0x522>
        count ++, total += p->property;
ffffffffc0200cec:	ff84a783          	lw	a5,-8(s1)
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200cf0:	85ca                	mv	a1,s2
ffffffffc0200cf2:	8556                	mv	a0,s5
        count ++, total += p->property;
ffffffffc0200cf4:	013789bb          	addw	s3,a5,s3
        cprintf("空闲块%d的虚拟地址为:0x%016lx.\n", i, p);
ffffffffc0200cf8:	bbeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("空闲页数目为: %d\n", p->property);
ffffffffc0200cfc:	ff84a583          	lw	a1,-8(s1)
ffffffffc0200d00:	8552                	mv	a0,s4
ffffffffc0200d02:	bb4ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200d06:	6484                	ld	s1,8(s1)
        i+=1;
ffffffffc0200d08:	0019071b          	addiw	a4,s2,1
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d0c:	fc8499e3          	bne	s1,s0,ffffffffc0200cde <buddy_system_check+0x498>
    }
    cprintf("释放p8后，空闲块数目为: %d\n", count);
ffffffffc0200d10:	85ca                	mv	a1,s2
ffffffffc0200d12:	00002517          	auipc	a0,0x2
ffffffffc0200d16:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0202890 <commands+0xa60>
ffffffffc0200d1a:	b9cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p8后，空闲页数目为: %d\n\n", total);
ffffffffc0200d1e:	85ce                	mv	a1,s3
ffffffffc0200d20:	00002517          	auipc	a0,0x2
ffffffffc0200d24:	b9850513          	addi	a0,a0,-1128 # ffffffffc02028b8 <commands+0xa88>
ffffffffc0200d28:	b8eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("=============================复杂测试完毕=============================\n");
}
ffffffffc0200d2c:	6406                	ld	s0,64(sp)
ffffffffc0200d2e:	60a6                	ld	ra,72(sp)
ffffffffc0200d30:	74e2                	ld	s1,56(sp)
ffffffffc0200d32:	7942                	ld	s2,48(sp)
ffffffffc0200d34:	79a2                	ld	s3,40(sp)
ffffffffc0200d36:	7a02                	ld	s4,32(sp)
ffffffffc0200d38:	6ae2                	ld	s5,24(sp)
ffffffffc0200d3a:	6b42                	ld	s6,16(sp)
ffffffffc0200d3c:	6ba2                	ld	s7,8(sp)
ffffffffc0200d3e:	6c02                	ld	s8,0(sp)
    cprintf("=============================复杂测试完毕=============================\n");
ffffffffc0200d40:	00002517          	auipc	a0,0x2
ffffffffc0200d44:	ba050513          	addi	a0,a0,-1120 # ffffffffc02028e0 <commands+0xab0>
}
ffffffffc0200d48:	6161                	addi	sp,sp,80
    cprintf("=============================复杂测试完毕=============================\n");
ffffffffc0200d4a:	b6cff06f          	j	ffffffffc02000b6 <cprintf>
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d4e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200d50:	4481                	li	s1,0
ffffffffc0200d52:	4901                	li	s2,0
ffffffffc0200d54:	b6b9                	j	ffffffffc02008a2 <buddy_system_check+0x5c>
    count = 0, total = 0;
ffffffffc0200d56:	4a01                	li	s4,0
ffffffffc0200d58:	4981                	li	s3,0
ffffffffc0200d5a:	b5b5                	j	ffffffffc0200bc6 <buddy_system_check+0x380>
    count = 0, total = 0;
ffffffffc0200d5c:	4981                	li	s3,0
ffffffffc0200d5e:	4901                	li	s2,0
ffffffffc0200d60:	bf09                	j	ffffffffc0200c72 <buddy_system_check+0x42c>
    count = 0, total = 0;
ffffffffc0200d62:	4981                	li	s3,0
ffffffffc0200d64:	4901                	li	s2,0
ffffffffc0200d66:	b76d                	j	ffffffffc0200d10 <buddy_system_check+0x4ca>
        assert(PageProperty(p));
ffffffffc0200d68:	00001697          	auipc	a3,0x1
ffffffffc0200d6c:	7e868693          	addi	a3,a3,2024 # ffffffffc0202550 <commands+0x720>
ffffffffc0200d70:	00001617          	auipc	a2,0x1
ffffffffc0200d74:	7f060613          	addi	a2,a2,2032 # ffffffffc0202560 <commands+0x730>
ffffffffc0200d78:	22e00593          	li	a1,558
ffffffffc0200d7c:	00001517          	auipc	a0,0x1
ffffffffc0200d80:	7fc50513          	addi	a0,a0,2044 # ffffffffc0202578 <commands+0x748>
ffffffffc0200d84:	bbaff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200d88:	00001697          	auipc	a3,0x1
ffffffffc0200d8c:	7c868693          	addi	a3,a3,1992 # ffffffffc0202550 <commands+0x720>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	7d060613          	addi	a2,a2,2000 # ffffffffc0202560 <commands+0x730>
ffffffffc0200d98:	21d00593          	li	a1,541
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	7dc50513          	addi	a0,a0,2012 # ffffffffc0202578 <commands+0x748>
ffffffffc0200da4:	b9aff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200da8:	00001697          	auipc	a3,0x1
ffffffffc0200dac:	7a868693          	addi	a3,a3,1960 # ffffffffc0202550 <commands+0x720>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	7b060613          	addi	a2,a2,1968 # ffffffffc0202560 <commands+0x730>
ffffffffc0200db8:	20b00593          	li	a1,523
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0202578 <commands+0x748>
ffffffffc0200dc4:	b7aff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200dc8:	00001697          	auipc	a3,0x1
ffffffffc0200dcc:	78868693          	addi	a3,a3,1928 # ffffffffc0202550 <commands+0x720>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	79060613          	addi	a2,a2,1936 # ffffffffc0202560 <commands+0x730>
ffffffffc0200dd8:	1fb00593          	li	a1,507
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	79c50513          	addi	a0,a0,1948 # ffffffffc0202578 <commands+0x748>
ffffffffc0200de4:	b5aff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200de8:	00001697          	auipc	a3,0x1
ffffffffc0200dec:	76868693          	addi	a3,a3,1896 # ffffffffc0202550 <commands+0x720>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	77060613          	addi	a2,a2,1904 # ffffffffc0202560 <commands+0x730>
ffffffffc0200df8:	1ec00593          	li	a1,492
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	77c50513          	addi	a0,a0,1916 # ffffffffc0202578 <commands+0x748>
ffffffffc0200e04:	b3aff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200e08:	00001697          	auipc	a3,0x1
ffffffffc0200e0c:	74868693          	addi	a3,a3,1864 # ffffffffc0202550 <commands+0x720>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	75060613          	addi	a2,a2,1872 # ffffffffc0202560 <commands+0x730>
ffffffffc0200e18:	1e100593          	li	a1,481
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	75c50513          	addi	a0,a0,1884 # ffffffffc0202578 <commands+0x748>
ffffffffc0200e24:	b1aff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	72868693          	addi	a3,a3,1832 # ffffffffc0202550 <commands+0x720>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	73060613          	addi	a2,a2,1840 # ffffffffc0202560 <commands+0x730>
ffffffffc0200e38:	1d600593          	li	a1,470
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	73c50513          	addi	a0,a0,1852 # ffffffffc0202578 <commands+0x748>
ffffffffc0200e44:	afaff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	70868693          	addi	a3,a3,1800 # ffffffffc0202550 <commands+0x720>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	71060613          	addi	a2,a2,1808 # ffffffffc0202560 <commands+0x730>
ffffffffc0200e58:	1cb00593          	li	a1,459
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	71c50513          	addi	a0,a0,1820 # ffffffffc0202578 <commands+0x748>
ffffffffc0200e64:	adaff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200e68:	00001697          	auipc	a3,0x1
ffffffffc0200e6c:	6e868693          	addi	a3,a3,1768 # ffffffffc0202550 <commands+0x720>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	6f060613          	addi	a2,a2,1776 # ffffffffc0202560 <commands+0x730>
ffffffffc0200e78:	14c00593          	li	a1,332
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	6fc50513          	addi	a0,a0,1788 # ffffffffc0202578 <commands+0x748>
ffffffffc0200e84:	abaff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200e88:	00001697          	auipc	a3,0x1
ffffffffc0200e8c:	71068693          	addi	a3,a3,1808 # ffffffffc0202598 <commands+0x768>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	6d060613          	addi	a2,a2,1744 # ffffffffc0202560 <commands+0x730>
ffffffffc0200e98:	14f00593          	li	a1,335
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	6dc50513          	addi	a0,a0,1756 # ffffffffc0202578 <commands+0x748>
ffffffffc0200ea4:	a9aff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200ea8 <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200ea8:	7119                	addi	sp,sp,-128
ffffffffc0200eaa:	fc86                	sd	ra,120(sp)
ffffffffc0200eac:	f8a2                	sd	s0,112(sp)
ffffffffc0200eae:	f4a6                	sd	s1,104(sp)
ffffffffc0200eb0:	f0ca                	sd	s2,96(sp)
ffffffffc0200eb2:	ecce                	sd	s3,88(sp)
ffffffffc0200eb4:	e8d2                	sd	s4,80(sp)
ffffffffc0200eb6:	e4d6                	sd	s5,72(sp)
ffffffffc0200eb8:	e0da                	sd	s6,64(sp)
ffffffffc0200eba:	fc5e                	sd	s7,56(sp)
ffffffffc0200ebc:	f862                	sd	s8,48(sp)
ffffffffc0200ebe:	f466                	sd	s9,40(sp)
ffffffffc0200ec0:	f06a                	sd	s10,32(sp)
ffffffffc0200ec2:	ec6e                	sd	s11,24(sp)
    assert(n > 0);
ffffffffc0200ec4:	3c058763          	beqz	a1,ffffffffc0201292 <buddy_system_free_pages+0x3ea>
    size_t size = 1;
ffffffffc0200ec8:	4605                	li	a2,1
ffffffffc0200eca:	842a                	mv	s0,a0
ffffffffc0200ecc:	02850693          	addi	a3,a0,40
    while (size < n) {
ffffffffc0200ed0:	00b67c63          	bleu	a1,a2,ffffffffc0200ee8 <buddy_system_free_pages+0x40>
        size <<= 1;
ffffffffc0200ed4:	0606                	slli	a2,a2,0x1
    while (size < n) {
ffffffffc0200ed6:	feb66fe3          	bltu	a2,a1,ffffffffc0200ed4 <buddy_system_free_pages+0x2c>
ffffffffc0200eda:	00261693          	slli	a3,a2,0x2
ffffffffc0200ede:	96b2                	add	a3,a3,a2
ffffffffc0200ee0:	068e                	slli	a3,a3,0x3
    for (; p != base + n; p ++) {
ffffffffc0200ee2:	96a2                	add	a3,a3,s0
ffffffffc0200ee4:	02d40d63          	beq	s0,a3,ffffffffc0200f1e <buddy_system_free_pages+0x76>
ffffffffc0200ee8:	641c                	ld	a5,8(s0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200eea:	8b85                	andi	a5,a5,1
ffffffffc0200eec:	34079663          	bnez	a5,ffffffffc0201238 <buddy_system_free_pages+0x390>
ffffffffc0200ef0:	641c                	ld	a5,8(s0)
ffffffffc0200ef2:	8385                	srli	a5,a5,0x1
ffffffffc0200ef4:	8b85                	andi	a5,a5,1
ffffffffc0200ef6:	34079163          	bnez	a5,ffffffffc0201238 <buddy_system_free_pages+0x390>
ffffffffc0200efa:	87a2                	mv	a5,s0
ffffffffc0200efc:	a809                	j	ffffffffc0200f0e <buddy_system_free_pages+0x66>
ffffffffc0200efe:	6798                	ld	a4,8(a5)
ffffffffc0200f00:	8b05                	andi	a4,a4,1
ffffffffc0200f02:	32071b63          	bnez	a4,ffffffffc0201238 <buddy_system_free_pages+0x390>
ffffffffc0200f06:	6798                	ld	a4,8(a5)
ffffffffc0200f08:	8b09                	andi	a4,a4,2
ffffffffc0200f0a:	32071763          	bnez	a4,ffffffffc0201238 <buddy_system_free_pages+0x390>
        p->flags = 0;
ffffffffc0200f0e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f12:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f16:	02878793          	addi	a5,a5,40
ffffffffc0200f1a:	fed792e3          	bne	a5,a3,ffffffffc0200efe <buddy_system_free_pages+0x56>
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
ffffffffc0200f1e:	2601                	sext.w	a2,a2
ffffffffc0200f20:	c810                	sw	a2,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f22:	4789                	li	a5,2
ffffffffc0200f24:	00840713          	addi	a4,s0,8
ffffffffc0200f28:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;// 更新空闲页计数器
ffffffffc0200f2c:	00005497          	auipc	s1,0x5
ffffffffc0200f30:	50c48493          	addi	s1,s1,1292 # ffffffffc0206438 <free_area>
ffffffffc0200f34:	4898                	lw	a4,16(s1)
    return list->next == list;
ffffffffc0200f36:	649c                	ld	a5,8(s1)
ffffffffc0200f38:	9e39                	addw	a2,a2,a4
ffffffffc0200f3a:	00005717          	auipc	a4,0x5
ffffffffc0200f3e:	50c72723          	sw	a2,1294(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0200f42:	2e978263          	beq	a5,s1,ffffffffc0201226 <buddy_system_free_pages+0x37e>
            struct Page* page = le2page(le, page_link);
ffffffffc0200f46:	fe878713          	addi	a4,a5,-24
ffffffffc0200f4a:	6090                	ld	a2,0(s1)
    if (list_empty(&free_list)) {
ffffffffc0200f4c:	4581                	li	a1,0
ffffffffc0200f4e:	01840693          	addi	a3,s0,24
            if (base < page) {
ffffffffc0200f52:	00e46a63          	bltu	s0,a4,ffffffffc0200f66 <buddy_system_free_pages+0xbe>
    return listelm->next;
ffffffffc0200f56:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200f58:	12970663          	beq	a4,s1,ffffffffc0201084 <buddy_system_free_pages+0x1dc>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200f5c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f5e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f62:	fee47ae3          	bleu	a4,s0,ffffffffc0200f56 <buddy_system_free_pages+0xae>
ffffffffc0200f66:	c589                	beqz	a1,ffffffffc0200f70 <buddy_system_free_pages+0xc8>
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	4cc73823          	sd	a2,1232(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f70:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f72:	e394                	sd	a3,0(a5)
ffffffffc0200f74:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200f76:	f01c                	sd	a5,32(s0)
    elm->prev = prev;
ffffffffc0200f78:	ec18                	sd	a4,24(s0)
                size_t relative_addr = (size_t)base - MEM_BEGIN; // 计算 base 的相对起始地址
ffffffffc0200f7a:	3fdf1cb7          	lui	s9,0x3fdf1
ffffffffc0200f7e:	ce8c8793          	addi	a5,s9,-792 # 3fdf0ce8 <BASE_ADDRESS-0xffffffff8040f318>
    while (merged && base->property < MAX_INIT_PAGES) {
ffffffffc0200f82:	6a11                	lui	s4,0x4
        cprintf("当前块的地址为: 0x%016lx.\n", base);
ffffffffc0200f84:	00002b17          	auipc	s6,0x2
ffffffffc0200f88:	9dcb0b13          	addi	s6,s6,-1572 # ffffffffc0202960 <commands+0xb30>
        cprintf("当前块的页数为: %d\n\n", base->property);
ffffffffc0200f8c:	00002a97          	auipc	s5,0x2
ffffffffc0200f90:	9fca8a93          	addi	s5,s5,-1540 # ffffffffc0202988 <commands+0xb58>
            cprintf("找到 base 后面的块 p\n");
ffffffffc0200f94:	00002c17          	auipc	s8,0x2
ffffffffc0200f98:	bb4c0c13          	addi	s8,s8,-1100 # ffffffffc0202b48 <commands+0xd18>
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
ffffffffc0200f9c:	00002997          	auipc	s3,0x2
ffffffffc0200fa0:	a2c98993          	addi	s3,s3,-1492 # ffffffffc02029c8 <commands+0xb98>
            cprintf("块 p 的页数为: %d\n\n", p->property);
ffffffffc0200fa4:	00002b97          	auipc	s7,0x2
ffffffffc0200fa8:	bc4b8b93          	addi	s7,s7,-1084 # ffffffffc0202b68 <commands+0xd38>
                size_t relative_addr = (size_t)base - MEM_BEGIN; // 计算 base 的相对起始地址
ffffffffc0200fac:	e43e                	sd	a5,8(sp)
    while (merged && base->property < MAX_INIT_PAGES) {
ffffffffc0200fae:	481c                	lw	a5,16(s0)
ffffffffc0200fb0:	0b47fb63          	bleu	s4,a5,ffffffffc0201066 <buddy_system_free_pages+0x1be>
        cprintf("当前块的地址为: 0x%016lx.\n", base);
ffffffffc0200fb4:	85a2                	mv	a1,s0
ffffffffc0200fb6:	855a                	mv	a0,s6
ffffffffc0200fb8:	8feff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        cprintf("当前块的页数为: %d\n\n", base->property);
ffffffffc0200fbc:	480c                	lw	a1,16(s0)
ffffffffc0200fbe:	8556                	mv	a0,s5
ffffffffc0200fc0:	8f6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return listelm->prev;
ffffffffc0200fc4:	01843d83          	ld	s11,24(s0)
        if (le != &free_list) {
ffffffffc0200fc8:	049d8263          	beq	s11,s1,ffffffffc020100c <buddy_system_free_pages+0x164>
            cprintf("找到 base 前面的块 p\n");
ffffffffc0200fcc:	00002517          	auipc	a0,0x2
ffffffffc0200fd0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02029a8 <commands+0xb78>
ffffffffc0200fd4:	8e2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            struct Page *p = le2page(le, page_link);
ffffffffc0200fd8:	fe8d8d13          	addi	s10,s11,-24
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
ffffffffc0200fdc:	85ea                	mv	a1,s10
ffffffffc0200fde:	854e                	mv	a0,s3
ffffffffc0200fe0:	8d6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("块 p 的页数为: %d\n", p->property);
ffffffffc0200fe4:	ff8da583          	lw	a1,-8(s11)
ffffffffc0200fe8:	00002517          	auipc	a0,0x2
ffffffffc0200fec:	a0050513          	addi	a0,a0,-1536 # ffffffffc02029e8 <commands+0xbb8>
ffffffffc0200ff0:	8c6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            if (p + p->property == base && p->property == base->property) {// 前一空闲块和当前块大小相同
ffffffffc0200ff4:	ff8da683          	lw	a3,-8(s11)
ffffffffc0200ff8:	02069713          	slli	a4,a3,0x20
ffffffffc0200ffc:	9301                	srli	a4,a4,0x20
ffffffffc0200ffe:	00271793          	slli	a5,a4,0x2
ffffffffc0201002:	97ba                	add	a5,a5,a4
ffffffffc0201004:	078e                	slli	a5,a5,0x3
ffffffffc0201006:	97ea                	add	a5,a5,s10
ffffffffc0201008:	16f40363          	beq	s0,a5,ffffffffc020116e <buddy_system_free_pages+0x2c6>
    return listelm->next;
ffffffffc020100c:	02043c83          	ld	s9,32(s0)
        if (le != &free_list) {
ffffffffc0201010:	129c8b63          	beq	s9,s1,ffffffffc0201146 <buddy_system_free_pages+0x29e>
            cprintf("找到 base 后面的块 p\n");
ffffffffc0201014:	8562                	mv	a0,s8
ffffffffc0201016:	8a0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            struct Page *p = le2page(le, page_link);
ffffffffc020101a:	fe8c8913          	addi	s2,s9,-24
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
ffffffffc020101e:	85ca                	mv	a1,s2
ffffffffc0201020:	854e                	mv	a0,s3
ffffffffc0201022:	894ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("块 p 的页数为: %d\n\n", p->property);
ffffffffc0201026:	ff8ca583          	lw	a1,-8(s9)
ffffffffc020102a:	855e                	mv	a0,s7
ffffffffc020102c:	88aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            if (base + base->property == p && base->property == p->property) {// 当前块和后一空闲块大小相同
ffffffffc0201030:	4810                	lw	a2,16(s0)
ffffffffc0201032:	02061693          	slli	a3,a2,0x20
ffffffffc0201036:	9281                	srli	a3,a3,0x20
ffffffffc0201038:	00269793          	slli	a5,a3,0x2
ffffffffc020103c:	97b6                	add	a5,a5,a3
ffffffffc020103e:	078e                	slli	a5,a5,0x3
ffffffffc0201040:	97a2                	add	a5,a5,s0
ffffffffc0201042:	10f91263          	bne	s2,a5,ffffffffc0201146 <buddy_system_free_pages+0x29e>
ffffffffc0201046:	4d01                	li	s10,0
ffffffffc0201048:	ff8ca783          	lw	a5,-8(s9)
ffffffffc020104c:	04c78663          	beq	a5,a2,ffffffffc0201098 <buddy_system_free_pages+0x1f0>
        if(!merged){
ffffffffc0201050:	0e0d0b63          	beqz	s10,ffffffffc0201146 <buddy_system_free_pages+0x29e>
            cprintf("继续尝试合并……\n\n");
ffffffffc0201054:	00002517          	auipc	a0,0x2
ffffffffc0201058:	aac50513          	addi	a0,a0,-1364 # ffffffffc0202b00 <commands+0xcd0>
ffffffffc020105c:	85aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    while (merged && base->property < MAX_INIT_PAGES) {
ffffffffc0201060:	481c                	lw	a5,16(s0)
ffffffffc0201062:	f547e9e3          	bltu	a5,s4,ffffffffc0200fb4 <buddy_system_free_pages+0x10c>
}
ffffffffc0201066:	70e6                	ld	ra,120(sp)
ffffffffc0201068:	7446                	ld	s0,112(sp)
ffffffffc020106a:	74a6                	ld	s1,104(sp)
ffffffffc020106c:	7906                	ld	s2,96(sp)
ffffffffc020106e:	69e6                	ld	s3,88(sp)
ffffffffc0201070:	6a46                	ld	s4,80(sp)
ffffffffc0201072:	6aa6                	ld	s5,72(sp)
ffffffffc0201074:	6b06                	ld	s6,64(sp)
ffffffffc0201076:	7be2                	ld	s7,56(sp)
ffffffffc0201078:	7c42                	ld	s8,48(sp)
ffffffffc020107a:	7ca2                	ld	s9,40(sp)
ffffffffc020107c:	7d02                	ld	s10,32(sp)
ffffffffc020107e:	6de2                	ld	s11,24(sp)
ffffffffc0201080:	6109                	addi	sp,sp,128
ffffffffc0201082:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201084:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0201086:	f004                	sd	s1,32(s0)
ffffffffc0201088:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020108a:	ec1c                	sd	a5,24(s0)
                list_add(le, &(base->page_link));
ffffffffc020108c:	8636                	mv	a2,a3
        while ((le = list_next(le)) != &free_list) {
ffffffffc020108e:	1a970363          	beq	a4,s1,ffffffffc0201234 <buddy_system_free_pages+0x38c>
ffffffffc0201092:	4585                	li	a1,1
ffffffffc0201094:	87ba                	mv	a5,a4
ffffffffc0201096:	b5e1                	j	ffffffffc0200f5e <buddy_system_free_pages+0xb6>
                cprintf("伙伴块的地址为: 0x%016lx.\n", p);
ffffffffc0201098:	85ca                	mv	a1,s2
ffffffffc020109a:	00002517          	auipc	a0,0x2
ffffffffc020109e:	96650513          	addi	a0,a0,-1690 # ffffffffc0202a00 <commands+0xbd0>
ffffffffc02010a2:	814ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                size_t relative_addr = (size_t)base - MEM_BEGIN; // 计算 base 的相对起始地址
ffffffffc02010a6:	67a2                	ld	a5,8(sp)
                cprintf("伙伴块的页数为: %d\n", p->property);
ffffffffc02010a8:	ff8ca583          	lw	a1,-8(s9)
ffffffffc02010ac:	00002517          	auipc	a0,0x2
ffffffffc02010b0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0202a28 <commands+0xbf8>
                size_t relative_addr = (size_t)base - MEM_BEGIN; // 计算 base 的相对起始地址
ffffffffc02010b4:	00f40933          	add	s2,s0,a5
                cprintf("伙伴块的页数为: %d\n", p->property);
ffffffffc02010b8:	ffffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                cprintf("合并后的相对首地址为: 0x%016lx.\n", relative_addr);
ffffffffc02010bc:	85ca                	mv	a1,s2
ffffffffc02010be:	00002517          	auipc	a0,0x2
ffffffffc02010c2:	98a50513          	addi	a0,a0,-1654 # ffffffffc0202a48 <commands+0xc18>
ffffffffc02010c6:	ff1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                size_t block_size = (base->property << 1) * sizeof(struct Page);//合并后的块大小
ffffffffc02010ca:	481c                	lw	a5,16(s0)
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
ffffffffc02010cc:	00002517          	auipc	a0,0x2
ffffffffc02010d0:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0202a78 <commands+0xc48>
                size_t block_size = (base->property << 1) * sizeof(struct Page);//合并后的块大小
ffffffffc02010d4:	0017979b          	slliw	a5,a5,0x1
ffffffffc02010d8:	1782                	slli	a5,a5,0x20
ffffffffc02010da:	9381                	srli	a5,a5,0x20
ffffffffc02010dc:	00279d93          	slli	s11,a5,0x2
ffffffffc02010e0:	9dbe                	add	s11,s11,a5
ffffffffc02010e2:	0d8e                	slli	s11,s11,0x3
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
ffffffffc02010e4:	85ee                	mv	a1,s11
ffffffffc02010e6:	fd1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                if (relative_addr % block_size == 0) { // 如果合并后的相对首地址是合并后的块大小的整数倍
ffffffffc02010ea:	03b97933          	remu	s2,s2,s11
ffffffffc02010ee:	f60911e3          	bnez	s2,ffffffffc0201050 <buddy_system_free_pages+0x1a8>
                    cprintf("合并成功\n");
ffffffffc02010f2:	00002517          	auipc	a0,0x2
ffffffffc02010f6:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0202aa0 <commands+0xc70>
ffffffffc02010fa:	fbdfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                    base->property <<= 1;
ffffffffc02010fe:	481c                	lw	a5,16(s0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201100:	ff0c8713          	addi	a4,s9,-16
ffffffffc0201104:	0017979b          	slliw	a5,a5,0x1
ffffffffc0201108:	c81c                	sw	a5,16(s0)
ffffffffc020110a:	57f5                	li	a5,-3
ffffffffc020110c:	60f7302f          	amoand.d	zero,a5,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201110:	000cb683          	ld	a3,0(s9)
ffffffffc0201114:	008cb783          	ld	a5,8(s9)
                    cprintf("合并后的块的地址为: 0x%016lx.\n", base);
ffffffffc0201118:	85a2                	mv	a1,s0
ffffffffc020111a:	00002517          	auipc	a0,0x2
ffffffffc020111e:	99650513          	addi	a0,a0,-1642 # ffffffffc0202ab0 <commands+0xc80>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201122:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201124:	e394                	sd	a3,0(a5)
ffffffffc0201126:	f91fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                    cprintf("合并后的块的块页数为: %d\n\n", base->property);
ffffffffc020112a:	480c                	lw	a1,16(s0)
ffffffffc020112c:	00002517          	auipc	a0,0x2
ffffffffc0201130:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0202ad8 <commands+0xca8>
ffffffffc0201134:	f83fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("继续尝试合并……\n\n");
ffffffffc0201138:	00002517          	auipc	a0,0x2
ffffffffc020113c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0202b00 <commands+0xcd0>
ffffffffc0201140:	f77fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0201144:	b5ad                	j	ffffffffc0200fae <buddy_system_free_pages+0x106>
}
ffffffffc0201146:	7446                	ld	s0,112(sp)
ffffffffc0201148:	70e6                	ld	ra,120(sp)
ffffffffc020114a:	74a6                	ld	s1,104(sp)
ffffffffc020114c:	7906                	ld	s2,96(sp)
ffffffffc020114e:	69e6                	ld	s3,88(sp)
ffffffffc0201150:	6a46                	ld	s4,80(sp)
ffffffffc0201152:	6aa6                	ld	s5,72(sp)
ffffffffc0201154:	6b06                	ld	s6,64(sp)
ffffffffc0201156:	7be2                	ld	s7,56(sp)
ffffffffc0201158:	7c42                	ld	s8,48(sp)
ffffffffc020115a:	7ca2                	ld	s9,40(sp)
ffffffffc020115c:	7d02                	ld	s10,32(sp)
ffffffffc020115e:	6de2                	ld	s11,24(sp)
            cprintf("没有找到可以合并的伙伴块\n\n");
ffffffffc0201160:	00002517          	auipc	a0,0x2
ffffffffc0201164:	9c050513          	addi	a0,a0,-1600 # ffffffffc0202b20 <commands+0xcf0>
}
ffffffffc0201168:	6109                	addi	sp,sp,128
            cprintf("没有找到可以合并的伙伴块\n\n");
ffffffffc020116a:	f4dfe06f          	j	ffffffffc02000b6 <cprintf>
            if (p + p->property == base && p->property == base->property) {// 前一空闲块和当前块大小相同
ffffffffc020116e:	481c                	lw	a5,16(s0)
ffffffffc0201170:	e8d79ee3          	bne	a5,a3,ffffffffc020100c <buddy_system_free_pages+0x164>
                cprintf("伙伴块的地址为: 0x%016lx.\n", p);
ffffffffc0201174:	85ea                	mv	a1,s10
ffffffffc0201176:	00002517          	auipc	a0,0x2
ffffffffc020117a:	88a50513          	addi	a0,a0,-1910 # ffffffffc0202a00 <commands+0xbd0>
ffffffffc020117e:	f39fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                size_t relative_addr = (size_t)p - MEM_BEGIN; // 计算 p 的相对起始地址
ffffffffc0201182:	67a2                	ld	a5,8(sp)
                cprintf("伙伴块的页数为: %d\n", base->property);
ffffffffc0201184:	480c                	lw	a1,16(s0)
ffffffffc0201186:	00002517          	auipc	a0,0x2
ffffffffc020118a:	8a250513          	addi	a0,a0,-1886 # ffffffffc0202a28 <commands+0xbf8>
                size_t relative_addr = (size_t)p - MEM_BEGIN; // 计算 p 的相对起始地址
ffffffffc020118e:	00fd0933          	add	s2,s10,a5
                cprintf("伙伴块的页数为: %d\n", base->property);
ffffffffc0201192:	f25fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                cprintf("合并后的相对首地址为: 0x%016lx.\n", relative_addr);
ffffffffc0201196:	85ca                	mv	a1,s2
ffffffffc0201198:	00002517          	auipc	a0,0x2
ffffffffc020119c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0202a48 <commands+0xc18>
ffffffffc02011a0:	f17fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                size_t block_size = (p->property << 1) * sizeof(struct Page);//合并后的块大小
ffffffffc02011a4:	ff8da783          	lw	a5,-8(s11)
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
ffffffffc02011a8:	00002517          	auipc	a0,0x2
ffffffffc02011ac:	8d050513          	addi	a0,a0,-1840 # ffffffffc0202a78 <commands+0xc48>
                size_t block_size = (p->property << 1) * sizeof(struct Page);//合并后的块大小
ffffffffc02011b0:	0017979b          	slliw	a5,a5,0x1
ffffffffc02011b4:	02079713          	slli	a4,a5,0x20
ffffffffc02011b8:	9301                	srli	a4,a4,0x20
ffffffffc02011ba:	00271793          	slli	a5,a4,0x2
ffffffffc02011be:	97ba                	add	a5,a5,a4
ffffffffc02011c0:	00379c93          	slli	s9,a5,0x3
                cprintf("合并后的块大小为: 0x%016lx.\n", block_size);
ffffffffc02011c4:	85e6                	mv	a1,s9
ffffffffc02011c6:	ef1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                if (relative_addr % block_size == 0) { // 如果合并后的相对首地址是合并后的块大小的整数倍
ffffffffc02011ca:	03997933          	remu	s2,s2,s9
ffffffffc02011ce:	e2091fe3          	bnez	s2,ffffffffc020100c <buddy_system_free_pages+0x164>
                    cprintf("合并成功\n");
ffffffffc02011d2:	00002517          	auipc	a0,0x2
ffffffffc02011d6:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0202aa0 <commands+0xc70>
ffffffffc02011da:	eddfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                    p->property <<= 1;
ffffffffc02011de:	ff8da783          	lw	a5,-8(s11)
ffffffffc02011e2:	00840713          	addi	a4,s0,8
ffffffffc02011e6:	0017979b          	slliw	a5,a5,0x1
ffffffffc02011ea:	fefdac23          	sw	a5,-8(s11)
ffffffffc02011ee:	57f5                	li	a5,-3
ffffffffc02011f0:	60f7302f          	amoand.d	zero,a5,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011f4:	6c18                	ld	a4,24(s0)
ffffffffc02011f6:	701c                	ld	a5,32(s0)
                    cprintf("合并后的块的地址为: 0x%016lx.\n", base);
ffffffffc02011f8:	85ea                	mv	a1,s10
ffffffffc02011fa:	00002517          	auipc	a0,0x2
ffffffffc02011fe:	8b650513          	addi	a0,a0,-1866 # ffffffffc0202ab0 <commands+0xc80>
    prev->next = next;
ffffffffc0201202:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201204:	e398                	sd	a4,0(a5)
ffffffffc0201206:	eb1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                    cprintf("合并后的块的块页数为: %d\n\n", base->property);
ffffffffc020120a:	ff8da583          	lw	a1,-8(s11)
ffffffffc020120e:	00002517          	auipc	a0,0x2
ffffffffc0201212:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0202ad8 <commands+0xca8>
ffffffffc0201216:	ea1fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return listelm->next;
ffffffffc020121a:	008dbc83          	ld	s9,8(s11)
        if (le != &free_list) {
ffffffffc020121e:	029c9d63          	bne	s9,s1,ffffffffc0201258 <buddy_system_free_pages+0x3b0>
            if (base + base->property == p && base->property == p->property) {// 当前块和后一空闲块大小相同
ffffffffc0201222:	846a                	mv	s0,s10
ffffffffc0201224:	bd05                	j	ffffffffc0201054 <buddy_system_free_pages+0x1ac>
        list_add(&free_list, &(base->page_link));
ffffffffc0201226:	01840793          	addi	a5,s0,24
    prev->next = next->prev = elm;
ffffffffc020122a:	e09c                	sd	a5,0(s1)
ffffffffc020122c:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc020122e:	f004                	sd	s1,32(s0)
    elm->prev = prev;
ffffffffc0201230:	ec04                	sd	s1,24(s0)
ffffffffc0201232:	b3a1                	j	ffffffffc0200f7a <buddy_system_free_pages+0xd2>
ffffffffc0201234:	e094                	sd	a3,0(s1)
ffffffffc0201236:	b391                	j	ffffffffc0200f7a <buddy_system_free_pages+0xd2>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201238:	00001697          	auipc	a3,0x1
ffffffffc020123c:	70068693          	addi	a3,a3,1792 # ffffffffc0202938 <commands+0xb08>
ffffffffc0201240:	00001617          	auipc	a2,0x1
ffffffffc0201244:	32060613          	addi	a2,a2,800 # ffffffffc0202560 <commands+0x730>
ffffffffc0201248:	06800593          	li	a1,104
ffffffffc020124c:	00001517          	auipc	a0,0x1
ffffffffc0201250:	32c50513          	addi	a0,a0,812 # ffffffffc0202578 <commands+0x748>
ffffffffc0201254:	eebfe0ef          	jal	ra,ffffffffc020013e <__panic>
            cprintf("找到 base 后面的块 p\n");
ffffffffc0201258:	8562                	mv	a0,s8
ffffffffc020125a:	e5dfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            struct Page *p = le2page(le, page_link);
ffffffffc020125e:	fe8c8913          	addi	s2,s9,-24
            cprintf("块 p 的地址为: 0x%016lx.\n", p);
ffffffffc0201262:	85ca                	mv	a1,s2
ffffffffc0201264:	854e                	mv	a0,s3
ffffffffc0201266:	e51fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("块 p 的页数为: %d\n\n", p->property);
ffffffffc020126a:	ff8ca583          	lw	a1,-8(s9)
ffffffffc020126e:	855e                	mv	a0,s7
ffffffffc0201270:	e47fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            if (base + base->property == p && base->property == p->property) {// 当前块和后一空闲块大小相同
ffffffffc0201274:	ff8da603          	lw	a2,-8(s11)
ffffffffc0201278:	02800693          	li	a3,40
ffffffffc020127c:	02061793          	slli	a5,a2,0x20
ffffffffc0201280:	9381                	srli	a5,a5,0x20
ffffffffc0201282:	02d787b3          	mul	a5,a5,a3
ffffffffc0201286:	97ea                	add	a5,a5,s10
ffffffffc0201288:	f8f91de3          	bne	s2,a5,ffffffffc0201222 <buddy_system_free_pages+0x37a>
ffffffffc020128c:	846a                	mv	s0,s10
                    merged = 1; // 标记为合并
ffffffffc020128e:	4d05                	li	s10,1
ffffffffc0201290:	bb65                	j	ffffffffc0201048 <buddy_system_free_pages+0x1a0>
    assert(n > 0);
ffffffffc0201292:	00001697          	auipc	a3,0x1
ffffffffc0201296:	69e68693          	addi	a3,a3,1694 # ffffffffc0202930 <commands+0xb00>
ffffffffc020129a:	00001617          	auipc	a2,0x1
ffffffffc020129e:	2c660613          	addi	a2,a2,710 # ffffffffc0202560 <commands+0x730>
ffffffffc02012a2:	06200593          	li	a1,98
ffffffffc02012a6:	00001517          	auipc	a0,0x1
ffffffffc02012aa:	2d250513          	addi	a0,a0,722 # ffffffffc0202578 <commands+0x748>
ffffffffc02012ae:	e91fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02012b2 <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t n) {
ffffffffc02012b2:	7179                	addi	sp,sp,-48
ffffffffc02012b4:	f406                	sd	ra,40(sp)
ffffffffc02012b6:	f022                	sd	s0,32(sp)
ffffffffc02012b8:	ec26                	sd	s1,24(sp)
ffffffffc02012ba:	e84a                	sd	s2,16(sp)
ffffffffc02012bc:	e44e                	sd	s3,8(sp)
    assert(n > 0);
ffffffffc02012be:	10050563          	beqz	a0,ffffffffc02013c8 <buddy_system_alloc_pages+0x116>
    size_t size = 1;
ffffffffc02012c2:	4485                	li	s1,1
    while (size < n) {
ffffffffc02012c4:	00a4f563          	bleu	a0,s1,ffffffffc02012ce <buddy_system_alloc_pages+0x1c>
        size <<= 1;
ffffffffc02012c8:	0486                	slli	s1,s1,0x1
    while (size < n) {
ffffffffc02012ca:	fea4efe3          	bltu	s1,a0,ffffffffc02012c8 <buddy_system_alloc_pages+0x16>
    if (n > nr_free) {
ffffffffc02012ce:	00005917          	auipc	s2,0x5
ffffffffc02012d2:	16a90913          	addi	s2,s2,362 # ffffffffc0206438 <free_area>
ffffffffc02012d6:	00005797          	auipc	a5,0x5
ffffffffc02012da:	1727e783          	lwu	a5,370(a5) # ffffffffc0206448 <free_area+0x10>
    list_entry_t *le = &free_list;
ffffffffc02012de:	844a                	mv	s0,s2
    if (n > nr_free) {
ffffffffc02012e0:	0097f763          	bleu	s1,a5,ffffffffc02012ee <buddy_system_alloc_pages+0x3c>
ffffffffc02012e4:	a801                	j	ffffffffc02012f4 <buddy_system_alloc_pages+0x42>
        if (p->property >= n) {
ffffffffc02012e6:	ff846783          	lwu	a5,-8(s0)
ffffffffc02012ea:	0097fe63          	bleu	s1,a5,ffffffffc0201306 <buddy_system_alloc_pages+0x54>
    return listelm->next;
ffffffffc02012ee:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02012f0:	ff241be3          	bne	s0,s2,ffffffffc02012e6 <buddy_system_alloc_pages+0x34>
}
ffffffffc02012f4:	70a2                	ld	ra,40(sp)
ffffffffc02012f6:	7402                	ld	s0,32(sp)
        return NULL;// 如果请求的页数大于可用页数，返回 NULL
ffffffffc02012f8:	4981                	li	s3,0
}
ffffffffc02012fa:	854e                	mv	a0,s3
ffffffffc02012fc:	64e2                	ld	s1,24(sp)
ffffffffc02012fe:	6942                	ld	s2,16(sp)
ffffffffc0201300:	69a2                	ld	s3,8(sp)
ffffffffc0201302:	6145                	addi	sp,sp,48
ffffffffc0201304:	8082                	ret
            cprintf("找到第一个满足要求的空闲块 p\n");
ffffffffc0201306:	00001517          	auipc	a0,0x1
ffffffffc020130a:	13a50513          	addi	a0,a0,314 # ffffffffc0202440 <commands+0x610>
ffffffffc020130e:	da9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        struct Page *p = le2page(le, page_link);
ffffffffc0201312:	fe840993          	addi	s3,s0,-24
            cprintf("准备用于分配的空闲块 p 的地址为: 0x%016lx.\n", p);
ffffffffc0201316:	85ce                	mv	a1,s3
ffffffffc0201318:	00001517          	auipc	a0,0x1
ffffffffc020131c:	15850513          	addi	a0,a0,344 # ffffffffc0202470 <commands+0x640>
ffffffffc0201320:	d97fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("准备分配的空闲块 p 的页数为: %d\n", p->property);
ffffffffc0201324:	ff842583          	lw	a1,-8(s0)
ffffffffc0201328:	00001517          	auipc	a0,0x1
ffffffffc020132c:	18850513          	addi	a0,a0,392 # ffffffffc02024b0 <commands+0x680>
ffffffffc0201330:	d87fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (page != NULL) {
ffffffffc0201334:	fc0980e3          	beqz	s3,ffffffffc02012f4 <buddy_system_alloc_pages+0x42>
        cprintf("开始分裂空闲块……\n\n");
ffffffffc0201338:	00001517          	auipc	a0,0x1
ffffffffc020133c:	1a850513          	addi	a0,a0,424 # ffffffffc02024e0 <commands+0x6b0>
ffffffffc0201340:	d77fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201344:	641c                	ld	a5,8(s0)
    return listelm->prev;
ffffffffc0201346:	6014                	ld	a3,0(s0)
        while (page->property > n) {
ffffffffc0201348:	ff842703          	lw	a4,-8(s0)
    prev->next = next;
ffffffffc020134c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020134e:	e394                	sd	a3,0(a5)
ffffffffc0201350:	02071793          	slli	a5,a4,0x20
ffffffffc0201354:	9381                	srli	a5,a5,0x20
ffffffffc0201356:	04f4f463          	bleu	a5,s1,ffffffffc020139e <buddy_system_alloc_pages+0xec>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020135a:	4509                	li	a0,2
            struct Page *p = page + (page->property >> 1);// 分裂当前空闲块成两个块
ffffffffc020135c:	0017571b          	srliw	a4,a4,0x1
ffffffffc0201360:	02071613          	slli	a2,a4,0x20
ffffffffc0201364:	9201                	srli	a2,a2,0x20
ffffffffc0201366:	00261793          	slli	a5,a2,0x2
ffffffffc020136a:	97b2                	add	a5,a5,a2
ffffffffc020136c:	078e                	slli	a5,a5,0x3
ffffffffc020136e:	97ce                	add	a5,a5,s3
            p->property = page->property >> 1;// 设置 p 的大小为空闲块的一半
ffffffffc0201370:	cb98                	sw	a4,16(a5)
ffffffffc0201372:	00878713          	addi	a4,a5,8
ffffffffc0201376:	40a7302f          	amoor.d	zero,a0,(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc020137a:	6690                	ld	a2,8(a3)
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc020137c:	ff842703          	lw	a4,-8(s0)
            list_add(prev, &(p->page_link));// 将 p 插入到空闲块链表中
ffffffffc0201380:	01878593          	addi	a1,a5,24
    prev->next = next->prev = elm;
ffffffffc0201384:	e20c                	sd	a1,0(a2)
ffffffffc0201386:	e68c                	sd	a1,8(a3)
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc0201388:	0017571b          	srliw	a4,a4,0x1
    elm->next = next;
ffffffffc020138c:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc020138e:	ef94                	sd	a3,24(a5)
        while (page->property > n) {
ffffffffc0201390:	02071793          	slli	a5,a4,0x20
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc0201394:	fee42c23          	sw	a4,-8(s0)
        while (page->property > n) {
ffffffffc0201398:	9381                	srli	a5,a5,0x20
ffffffffc020139a:	fcf4e1e3          	bltu	s1,a5,ffffffffc020135c <buddy_system_alloc_pages+0xaa>
        nr_free -= n;// 更新空闲页计数器
ffffffffc020139e:	01092783          	lw	a5,16(s2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013a2:	ff040713          	addi	a4,s0,-16
ffffffffc02013a6:	409784bb          	subw	s1,a5,s1
ffffffffc02013aa:	00005797          	auipc	a5,0x5
ffffffffc02013ae:	0897af23          	sw	s1,158(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc02013b2:	57f5                	li	a5,-3
ffffffffc02013b4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02013b8:	70a2                	ld	ra,40(sp)
ffffffffc02013ba:	7402                	ld	s0,32(sp)
ffffffffc02013bc:	854e                	mv	a0,s3
ffffffffc02013be:	64e2                	ld	s1,24(sp)
ffffffffc02013c0:	6942                	ld	s2,16(sp)
ffffffffc02013c2:	69a2                	ld	s3,8(sp)
ffffffffc02013c4:	6145                	addi	sp,sp,48
ffffffffc02013c6:	8082                	ret
    assert(n > 0);
ffffffffc02013c8:	00001697          	auipc	a3,0x1
ffffffffc02013cc:	56868693          	addi	a3,a3,1384 # ffffffffc0202930 <commands+0xb00>
ffffffffc02013d0:	00001617          	auipc	a2,0x1
ffffffffc02013d4:	19060613          	addi	a2,a2,400 # ffffffffc0202560 <commands+0x730>
ffffffffc02013d8:	03b00593          	li	a1,59
ffffffffc02013dc:	00001517          	auipc	a0,0x1
ffffffffc02013e0:	19c50513          	addi	a0,a0,412 # ffffffffc0202578 <commands+0x748>
ffffffffc02013e4:	d5bfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02013e8 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc02013e8:	1141                	addi	sp,sp,-16
ffffffffc02013ea:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02013ec:	cdf1                	beqz	a1,ffffffffc02014c8 <buddy_system_init_memmap+0xe0>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013ee:	6518                	ld	a4,8(a0)
    for (; p != base + n; p ++) {
ffffffffc02013f0:	000a06b7          	lui	a3,0xa0
ffffffffc02013f4:	96aa                	add	a3,a3,a0
        assert(PageReserved(p));
ffffffffc02013f6:	8b05                	andi	a4,a4,1
ffffffffc02013f8:	87aa                	mv	a5,a0
ffffffffc02013fa:	e709                	bnez	a4,ffffffffc0201404 <buddy_system_init_memmap+0x1c>
ffffffffc02013fc:	a07d                	j	ffffffffc02014aa <buddy_system_init_memmap+0xc2>
ffffffffc02013fe:	6798                	ld	a4,8(a5)
ffffffffc0201400:	8b05                	andi	a4,a4,1
ffffffffc0201402:	c745                	beqz	a4,ffffffffc02014aa <buddy_system_init_memmap+0xc2>
        p->flags = p->property = 0;
ffffffffc0201404:	0007a823          	sw	zero,16(a5)
ffffffffc0201408:	0007b423          	sd	zero,8(a5)
ffffffffc020140c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201410:	02878793          	addi	a5,a5,40
ffffffffc0201414:	fed795e3          	bne	a5,a3,ffffffffc02013fe <buddy_system_init_memmap+0x16>
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
ffffffffc0201418:	6611                	lui	a2,0x4
ffffffffc020141a:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020141c:	4789                	li	a5,2
ffffffffc020141e:	00850713          	addi	a4,a0,8
ffffffffc0201422:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;// 更新空闲页计数器
ffffffffc0201426:	00005697          	auipc	a3,0x5
ffffffffc020142a:	01268693          	addi	a3,a3,18 # ffffffffc0206438 <free_area>
ffffffffc020142e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201430:	669c                	ld	a5,8(a3)
ffffffffc0201432:	9f31                	addw	a4,a4,a2
ffffffffc0201434:	00005617          	auipc	a2,0x5
ffffffffc0201438:	00e62a23          	sw	a4,20(a2) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020143c:	04d78a63          	beq	a5,a3,ffffffffc0201490 <buddy_system_init_memmap+0xa8>
            struct Page* page = le2page(le, page_link);
ffffffffc0201440:	fe878713          	addi	a4,a5,-24
ffffffffc0201444:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201446:	4801                	li	a6,0
ffffffffc0201448:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020144c:	00e56a63          	bltu	a0,a4,ffffffffc0201460 <buddy_system_init_memmap+0x78>
    return listelm->next;
ffffffffc0201450:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201452:	02d70563          	beq	a4,a3,ffffffffc020147c <buddy_system_init_memmap+0x94>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201456:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201458:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020145c:	fee57ae3          	bleu	a4,a0,ffffffffc0201450 <buddy_system_init_memmap+0x68>
ffffffffc0201460:	00080663          	beqz	a6,ffffffffc020146c <buddy_system_init_memmap+0x84>
ffffffffc0201464:	00005717          	auipc	a4,0x5
ffffffffc0201468:	fcb73a23          	sd	a1,-44(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020146c:	6398                	ld	a4,0(a5)
}
ffffffffc020146e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201470:	e390                	sd	a2,0(a5)
ffffffffc0201472:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201474:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201476:	ed18                	sd	a4,24(a0)
ffffffffc0201478:	0141                	addi	sp,sp,16
ffffffffc020147a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020147c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020147e:	f114                	sd	a3,32(a0)
ffffffffc0201480:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201482:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201484:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201486:	00d70e63          	beq	a4,a3,ffffffffc02014a2 <buddy_system_init_memmap+0xba>
ffffffffc020148a:	4805                	li	a6,1
ffffffffc020148c:	87ba                	mv	a5,a4
ffffffffc020148e:	b7e9                	j	ffffffffc0201458 <buddy_system_init_memmap+0x70>
}
ffffffffc0201490:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201492:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201496:	e398                	sd	a4,0(a5)
ffffffffc0201498:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020149a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020149c:	ed1c                	sd	a5,24(a0)
}
ffffffffc020149e:	0141                	addi	sp,sp,16
ffffffffc02014a0:	8082                	ret
ffffffffc02014a2:	60a2                	ld	ra,8(sp)
ffffffffc02014a4:	e290                	sd	a2,0(a3)
ffffffffc02014a6:	0141                	addi	sp,sp,16
ffffffffc02014a8:	8082                	ret
        assert(PageReserved(p));
ffffffffc02014aa:	00001697          	auipc	a3,0x1
ffffffffc02014ae:	6de68693          	addi	a3,a3,1758 # ffffffffc0202b88 <commands+0xd58>
ffffffffc02014b2:	00001617          	auipc	a2,0x1
ffffffffc02014b6:	0ae60613          	addi	a2,a2,174 # ffffffffc0202560 <commands+0x730>
ffffffffc02014ba:	45e5                	li	a1,25
ffffffffc02014bc:	00001517          	auipc	a0,0x1
ffffffffc02014c0:	0bc50513          	addi	a0,a0,188 # ffffffffc0202578 <commands+0x748>
ffffffffc02014c4:	c7bfe0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc02014c8:	00001697          	auipc	a3,0x1
ffffffffc02014cc:	46868693          	addi	a3,a3,1128 # ffffffffc0202930 <commands+0xb00>
ffffffffc02014d0:	00001617          	auipc	a2,0x1
ffffffffc02014d4:	09060613          	addi	a2,a2,144 # ffffffffc0202560 <commands+0x730>
ffffffffc02014d8:	45d1                	li	a1,20
ffffffffc02014da:	00001517          	auipc	a0,0x1
ffffffffc02014de:	09e50513          	addi	a0,a0,158 # ffffffffc0202578 <commands+0x748>
ffffffffc02014e2:	c5dfe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc02014e6 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014e6:	100027f3          	csrr	a5,sstatus
ffffffffc02014ea:	8b89                	andi	a5,a5,2
ffffffffc02014ec:	eb89                	bnez	a5,ffffffffc02014fe <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02014ee:	00005797          	auipc	a5,0x5
ffffffffc02014f2:	f6a78793          	addi	a5,a5,-150 # ffffffffc0206458 <pmm_manager>
ffffffffc02014f6:	639c                	ld	a5,0(a5)
ffffffffc02014f8:	0187b303          	ld	t1,24(a5)
ffffffffc02014fc:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02014fe:	1141                	addi	sp,sp,-16
ffffffffc0201500:	e406                	sd	ra,8(sp)
ffffffffc0201502:	e022                	sd	s0,0(sp)
ffffffffc0201504:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201506:	f5ffe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020150a:	00005797          	auipc	a5,0x5
ffffffffc020150e:	f4e78793          	addi	a5,a5,-178 # ffffffffc0206458 <pmm_manager>
ffffffffc0201512:	639c                	ld	a5,0(a5)
ffffffffc0201514:	8522                	mv	a0,s0
ffffffffc0201516:	6f9c                	ld	a5,24(a5)
ffffffffc0201518:	9782                	jalr	a5
ffffffffc020151a:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020151c:	f43fe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201520:	8522                	mv	a0,s0
ffffffffc0201522:	60a2                	ld	ra,8(sp)
ffffffffc0201524:	6402                	ld	s0,0(sp)
ffffffffc0201526:	0141                	addi	sp,sp,16
ffffffffc0201528:	8082                	ret

ffffffffc020152a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020152a:	100027f3          	csrr	a5,sstatus
ffffffffc020152e:	8b89                	andi	a5,a5,2
ffffffffc0201530:	eb89                	bnez	a5,ffffffffc0201542 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201532:	00005797          	auipc	a5,0x5
ffffffffc0201536:	f2678793          	addi	a5,a5,-218 # ffffffffc0206458 <pmm_manager>
ffffffffc020153a:	639c                	ld	a5,0(a5)
ffffffffc020153c:	0207b303          	ld	t1,32(a5)
ffffffffc0201540:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201542:	1101                	addi	sp,sp,-32
ffffffffc0201544:	ec06                	sd	ra,24(sp)
ffffffffc0201546:	e822                	sd	s0,16(sp)
ffffffffc0201548:	e426                	sd	s1,8(sp)
ffffffffc020154a:	842a                	mv	s0,a0
ffffffffc020154c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020154e:	f17fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201552:	00005797          	auipc	a5,0x5
ffffffffc0201556:	f0678793          	addi	a5,a5,-250 # ffffffffc0206458 <pmm_manager>
ffffffffc020155a:	639c                	ld	a5,0(a5)
ffffffffc020155c:	85a6                	mv	a1,s1
ffffffffc020155e:	8522                	mv	a0,s0
ffffffffc0201560:	739c                	ld	a5,32(a5)
ffffffffc0201562:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201564:	6442                	ld	s0,16(sp)
ffffffffc0201566:	60e2                	ld	ra,24(sp)
ffffffffc0201568:	64a2                	ld	s1,8(sp)
ffffffffc020156a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020156c:	ef3fe06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201570 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201570:	100027f3          	csrr	a5,sstatus
ffffffffc0201574:	8b89                	andi	a5,a5,2
ffffffffc0201576:	eb89                	bnez	a5,ffffffffc0201588 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201578:	00005797          	auipc	a5,0x5
ffffffffc020157c:	ee078793          	addi	a5,a5,-288 # ffffffffc0206458 <pmm_manager>
ffffffffc0201580:	639c                	ld	a5,0(a5)
ffffffffc0201582:	0287b303          	ld	t1,40(a5)
ffffffffc0201586:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201588:	1141                	addi	sp,sp,-16
ffffffffc020158a:	e406                	sd	ra,8(sp)
ffffffffc020158c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020158e:	ed7fe0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201592:	00005797          	auipc	a5,0x5
ffffffffc0201596:	ec678793          	addi	a5,a5,-314 # ffffffffc0206458 <pmm_manager>
ffffffffc020159a:	639c                	ld	a5,0(a5)
ffffffffc020159c:	779c                	ld	a5,40(a5)
ffffffffc020159e:	9782                	jalr	a5
ffffffffc02015a0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02015a2:	ebdfe0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02015a6:	8522                	mv	a0,s0
ffffffffc02015a8:	60a2                	ld	ra,8(sp)
ffffffffc02015aa:	6402                	ld	s0,0(sp)
ffffffffc02015ac:	0141                	addi	sp,sp,16
ffffffffc02015ae:	8082                	ret

ffffffffc02015b0 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc02015b0:	00001797          	auipc	a5,0x1
ffffffffc02015b4:	5e878793          	addi	a5,a5,1512 # ffffffffc0202b98 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02015b8:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02015ba:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02015bc:	00001517          	auipc	a0,0x1
ffffffffc02015c0:	63450513          	addi	a0,a0,1588 # ffffffffc0202bf0 <buddy_system_pmm_manager+0x58>
void pmm_init(void) {
ffffffffc02015c4:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc02015c6:	00005717          	auipc	a4,0x5
ffffffffc02015ca:	e8f73923          	sd	a5,-366(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc02015ce:	e822                	sd	s0,16(sp)
ffffffffc02015d0:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc02015d2:	00005417          	auipc	s0,0x5
ffffffffc02015d6:	e8640413          	addi	s0,s0,-378 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02015da:	addfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02015de:	601c                	ld	a5,0(s0)
ffffffffc02015e0:	679c                	ld	a5,8(a5)
ffffffffc02015e2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02015e4:	57f5                	li	a5,-3
ffffffffc02015e6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02015e8:	00001517          	auipc	a0,0x1
ffffffffc02015ec:	62050513          	addi	a0,a0,1568 # ffffffffc0202c08 <buddy_system_pmm_manager+0x70>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02015f0:	00005717          	auipc	a4,0x5
ffffffffc02015f4:	e6f73823          	sd	a5,-400(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02015f8:	abffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02015fc:	46c5                	li	a3,17
ffffffffc02015fe:	06ee                	slli	a3,a3,0x1b
ffffffffc0201600:	40100613          	li	a2,1025
ffffffffc0201604:	16fd                	addi	a3,a3,-1
ffffffffc0201606:	0656                	slli	a2,a2,0x15
ffffffffc0201608:	07e005b7          	lui	a1,0x7e00
ffffffffc020160c:	00001517          	auipc	a0,0x1
ffffffffc0201610:	61450513          	addi	a0,a0,1556 # ffffffffc0202c20 <buddy_system_pmm_manager+0x88>
ffffffffc0201614:	aa3fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201618:	777d                	lui	a4,0xfffff
ffffffffc020161a:	00006797          	auipc	a5,0x6
ffffffffc020161e:	e5578793          	addi	a5,a5,-427 # ffffffffc020746f <end+0xfff>
ffffffffc0201622:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201624:	00088737          	lui	a4,0x88
ffffffffc0201628:	00005697          	auipc	a3,0x5
ffffffffc020162c:	dee6b823          	sd	a4,-528(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201630:	4601                	li	a2,0
ffffffffc0201632:	00005717          	auipc	a4,0x5
ffffffffc0201636:	e2f73b23          	sd	a5,-458(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020163a:	4681                	li	a3,0
ffffffffc020163c:	00005897          	auipc	a7,0x5
ffffffffc0201640:	ddc88893          	addi	a7,a7,-548 # ffffffffc0206418 <npage>
ffffffffc0201644:	00005597          	auipc	a1,0x5
ffffffffc0201648:	e2458593          	addi	a1,a1,-476 # ffffffffc0206468 <pages>
ffffffffc020164c:	4805                	li	a6,1
ffffffffc020164e:	fff80537          	lui	a0,0xfff80
ffffffffc0201652:	a011                	j	ffffffffc0201656 <pmm_init+0xa6>
ffffffffc0201654:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201656:	97b2                	add	a5,a5,a2
ffffffffc0201658:	07a1                	addi	a5,a5,8
ffffffffc020165a:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020165e:	0008b703          	ld	a4,0(a7)
ffffffffc0201662:	0685                	addi	a3,a3,1
ffffffffc0201664:	02860613          	addi	a2,a2,40
ffffffffc0201668:	00a707b3          	add	a5,a4,a0
ffffffffc020166c:	fef6e4e3          	bltu	a3,a5,ffffffffc0201654 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201670:	6190                	ld	a2,0(a1)
ffffffffc0201672:	00271793          	slli	a5,a4,0x2
ffffffffc0201676:	97ba                	add	a5,a5,a4
ffffffffc0201678:	fec006b7          	lui	a3,0xfec00
ffffffffc020167c:	078e                	slli	a5,a5,0x3
ffffffffc020167e:	96b2                	add	a3,a3,a2
ffffffffc0201680:	96be                	add	a3,a3,a5
ffffffffc0201682:	c02007b7          	lui	a5,0xc0200
ffffffffc0201686:	08f6e863          	bltu	a3,a5,ffffffffc0201716 <pmm_init+0x166>
ffffffffc020168a:	00005497          	auipc	s1,0x5
ffffffffc020168e:	dd648493          	addi	s1,s1,-554 # ffffffffc0206460 <va_pa_offset>
ffffffffc0201692:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201694:	45c5                	li	a1,17
ffffffffc0201696:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201698:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc020169a:	04b6e963          	bltu	a3,a1,ffffffffc02016ec <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020169e:	601c                	ld	a5,0(s0)
ffffffffc02016a0:	7b9c                	ld	a5,48(a5)
ffffffffc02016a2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02016a4:	00001517          	auipc	a0,0x1
ffffffffc02016a8:	61450513          	addi	a0,a0,1556 # ffffffffc0202cb8 <buddy_system_pmm_manager+0x120>
ffffffffc02016ac:	a0bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02016b0:	00004697          	auipc	a3,0x4
ffffffffc02016b4:	95068693          	addi	a3,a3,-1712 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02016b8:	00005797          	auipc	a5,0x5
ffffffffc02016bc:	d6d7b423          	sd	a3,-664(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02016c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02016c4:	06f6e563          	bltu	a3,a5,ffffffffc020172e <pmm_init+0x17e>
ffffffffc02016c8:	609c                	ld	a5,0(s1)
}
ffffffffc02016ca:	6442                	ld	s0,16(sp)
ffffffffc02016cc:	60e2                	ld	ra,24(sp)
ffffffffc02016ce:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02016d0:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02016d2:	8e9d                	sub	a3,a3,a5
ffffffffc02016d4:	00005797          	auipc	a5,0x5
ffffffffc02016d8:	d6d7be23          	sd	a3,-644(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02016dc:	00001517          	auipc	a0,0x1
ffffffffc02016e0:	5fc50513          	addi	a0,a0,1532 # ffffffffc0202cd8 <buddy_system_pmm_manager+0x140>
ffffffffc02016e4:	8636                	mv	a2,a3
}
ffffffffc02016e6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02016e8:	9cffe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02016ec:	6785                	lui	a5,0x1
ffffffffc02016ee:	17fd                	addi	a5,a5,-1
ffffffffc02016f0:	96be                	add	a3,a3,a5
ffffffffc02016f2:	77fd                	lui	a5,0xfffff
ffffffffc02016f4:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02016f6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02016fa:	04e7f663          	bleu	a4,a5,ffffffffc0201746 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02016fe:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201700:	97aa                	add	a5,a5,a0
ffffffffc0201702:	00279513          	slli	a0,a5,0x2
ffffffffc0201706:	953e                	add	a0,a0,a5
ffffffffc0201708:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020170a:	8d95                	sub	a1,a1,a3
ffffffffc020170c:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020170e:	81b1                	srli	a1,a1,0xc
ffffffffc0201710:	9532                	add	a0,a0,a2
ffffffffc0201712:	9782                	jalr	a5
ffffffffc0201714:	b769                	j	ffffffffc020169e <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201716:	00001617          	auipc	a2,0x1
ffffffffc020171a:	53a60613          	addi	a2,a2,1338 # ffffffffc0202c50 <buddy_system_pmm_manager+0xb8>
ffffffffc020171e:	07000593          	li	a1,112
ffffffffc0201722:	00001517          	auipc	a0,0x1
ffffffffc0201726:	55650513          	addi	a0,a0,1366 # ffffffffc0202c78 <buddy_system_pmm_manager+0xe0>
ffffffffc020172a:	a15fe0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020172e:	00001617          	auipc	a2,0x1
ffffffffc0201732:	52260613          	addi	a2,a2,1314 # ffffffffc0202c50 <buddy_system_pmm_manager+0xb8>
ffffffffc0201736:	08b00593          	li	a1,139
ffffffffc020173a:	00001517          	auipc	a0,0x1
ffffffffc020173e:	53e50513          	addi	a0,a0,1342 # ffffffffc0202c78 <buddy_system_pmm_manager+0xe0>
ffffffffc0201742:	9fdfe0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201746:	00001617          	auipc	a2,0x1
ffffffffc020174a:	54260613          	addi	a2,a2,1346 # ffffffffc0202c88 <buddy_system_pmm_manager+0xf0>
ffffffffc020174e:	06b00593          	li	a1,107
ffffffffc0201752:	00001517          	auipc	a0,0x1
ffffffffc0201756:	55650513          	addi	a0,a0,1366 # ffffffffc0202ca8 <buddy_system_pmm_manager+0x110>
ffffffffc020175a:	9e5fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020175e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020175e:	c185                	beqz	a1,ffffffffc020177e <strnlen+0x20>
ffffffffc0201760:	00054783          	lbu	a5,0(a0)
ffffffffc0201764:	cf89                	beqz	a5,ffffffffc020177e <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201766:	4781                	li	a5,0
ffffffffc0201768:	a021                	j	ffffffffc0201770 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020176a:	00074703          	lbu	a4,0(a4)
ffffffffc020176e:	c711                	beqz	a4,ffffffffc020177a <strnlen+0x1c>
        cnt ++;
ffffffffc0201770:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201772:	00f50733          	add	a4,a0,a5
ffffffffc0201776:	fef59ae3          	bne	a1,a5,ffffffffc020176a <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020177a:	853e                	mv	a0,a5
ffffffffc020177c:	8082                	ret
    size_t cnt = 0;
ffffffffc020177e:	4781                	li	a5,0
}
ffffffffc0201780:	853e                	mv	a0,a5
ffffffffc0201782:	8082                	ret

ffffffffc0201784 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201784:	00054783          	lbu	a5,0(a0)
ffffffffc0201788:	0005c703          	lbu	a4,0(a1)
ffffffffc020178c:	cb91                	beqz	a5,ffffffffc02017a0 <strcmp+0x1c>
ffffffffc020178e:	00e79c63          	bne	a5,a4,ffffffffc02017a6 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201792:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201794:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201798:	0585                	addi	a1,a1,1
ffffffffc020179a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020179e:	fbe5                	bnez	a5,ffffffffc020178e <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017a0:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02017a2:	9d19                	subw	a0,a0,a4
ffffffffc02017a4:	8082                	ret
ffffffffc02017a6:	0007851b          	sext.w	a0,a5
ffffffffc02017aa:	9d19                	subw	a0,a0,a4
ffffffffc02017ac:	8082                	ret

ffffffffc02017ae <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02017ae:	00054783          	lbu	a5,0(a0)
ffffffffc02017b2:	cb91                	beqz	a5,ffffffffc02017c6 <strchr+0x18>
        if (*s == c) {
ffffffffc02017b4:	00b79563          	bne	a5,a1,ffffffffc02017be <strchr+0x10>
ffffffffc02017b8:	a809                	j	ffffffffc02017ca <strchr+0x1c>
ffffffffc02017ba:	00b78763          	beq	a5,a1,ffffffffc02017c8 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02017be:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02017c0:	00054783          	lbu	a5,0(a0)
ffffffffc02017c4:	fbfd                	bnez	a5,ffffffffc02017ba <strchr+0xc>
    }
    return NULL;
ffffffffc02017c6:	4501                	li	a0,0
}
ffffffffc02017c8:	8082                	ret
ffffffffc02017ca:	8082                	ret

ffffffffc02017cc <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02017cc:	ca01                	beqz	a2,ffffffffc02017dc <memset+0x10>
ffffffffc02017ce:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02017d0:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02017d2:	0785                	addi	a5,a5,1
ffffffffc02017d4:	feb78fa3          	sb	a1,-1(a5) # ffffffffffffefff <end+0x3fdf8b8f>
    while (n -- > 0) {
ffffffffc02017d8:	fec79de3          	bne	a5,a2,ffffffffc02017d2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02017dc:	8082                	ret

ffffffffc02017de <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02017de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017e2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02017e4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02017ea:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02017ee:	f022                	sd	s0,32(sp)
ffffffffc02017f0:	ec26                	sd	s1,24(sp)
ffffffffc02017f2:	e84a                	sd	s2,16(sp)
ffffffffc02017f4:	f406                	sd	ra,40(sp)
ffffffffc02017f6:	e44e                	sd	s3,8(sp)
ffffffffc02017f8:	84aa                	mv	s1,a0
ffffffffc02017fa:	892e                	mv	s2,a1
ffffffffc02017fc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201800:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201802:	03067e63          	bleu	a6,a2,ffffffffc020183e <printnum+0x60>
ffffffffc0201806:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201808:	00805763          	blez	s0,ffffffffc0201816 <printnum+0x38>
ffffffffc020180c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020180e:	85ca                	mv	a1,s2
ffffffffc0201810:	854e                	mv	a0,s3
ffffffffc0201812:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201814:	fc65                	bnez	s0,ffffffffc020180c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201816:	1a02                	slli	s4,s4,0x20
ffffffffc0201818:	020a5a13          	srli	s4,s4,0x20
ffffffffc020181c:	00001797          	auipc	a5,0x1
ffffffffc0201820:	68c78793          	addi	a5,a5,1676 # ffffffffc0202ea8 <error_string+0x38>
ffffffffc0201824:	9a3e                	add	s4,s4,a5
}
ffffffffc0201826:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201828:	000a4503          	lbu	a0,0(s4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
}
ffffffffc020182c:	70a2                	ld	ra,40(sp)
ffffffffc020182e:	69a2                	ld	s3,8(sp)
ffffffffc0201830:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201832:	85ca                	mv	a1,s2
ffffffffc0201834:	8326                	mv	t1,s1
}
ffffffffc0201836:	6942                	ld	s2,16(sp)
ffffffffc0201838:	64e2                	ld	s1,24(sp)
ffffffffc020183a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020183c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020183e:	03065633          	divu	a2,a2,a6
ffffffffc0201842:	8722                	mv	a4,s0
ffffffffc0201844:	f9bff0ef          	jal	ra,ffffffffc02017de <printnum>
ffffffffc0201848:	b7f9                	j	ffffffffc0201816 <printnum+0x38>

ffffffffc020184a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020184a:	7119                	addi	sp,sp,-128
ffffffffc020184c:	f4a6                	sd	s1,104(sp)
ffffffffc020184e:	f0ca                	sd	s2,96(sp)
ffffffffc0201850:	e8d2                	sd	s4,80(sp)
ffffffffc0201852:	e4d6                	sd	s5,72(sp)
ffffffffc0201854:	e0da                	sd	s6,64(sp)
ffffffffc0201856:	fc5e                	sd	s7,56(sp)
ffffffffc0201858:	f862                	sd	s8,48(sp)
ffffffffc020185a:	f06a                	sd	s10,32(sp)
ffffffffc020185c:	fc86                	sd	ra,120(sp)
ffffffffc020185e:	f8a2                	sd	s0,112(sp)
ffffffffc0201860:	ecce                	sd	s3,88(sp)
ffffffffc0201862:	f466                	sd	s9,40(sp)
ffffffffc0201864:	ec6e                	sd	s11,24(sp)
ffffffffc0201866:	892a                	mv	s2,a0
ffffffffc0201868:	84ae                	mv	s1,a1
ffffffffc020186a:	8d32                	mv	s10,a2
ffffffffc020186c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020186e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201870:	00001a17          	auipc	s4,0x1
ffffffffc0201874:	4a8a0a13          	addi	s4,s4,1192 # ffffffffc0202d18 <buddy_system_pmm_manager+0x180>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201878:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020187c:	00001c17          	auipc	s8,0x1
ffffffffc0201880:	5f4c0c13          	addi	s8,s8,1524 # ffffffffc0202e70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201884:	000d4503          	lbu	a0,0(s10)
ffffffffc0201888:	02500793          	li	a5,37
ffffffffc020188c:	001d0413          	addi	s0,s10,1
ffffffffc0201890:	00f50e63          	beq	a0,a5,ffffffffc02018ac <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201894:	c521                	beqz	a0,ffffffffc02018dc <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201896:	02500993          	li	s3,37
ffffffffc020189a:	a011                	j	ffffffffc020189e <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020189c:	c121                	beqz	a0,ffffffffc02018dc <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020189e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018a0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02018a2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02018a4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02018a8:	ff351ae3          	bne	a0,s3,ffffffffc020189c <vprintfmt+0x52>
ffffffffc02018ac:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02018b0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02018b4:	4981                	li	s3,0
ffffffffc02018b6:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02018b8:	5cfd                	li	s9,-1
ffffffffc02018ba:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018bc:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02018c0:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018c2:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02018c6:	0ff6f693          	andi	a3,a3,255
ffffffffc02018ca:	00140d13          	addi	s10,s0,1
ffffffffc02018ce:	20d5e563          	bltu	a1,a3,ffffffffc0201ad8 <vprintfmt+0x28e>
ffffffffc02018d2:	068a                	slli	a3,a3,0x2
ffffffffc02018d4:	96d2                	add	a3,a3,s4
ffffffffc02018d6:	4294                	lw	a3,0(a3)
ffffffffc02018d8:	96d2                	add	a3,a3,s4
ffffffffc02018da:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02018dc:	70e6                	ld	ra,120(sp)
ffffffffc02018de:	7446                	ld	s0,112(sp)
ffffffffc02018e0:	74a6                	ld	s1,104(sp)
ffffffffc02018e2:	7906                	ld	s2,96(sp)
ffffffffc02018e4:	69e6                	ld	s3,88(sp)
ffffffffc02018e6:	6a46                	ld	s4,80(sp)
ffffffffc02018e8:	6aa6                	ld	s5,72(sp)
ffffffffc02018ea:	6b06                	ld	s6,64(sp)
ffffffffc02018ec:	7be2                	ld	s7,56(sp)
ffffffffc02018ee:	7c42                	ld	s8,48(sp)
ffffffffc02018f0:	7ca2                	ld	s9,40(sp)
ffffffffc02018f2:	7d02                	ld	s10,32(sp)
ffffffffc02018f4:	6de2                	ld	s11,24(sp)
ffffffffc02018f6:	6109                	addi	sp,sp,128
ffffffffc02018f8:	8082                	ret
    if (lflag >= 2) {
ffffffffc02018fa:	4705                	li	a4,1
ffffffffc02018fc:	008a8593          	addi	a1,s5,8
ffffffffc0201900:	01074463          	blt	a4,a6,ffffffffc0201908 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201904:	26080363          	beqz	a6,ffffffffc0201b6a <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201908:	000ab603          	ld	a2,0(s5)
ffffffffc020190c:	46c1                	li	a3,16
ffffffffc020190e:	8aae                	mv	s5,a1
ffffffffc0201910:	a06d                	j	ffffffffc02019ba <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201912:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201916:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201918:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020191a:	b765                	j	ffffffffc02018c2 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020191c:	000aa503          	lw	a0,0(s5)
ffffffffc0201920:	85a6                	mv	a1,s1
ffffffffc0201922:	0aa1                	addi	s5,s5,8
ffffffffc0201924:	9902                	jalr	s2
            break;
ffffffffc0201926:	bfb9                	j	ffffffffc0201884 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201928:	4705                	li	a4,1
ffffffffc020192a:	008a8993          	addi	s3,s5,8
ffffffffc020192e:	01074463          	blt	a4,a6,ffffffffc0201936 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201932:	22080463          	beqz	a6,ffffffffc0201b5a <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201936:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020193a:	24044463          	bltz	s0,ffffffffc0201b82 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020193e:	8622                	mv	a2,s0
ffffffffc0201940:	8ace                	mv	s5,s3
ffffffffc0201942:	46a9                	li	a3,10
ffffffffc0201944:	a89d                	j	ffffffffc02019ba <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201946:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020194a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020194c:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020194e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201952:	8fb5                	xor	a5,a5,a3
ffffffffc0201954:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201958:	1ad74363          	blt	a4,a3,ffffffffc0201afe <vprintfmt+0x2b4>
ffffffffc020195c:	00369793          	slli	a5,a3,0x3
ffffffffc0201960:	97e2                	add	a5,a5,s8
ffffffffc0201962:	639c                	ld	a5,0(a5)
ffffffffc0201964:	18078d63          	beqz	a5,ffffffffc0201afe <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201968:	86be                	mv	a3,a5
ffffffffc020196a:	00001617          	auipc	a2,0x1
ffffffffc020196e:	5ee60613          	addi	a2,a2,1518 # ffffffffc0202f58 <error_string+0xe8>
ffffffffc0201972:	85a6                	mv	a1,s1
ffffffffc0201974:	854a                	mv	a0,s2
ffffffffc0201976:	240000ef          	jal	ra,ffffffffc0201bb6 <printfmt>
ffffffffc020197a:	b729                	j	ffffffffc0201884 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020197c:	00144603          	lbu	a2,1(s0)
ffffffffc0201980:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201982:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201984:	bf3d                	j	ffffffffc02018c2 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201986:	4705                	li	a4,1
ffffffffc0201988:	008a8593          	addi	a1,s5,8
ffffffffc020198c:	01074463          	blt	a4,a6,ffffffffc0201994 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201990:	1e080263          	beqz	a6,ffffffffc0201b74 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201994:	000ab603          	ld	a2,0(s5)
ffffffffc0201998:	46a1                	li	a3,8
ffffffffc020199a:	8aae                	mv	s5,a1
ffffffffc020199c:	a839                	j	ffffffffc02019ba <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020199e:	03000513          	li	a0,48
ffffffffc02019a2:	85a6                	mv	a1,s1
ffffffffc02019a4:	e03e                	sd	a5,0(sp)
ffffffffc02019a6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02019a8:	85a6                	mv	a1,s1
ffffffffc02019aa:	07800513          	li	a0,120
ffffffffc02019ae:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02019b0:	0aa1                	addi	s5,s5,8
ffffffffc02019b2:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02019b6:	6782                	ld	a5,0(sp)
ffffffffc02019b8:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02019ba:	876e                	mv	a4,s11
ffffffffc02019bc:	85a6                	mv	a1,s1
ffffffffc02019be:	854a                	mv	a0,s2
ffffffffc02019c0:	e1fff0ef          	jal	ra,ffffffffc02017de <printnum>
            break;
ffffffffc02019c4:	b5c1                	j	ffffffffc0201884 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019c6:	000ab603          	ld	a2,0(s5)
ffffffffc02019ca:	0aa1                	addi	s5,s5,8
ffffffffc02019cc:	1c060663          	beqz	a2,ffffffffc0201b98 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02019d0:	00160413          	addi	s0,a2,1
ffffffffc02019d4:	17b05c63          	blez	s11,ffffffffc0201b4c <vprintfmt+0x302>
ffffffffc02019d8:	02d00593          	li	a1,45
ffffffffc02019dc:	14b79263          	bne	a5,a1,ffffffffc0201b20 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019e0:	00064783          	lbu	a5,0(a2)
ffffffffc02019e4:	0007851b          	sext.w	a0,a5
ffffffffc02019e8:	c905                	beqz	a0,ffffffffc0201a18 <vprintfmt+0x1ce>
ffffffffc02019ea:	000cc563          	bltz	s9,ffffffffc02019f4 <vprintfmt+0x1aa>
ffffffffc02019ee:	3cfd                	addiw	s9,s9,-1
ffffffffc02019f0:	036c8263          	beq	s9,s6,ffffffffc0201a14 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02019f4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019f6:	18098463          	beqz	s3,ffffffffc0201b7e <vprintfmt+0x334>
ffffffffc02019fa:	3781                	addiw	a5,a5,-32
ffffffffc02019fc:	18fbf163          	bleu	a5,s7,ffffffffc0201b7e <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201a00:	03f00513          	li	a0,63
ffffffffc0201a04:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a06:	0405                	addi	s0,s0,1
ffffffffc0201a08:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201a0c:	3dfd                	addiw	s11,s11,-1
ffffffffc0201a0e:	0007851b          	sext.w	a0,a5
ffffffffc0201a12:	fd61                	bnez	a0,ffffffffc02019ea <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201a14:	e7b058e3          	blez	s11,ffffffffc0201884 <vprintfmt+0x3a>
ffffffffc0201a18:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a1a:	85a6                	mv	a1,s1
ffffffffc0201a1c:	02000513          	li	a0,32
ffffffffc0201a20:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a22:	e60d81e3          	beqz	s11,ffffffffc0201884 <vprintfmt+0x3a>
ffffffffc0201a26:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201a28:	85a6                	mv	a1,s1
ffffffffc0201a2a:	02000513          	li	a0,32
ffffffffc0201a2e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201a30:	fe0d94e3          	bnez	s11,ffffffffc0201a18 <vprintfmt+0x1ce>
ffffffffc0201a34:	bd81                	j	ffffffffc0201884 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201a36:	4705                	li	a4,1
ffffffffc0201a38:	008a8593          	addi	a1,s5,8
ffffffffc0201a3c:	01074463          	blt	a4,a6,ffffffffc0201a44 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201a40:	12080063          	beqz	a6,ffffffffc0201b60 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201a44:	000ab603          	ld	a2,0(s5)
ffffffffc0201a48:	46a9                	li	a3,10
ffffffffc0201a4a:	8aae                	mv	s5,a1
ffffffffc0201a4c:	b7bd                	j	ffffffffc02019ba <vprintfmt+0x170>
ffffffffc0201a4e:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201a52:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a56:	846a                	mv	s0,s10
ffffffffc0201a58:	b5ad                	j	ffffffffc02018c2 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201a5a:	85a6                	mv	a1,s1
ffffffffc0201a5c:	02500513          	li	a0,37
ffffffffc0201a60:	9902                	jalr	s2
            break;
ffffffffc0201a62:	b50d                	j	ffffffffc0201884 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201a64:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201a68:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201a6c:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a6e:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201a70:	e40dd9e3          	bgez	s11,ffffffffc02018c2 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201a74:	8de6                	mv	s11,s9
ffffffffc0201a76:	5cfd                	li	s9,-1
ffffffffc0201a78:	b5a9                	j	ffffffffc02018c2 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201a7a:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0201a7e:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a82:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201a84:	bd3d                	j	ffffffffc02018c2 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201a86:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201a8a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a8e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201a90:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201a94:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201a98:	fcd56ce3          	bltu	a0,a3,ffffffffc0201a70 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201a9c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201a9e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201aa2:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201aa6:	0196873b          	addw	a4,a3,s9
ffffffffc0201aaa:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201aae:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201ab2:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201ab6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201aba:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201abe:	fcd57fe3          	bleu	a3,a0,ffffffffc0201a9c <vprintfmt+0x252>
ffffffffc0201ac2:	b77d                	j	ffffffffc0201a70 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201ac4:	fffdc693          	not	a3,s11
ffffffffc0201ac8:	96fd                	srai	a3,a3,0x3f
ffffffffc0201aca:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201ace:	00144603          	lbu	a2,1(s0)
ffffffffc0201ad2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad4:	846a                	mv	s0,s10
ffffffffc0201ad6:	b3f5                	j	ffffffffc02018c2 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201ad8:	85a6                	mv	a1,s1
ffffffffc0201ada:	02500513          	li	a0,37
ffffffffc0201ade:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201ae0:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201ae4:	02500793          	li	a5,37
ffffffffc0201ae8:	8d22                	mv	s10,s0
ffffffffc0201aea:	d8f70de3          	beq	a4,a5,ffffffffc0201884 <vprintfmt+0x3a>
ffffffffc0201aee:	02500713          	li	a4,37
ffffffffc0201af2:	1d7d                	addi	s10,s10,-1
ffffffffc0201af4:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201af8:	fee79de3          	bne	a5,a4,ffffffffc0201af2 <vprintfmt+0x2a8>
ffffffffc0201afc:	b361                	j	ffffffffc0201884 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201afe:	00001617          	auipc	a2,0x1
ffffffffc0201b02:	44a60613          	addi	a2,a2,1098 # ffffffffc0202f48 <error_string+0xd8>
ffffffffc0201b06:	85a6                	mv	a1,s1
ffffffffc0201b08:	854a                	mv	a0,s2
ffffffffc0201b0a:	0ac000ef          	jal	ra,ffffffffc0201bb6 <printfmt>
ffffffffc0201b0e:	bb9d                	j	ffffffffc0201884 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201b10:	00001617          	auipc	a2,0x1
ffffffffc0201b14:	43060613          	addi	a2,a2,1072 # ffffffffc0202f40 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201b18:	00001417          	auipc	s0,0x1
ffffffffc0201b1c:	42940413          	addi	s0,s0,1065 # ffffffffc0202f41 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b20:	8532                	mv	a0,a2
ffffffffc0201b22:	85e6                	mv	a1,s9
ffffffffc0201b24:	e032                	sd	a2,0(sp)
ffffffffc0201b26:	e43e                	sd	a5,8(sp)
ffffffffc0201b28:	c37ff0ef          	jal	ra,ffffffffc020175e <strnlen>
ffffffffc0201b2c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201b30:	6602                	ld	a2,0(sp)
ffffffffc0201b32:	01b05d63          	blez	s11,ffffffffc0201b4c <vprintfmt+0x302>
ffffffffc0201b36:	67a2                	ld	a5,8(sp)
ffffffffc0201b38:	2781                	sext.w	a5,a5
ffffffffc0201b3a:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201b3c:	6522                	ld	a0,8(sp)
ffffffffc0201b3e:	85a6                	mv	a1,s1
ffffffffc0201b40:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b42:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201b44:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b46:	6602                	ld	a2,0(sp)
ffffffffc0201b48:	fe0d9ae3          	bnez	s11,ffffffffc0201b3c <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b4c:	00064783          	lbu	a5,0(a2)
ffffffffc0201b50:	0007851b          	sext.w	a0,a5
ffffffffc0201b54:	e8051be3          	bnez	a0,ffffffffc02019ea <vprintfmt+0x1a0>
ffffffffc0201b58:	b335                	j	ffffffffc0201884 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201b5a:	000aa403          	lw	s0,0(s5)
ffffffffc0201b5e:	bbf1                	j	ffffffffc020193a <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0201b60:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b64:	46a9                	li	a3,10
ffffffffc0201b66:	8aae                	mv	s5,a1
ffffffffc0201b68:	bd89                	j	ffffffffc02019ba <vprintfmt+0x170>
ffffffffc0201b6a:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b6e:	46c1                	li	a3,16
ffffffffc0201b70:	8aae                	mv	s5,a1
ffffffffc0201b72:	b5a1                	j	ffffffffc02019ba <vprintfmt+0x170>
ffffffffc0201b74:	000ae603          	lwu	a2,0(s5)
ffffffffc0201b78:	46a1                	li	a3,8
ffffffffc0201b7a:	8aae                	mv	s5,a1
ffffffffc0201b7c:	bd3d                	j	ffffffffc02019ba <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0201b7e:	9902                	jalr	s2
ffffffffc0201b80:	b559                	j	ffffffffc0201a06 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0201b82:	85a6                	mv	a1,s1
ffffffffc0201b84:	02d00513          	li	a0,45
ffffffffc0201b88:	e03e                	sd	a5,0(sp)
ffffffffc0201b8a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201b8c:	8ace                	mv	s5,s3
ffffffffc0201b8e:	40800633          	neg	a2,s0
ffffffffc0201b92:	46a9                	li	a3,10
ffffffffc0201b94:	6782                	ld	a5,0(sp)
ffffffffc0201b96:	b515                	j	ffffffffc02019ba <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201b98:	01b05663          	blez	s11,ffffffffc0201ba4 <vprintfmt+0x35a>
ffffffffc0201b9c:	02d00693          	li	a3,45
ffffffffc0201ba0:	f6d798e3          	bne	a5,a3,ffffffffc0201b10 <vprintfmt+0x2c6>
ffffffffc0201ba4:	00001417          	auipc	s0,0x1
ffffffffc0201ba8:	39d40413          	addi	s0,s0,925 # ffffffffc0202f41 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bac:	02800513          	li	a0,40
ffffffffc0201bb0:	02800793          	li	a5,40
ffffffffc0201bb4:	bd1d                	j	ffffffffc02019ea <vprintfmt+0x1a0>

ffffffffc0201bb6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bb6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201bb8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bbc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bbe:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201bc0:	ec06                	sd	ra,24(sp)
ffffffffc0201bc2:	f83a                	sd	a4,48(sp)
ffffffffc0201bc4:	fc3e                	sd	a5,56(sp)
ffffffffc0201bc6:	e0c2                	sd	a6,64(sp)
ffffffffc0201bc8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201bca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201bcc:	c7fff0ef          	jal	ra,ffffffffc020184a <vprintfmt>
}
ffffffffc0201bd0:	60e2                	ld	ra,24(sp)
ffffffffc0201bd2:	6161                	addi	sp,sp,80
ffffffffc0201bd4:	8082                	ret

ffffffffc0201bd6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201bd6:	715d                	addi	sp,sp,-80
ffffffffc0201bd8:	e486                	sd	ra,72(sp)
ffffffffc0201bda:	e0a2                	sd	s0,64(sp)
ffffffffc0201bdc:	fc26                	sd	s1,56(sp)
ffffffffc0201bde:	f84a                	sd	s2,48(sp)
ffffffffc0201be0:	f44e                	sd	s3,40(sp)
ffffffffc0201be2:	f052                	sd	s4,32(sp)
ffffffffc0201be4:	ec56                	sd	s5,24(sp)
ffffffffc0201be6:	e85a                	sd	s6,16(sp)
ffffffffc0201be8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201bea:	c901                	beqz	a0,ffffffffc0201bfa <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201bec:	85aa                	mv	a1,a0
ffffffffc0201bee:	00001517          	auipc	a0,0x1
ffffffffc0201bf2:	36a50513          	addi	a0,a0,874 # ffffffffc0202f58 <error_string+0xe8>
ffffffffc0201bf6:	cc0fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201bfa:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bfc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201bfe:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201c00:	4aa9                	li	s5,10
ffffffffc0201c02:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201c04:	00004b97          	auipc	s7,0x4
ffffffffc0201c08:	40cb8b93          	addi	s7,s7,1036 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c0c:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201c10:	d1efe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201c14:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c16:	00054b63          	bltz	a0,ffffffffc0201c2c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c1a:	00a95b63          	ble	a0,s2,ffffffffc0201c30 <readline+0x5a>
ffffffffc0201c1e:	029a5463          	ble	s1,s4,ffffffffc0201c46 <readline+0x70>
        c = getchar();
ffffffffc0201c22:	d0cfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201c26:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c28:	fe0559e3          	bgez	a0,ffffffffc0201c1a <readline+0x44>
            return NULL;
ffffffffc0201c2c:	4501                	li	a0,0
ffffffffc0201c2e:	a099                	j	ffffffffc0201c74 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201c30:	03341463          	bne	s0,s3,ffffffffc0201c58 <readline+0x82>
ffffffffc0201c34:	e8b9                	bnez	s1,ffffffffc0201c8a <readline+0xb4>
        c = getchar();
ffffffffc0201c36:	cf8fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201c3a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201c3c:	fe0548e3          	bltz	a0,ffffffffc0201c2c <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201c40:	fea958e3          	ble	a0,s2,ffffffffc0201c30 <readline+0x5a>
ffffffffc0201c44:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201c46:	8522                	mv	a0,s0
ffffffffc0201c48:	ca2fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201c4c:	009b87b3          	add	a5,s7,s1
ffffffffc0201c50:	00878023          	sb	s0,0(a5)
ffffffffc0201c54:	2485                	addiw	s1,s1,1
ffffffffc0201c56:	bf6d                	j	ffffffffc0201c10 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201c58:	01540463          	beq	s0,s5,ffffffffc0201c60 <readline+0x8a>
ffffffffc0201c5c:	fb641ae3          	bne	s0,s6,ffffffffc0201c10 <readline+0x3a>
            cputchar(c);
ffffffffc0201c60:	8522                	mv	a0,s0
ffffffffc0201c62:	c88fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201c66:	00004517          	auipc	a0,0x4
ffffffffc0201c6a:	3aa50513          	addi	a0,a0,938 # ffffffffc0206010 <edata>
ffffffffc0201c6e:	94aa                	add	s1,s1,a0
ffffffffc0201c70:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201c74:	60a6                	ld	ra,72(sp)
ffffffffc0201c76:	6406                	ld	s0,64(sp)
ffffffffc0201c78:	74e2                	ld	s1,56(sp)
ffffffffc0201c7a:	7942                	ld	s2,48(sp)
ffffffffc0201c7c:	79a2                	ld	s3,40(sp)
ffffffffc0201c7e:	7a02                	ld	s4,32(sp)
ffffffffc0201c80:	6ae2                	ld	s5,24(sp)
ffffffffc0201c82:	6b42                	ld	s6,16(sp)
ffffffffc0201c84:	6ba2                	ld	s7,8(sp)
ffffffffc0201c86:	6161                	addi	sp,sp,80
ffffffffc0201c88:	8082                	ret
            cputchar(c);
ffffffffc0201c8a:	4521                	li	a0,8
ffffffffc0201c8c:	c5efe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201c90:	34fd                	addiw	s1,s1,-1
ffffffffc0201c92:	bfbd                	j	ffffffffc0201c10 <readline+0x3a>

ffffffffc0201c94 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201c94:	00004797          	auipc	a5,0x4
ffffffffc0201c98:	37478793          	addi	a5,a5,884 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201c9c:	6398                	ld	a4,0(a5)
ffffffffc0201c9e:	4781                	li	a5,0
ffffffffc0201ca0:	88ba                	mv	a7,a4
ffffffffc0201ca2:	852a                	mv	a0,a0
ffffffffc0201ca4:	85be                	mv	a1,a5
ffffffffc0201ca6:	863e                	mv	a2,a5
ffffffffc0201ca8:	00000073          	ecall
ffffffffc0201cac:	87aa                	mv	a5,a0
}
ffffffffc0201cae:	8082                	ret

ffffffffc0201cb0 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201cb0:	00004797          	auipc	a5,0x4
ffffffffc0201cb4:	77878793          	addi	a5,a5,1912 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201cb8:	6398                	ld	a4,0(a5)
ffffffffc0201cba:	4781                	li	a5,0
ffffffffc0201cbc:	88ba                	mv	a7,a4
ffffffffc0201cbe:	852a                	mv	a0,a0
ffffffffc0201cc0:	85be                	mv	a1,a5
ffffffffc0201cc2:	863e                	mv	a2,a5
ffffffffc0201cc4:	00000073          	ecall
ffffffffc0201cc8:	87aa                	mv	a5,a0
}
ffffffffc0201cca:	8082                	ret

ffffffffc0201ccc <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201ccc:	00004797          	auipc	a5,0x4
ffffffffc0201cd0:	33478793          	addi	a5,a5,820 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201cd4:	639c                	ld	a5,0(a5)
ffffffffc0201cd6:	4501                	li	a0,0
ffffffffc0201cd8:	88be                	mv	a7,a5
ffffffffc0201cda:	852a                	mv	a0,a0
ffffffffc0201cdc:	85aa                	mv	a1,a0
ffffffffc0201cde:	862a                	mv	a2,a0
ffffffffc0201ce0:	00000073          	ecall
ffffffffc0201ce4:	852a                	mv	a0,a0
ffffffffc0201ce6:	2501                	sext.w	a0,a0
ffffffffc0201ce8:	8082                	ret
