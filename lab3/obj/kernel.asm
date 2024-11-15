
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	01250513          	addi	a0,a0,18 # ffffffffc020a048 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	138040ef          	jal	ra,ffffffffc0204186 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	61658593          	addi	a1,a1,1558 # ffffffffc0204668 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	62e50513          	addi	a0,a0,1582 # ffffffffc0204688 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	100000ef          	jal	ra,ffffffffc0200166 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	73b000ef          	jal	ra,ffffffffc0200fa4 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	609010ef          	jal	ra,ffffffffc0201e7a <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	35e000ef          	jal	ra,ffffffffc02003d4 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	412020ef          	jal	ra,ffffffffc020248c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	3ae000ef          	jal	ra,ffffffffc020042c <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	3f6000ef          	jal	ra,ffffffffc0200482 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	16a040ef          	jal	ra,ffffffffc020421c <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	136040ef          	jal	ra,ffffffffc020421c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3900006f          	j	ffffffffc0200482 <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	3be000ef          	jal	ra,ffffffffc02004b8 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200106:	00011317          	auipc	t1,0x11
ffffffffc020010a:	34230313          	addi	t1,t1,834 # ffffffffc0211448 <is_panic>
ffffffffc020010e:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200112:	715d                	addi	sp,sp,-80
ffffffffc0200114:	ec06                	sd	ra,24(sp)
ffffffffc0200116:	e822                	sd	s0,16(sp)
ffffffffc0200118:	f436                	sd	a3,40(sp)
ffffffffc020011a:	f83a                	sd	a4,48(sp)
ffffffffc020011c:	fc3e                	sd	a5,56(sp)
ffffffffc020011e:	e0c2                	sd	a6,64(sp)
ffffffffc0200120:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200122:	02031c63          	bnez	t1,ffffffffc020015a <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200126:	4785                	li	a5,1
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	00011717          	auipc	a4,0x11
ffffffffc020012e:	30f72f23          	sw	a5,798(a4) # ffffffffc0211448 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200132:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc0200134:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200136:	85aa                	mv	a1,a0
ffffffffc0200138:	00004517          	auipc	a0,0x4
ffffffffc020013c:	55850513          	addi	a0,a0,1368 # ffffffffc0204690 <etext+0x2a>
    va_start(ap, fmt);
ffffffffc0200140:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200142:	f7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200146:	65a2                	ld	a1,8(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	f55ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc020014e:	00005517          	auipc	a0,0x5
ffffffffc0200152:	35250513          	addi	a0,a0,850 # ffffffffc02054a0 <commands+0xcf0>
ffffffffc0200156:	f69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020015a:	3a0000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020015e:	4501                	li	a0,0
ffffffffc0200160:	132000ef          	jal	ra,ffffffffc0200292 <kmonitor>
ffffffffc0200164:	bfed                	j	ffffffffc020015e <__panic+0x58>

ffffffffc0200166 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200166:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200168:	00004517          	auipc	a0,0x4
ffffffffc020016c:	57850513          	addi	a0,a0,1400 # ffffffffc02046e0 <etext+0x7a>
void print_kerninfo(void) {
ffffffffc0200170:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200172:	f4dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200176:	00000597          	auipc	a1,0x0
ffffffffc020017a:	ec058593          	addi	a1,a1,-320 # ffffffffc0200036 <kern_init>
ffffffffc020017e:	00004517          	auipc	a0,0x4
ffffffffc0200182:	58250513          	addi	a0,a0,1410 # ffffffffc0204700 <etext+0x9a>
ffffffffc0200186:	f39ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020018a:	00004597          	auipc	a1,0x4
ffffffffc020018e:	4dc58593          	addi	a1,a1,1244 # ffffffffc0204666 <etext>
ffffffffc0200192:	00004517          	auipc	a0,0x4
ffffffffc0200196:	58e50513          	addi	a0,a0,1422 # ffffffffc0204720 <etext+0xba>
ffffffffc020019a:	f25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020019e:	0000a597          	auipc	a1,0xa
ffffffffc02001a2:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a048 <edata>
ffffffffc02001a6:	00004517          	auipc	a0,0x4
ffffffffc02001aa:	59a50513          	addi	a0,a0,1434 # ffffffffc0204740 <etext+0xda>
ffffffffc02001ae:	f11ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001b2:	00011597          	auipc	a1,0x11
ffffffffc02001b6:	3ee58593          	addi	a1,a1,1006 # ffffffffc02115a0 <end>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	5a650513          	addi	a0,a0,1446 # ffffffffc0204760 <etext+0xfa>
ffffffffc02001c2:	efdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001c6:	00011597          	auipc	a1,0x11
ffffffffc02001ca:	7d958593          	addi	a1,a1,2009 # ffffffffc021199f <end+0x3ff>
ffffffffc02001ce:	00000797          	auipc	a5,0x0
ffffffffc02001d2:	e6878793          	addi	a5,a5,-408 # ffffffffc0200036 <kern_init>
ffffffffc02001d6:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001da:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001de:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001e0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e4:	95be                	add	a1,a1,a5
ffffffffc02001e6:	85a9                	srai	a1,a1,0xa
ffffffffc02001e8:	00004517          	auipc	a0,0x4
ffffffffc02001ec:	59850513          	addi	a0,a0,1432 # ffffffffc0204780 <etext+0x11a>
}
ffffffffc02001f0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001f2:	ecdff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02001f6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001f8:	00004617          	auipc	a2,0x4
ffffffffc02001fc:	4b860613          	addi	a2,a2,1208 # ffffffffc02046b0 <etext+0x4a>
ffffffffc0200200:	04e00593          	li	a1,78
ffffffffc0200204:	00004517          	auipc	a0,0x4
ffffffffc0200208:	4c450513          	addi	a0,a0,1220 # ffffffffc02046c8 <etext+0x62>
void print_stackframe(void) {
ffffffffc020020c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020020e:	ef9ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200212 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200214:	00004617          	auipc	a2,0x4
ffffffffc0200218:	67460613          	addi	a2,a2,1652 # ffffffffc0204888 <commands+0xd8>
ffffffffc020021c:	00004597          	auipc	a1,0x4
ffffffffc0200220:	68c58593          	addi	a1,a1,1676 # ffffffffc02048a8 <commands+0xf8>
ffffffffc0200224:	00004517          	auipc	a0,0x4
ffffffffc0200228:	68c50513          	addi	a0,a0,1676 # ffffffffc02048b0 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020022c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020022e:	e91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200232:	00004617          	auipc	a2,0x4
ffffffffc0200236:	68e60613          	addi	a2,a2,1678 # ffffffffc02048c0 <commands+0x110>
ffffffffc020023a:	00004597          	auipc	a1,0x4
ffffffffc020023e:	6ae58593          	addi	a1,a1,1710 # ffffffffc02048e8 <commands+0x138>
ffffffffc0200242:	00004517          	auipc	a0,0x4
ffffffffc0200246:	66e50513          	addi	a0,a0,1646 # ffffffffc02048b0 <commands+0x100>
ffffffffc020024a:	e75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024e:	00004617          	auipc	a2,0x4
ffffffffc0200252:	6aa60613          	addi	a2,a2,1706 # ffffffffc02048f8 <commands+0x148>
ffffffffc0200256:	00004597          	auipc	a1,0x4
ffffffffc020025a:	6c258593          	addi	a1,a1,1730 # ffffffffc0204918 <commands+0x168>
ffffffffc020025e:	00004517          	auipc	a0,0x4
ffffffffc0200262:	65250513          	addi	a0,a0,1618 # ffffffffc02048b0 <commands+0x100>
ffffffffc0200266:	e59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020026a:	60a2                	ld	ra,8(sp)
ffffffffc020026c:	4501                	li	a0,0
ffffffffc020026e:	0141                	addi	sp,sp,16
ffffffffc0200270:	8082                	ret

ffffffffc0200272 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200276:	ef1ff0ef          	jal	ra,ffffffffc0200166 <print_kerninfo>
    return 0;
}
ffffffffc020027a:	60a2                	ld	ra,8(sp)
ffffffffc020027c:	4501                	li	a0,0
ffffffffc020027e:	0141                	addi	sp,sp,16
ffffffffc0200280:	8082                	ret

ffffffffc0200282 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
ffffffffc0200284:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200286:	f71ff0ef          	jal	ra,ffffffffc02001f6 <print_stackframe>
    return 0;
}
ffffffffc020028a:	60a2                	ld	ra,8(sp)
ffffffffc020028c:	4501                	li	a0,0
ffffffffc020028e:	0141                	addi	sp,sp,16
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200292:	7115                	addi	sp,sp,-224
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200298:	00004517          	auipc	a0,0x4
ffffffffc020029c:	56050513          	addi	a0,a0,1376 # ffffffffc02047f8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	ed86                	sd	ra,216(sp)
ffffffffc02002a2:	e9a2                	sd	s0,208(sp)
ffffffffc02002a4:	e5a6                	sd	s1,200(sp)
ffffffffc02002a6:	e1ca                	sd	s2,192(sp)
ffffffffc02002a8:	fd4e                	sd	s3,184(sp)
ffffffffc02002aa:	f952                	sd	s4,176(sp)
ffffffffc02002ac:	f556                	sd	s5,168(sp)
ffffffffc02002ae:	f15a                	sd	s6,160(sp)
ffffffffc02002b0:	ed5e                	sd	s7,152(sp)
ffffffffc02002b2:	e566                	sd	s9,136(sp)
ffffffffc02002b4:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002b6:	e09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	56650513          	addi	a0,a0,1382 # ffffffffc0204820 <commands+0x70>
ffffffffc02002c2:	dfdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc02002c6:	000c0563          	beqz	s8,ffffffffc02002d0 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ca:	8562                	mv	a0,s8
ffffffffc02002cc:	492000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc02002d0:	00004c97          	auipc	s9,0x4
ffffffffc02002d4:	4e0c8c93          	addi	s9,s9,1248 # ffffffffc02047b0 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002d8:	00006997          	auipc	s3,0x6
ffffffffc02002dc:	9a098993          	addi	s3,s3,-1632 # ffffffffc0205c78 <commands+0x14c8>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00004917          	auipc	s2,0x4
ffffffffc02002e4:	56890913          	addi	s2,s2,1384 # ffffffffc0204848 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc02002e8:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ea:	00004b17          	auipc	s6,0x4
ffffffffc02002ee:	566b0b13          	addi	s6,s6,1382 # ffffffffc0204850 <commands+0xa0>
    if (argc == 0) {
ffffffffc02002f2:	00004a97          	auipc	s5,0x4
ffffffffc02002f6:	5b6a8a93          	addi	s5,s5,1462 # ffffffffc02048a8 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002fc:	854e                	mv	a0,s3
ffffffffc02002fe:	2aa040ef          	jal	ra,ffffffffc02045a8 <readline>
ffffffffc0200302:	842a                	mv	s0,a0
ffffffffc0200304:	dd65                	beqz	a0,ffffffffc02002fc <kmonitor+0x6a>
ffffffffc0200306:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020030a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	c999                	beqz	a1,ffffffffc0200322 <kmonitor+0x90>
ffffffffc020030e:	854a                	mv	a0,s2
ffffffffc0200310:	659030ef          	jal	ra,ffffffffc0204168 <strchr>
ffffffffc0200314:	c925                	beqz	a0,ffffffffc0200384 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc0200316:	00144583          	lbu	a1,1(s0)
ffffffffc020031a:	00040023          	sb	zero,0(s0)
ffffffffc020031e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200320:	f5fd                	bnez	a1,ffffffffc020030e <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200322:	dce9                	beqz	s1,ffffffffc02002fc <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	6582                	ld	a1,0(sp)
ffffffffc0200326:	00004d17          	auipc	s10,0x4
ffffffffc020032a:	48ad0d13          	addi	s10,s10,1162 # ffffffffc02047b0 <commands>
    if (argc == 0) {
ffffffffc020032e:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200330:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200332:	0d61                	addi	s10,s10,24
ffffffffc0200334:	60b030ef          	jal	ra,ffffffffc020413e <strcmp>
ffffffffc0200338:	c919                	beqz	a0,ffffffffc020034e <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020033a:	2405                	addiw	s0,s0,1
ffffffffc020033c:	09740463          	beq	s0,s7,ffffffffc02003c4 <kmonitor+0x132>
ffffffffc0200340:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200344:	6582                	ld	a1,0(sp)
ffffffffc0200346:	0d61                	addi	s10,s10,24
ffffffffc0200348:	5f7030ef          	jal	ra,ffffffffc020413e <strcmp>
ffffffffc020034c:	f57d                	bnez	a0,ffffffffc020033a <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020034e:	00141793          	slli	a5,s0,0x1
ffffffffc0200352:	97a2                	add	a5,a5,s0
ffffffffc0200354:	078e                	slli	a5,a5,0x3
ffffffffc0200356:	97e6                	add	a5,a5,s9
ffffffffc0200358:	6b9c                	ld	a5,16(a5)
ffffffffc020035a:	8662                	mv	a2,s8
ffffffffc020035c:	002c                	addi	a1,sp,8
ffffffffc020035e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200362:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200364:	f8055ce3          	bgez	a0,ffffffffc02002fc <kmonitor+0x6a>
}
ffffffffc0200368:	60ee                	ld	ra,216(sp)
ffffffffc020036a:	644e                	ld	s0,208(sp)
ffffffffc020036c:	64ae                	ld	s1,200(sp)
ffffffffc020036e:	690e                	ld	s2,192(sp)
ffffffffc0200370:	79ea                	ld	s3,184(sp)
ffffffffc0200372:	7a4a                	ld	s4,176(sp)
ffffffffc0200374:	7aaa                	ld	s5,168(sp)
ffffffffc0200376:	7b0a                	ld	s6,160(sp)
ffffffffc0200378:	6bea                	ld	s7,152(sp)
ffffffffc020037a:	6c4a                	ld	s8,144(sp)
ffffffffc020037c:	6caa                	ld	s9,136(sp)
ffffffffc020037e:	6d0a                	ld	s10,128(sp)
ffffffffc0200380:	612d                	addi	sp,sp,224
ffffffffc0200382:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200384:	00044783          	lbu	a5,0(s0)
ffffffffc0200388:	dfc9                	beqz	a5,ffffffffc0200322 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020038a:	03448863          	beq	s1,s4,ffffffffc02003ba <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020038e:	00349793          	slli	a5,s1,0x3
ffffffffc0200392:	0118                	addi	a4,sp,128
ffffffffc0200394:	97ba                	add	a5,a5,a4
ffffffffc0200396:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020039e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	e591                	bnez	a1,ffffffffc02003ac <kmonitor+0x11a>
ffffffffc02003a2:	b749                	j	ffffffffc0200324 <kmonitor+0x92>
            buf ++;
ffffffffc02003a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a6:	00044583          	lbu	a1,0(s0)
ffffffffc02003aa:	ddad                	beqz	a1,ffffffffc0200324 <kmonitor+0x92>
ffffffffc02003ac:	854a                	mv	a0,s2
ffffffffc02003ae:	5bb030ef          	jal	ra,ffffffffc0204168 <strchr>
ffffffffc02003b2:	d96d                	beqz	a0,ffffffffc02003a4 <kmonitor+0x112>
ffffffffc02003b4:	00044583          	lbu	a1,0(s0)
ffffffffc02003b8:	bf91                	j	ffffffffc020030c <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ba:	45c1                	li	a1,16
ffffffffc02003bc:	855a                	mv	a0,s6
ffffffffc02003be:	d01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003c2:	b7f1                	j	ffffffffc020038e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c4:	6582                	ld	a1,0(sp)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204870 <commands+0xc0>
ffffffffc02003ce:	cf1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc02003d2:	b72d                	j	ffffffffc02002fc <kmonitor+0x6a>

ffffffffc02003d4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d4:	8082                	ret

ffffffffc02003d6 <ide_device_valid>:

#define MAX_IDE 2 // 最大 IDE 磁盘数
#define MAX_DISK_NSECS 56 // 最大磁盘扇区数
static char ide[MAX_DISK_NSECS * SECTSIZE]; // 硬盘存储空间，大小为`56*512`

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d6:	00253513          	sltiu	a0,a0,2
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003dc:	03800513          	li	a0,56
ffffffffc02003e0:	8082                	ret

ffffffffc02003e2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003e2:	0000a797          	auipc	a5,0xa
ffffffffc02003e6:	c6678793          	addi	a5,a5,-922 # ffffffffc020a048 <edata>
ffffffffc02003ea:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ee:	1141                	addi	sp,sp,-16
ffffffffc02003f0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f2:	95be                	add	a1,a1,a5
ffffffffc02003f4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003fa:	59f030ef          	jal	ra,ffffffffc0204198 <memcpy>
    return 0;
}
ffffffffc02003fe:	60a2                	ld	ra,8(sp)
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	0141                	addi	sp,sp,16
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200406:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200408:	0095979b          	slliw	a5,a1,0x9
ffffffffc020040c:	0000a517          	auipc	a0,0xa
ffffffffc0200410:	c3c50513          	addi	a0,a0,-964 # ffffffffc020a048 <edata>
                   size_t nsecs) {
ffffffffc0200414:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200416:	00969613          	slli	a2,a3,0x9
ffffffffc020041a:	85ba                	mv	a1,a4
ffffffffc020041c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020041e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200420:	579030ef          	jal	ra,ffffffffc0204198 <memcpy>
    return 0;
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	4501                	li	a0,0
ffffffffc0200428:	0141                	addi	sp,sp,16
ffffffffc020042a:	8082                	ret

ffffffffc020042c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200432:	00011717          	auipc	a4,0x11
ffffffffc0200436:	00f73f23          	sd	a5,30(a4) # ffffffffc0211450 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020043e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200440:	953e                	add	a0,a0,a5
ffffffffc0200442:	4601                	li	a2,0
ffffffffc0200444:	4881                	li	a7,0
ffffffffc0200446:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020044a:	02000793          	li	a5,32
ffffffffc020044e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	4d650513          	addi	a0,a0,1238 # ffffffffc0204928 <commands+0x178>
    ticks = 0;
ffffffffc020045a:	00011797          	auipc	a5,0x11
ffffffffc020045e:	0207b323          	sd	zero,38(a5) # ffffffffc0211480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200462:	c5dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200466 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200466:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020046a:	00011797          	auipc	a5,0x11
ffffffffc020046e:	fe678793          	addi	a5,a5,-26 # ffffffffc0211450 <timebase>
ffffffffc0200472:	639c                	ld	a5,0(a5)
ffffffffc0200474:	4581                	li	a1,0
ffffffffc0200476:	4601                	li	a2,0
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4881                	li	a7,0
ffffffffc020047c:	00000073          	ecall
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200482:	100027f3          	csrr	a5,sstatus
ffffffffc0200486:	8b89                	andi	a5,a5,2
ffffffffc0200488:	0ff57513          	andi	a0,a0,255
ffffffffc020048c:	e799                	bnez	a5,ffffffffc020049a <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020048e:	4581                	li	a1,0
ffffffffc0200490:	4601                	li	a2,0
ffffffffc0200492:	4885                	li	a7,1
ffffffffc0200494:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200498:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020049a:	1101                	addi	sp,sp,-32
ffffffffc020049c:	ec06                	sd	ra,24(sp)
ffffffffc020049e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004a0:	05a000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004a4:	6522                	ld	a0,8(sp)
ffffffffc02004a6:	4581                	li	a1,0
ffffffffc02004a8:	4601                	li	a2,0
ffffffffc02004aa:	4885                	li	a7,1
ffffffffc02004ac:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004b0:	60e2                	ld	ra,24(sp)
ffffffffc02004b2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004b4:	0400006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc02004b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
ffffffffc02004be:	eb89                	bnez	a5,ffffffffc02004d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	4581                	li	a1,0
ffffffffc02004c4:	4601                	li	a2,0
ffffffffc02004c6:	4889                	li	a7,2
ffffffffc02004c8:	00000073          	ecall
ffffffffc02004cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004ce:	8082                	ret
int cons_getc(void) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004d4:	026000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	4889                	li	a7,2
ffffffffc02004e0:	00000073          	ecall
ffffffffc02004e4:	2501                	sext.w	a0,a0
ffffffffc02004e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004e8:	00c000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6522                	ld	a0,8(sp)
ffffffffc02004f0:	6105                	addi	sp,sp,32
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	6f050513          	addi	a0,a0,1776 # ffffffffc0204c20 <commands+0x470>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	f7c78793          	addi	a5,a5,-132 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	6630106f          	j	ffffffffc02023b8 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	6e660613          	addi	a2,a2,1766 # ffffffffc0204c40 <commands+0x490>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	6f250513          	addi	a0,a0,1778 # ffffffffc0204c58 <commands+0x4a8>
ffffffffc020056e:	b99ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	49a78793          	addi	a5,a5,1178 # ffffffffc0200a10 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	6d850513          	addi	a0,a0,1752 # ffffffffc0204c70 <commands+0x4c0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	6e050513          	addi	a0,a0,1760 # ffffffffc0204c88 <commands+0x4d8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	6ea50513          	addi	a0,a0,1770 # ffffffffc0204ca0 <commands+0x4f0>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	6f450513          	addi	a0,a0,1780 # ffffffffc0204cb8 <commands+0x508>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	6fe50513          	addi	a0,a0,1790 # ffffffffc0204cd0 <commands+0x520>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	70850513          	addi	a0,a0,1800 # ffffffffc0204ce8 <commands+0x538>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	71250513          	addi	a0,a0,1810 # ffffffffc0204d00 <commands+0x550>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	71c50513          	addi	a0,a0,1820 # ffffffffc0204d18 <commands+0x568>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	72650513          	addi	a0,a0,1830 # ffffffffc0204d30 <commands+0x580>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	73050513          	addi	a0,a0,1840 # ffffffffc0204d48 <commands+0x598>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	73a50513          	addi	a0,a0,1850 # ffffffffc0204d60 <commands+0x5b0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	74450513          	addi	a0,a0,1860 # ffffffffc0204d78 <commands+0x5c8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	74e50513          	addi	a0,a0,1870 # ffffffffc0204d90 <commands+0x5e0>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	75850513          	addi	a0,a0,1880 # ffffffffc0204da8 <commands+0x5f8>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	76250513          	addi	a0,a0,1890 # ffffffffc0204dc0 <commands+0x610>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	76c50513          	addi	a0,a0,1900 # ffffffffc0204dd8 <commands+0x628>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	77650513          	addi	a0,a0,1910 # ffffffffc0204df0 <commands+0x640>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	78050513          	addi	a0,a0,1920 # ffffffffc0204e08 <commands+0x658>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	78a50513          	addi	a0,a0,1930 # ffffffffc0204e20 <commands+0x670>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	79450513          	addi	a0,a0,1940 # ffffffffc0204e38 <commands+0x688>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	79e50513          	addi	a0,a0,1950 # ffffffffc0204e50 <commands+0x6a0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	7a850513          	addi	a0,a0,1960 # ffffffffc0204e68 <commands+0x6b8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	7b250513          	addi	a0,a0,1970 # ffffffffc0204e80 <commands+0x6d0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0204e98 <commands+0x6e8>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	7c650513          	addi	a0,a0,1990 # ffffffffc0204eb0 <commands+0x700>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	7d050513          	addi	a0,a0,2000 # ffffffffc0204ec8 <commands+0x718>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	7da50513          	addi	a0,a0,2010 # ffffffffc0204ee0 <commands+0x730>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	7e450513          	addi	a0,a0,2020 # ffffffffc0204ef8 <commands+0x748>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	7ee50513          	addi	a0,a0,2030 # ffffffffc0204f10 <commands+0x760>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	7f850513          	addi	a0,a0,2040 # ffffffffc0204f28 <commands+0x778>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00005517          	auipc	a0,0x5
ffffffffc0200742:	80250513          	addi	a0,a0,-2046 # ffffffffc0204f40 <commands+0x790>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00005517          	auipc	a0,0x5
ffffffffc0200754:	80850513          	addi	a0,a0,-2040 # ffffffffc0204f58 <commands+0x7a8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00005517          	auipc	a0,0x5
ffffffffc020076a:	80a50513          	addi	a0,a0,-2038 # ffffffffc0204f70 <commands+0x7c0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00005517          	auipc	a0,0x5
ffffffffc0200782:	80a50513          	addi	a0,a0,-2038 # ffffffffc0204f88 <commands+0x7d8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00005517          	auipc	a0,0x5
ffffffffc0200792:	81250513          	addi	a0,a0,-2030 # ffffffffc0204fa0 <commands+0x7f0>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00005517          	auipc	a0,0x5
ffffffffc02007a2:	81a50513          	addi	a0,a0,-2022 # ffffffffc0204fb8 <commands+0x808>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00005517          	auipc	a0,0x5
ffffffffc02007b6:	81e50513          	addi	a0,a0,-2018 # ffffffffc0204fd0 <commands+0x820>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	17470713          	addi	a4,a4,372 # ffffffffc0204944 <commands+0x194>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204bd0 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	3c250513          	addi	a0,a0,962 # ffffffffc0204bb0 <commands+0x400>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	37650513          	addi	a0,a0,886 # ffffffffc0204b70 <commands+0x3c0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	38a50513          	addi	a0,a0,906 # ffffffffc0204b90 <commands+0x3e0>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	3ee50513          	addi	a0,a0,1006 # ffffffffc0204c00 <commands+0x450>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	c45ff0ef          	jal	ra,ffffffffc0200466 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c5a78793          	addi	a5,a5,-934 # ffffffffc0211480 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c4f6b323          	sd	a5,-954(a3) # ffffffffc0211480 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	39c50513          	addi	a0,a0,924 # ffffffffc0204bf0 <commands+0x440>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	16f76563          	bltu	a4,a5,ffffffffc02009d2 <exception_handler+0x170>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	10870713          	addi	a4,a4,264 # ffffffffc0204974 <commands+0x1c4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	2d050513          	addi	a0,a0,720 # ffffffffc0204b58 <commands+0x3a8>
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) { //do_pgfault()页面置换成功时返回0
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	12051d63          	bnez	a0,ffffffffc02009d6 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	10e50513          	addi	a0,a0,270 # ffffffffc02049b8 <commands+0x208>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	11a50513          	addi	a0,a0,282 # ffffffffc02049d8 <commands+0x228>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	13050513          	addi	a0,a0,304 # ffffffffc02049f8 <commands+0x248>
ffffffffc02008d0:	b7cd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008d2:	00004517          	auipc	a0,0x4
ffffffffc02008d6:	13e50513          	addi	a0,a0,318 # ffffffffc0204a10 <commands+0x260>
ffffffffc02008da:	bfe1                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008dc:	00004517          	auipc	a0,0x4
ffffffffc02008e0:	14450513          	addi	a0,a0,324 # ffffffffc0204a20 <commands+0x270>
ffffffffc02008e4:	b7f9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	15a50513          	addi	a0,a0,346 # ffffffffc0204a40 <commands+0x290>
ffffffffc02008ee:	fd0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008f2:	8522                	mv	a0,s0
ffffffffc02008f4:	c0dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008f8:	84aa                	mv	s1,a0
ffffffffc02008fa:	d15d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008fc:	8522                	mv	a0,s0
ffffffffc02008fe:	e61ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200902:	86a6                	mv	a3,s1
ffffffffc0200904:	00004617          	auipc	a2,0x4
ffffffffc0200908:	15460613          	addi	a2,a2,340 # ffffffffc0204a58 <commands+0x2a8>
ffffffffc020090c:	0ca00593          	li	a1,202
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	34850513          	addi	a0,a0,840 # ffffffffc0204c58 <commands+0x4a8>
ffffffffc0200918:	feeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020091c:	00004517          	auipc	a0,0x4
ffffffffc0200920:	15c50513          	addi	a0,a0,348 # ffffffffc0204a78 <commands+0x2c8>
ffffffffc0200924:	b779                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	16a50513          	addi	a0,a0,362 # ffffffffc0204a90 <commands+0x2e0>
ffffffffc020092e:	f90ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200932:	8522                	mv	a0,s0
ffffffffc0200934:	bcdff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200938:	84aa                	mv	s1,a0
ffffffffc020093a:	d13d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020093c:	8522                	mv	a0,s0
ffffffffc020093e:	e21ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200942:	86a6                	mv	a3,s1
ffffffffc0200944:	00004617          	auipc	a2,0x4
ffffffffc0200948:	11460613          	addi	a2,a2,276 # ffffffffc0204a58 <commands+0x2a8>
ffffffffc020094c:	0d400593          	li	a1,212
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	30850513          	addi	a0,a0,776 # ffffffffc0204c58 <commands+0x4a8>
ffffffffc0200958:	faeff0ef          	jal	ra,ffffffffc0200106 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020095c:	00004517          	auipc	a0,0x4
ffffffffc0200960:	14c50513          	addi	a0,a0,332 # ffffffffc0204aa8 <commands+0x2f8>
ffffffffc0200964:	b7b9                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	16250513          	addi	a0,a0,354 # ffffffffc0204ac8 <commands+0x318>
ffffffffc020096e:	b791                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200970:	00004517          	auipc	a0,0x4
ffffffffc0200974:	17850513          	addi	a0,a0,376 # ffffffffc0204ae8 <commands+0x338>
ffffffffc0200978:	bf2d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020097a:	00004517          	auipc	a0,0x4
ffffffffc020097e:	18e50513          	addi	a0,a0,398 # ffffffffc0204b08 <commands+0x358>
ffffffffc0200982:	bf05                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200984:	00004517          	auipc	a0,0x4
ffffffffc0200988:	1a450513          	addi	a0,a0,420 # ffffffffc0204b28 <commands+0x378>
ffffffffc020098c:	b71d                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	1b250513          	addi	a0,a0,434 # ffffffffc0204b40 <commands+0x390>
ffffffffc0200996:	f28ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	b65ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009a0:	84aa                	mv	s1,a0
ffffffffc02009a2:	ee050fe3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	db7ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ac:	86a6                	mv	a3,s1
ffffffffc02009ae:	00004617          	auipc	a2,0x4
ffffffffc02009b2:	0aa60613          	addi	a2,a2,170 # ffffffffc0204a58 <commands+0x2a8>
ffffffffc02009b6:	0ea00593          	li	a1,234
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	29e50513          	addi	a0,a0,670 # ffffffffc0204c58 <commands+0x4a8>
ffffffffc02009c2:	f44ff0ef          	jal	ra,ffffffffc0200106 <__panic>
}
ffffffffc02009c6:	6442                	ld	s0,16(sp)
ffffffffc02009c8:	60e2                	ld	ra,24(sp)
ffffffffc02009ca:	64a2                	ld	s1,8(sp)
ffffffffc02009cc:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009ce:	d91ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009d2:	d8dff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009d6:	8522                	mv	a0,s0
ffffffffc02009d8:	d87ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009dc:	86a6                	mv	a3,s1
ffffffffc02009de:	00004617          	auipc	a2,0x4
ffffffffc02009e2:	07a60613          	addi	a2,a2,122 # ffffffffc0204a58 <commands+0x2a8>
ffffffffc02009e6:	0f100593          	li	a1,241
ffffffffc02009ea:	00004517          	auipc	a0,0x4
ffffffffc02009ee:	26e50513          	addi	a0,a0,622 # ffffffffc0204c58 <commands+0x4a8>
ffffffffc02009f2:	f14ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02009f6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009f6:	11853783          	ld	a5,280(a0)
ffffffffc02009fa:	0007c463          	bltz	a5,ffffffffc0200a02 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009fe:	e65ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a02:	dbfff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a10 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a10:	14011073          	csrw	sscratch,sp
ffffffffc0200a14:	712d                	addi	sp,sp,-288
ffffffffc0200a16:	e406                	sd	ra,8(sp)
ffffffffc0200a18:	ec0e                	sd	gp,24(sp)
ffffffffc0200a1a:	f012                	sd	tp,32(sp)
ffffffffc0200a1c:	f416                	sd	t0,40(sp)
ffffffffc0200a1e:	f81a                	sd	t1,48(sp)
ffffffffc0200a20:	fc1e                	sd	t2,56(sp)
ffffffffc0200a22:	e0a2                	sd	s0,64(sp)
ffffffffc0200a24:	e4a6                	sd	s1,72(sp)
ffffffffc0200a26:	e8aa                	sd	a0,80(sp)
ffffffffc0200a28:	ecae                	sd	a1,88(sp)
ffffffffc0200a2a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a2c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a2e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a30:	fcbe                	sd	a5,120(sp)
ffffffffc0200a32:	e142                	sd	a6,128(sp)
ffffffffc0200a34:	e546                	sd	a7,136(sp)
ffffffffc0200a36:	e94a                	sd	s2,144(sp)
ffffffffc0200a38:	ed4e                	sd	s3,152(sp)
ffffffffc0200a3a:	f152                	sd	s4,160(sp)
ffffffffc0200a3c:	f556                	sd	s5,168(sp)
ffffffffc0200a3e:	f95a                	sd	s6,176(sp)
ffffffffc0200a40:	fd5e                	sd	s7,184(sp)
ffffffffc0200a42:	e1e2                	sd	s8,192(sp)
ffffffffc0200a44:	e5e6                	sd	s9,200(sp)
ffffffffc0200a46:	e9ea                	sd	s10,208(sp)
ffffffffc0200a48:	edee                	sd	s11,216(sp)
ffffffffc0200a4a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a4c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a4e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a50:	fdfe                	sd	t6,248(sp)
ffffffffc0200a52:	14002473          	csrr	s0,sscratch
ffffffffc0200a56:	100024f3          	csrr	s1,sstatus
ffffffffc0200a5a:	14102973          	csrr	s2,sepc
ffffffffc0200a5e:	143029f3          	csrr	s3,stval
ffffffffc0200a62:	14202a73          	csrr	s4,scause
ffffffffc0200a66:	e822                	sd	s0,16(sp)
ffffffffc0200a68:	e226                	sd	s1,256(sp)
ffffffffc0200a6a:	e64a                	sd	s2,264(sp)
ffffffffc0200a6c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a6e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a70:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a72:	f85ff0ef          	jal	ra,ffffffffc02009f6 <trap>

ffffffffc0200a76 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a76:	6492                	ld	s1,256(sp)
ffffffffc0200a78:	6932                	ld	s2,264(sp)
ffffffffc0200a7a:	10049073          	csrw	sstatus,s1
ffffffffc0200a7e:	14191073          	csrw	sepc,s2
ffffffffc0200a82:	60a2                	ld	ra,8(sp)
ffffffffc0200a84:	61e2                	ld	gp,24(sp)
ffffffffc0200a86:	7202                	ld	tp,32(sp)
ffffffffc0200a88:	72a2                	ld	t0,40(sp)
ffffffffc0200a8a:	7342                	ld	t1,48(sp)
ffffffffc0200a8c:	73e2                	ld	t2,56(sp)
ffffffffc0200a8e:	6406                	ld	s0,64(sp)
ffffffffc0200a90:	64a6                	ld	s1,72(sp)
ffffffffc0200a92:	6546                	ld	a0,80(sp)
ffffffffc0200a94:	65e6                	ld	a1,88(sp)
ffffffffc0200a96:	7606                	ld	a2,96(sp)
ffffffffc0200a98:	76a6                	ld	a3,104(sp)
ffffffffc0200a9a:	7746                	ld	a4,112(sp)
ffffffffc0200a9c:	77e6                	ld	a5,120(sp)
ffffffffc0200a9e:	680a                	ld	a6,128(sp)
ffffffffc0200aa0:	68aa                	ld	a7,136(sp)
ffffffffc0200aa2:	694a                	ld	s2,144(sp)
ffffffffc0200aa4:	69ea                	ld	s3,152(sp)
ffffffffc0200aa6:	7a0a                	ld	s4,160(sp)
ffffffffc0200aa8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aaa:	7b4a                	ld	s6,176(sp)
ffffffffc0200aac:	7bea                	ld	s7,184(sp)
ffffffffc0200aae:	6c0e                	ld	s8,192(sp)
ffffffffc0200ab0:	6cae                	ld	s9,200(sp)
ffffffffc0200ab2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ab4:	6dee                	ld	s11,216(sp)
ffffffffc0200ab6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ab8:	7eae                	ld	t4,232(sp)
ffffffffc0200aba:	7f4e                	ld	t5,240(sp)
ffffffffc0200abc:	7fee                	ld	t6,248(sp)
ffffffffc0200abe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ac0:	10200073          	sret
	...

ffffffffc0200ad0 <pa2page.part.4>:

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200ad2:	00004617          	auipc	a2,0x4
ffffffffc0200ad6:	59660613          	addi	a2,a2,1430 # ffffffffc0205068 <commands+0x8b8>
ffffffffc0200ada:	06500593          	li	a1,101
ffffffffc0200ade:	00004517          	auipc	a0,0x4
ffffffffc0200ae2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0205088 <commands+0x8d8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0200ae6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200ae8:	e1eff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200aec <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200aec:	715d                	addi	sp,sp,-80
ffffffffc0200aee:	e0a2                	sd	s0,64(sp)
ffffffffc0200af0:	fc26                	sd	s1,56(sp)
ffffffffc0200af2:	f84a                	sd	s2,48(sp)
ffffffffc0200af4:	f44e                	sd	s3,40(sp)
ffffffffc0200af6:	f052                	sd	s4,32(sp)
ffffffffc0200af8:	ec56                	sd	s5,24(sp)
ffffffffc0200afa:	e486                	sd	ra,72(sp)
ffffffffc0200afc:	842a                	mv	s0,a0
ffffffffc0200afe:	00011497          	auipc	s1,0x11
ffffffffc0200b02:	98a48493          	addi	s1,s1,-1654 # ffffffffc0211488 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b06:	4985                	li	s3,1
ffffffffc0200b08:	00011a17          	auipc	s4,0x11
ffffffffc0200b0c:	970a0a13          	addi	s4,s4,-1680 # ffffffffc0211478 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b10:	0005091b          	sext.w	s2,a0
ffffffffc0200b14:	00011a97          	auipc	s5,0x11
ffffffffc0200b18:	9a4a8a93          	addi	s5,s5,-1628 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0200b1c:	a00d                	j	ffffffffc0200b3e <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b1e:	609c                	ld	a5,0(s1)
ffffffffc0200b20:	6f9c                	ld	a5,24(a5)
ffffffffc0200b22:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b24:	4601                	li	a2,0
ffffffffc0200b26:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b28:	ed0d                	bnez	a0,ffffffffc0200b62 <alloc_pages+0x76>
ffffffffc0200b2a:	0289ec63          	bltu	s3,s0,ffffffffc0200b62 <alloc_pages+0x76>
ffffffffc0200b2e:	000a2783          	lw	a5,0(s4)
ffffffffc0200b32:	2781                	sext.w	a5,a5
ffffffffc0200b34:	c79d                	beqz	a5,ffffffffc0200b62 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b36:	000ab503          	ld	a0,0(s5)
ffffffffc0200b3a:	2ea020ef          	jal	ra,ffffffffc0202e24 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b3e:	100027f3          	csrr	a5,sstatus
ffffffffc0200b42:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0200b44:	8522                	mv	a0,s0
ffffffffc0200b46:	dfe1                	beqz	a5,ffffffffc0200b1e <alloc_pages+0x32>
        intr_disable();
ffffffffc0200b48:	9b3ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200b4c:	609c                	ld	a5,0(s1)
ffffffffc0200b4e:	8522                	mv	a0,s0
ffffffffc0200b50:	6f9c                	ld	a5,24(a5)
ffffffffc0200b52:	9782                	jalr	a5
ffffffffc0200b54:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200b56:	99fff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc0200b5a:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0200b5c:	4601                	li	a2,0
ffffffffc0200b5e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200b60:	d569                	beqz	a0,ffffffffc0200b2a <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200b62:	60a6                	ld	ra,72(sp)
ffffffffc0200b64:	6406                	ld	s0,64(sp)
ffffffffc0200b66:	74e2                	ld	s1,56(sp)
ffffffffc0200b68:	7942                	ld	s2,48(sp)
ffffffffc0200b6a:	79a2                	ld	s3,40(sp)
ffffffffc0200b6c:	7a02                	ld	s4,32(sp)
ffffffffc0200b6e:	6ae2                	ld	s5,24(sp)
ffffffffc0200b70:	6161                	addi	sp,sp,80
ffffffffc0200b72:	8082                	ret

ffffffffc0200b74 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200b74:	100027f3          	csrr	a5,sstatus
ffffffffc0200b78:	8b89                	andi	a5,a5,2
ffffffffc0200b7a:	eb89                	bnez	a5,ffffffffc0200b8c <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b7c:	00011797          	auipc	a5,0x11
ffffffffc0200b80:	90c78793          	addi	a5,a5,-1780 # ffffffffc0211488 <pmm_manager>
ffffffffc0200b84:	639c                	ld	a5,0(a5)
ffffffffc0200b86:	0207b303          	ld	t1,32(a5)
ffffffffc0200b8a:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200b8c:	1101                	addi	sp,sp,-32
ffffffffc0200b8e:	ec06                	sd	ra,24(sp)
ffffffffc0200b90:	e822                	sd	s0,16(sp)
ffffffffc0200b92:	e426                	sd	s1,8(sp)
ffffffffc0200b94:	842a                	mv	s0,a0
ffffffffc0200b96:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200b98:	963ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0200b9c:	00011797          	auipc	a5,0x11
ffffffffc0200ba0:	8ec78793          	addi	a5,a5,-1812 # ffffffffc0211488 <pmm_manager>
ffffffffc0200ba4:	639c                	ld	a5,0(a5)
ffffffffc0200ba6:	85a6                	mv	a1,s1
ffffffffc0200ba8:	8522                	mv	a0,s0
ffffffffc0200baa:	739c                	ld	a5,32(a5)
ffffffffc0200bac:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0200bae:	6442                	ld	s0,16(sp)
ffffffffc0200bb0:	60e2                	ld	ra,24(sp)
ffffffffc0200bb2:	64a2                	ld	s1,8(sp)
ffffffffc0200bb4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200bb6:	93fff06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200bba <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200bba:	100027f3          	csrr	a5,sstatus
ffffffffc0200bbe:	8b89                	andi	a5,a5,2
ffffffffc0200bc0:	eb89                	bnez	a5,ffffffffc0200bd2 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bc2:	00011797          	auipc	a5,0x11
ffffffffc0200bc6:	8c678793          	addi	a5,a5,-1850 # ffffffffc0211488 <pmm_manager>
ffffffffc0200bca:	639c                	ld	a5,0(a5)
ffffffffc0200bcc:	0287b303          	ld	t1,40(a5)
ffffffffc0200bd0:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200bd2:	1141                	addi	sp,sp,-16
ffffffffc0200bd4:	e406                	sd	ra,8(sp)
ffffffffc0200bd6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200bd8:	923ff0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0200bdc:	00011797          	auipc	a5,0x11
ffffffffc0200be0:	8ac78793          	addi	a5,a5,-1876 # ffffffffc0211488 <pmm_manager>
ffffffffc0200be4:	639c                	ld	a5,0(a5)
ffffffffc0200be6:	779c                	ld	a5,40(a5)
ffffffffc0200be8:	9782                	jalr	a5
ffffffffc0200bea:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bec:	909ff0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200bf0:	8522                	mv	a0,s0
ffffffffc0200bf2:	60a2                	ld	ra,8(sp)
ffffffffc0200bf4:	6402                	ld	s0,0(sp)
ffffffffc0200bf6:	0141                	addi	sp,sp,16
ffffffffc0200bf8:	8082                	ret

ffffffffc0200bfa <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200bfa:	715d                	addi	sp,sp,-80
ffffffffc0200bfc:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bfe:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0200c02:	1ff4f493          	andi	s1,s1,511
ffffffffc0200c06:	048e                	slli	s1,s1,0x3
ffffffffc0200c08:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c0a:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c0c:	f84a                	sd	s2,48(sp)
ffffffffc0200c0e:	f44e                	sd	s3,40(sp)
ffffffffc0200c10:	f052                	sd	s4,32(sp)
ffffffffc0200c12:	e486                	sd	ra,72(sp)
ffffffffc0200c14:	e0a2                	sd	s0,64(sp)
ffffffffc0200c16:	ec56                	sd	s5,24(sp)
ffffffffc0200c18:	e85a                	sd	s6,16(sp)
ffffffffc0200c1a:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c1c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200c20:	892e                	mv	s2,a1
ffffffffc0200c22:	8a32                	mv	s4,a2
ffffffffc0200c24:	00011997          	auipc	s3,0x11
ffffffffc0200c28:	83c98993          	addi	s3,s3,-1988 # ffffffffc0211460 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200c2c:	e3c9                	bnez	a5,ffffffffc0200cae <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c2e:	16060163          	beqz	a2,ffffffffc0200d90 <get_pte+0x196>
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	eb9ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0200c38:	842a                	mv	s0,a0
ffffffffc0200c3a:	14050b63          	beqz	a0,ffffffffc0200d90 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c3e:	00011b97          	auipc	s7,0x11
ffffffffc0200c42:	862b8b93          	addi	s7,s7,-1950 # ffffffffc02114a0 <pages>
ffffffffc0200c46:	000bb503          	ld	a0,0(s7)
ffffffffc0200c4a:	00004797          	auipc	a5,0x4
ffffffffc0200c4e:	39e78793          	addi	a5,a5,926 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0200c52:	0007bb03          	ld	s6,0(a5)
ffffffffc0200c56:	40a40533          	sub	a0,s0,a0
ffffffffc0200c5a:	850d                	srai	a0,a0,0x3
ffffffffc0200c5c:	03650533          	mul	a0,a0,s6
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c60:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c62:	00010997          	auipc	s3,0x10
ffffffffc0200c66:	7fe98993          	addi	s3,s3,2046 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c6a:	00080ab7          	lui	s5,0x80
ffffffffc0200c6e:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c72:	c01c                	sw	a5,0(s0)
ffffffffc0200c74:	57fd                	li	a5,-1
ffffffffc0200c76:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c78:	9556                	add	a0,a0,s5
ffffffffc0200c7a:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c7c:	0532                	slli	a0,a0,0xc
ffffffffc0200c7e:	16e7f063          	bleu	a4,a5,ffffffffc0200dde <get_pte+0x1e4>
ffffffffc0200c82:	00011797          	auipc	a5,0x11
ffffffffc0200c86:	80e78793          	addi	a5,a5,-2034 # ffffffffc0211490 <va_pa_offset>
ffffffffc0200c8a:	639c                	ld	a5,0(a5)
ffffffffc0200c8c:	6605                	lui	a2,0x1
ffffffffc0200c8e:	4581                	li	a1,0
ffffffffc0200c90:	953e                	add	a0,a0,a5
ffffffffc0200c92:	4f4030ef          	jal	ra,ffffffffc0204186 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c96:	000bb683          	ld	a3,0(s7)
ffffffffc0200c9a:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c9e:	868d                	srai	a3,a3,0x3
ffffffffc0200ca0:	036686b3          	mul	a3,a3,s6
ffffffffc0200ca4:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ca6:	06aa                	slli	a3,a3,0xa
ffffffffc0200ca8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200cac:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200cae:	77fd                	lui	a5,0xfffff
ffffffffc0200cb0:	068a                	slli	a3,a3,0x2
ffffffffc0200cb2:	0009b703          	ld	a4,0(s3)
ffffffffc0200cb6:	8efd                	and	a3,a3,a5
ffffffffc0200cb8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200cbc:	0ce7fc63          	bleu	a4,a5,ffffffffc0200d94 <get_pte+0x19a>
ffffffffc0200cc0:	00010a97          	auipc	s5,0x10
ffffffffc0200cc4:	7d0a8a93          	addi	s5,s5,2000 # ffffffffc0211490 <va_pa_offset>
ffffffffc0200cc8:	000ab403          	ld	s0,0(s5)
ffffffffc0200ccc:	01595793          	srli	a5,s2,0x15
ffffffffc0200cd0:	1ff7f793          	andi	a5,a5,511
ffffffffc0200cd4:	96a2                	add	a3,a3,s0
ffffffffc0200cd6:	00379413          	slli	s0,a5,0x3
ffffffffc0200cda:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200cdc:	6014                	ld	a3,0(s0)
ffffffffc0200cde:	0016f793          	andi	a5,a3,1
ffffffffc0200ce2:	ebbd                	bnez	a5,ffffffffc0200d58 <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200ce4:	0a0a0663          	beqz	s4,ffffffffc0200d90 <get_pte+0x196>
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	e03ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0200cee:	84aa                	mv	s1,a0
ffffffffc0200cf0:	c145                	beqz	a0,ffffffffc0200d90 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cf2:	00010b97          	auipc	s7,0x10
ffffffffc0200cf6:	7aeb8b93          	addi	s7,s7,1966 # ffffffffc02114a0 <pages>
ffffffffc0200cfa:	000bb503          	ld	a0,0(s7)
ffffffffc0200cfe:	00004797          	auipc	a5,0x4
ffffffffc0200d02:	2ea78793          	addi	a5,a5,746 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0200d06:	0007bb03          	ld	s6,0(a5)
ffffffffc0200d0a:	40a48533          	sub	a0,s1,a0
ffffffffc0200d0e:	850d                	srai	a0,a0,0x3
ffffffffc0200d10:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d14:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d16:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d1a:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200d1e:	c09c                	sw	a5,0(s1)
ffffffffc0200d20:	57fd                	li	a5,-1
ffffffffc0200d22:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d24:	9552                	add	a0,a0,s4
ffffffffc0200d26:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d28:	0532                	slli	a0,a0,0xc
ffffffffc0200d2a:	08e7fd63          	bleu	a4,a5,ffffffffc0200dc4 <get_pte+0x1ca>
ffffffffc0200d2e:	000ab783          	ld	a5,0(s5)
ffffffffc0200d32:	6605                	lui	a2,0x1
ffffffffc0200d34:	4581                	li	a1,0
ffffffffc0200d36:	953e                	add	a0,a0,a5
ffffffffc0200d38:	44e030ef          	jal	ra,ffffffffc0204186 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d3c:	000bb683          	ld	a3,0(s7)
ffffffffc0200d40:	40d486b3          	sub	a3,s1,a3
ffffffffc0200d44:	868d                	srai	a3,a3,0x3
ffffffffc0200d46:	036686b3          	mul	a3,a3,s6
ffffffffc0200d4a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d4c:	06aa                	slli	a3,a3,0xa
ffffffffc0200d4e:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d52:	e014                	sd	a3,0(s0)
ffffffffc0200d54:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d58:	068a                	slli	a3,a3,0x2
ffffffffc0200d5a:	757d                	lui	a0,0xfffff
ffffffffc0200d5c:	8ee9                	and	a3,a3,a0
ffffffffc0200d5e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d62:	04e7f563          	bleu	a4,a5,ffffffffc0200dac <get_pte+0x1b2>
ffffffffc0200d66:	000ab503          	ld	a0,0(s5)
ffffffffc0200d6a:	00c95793          	srli	a5,s2,0xc
ffffffffc0200d6e:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d72:	96aa                	add	a3,a3,a0
ffffffffc0200d74:	00379513          	slli	a0,a5,0x3
ffffffffc0200d78:	9536                	add	a0,a0,a3
}
ffffffffc0200d7a:	60a6                	ld	ra,72(sp)
ffffffffc0200d7c:	6406                	ld	s0,64(sp)
ffffffffc0200d7e:	74e2                	ld	s1,56(sp)
ffffffffc0200d80:	7942                	ld	s2,48(sp)
ffffffffc0200d82:	79a2                	ld	s3,40(sp)
ffffffffc0200d84:	7a02                	ld	s4,32(sp)
ffffffffc0200d86:	6ae2                	ld	s5,24(sp)
ffffffffc0200d88:	6b42                	ld	s6,16(sp)
ffffffffc0200d8a:	6ba2                	ld	s7,8(sp)
ffffffffc0200d8c:	6161                	addi	sp,sp,80
ffffffffc0200d8e:	8082                	ret
            return NULL;
ffffffffc0200d90:	4501                	li	a0,0
ffffffffc0200d92:	b7e5                	j	ffffffffc0200d7a <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d94:	00004617          	auipc	a2,0x4
ffffffffc0200d98:	25c60613          	addi	a2,a2,604 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0200d9c:	10200593          	li	a1,258
ffffffffc0200da0:	00004517          	auipc	a0,0x4
ffffffffc0200da4:	27850513          	addi	a0,a0,632 # ffffffffc0205018 <commands+0x868>
ffffffffc0200da8:	b5eff0ef          	jal	ra,ffffffffc0200106 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200dac:	00004617          	auipc	a2,0x4
ffffffffc0200db0:	24460613          	addi	a2,a2,580 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0200db4:	10f00593          	li	a1,271
ffffffffc0200db8:	00004517          	auipc	a0,0x4
ffffffffc0200dbc:	26050513          	addi	a0,a0,608 # ffffffffc0205018 <commands+0x868>
ffffffffc0200dc0:	b46ff0ef          	jal	ra,ffffffffc0200106 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dc4:	86aa                	mv	a3,a0
ffffffffc0200dc6:	00004617          	auipc	a2,0x4
ffffffffc0200dca:	22a60613          	addi	a2,a2,554 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0200dce:	10b00593          	li	a1,267
ffffffffc0200dd2:	00004517          	auipc	a0,0x4
ffffffffc0200dd6:	24650513          	addi	a0,a0,582 # ffffffffc0205018 <commands+0x868>
ffffffffc0200dda:	b2cff0ef          	jal	ra,ffffffffc0200106 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200dde:	86aa                	mv	a3,a0
ffffffffc0200de0:	00004617          	auipc	a2,0x4
ffffffffc0200de4:	21060613          	addi	a2,a2,528 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0200de8:	0ff00593          	li	a1,255
ffffffffc0200dec:	00004517          	auipc	a0,0x4
ffffffffc0200df0:	22c50513          	addi	a0,a0,556 # ffffffffc0205018 <commands+0x868>
ffffffffc0200df4:	b12ff0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0200df8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200df8:	1141                	addi	sp,sp,-16
ffffffffc0200dfa:	e022                	sd	s0,0(sp)
ffffffffc0200dfc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200dfe:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e00:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e02:	df9ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e06:	c011                	beqz	s0,ffffffffc0200e0a <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e08:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e0a:	c521                	beqz	a0,ffffffffc0200e52 <get_page+0x5a>
ffffffffc0200e0c:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e0e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e10:	0017f713          	andi	a4,a5,1
ffffffffc0200e14:	e709                	bnez	a4,ffffffffc0200e1e <get_page+0x26>
}
ffffffffc0200e16:	60a2                	ld	ra,8(sp)
ffffffffc0200e18:	6402                	ld	s0,0(sp)
ffffffffc0200e1a:	0141                	addi	sp,sp,16
ffffffffc0200e1c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e1e:	00010717          	auipc	a4,0x10
ffffffffc0200e22:	64270713          	addi	a4,a4,1602 # ffffffffc0211460 <npage>
ffffffffc0200e26:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e28:	078a                	slli	a5,a5,0x2
ffffffffc0200e2a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e2c:	02e7f863          	bleu	a4,a5,ffffffffc0200e5c <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e30:	fff80537          	lui	a0,0xfff80
ffffffffc0200e34:	97aa                	add	a5,a5,a0
ffffffffc0200e36:	00010697          	auipc	a3,0x10
ffffffffc0200e3a:	66a68693          	addi	a3,a3,1642 # ffffffffc02114a0 <pages>
ffffffffc0200e3e:	6288                	ld	a0,0(a3)
ffffffffc0200e40:	60a2                	ld	ra,8(sp)
ffffffffc0200e42:	6402                	ld	s0,0(sp)
ffffffffc0200e44:	00379713          	slli	a4,a5,0x3
ffffffffc0200e48:	97ba                	add	a5,a5,a4
ffffffffc0200e4a:	078e                	slli	a5,a5,0x3
ffffffffc0200e4c:	953e                	add	a0,a0,a5
ffffffffc0200e4e:	0141                	addi	sp,sp,16
ffffffffc0200e50:	8082                	ret
ffffffffc0200e52:	60a2                	ld	ra,8(sp)
ffffffffc0200e54:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0200e56:	4501                	li	a0,0
}
ffffffffc0200e58:	0141                	addi	sp,sp,16
ffffffffc0200e5a:	8082                	ret
ffffffffc0200e5c:	c75ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200e60 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e60:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e62:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200e64:	e406                	sd	ra,8(sp)
ffffffffc0200e66:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e68:	d93ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep != NULL) {
ffffffffc0200e6c:	c511                	beqz	a0,ffffffffc0200e78 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200e6e:	611c                	ld	a5,0(a0)
ffffffffc0200e70:	842a                	mv	s0,a0
ffffffffc0200e72:	0017f713          	andi	a4,a5,1
ffffffffc0200e76:	e709                	bnez	a4,ffffffffc0200e80 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200e78:	60a2                	ld	ra,8(sp)
ffffffffc0200e7a:	6402                	ld	s0,0(sp)
ffffffffc0200e7c:	0141                	addi	sp,sp,16
ffffffffc0200e7e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200e80:	00010717          	auipc	a4,0x10
ffffffffc0200e84:	5e070713          	addi	a4,a4,1504 # ffffffffc0211460 <npage>
ffffffffc0200e88:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e8a:	078a                	slli	a5,a5,0x2
ffffffffc0200e8c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e8e:	04e7f063          	bleu	a4,a5,ffffffffc0200ece <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0200e92:	fff80737          	lui	a4,0xfff80
ffffffffc0200e96:	97ba                	add	a5,a5,a4
ffffffffc0200e98:	00010717          	auipc	a4,0x10
ffffffffc0200e9c:	60870713          	addi	a4,a4,1544 # ffffffffc02114a0 <pages>
ffffffffc0200ea0:	6308                	ld	a0,0(a4)
ffffffffc0200ea2:	00379713          	slli	a4,a5,0x3
ffffffffc0200ea6:	97ba                	add	a5,a5,a4
ffffffffc0200ea8:	078e                	slli	a5,a5,0x3
ffffffffc0200eaa:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200eac:	411c                	lw	a5,0(a0)
ffffffffc0200eae:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200eb2:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200eb4:	cb09                	beqz	a4,ffffffffc0200ec6 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200eb6:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200eba:	12000073          	sfence.vma
}
ffffffffc0200ebe:	60a2                	ld	ra,8(sp)
ffffffffc0200ec0:	6402                	ld	s0,0(sp)
ffffffffc0200ec2:	0141                	addi	sp,sp,16
ffffffffc0200ec4:	8082                	ret
            free_page(page);
ffffffffc0200ec6:	4585                	li	a1,1
ffffffffc0200ec8:	cadff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0200ecc:	b7ed                	j	ffffffffc0200eb6 <page_remove+0x56>
ffffffffc0200ece:	c03ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200ed2 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ed2:	7179                	addi	sp,sp,-48
ffffffffc0200ed4:	87b2                	mv	a5,a2
ffffffffc0200ed6:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ed8:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200eda:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200edc:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200ede:	ec26                	sd	s1,24(sp)
ffffffffc0200ee0:	f406                	sd	ra,40(sp)
ffffffffc0200ee2:	e84a                	sd	s2,16(sp)
ffffffffc0200ee4:	e44e                	sd	s3,8(sp)
ffffffffc0200ee6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200ee8:	d13ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    if (ptep == NULL) {
ffffffffc0200eec:	c945                	beqz	a0,ffffffffc0200f9c <page_insert+0xca>
    page->ref += 1;
ffffffffc0200eee:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0200ef0:	611c                	ld	a5,0(a0)
ffffffffc0200ef2:	892a                	mv	s2,a0
ffffffffc0200ef4:	0016871b          	addiw	a4,a3,1
ffffffffc0200ef8:	c018                	sw	a4,0(s0)
ffffffffc0200efa:	0017f713          	andi	a4,a5,1
ffffffffc0200efe:	e339                	bnez	a4,ffffffffc0200f44 <page_insert+0x72>
ffffffffc0200f00:	00010797          	auipc	a5,0x10
ffffffffc0200f04:	5a078793          	addi	a5,a5,1440 # ffffffffc02114a0 <pages>
ffffffffc0200f08:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f0a:	00004717          	auipc	a4,0x4
ffffffffc0200f0e:	0de70713          	addi	a4,a4,222 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0200f12:	40f407b3          	sub	a5,s0,a5
ffffffffc0200f16:	6300                	ld	s0,0(a4)
ffffffffc0200f18:	878d                	srai	a5,a5,0x3
ffffffffc0200f1a:	000806b7          	lui	a3,0x80
ffffffffc0200f1e:	028787b3          	mul	a5,a5,s0
ffffffffc0200f22:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f24:	07aa                	slli	a5,a5,0xa
ffffffffc0200f26:	8fc5                	or	a5,a5,s1
ffffffffc0200f28:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f2c:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f30:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0200f34:	4501                	li	a0,0
}
ffffffffc0200f36:	70a2                	ld	ra,40(sp)
ffffffffc0200f38:	7402                	ld	s0,32(sp)
ffffffffc0200f3a:	64e2                	ld	s1,24(sp)
ffffffffc0200f3c:	6942                	ld	s2,16(sp)
ffffffffc0200f3e:	69a2                	ld	s3,8(sp)
ffffffffc0200f40:	6145                	addi	sp,sp,48
ffffffffc0200f42:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0200f44:	00010717          	auipc	a4,0x10
ffffffffc0200f48:	51c70713          	addi	a4,a4,1308 # ffffffffc0211460 <npage>
ffffffffc0200f4c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f4e:	00279513          	slli	a0,a5,0x2
ffffffffc0200f52:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f54:	04e57663          	bleu	a4,a0,ffffffffc0200fa0 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f58:	fff807b7          	lui	a5,0xfff80
ffffffffc0200f5c:	953e                	add	a0,a0,a5
ffffffffc0200f5e:	00010997          	auipc	s3,0x10
ffffffffc0200f62:	54298993          	addi	s3,s3,1346 # ffffffffc02114a0 <pages>
ffffffffc0200f66:	0009b783          	ld	a5,0(s3)
ffffffffc0200f6a:	00351713          	slli	a4,a0,0x3
ffffffffc0200f6e:	953a                	add	a0,a0,a4
ffffffffc0200f70:	050e                	slli	a0,a0,0x3
ffffffffc0200f72:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0200f74:	00a40e63          	beq	s0,a0,ffffffffc0200f90 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0200f78:	411c                	lw	a5,0(a0)
ffffffffc0200f7a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f7e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f80:	cb11                	beqz	a4,ffffffffc0200f94 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f82:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0200f86:	12000073          	sfence.vma
ffffffffc0200f8a:	0009b783          	ld	a5,0(s3)
ffffffffc0200f8e:	bfb5                	j	ffffffffc0200f0a <page_insert+0x38>
    page->ref -= 1;
ffffffffc0200f90:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200f92:	bfa5                	j	ffffffffc0200f0a <page_insert+0x38>
            free_page(page);
ffffffffc0200f94:	4585                	li	a1,1
ffffffffc0200f96:	bdfff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0200f9a:	b7e5                	j	ffffffffc0200f82 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0200f9c:	5571                	li	a0,-4
ffffffffc0200f9e:	bf61                	j	ffffffffc0200f36 <page_insert+0x64>
ffffffffc0200fa0:	b31ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>

ffffffffc0200fa4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fa4:	00005797          	auipc	a5,0x5
ffffffffc0200fa8:	0dc78793          	addi	a5,a5,220 # ffffffffc0206080 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fac:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200fae:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fb0:	00004517          	auipc	a0,0x4
ffffffffc0200fb4:	10050513          	addi	a0,a0,256 # ffffffffc02050b0 <commands+0x900>
void pmm_init(void) {
ffffffffc0200fb8:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fba:	00010717          	auipc	a4,0x10
ffffffffc0200fbe:	4cf73723          	sd	a5,1230(a4) # ffffffffc0211488 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fc2:	e8a2                	sd	s0,80(sp)
ffffffffc0200fc4:	e4a6                	sd	s1,72(sp)
ffffffffc0200fc6:	e0ca                	sd	s2,64(sp)
ffffffffc0200fc8:	fc4e                	sd	s3,56(sp)
ffffffffc0200fca:	f852                	sd	s4,48(sp)
ffffffffc0200fcc:	f456                	sd	s5,40(sp)
ffffffffc0200fce:	f05a                	sd	s6,32(sp)
ffffffffc0200fd0:	ec5e                	sd	s7,24(sp)
ffffffffc0200fd2:	e862                	sd	s8,16(sp)
ffffffffc0200fd4:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0200fd6:	00010417          	auipc	s0,0x10
ffffffffc0200fda:	4b240413          	addi	s0,s0,1202 # ffffffffc0211488 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fde:	8e0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0200fe2:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0200fe4:	49c5                	li	s3,17
ffffffffc0200fe6:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0200fea:	679c                	ld	a5,8(a5)
ffffffffc0200fec:	00010497          	auipc	s1,0x10
ffffffffc0200ff0:	47448493          	addi	s1,s1,1140 # ffffffffc0211460 <npage>
ffffffffc0200ff4:	00010917          	auipc	s2,0x10
ffffffffc0200ff8:	4ac90913          	addi	s2,s2,1196 # ffffffffc02114a0 <pages>
ffffffffc0200ffc:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200ffe:	57f5                	li	a5,-3
ffffffffc0201000:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201002:	07e006b7          	lui	a3,0x7e00
ffffffffc0201006:	01b99613          	slli	a2,s3,0x1b
ffffffffc020100a:	015a1593          	slli	a1,s4,0x15
ffffffffc020100e:	00004517          	auipc	a0,0x4
ffffffffc0201012:	0ba50513          	addi	a0,a0,186 # ffffffffc02050c8 <commands+0x918>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201016:	00010717          	auipc	a4,0x10
ffffffffc020101a:	46f73d23          	sd	a5,1146(a4) # ffffffffc0211490 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020101e:	8a0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201022:	00004517          	auipc	a0,0x4
ffffffffc0201026:	0d650513          	addi	a0,a0,214 # ffffffffc02050f8 <commands+0x948>
ffffffffc020102a:	894ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020102e:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201032:	16fd                	addi	a3,a3,-1
ffffffffc0201034:	015a1613          	slli	a2,s4,0x15
ffffffffc0201038:	07e005b7          	lui	a1,0x7e00
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	0d450513          	addi	a0,a0,212 # ffffffffc0205110 <commands+0x960>
ffffffffc0201044:	87aff0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201048:	777d                	lui	a4,0xfffff
ffffffffc020104a:	00011797          	auipc	a5,0x11
ffffffffc020104e:	55578793          	addi	a5,a5,1365 # ffffffffc021259f <end+0xfff>
ffffffffc0201052:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201054:	00088737          	lui	a4,0x88
ffffffffc0201058:	00010697          	auipc	a3,0x10
ffffffffc020105c:	40e6b423          	sd	a4,1032(a3) # ffffffffc0211460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201060:	00010717          	auipc	a4,0x10
ffffffffc0201064:	44f73023          	sd	a5,1088(a4) # ffffffffc02114a0 <pages>
ffffffffc0201068:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020106a:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020106c:	4585                	li	a1,1
ffffffffc020106e:	fff80637          	lui	a2,0xfff80
ffffffffc0201072:	a019                	j	ffffffffc0201078 <pmm_init+0xd4>
ffffffffc0201074:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201078:	97b6                	add	a5,a5,a3
ffffffffc020107a:	07a1                	addi	a5,a5,8
ffffffffc020107c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201080:	609c                	ld	a5,0(s1)
ffffffffc0201082:	0705                	addi	a4,a4,1
ffffffffc0201084:	04868693          	addi	a3,a3,72
ffffffffc0201088:	00c78533          	add	a0,a5,a2
ffffffffc020108c:	fea764e3          	bltu	a4,a0,ffffffffc0201074 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201090:	00093503          	ld	a0,0(s2)
ffffffffc0201094:	00379693          	slli	a3,a5,0x3
ffffffffc0201098:	96be                	add	a3,a3,a5
ffffffffc020109a:	fdc00737          	lui	a4,0xfdc00
ffffffffc020109e:	972a                	add	a4,a4,a0
ffffffffc02010a0:	068e                	slli	a3,a3,0x3
ffffffffc02010a2:	96ba                	add	a3,a3,a4
ffffffffc02010a4:	c0200737          	lui	a4,0xc0200
ffffffffc02010a8:	58e6ea63          	bltu	a3,a4,ffffffffc020163c <pmm_init+0x698>
ffffffffc02010ac:	00010997          	auipc	s3,0x10
ffffffffc02010b0:	3e498993          	addi	s3,s3,996 # ffffffffc0211490 <va_pa_offset>
ffffffffc02010b4:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02010b8:	45c5                	li	a1,17
ffffffffc02010ba:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010bc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02010be:	44b6ef63          	bltu	a3,a1,ffffffffc020151c <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02010c2:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010c4:	00010417          	auipc	s0,0x10
ffffffffc02010c8:	39440413          	addi	s0,s0,916 # ffffffffc0211458 <boot_pgdir>
    pmm_manager->check();
ffffffffc02010cc:	7b9c                	ld	a5,48(a5)
ffffffffc02010ce:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02010d0:	00004517          	auipc	a0,0x4
ffffffffc02010d4:	09050513          	addi	a0,a0,144 # ffffffffc0205160 <commands+0x9b0>
ffffffffc02010d8:	fe7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02010dc:	00008697          	auipc	a3,0x8
ffffffffc02010e0:	f2468693          	addi	a3,a3,-220 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02010e4:	00010797          	auipc	a5,0x10
ffffffffc02010e8:	36d7ba23          	sd	a3,884(a5) # ffffffffc0211458 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02010ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02010f0:	0ef6ece3          	bltu	a3,a5,ffffffffc02019e8 <pmm_init+0xa44>
ffffffffc02010f4:	0009b783          	ld	a5,0(s3)
ffffffffc02010f8:	8e9d                	sub	a3,a3,a5
ffffffffc02010fa:	00010797          	auipc	a5,0x10
ffffffffc02010fe:	38d7bf23          	sd	a3,926(a5) # ffffffffc0211498 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201102:	ab9ff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201106:	6098                	ld	a4,0(s1)
ffffffffc0201108:	c80007b7          	lui	a5,0xc8000
ffffffffc020110c:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020110e:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201110:	0ae7ece3          	bltu	a5,a4,ffffffffc02019c8 <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201114:	6008                	ld	a0,0(s0)
ffffffffc0201116:	4c050363          	beqz	a0,ffffffffc02015dc <pmm_init+0x638>
ffffffffc020111a:	6785                	lui	a5,0x1
ffffffffc020111c:	17fd                	addi	a5,a5,-1
ffffffffc020111e:	8fe9                	and	a5,a5,a0
ffffffffc0201120:	2781                	sext.w	a5,a5
ffffffffc0201122:	4a079d63          	bnez	a5,ffffffffc02015dc <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201126:	4601                	li	a2,0
ffffffffc0201128:	4581                	li	a1,0
ffffffffc020112a:	ccfff0ef          	jal	ra,ffffffffc0200df8 <get_page>
ffffffffc020112e:	4c051763          	bnez	a0,ffffffffc02015fc <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201132:	4505                	li	a0,1
ffffffffc0201134:	9b9ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0201138:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020113a:	6008                	ld	a0,0(s0)
ffffffffc020113c:	4681                	li	a3,0
ffffffffc020113e:	4601                	li	a2,0
ffffffffc0201140:	85d6                	mv	a1,s5
ffffffffc0201142:	d91ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc0201146:	52051763          	bnez	a0,ffffffffc0201674 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020114a:	6008                	ld	a0,0(s0)
ffffffffc020114c:	4601                	li	a2,0
ffffffffc020114e:	4581                	li	a1,0
ffffffffc0201150:	aabff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc0201154:	50050063          	beqz	a0,ffffffffc0201654 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201158:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020115a:	0017f713          	andi	a4,a5,1
ffffffffc020115e:	46070363          	beqz	a4,ffffffffc02015c4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201162:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201164:	078a                	slli	a5,a5,0x2
ffffffffc0201166:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201168:	44c7f063          	bleu	a2,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020116c:	fff80737          	lui	a4,0xfff80
ffffffffc0201170:	97ba                	add	a5,a5,a4
ffffffffc0201172:	00379713          	slli	a4,a5,0x3
ffffffffc0201176:	00093683          	ld	a3,0(s2)
ffffffffc020117a:	97ba                	add	a5,a5,a4
ffffffffc020117c:	078e                	slli	a5,a5,0x3
ffffffffc020117e:	97b6                	add	a5,a5,a3
ffffffffc0201180:	5efa9463          	bne	s5,a5,ffffffffc0201768 <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201184:	000aab83          	lw	s7,0(s5)
ffffffffc0201188:	4785                	li	a5,1
ffffffffc020118a:	5afb9f63          	bne	s7,a5,ffffffffc0201748 <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020118e:	6008                	ld	a0,0(s0)
ffffffffc0201190:	76fd                	lui	a3,0xfffff
ffffffffc0201192:	611c                	ld	a5,0(a0)
ffffffffc0201194:	078a                	slli	a5,a5,0x2
ffffffffc0201196:	8ff5                	and	a5,a5,a3
ffffffffc0201198:	00c7d713          	srli	a4,a5,0xc
ffffffffc020119c:	58c77963          	bleu	a2,a4,ffffffffc020172e <pmm_init+0x78a>
ffffffffc02011a0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011a4:	97e2                	add	a5,a5,s8
ffffffffc02011a6:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02011aa:	0b0a                	slli	s6,s6,0x2
ffffffffc02011ac:	00db7b33          	and	s6,s6,a3
ffffffffc02011b0:	00cb5793          	srli	a5,s6,0xc
ffffffffc02011b4:	56c7f063          	bleu	a2,a5,ffffffffc0201714 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011b8:	4601                	li	a2,0
ffffffffc02011ba:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011bc:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011be:	a3dff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011c2:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011c4:	53651863          	bne	a0,s6,ffffffffc02016f4 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc02011c8:	4505                	li	a0,1
ffffffffc02011ca:	923ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02011ce:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02011d0:	6008                	ld	a0,0(s0)
ffffffffc02011d2:	46d1                	li	a3,20
ffffffffc02011d4:	6605                	lui	a2,0x1
ffffffffc02011d6:	85da                	mv	a1,s6
ffffffffc02011d8:	cfbff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02011dc:	4e051c63          	bnez	a0,ffffffffc02016d4 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02011e0:	6008                	ld	a0,0(s0)
ffffffffc02011e2:	4601                	li	a2,0
ffffffffc02011e4:	6585                	lui	a1,0x1
ffffffffc02011e6:	a15ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc02011ea:	4c050563          	beqz	a0,ffffffffc02016b4 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc02011ee:	611c                	ld	a5,0(a0)
ffffffffc02011f0:	0107f713          	andi	a4,a5,16
ffffffffc02011f4:	4a070063          	beqz	a4,ffffffffc0201694 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc02011f8:	8b91                	andi	a5,a5,4
ffffffffc02011fa:	66078763          	beqz	a5,ffffffffc0201868 <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02011fe:	6008                	ld	a0,0(s0)
ffffffffc0201200:	611c                	ld	a5,0(a0)
ffffffffc0201202:	8bc1                	andi	a5,a5,16
ffffffffc0201204:	64078263          	beqz	a5,ffffffffc0201848 <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201208:	000b2783          	lw	a5,0(s6)
ffffffffc020120c:	61779e63          	bne	a5,s7,ffffffffc0201828 <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201210:	4681                	li	a3,0
ffffffffc0201212:	6605                	lui	a2,0x1
ffffffffc0201214:	85d6                	mv	a1,s5
ffffffffc0201216:	cbdff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc020121a:	5e051763          	bnez	a0,ffffffffc0201808 <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc020121e:	000aa703          	lw	a4,0(s5)
ffffffffc0201222:	4789                	li	a5,2
ffffffffc0201224:	5cf71263          	bne	a4,a5,ffffffffc02017e8 <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201228:	000b2783          	lw	a5,0(s6)
ffffffffc020122c:	58079e63          	bnez	a5,ffffffffc02017c8 <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201230:	6008                	ld	a0,0(s0)
ffffffffc0201232:	4601                	li	a2,0
ffffffffc0201234:	6585                	lui	a1,0x1
ffffffffc0201236:	9c5ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc020123a:	56050763          	beqz	a0,ffffffffc02017a8 <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc020123e:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201240:	0016f793          	andi	a5,a3,1
ffffffffc0201244:	38078063          	beqz	a5,ffffffffc02015c4 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201248:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020124a:	00269793          	slli	a5,a3,0x2
ffffffffc020124e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201250:	34e7fc63          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201254:	fff80737          	lui	a4,0xfff80
ffffffffc0201258:	97ba                	add	a5,a5,a4
ffffffffc020125a:	00379713          	slli	a4,a5,0x3
ffffffffc020125e:	00093603          	ld	a2,0(s2)
ffffffffc0201262:	97ba                	add	a5,a5,a4
ffffffffc0201264:	078e                	slli	a5,a5,0x3
ffffffffc0201266:	97b2                	add	a5,a5,a2
ffffffffc0201268:	52fa9063          	bne	s5,a5,ffffffffc0201788 <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc020126c:	8ac1                	andi	a3,a3,16
ffffffffc020126e:	6e069d63          	bnez	a3,ffffffffc0201968 <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201272:	6008                	ld	a0,0(s0)
ffffffffc0201274:	4581                	li	a1,0
ffffffffc0201276:	bebff0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020127a:	000aa703          	lw	a4,0(s5)
ffffffffc020127e:	4785                	li	a5,1
ffffffffc0201280:	6cf71463          	bne	a4,a5,ffffffffc0201948 <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201284:	000b2783          	lw	a5,0(s6)
ffffffffc0201288:	6a079063          	bnez	a5,ffffffffc0201928 <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020128c:	6008                	ld	a0,0(s0)
ffffffffc020128e:	6585                	lui	a1,0x1
ffffffffc0201290:	bd1ff0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201294:	000aa783          	lw	a5,0(s5)
ffffffffc0201298:	66079863          	bnez	a5,ffffffffc0201908 <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc020129c:	000b2783          	lw	a5,0(s6)
ffffffffc02012a0:	70079463          	bnez	a5,ffffffffc02019a8 <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012a4:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02012a8:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012aa:	000b3783          	ld	a5,0(s6)
ffffffffc02012ae:	078a                	slli	a5,a5,0x2
ffffffffc02012b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012b2:	2eb7fb63          	bleu	a1,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02012b6:	fff80737          	lui	a4,0xfff80
ffffffffc02012ba:	973e                	add	a4,a4,a5
ffffffffc02012bc:	00371793          	slli	a5,a4,0x3
ffffffffc02012c0:	00093603          	ld	a2,0(s2)
ffffffffc02012c4:	97ba                	add	a5,a5,a4
ffffffffc02012c6:	078e                	slli	a5,a5,0x3
ffffffffc02012c8:	00f60733          	add	a4,a2,a5
ffffffffc02012cc:	4314                	lw	a3,0(a4)
ffffffffc02012ce:	4705                	li	a4,1
ffffffffc02012d0:	6ae69c63          	bne	a3,a4,ffffffffc0201988 <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012d4:	00004a97          	auipc	s5,0x4
ffffffffc02012d8:	d14a8a93          	addi	s5,s5,-748 # ffffffffc0204fe8 <commands+0x838>
ffffffffc02012dc:	000ab703          	ld	a4,0(s5)
ffffffffc02012e0:	4037d693          	srai	a3,a5,0x3
ffffffffc02012e4:	00080bb7          	lui	s7,0x80
ffffffffc02012e8:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012ec:	577d                	li	a4,-1
ffffffffc02012ee:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02012f0:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012f2:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02012f4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02012f6:	2ab77b63          	bleu	a1,a4,ffffffffc02015ac <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02012fa:	0009b783          	ld	a5,0(s3)
ffffffffc02012fe:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201300:	629c                	ld	a5,0(a3)
ffffffffc0201302:	078a                	slli	a5,a5,0x2
ffffffffc0201304:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201306:	2ab7f163          	bleu	a1,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020130a:	417787b3          	sub	a5,a5,s7
ffffffffc020130e:	00379513          	slli	a0,a5,0x3
ffffffffc0201312:	97aa                	add	a5,a5,a0
ffffffffc0201314:	00379513          	slli	a0,a5,0x3
ffffffffc0201318:	9532                	add	a0,a0,a2
ffffffffc020131a:	4585                	li	a1,1
ffffffffc020131c:	859ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201320:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201324:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201326:	050a                	slli	a0,a0,0x2
ffffffffc0201328:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020132a:	26f57f63          	bleu	a5,a0,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020132e:	417507b3          	sub	a5,a0,s7
ffffffffc0201332:	00379513          	slli	a0,a5,0x3
ffffffffc0201336:	00093703          	ld	a4,0(s2)
ffffffffc020133a:	953e                	add	a0,a0,a5
ffffffffc020133c:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc020133e:	4585                	li	a1,1
ffffffffc0201340:	953a                	add	a0,a0,a4
ffffffffc0201342:	833ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201346:	601c                	ld	a5,0(s0)
ffffffffc0201348:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc020134c:	86fff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201350:	2caa1663          	bne	s4,a0,ffffffffc020161c <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201354:	00004517          	auipc	a0,0x4
ffffffffc0201358:	13450513          	addi	a0,a0,308 # ffffffffc0205488 <commands+0xcd8>
ffffffffc020135c:	d63fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201360:	85bff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201364:	6098                	ld	a4,0(s1)
ffffffffc0201366:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc020136a:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020136c:	00c71693          	slli	a3,a4,0xc
ffffffffc0201370:	1cd7fd63          	bleu	a3,a5,ffffffffc020154a <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201374:	83b1                	srli	a5,a5,0xc
ffffffffc0201376:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201378:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020137c:	1ce7f963          	bleu	a4,a5,ffffffffc020154e <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201380:	7c7d                	lui	s8,0xfffff
ffffffffc0201382:	6b85                	lui	s7,0x1
ffffffffc0201384:	a029                	j	ffffffffc020138e <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201386:	00ca5713          	srli	a4,s4,0xc
ffffffffc020138a:	1cf77263          	bleu	a5,a4,ffffffffc020154e <pmm_init+0x5aa>
ffffffffc020138e:	0009b583          	ld	a1,0(s3)
ffffffffc0201392:	4601                	li	a2,0
ffffffffc0201394:	95d2                	add	a1,a1,s4
ffffffffc0201396:	865ff0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc020139a:	1c050763          	beqz	a0,ffffffffc0201568 <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020139e:	611c                	ld	a5,0(a0)
ffffffffc02013a0:	078a                	slli	a5,a5,0x2
ffffffffc02013a2:	0187f7b3          	and	a5,a5,s8
ffffffffc02013a6:	1f479163          	bne	a5,s4,ffffffffc0201588 <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013aa:	609c                	ld	a5,0(s1)
ffffffffc02013ac:	9a5e                	add	s4,s4,s7
ffffffffc02013ae:	6008                	ld	a0,0(s0)
ffffffffc02013b0:	00c79713          	slli	a4,a5,0xc
ffffffffc02013b4:	fcea69e3          	bltu	s4,a4,ffffffffc0201386 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02013b8:	611c                	ld	a5,0(a0)
ffffffffc02013ba:	6a079363          	bnez	a5,ffffffffc0201a60 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc02013be:	4505                	li	a0,1
ffffffffc02013c0:	f2cff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02013c4:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02013c6:	6008                	ld	a0,0(s0)
ffffffffc02013c8:	4699                	li	a3,6
ffffffffc02013ca:	10000613          	li	a2,256
ffffffffc02013ce:	85d2                	mv	a1,s4
ffffffffc02013d0:	b03ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02013d4:	66051663          	bnez	a0,ffffffffc0201a40 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc02013d8:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc02013dc:	4785                	li	a5,1
ffffffffc02013de:	64f71163          	bne	a4,a5,ffffffffc0201a20 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02013e2:	6008                	ld	a0,0(s0)
ffffffffc02013e4:	6b85                	lui	s7,0x1
ffffffffc02013e6:	4699                	li	a3,6
ffffffffc02013e8:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc02013ec:	85d2                	mv	a1,s4
ffffffffc02013ee:	ae5ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc02013f2:	60051763          	bnez	a0,ffffffffc0201a00 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc02013f6:	000a2703          	lw	a4,0(s4)
ffffffffc02013fa:	4789                	li	a5,2
ffffffffc02013fc:	4ef71663          	bne	a4,a5,ffffffffc02018e8 <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201400:	00004597          	auipc	a1,0x4
ffffffffc0201404:	1c058593          	addi	a1,a1,448 # ffffffffc02055c0 <commands+0xe10>
ffffffffc0201408:	10000513          	li	a0,256
ffffffffc020140c:	521020ef          	jal	ra,ffffffffc020412c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201410:	100b8593          	addi	a1,s7,256
ffffffffc0201414:	10000513          	li	a0,256
ffffffffc0201418:	527020ef          	jal	ra,ffffffffc020413e <strcmp>
ffffffffc020141c:	4a051663          	bnez	a0,ffffffffc02018c8 <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201420:	00093683          	ld	a3,0(s2)
ffffffffc0201424:	000abc83          	ld	s9,0(s5)
ffffffffc0201428:	00080c37          	lui	s8,0x80
ffffffffc020142c:	40da06b3          	sub	a3,s4,a3
ffffffffc0201430:	868d                	srai	a3,a3,0x3
ffffffffc0201432:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201436:	5afd                	li	s5,-1
ffffffffc0201438:	609c                	ld	a5,0(s1)
ffffffffc020143a:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020143e:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201440:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201444:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201446:	16f77363          	bleu	a5,a4,ffffffffc02015ac <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020144a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020144e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201452:	96be                	add	a3,a3,a5
ffffffffc0201454:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201458:	491020ef          	jal	ra,ffffffffc02040e8 <strlen>
ffffffffc020145c:	44051663          	bnez	a0,ffffffffc02018a8 <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201460:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201464:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201466:	000bb783          	ld	a5,0(s7)
ffffffffc020146a:	078a                	slli	a5,a5,0x2
ffffffffc020146c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020146e:	12e7fd63          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201472:	418787b3          	sub	a5,a5,s8
ffffffffc0201476:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020147a:	96be                	add	a3,a3,a5
ffffffffc020147c:	039686b3          	mul	a3,a3,s9
ffffffffc0201480:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201482:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201486:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201488:	12eaf263          	bleu	a4,s5,ffffffffc02015ac <pmm_init+0x608>
ffffffffc020148c:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201490:	4585                	li	a1,1
ffffffffc0201492:	8552                	mv	a0,s4
ffffffffc0201494:	99b6                	add	s3,s3,a3
ffffffffc0201496:	edeff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020149a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020149e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a0:	078a                	slli	a5,a5,0x2
ffffffffc02014a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014a4:	10e7f263          	bleu	a4,a5,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02014a8:	fff809b7          	lui	s3,0xfff80
ffffffffc02014ac:	97ce                	add	a5,a5,s3
ffffffffc02014ae:	00379513          	slli	a0,a5,0x3
ffffffffc02014b2:	00093703          	ld	a4,0(s2)
ffffffffc02014b6:	97aa                	add	a5,a5,a0
ffffffffc02014b8:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc02014bc:	953a                	add	a0,a0,a4
ffffffffc02014be:	4585                	li	a1,1
ffffffffc02014c0:	eb4ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014c4:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014c8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014ca:	050a                	slli	a0,a0,0x2
ffffffffc02014cc:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ce:	0cf57d63          	bleu	a5,a0,ffffffffc02015a8 <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc02014d2:	013507b3          	add	a5,a0,s3
ffffffffc02014d6:	00379513          	slli	a0,a5,0x3
ffffffffc02014da:	00093703          	ld	a4,0(s2)
ffffffffc02014de:	953e                	add	a0,a0,a5
ffffffffc02014e0:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc02014e2:	4585                	li	a1,1
ffffffffc02014e4:	953a                	add	a0,a0,a4
ffffffffc02014e6:	e8eff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014ea:	601c                	ld	a5,0(s0)
ffffffffc02014ec:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02014f0:	ecaff0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc02014f4:	38ab1a63          	bne	s6,a0,ffffffffc0201888 <pmm_init+0x8e4>
}
ffffffffc02014f8:	6446                	ld	s0,80(sp)
ffffffffc02014fa:	60e6                	ld	ra,88(sp)
ffffffffc02014fc:	64a6                	ld	s1,72(sp)
ffffffffc02014fe:	6906                	ld	s2,64(sp)
ffffffffc0201500:	79e2                	ld	s3,56(sp)
ffffffffc0201502:	7a42                	ld	s4,48(sp)
ffffffffc0201504:	7aa2                	ld	s5,40(sp)
ffffffffc0201506:	7b02                	ld	s6,32(sp)
ffffffffc0201508:	6be2                	ld	s7,24(sp)
ffffffffc020150a:	6c42                	ld	s8,16(sp)
ffffffffc020150c:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020150e:	00004517          	auipc	a0,0x4
ffffffffc0201512:	12a50513          	addi	a0,a0,298 # ffffffffc0205638 <commands+0xe88>
}
ffffffffc0201516:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0201518:	ba7fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020151c:	6705                	lui	a4,0x1
ffffffffc020151e:	177d                	addi	a4,a4,-1
ffffffffc0201520:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0201522:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201526:	08f77163          	bleu	a5,a4,ffffffffc02015a8 <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc020152a:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc020152e:	9732                	add	a4,a4,a2
ffffffffc0201530:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201534:	767d                	lui	a2,0xfffff
ffffffffc0201536:	8ef1                	and	a3,a3,a2
ffffffffc0201538:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020153a:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020153e:	8d95                	sub	a1,a1,a3
ffffffffc0201540:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201542:	81b1                	srli	a1,a1,0xc
ffffffffc0201544:	953e                	add	a0,a0,a5
ffffffffc0201546:	9702                	jalr	a4
ffffffffc0201548:	bead                	j	ffffffffc02010c2 <pmm_init+0x11e>
ffffffffc020154a:	6008                	ld	a0,0(s0)
ffffffffc020154c:	b5b5                	j	ffffffffc02013b8 <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020154e:	86d2                	mv	a3,s4
ffffffffc0201550:	00004617          	auipc	a2,0x4
ffffffffc0201554:	aa060613          	addi	a2,a2,-1376 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0201558:	1cd00593          	li	a1,461
ffffffffc020155c:	00004517          	auipc	a0,0x4
ffffffffc0201560:	abc50513          	addi	a0,a0,-1348 # ffffffffc0205018 <commands+0x868>
ffffffffc0201564:	ba3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	f4068693          	addi	a3,a3,-192 # ffffffffc02054a8 <commands+0xcf8>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	c3060613          	addi	a2,a2,-976 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201578:	1cd00593          	li	a1,461
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0205018 <commands+0x868>
ffffffffc0201584:	b83fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201588:	00004697          	auipc	a3,0x4
ffffffffc020158c:	f6068693          	addi	a3,a3,-160 # ffffffffc02054e8 <commands+0xd38>
ffffffffc0201590:	00004617          	auipc	a2,0x4
ffffffffc0201594:	c1060613          	addi	a2,a2,-1008 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201598:	1ce00593          	li	a1,462
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205018 <commands+0x868>
ffffffffc02015a4:	b63fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02015a8:	d28ff0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02015ac:	00004617          	auipc	a2,0x4
ffffffffc02015b0:	a4460613          	addi	a2,a2,-1468 # ffffffffc0204ff0 <commands+0x840>
ffffffffc02015b4:	06a00593          	li	a1,106
ffffffffc02015b8:	00004517          	auipc	a0,0x4
ffffffffc02015bc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0205088 <commands+0x8d8>
ffffffffc02015c0:	b47fe0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02015c4:	00004617          	auipc	a2,0x4
ffffffffc02015c8:	cb460613          	addi	a2,a2,-844 # ffffffffc0205278 <commands+0xac8>
ffffffffc02015cc:	07000593          	li	a1,112
ffffffffc02015d0:	00004517          	auipc	a0,0x4
ffffffffc02015d4:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205088 <commands+0x8d8>
ffffffffc02015d8:	b2ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02015dc:	00004697          	auipc	a3,0x4
ffffffffc02015e0:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02051b8 <commands+0xa08>
ffffffffc02015e4:	00004617          	auipc	a2,0x4
ffffffffc02015e8:	bbc60613          	addi	a2,a2,-1092 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02015ec:	19300593          	li	a1,403
ffffffffc02015f0:	00004517          	auipc	a0,0x4
ffffffffc02015f4:	a2850513          	addi	a0,a0,-1496 # ffffffffc0205018 <commands+0x868>
ffffffffc02015f8:	b0ffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02015fc:	00004697          	auipc	a3,0x4
ffffffffc0201600:	bf468693          	addi	a3,a3,-1036 # ffffffffc02051f0 <commands+0xa40>
ffffffffc0201604:	00004617          	auipc	a2,0x4
ffffffffc0201608:	b9c60613          	addi	a2,a2,-1124 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc020160c:	19400593          	li	a1,404
ffffffffc0201610:	00004517          	auipc	a0,0x4
ffffffffc0201614:	a0850513          	addi	a0,a0,-1528 # ffffffffc0205018 <commands+0x868>
ffffffffc0201618:	aeffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020161c:	00004697          	auipc	a3,0x4
ffffffffc0201620:	e4c68693          	addi	a3,a3,-436 # ffffffffc0205468 <commands+0xcb8>
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	b7c60613          	addi	a2,a2,-1156 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc020162c:	1c000593          	li	a1,448
ffffffffc0201630:	00004517          	auipc	a0,0x4
ffffffffc0201634:	9e850513          	addi	a0,a0,-1560 # ffffffffc0205018 <commands+0x868>
ffffffffc0201638:	acffe0ef          	jal	ra,ffffffffc0200106 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020163c:	00004617          	auipc	a2,0x4
ffffffffc0201640:	afc60613          	addi	a2,a2,-1284 # ffffffffc0205138 <commands+0x988>
ffffffffc0201644:	07700593          	li	a1,119
ffffffffc0201648:	00004517          	auipc	a0,0x4
ffffffffc020164c:	9d050513          	addi	a0,a0,-1584 # ffffffffc0205018 <commands+0x868>
ffffffffc0201650:	ab7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201654:	00004697          	auipc	a3,0x4
ffffffffc0201658:	bf468693          	addi	a3,a3,-1036 # ffffffffc0205248 <commands+0xa98>
ffffffffc020165c:	00004617          	auipc	a2,0x4
ffffffffc0201660:	b4460613          	addi	a2,a2,-1212 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201664:	19a00593          	li	a1,410
ffffffffc0201668:	00004517          	auipc	a0,0x4
ffffffffc020166c:	9b050513          	addi	a0,a0,-1616 # ffffffffc0205018 <commands+0x868>
ffffffffc0201670:	a97fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201674:	00004697          	auipc	a3,0x4
ffffffffc0201678:	ba468693          	addi	a3,a3,-1116 # ffffffffc0205218 <commands+0xa68>
ffffffffc020167c:	00004617          	auipc	a2,0x4
ffffffffc0201680:	b2460613          	addi	a2,a2,-1244 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201684:	19800593          	li	a1,408
ffffffffc0201688:	00004517          	auipc	a0,0x4
ffffffffc020168c:	99050513          	addi	a0,a0,-1648 # ffffffffc0205018 <commands+0x868>
ffffffffc0201690:	a77fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0201694:	00004697          	auipc	a3,0x4
ffffffffc0201698:	ccc68693          	addi	a3,a3,-820 # ffffffffc0205360 <commands+0xbb0>
ffffffffc020169c:	00004617          	auipc	a2,0x4
ffffffffc02016a0:	b0460613          	addi	a2,a2,-1276 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02016a4:	1a500593          	li	a1,421
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	97050513          	addi	a0,a0,-1680 # ffffffffc0205018 <commands+0x868>
ffffffffc02016b0:	a57fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	c7c68693          	addi	a3,a3,-900 # ffffffffc0205330 <commands+0xb80>
ffffffffc02016bc:	00004617          	auipc	a2,0x4
ffffffffc02016c0:	ae460613          	addi	a2,a2,-1308 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02016c4:	1a400593          	li	a1,420
ffffffffc02016c8:	00004517          	auipc	a0,0x4
ffffffffc02016cc:	95050513          	addi	a0,a0,-1712 # ffffffffc0205018 <commands+0x868>
ffffffffc02016d0:	a37fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02016d4:	00004697          	auipc	a3,0x4
ffffffffc02016d8:	c2468693          	addi	a3,a3,-988 # ffffffffc02052f8 <commands+0xb48>
ffffffffc02016dc:	00004617          	auipc	a2,0x4
ffffffffc02016e0:	ac460613          	addi	a2,a2,-1340 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02016e4:	1a300593          	li	a1,419
ffffffffc02016e8:	00004517          	auipc	a0,0x4
ffffffffc02016ec:	93050513          	addi	a0,a0,-1744 # ffffffffc0205018 <commands+0x868>
ffffffffc02016f0:	a17fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02016f4:	00004697          	auipc	a3,0x4
ffffffffc02016f8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02052d0 <commands+0xb20>
ffffffffc02016fc:	00004617          	auipc	a2,0x4
ffffffffc0201700:	aa460613          	addi	a2,a2,-1372 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201704:	1a000593          	li	a1,416
ffffffffc0201708:	00004517          	auipc	a0,0x4
ffffffffc020170c:	91050513          	addi	a0,a0,-1776 # ffffffffc0205018 <commands+0x868>
ffffffffc0201710:	9f7fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201714:	86da                	mv	a3,s6
ffffffffc0201716:	00004617          	auipc	a2,0x4
ffffffffc020171a:	8da60613          	addi	a2,a2,-1830 # ffffffffc0204ff0 <commands+0x840>
ffffffffc020171e:	19f00593          	li	a1,415
ffffffffc0201722:	00004517          	auipc	a0,0x4
ffffffffc0201726:	8f650513          	addi	a0,a0,-1802 # ffffffffc0205018 <commands+0x868>
ffffffffc020172a:	9ddfe0ef          	jal	ra,ffffffffc0200106 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020172e:	86be                	mv	a3,a5
ffffffffc0201730:	00004617          	auipc	a2,0x4
ffffffffc0201734:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0201738:	19e00593          	li	a1,414
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0205018 <commands+0x868>
ffffffffc0201744:	9c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201748:	00004697          	auipc	a3,0x4
ffffffffc020174c:	b7068693          	addi	a3,a3,-1168 # ffffffffc02052b8 <commands+0xb08>
ffffffffc0201750:	00004617          	auipc	a2,0x4
ffffffffc0201754:	a5060613          	addi	a2,a2,-1456 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201758:	19c00593          	li	a1,412
ffffffffc020175c:	00004517          	auipc	a0,0x4
ffffffffc0201760:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0205018 <commands+0x868>
ffffffffc0201764:	9a3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201768:	00004697          	auipc	a3,0x4
ffffffffc020176c:	b3868693          	addi	a3,a3,-1224 # ffffffffc02052a0 <commands+0xaf0>
ffffffffc0201770:	00004617          	auipc	a2,0x4
ffffffffc0201774:	a3060613          	addi	a2,a2,-1488 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201778:	19b00593          	li	a1,411
ffffffffc020177c:	00004517          	auipc	a0,0x4
ffffffffc0201780:	89c50513          	addi	a0,a0,-1892 # ffffffffc0205018 <commands+0x868>
ffffffffc0201784:	983fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201788:	00004697          	auipc	a3,0x4
ffffffffc020178c:	b1868693          	addi	a3,a3,-1256 # ffffffffc02052a0 <commands+0xaf0>
ffffffffc0201790:	00004617          	auipc	a2,0x4
ffffffffc0201794:	a1060613          	addi	a2,a2,-1520 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201798:	1ae00593          	li	a1,430
ffffffffc020179c:	00004517          	auipc	a0,0x4
ffffffffc02017a0:	87c50513          	addi	a0,a0,-1924 # ffffffffc0205018 <commands+0x868>
ffffffffc02017a4:	963fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02017a8:	00004697          	auipc	a3,0x4
ffffffffc02017ac:	b8868693          	addi	a3,a3,-1144 # ffffffffc0205330 <commands+0xb80>
ffffffffc02017b0:	00004617          	auipc	a2,0x4
ffffffffc02017b4:	9f060613          	addi	a2,a2,-1552 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02017b8:	1ad00593          	li	a1,429
ffffffffc02017bc:	00004517          	auipc	a0,0x4
ffffffffc02017c0:	85c50513          	addi	a0,a0,-1956 # ffffffffc0205018 <commands+0x868>
ffffffffc02017c4:	943fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017c8:	00004697          	auipc	a3,0x4
ffffffffc02017cc:	c3068693          	addi	a3,a3,-976 # ffffffffc02053f8 <commands+0xc48>
ffffffffc02017d0:	00004617          	auipc	a2,0x4
ffffffffc02017d4:	9d060613          	addi	a2,a2,-1584 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02017d8:	1ac00593          	li	a1,428
ffffffffc02017dc:	00004517          	auipc	a0,0x4
ffffffffc02017e0:	83c50513          	addi	a0,a0,-1988 # ffffffffc0205018 <commands+0x868>
ffffffffc02017e4:	923fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02017e8:	00004697          	auipc	a3,0x4
ffffffffc02017ec:	bf868693          	addi	a3,a3,-1032 # ffffffffc02053e0 <commands+0xc30>
ffffffffc02017f0:	00004617          	auipc	a2,0x4
ffffffffc02017f4:	9b060613          	addi	a2,a2,-1616 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02017f8:	1ab00593          	li	a1,427
ffffffffc02017fc:	00004517          	auipc	a0,0x4
ffffffffc0201800:	81c50513          	addi	a0,a0,-2020 # ffffffffc0205018 <commands+0x868>
ffffffffc0201804:	903fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201808:	00004697          	auipc	a3,0x4
ffffffffc020180c:	ba868693          	addi	a3,a3,-1112 # ffffffffc02053b0 <commands+0xc00>
ffffffffc0201810:	00004617          	auipc	a2,0x4
ffffffffc0201814:	99060613          	addi	a2,a2,-1648 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201818:	1aa00593          	li	a1,426
ffffffffc020181c:	00003517          	auipc	a0,0x3
ffffffffc0201820:	7fc50513          	addi	a0,a0,2044 # ffffffffc0205018 <commands+0x868>
ffffffffc0201824:	8e3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201828:	00004697          	auipc	a3,0x4
ffffffffc020182c:	b7068693          	addi	a3,a3,-1168 # ffffffffc0205398 <commands+0xbe8>
ffffffffc0201830:	00004617          	auipc	a2,0x4
ffffffffc0201834:	97060613          	addi	a2,a2,-1680 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201838:	1a800593          	li	a1,424
ffffffffc020183c:	00003517          	auipc	a0,0x3
ffffffffc0201840:	7dc50513          	addi	a0,a0,2012 # ffffffffc0205018 <commands+0x868>
ffffffffc0201844:	8c3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201848:	00004697          	auipc	a3,0x4
ffffffffc020184c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0205380 <commands+0xbd0>
ffffffffc0201850:	00004617          	auipc	a2,0x4
ffffffffc0201854:	95060613          	addi	a2,a2,-1712 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201858:	1a700593          	li	a1,423
ffffffffc020185c:	00003517          	auipc	a0,0x3
ffffffffc0201860:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205018 <commands+0x868>
ffffffffc0201864:	8a3fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0201868:	00004697          	auipc	a3,0x4
ffffffffc020186c:	b0868693          	addi	a3,a3,-1272 # ffffffffc0205370 <commands+0xbc0>
ffffffffc0201870:	00004617          	auipc	a2,0x4
ffffffffc0201874:	93060613          	addi	a2,a2,-1744 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201878:	1a600593          	li	a1,422
ffffffffc020187c:	00003517          	auipc	a0,0x3
ffffffffc0201880:	79c50513          	addi	a0,a0,1948 # ffffffffc0205018 <commands+0x868>
ffffffffc0201884:	883fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201888:	00004697          	auipc	a3,0x4
ffffffffc020188c:	be068693          	addi	a3,a3,-1056 # ffffffffc0205468 <commands+0xcb8>
ffffffffc0201890:	00004617          	auipc	a2,0x4
ffffffffc0201894:	91060613          	addi	a2,a2,-1776 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201898:	1e800593          	li	a1,488
ffffffffc020189c:	00003517          	auipc	a0,0x3
ffffffffc02018a0:	77c50513          	addi	a0,a0,1916 # ffffffffc0205018 <commands+0x868>
ffffffffc02018a4:	863fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02018a8:	00004697          	auipc	a3,0x4
ffffffffc02018ac:	d6868693          	addi	a3,a3,-664 # ffffffffc0205610 <commands+0xe60>
ffffffffc02018b0:	00004617          	auipc	a2,0x4
ffffffffc02018b4:	8f060613          	addi	a2,a2,-1808 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02018b8:	1e000593          	li	a1,480
ffffffffc02018bc:	00003517          	auipc	a0,0x3
ffffffffc02018c0:	75c50513          	addi	a0,a0,1884 # ffffffffc0205018 <commands+0x868>
ffffffffc02018c4:	843fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02018c8:	00004697          	auipc	a3,0x4
ffffffffc02018cc:	d1068693          	addi	a3,a3,-752 # ffffffffc02055d8 <commands+0xe28>
ffffffffc02018d0:	00004617          	auipc	a2,0x4
ffffffffc02018d4:	8d060613          	addi	a2,a2,-1840 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02018d8:	1dd00593          	li	a1,477
ffffffffc02018dc:	00003517          	auipc	a0,0x3
ffffffffc02018e0:	73c50513          	addi	a0,a0,1852 # ffffffffc0205018 <commands+0x868>
ffffffffc02018e4:	823fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02018e8:	00004697          	auipc	a3,0x4
ffffffffc02018ec:	cc068693          	addi	a3,a3,-832 # ffffffffc02055a8 <commands+0xdf8>
ffffffffc02018f0:	00004617          	auipc	a2,0x4
ffffffffc02018f4:	8b060613          	addi	a2,a2,-1872 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02018f8:	1d900593          	li	a1,473
ffffffffc02018fc:	00003517          	auipc	a0,0x3
ffffffffc0201900:	71c50513          	addi	a0,a0,1820 # ffffffffc0205018 <commands+0x868>
ffffffffc0201904:	803fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0201908:	00004697          	auipc	a3,0x4
ffffffffc020190c:	b2068693          	addi	a3,a3,-1248 # ffffffffc0205428 <commands+0xc78>
ffffffffc0201910:	00004617          	auipc	a2,0x4
ffffffffc0201914:	89060613          	addi	a2,a2,-1904 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201918:	1b600593          	li	a1,438
ffffffffc020191c:	00003517          	auipc	a0,0x3
ffffffffc0201920:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205018 <commands+0x868>
ffffffffc0201924:	fe2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201928:	00004697          	auipc	a3,0x4
ffffffffc020192c:	ad068693          	addi	a3,a3,-1328 # ffffffffc02053f8 <commands+0xc48>
ffffffffc0201930:	00004617          	auipc	a2,0x4
ffffffffc0201934:	87060613          	addi	a2,a2,-1936 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201938:	1b300593          	li	a1,435
ffffffffc020193c:	00003517          	auipc	a0,0x3
ffffffffc0201940:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205018 <commands+0x868>
ffffffffc0201944:	fc2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201948:	00004697          	auipc	a3,0x4
ffffffffc020194c:	97068693          	addi	a3,a3,-1680 # ffffffffc02052b8 <commands+0xb08>
ffffffffc0201950:	00004617          	auipc	a2,0x4
ffffffffc0201954:	85060613          	addi	a2,a2,-1968 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201958:	1b200593          	li	a1,434
ffffffffc020195c:	00003517          	auipc	a0,0x3
ffffffffc0201960:	6bc50513          	addi	a0,a0,1724 # ffffffffc0205018 <commands+0x868>
ffffffffc0201964:	fa2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201968:	00004697          	auipc	a3,0x4
ffffffffc020196c:	aa868693          	addi	a3,a3,-1368 # ffffffffc0205410 <commands+0xc60>
ffffffffc0201970:	00004617          	auipc	a2,0x4
ffffffffc0201974:	83060613          	addi	a2,a2,-2000 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201978:	1af00593          	li	a1,431
ffffffffc020197c:	00003517          	auipc	a0,0x3
ffffffffc0201980:	69c50513          	addi	a0,a0,1692 # ffffffffc0205018 <commands+0x868>
ffffffffc0201984:	f82fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201988:	00004697          	auipc	a3,0x4
ffffffffc020198c:	ab868693          	addi	a3,a3,-1352 # ffffffffc0205440 <commands+0xc90>
ffffffffc0201990:	00004617          	auipc	a2,0x4
ffffffffc0201994:	81060613          	addi	a2,a2,-2032 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201998:	1b900593          	li	a1,441
ffffffffc020199c:	00003517          	auipc	a0,0x3
ffffffffc02019a0:	67c50513          	addi	a0,a0,1660 # ffffffffc0205018 <commands+0x868>
ffffffffc02019a4:	f62fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02019a8:	00004697          	auipc	a3,0x4
ffffffffc02019ac:	a5068693          	addi	a3,a3,-1456 # ffffffffc02053f8 <commands+0xc48>
ffffffffc02019b0:	00003617          	auipc	a2,0x3
ffffffffc02019b4:	7f060613          	addi	a2,a2,2032 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02019b8:	1b700593          	li	a1,439
ffffffffc02019bc:	00003517          	auipc	a0,0x3
ffffffffc02019c0:	65c50513          	addi	a0,a0,1628 # ffffffffc0205018 <commands+0x868>
ffffffffc02019c4:	f42fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02019c8:	00003697          	auipc	a3,0x3
ffffffffc02019cc:	7b868693          	addi	a3,a3,1976 # ffffffffc0205180 <commands+0x9d0>
ffffffffc02019d0:	00003617          	auipc	a2,0x3
ffffffffc02019d4:	7d060613          	addi	a2,a2,2000 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02019d8:	19200593          	li	a1,402
ffffffffc02019dc:	00003517          	auipc	a0,0x3
ffffffffc02019e0:	63c50513          	addi	a0,a0,1596 # ffffffffc0205018 <commands+0x868>
ffffffffc02019e4:	f22fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02019e8:	00003617          	auipc	a2,0x3
ffffffffc02019ec:	75060613          	addi	a2,a2,1872 # ffffffffc0205138 <commands+0x988>
ffffffffc02019f0:	0bd00593          	li	a1,189
ffffffffc02019f4:	00003517          	auipc	a0,0x3
ffffffffc02019f8:	62450513          	addi	a0,a0,1572 # ffffffffc0205018 <commands+0x868>
ffffffffc02019fc:	f0afe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201a00:	00004697          	auipc	a3,0x4
ffffffffc0201a04:	b6868693          	addi	a3,a3,-1176 # ffffffffc0205568 <commands+0xdb8>
ffffffffc0201a08:	00003617          	auipc	a2,0x3
ffffffffc0201a0c:	79860613          	addi	a2,a2,1944 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201a10:	1d800593          	li	a1,472
ffffffffc0201a14:	00003517          	auipc	a0,0x3
ffffffffc0201a18:	60450513          	addi	a0,a0,1540 # ffffffffc0205018 <commands+0x868>
ffffffffc0201a1c:	eeafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0201a20:	00004697          	auipc	a3,0x4
ffffffffc0201a24:	b3068693          	addi	a3,a3,-1232 # ffffffffc0205550 <commands+0xda0>
ffffffffc0201a28:	00003617          	auipc	a2,0x3
ffffffffc0201a2c:	77860613          	addi	a2,a2,1912 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201a30:	1d700593          	li	a1,471
ffffffffc0201a34:	00003517          	auipc	a0,0x3
ffffffffc0201a38:	5e450513          	addi	a0,a0,1508 # ffffffffc0205018 <commands+0x868>
ffffffffc0201a3c:	ecafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201a40:	00004697          	auipc	a3,0x4
ffffffffc0201a44:	ad868693          	addi	a3,a3,-1320 # ffffffffc0205518 <commands+0xd68>
ffffffffc0201a48:	00003617          	auipc	a2,0x3
ffffffffc0201a4c:	75860613          	addi	a2,a2,1880 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201a50:	1d600593          	li	a1,470
ffffffffc0201a54:	00003517          	auipc	a0,0x3
ffffffffc0201a58:	5c450513          	addi	a0,a0,1476 # ffffffffc0205018 <commands+0x868>
ffffffffc0201a5c:	eaafe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201a60:	00004697          	auipc	a3,0x4
ffffffffc0201a64:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205500 <commands+0xd50>
ffffffffc0201a68:	00003617          	auipc	a2,0x3
ffffffffc0201a6c:	73860613          	addi	a2,a2,1848 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201a70:	1d200593          	li	a1,466
ffffffffc0201a74:	00003517          	auipc	a0,0x3
ffffffffc0201a78:	5a450513          	addi	a0,a0,1444 # ffffffffc0205018 <commands+0x868>
ffffffffc0201a7c:	e8afe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201a80 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a80:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0201a84:	8082                	ret

ffffffffc0201a86 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a86:	7179                	addi	sp,sp,-48
ffffffffc0201a88:	e84a                	sd	s2,16(sp)
ffffffffc0201a8a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201a8c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a8e:	f022                	sd	s0,32(sp)
ffffffffc0201a90:	ec26                	sd	s1,24(sp)
ffffffffc0201a92:	e44e                	sd	s3,8(sp)
ffffffffc0201a94:	f406                	sd	ra,40(sp)
ffffffffc0201a96:	84ae                	mv	s1,a1
ffffffffc0201a98:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201a9a:	852ff0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0201a9e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201aa0:	cd19                	beqz	a0,ffffffffc0201abe <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201aa2:	85aa                	mv	a1,a0
ffffffffc0201aa4:	86ce                	mv	a3,s3
ffffffffc0201aa6:	8626                	mv	a2,s1
ffffffffc0201aa8:	854a                	mv	a0,s2
ffffffffc0201aaa:	c28ff0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
ffffffffc0201aae:	ed39                	bnez	a0,ffffffffc0201b0c <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0201ab0:	00010797          	auipc	a5,0x10
ffffffffc0201ab4:	9c878793          	addi	a5,a5,-1592 # ffffffffc0211478 <swap_init_ok>
ffffffffc0201ab8:	439c                	lw	a5,0(a5)
ffffffffc0201aba:	2781                	sext.w	a5,a5
ffffffffc0201abc:	eb89                	bnez	a5,ffffffffc0201ace <pgdir_alloc_page+0x48>
}
ffffffffc0201abe:	8522                	mv	a0,s0
ffffffffc0201ac0:	70a2                	ld	ra,40(sp)
ffffffffc0201ac2:	7402                	ld	s0,32(sp)
ffffffffc0201ac4:	64e2                	ld	s1,24(sp)
ffffffffc0201ac6:	6942                	ld	s2,16(sp)
ffffffffc0201ac8:	69a2                	ld	s3,8(sp)
ffffffffc0201aca:	6145                	addi	sp,sp,48
ffffffffc0201acc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201ace:	00010797          	auipc	a5,0x10
ffffffffc0201ad2:	9ea78793          	addi	a5,a5,-1558 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0201ad6:	6388                	ld	a0,0(a5)
ffffffffc0201ad8:	4681                	li	a3,0
ffffffffc0201ada:	8622                	mv	a2,s0
ffffffffc0201adc:	85a6                	mv	a1,s1
ffffffffc0201ade:	336010ef          	jal	ra,ffffffffc0202e14 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201ae2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201ae4:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0201ae6:	4785                	li	a5,1
ffffffffc0201ae8:	fcf70be3          	beq	a4,a5,ffffffffc0201abe <pgdir_alloc_page+0x38>
ffffffffc0201aec:	00003697          	auipc	a3,0x3
ffffffffc0201af0:	5ac68693          	addi	a3,a3,1452 # ffffffffc0205098 <commands+0x8e8>
ffffffffc0201af4:	00003617          	auipc	a2,0x3
ffffffffc0201af8:	6ac60613          	addi	a2,a2,1708 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201afc:	17a00593          	li	a1,378
ffffffffc0201b00:	00003517          	auipc	a0,0x3
ffffffffc0201b04:	51850513          	addi	a0,a0,1304 # ffffffffc0205018 <commands+0x868>
ffffffffc0201b08:	dfefe0ef          	jal	ra,ffffffffc0200106 <__panic>
            free_page(page);
ffffffffc0201b0c:	8522                	mv	a0,s0
ffffffffc0201b0e:	4585                	li	a1,1
ffffffffc0201b10:	864ff0ef          	jal	ra,ffffffffc0200b74 <free_pages>
            return NULL;
ffffffffc0201b14:	4401                	li	s0,0
ffffffffc0201b16:	b765                	j	ffffffffc0201abe <pgdir_alloc_page+0x38>

ffffffffc0201b18 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0201b18:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b1a:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0201b1c:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b1e:	fff50713          	addi	a4,a0,-1
ffffffffc0201b22:	17f9                	addi	a5,a5,-2
ffffffffc0201b24:	04e7ee63          	bltu	a5,a4,ffffffffc0201b80 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201b28:	6785                	lui	a5,0x1
ffffffffc0201b2a:	17fd                	addi	a5,a5,-1
ffffffffc0201b2c:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0201b2e:	8131                	srli	a0,a0,0xc
ffffffffc0201b30:	fbdfe0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
    assert(base != NULL);
ffffffffc0201b34:	c159                	beqz	a0,ffffffffc0201bba <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b36:	00010797          	auipc	a5,0x10
ffffffffc0201b3a:	96a78793          	addi	a5,a5,-1686 # ffffffffc02114a0 <pages>
ffffffffc0201b3e:	639c                	ld	a5,0(a5)
ffffffffc0201b40:	8d1d                	sub	a0,a0,a5
ffffffffc0201b42:	00003797          	auipc	a5,0x3
ffffffffc0201b46:	4a678793          	addi	a5,a5,1190 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0201b4a:	6394                	ld	a3,0(a5)
ffffffffc0201b4c:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b4e:	00010797          	auipc	a5,0x10
ffffffffc0201b52:	91278793          	addi	a5,a5,-1774 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b56:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b5a:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b5c:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b60:	57fd                	li	a5,-1
ffffffffc0201b62:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b64:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b66:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201b68:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201b6a:	02e7fb63          	bleu	a4,a5,ffffffffc0201ba0 <kmalloc+0x88>
ffffffffc0201b6e:	00010797          	auipc	a5,0x10
ffffffffc0201b72:	92278793          	addi	a5,a5,-1758 # ffffffffc0211490 <va_pa_offset>
ffffffffc0201b76:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0201b78:	60a2                	ld	ra,8(sp)
ffffffffc0201b7a:	953e                	add	a0,a0,a5
ffffffffc0201b7c:	0141                	addi	sp,sp,16
ffffffffc0201b7e:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201b80:	00003697          	auipc	a3,0x3
ffffffffc0201b84:	4b868693          	addi	a3,a3,1208 # ffffffffc0205038 <commands+0x888>
ffffffffc0201b88:	00003617          	auipc	a2,0x3
ffffffffc0201b8c:	61860613          	addi	a2,a2,1560 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201b90:	1f000593          	li	a1,496
ffffffffc0201b94:	00003517          	auipc	a0,0x3
ffffffffc0201b98:	48450513          	addi	a0,a0,1156 # ffffffffc0205018 <commands+0x868>
ffffffffc0201b9c:	d6afe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201ba0:	86aa                	mv	a3,a0
ffffffffc0201ba2:	00003617          	auipc	a2,0x3
ffffffffc0201ba6:	44e60613          	addi	a2,a2,1102 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0201baa:	06a00593          	li	a1,106
ffffffffc0201bae:	00003517          	auipc	a0,0x3
ffffffffc0201bb2:	4da50513          	addi	a0,a0,1242 # ffffffffc0205088 <commands+0x8d8>
ffffffffc0201bb6:	d50fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(base != NULL);
ffffffffc0201bba:	00003697          	auipc	a3,0x3
ffffffffc0201bbe:	49e68693          	addi	a3,a3,1182 # ffffffffc0205058 <commands+0x8a8>
ffffffffc0201bc2:	00003617          	auipc	a2,0x3
ffffffffc0201bc6:	5de60613          	addi	a2,a2,1502 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201bca:	1f300593          	li	a1,499
ffffffffc0201bce:	00003517          	auipc	a0,0x3
ffffffffc0201bd2:	44a50513          	addi	a0,a0,1098 # ffffffffc0205018 <commands+0x868>
ffffffffc0201bd6:	d30fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201bda <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0201bda:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201bdc:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0201bde:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201be0:	fff58713          	addi	a4,a1,-1
ffffffffc0201be4:	17f9                	addi	a5,a5,-2
ffffffffc0201be6:	04e7eb63          	bltu	a5,a4,ffffffffc0201c3c <kfree+0x62>
    assert(ptr != NULL);
ffffffffc0201bea:	c941                	beqz	a0,ffffffffc0201c7a <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0201bec:	6785                	lui	a5,0x1
ffffffffc0201bee:	17fd                	addi	a5,a5,-1
ffffffffc0201bf0:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201bf2:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bf6:	81b1                	srli	a1,a1,0xc
ffffffffc0201bf8:	06f56463          	bltu	a0,a5,ffffffffc0201c60 <kfree+0x86>
ffffffffc0201bfc:	00010797          	auipc	a5,0x10
ffffffffc0201c00:	89478793          	addi	a5,a5,-1900 # ffffffffc0211490 <va_pa_offset>
ffffffffc0201c04:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201c06:	00010717          	auipc	a4,0x10
ffffffffc0201c0a:	85a70713          	addi	a4,a4,-1958 # ffffffffc0211460 <npage>
ffffffffc0201c0e:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c10:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0201c14:	83b1                	srli	a5,a5,0xc
ffffffffc0201c16:	04e7f363          	bleu	a4,a5,ffffffffc0201c5c <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c1a:	fff80537          	lui	a0,0xfff80
ffffffffc0201c1e:	97aa                	add	a5,a5,a0
ffffffffc0201c20:	00010697          	auipc	a3,0x10
ffffffffc0201c24:	88068693          	addi	a3,a3,-1920 # ffffffffc02114a0 <pages>
ffffffffc0201c28:	6288                	ld	a0,0(a3)
ffffffffc0201c2a:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0201c2e:	60a2                	ld	ra,8(sp)
ffffffffc0201c30:	97ba                	add	a5,a5,a4
ffffffffc0201c32:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0201c34:	953e                	add	a0,a0,a5
}
ffffffffc0201c36:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc0201c38:	f3dfe06f          	j	ffffffffc0200b74 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0201c3c:	00003697          	auipc	a3,0x3
ffffffffc0201c40:	3fc68693          	addi	a3,a3,1020 # ffffffffc0205038 <commands+0x888>
ffffffffc0201c44:	00003617          	auipc	a2,0x3
ffffffffc0201c48:	55c60613          	addi	a2,a2,1372 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201c4c:	1f900593          	li	a1,505
ffffffffc0201c50:	00003517          	auipc	a0,0x3
ffffffffc0201c54:	3c850513          	addi	a0,a0,968 # ffffffffc0205018 <commands+0x868>
ffffffffc0201c58:	caefe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201c5c:	e75fe0ef          	jal	ra,ffffffffc0200ad0 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0201c60:	86aa                	mv	a3,a0
ffffffffc0201c62:	00003617          	auipc	a2,0x3
ffffffffc0201c66:	4d660613          	addi	a2,a2,1238 # ffffffffc0205138 <commands+0x988>
ffffffffc0201c6a:	06c00593          	li	a1,108
ffffffffc0201c6e:	00003517          	auipc	a0,0x3
ffffffffc0201c72:	41a50513          	addi	a0,a0,1050 # ffffffffc0205088 <commands+0x8d8>
ffffffffc0201c76:	c90fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(ptr != NULL);
ffffffffc0201c7a:	00003697          	auipc	a3,0x3
ffffffffc0201c7e:	3ae68693          	addi	a3,a3,942 # ffffffffc0205028 <commands+0x878>
ffffffffc0201c82:	00003617          	auipc	a2,0x3
ffffffffc0201c86:	51e60613          	addi	a2,a2,1310 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201c8a:	1fa00593          	li	a1,506
ffffffffc0201c8e:	00003517          	auipc	a0,0x3
ffffffffc0201c92:	38a50513          	addi	a0,a0,906 # ffffffffc0205018 <commands+0x868>
ffffffffc0201c96:	c70fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201c9a <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201c9a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201c9c:	00004697          	auipc	a3,0x4
ffffffffc0201ca0:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0205658 <commands+0xea8>
ffffffffc0201ca4:	00003617          	auipc	a2,0x3
ffffffffc0201ca8:	4fc60613          	addi	a2,a2,1276 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201cac:	07d00593          	li	a1,125
ffffffffc0201cb0:	00004517          	auipc	a0,0x4
ffffffffc0201cb4:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205678 <commands+0xec8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201cb8:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201cba:	c4cfe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201cbe <mm_create>:
mm_create(void) {
ffffffffc0201cbe:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201cc0:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201cc4:	e022                	sd	s0,0(sp)
ffffffffc0201cc6:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201cc8:	e51ff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201ccc:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201cce:	c115                	beqz	a0,ffffffffc0201cf2 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cd0:	0000f797          	auipc	a5,0xf
ffffffffc0201cd4:	7a878793          	addi	a5,a5,1960 # ffffffffc0211478 <swap_init_ok>
ffffffffc0201cd8:	439c                	lw	a5,0(a5)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201cda:	e408                	sd	a0,8(s0)
ffffffffc0201cdc:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201cde:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201ce2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201ce6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cea:	2781                	sext.w	a5,a5
ffffffffc0201cec:	eb81                	bnez	a5,ffffffffc0201cfc <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc0201cee:	02053423          	sd	zero,40(a0)
}
ffffffffc0201cf2:	8522                	mv	a0,s0
ffffffffc0201cf4:	60a2                	ld	ra,8(sp)
ffffffffc0201cf6:	6402                	ld	s0,0(sp)
ffffffffc0201cf8:	0141                	addi	sp,sp,16
ffffffffc0201cfa:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201cfc:	108010ef          	jal	ra,ffffffffc0202e04 <swap_init_mm>
}
ffffffffc0201d00:	8522                	mv	a0,s0
ffffffffc0201d02:	60a2                	ld	ra,8(sp)
ffffffffc0201d04:	6402                	ld	s0,0(sp)
ffffffffc0201d06:	0141                	addi	sp,sp,16
ffffffffc0201d08:	8082                	ret

ffffffffc0201d0a <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d0a:	1101                	addi	sp,sp,-32
ffffffffc0201d0c:	e04a                	sd	s2,0(sp)
ffffffffc0201d0e:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d10:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0201d14:	e822                	sd	s0,16(sp)
ffffffffc0201d16:	e426                	sd	s1,8(sp)
ffffffffc0201d18:	ec06                	sd	ra,24(sp)
ffffffffc0201d1a:	84ae                	mv	s1,a1
ffffffffc0201d1c:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201d1e:	dfbff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
    if (vma != NULL) {
ffffffffc0201d22:	c509                	beqz	a0,ffffffffc0201d2c <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201d24:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201d28:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201d2a:	ed00                	sd	s0,24(a0)
}
ffffffffc0201d2c:	60e2                	ld	ra,24(sp)
ffffffffc0201d2e:	6442                	ld	s0,16(sp)
ffffffffc0201d30:	64a2                	ld	s1,8(sp)
ffffffffc0201d32:	6902                	ld	s2,0(sp)
ffffffffc0201d34:	6105                	addi	sp,sp,32
ffffffffc0201d36:	8082                	ret

ffffffffc0201d38 <find_vma>:
    if (mm != NULL) {
ffffffffc0201d38:	c51d                	beqz	a0,ffffffffc0201d66 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0201d3a:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d3c:	c781                	beqz	a5,ffffffffc0201d44 <find_vma+0xc>
ffffffffc0201d3e:	6798                	ld	a4,8(a5)
ffffffffc0201d40:	02e5f663          	bleu	a4,a1,ffffffffc0201d6c <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0201d44:	87aa                	mv	a5,a0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201d46:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201d48:	00f50f63          	beq	a0,a5,ffffffffc0201d66 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201d4c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201d50:	fee5ebe3          	bltu	a1,a4,ffffffffc0201d46 <find_vma+0xe>
ffffffffc0201d54:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201d58:	fee5f7e3          	bleu	a4,a1,ffffffffc0201d46 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0201d5c:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0201d5e:	c781                	beqz	a5,ffffffffc0201d66 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0201d60:	e91c                	sd	a5,16(a0)
}
ffffffffc0201d62:	853e                	mv	a0,a5
ffffffffc0201d64:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0201d66:	4781                	li	a5,0
}
ffffffffc0201d68:	853e                	mv	a0,a5
ffffffffc0201d6a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201d6c:	6b98                	ld	a4,16(a5)
ffffffffc0201d6e:	fce5fbe3          	bleu	a4,a1,ffffffffc0201d44 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0201d72:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0201d74:	b7fd                	j	ffffffffc0201d62 <find_vma+0x2a>

ffffffffc0201d76 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d76:	6590                	ld	a2,8(a1)
ffffffffc0201d78:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201d7c:	1141                	addi	sp,sp,-16
ffffffffc0201d7e:	e406                	sd	ra,8(sp)
ffffffffc0201d80:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201d82:	01066863          	bltu	a2,a6,ffffffffc0201d92 <insert_vma_struct+0x1c>
ffffffffc0201d86:	a8b9                	j	ffffffffc0201de4 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201d88:	fe87b683          	ld	a3,-24(a5)
ffffffffc0201d8c:	04d66763          	bltu	a2,a3,ffffffffc0201dda <insert_vma_struct+0x64>
ffffffffc0201d90:	873e                	mv	a4,a5
ffffffffc0201d92:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0201d94:	fef51ae3          	bne	a0,a5,ffffffffc0201d88 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201d98:	02a70463          	beq	a4,a0,ffffffffc0201dc0 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201d9c:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201da0:	fe873883          	ld	a7,-24(a4)
ffffffffc0201da4:	08d8f063          	bleu	a3,a7,ffffffffc0201e24 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201da8:	04d66e63          	bltu	a2,a3,ffffffffc0201e04 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0201dac:	00f50a63          	beq	a0,a5,ffffffffc0201dc0 <insert_vma_struct+0x4a>
ffffffffc0201db0:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201db4:	0506e863          	bltu	a3,a6,ffffffffc0201e04 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201db8:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201dbc:	02c6f263          	bleu	a2,a3,ffffffffc0201de0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201dc0:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0201dc2:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201dc4:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201dc8:	e390                	sd	a2,0(a5)
ffffffffc0201dca:	e710                	sd	a2,8(a4)
}
ffffffffc0201dcc:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201dce:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201dd0:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0201dd2:	2685                	addiw	a3,a3,1
ffffffffc0201dd4:	d114                	sw	a3,32(a0)
}
ffffffffc0201dd6:	0141                	addi	sp,sp,16
ffffffffc0201dd8:	8082                	ret
    if (le_prev != list) {
ffffffffc0201dda:	fca711e3          	bne	a4,a0,ffffffffc0201d9c <insert_vma_struct+0x26>
ffffffffc0201dde:	bfd9                	j	ffffffffc0201db4 <insert_vma_struct+0x3e>
ffffffffc0201de0:	ebbff0ef          	jal	ra,ffffffffc0201c9a <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201de4:	00004697          	auipc	a3,0x4
ffffffffc0201de8:	92468693          	addi	a3,a3,-1756 # ffffffffc0205708 <commands+0xf58>
ffffffffc0201dec:	00003617          	auipc	a2,0x3
ffffffffc0201df0:	3b460613          	addi	a2,a2,948 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201df4:	08400593          	li	a1,132
ffffffffc0201df8:	00004517          	auipc	a0,0x4
ffffffffc0201dfc:	88050513          	addi	a0,a0,-1920 # ffffffffc0205678 <commands+0xec8>
ffffffffc0201e00:	b06fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201e04:	00004697          	auipc	a3,0x4
ffffffffc0201e08:	94468693          	addi	a3,a3,-1724 # ffffffffc0205748 <commands+0xf98>
ffffffffc0201e0c:	00003617          	auipc	a2,0x3
ffffffffc0201e10:	39460613          	addi	a2,a2,916 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201e14:	07c00593          	li	a1,124
ffffffffc0201e18:	00004517          	auipc	a0,0x4
ffffffffc0201e1c:	86050513          	addi	a0,a0,-1952 # ffffffffc0205678 <commands+0xec8>
ffffffffc0201e20:	ae6fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201e24:	00004697          	auipc	a3,0x4
ffffffffc0201e28:	90468693          	addi	a3,a3,-1788 # ffffffffc0205728 <commands+0xf78>
ffffffffc0201e2c:	00003617          	auipc	a2,0x3
ffffffffc0201e30:	37460613          	addi	a2,a2,884 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201e34:	07b00593          	li	a1,123
ffffffffc0201e38:	00004517          	auipc	a0,0x4
ffffffffc0201e3c:	84050513          	addi	a0,a0,-1984 # ffffffffc0205678 <commands+0xec8>
ffffffffc0201e40:	ac6fe0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0201e44 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0201e44:	1141                	addi	sp,sp,-16
ffffffffc0201e46:	e022                	sd	s0,0(sp)
ffffffffc0201e48:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201e4a:	6508                	ld	a0,8(a0)
ffffffffc0201e4c:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0201e4e:	00a40e63          	beq	s0,a0,ffffffffc0201e6a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e52:	6118                	ld	a4,0(a0)
ffffffffc0201e54:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0201e56:	03000593          	li	a1,48
ffffffffc0201e5a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201e5c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201e5e:	e398                	sd	a4,0(a5)
ffffffffc0201e60:	d7bff0ef          	jal	ra,ffffffffc0201bda <kfree>
    return listelm->next;
ffffffffc0201e64:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201e66:	fea416e3          	bne	s0,a0,ffffffffc0201e52 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e6a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0201e6c:	6402                	ld	s0,0(sp)
ffffffffc0201e6e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e70:	03000593          	li	a1,48
}
ffffffffc0201e74:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0201e76:	d65ff06f          	j	ffffffffc0201bda <kfree>

ffffffffc0201e7a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0201e7a:	715d                	addi	sp,sp,-80
ffffffffc0201e7c:	e486                	sd	ra,72(sp)
ffffffffc0201e7e:	e0a2                	sd	s0,64(sp)
ffffffffc0201e80:	fc26                	sd	s1,56(sp)
ffffffffc0201e82:	f84a                	sd	s2,48(sp)
ffffffffc0201e84:	f052                	sd	s4,32(sp)
ffffffffc0201e86:	f44e                	sd	s3,40(sp)
ffffffffc0201e88:	ec56                	sd	s5,24(sp)
ffffffffc0201e8a:	e85a                	sd	s6,16(sp)
ffffffffc0201e8c:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e8e:	d2dfe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201e92:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0201e94:	d27fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0201e98:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0201e9a:	e25ff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
    assert(mm != NULL);
ffffffffc0201e9e:	842a                	mv	s0,a0
ffffffffc0201ea0:	03200493          	li	s1,50
ffffffffc0201ea4:	e919                	bnez	a0,ffffffffc0201eba <vmm_init+0x40>
ffffffffc0201ea6:	aeed                	j	ffffffffc02022a0 <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0201ea8:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201eaa:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201eac:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201eb0:	14ed                	addi	s1,s1,-5
ffffffffc0201eb2:	8522                	mv	a0,s0
ffffffffc0201eb4:	ec3ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0201eb8:	c88d                	beqz	s1,ffffffffc0201eea <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201eba:	03000513          	li	a0,48
ffffffffc0201ebe:	c5bff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201ec2:	85aa                	mv	a1,a0
ffffffffc0201ec4:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201ec8:	f165                	bnez	a0,ffffffffc0201ea8 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0201eca:	00004697          	auipc	a3,0x4
ffffffffc0201ece:	ac668693          	addi	a3,a3,-1338 # ffffffffc0205990 <commands+0x11e0>
ffffffffc0201ed2:	00003617          	auipc	a2,0x3
ffffffffc0201ed6:	2ce60613          	addi	a2,a2,718 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201eda:	0ce00593          	li	a1,206
ffffffffc0201ede:	00003517          	auipc	a0,0x3
ffffffffc0201ee2:	79a50513          	addi	a0,a0,1946 # ffffffffc0205678 <commands+0xec8>
ffffffffc0201ee6:	a20fe0ef          	jal	ra,ffffffffc0200106 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0201eea:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201eee:	1f900993          	li	s3,505
ffffffffc0201ef2:	a819                	j	ffffffffc0201f08 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0201ef4:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201ef6:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201ef8:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201efc:	0495                	addi	s1,s1,5
ffffffffc0201efe:	8522                	mv	a0,s0
ffffffffc0201f00:	e77ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0201f04:	03348a63          	beq	s1,s3,ffffffffc0201f38 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f08:	03000513          	li	a0,48
ffffffffc0201f0c:	c0dff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc0201f10:	85aa                	mv	a1,a0
ffffffffc0201f12:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0201f16:	fd79                	bnez	a0,ffffffffc0201ef4 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0201f18:	00004697          	auipc	a3,0x4
ffffffffc0201f1c:	a7868693          	addi	a3,a3,-1416 # ffffffffc0205990 <commands+0x11e0>
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	28060613          	addi	a2,a2,640 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0201f28:	0d400593          	li	a1,212
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	74c50513          	addi	a0,a0,1868 # ffffffffc0205678 <commands+0xec8>
ffffffffc0201f34:	9d2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0201f38:	6418                	ld	a4,8(s0)
ffffffffc0201f3a:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0201f3c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0201f40:	2ae40063          	beq	s0,a4,ffffffffc02021e0 <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201f44:	fe873603          	ld	a2,-24(a4)
ffffffffc0201f48:	ffe78693          	addi	a3,a5,-2
ffffffffc0201f4c:	20d61a63          	bne	a2,a3,ffffffffc0202160 <vmm_init+0x2e6>
ffffffffc0201f50:	ff073683          	ld	a3,-16(a4)
ffffffffc0201f54:	20d79663          	bne	a5,a3,ffffffffc0202160 <vmm_init+0x2e6>
ffffffffc0201f58:	0795                	addi	a5,a5,5
ffffffffc0201f5a:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0201f5c:	feb792e3          	bne	a5,a1,ffffffffc0201f40 <vmm_init+0xc6>
ffffffffc0201f60:	499d                	li	s3,7
ffffffffc0201f62:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201f64:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201f68:	85a6                	mv	a1,s1
ffffffffc0201f6a:	8522                	mv	a0,s0
ffffffffc0201f6c:	dcdff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201f70:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0201f72:	2e050763          	beqz	a0,ffffffffc0202260 <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0201f76:	00148593          	addi	a1,s1,1
ffffffffc0201f7a:	8522                	mv	a0,s0
ffffffffc0201f7c:	dbdff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201f80:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0201f82:	2a050f63          	beqz	a0,ffffffffc0202240 <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0201f86:	85ce                	mv	a1,s3
ffffffffc0201f88:	8522                	mv	a0,s0
ffffffffc0201f8a:	dafff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201f8e:	28051963          	bnez	a0,ffffffffc0202220 <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0201f92:	00348593          	addi	a1,s1,3
ffffffffc0201f96:	8522                	mv	a0,s0
ffffffffc0201f98:	da1ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma4 == NULL);
ffffffffc0201f9c:	26051263          	bnez	a0,ffffffffc0202200 <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0201fa0:	00448593          	addi	a1,s1,4
ffffffffc0201fa4:	8522                	mv	a0,s0
ffffffffc0201fa6:	d93ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
        assert(vma5 == NULL);
ffffffffc0201faa:	2c051b63          	bnez	a0,ffffffffc0202280 <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201fae:	008b3783          	ld	a5,8(s6)
ffffffffc0201fb2:	1c979763          	bne	a5,s1,ffffffffc0202180 <vmm_init+0x306>
ffffffffc0201fb6:	010b3783          	ld	a5,16(s6)
ffffffffc0201fba:	1d379363          	bne	a5,s3,ffffffffc0202180 <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201fbe:	008ab783          	ld	a5,8(s5)
ffffffffc0201fc2:	1c979f63          	bne	a5,s1,ffffffffc02021a0 <vmm_init+0x326>
ffffffffc0201fc6:	010ab783          	ld	a5,16(s5)
ffffffffc0201fca:	1d379b63          	bne	a5,s3,ffffffffc02021a0 <vmm_init+0x326>
ffffffffc0201fce:	0495                	addi	s1,s1,5
ffffffffc0201fd0:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0201fd2:	f9749be3          	bne	s1,s7,ffffffffc0201f68 <vmm_init+0xee>
ffffffffc0201fd6:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0201fd8:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0201fda:	85a6                	mv	a1,s1
ffffffffc0201fdc:	8522                	mv	a0,s0
ffffffffc0201fde:	d5bff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0201fe2:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0201fe6:	c90d                	beqz	a0,ffffffffc0202018 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0201fe8:	6914                	ld	a3,16(a0)
ffffffffc0201fea:	6510                	ld	a2,8(a0)
ffffffffc0201fec:	00004517          	auipc	a0,0x4
ffffffffc0201ff0:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205878 <commands+0x10c8>
ffffffffc0201ff4:	8cafe0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0201ff8:	00004697          	auipc	a3,0x4
ffffffffc0201ffc:	8a868693          	addi	a3,a3,-1880 # ffffffffc02058a0 <commands+0x10f0>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	1a060613          	addi	a2,a2,416 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202008:	0f600593          	li	a1,246
ffffffffc020200c:	00003517          	auipc	a0,0x3
ffffffffc0202010:	66c50513          	addi	a0,a0,1644 # ffffffffc0205678 <commands+0xec8>
ffffffffc0202014:	8f2fe0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0202018:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc020201a:	fd3490e3          	bne	s1,s3,ffffffffc0201fda <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020201e:	8522                	mv	a0,s0
ffffffffc0202020:	e25ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202024:	b97fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202028:	28aa1c63          	bne	s4,a0,ffffffffc02022c0 <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020202c:	00004517          	auipc	a0,0x4
ffffffffc0202030:	8b450513          	addi	a0,a0,-1868 # ffffffffc02058e0 <commands+0x1130>
ffffffffc0202034:	88afe0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202038:	b83fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc020203c:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020203e:	c81ff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
ffffffffc0202042:	0000f797          	auipc	a5,0xf
ffffffffc0202046:	46a7bb23          	sd	a0,1142(a5) # ffffffffc02114b8 <check_mm_struct>
ffffffffc020204a:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020204c:	2a050a63          	beqz	a0,ffffffffc0202300 <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202050:	0000f797          	auipc	a5,0xf
ffffffffc0202054:	40878793          	addi	a5,a5,1032 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202058:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020205a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020205c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020205e:	32079d63          	bnez	a5,ffffffffc0202398 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202062:	03000513          	li	a0,48
ffffffffc0202066:	ab3ff0ef          	jal	ra,ffffffffc0201b18 <kmalloc>
ffffffffc020206a:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020206c:	14050a63          	beqz	a0,ffffffffc02021c0 <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc0202070:	002007b7          	lui	a5,0x200
ffffffffc0202074:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0202078:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020207a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020207c:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202080:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0202082:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0202086:	cf1ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020208a:	10000593          	li	a1,256
ffffffffc020208e:	8522                	mv	a0,s0
ffffffffc0202090:	ca9ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>
ffffffffc0202094:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0202098:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020209c:	2aaa1263          	bne	s4,a0,ffffffffc0202340 <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02020a0:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02020a4:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02020a6:	fee79de3          	bne	a5,a4,ffffffffc02020a0 <vmm_init+0x226>
        sum += i;
ffffffffc02020aa:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02020ac:	10000793          	li	a5,256
        sum += i;
ffffffffc02020b0:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02020b4:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02020b8:	0007c683          	lbu	a3,0(a5)
ffffffffc02020bc:	0785                	addi	a5,a5,1
ffffffffc02020be:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02020c0:	fec79ce3          	bne	a5,a2,ffffffffc02020b8 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02020c4:	2a071a63          	bnez	a4,ffffffffc0202378 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02020c8:	4581                	li	a1,0
ffffffffc02020ca:	8526                	mv	a0,s1
ffffffffc02020cc:	d95fe0ef          	jal	ra,ffffffffc0200e60 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02020d0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02020d2:	0000f717          	auipc	a4,0xf
ffffffffc02020d6:	38e70713          	addi	a4,a4,910 # ffffffffc0211460 <npage>
ffffffffc02020da:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020dc:	078a                	slli	a5,a5,0x2
ffffffffc02020de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020e0:	28e7f063          	bleu	a4,a5,ffffffffc0202360 <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02020e4:	00004717          	auipc	a4,0x4
ffffffffc02020e8:	42c70713          	addi	a4,a4,1068 # ffffffffc0206510 <nbase>
ffffffffc02020ec:	6318                	ld	a4,0(a4)
ffffffffc02020ee:	0000f697          	auipc	a3,0xf
ffffffffc02020f2:	3b268693          	addi	a3,a3,946 # ffffffffc02114a0 <pages>
ffffffffc02020f6:	6288                	ld	a0,0(a3)
ffffffffc02020f8:	8f99                	sub	a5,a5,a4
ffffffffc02020fa:	00379713          	slli	a4,a5,0x3
ffffffffc02020fe:	97ba                	add	a5,a5,a4
ffffffffc0202100:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0202102:	953e                	add	a0,a0,a5
ffffffffc0202104:	4585                	li	a1,1
ffffffffc0202106:	a6ffe0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    pgdir[0] = 0;
ffffffffc020210a:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020210e:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0202110:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0202114:	d31ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0202118:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc020211a:	0000f797          	auipc	a5,0xf
ffffffffc020211e:	3807bf23          	sd	zero,926(a5) # ffffffffc02114b8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202122:	a99fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202126:	1aa99d63          	bne	s3,a0,ffffffffc02022e0 <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020212a:	00004517          	auipc	a0,0x4
ffffffffc020212e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205958 <commands+0x11a8>
ffffffffc0202132:	f8dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202136:	a85fe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc020213a:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020213c:	1ea91263          	bne	s2,a0,ffffffffc0202320 <vmm_init+0x4a6>
}
ffffffffc0202140:	6406                	ld	s0,64(sp)
ffffffffc0202142:	60a6                	ld	ra,72(sp)
ffffffffc0202144:	74e2                	ld	s1,56(sp)
ffffffffc0202146:	7942                	ld	s2,48(sp)
ffffffffc0202148:	79a2                	ld	s3,40(sp)
ffffffffc020214a:	7a02                	ld	s4,32(sp)
ffffffffc020214c:	6ae2                	ld	s5,24(sp)
ffffffffc020214e:	6b42                	ld	s6,16(sp)
ffffffffc0202150:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202152:	00004517          	auipc	a0,0x4
ffffffffc0202156:	82650513          	addi	a0,a0,-2010 # ffffffffc0205978 <commands+0x11c8>
}
ffffffffc020215a:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020215c:	f63fd06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202160:	00003697          	auipc	a3,0x3
ffffffffc0202164:	63068693          	addi	a3,a3,1584 # ffffffffc0205790 <commands+0xfe0>
ffffffffc0202168:	00003617          	auipc	a2,0x3
ffffffffc020216c:	03860613          	addi	a2,a2,56 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202170:	0dd00593          	li	a1,221
ffffffffc0202174:	00003517          	auipc	a0,0x3
ffffffffc0202178:	50450513          	addi	a0,a0,1284 # ffffffffc0205678 <commands+0xec8>
ffffffffc020217c:	f8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0202180:	00003697          	auipc	a3,0x3
ffffffffc0202184:	69868693          	addi	a3,a3,1688 # ffffffffc0205818 <commands+0x1068>
ffffffffc0202188:	00003617          	auipc	a2,0x3
ffffffffc020218c:	01860613          	addi	a2,a2,24 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202190:	0ed00593          	li	a1,237
ffffffffc0202194:	00003517          	auipc	a0,0x3
ffffffffc0202198:	4e450513          	addi	a0,a0,1252 # ffffffffc0205678 <commands+0xec8>
ffffffffc020219c:	f6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02021a0:	00003697          	auipc	a3,0x3
ffffffffc02021a4:	6a868693          	addi	a3,a3,1704 # ffffffffc0205848 <commands+0x1098>
ffffffffc02021a8:	00003617          	auipc	a2,0x3
ffffffffc02021ac:	ff860613          	addi	a2,a2,-8 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02021b0:	0ee00593          	li	a1,238
ffffffffc02021b4:	00003517          	auipc	a0,0x3
ffffffffc02021b8:	4c450513          	addi	a0,a0,1220 # ffffffffc0205678 <commands+0xec8>
ffffffffc02021bc:	f4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(vma != NULL);
ffffffffc02021c0:	00003697          	auipc	a3,0x3
ffffffffc02021c4:	7d068693          	addi	a3,a3,2000 # ffffffffc0205990 <commands+0x11e0>
ffffffffc02021c8:	00003617          	auipc	a2,0x3
ffffffffc02021cc:	fd860613          	addi	a2,a2,-40 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02021d0:	11100593          	li	a1,273
ffffffffc02021d4:	00003517          	auipc	a0,0x3
ffffffffc02021d8:	4a450513          	addi	a0,a0,1188 # ffffffffc0205678 <commands+0xec8>
ffffffffc02021dc:	f2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02021e0:	00003697          	auipc	a3,0x3
ffffffffc02021e4:	59868693          	addi	a3,a3,1432 # ffffffffc0205778 <commands+0xfc8>
ffffffffc02021e8:	00003617          	auipc	a2,0x3
ffffffffc02021ec:	fb860613          	addi	a2,a2,-72 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02021f0:	0db00593          	li	a1,219
ffffffffc02021f4:	00003517          	auipc	a0,0x3
ffffffffc02021f8:	48450513          	addi	a0,a0,1156 # ffffffffc0205678 <commands+0xec8>
ffffffffc02021fc:	f0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma4 == NULL);
ffffffffc0202200:	00003697          	auipc	a3,0x3
ffffffffc0202204:	5f868693          	addi	a3,a3,1528 # ffffffffc02057f8 <commands+0x1048>
ffffffffc0202208:	00003617          	auipc	a2,0x3
ffffffffc020220c:	f9860613          	addi	a2,a2,-104 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202210:	0e900593          	li	a1,233
ffffffffc0202214:	00003517          	auipc	a0,0x3
ffffffffc0202218:	46450513          	addi	a0,a0,1124 # ffffffffc0205678 <commands+0xec8>
ffffffffc020221c:	eebfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma3 == NULL);
ffffffffc0202220:	00003697          	auipc	a3,0x3
ffffffffc0202224:	5c868693          	addi	a3,a3,1480 # ffffffffc02057e8 <commands+0x1038>
ffffffffc0202228:	00003617          	auipc	a2,0x3
ffffffffc020222c:	f7860613          	addi	a2,a2,-136 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202230:	0e700593          	li	a1,231
ffffffffc0202234:	00003517          	auipc	a0,0x3
ffffffffc0202238:	44450513          	addi	a0,a0,1092 # ffffffffc0205678 <commands+0xec8>
ffffffffc020223c:	ecbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma2 != NULL);
ffffffffc0202240:	00003697          	auipc	a3,0x3
ffffffffc0202244:	59868693          	addi	a3,a3,1432 # ffffffffc02057d8 <commands+0x1028>
ffffffffc0202248:	00003617          	auipc	a2,0x3
ffffffffc020224c:	f5860613          	addi	a2,a2,-168 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202250:	0e500593          	li	a1,229
ffffffffc0202254:	00003517          	auipc	a0,0x3
ffffffffc0202258:	42450513          	addi	a0,a0,1060 # ffffffffc0205678 <commands+0xec8>
ffffffffc020225c:	eabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma1 != NULL);
ffffffffc0202260:	00003697          	auipc	a3,0x3
ffffffffc0202264:	56868693          	addi	a3,a3,1384 # ffffffffc02057c8 <commands+0x1018>
ffffffffc0202268:	00003617          	auipc	a2,0x3
ffffffffc020226c:	f3860613          	addi	a2,a2,-200 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202270:	0e300593          	li	a1,227
ffffffffc0202274:	00003517          	auipc	a0,0x3
ffffffffc0202278:	40450513          	addi	a0,a0,1028 # ffffffffc0205678 <commands+0xec8>
ffffffffc020227c:	e8bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        assert(vma5 == NULL);
ffffffffc0202280:	00003697          	auipc	a3,0x3
ffffffffc0202284:	58868693          	addi	a3,a3,1416 # ffffffffc0205808 <commands+0x1058>
ffffffffc0202288:	00003617          	auipc	a2,0x3
ffffffffc020228c:	f1860613          	addi	a2,a2,-232 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202290:	0eb00593          	li	a1,235
ffffffffc0202294:	00003517          	auipc	a0,0x3
ffffffffc0202298:	3e450513          	addi	a0,a0,996 # ffffffffc0205678 <commands+0xec8>
ffffffffc020229c:	e6bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(mm != NULL);
ffffffffc02022a0:	00003697          	auipc	a3,0x3
ffffffffc02022a4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205768 <commands+0xfb8>
ffffffffc02022a8:	00003617          	auipc	a2,0x3
ffffffffc02022ac:	ef860613          	addi	a2,a2,-264 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02022b0:	0c700593          	li	a1,199
ffffffffc02022b4:	00003517          	auipc	a0,0x3
ffffffffc02022b8:	3c450513          	addi	a0,a0,964 # ffffffffc0205678 <commands+0xec8>
ffffffffc02022bc:	e4bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022c0:	00003697          	auipc	a3,0x3
ffffffffc02022c4:	5f868693          	addi	a3,a3,1528 # ffffffffc02058b8 <commands+0x1108>
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	ed860613          	addi	a2,a2,-296 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02022d0:	0fb00593          	li	a1,251
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	3a450513          	addi	a0,a0,932 # ffffffffc0205678 <commands+0xec8>
ffffffffc02022dc:	e2bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02022e0:	00003697          	auipc	a3,0x3
ffffffffc02022e4:	5d868693          	addi	a3,a3,1496 # ffffffffc02058b8 <commands+0x1108>
ffffffffc02022e8:	00003617          	auipc	a2,0x3
ffffffffc02022ec:	eb860613          	addi	a2,a2,-328 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02022f0:	12e00593          	li	a1,302
ffffffffc02022f4:	00003517          	auipc	a0,0x3
ffffffffc02022f8:	38450513          	addi	a0,a0,900 # ffffffffc0205678 <commands+0xec8>
ffffffffc02022fc:	e0bfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0202300:	00003697          	auipc	a3,0x3
ffffffffc0202304:	60068693          	addi	a3,a3,1536 # ffffffffc0205900 <commands+0x1150>
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	e9860613          	addi	a2,a2,-360 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202310:	10a00593          	li	a1,266
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	36450513          	addi	a0,a0,868 # ffffffffc0205678 <commands+0xec8>
ffffffffc020231c:	debfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202320:	00003697          	auipc	a3,0x3
ffffffffc0202324:	59868693          	addi	a3,a3,1432 # ffffffffc02058b8 <commands+0x1108>
ffffffffc0202328:	00003617          	auipc	a2,0x3
ffffffffc020232c:	e7860613          	addi	a2,a2,-392 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202330:	0bd00593          	li	a1,189
ffffffffc0202334:	00003517          	auipc	a0,0x3
ffffffffc0202338:	34450513          	addi	a0,a0,836 # ffffffffc0205678 <commands+0xec8>
ffffffffc020233c:	dcbfd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202340:	00003697          	auipc	a3,0x3
ffffffffc0202344:	5e868693          	addi	a3,a3,1512 # ffffffffc0205928 <commands+0x1178>
ffffffffc0202348:	00003617          	auipc	a2,0x3
ffffffffc020234c:	e5860613          	addi	a2,a2,-424 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202350:	11600593          	li	a1,278
ffffffffc0202354:	00003517          	auipc	a0,0x3
ffffffffc0202358:	32450513          	addi	a0,a0,804 # ffffffffc0205678 <commands+0xec8>
ffffffffc020235c:	dabfd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202360:	00003617          	auipc	a2,0x3
ffffffffc0202364:	d0860613          	addi	a2,a2,-760 # ffffffffc0205068 <commands+0x8b8>
ffffffffc0202368:	06500593          	li	a1,101
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	d1c50513          	addi	a0,a0,-740 # ffffffffc0205088 <commands+0x8d8>
ffffffffc0202374:	d93fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(sum == 0);
ffffffffc0202378:	00003697          	auipc	a3,0x3
ffffffffc020237c:	5d068693          	addi	a3,a3,1488 # ffffffffc0205948 <commands+0x1198>
ffffffffc0202380:	00003617          	auipc	a2,0x3
ffffffffc0202384:	e2060613          	addi	a2,a2,-480 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202388:	12000593          	li	a1,288
ffffffffc020238c:	00003517          	auipc	a0,0x3
ffffffffc0202390:	2ec50513          	addi	a0,a0,748 # ffffffffc0205678 <commands+0xec8>
ffffffffc0202394:	d73fd0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202398:	00003697          	auipc	a3,0x3
ffffffffc020239c:	58068693          	addi	a3,a3,1408 # ffffffffc0205918 <commands+0x1168>
ffffffffc02023a0:	00003617          	auipc	a2,0x3
ffffffffc02023a4:	e0060613          	addi	a2,a2,-512 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02023a8:	10d00593          	li	a1,269
ffffffffc02023ac:	00003517          	auipc	a0,0x3
ffffffffc02023b0:	2cc50513          	addi	a0,a0,716 # ffffffffc0205678 <commands+0xec8>
ffffffffc02023b4:	d53fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02023b8 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02023b8:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02023ba:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02023bc:	f022                	sd	s0,32(sp)
ffffffffc02023be:	ec26                	sd	s1,24(sp)
ffffffffc02023c0:	f406                	sd	ra,40(sp)
ffffffffc02023c2:	e84a                	sd	s2,16(sp)
ffffffffc02023c4:	8432                	mv	s0,a2
ffffffffc02023c6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02023c8:	971ff0ef          	jal	ra,ffffffffc0201d38 <find_vma>

    pgfault_num++;
ffffffffc02023cc:	0000f797          	auipc	a5,0xf
ffffffffc02023d0:	09c78793          	addi	a5,a5,156 # ffffffffc0211468 <pgfault_num>
ffffffffc02023d4:	439c                	lw	a5,0(a5)
ffffffffc02023d6:	2785                	addiw	a5,a5,1
ffffffffc02023d8:	0000f717          	auipc	a4,0xf
ffffffffc02023dc:	08f72823          	sw	a5,144(a4) # ffffffffc0211468 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02023e0:	c549                	beqz	a0,ffffffffc020246a <do_pgfault+0xb2>
ffffffffc02023e2:	651c                	ld	a5,8(a0)
ffffffffc02023e4:	08f46363          	bltu	s0,a5,ffffffffc020246a <do_pgfault+0xb2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023e8:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02023ea:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02023ec:	8b89                	andi	a5,a5,2
ffffffffc02023ee:	efa9                	bnez	a5,ffffffffc0202448 <do_pgfault+0x90>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023f0:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023f2:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02023f4:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02023f6:	85a2                	mv	a1,s0
ffffffffc02023f8:	4605                	li	a2,1
ffffffffc02023fa:	801fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02023fe:	610c                	ld	a1,0(a0)
ffffffffc0202400:	c5b1                	beqz	a1,ffffffffc020244c <do_pgfault+0x94>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202402:	0000f797          	auipc	a5,0xf
ffffffffc0202406:	07678793          	addi	a5,a5,118 # ffffffffc0211478 <swap_init_ok>
ffffffffc020240a:	439c                	lw	a5,0(a5)
ffffffffc020240c:	2781                	sext.w	a5,a5
ffffffffc020240e:	c7bd                	beqz	a5,ffffffffc020247c <do_pgfault+0xc4>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc0202410:	85a2                	mv	a1,s0
ffffffffc0202412:	0030                	addi	a2,sp,8
ffffffffc0202414:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202416:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0202418:	321000ef          	jal	ra,ffffffffc0202f38 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020241c:	65a2                	ld	a1,8(sp)
ffffffffc020241e:	6c88                	ld	a0,24(s1)
ffffffffc0202420:	86ca                	mv	a3,s2
ffffffffc0202422:	8622                	mv	a2,s0
ffffffffc0202424:	aaffe0ef          	jal	ra,ffffffffc0200ed2 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202428:	6622                	ld	a2,8(sp)
ffffffffc020242a:	4685                	li	a3,1
ffffffffc020242c:	85a2                	mv	a1,s0
ffffffffc020242e:	8526                	mv	a0,s1
ffffffffc0202430:	1e5000ef          	jal	ra,ffffffffc0202e14 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202434:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202436:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0202438:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc020243a:	70a2                	ld	ra,40(sp)
ffffffffc020243c:	7402                	ld	s0,32(sp)
ffffffffc020243e:	64e2                	ld	s1,24(sp)
ffffffffc0202440:	6942                	ld	s2,16(sp)
ffffffffc0202442:	853e                	mv	a0,a5
ffffffffc0202444:	6145                	addi	sp,sp,48
ffffffffc0202446:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0202448:	4959                	li	s2,22
ffffffffc020244a:	b75d                	j	ffffffffc02023f0 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020244c:	6c88                	ld	a0,24(s1)
ffffffffc020244e:	864a                	mv	a2,s2
ffffffffc0202450:	85a2                	mv	a1,s0
ffffffffc0202452:	e34ff0ef          	jal	ra,ffffffffc0201a86 <pgdir_alloc_page>
   ret = 0;
ffffffffc0202456:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202458:	f16d                	bnez	a0,ffffffffc020243a <do_pgfault+0x82>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc020245a:	00003517          	auipc	a0,0x3
ffffffffc020245e:	25e50513          	addi	a0,a0,606 # ffffffffc02056b8 <commands+0xf08>
ffffffffc0202462:	c5dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202466:	57f1                	li	a5,-4
            goto failed;
ffffffffc0202468:	bfc9                	j	ffffffffc020243a <do_pgfault+0x82>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020246a:	85a2                	mv	a1,s0
ffffffffc020246c:	00003517          	auipc	a0,0x3
ffffffffc0202470:	21c50513          	addi	a0,a0,540 # ffffffffc0205688 <commands+0xed8>
ffffffffc0202474:	c4bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0202478:	57f5                	li	a5,-3
        goto failed;
ffffffffc020247a:	b7c1                	j	ffffffffc020243a <do_pgfault+0x82>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020247c:	00003517          	auipc	a0,0x3
ffffffffc0202480:	26450513          	addi	a0,a0,612 # ffffffffc02056e0 <commands+0xf30>
ffffffffc0202484:	c3bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202488:	57f1                	li	a5,-4
            goto failed;
ffffffffc020248a:	bf45                	j	ffffffffc020243a <do_pgfault+0x82>

ffffffffc020248c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020248c:	7135                	addi	sp,sp,-160
ffffffffc020248e:	ed06                	sd	ra,152(sp)
ffffffffc0202490:	e922                	sd	s0,144(sp)
ffffffffc0202492:	e526                	sd	s1,136(sp)
ffffffffc0202494:	e14a                	sd	s2,128(sp)
ffffffffc0202496:	fcce                	sd	s3,120(sp)
ffffffffc0202498:	f8d2                	sd	s4,112(sp)
ffffffffc020249a:	f4d6                	sd	s5,104(sp)
ffffffffc020249c:	f0da                	sd	s6,96(sp)
ffffffffc020249e:	ecde                	sd	s7,88(sp)
ffffffffc02024a0:	e8e2                	sd	s8,80(sp)
ffffffffc02024a2:	e4e6                	sd	s9,72(sp)
ffffffffc02024a4:	e0ea                	sd	s10,64(sp)
ffffffffc02024a6:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02024a8:	2bd010ef          	jal	ra,ffffffffc0203f64 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02024ac:	0000f797          	auipc	a5,0xf
ffffffffc02024b0:	09c78793          	addi	a5,a5,156 # ffffffffc0211548 <max_swap_offset>
ffffffffc02024b4:	6394                	ld	a3,0(a5)
ffffffffc02024b6:	010007b7          	lui	a5,0x1000
ffffffffc02024ba:	17e1                	addi	a5,a5,-8
ffffffffc02024bc:	ff968713          	addi	a4,a3,-7
ffffffffc02024c0:	6ce7e663          	bltu	a5,a4,ffffffffc0202b8c <swap_init+0x700>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc02024c4:	00008797          	auipc	a5,0x8
ffffffffc02024c8:	b3c78793          	addi	a5,a5,-1220 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc02024cc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc02024ce:	0000f697          	auipc	a3,0xf
ffffffffc02024d2:	faf6b123          	sd	a5,-94(a3) # ffffffffc0211470 <sm>
ffffffffc02024d6:	0000f997          	auipc	s3,0xf
ffffffffc02024da:	f9a98993          	addi	s3,s3,-102 # ffffffffc0211470 <sm>
     int r = sm->init();
ffffffffc02024de:	9702                	jalr	a4
ffffffffc02024e0:	e02a                	sd	a0,0(sp)
     
     if (r == 0)
ffffffffc02024e2:	c10d                	beqz	a0,ffffffffc0202504 <swap_init+0x78>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02024e4:	60ea                	ld	ra,152(sp)
ffffffffc02024e6:	644a                	ld	s0,144(sp)
ffffffffc02024e8:	6502                	ld	a0,0(sp)
ffffffffc02024ea:	64aa                	ld	s1,136(sp)
ffffffffc02024ec:	690a                	ld	s2,128(sp)
ffffffffc02024ee:	79e6                	ld	s3,120(sp)
ffffffffc02024f0:	7a46                	ld	s4,112(sp)
ffffffffc02024f2:	7aa6                	ld	s5,104(sp)
ffffffffc02024f4:	7b06                	ld	s6,96(sp)
ffffffffc02024f6:	6be6                	ld	s7,88(sp)
ffffffffc02024f8:	6c46                	ld	s8,80(sp)
ffffffffc02024fa:	6ca6                	ld	s9,72(sp)
ffffffffc02024fc:	6d06                	ld	s10,64(sp)
ffffffffc02024fe:	7de2                	ld	s11,56(sp)
ffffffffc0202500:	610d                	addi	sp,sp,160
ffffffffc0202502:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202504:	0009b783          	ld	a5,0(s3)
ffffffffc0202508:	00003517          	auipc	a0,0x3
ffffffffc020250c:	51850513          	addi	a0,a0,1304 # ffffffffc0205a20 <commands+0x1270>
ffffffffc0202510:	0000f917          	auipc	s2,0xf
ffffffffc0202514:	07890913          	addi	s2,s2,120 # ffffffffc0211588 <free_area>
ffffffffc0202518:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020251a:	4785                	li	a5,1
ffffffffc020251c:	0000f717          	auipc	a4,0xf
ffffffffc0202520:	f4f72e23          	sw	a5,-164(a4) # ffffffffc0211478 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202524:	b9bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202528:	00893783          	ld	a5,8(s2)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020252c:	5d278463          	beq	a5,s2,ffffffffc0202af4 <swap_init+0x668>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202530:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202534:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202536:	8b05                	andi	a4,a4,1
ffffffffc0202538:	5c070263          	beqz	a4,ffffffffc0202afc <swap_init+0x670>
     int ret, count = 0, total = 0, i;
ffffffffc020253c:	4481                	li	s1,0
ffffffffc020253e:	4a01                	li	s4,0
ffffffffc0202540:	a031                	j	ffffffffc020254c <swap_init+0xc0>
ffffffffc0202542:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202546:	8b09                	andi	a4,a4,2
ffffffffc0202548:	5a070a63          	beqz	a4,ffffffffc0202afc <swap_init+0x670>
        count ++, total += p->property;
ffffffffc020254c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202550:	679c                	ld	a5,8(a5)
ffffffffc0202552:	2a05                	addiw	s4,s4,1
ffffffffc0202554:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202556:	ff2796e3          	bne	a5,s2,ffffffffc0202542 <swap_init+0xb6>
ffffffffc020255a:	8426                	mv	s0,s1
     }
     assert(total == nr_free_pages());
ffffffffc020255c:	e5efe0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0202560:	68851263          	bne	a0,s0,ffffffffc0202be4 <swap_init+0x758>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202564:	8626                	mv	a2,s1
ffffffffc0202566:	85d2                	mv	a1,s4
ffffffffc0202568:	00003517          	auipc	a0,0x3
ffffffffc020256c:	50050513          	addi	a0,a0,1280 # ffffffffc0205a68 <commands+0x12b8>
ffffffffc0202570:	b4ffd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202574:	f4aff0ef          	jal	ra,ffffffffc0201cbe <mm_create>
ffffffffc0202578:	842a                	mv	s0,a0
     assert(mm != NULL);
ffffffffc020257a:	060505e3          	beqz	a0,ffffffffc0202de4 <swap_init+0x958>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020257e:	0000f797          	auipc	a5,0xf
ffffffffc0202582:	f3a78793          	addi	a5,a5,-198 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0202586:	639c                	ld	a5,0(a5)
ffffffffc0202588:	62079e63          	bnez	a5,ffffffffc0202bc4 <swap_init+0x738>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020258c:	0000f797          	auipc	a5,0xf
ffffffffc0202590:	ecc78793          	addi	a5,a5,-308 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202594:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202598:	0000f797          	auipc	a5,0xf
ffffffffc020259c:	f2a7b023          	sd	a0,-224(a5) # ffffffffc02114b8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02025a0:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02025a4:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02025a8:	72079e63          	bnez	a5,ffffffffc0202ce4 <swap_init+0x858>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02025ac:	6599                	lui	a1,0x6
ffffffffc02025ae:	460d                	li	a2,3
ffffffffc02025b0:	6505                	lui	a0,0x1
ffffffffc02025b2:	f58ff0ef          	jal	ra,ffffffffc0201d0a <vma_create>
ffffffffc02025b6:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02025b8:	74050663          	beqz	a0,ffffffffc0202d04 <swap_init+0x878>

     insert_vma_struct(mm, vma);
ffffffffc02025bc:	8522                	mv	a0,s0
ffffffffc02025be:	fb8ff0ef          	jal	ra,ffffffffc0201d76 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02025c2:	00003517          	auipc	a0,0x3
ffffffffc02025c6:	4e650513          	addi	a0,a0,1254 # ffffffffc0205aa8 <commands+0x12f8>
ffffffffc02025ca:	af5fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02025ce:	6c08                	ld	a0,24(s0)
ffffffffc02025d0:	4605                	li	a2,1
ffffffffc02025d2:	6585                	lui	a1,0x1
ffffffffc02025d4:	e26fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02025d8:	74050663          	beqz	a0,ffffffffc0202d24 <swap_init+0x898>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025dc:	00003517          	auipc	a0,0x3
ffffffffc02025e0:	51c50513          	addi	a0,a0,1308 # ffffffffc0205af8 <commands+0x1348>
ffffffffc02025e4:	0000fb97          	auipc	s7,0xf
ffffffffc02025e8:	edcb8b93          	addi	s7,s7,-292 # ffffffffc02114c0 <check_rp>
ffffffffc02025ec:	ad3fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02025f0:	0000fd97          	auipc	s11,0xf
ffffffffc02025f4:	ef0d8d93          	addi	s11,s11,-272 # ffffffffc02114e0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02025f8:	8ade                	mv	s5,s7
          check_rp[i] = alloc_page();
ffffffffc02025fa:	4505                	li	a0,1
ffffffffc02025fc:	cf0fe0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0202600:	00aab023          	sd	a0,0(s5)
          assert(check_rp[i] != NULL );
ffffffffc0202604:	56050463          	beqz	a0,ffffffffc0202b6c <swap_init+0x6e0>
ffffffffc0202608:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc020260a:	8b89                	andi	a5,a5,2
ffffffffc020260c:	54079063          	bnez	a5,ffffffffc0202b4c <swap_init+0x6c0>
ffffffffc0202610:	0aa1                	addi	s5,s5,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202612:	ff5d94e3          	bne	s11,s5,ffffffffc02025fa <swap_init+0x16e>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202616:	00093783          	ld	a5,0(s2)
ffffffffc020261a:	00893a83          	ld	s5,8(s2)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc020261e:	0000fc17          	auipc	s8,0xf
ffffffffc0202622:	ea2c0c13          	addi	s8,s8,-350 # ffffffffc02114c0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202626:	ec3e                	sd	a5,24(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202628:	01092783          	lw	a5,16(s2)
ffffffffc020262c:	f03e                	sd	a5,32(sp)
    elm->prev = elm->next = elm;
ffffffffc020262e:	0000f797          	auipc	a5,0xf
ffffffffc0202632:	f727b123          	sd	s2,-158(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc0202636:	0000f797          	auipc	a5,0xf
ffffffffc020263a:	f527b923          	sd	s2,-174(a5) # ffffffffc0211588 <free_area>
     nr_free = 0;
ffffffffc020263e:	0000f797          	auipc	a5,0xf
ffffffffc0202642:	f407ad23          	sw	zero,-166(a5) # ffffffffc0211598 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202646:	000c3503          	ld	a0,0(s8)
ffffffffc020264a:	4585                	li	a1,1
ffffffffc020264c:	0c21                	addi	s8,s8,8
ffffffffc020264e:	d26fe0ef          	jal	ra,ffffffffc0200b74 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202652:	ff8d9ae3          	bne	s11,s8,ffffffffc0202646 <swap_init+0x1ba>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202656:	01092703          	lw	a4,16(s2)
ffffffffc020265a:	4791                	li	a5,4
ffffffffc020265c:	6ef71463          	bne	a4,a5,ffffffffc0202d44 <swap_init+0x8b8>
     // cprintf("count is %d, total is %d\n",count,total);
     // //assert(count == 0);
     
     // cprintf("check_swap() succeeded!\n");
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202660:	00003517          	auipc	a0,0x3
ffffffffc0202664:	52050513          	addi	a0,a0,1312 # ffffffffc0205b80 <commands+0x13d0>
ffffffffc0202668:	a57fd0ef          	jal	ra,ffffffffc02000be <cprintf>

     pgfault_num=0;
ffffffffc020266c:	0000f797          	auipc	a5,0xf
ffffffffc0202670:	de07ae23          	sw	zero,-516(a5) # ffffffffc0211468 <pgfault_num>
     *(unsigned char *)la = value;
ffffffffc0202674:	47a9                	li	a5,10
ffffffffc0202676:	6685                	lui	a3,0x1
ffffffffc0202678:	00f68023          	sb	a5,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020267c:	4601                	li	a2,0
ffffffffc020267e:	6585                	lui	a1,0x1
ffffffffc0202680:	855a                	mv	a0,s6
ffffffffc0202682:	d78fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc0202686:	611c                	ld	a5,0(a0)
     pgfault_num=0;
ffffffffc0202688:	0000fc97          	auipc	s9,0xf
ffffffffc020268c:	de0c8c93          	addi	s9,s9,-544 # ffffffffc0211468 <pgfault_num>
    if (!(pte & PTE_V)) {
ffffffffc0202690:	0017f713          	andi	a4,a5,1
ffffffffc0202694:	4a070063          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202698:	0000fc17          	auipc	s8,0xf
ffffffffc020269c:	dc8c0c13          	addi	s8,s8,-568 # ffffffffc0211460 <npage>
ffffffffc02026a0:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026a4:	078a                	slli	a5,a5,0x2
ffffffffc02026a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026a8:	46e7fa63          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc02026ac:	00004717          	auipc	a4,0x4
ffffffffc02026b0:	e6470713          	addi	a4,a4,-412 # ffffffffc0206510 <nbase>
ffffffffc02026b4:	6318                	ld	a4,0(a4)
     sm->update_swaplist(mm, page);
ffffffffc02026b6:	0009b603          	ld	a2,0(s3)
ffffffffc02026ba:	0000fd17          	auipc	s10,0xf
ffffffffc02026be:	de6d0d13          	addi	s10,s10,-538 # ffffffffc02114a0 <pages>
ffffffffc02026c2:	8f99                	sub	a5,a5,a4
ffffffffc02026c4:	e83a                	sd	a4,16(sp)
ffffffffc02026c6:	000d3583          	ld	a1,0(s10)
ffffffffc02026ca:	00379713          	slli	a4,a5,0x3
ffffffffc02026ce:	97ba                	add	a5,a5,a4
ffffffffc02026d0:	6238                	ld	a4,64(a2)
ffffffffc02026d2:	078e                	slli	a5,a5,0x3
ffffffffc02026d4:	95be                	add	a1,a1,a5
ffffffffc02026d6:	8522                	mv	a0,s0
ffffffffc02026d8:	9702                	jalr	a4

     check_content_set_fixed(pgdir, mm, 0x1000, 0x0a);
     assert(pgfault_num==1);
ffffffffc02026da:	000ca703          	lw	a4,0(s9)
ffffffffc02026de:	4785                	li	a5,1
ffffffffc02026e0:	6685                	lui	a3,0x1
ffffffffc02026e2:	2701                	sext.w	a4,a4
ffffffffc02026e4:	e43a                	sd	a4,8(sp)
ffffffffc02026e6:	66f71f63          	bne	a4,a5,ffffffffc0202d64 <swap_init+0x8d8>
     *(unsigned char *)la = value;
ffffffffc02026ea:	47a9                	li	a5,10
ffffffffc02026ec:	00f68823          	sb	a5,16(a3) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026f0:	4601                	li	a2,0
ffffffffc02026f2:	01068593          	addi	a1,a3,16
ffffffffc02026f6:	855a                	mv	a0,s6
ffffffffc02026f8:	d02fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc02026fc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02026fe:	0017f713          	andi	a4,a5,1
ffffffffc0202702:	42070963          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202706:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020270a:	078a                	slli	a5,a5,0x2
ffffffffc020270c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020270e:	40e7f763          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202712:	6742                	ld	a4,16(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202714:	0009b683          	ld	a3,0(s3)
ffffffffc0202718:	000d3583          	ld	a1,0(s10)
ffffffffc020271c:	8f99                	sub	a5,a5,a4
ffffffffc020271e:	00379713          	slli	a4,a5,0x3
ffffffffc0202722:	97ba                	add	a5,a5,a4
ffffffffc0202724:	62b8                	ld	a4,64(a3)
ffffffffc0202726:	078e                	slli	a5,a5,0x3
ffffffffc0202728:	95be                	add	a1,a1,a5
ffffffffc020272a:	8522                	mv	a0,s0
ffffffffc020272c:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x1010, 0x0a);
     assert(pgfault_num==1);
ffffffffc020272e:	000ca783          	lw	a5,0(s9)
ffffffffc0202732:	6722                	ld	a4,8(sp)
ffffffffc0202734:	2781                	sext.w	a5,a5
ffffffffc0202736:	64e79763          	bne	a5,a4,ffffffffc0202d84 <swap_init+0x8f8>
     *(unsigned char *)la = value;
ffffffffc020273a:	6789                	lui	a5,0x2
ffffffffc020273c:	472d                	li	a4,11
ffffffffc020273e:	00e78023          	sb	a4,0(a5) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202742:	4601                	li	a2,0
ffffffffc0202744:	6589                	lui	a1,0x2
ffffffffc0202746:	855a                	mv	a0,s6
ffffffffc0202748:	cb2fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc020274c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020274e:	0017f713          	andi	a4,a5,1
ffffffffc0202752:	3e070163          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202756:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020275a:	078a                	slli	a5,a5,0x2
ffffffffc020275c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020275e:	3ae7ff63          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202762:	00004717          	auipc	a4,0x4
ffffffffc0202766:	dae70713          	addi	a4,a4,-594 # ffffffffc0206510 <nbase>
ffffffffc020276a:	6318                	ld	a4,0(a4)
     sm->update_swaplist(mm, page);
ffffffffc020276c:	0009b683          	ld	a3,0(s3)
ffffffffc0202770:	000d3583          	ld	a1,0(s10)
ffffffffc0202774:	8f99                	sub	a5,a5,a4
ffffffffc0202776:	e43a                	sd	a4,8(sp)
ffffffffc0202778:	00379713          	slli	a4,a5,0x3
ffffffffc020277c:	97ba                	add	a5,a5,a4
ffffffffc020277e:	62b8                	ld	a4,64(a3)
ffffffffc0202780:	078e                	slli	a5,a5,0x3
ffffffffc0202782:	95be                	add	a1,a1,a5
ffffffffc0202784:	8522                	mv	a0,s0
ffffffffc0202786:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x2000, 0x0b);
     assert(pgfault_num==2);
ffffffffc0202788:	000ca703          	lw	a4,0(s9)
ffffffffc020278c:	4789                	li	a5,2
ffffffffc020278e:	2701                	sext.w	a4,a4
ffffffffc0202790:	e83a                	sd	a4,16(sp)
ffffffffc0202792:	60f71963          	bne	a4,a5,ffffffffc0202da4 <swap_init+0x918>
     *(unsigned char *)la = value;
ffffffffc0202796:	47ad                	li	a5,11
ffffffffc0202798:	6589                	lui	a1,0x2
ffffffffc020279a:	00f58823          	sb	a5,16(a1) # 2010 <BASE_ADDRESS-0xffffffffc01fdff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020279e:	4601                	li	a2,0
ffffffffc02027a0:	05c1                	addi	a1,a1,16
ffffffffc02027a2:	855a                	mv	a0,s6
ffffffffc02027a4:	c56fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc02027a8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027aa:	0017f713          	andi	a4,a5,1
ffffffffc02027ae:	38070363          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc02027b2:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027b6:	078a                	slli	a5,a5,0x2
ffffffffc02027b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ba:	36e7f163          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc02027be:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc02027c0:	0009b683          	ld	a3,0(s3)
ffffffffc02027c4:	000d3583          	ld	a1,0(s10)
ffffffffc02027c8:	8f99                	sub	a5,a5,a4
ffffffffc02027ca:	00379713          	slli	a4,a5,0x3
ffffffffc02027ce:	97ba                	add	a5,a5,a4
ffffffffc02027d0:	62b8                	ld	a4,64(a3)
ffffffffc02027d2:	078e                	slli	a5,a5,0x3
ffffffffc02027d4:	95be                	add	a1,a1,a5
ffffffffc02027d6:	8522                	mv	a0,s0
ffffffffc02027d8:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x2010, 0x0b);
     assert(pgfault_num==2);
ffffffffc02027da:	000ca783          	lw	a5,0(s9)
ffffffffc02027de:	6742                	ld	a4,16(sp)
ffffffffc02027e0:	2781                	sext.w	a5,a5
ffffffffc02027e2:	5ee79163          	bne	a5,a4,ffffffffc0202dc4 <swap_init+0x938>
     *(unsigned char *)la = value;
ffffffffc02027e6:	47b1                	li	a5,12
ffffffffc02027e8:	668d                	lui	a3,0x3
ffffffffc02027ea:	00f68023          	sb	a5,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02027ee:	4601                	li	a2,0
ffffffffc02027f0:	658d                	lui	a1,0x3
ffffffffc02027f2:	855a                	mv	a0,s6
ffffffffc02027f4:	c06fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc02027f8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fa:	0017f713          	andi	a4,a5,1
ffffffffc02027fe:	32070b63          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202802:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202806:	078a                	slli	a5,a5,0x2
ffffffffc0202808:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280a:	30e7f963          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc020280e:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202810:	0009b603          	ld	a2,0(s3)
ffffffffc0202814:	000d3583          	ld	a1,0(s10)
ffffffffc0202818:	8f99                	sub	a5,a5,a4
ffffffffc020281a:	00379713          	slli	a4,a5,0x3
ffffffffc020281e:	97ba                	add	a5,a5,a4
ffffffffc0202820:	6238                	ld	a4,64(a2)
ffffffffc0202822:	078e                	slli	a5,a5,0x3
ffffffffc0202824:	95be                	add	a1,a1,a5
ffffffffc0202826:	8522                	mv	a0,s0
ffffffffc0202828:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x3000, 0x0c);
     assert(pgfault_num==3);
ffffffffc020282a:	000ca703          	lw	a4,0(s9)
ffffffffc020282e:	478d                	li	a5,3
ffffffffc0202830:	668d                	lui	a3,0x3
ffffffffc0202832:	2701                	sext.w	a4,a4
ffffffffc0202834:	e83a                	sd	a4,16(sp)
ffffffffc0202836:	36f71763          	bne	a4,a5,ffffffffc0202ba4 <swap_init+0x718>
     *(unsigned char *)la = value;
ffffffffc020283a:	47b1                	li	a5,12
ffffffffc020283c:	00f68823          	sb	a5,16(a3) # 3010 <BASE_ADDRESS-0xffffffffc01fcff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202840:	4601                	li	a2,0
ffffffffc0202842:	01068593          	addi	a1,a3,16
ffffffffc0202846:	855a                	mv	a0,s6
ffffffffc0202848:	bb2fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc020284c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020284e:	0017f713          	andi	a4,a5,1
ffffffffc0202852:	2e070163          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202856:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020285a:	078a                	slli	a5,a5,0x2
ffffffffc020285c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020285e:	2ae7ff63          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202862:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202864:	0009b683          	ld	a3,0(s3)
ffffffffc0202868:	000d3583          	ld	a1,0(s10)
ffffffffc020286c:	8f99                	sub	a5,a5,a4
ffffffffc020286e:	00379713          	slli	a4,a5,0x3
ffffffffc0202872:	97ba                	add	a5,a5,a4
ffffffffc0202874:	62b8                	ld	a4,64(a3)
ffffffffc0202876:	078e                	slli	a5,a5,0x3
ffffffffc0202878:	95be                	add	a1,a1,a5
ffffffffc020287a:	8522                	mv	a0,s0
ffffffffc020287c:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x3010, 0x0c);
     assert(pgfault_num==3);
ffffffffc020287e:	000ca783          	lw	a5,0(s9)
ffffffffc0202882:	6742                	ld	a4,16(sp)
ffffffffc0202884:	2781                	sext.w	a5,a5
ffffffffc0202886:	36e79f63          	bne	a5,a4,ffffffffc0202c04 <swap_init+0x778>
     *(unsigned char *)la = value;
ffffffffc020288a:	6791                	lui	a5,0x4
ffffffffc020288c:	4735                	li	a4,13
ffffffffc020288e:	00e78023          	sb	a4,0(a5) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202892:	4601                	li	a2,0
ffffffffc0202894:	6591                	lui	a1,0x4
ffffffffc0202896:	855a                	mv	a0,s6
ffffffffc0202898:	b62fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc020289c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020289e:	0017f713          	andi	a4,a5,1
ffffffffc02028a2:	28070963          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc02028a6:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028aa:	078a                	slli	a5,a5,0x2
ffffffffc02028ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028ae:	26e7f763          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc02028b2:	00004717          	auipc	a4,0x4
ffffffffc02028b6:	c5e70713          	addi	a4,a4,-930 # ffffffffc0206510 <nbase>
ffffffffc02028ba:	6318                	ld	a4,0(a4)
     sm->update_swaplist(mm, page);
ffffffffc02028bc:	0009b683          	ld	a3,0(s3)
ffffffffc02028c0:	000d3583          	ld	a1,0(s10)
ffffffffc02028c4:	8f99                	sub	a5,a5,a4
ffffffffc02028c6:	e43a                	sd	a4,8(sp)
ffffffffc02028c8:	00379713          	slli	a4,a5,0x3
ffffffffc02028cc:	97ba                	add	a5,a5,a4
ffffffffc02028ce:	62b8                	ld	a4,64(a3)
ffffffffc02028d0:	078e                	slli	a5,a5,0x3
ffffffffc02028d2:	95be                	add	a1,a1,a5
ffffffffc02028d4:	8522                	mv	a0,s0
ffffffffc02028d6:	9702                	jalr	a4
     check_content_set_fixed(pgdir, mm, 0x4000, 0x0d);
     assert(pgfault_num==4);
ffffffffc02028d8:	000ca703          	lw	a4,0(s9)
ffffffffc02028dc:	4791                	li	a5,4
ffffffffc02028de:	2701                	sext.w	a4,a4
ffffffffc02028e0:	e83a                	sd	a4,16(sp)
ffffffffc02028e2:	34f71163          	bne	a4,a5,ffffffffc0202c24 <swap_init+0x798>
     *(unsigned char *)la = value;
ffffffffc02028e6:	6791                	lui	a5,0x4
ffffffffc02028e8:	4735                	li	a4,13
ffffffffc02028ea:	00e78823          	sb	a4,16(a5) # 4010 <BASE_ADDRESS-0xffffffffc01fbff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02028ee:	01078593          	addi	a1,a5,16
ffffffffc02028f2:	4601                	li	a2,0
ffffffffc02028f4:	855a                	mv	a0,s6
ffffffffc02028f6:	b04fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc02028fa:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028fc:	0017f713          	andi	a4,a5,1
ffffffffc0202900:	22070a63          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202904:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202908:	078a                	slli	a5,a5,0x2
ffffffffc020290a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020290c:	20e7f863          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202910:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202912:	0009b683          	ld	a3,0(s3)
ffffffffc0202916:	000d3583          	ld	a1,0(s10)
ffffffffc020291a:	8f99                	sub	a5,a5,a4
ffffffffc020291c:	00379713          	slli	a4,a5,0x3
ffffffffc0202920:	97ba                	add	a5,a5,a4
ffffffffc0202922:	62b8                	ld	a4,64(a3)
ffffffffc0202924:	078e                	slli	a5,a5,0x3
ffffffffc0202926:	95be                	add	a1,a1,a5
ffffffffc0202928:	8522                	mv	a0,s0
ffffffffc020292a:	9702                	jalr	a4
     //（链头/队尾）4000-3000-2000-1000（链尾/队头）
     check_content_set_fixed(pgdir, mm, 0x4010, 0x0d);
     assert(pgfault_num==4);
ffffffffc020292c:	000ca783          	lw	a5,0(s9)
ffffffffc0202930:	6742                	ld	a4,16(sp)
ffffffffc0202932:	2781                	sext.w	a5,a5
ffffffffc0202934:	f43e                	sd	a5,40(sp)
ffffffffc0202936:	30e79763          	bne	a5,a4,ffffffffc0202c44 <swap_init+0x7b8>
     *(unsigned char *)la = value;
ffffffffc020293a:	47ad                	li	a5,11
ffffffffc020293c:	6589                	lui	a1,0x2
ffffffffc020293e:	00f58823          	sb	a5,16(a1) # 2010 <BASE_ADDRESS-0xffffffffc01fdff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202942:	4601                	li	a2,0
ffffffffc0202944:	05c1                	addi	a1,a1,16
ffffffffc0202946:	855a                	mv	a0,s6
ffffffffc0202948:	ab2fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc020294c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020294e:	0017f713          	andi	a4,a5,1
ffffffffc0202952:	1e070163          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202956:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020295a:	078a                	slli	a5,a5,0x2
ffffffffc020295c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020295e:	1ae7ff63          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202962:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202964:	0009b683          	ld	a3,0(s3)
ffffffffc0202968:	000d3583          	ld	a1,0(s10)
ffffffffc020296c:	8f99                	sub	a5,a5,a4
ffffffffc020296e:	00379713          	slli	a4,a5,0x3
ffffffffc0202972:	97ba                	add	a5,a5,a4
ffffffffc0202974:	62b8                	ld	a4,64(a3)
ffffffffc0202976:	078e                	slli	a5,a5,0x3
ffffffffc0202978:	95be                	add	a1,a1,a5
ffffffffc020297a:	8522                	mv	a0,s0
ffffffffc020297c:	9702                	jalr	a4
     //（链头/队尾）4000-3000-2000-1000（链尾/队头）
     check_content_set_fixed(pgdir, mm, 0x2010, 0x0b);
     assert(pgfault_num==4);
ffffffffc020297e:	000ca783          	lw	a5,0(s9)
ffffffffc0202982:	7722                	ld	a4,40(sp)
ffffffffc0202984:	2781                	sext.w	a5,a5
ffffffffc0202986:	2ce79f63          	bne	a5,a4,ffffffffc0202c64 <swap_init+0x7d8>
     *(unsigned char *)la = value;
ffffffffc020298a:	47b9                	li	a5,14
ffffffffc020298c:	6595                	lui	a1,0x5
ffffffffc020298e:	00f58823          	sb	a5,16(a1) # 5010 <BASE_ADDRESS-0xffffffffc01faff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202992:	4601                	li	a2,0
ffffffffc0202994:	05c1                	addi	a1,a1,16
ffffffffc0202996:	855a                	mv	a0,s6
ffffffffc0202998:	a62fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc020299c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020299e:	0017f713          	andi	a4,a5,1
ffffffffc02029a2:	18070963          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc02029a6:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02029aa:	078a                	slli	a5,a5,0x2
ffffffffc02029ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029ae:	16e7f763          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc02029b2:	00004717          	auipc	a4,0x4
ffffffffc02029b6:	b5e70713          	addi	a4,a4,-1186 # ffffffffc0206510 <nbase>
ffffffffc02029ba:	6318                	ld	a4,0(a4)
     sm->update_swaplist(mm, page);
ffffffffc02029bc:	0009b683          	ld	a3,0(s3)
ffffffffc02029c0:	000d3583          	ld	a1,0(s10)
ffffffffc02029c4:	8f99                	sub	a5,a5,a4
ffffffffc02029c6:	e43a                	sd	a4,8(sp)
ffffffffc02029c8:	00379713          	slli	a4,a5,0x3
ffffffffc02029cc:	97ba                	add	a5,a5,a4
ffffffffc02029ce:	62b8                	ld	a4,64(a3)
ffffffffc02029d0:	078e                	slli	a5,a5,0x3
ffffffffc02029d2:	95be                	add	a1,a1,a5
ffffffffc02029d4:	8522                	mv	a0,s0
ffffffffc02029d6:	9702                	jalr	a4
     //（链头/队尾）2000-4000-3000-1000（链尾/队头）
     check_content_set_fixed(pgdir, mm, 0x5010, 0x0e);
     assert(pgfault_num==5);
ffffffffc02029d8:	000ca783          	lw	a5,0(s9)
ffffffffc02029dc:	4715                	li	a4,5
ffffffffc02029de:	2781                	sext.w	a5,a5
ffffffffc02029e0:	2ae79263          	bne	a5,a4,ffffffffc0202c84 <swap_init+0x7f8>
     *(unsigned char *)la = value;
ffffffffc02029e4:	47a9                	li	a5,10
ffffffffc02029e6:	6585                	lui	a1,0x1
ffffffffc02029e8:	00f58823          	sb	a5,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02029ec:	4601                	li	a2,0
ffffffffc02029ee:	05c1                	addi	a1,a1,16
ffffffffc02029f0:	855a                	mv	a0,s6
ffffffffc02029f2:	a08fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc02029f6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02029f8:	0017f713          	andi	a4,a5,1
ffffffffc02029fc:	12070c63          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202a00:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a04:	078a                	slli	a5,a5,0x2
ffffffffc0202a06:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a08:	10e7fa63          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a0c:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202a0e:	0009b683          	ld	a3,0(s3)
ffffffffc0202a12:	000d3583          	ld	a1,0(s10)
ffffffffc0202a16:	8f99                	sub	a5,a5,a4
ffffffffc0202a18:	00379713          	slli	a4,a5,0x3
ffffffffc0202a1c:	97ba                	add	a5,a5,a4
ffffffffc0202a1e:	62b8                	ld	a4,64(a3)
ffffffffc0202a20:	078e                	slli	a5,a5,0x3
ffffffffc0202a22:	95be                	add	a1,a1,a5
ffffffffc0202a24:	8522                	mv	a0,s0
ffffffffc0202a26:	9702                	jalr	a4
     //（链头/队尾）5000-2000-4000-3000（链尾/队头）
     check_content_set_fixed(pgdir, mm, 0x1010, 0x0a);
     assert(pgfault_num==6);
ffffffffc0202a28:	000ca783          	lw	a5,0(s9)
ffffffffc0202a2c:	4719                	li	a4,6
ffffffffc0202a2e:	2781                	sext.w	a5,a5
ffffffffc0202a30:	26e79a63          	bne	a5,a4,ffffffffc0202ca4 <swap_init+0x818>
     *(unsigned char *)la = value;
ffffffffc0202a34:	47b1                	li	a5,12
ffffffffc0202a36:	658d                	lui	a1,0x3
ffffffffc0202a38:	00f58823          	sb	a5,16(a1) # 3010 <BASE_ADDRESS-0xffffffffc01fcff0>
     pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202a3c:	4601                	li	a2,0
ffffffffc0202a3e:	05c1                	addi	a1,a1,16
ffffffffc0202a40:	855a                	mv	a0,s6
ffffffffc0202a42:	9b8fe0ef          	jal	ra,ffffffffc0200bfa <get_pte>
     struct Page *page = pte2page(*ptep);
ffffffffc0202a46:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202a48:	0017f713          	andi	a4,a5,1
ffffffffc0202a4c:	0e070463          	beqz	a4,ffffffffc0202b34 <swap_init+0x6a8>
    if (PPN(pa) >= npage) {
ffffffffc0202a50:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a54:	078a                	slli	a5,a5,0x2
ffffffffc0202a56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a58:	0ce7f263          	bleu	a4,a5,ffffffffc0202b1c <swap_init+0x690>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a5c:	6722                	ld	a4,8(sp)
     sm->update_swaplist(mm, page);
ffffffffc0202a5e:	0009b683          	ld	a3,0(s3)
ffffffffc0202a62:	000d3583          	ld	a1,0(s10)
ffffffffc0202a66:	8f99                	sub	a5,a5,a4
ffffffffc0202a68:	00379713          	slli	a4,a5,0x3
ffffffffc0202a6c:	97ba                	add	a5,a5,a4
ffffffffc0202a6e:	62b8                	ld	a4,64(a3)
ffffffffc0202a70:	078e                	slli	a5,a5,0x3
ffffffffc0202a72:	95be                	add	a1,a1,a5
ffffffffc0202a74:	8522                	mv	a0,s0
ffffffffc0202a76:	9702                	jalr	a4
     //（链头/队尾）1000-5000-2000-4000（链尾/队头）
     check_content_set_fixed(pgdir, mm, 0x3010, 0x0c);
     assert(pgfault_num==7);
ffffffffc0202a78:	000ca783          	lw	a5,0(s9)
ffffffffc0202a7c:	471d                	li	a4,7
ffffffffc0202a7e:	2781                	sext.w	a5,a5
ffffffffc0202a80:	24e79263          	bne	a5,a4,ffffffffc0202cc4 <swap_init+0x838>
     //（链头/队尾）3000-1000-5000-2000（链尾/队头）


     cprintf("set up init env for check_swap over!\n");
ffffffffc0202a84:	00003517          	auipc	a0,0x3
ffffffffc0202a88:	19450513          	addi	a0,a0,404 # ffffffffc0205c18 <commands+0x1468>
ffffffffc0202a8c:	e32fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202a90:	000bb503          	ld	a0,0(s7)
ffffffffc0202a94:	4585                	li	a1,1
ffffffffc0202a96:	0ba1                	addi	s7,s7,8
ffffffffc0202a98:	8dcfe0ef          	jal	ra,ffffffffc0200b74 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a9c:	ffbb9ae3          	bne	s7,s11,ffffffffc0202a90 <swap_init+0x604>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202aa0:	8522                	mv	a0,s0
ffffffffc0202aa2:	ba2ff0ef          	jal	ra,ffffffffc0201e44 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202aa6:	7782                	ld	a5,32(sp)
ffffffffc0202aa8:	0000f717          	auipc	a4,0xf
ffffffffc0202aac:	aef72823          	sw	a5,-1296(a4) # ffffffffc0211598 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202ab0:	67e2                	ld	a5,24(sp)
ffffffffc0202ab2:	0000f717          	auipc	a4,0xf
ffffffffc0202ab6:	acf73b23          	sd	a5,-1322(a4) # ffffffffc0211588 <free_area>
ffffffffc0202aba:	0000f797          	auipc	a5,0xf
ffffffffc0202abe:	ad57bb23          	sd	s5,-1322(a5) # ffffffffc0211590 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ac2:	012a8a63          	beq	s5,s2,ffffffffc0202ad6 <swap_init+0x64a>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202ac6:	ff8aa783          	lw	a5,-8(s5)
    return listelm->next;
ffffffffc0202aca:	008aba83          	ld	s5,8(s5)
ffffffffc0202ace:	3a7d                	addiw	s4,s4,-1
ffffffffc0202ad0:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ad2:	ff2a9ae3          	bne	s5,s2,ffffffffc0202ac6 <swap_init+0x63a>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202ad6:	8626                	mv	a2,s1
ffffffffc0202ad8:	85d2                	mv	a1,s4
ffffffffc0202ada:	00003517          	auipc	a0,0x3
ffffffffc0202ade:	16650513          	addi	a0,a0,358 # ffffffffc0205c40 <commands+0x1490>
ffffffffc0202ae2:	ddcfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202ae6:	00003517          	auipc	a0,0x3
ffffffffc0202aea:	17a50513          	addi	a0,a0,378 # ffffffffc0205c60 <commands+0x14b0>
ffffffffc0202aee:	dd0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202af2:	bacd                	j	ffffffffc02024e4 <swap_init+0x58>
     int ret, count = 0, total = 0, i;
ffffffffc0202af4:	4481                	li	s1,0
ffffffffc0202af6:	4a01                	li	s4,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202af8:	4401                	li	s0,0
ffffffffc0202afa:	b48d                	j	ffffffffc020255c <swap_init+0xd0>
        assert(PageProperty(p));
ffffffffc0202afc:	00003697          	auipc	a3,0x3
ffffffffc0202b00:	f3c68693          	addi	a3,a3,-196 # ffffffffc0205a38 <commands+0x1288>
ffffffffc0202b04:	00002617          	auipc	a2,0x2
ffffffffc0202b08:	69c60613          	addi	a2,a2,1692 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202b0c:	0c700593          	li	a1,199
ffffffffc0202b10:	00003517          	auipc	a0,0x3
ffffffffc0202b14:	f0050513          	addi	a0,a0,-256 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202b18:	deefd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202b1c:	00002617          	auipc	a2,0x2
ffffffffc0202b20:	54c60613          	addi	a2,a2,1356 # ffffffffc0205068 <commands+0x8b8>
ffffffffc0202b24:	06500593          	li	a1,101
ffffffffc0202b28:	00002517          	auipc	a0,0x2
ffffffffc0202b2c:	56050513          	addi	a0,a0,1376 # ffffffffc0205088 <commands+0x8d8>
ffffffffc0202b30:	dd6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202b34:	00002617          	auipc	a2,0x2
ffffffffc0202b38:	74460613          	addi	a2,a2,1860 # ffffffffc0205278 <commands+0xac8>
ffffffffc0202b3c:	07000593          	li	a1,112
ffffffffc0202b40:	00002517          	auipc	a0,0x2
ffffffffc0202b44:	54850513          	addi	a0,a0,1352 # ffffffffc0205088 <commands+0x8d8>
ffffffffc0202b48:	dbefd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202b4c:	00003697          	auipc	a3,0x3
ffffffffc0202b50:	fec68693          	addi	a3,a3,-20 # ffffffffc0205b38 <commands+0x1388>
ffffffffc0202b54:	00002617          	auipc	a2,0x2
ffffffffc0202b58:	64c60613          	addi	a2,a2,1612 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202b5c:	0e800593          	li	a1,232
ffffffffc0202b60:	00003517          	auipc	a0,0x3
ffffffffc0202b64:	eb050513          	addi	a0,a0,-336 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202b68:	d9efd0ef          	jal	ra,ffffffffc0200106 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202b6c:	00003697          	auipc	a3,0x3
ffffffffc0202b70:	fb468693          	addi	a3,a3,-76 # ffffffffc0205b20 <commands+0x1370>
ffffffffc0202b74:	00002617          	auipc	a2,0x2
ffffffffc0202b78:	62c60613          	addi	a2,a2,1580 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202b7c:	0e700593          	li	a1,231
ffffffffc0202b80:	00003517          	auipc	a0,0x3
ffffffffc0202b84:	e9050513          	addi	a0,a0,-368 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202b88:	d7efd0ef          	jal	ra,ffffffffc0200106 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202b8c:	00003617          	auipc	a2,0x3
ffffffffc0202b90:	e6460613          	addi	a2,a2,-412 # ffffffffc02059f0 <commands+0x1240>
ffffffffc0202b94:	02800593          	li	a1,40
ffffffffc0202b98:	00003517          	auipc	a0,0x3
ffffffffc0202b9c:	e7850513          	addi	a0,a0,-392 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202ba0:	d66fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0202ba4:	00003697          	auipc	a3,0x3
ffffffffc0202ba8:	02468693          	addi	a3,a3,36 # ffffffffc0205bc8 <commands+0x1418>
ffffffffc0202bac:	00002617          	auipc	a2,0x2
ffffffffc0202bb0:	5f460613          	addi	a2,a2,1524 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202bb4:	13300593          	li	a1,307
ffffffffc0202bb8:	00003517          	auipc	a0,0x3
ffffffffc0202bbc:	e5850513          	addi	a0,a0,-424 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202bc0:	d46fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202bc4:	00003697          	auipc	a3,0x3
ffffffffc0202bc8:	ecc68693          	addi	a3,a3,-308 # ffffffffc0205a90 <commands+0x12e0>
ffffffffc0202bcc:	00002617          	auipc	a2,0x2
ffffffffc0202bd0:	5d460613          	addi	a2,a2,1492 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202bd4:	0d200593          	li	a1,210
ffffffffc0202bd8:	00003517          	auipc	a0,0x3
ffffffffc0202bdc:	e3850513          	addi	a0,a0,-456 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202be0:	d26fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202be4:	00003697          	auipc	a3,0x3
ffffffffc0202be8:	e6468693          	addi	a3,a3,-412 # ffffffffc0205a48 <commands+0x1298>
ffffffffc0202bec:	00002617          	auipc	a2,0x2
ffffffffc0202bf0:	5b460613          	addi	a2,a2,1460 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202bf4:	0ca00593          	li	a1,202
ffffffffc0202bf8:	00003517          	auipc	a0,0x3
ffffffffc0202bfc:	e1850513          	addi	a0,a0,-488 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202c00:	d06fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c04:	00003697          	auipc	a3,0x3
ffffffffc0202c08:	fc468693          	addi	a3,a3,-60 # ffffffffc0205bc8 <commands+0x1418>
ffffffffc0202c0c:	00002617          	auipc	a2,0x2
ffffffffc0202c10:	59460613          	addi	a2,a2,1428 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202c14:	13500593          	li	a1,309
ffffffffc0202c18:	00003517          	auipc	a0,0x3
ffffffffc0202c1c:	df850513          	addi	a0,a0,-520 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202c20:	ce6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202c24:	00003697          	auipc	a3,0x3
ffffffffc0202c28:	fb468693          	addi	a3,a3,-76 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0202c2c:	00002617          	auipc	a2,0x2
ffffffffc0202c30:	57460613          	addi	a2,a2,1396 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202c34:	13700593          	li	a1,311
ffffffffc0202c38:	00003517          	auipc	a0,0x3
ffffffffc0202c3c:	dd850513          	addi	a0,a0,-552 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202c40:	cc6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202c44:	00003697          	auipc	a3,0x3
ffffffffc0202c48:	f9468693          	addi	a3,a3,-108 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0202c4c:	00002617          	auipc	a2,0x2
ffffffffc0202c50:	55460613          	addi	a2,a2,1364 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202c54:	13a00593          	li	a1,314
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	db850513          	addi	a0,a0,-584 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202c60:	ca6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==4);
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	f7468693          	addi	a3,a3,-140 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	53460613          	addi	a2,a2,1332 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202c74:	13d00593          	li	a1,317
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	d9850513          	addi	a0,a0,-616 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202c80:	c86fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==5);
ffffffffc0202c84:	00003697          	auipc	a3,0x3
ffffffffc0202c88:	f6468693          	addi	a3,a3,-156 # ffffffffc0205be8 <commands+0x1438>
ffffffffc0202c8c:	00002617          	auipc	a2,0x2
ffffffffc0202c90:	51460613          	addi	a2,a2,1300 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202c94:	14000593          	li	a1,320
ffffffffc0202c98:	00003517          	auipc	a0,0x3
ffffffffc0202c9c:	d7850513          	addi	a0,a0,-648 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202ca0:	c66fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==6);
ffffffffc0202ca4:	00003697          	auipc	a3,0x3
ffffffffc0202ca8:	f5468693          	addi	a3,a3,-172 # ffffffffc0205bf8 <commands+0x1448>
ffffffffc0202cac:	00002617          	auipc	a2,0x2
ffffffffc0202cb0:	4f460613          	addi	a2,a2,1268 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202cb4:	14300593          	li	a1,323
ffffffffc0202cb8:	00003517          	auipc	a0,0x3
ffffffffc0202cbc:	d5850513          	addi	a0,a0,-680 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202cc0:	c46fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==7);
ffffffffc0202cc4:	00003697          	auipc	a3,0x3
ffffffffc0202cc8:	f4468693          	addi	a3,a3,-188 # ffffffffc0205c08 <commands+0x1458>
ffffffffc0202ccc:	00002617          	auipc	a2,0x2
ffffffffc0202cd0:	4d460613          	addi	a2,a2,1236 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202cd4:	14600593          	li	a1,326
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	d3850513          	addi	a0,a0,-712 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202ce0:	c26fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202ce4:	00003697          	auipc	a3,0x3
ffffffffc0202ce8:	c3468693          	addi	a3,a3,-972 # ffffffffc0205918 <commands+0x1168>
ffffffffc0202cec:	00002617          	auipc	a2,0x2
ffffffffc0202cf0:	4b460613          	addi	a2,a2,1204 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202cf4:	0d700593          	li	a1,215
ffffffffc0202cf8:	00003517          	auipc	a0,0x3
ffffffffc0202cfc:	d1850513          	addi	a0,a0,-744 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202d00:	c06fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(vma != NULL);
ffffffffc0202d04:	00003697          	auipc	a3,0x3
ffffffffc0202d08:	c8c68693          	addi	a3,a3,-884 # ffffffffc0205990 <commands+0x11e0>
ffffffffc0202d0c:	00002617          	auipc	a2,0x2
ffffffffc0202d10:	49460613          	addi	a2,a2,1172 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202d14:	0da00593          	li	a1,218
ffffffffc0202d18:	00003517          	auipc	a0,0x3
ffffffffc0202d1c:	cf850513          	addi	a0,a0,-776 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202d20:	be6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d24:	00003697          	auipc	a3,0x3
ffffffffc0202d28:	dbc68693          	addi	a3,a3,-580 # ffffffffc0205ae0 <commands+0x1330>
ffffffffc0202d2c:	00002617          	auipc	a2,0x2
ffffffffc0202d30:	47460613          	addi	a2,a2,1140 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202d34:	0e200593          	li	a1,226
ffffffffc0202d38:	00003517          	auipc	a0,0x3
ffffffffc0202d3c:	cd850513          	addi	a0,a0,-808 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202d40:	bc6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d44:	00003697          	auipc	a3,0x3
ffffffffc0202d48:	e1468693          	addi	a3,a3,-492 # ffffffffc0205b58 <commands+0x13a8>
ffffffffc0202d4c:	00002617          	auipc	a2,0x2
ffffffffc0202d50:	45460613          	addi	a2,a2,1108 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202d54:	0f500593          	li	a1,245
ffffffffc0202d58:	00003517          	auipc	a0,0x3
ffffffffc0202d5c:	cb850513          	addi	a0,a0,-840 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202d60:	ba6fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d64:	00003697          	auipc	a3,0x3
ffffffffc0202d68:	e4468693          	addi	a3,a3,-444 # ffffffffc0205ba8 <commands+0x13f8>
ffffffffc0202d6c:	00002617          	auipc	a2,0x2
ffffffffc0202d70:	43460613          	addi	a2,a2,1076 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202d74:	12b00593          	li	a1,299
ffffffffc0202d78:	00003517          	auipc	a0,0x3
ffffffffc0202d7c:	c9850513          	addi	a0,a0,-872 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202d80:	b86fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	e2468693          	addi	a3,a3,-476 # ffffffffc0205ba8 <commands+0x13f8>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	41460613          	addi	a2,a2,1044 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202d94:	12d00593          	li	a1,301
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	c7850513          	addi	a0,a0,-904 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202da0:	b66fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	e1468693          	addi	a3,a3,-492 # ffffffffc0205bb8 <commands+0x1408>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	3f460613          	addi	a2,a2,1012 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202db4:	12f00593          	li	a1,303
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	c5850513          	addi	a0,a0,-936 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202dc0:	b46fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(pgfault_num==2);
ffffffffc0202dc4:	00003697          	auipc	a3,0x3
ffffffffc0202dc8:	df468693          	addi	a3,a3,-524 # ffffffffc0205bb8 <commands+0x1408>
ffffffffc0202dcc:	00002617          	auipc	a2,0x2
ffffffffc0202dd0:	3d460613          	addi	a2,a2,980 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202dd4:	13100593          	li	a1,305
ffffffffc0202dd8:	00003517          	auipc	a0,0x3
ffffffffc0202ddc:	c3850513          	addi	a0,a0,-968 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202de0:	b26fd0ef          	jal	ra,ffffffffc0200106 <__panic>
     assert(mm != NULL);
ffffffffc0202de4:	00003697          	auipc	a3,0x3
ffffffffc0202de8:	98468693          	addi	a3,a3,-1660 # ffffffffc0205768 <commands+0xfb8>
ffffffffc0202dec:	00002617          	auipc	a2,0x2
ffffffffc0202df0:	3b460613          	addi	a2,a2,948 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202df4:	0cf00593          	li	a1,207
ffffffffc0202df8:	00003517          	auipc	a0,0x3
ffffffffc0202dfc:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202e00:	b06fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202e04 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202e04:	0000e797          	auipc	a5,0xe
ffffffffc0202e08:	66c78793          	addi	a5,a5,1644 # ffffffffc0211470 <sm>
ffffffffc0202e0c:	639c                	ld	a5,0(a5)
ffffffffc0202e0e:	0107b303          	ld	t1,16(a5)
ffffffffc0202e12:	8302                	jr	t1

ffffffffc0202e14 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202e14:	0000e797          	auipc	a5,0xe
ffffffffc0202e18:	65c78793          	addi	a5,a5,1628 # ffffffffc0211470 <sm>
ffffffffc0202e1c:	639c                	ld	a5,0(a5)
ffffffffc0202e1e:	0207b303          	ld	t1,32(a5)
ffffffffc0202e22:	8302                	jr	t1

ffffffffc0202e24 <swap_out>:
{
ffffffffc0202e24:	711d                	addi	sp,sp,-96
ffffffffc0202e26:	ec86                	sd	ra,88(sp)
ffffffffc0202e28:	e8a2                	sd	s0,80(sp)
ffffffffc0202e2a:	e4a6                	sd	s1,72(sp)
ffffffffc0202e2c:	e0ca                	sd	s2,64(sp)
ffffffffc0202e2e:	fc4e                	sd	s3,56(sp)
ffffffffc0202e30:	f852                	sd	s4,48(sp)
ffffffffc0202e32:	f456                	sd	s5,40(sp)
ffffffffc0202e34:	f05a                	sd	s6,32(sp)
ffffffffc0202e36:	ec5e                	sd	s7,24(sp)
ffffffffc0202e38:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202e3a:	cde9                	beqz	a1,ffffffffc0202f14 <swap_out+0xf0>
ffffffffc0202e3c:	8ab2                	mv	s5,a2
ffffffffc0202e3e:	892a                	mv	s2,a0
ffffffffc0202e40:	8a2e                	mv	s4,a1
ffffffffc0202e42:	4401                	li	s0,0
ffffffffc0202e44:	0000e997          	auipc	s3,0xe
ffffffffc0202e48:	62c98993          	addi	s3,s3,1580 # ffffffffc0211470 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202e4c:	00003b17          	auipc	s6,0x3
ffffffffc0202e50:	e94b0b13          	addi	s6,s6,-364 # ffffffffc0205ce0 <commands+0x1530>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202e54:	00003b97          	auipc	s7,0x3
ffffffffc0202e58:	e74b8b93          	addi	s7,s7,-396 # ffffffffc0205cc8 <commands+0x1518>
ffffffffc0202e5c:	a825                	j	ffffffffc0202e94 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202e5e:	67a2                	ld	a5,8(sp)
ffffffffc0202e60:	8626                	mv	a2,s1
ffffffffc0202e62:	85a2                	mv	a1,s0
ffffffffc0202e64:	63b4                	ld	a3,64(a5)
ffffffffc0202e66:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202e68:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202e6a:	82b1                	srli	a3,a3,0xc
ffffffffc0202e6c:	0685                	addi	a3,a3,1
ffffffffc0202e6e:	a50fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202e72:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202e74:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202e76:	613c                	ld	a5,64(a0)
ffffffffc0202e78:	83b1                	srli	a5,a5,0xc
ffffffffc0202e7a:	0785                	addi	a5,a5,1
ffffffffc0202e7c:	07a2                	slli	a5,a5,0x8
ffffffffc0202e7e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202e82:	cf3fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202e86:	01893503          	ld	a0,24(s2)
ffffffffc0202e8a:	85a6                	mv	a1,s1
ffffffffc0202e8c:	bf5fe0ef          	jal	ra,ffffffffc0201a80 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202e90:	048a0d63          	beq	s4,s0,ffffffffc0202eea <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202e94:	0009b783          	ld	a5,0(s3)
ffffffffc0202e98:	8656                	mv	a2,s5
ffffffffc0202e9a:	002c                	addi	a1,sp,8
ffffffffc0202e9c:	7b9c                	ld	a5,48(a5)
ffffffffc0202e9e:	854a                	mv	a0,s2
ffffffffc0202ea0:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202ea2:	e12d                	bnez	a0,ffffffffc0202f04 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202ea4:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202ea6:	01893503          	ld	a0,24(s2)
ffffffffc0202eaa:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202eac:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202eae:	85a6                	mv	a1,s1
ffffffffc0202eb0:	d4bfd0ef          	jal	ra,ffffffffc0200bfa <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202eb4:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202eb6:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202eb8:	8b85                	andi	a5,a5,1
ffffffffc0202eba:	cfb9                	beqz	a5,ffffffffc0202f18 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202ebc:	65a2                	ld	a1,8(sp)
ffffffffc0202ebe:	61bc                	ld	a5,64(a1)
ffffffffc0202ec0:	83b1                	srli	a5,a5,0xc
ffffffffc0202ec2:	00178513          	addi	a0,a5,1
ffffffffc0202ec6:	0522                	slli	a0,a0,0x8
ffffffffc0202ec8:	17a010ef          	jal	ra,ffffffffc0204042 <swapfs_write>
ffffffffc0202ecc:	d949                	beqz	a0,ffffffffc0202e5e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202ece:	855e                	mv	a0,s7
ffffffffc0202ed0:	9eefd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ed4:	0009b783          	ld	a5,0(s3)
ffffffffc0202ed8:	6622                	ld	a2,8(sp)
ffffffffc0202eda:	4681                	li	a3,0
ffffffffc0202edc:	739c                	ld	a5,32(a5)
ffffffffc0202ede:	85a6                	mv	a1,s1
ffffffffc0202ee0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ee2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ee4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202ee6:	fa8a17e3          	bne	s4,s0,ffffffffc0202e94 <swap_out+0x70>
}
ffffffffc0202eea:	8522                	mv	a0,s0
ffffffffc0202eec:	60e6                	ld	ra,88(sp)
ffffffffc0202eee:	6446                	ld	s0,80(sp)
ffffffffc0202ef0:	64a6                	ld	s1,72(sp)
ffffffffc0202ef2:	6906                	ld	s2,64(sp)
ffffffffc0202ef4:	79e2                	ld	s3,56(sp)
ffffffffc0202ef6:	7a42                	ld	s4,48(sp)
ffffffffc0202ef8:	7aa2                	ld	s5,40(sp)
ffffffffc0202efa:	7b02                	ld	s6,32(sp)
ffffffffc0202efc:	6be2                	ld	s7,24(sp)
ffffffffc0202efe:	6c42                	ld	s8,16(sp)
ffffffffc0202f00:	6125                	addi	sp,sp,96
ffffffffc0202f02:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202f04:	85a2                	mv	a1,s0
ffffffffc0202f06:	00003517          	auipc	a0,0x3
ffffffffc0202f0a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205c80 <commands+0x14d0>
ffffffffc0202f0e:	9b0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202f12:	bfe1                	j	ffffffffc0202eea <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202f14:	4401                	li	s0,0
ffffffffc0202f16:	bfd1                	j	ffffffffc0202eea <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f18:	00003697          	auipc	a3,0x3
ffffffffc0202f1c:	d9868693          	addi	a3,a3,-616 # ffffffffc0205cb0 <commands+0x1500>
ffffffffc0202f20:	00002617          	auipc	a2,0x2
ffffffffc0202f24:	28060613          	addi	a2,a2,640 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202f28:	06700593          	li	a1,103
ffffffffc0202f2c:	00003517          	auipc	a0,0x3
ffffffffc0202f30:	ae450513          	addi	a0,a0,-1308 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202f34:	9d2fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202f38 <swap_in>:
{
ffffffffc0202f38:	7179                	addi	sp,sp,-48
ffffffffc0202f3a:	e84a                	sd	s2,16(sp)
ffffffffc0202f3c:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202f3e:	4505                	li	a0,1
{
ffffffffc0202f40:	ec26                	sd	s1,24(sp)
ffffffffc0202f42:	e44e                	sd	s3,8(sp)
ffffffffc0202f44:	f406                	sd	ra,40(sp)
ffffffffc0202f46:	f022                	sd	s0,32(sp)
ffffffffc0202f48:	84ae                	mv	s1,a1
ffffffffc0202f4a:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202f4c:	ba1fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
     assert(result!=NULL);
ffffffffc0202f50:	c129                	beqz	a0,ffffffffc0202f92 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202f52:	842a                	mv	s0,a0
ffffffffc0202f54:	01893503          	ld	a0,24(s2)
ffffffffc0202f58:	4601                	li	a2,0
ffffffffc0202f5a:	85a6                	mv	a1,s1
ffffffffc0202f5c:	c9ffd0ef          	jal	ra,ffffffffc0200bfa <get_pte>
ffffffffc0202f60:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202f62:	6108                	ld	a0,0(a0)
ffffffffc0202f64:	85a2                	mv	a1,s0
ffffffffc0202f66:	036010ef          	jal	ra,ffffffffc0203f9c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202f6a:	00093583          	ld	a1,0(s2)
ffffffffc0202f6e:	8626                	mv	a2,s1
ffffffffc0202f70:	00003517          	auipc	a0,0x3
ffffffffc0202f74:	a4050513          	addi	a0,a0,-1472 # ffffffffc02059b0 <commands+0x1200>
ffffffffc0202f78:	81a1                	srli	a1,a1,0x8
ffffffffc0202f7a:	944fd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202f7e:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202f80:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202f84:	7402                	ld	s0,32(sp)
ffffffffc0202f86:	64e2                	ld	s1,24(sp)
ffffffffc0202f88:	6942                	ld	s2,16(sp)
ffffffffc0202f8a:	69a2                	ld	s3,8(sp)
ffffffffc0202f8c:	4501                	li	a0,0
ffffffffc0202f8e:	6145                	addi	sp,sp,48
ffffffffc0202f90:	8082                	ret
     assert(result!=NULL);
ffffffffc0202f92:	00003697          	auipc	a3,0x3
ffffffffc0202f96:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02059a0 <commands+0x11f0>
ffffffffc0202f9a:	00002617          	auipc	a2,0x2
ffffffffc0202f9e:	20660613          	addi	a2,a2,518 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0202fa2:	07d00593          	li	a1,125
ffffffffc0202fa6:	00003517          	auipc	a0,0x3
ffffffffc0202faa:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0205a10 <commands+0x1260>
ffffffffc0202fae:	958fd0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0202fb2 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0202fb2:	0000e797          	auipc	a5,0xe
ffffffffc0202fb6:	5d678793          	addi	a5,a5,1494 # ffffffffc0211588 <free_area>
ffffffffc0202fba:	e79c                	sd	a5,8(a5)
ffffffffc0202fbc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202fbe:	0007a823          	sw	zero,16(a5)
}
ffffffffc0202fc2:	8082                	ret

ffffffffc0202fc4 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0202fc4:	0000e517          	auipc	a0,0xe
ffffffffc0202fc8:	5d456503          	lwu	a0,1492(a0) # ffffffffc0211598 <free_area+0x10>
ffffffffc0202fcc:	8082                	ret

ffffffffc0202fce <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202fce:	715d                	addi	sp,sp,-80
ffffffffc0202fd0:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0202fd2:	0000e917          	auipc	s2,0xe
ffffffffc0202fd6:	5b690913          	addi	s2,s2,1462 # ffffffffc0211588 <free_area>
ffffffffc0202fda:	00893783          	ld	a5,8(s2)
ffffffffc0202fde:	e486                	sd	ra,72(sp)
ffffffffc0202fe0:	e0a2                	sd	s0,64(sp)
ffffffffc0202fe2:	fc26                	sd	s1,56(sp)
ffffffffc0202fe4:	f44e                	sd	s3,40(sp)
ffffffffc0202fe6:	f052                	sd	s4,32(sp)
ffffffffc0202fe8:	ec56                	sd	s5,24(sp)
ffffffffc0202fea:	e85a                	sd	s6,16(sp)
ffffffffc0202fec:	e45e                	sd	s7,8(sp)
ffffffffc0202fee:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202ff0:	31278f63          	beq	a5,s2,ffffffffc020330e <default_check+0x340>
ffffffffc0202ff4:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202ff8:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202ffa:	8b05                	andi	a4,a4,1
ffffffffc0202ffc:	30070d63          	beqz	a4,ffffffffc0203316 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0203000:	4401                	li	s0,0
ffffffffc0203002:	4481                	li	s1,0
ffffffffc0203004:	a031                	j	ffffffffc0203010 <default_check+0x42>
ffffffffc0203006:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc020300a:	8b09                	andi	a4,a4,2
ffffffffc020300c:	30070563          	beqz	a4,ffffffffc0203316 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0203010:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203014:	679c                	ld	a5,8(a5)
ffffffffc0203016:	2485                	addiw	s1,s1,1
ffffffffc0203018:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020301a:	ff2796e3          	bne	a5,s2,ffffffffc0203006 <default_check+0x38>
ffffffffc020301e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0203020:	b9bfd0ef          	jal	ra,ffffffffc0200bba <nr_free_pages>
ffffffffc0203024:	75351963          	bne	a0,s3,ffffffffc0203776 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0203028:	4505                	li	a0,1
ffffffffc020302a:	ac3fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020302e:	8a2a                	mv	s4,a0
ffffffffc0203030:	48050363          	beqz	a0,ffffffffc02034b6 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203034:	4505                	li	a0,1
ffffffffc0203036:	ab7fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020303a:	89aa                	mv	s3,a0
ffffffffc020303c:	74050d63          	beqz	a0,ffffffffc0203796 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203040:	4505                	li	a0,1
ffffffffc0203042:	aabfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203046:	8aaa                	mv	s5,a0
ffffffffc0203048:	4e050763          	beqz	a0,ffffffffc0203536 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020304c:	2f3a0563          	beq	s4,s3,ffffffffc0203336 <default_check+0x368>
ffffffffc0203050:	2eaa0363          	beq	s4,a0,ffffffffc0203336 <default_check+0x368>
ffffffffc0203054:	2ea98163          	beq	s3,a0,ffffffffc0203336 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203058:	000a2783          	lw	a5,0(s4)
ffffffffc020305c:	2e079d63          	bnez	a5,ffffffffc0203356 <default_check+0x388>
ffffffffc0203060:	0009a783          	lw	a5,0(s3)
ffffffffc0203064:	2e079963          	bnez	a5,ffffffffc0203356 <default_check+0x388>
ffffffffc0203068:	411c                	lw	a5,0(a0)
ffffffffc020306a:	2e079663          	bnez	a5,ffffffffc0203356 <default_check+0x388>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020306e:	0000e797          	auipc	a5,0xe
ffffffffc0203072:	43278793          	addi	a5,a5,1074 # ffffffffc02114a0 <pages>
ffffffffc0203076:	639c                	ld	a5,0(a5)
ffffffffc0203078:	00002717          	auipc	a4,0x2
ffffffffc020307c:	f7070713          	addi	a4,a4,-144 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0203080:	630c                	ld	a1,0(a4)
ffffffffc0203082:	40fa0733          	sub	a4,s4,a5
ffffffffc0203086:	870d                	srai	a4,a4,0x3
ffffffffc0203088:	02b70733          	mul	a4,a4,a1
ffffffffc020308c:	00003697          	auipc	a3,0x3
ffffffffc0203090:	48468693          	addi	a3,a3,1156 # ffffffffc0206510 <nbase>
ffffffffc0203094:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203096:	0000e697          	auipc	a3,0xe
ffffffffc020309a:	3ca68693          	addi	a3,a3,970 # ffffffffc0211460 <npage>
ffffffffc020309e:	6294                	ld	a3,0(a3)
ffffffffc02030a0:	06b2                	slli	a3,a3,0xc
ffffffffc02030a2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02030a4:	0732                	slli	a4,a4,0xc
ffffffffc02030a6:	2cd77863          	bleu	a3,a4,ffffffffc0203376 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02030aa:	40f98733          	sub	a4,s3,a5
ffffffffc02030ae:	870d                	srai	a4,a4,0x3
ffffffffc02030b0:	02b70733          	mul	a4,a4,a1
ffffffffc02030b4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02030b6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02030b8:	4ed77f63          	bleu	a3,a4,ffffffffc02035b6 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02030bc:	40f507b3          	sub	a5,a0,a5
ffffffffc02030c0:	878d                	srai	a5,a5,0x3
ffffffffc02030c2:	02b787b3          	mul	a5,a5,a1
ffffffffc02030c6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02030c8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02030ca:	34d7f663          	bleu	a3,a5,ffffffffc0203416 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc02030ce:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02030d0:	00093c03          	ld	s8,0(s2)
ffffffffc02030d4:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02030d8:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02030dc:	0000e797          	auipc	a5,0xe
ffffffffc02030e0:	4b27ba23          	sd	s2,1204(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc02030e4:	0000e797          	auipc	a5,0xe
ffffffffc02030e8:	4b27b223          	sd	s2,1188(a5) # ffffffffc0211588 <free_area>
    nr_free = 0;
ffffffffc02030ec:	0000e797          	auipc	a5,0xe
ffffffffc02030f0:	4a07a623          	sw	zero,1196(a5) # ffffffffc0211598 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02030f4:	9f9fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02030f8:	2e051f63          	bnez	a0,ffffffffc02033f6 <default_check+0x428>
    free_page(p0);
ffffffffc02030fc:	4585                	li	a1,1
ffffffffc02030fe:	8552                	mv	a0,s4
ffffffffc0203100:	a75fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0203104:	4585                	li	a1,1
ffffffffc0203106:	854e                	mv	a0,s3
ffffffffc0203108:	a6dfd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc020310c:	4585                	li	a1,1
ffffffffc020310e:	8556                	mv	a0,s5
ffffffffc0203110:	a65fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(nr_free == 3);
ffffffffc0203114:	01092703          	lw	a4,16(s2)
ffffffffc0203118:	478d                	li	a5,3
ffffffffc020311a:	2af71e63          	bne	a4,a5,ffffffffc02033d6 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020311e:	4505                	li	a0,1
ffffffffc0203120:	9cdfd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203124:	89aa                	mv	s3,a0
ffffffffc0203126:	28050863          	beqz	a0,ffffffffc02033b6 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020312a:	4505                	li	a0,1
ffffffffc020312c:	9c1fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203130:	8aaa                	mv	s5,a0
ffffffffc0203132:	3e050263          	beqz	a0,ffffffffc0203516 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203136:	4505                	li	a0,1
ffffffffc0203138:	9b5fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020313c:	8a2a                	mv	s4,a0
ffffffffc020313e:	3a050c63          	beqz	a0,ffffffffc02034f6 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0203142:	4505                	li	a0,1
ffffffffc0203144:	9a9fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203148:	38051763          	bnez	a0,ffffffffc02034d6 <default_check+0x508>
    free_page(p0);
ffffffffc020314c:	4585                	li	a1,1
ffffffffc020314e:	854e                	mv	a0,s3
ffffffffc0203150:	a25fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0203154:	00893783          	ld	a5,8(s2)
ffffffffc0203158:	23278f63          	beq	a5,s2,ffffffffc0203396 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc020315c:	4505                	li	a0,1
ffffffffc020315e:	98ffd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203162:	32a99a63          	bne	s3,a0,ffffffffc0203496 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0203166:	4505                	li	a0,1
ffffffffc0203168:	985fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020316c:	30051563          	bnez	a0,ffffffffc0203476 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0203170:	01092783          	lw	a5,16(s2)
ffffffffc0203174:	2e079163          	bnez	a5,ffffffffc0203456 <default_check+0x488>
    free_page(p);
ffffffffc0203178:	854e                	mv	a0,s3
ffffffffc020317a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020317c:	0000e797          	auipc	a5,0xe
ffffffffc0203180:	4187b623          	sd	s8,1036(a5) # ffffffffc0211588 <free_area>
ffffffffc0203184:	0000e797          	auipc	a5,0xe
ffffffffc0203188:	4177b623          	sd	s7,1036(a5) # ffffffffc0211590 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020318c:	0000e797          	auipc	a5,0xe
ffffffffc0203190:	4167a623          	sw	s6,1036(a5) # ffffffffc0211598 <free_area+0x10>
    free_page(p);
ffffffffc0203194:	9e1fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p1);
ffffffffc0203198:	4585                	li	a1,1
ffffffffc020319a:	8556                	mv	a0,s5
ffffffffc020319c:	9d9fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc02031a0:	4585                	li	a1,1
ffffffffc02031a2:	8552                	mv	a0,s4
ffffffffc02031a4:	9d1fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02031a8:	4515                	li	a0,5
ffffffffc02031aa:	943fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02031ae:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02031b0:	28050363          	beqz	a0,ffffffffc0203436 <default_check+0x468>
ffffffffc02031b4:	651c                	ld	a5,8(a0)
ffffffffc02031b6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02031b8:	8b85                	andi	a5,a5,1
ffffffffc02031ba:	54079e63          	bnez	a5,ffffffffc0203716 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02031be:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02031c0:	00093b03          	ld	s6,0(s2)
ffffffffc02031c4:	00893a83          	ld	s5,8(s2)
ffffffffc02031c8:	0000e797          	auipc	a5,0xe
ffffffffc02031cc:	3d27b023          	sd	s2,960(a5) # ffffffffc0211588 <free_area>
ffffffffc02031d0:	0000e797          	auipc	a5,0xe
ffffffffc02031d4:	3d27b023          	sd	s2,960(a5) # ffffffffc0211590 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02031d8:	915fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02031dc:	50051d63          	bnez	a0,ffffffffc02036f6 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02031e0:	09098a13          	addi	s4,s3,144
ffffffffc02031e4:	8552                	mv	a0,s4
ffffffffc02031e6:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02031e8:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02031ec:	0000e797          	auipc	a5,0xe
ffffffffc02031f0:	3a07a623          	sw	zero,940(a5) # ffffffffc0211598 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02031f4:	981fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02031f8:	4511                	li	a0,4
ffffffffc02031fa:	8f3fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02031fe:	4c051c63          	bnez	a0,ffffffffc02036d6 <default_check+0x708>
ffffffffc0203202:	0989b783          	ld	a5,152(s3)
ffffffffc0203206:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203208:	8b85                	andi	a5,a5,1
ffffffffc020320a:	4a078663          	beqz	a5,ffffffffc02036b6 <default_check+0x6e8>
ffffffffc020320e:	0a89a703          	lw	a4,168(s3)
ffffffffc0203212:	478d                	li	a5,3
ffffffffc0203214:	4af71163          	bne	a4,a5,ffffffffc02036b6 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203218:	450d                	li	a0,3
ffffffffc020321a:	8d3fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020321e:	8c2a                	mv	s8,a0
ffffffffc0203220:	46050b63          	beqz	a0,ffffffffc0203696 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0203224:	4505                	li	a0,1
ffffffffc0203226:	8c7fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc020322a:	44051663          	bnez	a0,ffffffffc0203676 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc020322e:	438a1463          	bne	s4,s8,ffffffffc0203656 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0203232:	4585                	li	a1,1
ffffffffc0203234:	854e                	mv	a0,s3
ffffffffc0203236:	93ffd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_pages(p1, 3);
ffffffffc020323a:	458d                	li	a1,3
ffffffffc020323c:	8552                	mv	a0,s4
ffffffffc020323e:	937fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
ffffffffc0203242:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0203246:	04898c13          	addi	s8,s3,72
ffffffffc020324a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020324c:	8b85                	andi	a5,a5,1
ffffffffc020324e:	3e078463          	beqz	a5,ffffffffc0203636 <default_check+0x668>
ffffffffc0203252:	0189a703          	lw	a4,24(s3)
ffffffffc0203256:	4785                	li	a5,1
ffffffffc0203258:	3cf71f63          	bne	a4,a5,ffffffffc0203636 <default_check+0x668>
ffffffffc020325c:	008a3783          	ld	a5,8(s4)
ffffffffc0203260:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203262:	8b85                	andi	a5,a5,1
ffffffffc0203264:	3a078963          	beqz	a5,ffffffffc0203616 <default_check+0x648>
ffffffffc0203268:	018a2703          	lw	a4,24(s4)
ffffffffc020326c:	478d                	li	a5,3
ffffffffc020326e:	3af71463          	bne	a4,a5,ffffffffc0203616 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0203272:	4505                	li	a0,1
ffffffffc0203274:	879fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203278:	36a99f63          	bne	s3,a0,ffffffffc02035f6 <default_check+0x628>
    free_page(p0);
ffffffffc020327c:	4585                	li	a1,1
ffffffffc020327e:	8f7fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0203282:	4509                	li	a0,2
ffffffffc0203284:	869fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc0203288:	34aa1763          	bne	s4,a0,ffffffffc02035d6 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc020328c:	4589                	li	a1,2
ffffffffc020328e:	8e7fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    free_page(p2);
ffffffffc0203292:	4585                	li	a1,1
ffffffffc0203294:	8562                	mv	a0,s8
ffffffffc0203296:	8dffd0ef          	jal	ra,ffffffffc0200b74 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020329a:	4515                	li	a0,5
ffffffffc020329c:	851fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02032a0:	89aa                	mv	s3,a0
ffffffffc02032a2:	48050a63          	beqz	a0,ffffffffc0203736 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc02032a6:	4505                	li	a0,1
ffffffffc02032a8:	845fd0ef          	jal	ra,ffffffffc0200aec <alloc_pages>
ffffffffc02032ac:	2e051563          	bnez	a0,ffffffffc0203596 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc02032b0:	01092783          	lw	a5,16(s2)
ffffffffc02032b4:	2c079163          	bnez	a5,ffffffffc0203576 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02032b8:	4595                	li	a1,5
ffffffffc02032ba:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02032bc:	0000e797          	auipc	a5,0xe
ffffffffc02032c0:	2d77ae23          	sw	s7,732(a5) # ffffffffc0211598 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02032c4:	0000e797          	auipc	a5,0xe
ffffffffc02032c8:	2d67b223          	sd	s6,708(a5) # ffffffffc0211588 <free_area>
ffffffffc02032cc:	0000e797          	auipc	a5,0xe
ffffffffc02032d0:	2d57b223          	sd	s5,708(a5) # ffffffffc0211590 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02032d4:	8a1fd0ef          	jal	ra,ffffffffc0200b74 <free_pages>
    return listelm->next;
ffffffffc02032d8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02032dc:	01278963          	beq	a5,s2,ffffffffc02032ee <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02032e0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02032e4:	679c                	ld	a5,8(a5)
ffffffffc02032e6:	34fd                	addiw	s1,s1,-1
ffffffffc02032e8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02032ea:	ff279be3          	bne	a5,s2,ffffffffc02032e0 <default_check+0x312>
    }
    assert(count == 0);
ffffffffc02032ee:	26049463          	bnez	s1,ffffffffc0203556 <default_check+0x588>
    assert(total == 0);
ffffffffc02032f2:	46041263          	bnez	s0,ffffffffc0203756 <default_check+0x788>
}
ffffffffc02032f6:	60a6                	ld	ra,72(sp)
ffffffffc02032f8:	6406                	ld	s0,64(sp)
ffffffffc02032fa:	74e2                	ld	s1,56(sp)
ffffffffc02032fc:	7942                	ld	s2,48(sp)
ffffffffc02032fe:	79a2                	ld	s3,40(sp)
ffffffffc0203300:	7a02                	ld	s4,32(sp)
ffffffffc0203302:	6ae2                	ld	s5,24(sp)
ffffffffc0203304:	6b42                	ld	s6,16(sp)
ffffffffc0203306:	6ba2                	ld	s7,8(sp)
ffffffffc0203308:	6c02                	ld	s8,0(sp)
ffffffffc020330a:	6161                	addi	sp,sp,80
ffffffffc020330c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020330e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203310:	4401                	li	s0,0
ffffffffc0203312:	4481                	li	s1,0
ffffffffc0203314:	b331                	j	ffffffffc0203020 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0203316:	00002697          	auipc	a3,0x2
ffffffffc020331a:	72268693          	addi	a3,a3,1826 # ffffffffc0205a38 <commands+0x1288>
ffffffffc020331e:	00002617          	auipc	a2,0x2
ffffffffc0203322:	e8260613          	addi	a2,a2,-382 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203326:	0f000593          	li	a1,240
ffffffffc020332a:	00003517          	auipc	a0,0x3
ffffffffc020332e:	9f650513          	addi	a0,a0,-1546 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203332:	dd5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0203336:	00003697          	auipc	a3,0x3
ffffffffc020333a:	a6268693          	addi	a3,a3,-1438 # ffffffffc0205d98 <commands+0x15e8>
ffffffffc020333e:	00002617          	auipc	a2,0x2
ffffffffc0203342:	e6260613          	addi	a2,a2,-414 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203346:	0bd00593          	li	a1,189
ffffffffc020334a:	00003517          	auipc	a0,0x3
ffffffffc020334e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203352:	db5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203356:	00003697          	auipc	a3,0x3
ffffffffc020335a:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0205dc0 <commands+0x1610>
ffffffffc020335e:	00002617          	auipc	a2,0x2
ffffffffc0203362:	e4260613          	addi	a2,a2,-446 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203366:	0be00593          	li	a1,190
ffffffffc020336a:	00003517          	auipc	a0,0x3
ffffffffc020336e:	9b650513          	addi	a0,a0,-1610 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203372:	d95fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203376:	00003697          	auipc	a3,0x3
ffffffffc020337a:	a8a68693          	addi	a3,a3,-1398 # ffffffffc0205e00 <commands+0x1650>
ffffffffc020337e:	00002617          	auipc	a2,0x2
ffffffffc0203382:	e2260613          	addi	a2,a2,-478 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203386:	0c000593          	li	a1,192
ffffffffc020338a:	00003517          	auipc	a0,0x3
ffffffffc020338e:	99650513          	addi	a0,a0,-1642 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203392:	d75fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0203396:	00003697          	auipc	a3,0x3
ffffffffc020339a:	af268693          	addi	a3,a3,-1294 # ffffffffc0205e88 <commands+0x16d8>
ffffffffc020339e:	00002617          	auipc	a2,0x2
ffffffffc02033a2:	e0260613          	addi	a2,a2,-510 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02033a6:	0d900593          	li	a1,217
ffffffffc02033aa:	00003517          	auipc	a0,0x3
ffffffffc02033ae:	97650513          	addi	a0,a0,-1674 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02033b2:	d55fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02033b6:	00003697          	auipc	a3,0x3
ffffffffc02033ba:	98268693          	addi	a3,a3,-1662 # ffffffffc0205d38 <commands+0x1588>
ffffffffc02033be:	00002617          	auipc	a2,0x2
ffffffffc02033c2:	de260613          	addi	a2,a2,-542 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02033c6:	0d200593          	li	a1,210
ffffffffc02033ca:	00003517          	auipc	a0,0x3
ffffffffc02033ce:	95650513          	addi	a0,a0,-1706 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02033d2:	d35fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 3);
ffffffffc02033d6:	00003697          	auipc	a3,0x3
ffffffffc02033da:	aa268693          	addi	a3,a3,-1374 # ffffffffc0205e78 <commands+0x16c8>
ffffffffc02033de:	00002617          	auipc	a2,0x2
ffffffffc02033e2:	dc260613          	addi	a2,a2,-574 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02033e6:	0d000593          	li	a1,208
ffffffffc02033ea:	00003517          	auipc	a0,0x3
ffffffffc02033ee:	93650513          	addi	a0,a0,-1738 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02033f2:	d15fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02033f6:	00003697          	auipc	a3,0x3
ffffffffc02033fa:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc02033fe:	00002617          	auipc	a2,0x2
ffffffffc0203402:	da260613          	addi	a2,a2,-606 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203406:	0cb00593          	li	a1,203
ffffffffc020340a:	00003517          	auipc	a0,0x3
ffffffffc020340e:	91650513          	addi	a0,a0,-1770 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203412:	cf5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0203416:	00003697          	auipc	a3,0x3
ffffffffc020341a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0205e40 <commands+0x1690>
ffffffffc020341e:	00002617          	auipc	a2,0x2
ffffffffc0203422:	d8260613          	addi	a2,a2,-638 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203426:	0c200593          	li	a1,194
ffffffffc020342a:	00003517          	auipc	a0,0x3
ffffffffc020342e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203432:	cd5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 != NULL);
ffffffffc0203436:	00003697          	auipc	a3,0x3
ffffffffc020343a:	a9a68693          	addi	a3,a3,-1382 # ffffffffc0205ed0 <commands+0x1720>
ffffffffc020343e:	00002617          	auipc	a2,0x2
ffffffffc0203442:	d6260613          	addi	a2,a2,-670 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203446:	0f800593          	li	a1,248
ffffffffc020344a:	00003517          	auipc	a0,0x3
ffffffffc020344e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203452:	cb5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0203456:	00003697          	auipc	a3,0x3
ffffffffc020345a:	a6a68693          	addi	a3,a3,-1430 # ffffffffc0205ec0 <commands+0x1710>
ffffffffc020345e:	00002617          	auipc	a2,0x2
ffffffffc0203462:	d4260613          	addi	a2,a2,-702 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203466:	0df00593          	li	a1,223
ffffffffc020346a:	00003517          	auipc	a0,0x3
ffffffffc020346e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203472:	c95fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203476:	00003697          	auipc	a3,0x3
ffffffffc020347a:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc020347e:	00002617          	auipc	a2,0x2
ffffffffc0203482:	d2260613          	addi	a2,a2,-734 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203486:	0dd00593          	li	a1,221
ffffffffc020348a:	00003517          	auipc	a0,0x3
ffffffffc020348e:	89650513          	addi	a0,a0,-1898 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203492:	c75fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0203496:	00003697          	auipc	a3,0x3
ffffffffc020349a:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0205ea0 <commands+0x16f0>
ffffffffc020349e:	00002617          	auipc	a2,0x2
ffffffffc02034a2:	d0260613          	addi	a2,a2,-766 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02034a6:	0dc00593          	li	a1,220
ffffffffc02034aa:	00003517          	auipc	a0,0x3
ffffffffc02034ae:	87650513          	addi	a0,a0,-1930 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02034b2:	c55fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02034b6:	00003697          	auipc	a3,0x3
ffffffffc02034ba:	88268693          	addi	a3,a3,-1918 # ffffffffc0205d38 <commands+0x1588>
ffffffffc02034be:	00002617          	auipc	a2,0x2
ffffffffc02034c2:	ce260613          	addi	a2,a2,-798 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02034c6:	0b900593          	li	a1,185
ffffffffc02034ca:	00003517          	auipc	a0,0x3
ffffffffc02034ce:	85650513          	addi	a0,a0,-1962 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02034d2:	c35fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02034d6:	00003697          	auipc	a3,0x3
ffffffffc02034da:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc02034de:	00002617          	auipc	a2,0x2
ffffffffc02034e2:	cc260613          	addi	a2,a2,-830 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02034e6:	0d600593          	li	a1,214
ffffffffc02034ea:	00003517          	auipc	a0,0x3
ffffffffc02034ee:	83650513          	addi	a0,a0,-1994 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02034f2:	c15fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02034f6:	00003697          	auipc	a3,0x3
ffffffffc02034fa:	88268693          	addi	a3,a3,-1918 # ffffffffc0205d78 <commands+0x15c8>
ffffffffc02034fe:	00002617          	auipc	a2,0x2
ffffffffc0203502:	ca260613          	addi	a2,a2,-862 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203506:	0d400593          	li	a1,212
ffffffffc020350a:	00003517          	auipc	a0,0x3
ffffffffc020350e:	81650513          	addi	a0,a0,-2026 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203512:	bf5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203516:	00003697          	auipc	a3,0x3
ffffffffc020351a:	84268693          	addi	a3,a3,-1982 # ffffffffc0205d58 <commands+0x15a8>
ffffffffc020351e:	00002617          	auipc	a2,0x2
ffffffffc0203522:	c8260613          	addi	a2,a2,-894 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203526:	0d300593          	li	a1,211
ffffffffc020352a:	00002517          	auipc	a0,0x2
ffffffffc020352e:	7f650513          	addi	a0,a0,2038 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203532:	bd5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0203536:	00003697          	auipc	a3,0x3
ffffffffc020353a:	84268693          	addi	a3,a3,-1982 # ffffffffc0205d78 <commands+0x15c8>
ffffffffc020353e:	00002617          	auipc	a2,0x2
ffffffffc0203542:	c6260613          	addi	a2,a2,-926 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203546:	0bb00593          	li	a1,187
ffffffffc020354a:	00002517          	auipc	a0,0x2
ffffffffc020354e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203552:	bb5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(count == 0);
ffffffffc0203556:	00003697          	auipc	a3,0x3
ffffffffc020355a:	aca68693          	addi	a3,a3,-1334 # ffffffffc0206020 <commands+0x1870>
ffffffffc020355e:	00002617          	auipc	a2,0x2
ffffffffc0203562:	c4260613          	addi	a2,a2,-958 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203566:	12500593          	li	a1,293
ffffffffc020356a:	00002517          	auipc	a0,0x2
ffffffffc020356e:	7b650513          	addi	a0,a0,1974 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203572:	b95fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(nr_free == 0);
ffffffffc0203576:	00003697          	auipc	a3,0x3
ffffffffc020357a:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205ec0 <commands+0x1710>
ffffffffc020357e:	00002617          	auipc	a2,0x2
ffffffffc0203582:	c2260613          	addi	a2,a2,-990 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203586:	11a00593          	li	a1,282
ffffffffc020358a:	00002517          	auipc	a0,0x2
ffffffffc020358e:	79650513          	addi	a0,a0,1942 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203592:	b75fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203596:	00003697          	auipc	a3,0x3
ffffffffc020359a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc020359e:	00002617          	auipc	a2,0x2
ffffffffc02035a2:	c0260613          	addi	a2,a2,-1022 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02035a6:	11800593          	li	a1,280
ffffffffc02035aa:	00002517          	auipc	a0,0x2
ffffffffc02035ae:	77650513          	addi	a0,a0,1910 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02035b2:	b55fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02035b6:	00003697          	auipc	a3,0x3
ffffffffc02035ba:	86a68693          	addi	a3,a3,-1942 # ffffffffc0205e20 <commands+0x1670>
ffffffffc02035be:	00002617          	auipc	a2,0x2
ffffffffc02035c2:	be260613          	addi	a2,a2,-1054 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02035c6:	0c100593          	li	a1,193
ffffffffc02035ca:	00002517          	auipc	a0,0x2
ffffffffc02035ce:	75650513          	addi	a0,a0,1878 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02035d2:	b35fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02035d6:	00003697          	auipc	a3,0x3
ffffffffc02035da:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0205fe0 <commands+0x1830>
ffffffffc02035de:	00002617          	auipc	a2,0x2
ffffffffc02035e2:	bc260613          	addi	a2,a2,-1086 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02035e6:	11200593          	li	a1,274
ffffffffc02035ea:	00002517          	auipc	a0,0x2
ffffffffc02035ee:	73650513          	addi	a0,a0,1846 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02035f2:	b15fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02035f6:	00003697          	auipc	a3,0x3
ffffffffc02035fa:	9ca68693          	addi	a3,a3,-1590 # ffffffffc0205fc0 <commands+0x1810>
ffffffffc02035fe:	00002617          	auipc	a2,0x2
ffffffffc0203602:	ba260613          	addi	a2,a2,-1118 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203606:	11000593          	li	a1,272
ffffffffc020360a:	00002517          	auipc	a0,0x2
ffffffffc020360e:	71650513          	addi	a0,a0,1814 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203612:	af5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0203616:	00003697          	auipc	a3,0x3
ffffffffc020361a:	98268693          	addi	a3,a3,-1662 # ffffffffc0205f98 <commands+0x17e8>
ffffffffc020361e:	00002617          	auipc	a2,0x2
ffffffffc0203622:	b8260613          	addi	a2,a2,-1150 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203626:	10e00593          	li	a1,270
ffffffffc020362a:	00002517          	auipc	a0,0x2
ffffffffc020362e:	6f650513          	addi	a0,a0,1782 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203632:	ad5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0203636:	00003697          	auipc	a3,0x3
ffffffffc020363a:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205f70 <commands+0x17c0>
ffffffffc020363e:	00002617          	auipc	a2,0x2
ffffffffc0203642:	b6260613          	addi	a2,a2,-1182 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203646:	10d00593          	li	a1,269
ffffffffc020364a:	00002517          	auipc	a0,0x2
ffffffffc020364e:	6d650513          	addi	a0,a0,1750 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203652:	ab5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0203656:	00003697          	auipc	a3,0x3
ffffffffc020365a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0205f60 <commands+0x17b0>
ffffffffc020365e:	00002617          	auipc	a2,0x2
ffffffffc0203662:	b4260613          	addi	a2,a2,-1214 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203666:	10800593          	li	a1,264
ffffffffc020366a:	00002517          	auipc	a0,0x2
ffffffffc020366e:	6b650513          	addi	a0,a0,1718 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203672:	a95fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203676:	00002697          	auipc	a3,0x2
ffffffffc020367a:	7ea68693          	addi	a3,a3,2026 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc020367e:	00002617          	auipc	a2,0x2
ffffffffc0203682:	b2260613          	addi	a2,a2,-1246 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203686:	10700593          	li	a1,263
ffffffffc020368a:	00002517          	auipc	a0,0x2
ffffffffc020368e:	69650513          	addi	a0,a0,1686 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203692:	a75fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203696:	00003697          	auipc	a3,0x3
ffffffffc020369a:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0205f40 <commands+0x1790>
ffffffffc020369e:	00002617          	auipc	a2,0x2
ffffffffc02036a2:	b0260613          	addi	a2,a2,-1278 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02036a6:	10600593          	li	a1,262
ffffffffc02036aa:	00002517          	auipc	a0,0x2
ffffffffc02036ae:	67650513          	addi	a0,a0,1654 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02036b2:	a55fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02036b6:	00003697          	auipc	a3,0x3
ffffffffc02036ba:	85a68693          	addi	a3,a3,-1958 # ffffffffc0205f10 <commands+0x1760>
ffffffffc02036be:	00002617          	auipc	a2,0x2
ffffffffc02036c2:	ae260613          	addi	a2,a2,-1310 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02036c6:	10500593          	li	a1,261
ffffffffc02036ca:	00002517          	auipc	a0,0x2
ffffffffc02036ce:	65650513          	addi	a0,a0,1622 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02036d2:	a35fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02036d6:	00003697          	auipc	a3,0x3
ffffffffc02036da:	82268693          	addi	a3,a3,-2014 # ffffffffc0205ef8 <commands+0x1748>
ffffffffc02036de:	00002617          	auipc	a2,0x2
ffffffffc02036e2:	ac260613          	addi	a2,a2,-1342 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02036e6:	10400593          	li	a1,260
ffffffffc02036ea:	00002517          	auipc	a0,0x2
ffffffffc02036ee:	63650513          	addi	a0,a0,1590 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02036f2:	a15fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02036f6:	00002697          	auipc	a3,0x2
ffffffffc02036fa:	76a68693          	addi	a3,a3,1898 # ffffffffc0205e60 <commands+0x16b0>
ffffffffc02036fe:	00002617          	auipc	a2,0x2
ffffffffc0203702:	aa260613          	addi	a2,a2,-1374 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203706:	0fe00593          	li	a1,254
ffffffffc020370a:	00002517          	auipc	a0,0x2
ffffffffc020370e:	61650513          	addi	a0,a0,1558 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203712:	9f5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203716:	00002697          	auipc	a3,0x2
ffffffffc020371a:	7ca68693          	addi	a3,a3,1994 # ffffffffc0205ee0 <commands+0x1730>
ffffffffc020371e:	00002617          	auipc	a2,0x2
ffffffffc0203722:	a8260613          	addi	a2,a2,-1406 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203726:	0f900593          	li	a1,249
ffffffffc020372a:	00002517          	auipc	a0,0x2
ffffffffc020372e:	5f650513          	addi	a0,a0,1526 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203732:	9d5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203736:	00003697          	auipc	a3,0x3
ffffffffc020373a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0206000 <commands+0x1850>
ffffffffc020373e:	00002617          	auipc	a2,0x2
ffffffffc0203742:	a6260613          	addi	a2,a2,-1438 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203746:	11700593          	li	a1,279
ffffffffc020374a:	00002517          	auipc	a0,0x2
ffffffffc020374e:	5d650513          	addi	a0,a0,1494 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203752:	9b5fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == 0);
ffffffffc0203756:	00003697          	auipc	a3,0x3
ffffffffc020375a:	8da68693          	addi	a3,a3,-1830 # ffffffffc0206030 <commands+0x1880>
ffffffffc020375e:	00002617          	auipc	a2,0x2
ffffffffc0203762:	a4260613          	addi	a2,a2,-1470 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203766:	12600593          	li	a1,294
ffffffffc020376a:	00002517          	auipc	a0,0x2
ffffffffc020376e:	5b650513          	addi	a0,a0,1462 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203772:	995fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203776:	00002697          	auipc	a3,0x2
ffffffffc020377a:	2d268693          	addi	a3,a3,722 # ffffffffc0205a48 <commands+0x1298>
ffffffffc020377e:	00002617          	auipc	a2,0x2
ffffffffc0203782:	a2260613          	addi	a2,a2,-1502 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203786:	0f300593          	li	a1,243
ffffffffc020378a:	00002517          	auipc	a0,0x2
ffffffffc020378e:	59650513          	addi	a0,a0,1430 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203792:	975fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203796:	00002697          	auipc	a3,0x2
ffffffffc020379a:	5c268693          	addi	a3,a3,1474 # ffffffffc0205d58 <commands+0x15a8>
ffffffffc020379e:	00002617          	auipc	a2,0x2
ffffffffc02037a2:	a0260613          	addi	a2,a2,-1534 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc02037a6:	0ba00593          	li	a1,186
ffffffffc02037aa:	00002517          	auipc	a0,0x2
ffffffffc02037ae:	57650513          	addi	a0,a0,1398 # ffffffffc0205d20 <commands+0x1570>
ffffffffc02037b2:	955fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02037b6 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02037b6:	1141                	addi	sp,sp,-16
ffffffffc02037b8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02037ba:	18058063          	beqz	a1,ffffffffc020393a <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02037be:	00359693          	slli	a3,a1,0x3
ffffffffc02037c2:	96ae                	add	a3,a3,a1
ffffffffc02037c4:	068e                	slli	a3,a3,0x3
ffffffffc02037c6:	96aa                	add	a3,a3,a0
ffffffffc02037c8:	02d50d63          	beq	a0,a3,ffffffffc0203802 <default_free_pages+0x4c>
ffffffffc02037cc:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02037ce:	8b85                	andi	a5,a5,1
ffffffffc02037d0:	14079563          	bnez	a5,ffffffffc020391a <default_free_pages+0x164>
ffffffffc02037d4:	651c                	ld	a5,8(a0)
ffffffffc02037d6:	8385                	srli	a5,a5,0x1
ffffffffc02037d8:	8b85                	andi	a5,a5,1
ffffffffc02037da:	14079063          	bnez	a5,ffffffffc020391a <default_free_pages+0x164>
ffffffffc02037de:	87aa                	mv	a5,a0
ffffffffc02037e0:	a809                	j	ffffffffc02037f2 <default_free_pages+0x3c>
ffffffffc02037e2:	6798                	ld	a4,8(a5)
ffffffffc02037e4:	8b05                	andi	a4,a4,1
ffffffffc02037e6:	12071a63          	bnez	a4,ffffffffc020391a <default_free_pages+0x164>
ffffffffc02037ea:	6798                	ld	a4,8(a5)
ffffffffc02037ec:	8b09                	andi	a4,a4,2
ffffffffc02037ee:	12071663          	bnez	a4,ffffffffc020391a <default_free_pages+0x164>
        p->flags = 0;
ffffffffc02037f2:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02037f6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02037fa:	04878793          	addi	a5,a5,72
ffffffffc02037fe:	fed792e3          	bne	a5,a3,ffffffffc02037e2 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0203802:	2581                	sext.w	a1,a1
ffffffffc0203804:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0203806:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020380a:	4789                	li	a5,2
ffffffffc020380c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203810:	0000e697          	auipc	a3,0xe
ffffffffc0203814:	d7868693          	addi	a3,a3,-648 # ffffffffc0211588 <free_area>
ffffffffc0203818:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020381a:	669c                	ld	a5,8(a3)
ffffffffc020381c:	9db9                	addw	a1,a1,a4
ffffffffc020381e:	0000e717          	auipc	a4,0xe
ffffffffc0203822:	d6b72d23          	sw	a1,-646(a4) # ffffffffc0211598 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203826:	08d78f63          	beq	a5,a3,ffffffffc02038c4 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc020382a:	fe078713          	addi	a4,a5,-32
ffffffffc020382e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203830:	4801                	li	a6,0
ffffffffc0203832:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203836:	00e56a63          	bltu	a0,a4,ffffffffc020384a <default_free_pages+0x94>
    return listelm->next;
ffffffffc020383a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020383c:	02d70563          	beq	a4,a3,ffffffffc0203866 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203840:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203842:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203846:	fee57ae3          	bleu	a4,a0,ffffffffc020383a <default_free_pages+0x84>
ffffffffc020384a:	00080663          	beqz	a6,ffffffffc0203856 <default_free_pages+0xa0>
ffffffffc020384e:	0000e817          	auipc	a6,0xe
ffffffffc0203852:	d2b83d23          	sd	a1,-710(a6) # ffffffffc0211588 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203856:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203858:	e390                	sd	a2,0(a5)
ffffffffc020385a:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020385c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020385e:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc0203860:	02d59163          	bne	a1,a3,ffffffffc0203882 <default_free_pages+0xcc>
ffffffffc0203864:	a091                	j	ffffffffc02038a8 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0203866:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203868:	f514                	sd	a3,40(a0)
ffffffffc020386a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020386c:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020386e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203870:	00d70563          	beq	a4,a3,ffffffffc020387a <default_free_pages+0xc4>
ffffffffc0203874:	4805                	li	a6,1
ffffffffc0203876:	87ba                	mv	a5,a4
ffffffffc0203878:	b7e9                	j	ffffffffc0203842 <default_free_pages+0x8c>
ffffffffc020387a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020387c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020387e:	02d78163          	beq	a5,a3,ffffffffc02038a0 <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0203882:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0203886:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc020388a:	02081713          	slli	a4,a6,0x20
ffffffffc020388e:	9301                	srli	a4,a4,0x20
ffffffffc0203890:	00371793          	slli	a5,a4,0x3
ffffffffc0203894:	97ba                	add	a5,a5,a4
ffffffffc0203896:	078e                	slli	a5,a5,0x3
ffffffffc0203898:	97b2                	add	a5,a5,a2
ffffffffc020389a:	02f50e63          	beq	a0,a5,ffffffffc02038d6 <default_free_pages+0x120>
ffffffffc020389e:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02038a0:	fe078713          	addi	a4,a5,-32
ffffffffc02038a4:	00d78d63          	beq	a5,a3,ffffffffc02038be <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02038a8:	4d0c                	lw	a1,24(a0)
ffffffffc02038aa:	02059613          	slli	a2,a1,0x20
ffffffffc02038ae:	9201                	srli	a2,a2,0x20
ffffffffc02038b0:	00361693          	slli	a3,a2,0x3
ffffffffc02038b4:	96b2                	add	a3,a3,a2
ffffffffc02038b6:	068e                	slli	a3,a3,0x3
ffffffffc02038b8:	96aa                	add	a3,a3,a0
ffffffffc02038ba:	04d70063          	beq	a4,a3,ffffffffc02038fa <default_free_pages+0x144>
}
ffffffffc02038be:	60a2                	ld	ra,8(sp)
ffffffffc02038c0:	0141                	addi	sp,sp,16
ffffffffc02038c2:	8082                	ret
ffffffffc02038c4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02038c6:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02038ca:	e398                	sd	a4,0(a5)
ffffffffc02038cc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02038ce:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02038d0:	f11c                	sd	a5,32(a0)
}
ffffffffc02038d2:	0141                	addi	sp,sp,16
ffffffffc02038d4:	8082                	ret
            p->property += base->property;
ffffffffc02038d6:	4d1c                	lw	a5,24(a0)
ffffffffc02038d8:	0107883b          	addw	a6,a5,a6
ffffffffc02038dc:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02038e0:	57f5                	li	a5,-3
ffffffffc02038e2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02038e6:	02053803          	ld	a6,32(a0)
ffffffffc02038ea:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc02038ec:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02038ee:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02038f2:	659c                	ld	a5,8(a1)
ffffffffc02038f4:	01073023          	sd	a6,0(a4)
ffffffffc02038f8:	b765                	j	ffffffffc02038a0 <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02038fa:	ff87a703          	lw	a4,-8(a5)
ffffffffc02038fe:	fe878693          	addi	a3,a5,-24
ffffffffc0203902:	9db9                	addw	a1,a1,a4
ffffffffc0203904:	cd0c                	sw	a1,24(a0)
ffffffffc0203906:	5775                	li	a4,-3
ffffffffc0203908:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020390c:	6398                	ld	a4,0(a5)
ffffffffc020390e:	679c                	ld	a5,8(a5)
}
ffffffffc0203910:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203912:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203914:	e398                	sd	a4,0(a5)
ffffffffc0203916:	0141                	addi	sp,sp,16
ffffffffc0203918:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020391a:	00002697          	auipc	a3,0x2
ffffffffc020391e:	72668693          	addi	a3,a3,1830 # ffffffffc0206040 <commands+0x1890>
ffffffffc0203922:	00002617          	auipc	a2,0x2
ffffffffc0203926:	87e60613          	addi	a2,a2,-1922 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc020392a:	08300593          	li	a1,131
ffffffffc020392e:	00002517          	auipc	a0,0x2
ffffffffc0203932:	3f250513          	addi	a0,a0,1010 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203936:	fd0fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc020393a:	00002697          	auipc	a3,0x2
ffffffffc020393e:	72e68693          	addi	a3,a3,1838 # ffffffffc0206068 <commands+0x18b8>
ffffffffc0203942:	00002617          	auipc	a2,0x2
ffffffffc0203946:	85e60613          	addi	a2,a2,-1954 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc020394a:	08000593          	li	a1,128
ffffffffc020394e:	00002517          	auipc	a0,0x2
ffffffffc0203952:	3d250513          	addi	a0,a0,978 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203956:	fb0fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc020395a <default_alloc_pages>:
    assert(n > 0);
ffffffffc020395a:	cd51                	beqz	a0,ffffffffc02039f6 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020395c:	0000e597          	auipc	a1,0xe
ffffffffc0203960:	c2c58593          	addi	a1,a1,-980 # ffffffffc0211588 <free_area>
ffffffffc0203964:	0105a803          	lw	a6,16(a1)
ffffffffc0203968:	862a                	mv	a2,a0
ffffffffc020396a:	02081793          	slli	a5,a6,0x20
ffffffffc020396e:	9381                	srli	a5,a5,0x20
ffffffffc0203970:	00a7ee63          	bltu	a5,a0,ffffffffc020398c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203974:	87ae                	mv	a5,a1
ffffffffc0203976:	a801                	j	ffffffffc0203986 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203978:	ff87a703          	lw	a4,-8(a5)
ffffffffc020397c:	02071693          	slli	a3,a4,0x20
ffffffffc0203980:	9281                	srli	a3,a3,0x20
ffffffffc0203982:	00c6f763          	bleu	a2,a3,ffffffffc0203990 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203986:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203988:	feb798e3          	bne	a5,a1,ffffffffc0203978 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020398c:	4501                	li	a0,0
}
ffffffffc020398e:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0203990:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0203994:	dd6d                	beqz	a0,ffffffffc020398e <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0203996:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020399a:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020399e:	00060e1b          	sext.w	t3,a2
ffffffffc02039a2:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02039a6:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02039aa:	02d67b63          	bleu	a3,a2,ffffffffc02039e0 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02039ae:	00361693          	slli	a3,a2,0x3
ffffffffc02039b2:	96b2                	add	a3,a3,a2
ffffffffc02039b4:	068e                	slli	a3,a3,0x3
ffffffffc02039b6:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02039b8:	41c7073b          	subw	a4,a4,t3
ffffffffc02039bc:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02039be:	00868613          	addi	a2,a3,8
ffffffffc02039c2:	4709                	li	a4,2
ffffffffc02039c4:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02039c8:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02039cc:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02039d0:	0105a803          	lw	a6,16(a1)
ffffffffc02039d4:	e310                	sd	a2,0(a4)
ffffffffc02039d6:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02039da:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02039dc:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc02039e0:	41c8083b          	subw	a6,a6,t3
ffffffffc02039e4:	0000e717          	auipc	a4,0xe
ffffffffc02039e8:	bb072a23          	sw	a6,-1100(a4) # ffffffffc0211598 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02039ec:	5775                	li	a4,-3
ffffffffc02039ee:	17a1                	addi	a5,a5,-24
ffffffffc02039f0:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02039f4:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02039f6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02039f8:	00002697          	auipc	a3,0x2
ffffffffc02039fc:	67068693          	addi	a3,a3,1648 # ffffffffc0206068 <commands+0x18b8>
ffffffffc0203a00:	00001617          	auipc	a2,0x1
ffffffffc0203a04:	7a060613          	addi	a2,a2,1952 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203a08:	06200593          	li	a1,98
ffffffffc0203a0c:	00002517          	auipc	a0,0x2
ffffffffc0203a10:	31450513          	addi	a0,a0,788 # ffffffffc0205d20 <commands+0x1570>
default_alloc_pages(size_t n) {
ffffffffc0203a14:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203a16:	ef0fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203a1a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203a1a:	1141                	addi	sp,sp,-16
ffffffffc0203a1c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203a1e:	c1fd                	beqz	a1,ffffffffc0203b04 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc0203a20:	00359693          	slli	a3,a1,0x3
ffffffffc0203a24:	96ae                	add	a3,a3,a1
ffffffffc0203a26:	068e                	slli	a3,a3,0x3
ffffffffc0203a28:	96aa                	add	a3,a3,a0
ffffffffc0203a2a:	02d50463          	beq	a0,a3,ffffffffc0203a52 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203a2e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0203a30:	87aa                	mv	a5,a0
ffffffffc0203a32:	8b05                	andi	a4,a4,1
ffffffffc0203a34:	e709                	bnez	a4,ffffffffc0203a3e <default_init_memmap+0x24>
ffffffffc0203a36:	a07d                	j	ffffffffc0203ae4 <default_init_memmap+0xca>
ffffffffc0203a38:	6798                	ld	a4,8(a5)
ffffffffc0203a3a:	8b05                	andi	a4,a4,1
ffffffffc0203a3c:	c745                	beqz	a4,ffffffffc0203ae4 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0203a3e:	0007ac23          	sw	zero,24(a5)
ffffffffc0203a42:	0007b423          	sd	zero,8(a5)
ffffffffc0203a46:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203a4a:	04878793          	addi	a5,a5,72
ffffffffc0203a4e:	fed795e3          	bne	a5,a3,ffffffffc0203a38 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0203a52:	2581                	sext.w	a1,a1
ffffffffc0203a54:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203a56:	4789                	li	a5,2
ffffffffc0203a58:	00850713          	addi	a4,a0,8
ffffffffc0203a5c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203a60:	0000e697          	auipc	a3,0xe
ffffffffc0203a64:	b2868693          	addi	a3,a3,-1240 # ffffffffc0211588 <free_area>
ffffffffc0203a68:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203a6a:	669c                	ld	a5,8(a3)
ffffffffc0203a6c:	9db9                	addw	a1,a1,a4
ffffffffc0203a6e:	0000e717          	auipc	a4,0xe
ffffffffc0203a72:	b2b72523          	sw	a1,-1238(a4) # ffffffffc0211598 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0203a76:	04d78a63          	beq	a5,a3,ffffffffc0203aca <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0203a7a:	fe078713          	addi	a4,a5,-32
ffffffffc0203a7e:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203a80:	4801                	li	a6,0
ffffffffc0203a82:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0203a86:	00e56a63          	bltu	a0,a4,ffffffffc0203a9a <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0203a8a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203a8c:	02d70563          	beq	a4,a3,ffffffffc0203ab6 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203a90:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203a92:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0203a96:	fee57ae3          	bleu	a4,a0,ffffffffc0203a8a <default_init_memmap+0x70>
ffffffffc0203a9a:	00080663          	beqz	a6,ffffffffc0203aa6 <default_init_memmap+0x8c>
ffffffffc0203a9e:	0000e717          	auipc	a4,0xe
ffffffffc0203aa2:	aeb73523          	sd	a1,-1302(a4) # ffffffffc0211588 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203aa6:	6398                	ld	a4,0(a5)
}
ffffffffc0203aa8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203aaa:	e390                	sd	a2,0(a5)
ffffffffc0203aac:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203aae:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203ab0:	f118                	sd	a4,32(a0)
ffffffffc0203ab2:	0141                	addi	sp,sp,16
ffffffffc0203ab4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203ab6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203ab8:	f514                	sd	a3,40(a0)
ffffffffc0203aba:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203abc:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0203abe:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203ac0:	00d70e63          	beq	a4,a3,ffffffffc0203adc <default_init_memmap+0xc2>
ffffffffc0203ac4:	4805                	li	a6,1
ffffffffc0203ac6:	87ba                	mv	a5,a4
ffffffffc0203ac8:	b7e9                	j	ffffffffc0203a92 <default_init_memmap+0x78>
}
ffffffffc0203aca:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0203acc:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0203ad0:	e398                	sd	a4,0(a5)
ffffffffc0203ad2:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203ad4:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0203ad6:	f11c                	sd	a5,32(a0)
}
ffffffffc0203ad8:	0141                	addi	sp,sp,16
ffffffffc0203ada:	8082                	ret
ffffffffc0203adc:	60a2                	ld	ra,8(sp)
ffffffffc0203ade:	e290                	sd	a2,0(a3)
ffffffffc0203ae0:	0141                	addi	sp,sp,16
ffffffffc0203ae2:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203ae4:	00002697          	auipc	a3,0x2
ffffffffc0203ae8:	58c68693          	addi	a3,a3,1420 # ffffffffc0206070 <commands+0x18c0>
ffffffffc0203aec:	00001617          	auipc	a2,0x1
ffffffffc0203af0:	6b460613          	addi	a2,a2,1716 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203af4:	04900593          	li	a1,73
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	22850513          	addi	a0,a0,552 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203b00:	e06fc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(n > 0);
ffffffffc0203b04:	00002697          	auipc	a3,0x2
ffffffffc0203b08:	56468693          	addi	a3,a3,1380 # ffffffffc0206068 <commands+0x18b8>
ffffffffc0203b0c:	00001617          	auipc	a2,0x1
ffffffffc0203b10:	69460613          	addi	a2,a2,1684 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203b14:	04600593          	li	a1,70
ffffffffc0203b18:	00002517          	auipc	a0,0x2
ffffffffc0203b1c:	20850513          	addi	a0,a0,520 # ffffffffc0205d20 <commands+0x1570>
ffffffffc0203b20:	de6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203b24 <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203b24:	0000e797          	auipc	a5,0xe
ffffffffc0203b28:	98478793          	addi	a5,a5,-1660 # ffffffffc02114a8 <pra_list_head>

static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203b2c:	f51c                	sd	a5,40(a0)
ffffffffc0203b2e:	e79c                	sd	a5,8(a5)
ffffffffc0203b30:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203b32:	4501                	li	a0,0
ffffffffc0203b34:	8082                	ret

ffffffffc0203b36 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc0203b36:	4501                	li	a0,0
ffffffffc0203b38:	8082                	ret

ffffffffc0203b3a <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203b3a:	4501                	li	a0,0
ffffffffc0203b3c:	8082                	ret

ffffffffc0203b3e <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ 
    return 0;
}
ffffffffc0203b3e:	4501                	li	a0,0
ffffffffc0203b40:	8082                	ret

ffffffffc0203b42 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0203b42:	711d                	addi	sp,sp,-96
ffffffffc0203b44:	fc4e                	sd	s3,56(sp)
ffffffffc0203b46:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203b48:	00002517          	auipc	a0,0x2
ffffffffc0203b4c:	58850513          	addi	a0,a0,1416 # ffffffffc02060d0 <default_pmm_manager+0x50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203b50:	698d                	lui	s3,0x3
ffffffffc0203b52:	4a31                	li	s4,12
_lru_check_swap(void) {
ffffffffc0203b54:	e8a2                	sd	s0,80(sp)
ffffffffc0203b56:	e4a6                	sd	s1,72(sp)
ffffffffc0203b58:	ec86                	sd	ra,88(sp)
ffffffffc0203b5a:	e0ca                	sd	s2,64(sp)
ffffffffc0203b5c:	f456                	sd	s5,40(sp)
ffffffffc0203b5e:	f05a                	sd	s6,32(sp)
ffffffffc0203b60:	ec5e                	sd	s7,24(sp)
ffffffffc0203b62:	e862                	sd	s8,16(sp)
ffffffffc0203b64:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203b66:	0000e417          	auipc	s0,0xe
ffffffffc0203b6a:	90240413          	addi	s0,s0,-1790 # ffffffffc0211468 <pgfault_num>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203b6e:	d50fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203b72:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203b76:	4004                	lw	s1,0(s0)
ffffffffc0203b78:	4791                	li	a5,4
ffffffffc0203b7a:	2481                	sext.w	s1,s1
ffffffffc0203b7c:	14f49963          	bne	s1,a5,ffffffffc0203cce <_lru_check_swap+0x18c>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203b80:	00002517          	auipc	a0,0x2
ffffffffc0203b84:	59050513          	addi	a0,a0,1424 # ffffffffc0206110 <default_pmm_manager+0x90>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203b88:	6a85                	lui	s5,0x1
ffffffffc0203b8a:	4b29                	li	s6,10
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203b8c:	d32fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203b90:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203b94:	00042903          	lw	s2,0(s0)
ffffffffc0203b98:	2901                	sext.w	s2,s2
ffffffffc0203b9a:	2a991a63          	bne	s2,s1,ffffffffc0203e4e <_lru_check_swap+0x30c>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203b9e:	00002517          	auipc	a0,0x2
ffffffffc0203ba2:	59a50513          	addi	a0,a0,1434 # ffffffffc0206138 <default_pmm_manager+0xb8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203ba6:	6b91                	lui	s7,0x4
ffffffffc0203ba8:	4c35                	li	s8,13
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203baa:	d14fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203bae:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203bb2:	4004                	lw	s1,0(s0)
ffffffffc0203bb4:	2481                	sext.w	s1,s1
ffffffffc0203bb6:	27249c63          	bne	s1,s2,ffffffffc0203e2e <_lru_check_swap+0x2ec>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203bba:	00002517          	auipc	a0,0x2
ffffffffc0203bbe:	5a650513          	addi	a0,a0,1446 # ffffffffc0206160 <default_pmm_manager+0xe0>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203bc2:	6909                	lui	s2,0x2
ffffffffc0203bc4:	4cad                	li	s9,11
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203bc6:	cf8fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203bca:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203bce:	401c                	lw	a5,0(s0)
ffffffffc0203bd0:	2781                	sext.w	a5,a5
ffffffffc0203bd2:	22979e63          	bne	a5,s1,ffffffffc0203e0e <_lru_check_swap+0x2cc>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203bd6:	00002517          	auipc	a0,0x2
ffffffffc0203bda:	5b250513          	addi	a0,a0,1458 # ffffffffc0206188 <default_pmm_manager+0x108>
ffffffffc0203bde:	ce0fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203be2:	6795                	lui	a5,0x5
ffffffffc0203be4:	4739                	li	a4,14
ffffffffc0203be6:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203bea:	4004                	lw	s1,0(s0)
ffffffffc0203bec:	4795                	li	a5,5
ffffffffc0203bee:	2481                	sext.w	s1,s1
ffffffffc0203bf0:	1ef49f63          	bne	s1,a5,ffffffffc0203dee <_lru_check_swap+0x2ac>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203bf4:	00002517          	auipc	a0,0x2
ffffffffc0203bf8:	56c50513          	addi	a0,a0,1388 # ffffffffc0206160 <default_pmm_manager+0xe0>
ffffffffc0203bfc:	cc2fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c00:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203c04:	401c                	lw	a5,0(s0)
ffffffffc0203c06:	2781                	sext.w	a5,a5
ffffffffc0203c08:	1c979363          	bne	a5,s1,ffffffffc0203dce <_lru_check_swap+0x28c>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	50450513          	addi	a0,a0,1284 # ffffffffc0206110 <default_pmm_manager+0x90>
ffffffffc0203c14:	caafc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c18:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203c1c:	401c                	lw	a5,0(s0)
ffffffffc0203c1e:	4719                	li	a4,6
ffffffffc0203c20:	2781                	sext.w	a5,a5
ffffffffc0203c22:	18e79663          	bne	a5,a4,ffffffffc0203dae <_lru_check_swap+0x26c>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc0203c26:	00002517          	auipc	a0,0x2
ffffffffc0203c2a:	53a50513          	addi	a0,a0,1338 # ffffffffc0206160 <default_pmm_manager+0xe0>
ffffffffc0203c2e:	c90fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203c32:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203c36:	401c                	lw	a5,0(s0)
ffffffffc0203c38:	471d                	li	a4,7
ffffffffc0203c3a:	2781                	sext.w	a5,a5
ffffffffc0203c3c:	14e79963          	bne	a5,a4,ffffffffc0203d8e <_lru_check_swap+0x24c>
    cprintf("write Virt Page c in lru_check_swap\n");
ffffffffc0203c40:	00002517          	auipc	a0,0x2
ffffffffc0203c44:	49050513          	addi	a0,a0,1168 # ffffffffc02060d0 <default_pmm_manager+0x50>
ffffffffc0203c48:	c76fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c4c:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203c50:	401c                	lw	a5,0(s0)
ffffffffc0203c52:	4721                	li	a4,8
ffffffffc0203c54:	2781                	sext.w	a5,a5
ffffffffc0203c56:	10e79c63          	bne	a5,a4,ffffffffc0203d6e <_lru_check_swap+0x22c>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203c5a:	00002517          	auipc	a0,0x2
ffffffffc0203c5e:	4de50513          	addi	a0,a0,1246 # ffffffffc0206138 <default_pmm_manager+0xb8>
ffffffffc0203c62:	c5cfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c66:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203c6a:	401c                	lw	a5,0(s0)
ffffffffc0203c6c:	4725                	li	a4,9
ffffffffc0203c6e:	2781                	sext.w	a5,a5
ffffffffc0203c70:	0ce79f63          	bne	a5,a4,ffffffffc0203d4e <_lru_check_swap+0x20c>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc0203c74:	00002517          	auipc	a0,0x2
ffffffffc0203c78:	51450513          	addi	a0,a0,1300 # ffffffffc0206188 <default_pmm_manager+0x108>
ffffffffc0203c7c:	c42fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203c80:	6795                	lui	a5,0x5
ffffffffc0203c82:	4739                	li	a4,14
ffffffffc0203c84:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203c88:	4004                	lw	s1,0(s0)
ffffffffc0203c8a:	47a9                	li	a5,10
ffffffffc0203c8c:	2481                	sext.w	s1,s1
ffffffffc0203c8e:	0af49063          	bne	s1,a5,ffffffffc0203d2e <_lru_check_swap+0x1ec>
    cprintf("write Virt Page a in lru_check_swap\n");
ffffffffc0203c92:	00002517          	auipc	a0,0x2
ffffffffc0203c96:	47e50513          	addi	a0,a0,1150 # ffffffffc0206110 <default_pmm_manager+0x90>
ffffffffc0203c9a:	c24fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203c9e:	6785                	lui	a5,0x1
ffffffffc0203ca0:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203ca4:	06979563          	bne	a5,s1,ffffffffc0203d0e <_lru_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203ca8:	401c                	lw	a5,0(s0)
ffffffffc0203caa:	472d                	li	a4,11
ffffffffc0203cac:	2781                	sext.w	a5,a5
ffffffffc0203cae:	04e79063          	bne	a5,a4,ffffffffc0203cee <_lru_check_swap+0x1ac>
}
ffffffffc0203cb2:	60e6                	ld	ra,88(sp)
ffffffffc0203cb4:	6446                	ld	s0,80(sp)
ffffffffc0203cb6:	64a6                	ld	s1,72(sp)
ffffffffc0203cb8:	6906                	ld	s2,64(sp)
ffffffffc0203cba:	79e2                	ld	s3,56(sp)
ffffffffc0203cbc:	7a42                	ld	s4,48(sp)
ffffffffc0203cbe:	7aa2                	ld	s5,40(sp)
ffffffffc0203cc0:	7b02                	ld	s6,32(sp)
ffffffffc0203cc2:	6be2                	ld	s7,24(sp)
ffffffffc0203cc4:	6c42                	ld	s8,16(sp)
ffffffffc0203cc6:	6ca2                	ld	s9,8(sp)
ffffffffc0203cc8:	4501                	li	a0,0
ffffffffc0203cca:	6125                	addi	sp,sp,96
ffffffffc0203ccc:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203cce:	00002697          	auipc	a3,0x2
ffffffffc0203cd2:	f0a68693          	addi	a3,a3,-246 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0203cd6:	00001617          	auipc	a2,0x1
ffffffffc0203cda:	4ca60613          	addi	a2,a2,1226 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203cde:	04400593          	li	a1,68
ffffffffc0203ce2:	00002517          	auipc	a0,0x2
ffffffffc0203ce6:	41650513          	addi	a0,a0,1046 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203cea:	c1cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==11);
ffffffffc0203cee:	00002697          	auipc	a3,0x2
ffffffffc0203cf2:	51a68693          	addi	a3,a3,1306 # ffffffffc0206208 <default_pmm_manager+0x188>
ffffffffc0203cf6:	00001617          	auipc	a2,0x1
ffffffffc0203cfa:	4aa60613          	addi	a2,a2,1194 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203cfe:	06600593          	li	a1,102
ffffffffc0203d02:	00002517          	auipc	a0,0x2
ffffffffc0203d06:	3f650513          	addi	a0,a0,1014 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203d0a:	bfcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d0e:	00002697          	auipc	a3,0x2
ffffffffc0203d12:	4d268693          	addi	a3,a3,1234 # ffffffffc02061e0 <default_pmm_manager+0x160>
ffffffffc0203d16:	00001617          	auipc	a2,0x1
ffffffffc0203d1a:	48a60613          	addi	a2,a2,1162 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203d1e:	06400593          	li	a1,100
ffffffffc0203d22:	00002517          	auipc	a0,0x2
ffffffffc0203d26:	3d650513          	addi	a0,a0,982 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203d2a:	bdcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==10);
ffffffffc0203d2e:	00002697          	auipc	a3,0x2
ffffffffc0203d32:	4a268693          	addi	a3,a3,1186 # ffffffffc02061d0 <default_pmm_manager+0x150>
ffffffffc0203d36:	00001617          	auipc	a2,0x1
ffffffffc0203d3a:	46a60613          	addi	a2,a2,1130 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203d3e:	06200593          	li	a1,98
ffffffffc0203d42:	00002517          	auipc	a0,0x2
ffffffffc0203d46:	3b650513          	addi	a0,a0,950 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203d4a:	bbcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==9);
ffffffffc0203d4e:	00002697          	auipc	a3,0x2
ffffffffc0203d52:	47268693          	addi	a3,a3,1138 # ffffffffc02061c0 <default_pmm_manager+0x140>
ffffffffc0203d56:	00001617          	auipc	a2,0x1
ffffffffc0203d5a:	44a60613          	addi	a2,a2,1098 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203d5e:	05f00593          	li	a1,95
ffffffffc0203d62:	00002517          	auipc	a0,0x2
ffffffffc0203d66:	39650513          	addi	a0,a0,918 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203d6a:	b9cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==8);
ffffffffc0203d6e:	00002697          	auipc	a3,0x2
ffffffffc0203d72:	44268693          	addi	a3,a3,1090 # ffffffffc02061b0 <default_pmm_manager+0x130>
ffffffffc0203d76:	00001617          	auipc	a2,0x1
ffffffffc0203d7a:	42a60613          	addi	a2,a2,1066 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203d7e:	05c00593          	li	a1,92
ffffffffc0203d82:	00002517          	auipc	a0,0x2
ffffffffc0203d86:	37650513          	addi	a0,a0,886 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203d8a:	b7cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==7);
ffffffffc0203d8e:	00002697          	auipc	a3,0x2
ffffffffc0203d92:	e7a68693          	addi	a3,a3,-390 # ffffffffc0205c08 <commands+0x1458>
ffffffffc0203d96:	00001617          	auipc	a2,0x1
ffffffffc0203d9a:	40a60613          	addi	a2,a2,1034 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203d9e:	05900593          	li	a1,89
ffffffffc0203da2:	00002517          	auipc	a0,0x2
ffffffffc0203da6:	35650513          	addi	a0,a0,854 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203daa:	b5cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==6);
ffffffffc0203dae:	00002697          	auipc	a3,0x2
ffffffffc0203db2:	e4a68693          	addi	a3,a3,-438 # ffffffffc0205bf8 <commands+0x1448>
ffffffffc0203db6:	00001617          	auipc	a2,0x1
ffffffffc0203dba:	3ea60613          	addi	a2,a2,1002 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203dbe:	05600593          	li	a1,86
ffffffffc0203dc2:	00002517          	auipc	a0,0x2
ffffffffc0203dc6:	33650513          	addi	a0,a0,822 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203dca:	b3cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203dce:	00002697          	auipc	a3,0x2
ffffffffc0203dd2:	e1a68693          	addi	a3,a3,-486 # ffffffffc0205be8 <commands+0x1438>
ffffffffc0203dd6:	00001617          	auipc	a2,0x1
ffffffffc0203dda:	3ca60613          	addi	a2,a2,970 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203dde:	05300593          	li	a1,83
ffffffffc0203de2:	00002517          	auipc	a0,0x2
ffffffffc0203de6:	31650513          	addi	a0,a0,790 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203dea:	b1cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==5);
ffffffffc0203dee:	00002697          	auipc	a3,0x2
ffffffffc0203df2:	dfa68693          	addi	a3,a3,-518 # ffffffffc0205be8 <commands+0x1438>
ffffffffc0203df6:	00001617          	auipc	a2,0x1
ffffffffc0203dfa:	3aa60613          	addi	a2,a2,938 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203dfe:	05000593          	li	a1,80
ffffffffc0203e02:	00002517          	auipc	a0,0x2
ffffffffc0203e06:	2f650513          	addi	a0,a0,758 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203e0a:	afcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203e0e:	00002697          	auipc	a3,0x2
ffffffffc0203e12:	dca68693          	addi	a3,a3,-566 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0203e16:	00001617          	auipc	a2,0x1
ffffffffc0203e1a:	38a60613          	addi	a2,a2,906 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203e1e:	04d00593          	li	a1,77
ffffffffc0203e22:	00002517          	auipc	a0,0x2
ffffffffc0203e26:	2d650513          	addi	a0,a0,726 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203e2a:	adcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203e2e:	00002697          	auipc	a3,0x2
ffffffffc0203e32:	daa68693          	addi	a3,a3,-598 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0203e36:	00001617          	auipc	a2,0x1
ffffffffc0203e3a:	36a60613          	addi	a2,a2,874 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203e3e:	04a00593          	li	a1,74
ffffffffc0203e42:	00002517          	auipc	a0,0x2
ffffffffc0203e46:	2b650513          	addi	a0,a0,694 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203e4a:	abcfc0ef          	jal	ra,ffffffffc0200106 <__panic>
    assert(pgfault_num==4);
ffffffffc0203e4e:	00002697          	auipc	a3,0x2
ffffffffc0203e52:	d8a68693          	addi	a3,a3,-630 # ffffffffc0205bd8 <commands+0x1428>
ffffffffc0203e56:	00001617          	auipc	a2,0x1
ffffffffc0203e5a:	34a60613          	addi	a2,a2,842 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203e5e:	04700593          	li	a1,71
ffffffffc0203e62:	00002517          	auipc	a0,0x2
ffffffffc0203e66:	29650513          	addi	a0,a0,662 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203e6a:	a9cfc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203e6e <_lru_update_swaplist>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203e6e:	03058713          	addi	a4,a1,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203e72:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203e74:	c305                	beqz	a4,ffffffffc0203e94 <_lru_update_swaplist+0x26>
ffffffffc0203e76:	cf99                	beqz	a5,ffffffffc0203e94 <_lru_update_swaplist+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203e78:	0305b803          	ld	a6,48(a1)
ffffffffc0203e7c:	7d90                	ld	a2,56(a1)
}
ffffffffc0203e7e:	4501                	li	a0,0
    prev->next = next;
ffffffffc0203e80:	00c83423          	sd	a2,8(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203e84:	6794                	ld	a3,8(a5)
    next->prev = prev;
ffffffffc0203e86:	01063023          	sd	a6,0(a2)
    prev->next = next->prev = elm;
ffffffffc0203e8a:	e298                	sd	a4,0(a3)
ffffffffc0203e8c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203e8e:	fd94                	sd	a3,56(a1)
    elm->prev = prev;
ffffffffc0203e90:	f99c                	sd	a5,48(a1)
ffffffffc0203e92:	8082                	ret
{
ffffffffc0203e94:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203e96:	00002697          	auipc	a3,0x2
ffffffffc0203e9a:	3a268693          	addi	a3,a3,930 # ffffffffc0206238 <default_pmm_manager+0x1b8>
ffffffffc0203e9e:	00001617          	auipc	a2,0x1
ffffffffc0203ea2:	30260613          	addi	a2,a2,770 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203ea6:	02800593          	li	a1,40
ffffffffc0203eaa:	00002517          	auipc	a0,0x2
ffffffffc0203eae:	24e50513          	addi	a0,a0,590 # ffffffffc02060f8 <default_pmm_manager+0x78>
{
ffffffffc0203eb2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203eb4:	a52fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203eb8 <_lru_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203eb8:	7518                	ld	a4,40(a0)
{
ffffffffc0203eba:	1141                	addi	sp,sp,-16
ffffffffc0203ebc:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203ebe:	c731                	beqz	a4,ffffffffc0203f0a <_lru_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0203ec0:	e60d                	bnez	a2,ffffffffc0203eea <_lru_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0203ec2:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0203ec4:	00f70d63          	beq	a4,a5,ffffffffc0203ede <_lru_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203ec8:	6394                	ld	a3,0(a5)
ffffffffc0203eca:	6798                	ld	a4,8(a5)
}
ffffffffc0203ecc:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203ece:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc0203ed2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203ed4:	e314                	sd	a3,0(a4)
ffffffffc0203ed6:	e19c                	sd	a5,0(a1)
}
ffffffffc0203ed8:	4501                	li	a0,0
ffffffffc0203eda:	0141                	addi	sp,sp,16
ffffffffc0203edc:	8082                	ret
ffffffffc0203ede:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0203ee0:	0005b023          	sd	zero,0(a1)
}
ffffffffc0203ee4:	4501                	li	a0,0
ffffffffc0203ee6:	0141                	addi	sp,sp,16
ffffffffc0203ee8:	8082                	ret
     assert(in_tick==0);
ffffffffc0203eea:	00002697          	auipc	a3,0x2
ffffffffc0203eee:	33e68693          	addi	a3,a3,830 # ffffffffc0206228 <default_pmm_manager+0x1a8>
ffffffffc0203ef2:	00001617          	auipc	a2,0x1
ffffffffc0203ef6:	2ae60613          	addi	a2,a2,686 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203efa:	03400593          	li	a1,52
ffffffffc0203efe:	00002517          	auipc	a0,0x2
ffffffffc0203f02:	1fa50513          	addi	a0,a0,506 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203f06:	a00fc0ef          	jal	ra,ffffffffc0200106 <__panic>
         assert(head != NULL);
ffffffffc0203f0a:	00002697          	auipc	a3,0x2
ffffffffc0203f0e:	30e68693          	addi	a3,a3,782 # ffffffffc0206218 <default_pmm_manager+0x198>
ffffffffc0203f12:	00001617          	auipc	a2,0x1
ffffffffc0203f16:	28e60613          	addi	a2,a2,654 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203f1a:	03300593          	li	a1,51
ffffffffc0203f1e:	00002517          	auipc	a0,0x2
ffffffffc0203f22:	1da50513          	addi	a0,a0,474 # ffffffffc02060f8 <default_pmm_manager+0x78>
ffffffffc0203f26:	9e0fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203f2a <_lru_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203f2a:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f2e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203f30:	cb09                	beqz	a4,ffffffffc0203f42 <_lru_map_swappable+0x18>
ffffffffc0203f32:	cb81                	beqz	a5,ffffffffc0203f42 <_lru_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203f34:	6794                	ld	a3,8(a5)
}
ffffffffc0203f36:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203f38:	e298                	sd	a4,0(a3)
ffffffffc0203f3a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203f3c:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203f3e:	fa1c                	sd	a5,48(a2)
ffffffffc0203f40:	8082                	ret
{
ffffffffc0203f42:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203f44:	00002697          	auipc	a3,0x2
ffffffffc0203f48:	2f468693          	addi	a3,a3,756 # ffffffffc0206238 <default_pmm_manager+0x1b8>
ffffffffc0203f4c:	00001617          	auipc	a2,0x1
ffffffffc0203f50:	25460613          	addi	a2,a2,596 # ffffffffc02051a0 <commands+0x9f0>
ffffffffc0203f54:	45ed                	li	a1,27
ffffffffc0203f56:	00002517          	auipc	a0,0x2
ffffffffc0203f5a:	1a250513          	addi	a0,a0,418 # ffffffffc02060f8 <default_pmm_manager+0x78>
{
ffffffffc0203f5e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203f60:	9a6fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203f64 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f64:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f66:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f68:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f6a:	c6cfc0ef          	jal	ra,ffffffffc02003d6 <ide_device_valid>
ffffffffc0203f6e:	cd01                	beqz	a0,ffffffffc0203f86 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f70:	4505                	li	a0,1
ffffffffc0203f72:	c6afc0ef          	jal	ra,ffffffffc02003dc <ide_device_size>
}
ffffffffc0203f76:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f78:	810d                	srli	a0,a0,0x3
ffffffffc0203f7a:	0000d797          	auipc	a5,0xd
ffffffffc0203f7e:	5ca7b723          	sd	a0,1486(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203f82:	0141                	addi	sp,sp,16
ffffffffc0203f84:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203f86:	00002617          	auipc	a2,0x2
ffffffffc0203f8a:	2ea60613          	addi	a2,a2,746 # ffffffffc0206270 <default_pmm_manager+0x1f0>
ffffffffc0203f8e:	45b5                	li	a1,13
ffffffffc0203f90:	00002517          	auipc	a0,0x2
ffffffffc0203f94:	30050513          	addi	a0,a0,768 # ffffffffc0206290 <default_pmm_manager+0x210>
ffffffffc0203f98:	96efc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0203f9c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203f9c:	1141                	addi	sp,sp,-16
ffffffffc0203f9e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fa0:	00855793          	srli	a5,a0,0x8
ffffffffc0203fa4:	c7b5                	beqz	a5,ffffffffc0204010 <swapfs_read+0x74>
ffffffffc0203fa6:	0000d717          	auipc	a4,0xd
ffffffffc0203faa:	5a270713          	addi	a4,a4,1442 # ffffffffc0211548 <max_swap_offset>
ffffffffc0203fae:	6318                	ld	a4,0(a4)
ffffffffc0203fb0:	06e7f063          	bleu	a4,a5,ffffffffc0204010 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fb4:	0000d717          	auipc	a4,0xd
ffffffffc0203fb8:	4ec70713          	addi	a4,a4,1260 # ffffffffc02114a0 <pages>
ffffffffc0203fbc:	6310                	ld	a2,0(a4)
ffffffffc0203fbe:	00001717          	auipc	a4,0x1
ffffffffc0203fc2:	02a70713          	addi	a4,a4,42 # ffffffffc0204fe8 <commands+0x838>
ffffffffc0203fc6:	00002697          	auipc	a3,0x2
ffffffffc0203fca:	54a68693          	addi	a3,a3,1354 # ffffffffc0206510 <nbase>
ffffffffc0203fce:	40c58633          	sub	a2,a1,a2
ffffffffc0203fd2:	630c                	ld	a1,0(a4)
ffffffffc0203fd4:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fd6:	0000d717          	auipc	a4,0xd
ffffffffc0203fda:	48a70713          	addi	a4,a4,1162 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fde:	02b60633          	mul	a2,a2,a1
ffffffffc0203fe2:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203fe6:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fe8:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203fea:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203fec:	57fd                	li	a5,-1
ffffffffc0203fee:	83b1                	srli	a5,a5,0xc
ffffffffc0203ff0:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ff2:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ff4:	02e7fa63          	bleu	a4,a5,ffffffffc0204028 <swapfs_read+0x8c>
ffffffffc0203ff8:	0000d797          	auipc	a5,0xd
ffffffffc0203ffc:	49878793          	addi	a5,a5,1176 # ffffffffc0211490 <va_pa_offset>
ffffffffc0204000:	639c                	ld	a5,0(a5)
}
ffffffffc0204002:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204004:	46a1                	li	a3,8
ffffffffc0204006:	963e                	add	a2,a2,a5
ffffffffc0204008:	4505                	li	a0,1
}
ffffffffc020400a:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020400c:	bd6fc06f          	j	ffffffffc02003e2 <ide_read_secs>
ffffffffc0204010:	86aa                	mv	a3,a0
ffffffffc0204012:	00002617          	auipc	a2,0x2
ffffffffc0204016:	29660613          	addi	a2,a2,662 # ffffffffc02062a8 <default_pmm_manager+0x228>
ffffffffc020401a:	45d1                	li	a1,20
ffffffffc020401c:	00002517          	auipc	a0,0x2
ffffffffc0204020:	27450513          	addi	a0,a0,628 # ffffffffc0206290 <default_pmm_manager+0x210>
ffffffffc0204024:	8e2fc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc0204028:	86b2                	mv	a3,a2
ffffffffc020402a:	06a00593          	li	a1,106
ffffffffc020402e:	00001617          	auipc	a2,0x1
ffffffffc0204032:	fc260613          	addi	a2,a2,-62 # ffffffffc0204ff0 <commands+0x840>
ffffffffc0204036:	00001517          	auipc	a0,0x1
ffffffffc020403a:	05250513          	addi	a0,a0,82 # ffffffffc0205088 <commands+0x8d8>
ffffffffc020403e:	8c8fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc0204042 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204042:	1141                	addi	sp,sp,-16
ffffffffc0204044:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204046:	00855793          	srli	a5,a0,0x8
ffffffffc020404a:	c7b5                	beqz	a5,ffffffffc02040b6 <swapfs_write+0x74>
ffffffffc020404c:	0000d717          	auipc	a4,0xd
ffffffffc0204050:	4fc70713          	addi	a4,a4,1276 # ffffffffc0211548 <max_swap_offset>
ffffffffc0204054:	6318                	ld	a4,0(a4)
ffffffffc0204056:	06e7f063          	bleu	a4,a5,ffffffffc02040b6 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020405a:	0000d717          	auipc	a4,0xd
ffffffffc020405e:	44670713          	addi	a4,a4,1094 # ffffffffc02114a0 <pages>
ffffffffc0204062:	6310                	ld	a2,0(a4)
ffffffffc0204064:	00001717          	auipc	a4,0x1
ffffffffc0204068:	f8470713          	addi	a4,a4,-124 # ffffffffc0204fe8 <commands+0x838>
ffffffffc020406c:	00002697          	auipc	a3,0x2
ffffffffc0204070:	4a468693          	addi	a3,a3,1188 # ffffffffc0206510 <nbase>
ffffffffc0204074:	40c58633          	sub	a2,a1,a2
ffffffffc0204078:	630c                	ld	a1,0(a4)
ffffffffc020407a:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020407c:	0000d717          	auipc	a4,0xd
ffffffffc0204080:	3e470713          	addi	a4,a4,996 # ffffffffc0211460 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0204084:	02b60633          	mul	a2,a2,a1
ffffffffc0204088:	0037959b          	slliw	a1,a5,0x3
ffffffffc020408c:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020408e:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0204090:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0204092:	57fd                	li	a5,-1
ffffffffc0204094:	83b1                	srli	a5,a5,0xc
ffffffffc0204096:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0204098:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020409a:	02e7fa63          	bleu	a4,a5,ffffffffc02040ce <swapfs_write+0x8c>
ffffffffc020409e:	0000d797          	auipc	a5,0xd
ffffffffc02040a2:	3f278793          	addi	a5,a5,1010 # ffffffffc0211490 <va_pa_offset>
ffffffffc02040a6:	639c                	ld	a5,0(a5)
}
ffffffffc02040a8:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040aa:	46a1                	li	a3,8
ffffffffc02040ac:	963e                	add	a2,a2,a5
ffffffffc02040ae:	4505                	li	a0,1
}
ffffffffc02040b0:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc02040b2:	b54fc06f          	j	ffffffffc0200406 <ide_write_secs>
ffffffffc02040b6:	86aa                	mv	a3,a0
ffffffffc02040b8:	00002617          	auipc	a2,0x2
ffffffffc02040bc:	1f060613          	addi	a2,a2,496 # ffffffffc02062a8 <default_pmm_manager+0x228>
ffffffffc02040c0:	45e5                	li	a1,25
ffffffffc02040c2:	00002517          	auipc	a0,0x2
ffffffffc02040c6:	1ce50513          	addi	a0,a0,462 # ffffffffc0206290 <default_pmm_manager+0x210>
ffffffffc02040ca:	83cfc0ef          	jal	ra,ffffffffc0200106 <__panic>
ffffffffc02040ce:	86b2                	mv	a3,a2
ffffffffc02040d0:	06a00593          	li	a1,106
ffffffffc02040d4:	00001617          	auipc	a2,0x1
ffffffffc02040d8:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204ff0 <commands+0x840>
ffffffffc02040dc:	00001517          	auipc	a0,0x1
ffffffffc02040e0:	fac50513          	addi	a0,a0,-84 # ffffffffc0205088 <commands+0x8d8>
ffffffffc02040e4:	822fc0ef          	jal	ra,ffffffffc0200106 <__panic>

ffffffffc02040e8 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02040e8:	00054783          	lbu	a5,0(a0)
ffffffffc02040ec:	cb91                	beqz	a5,ffffffffc0204100 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02040ee:	4781                	li	a5,0
        cnt ++;
ffffffffc02040f0:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02040f2:	00f50733          	add	a4,a0,a5
ffffffffc02040f6:	00074703          	lbu	a4,0(a4)
ffffffffc02040fa:	fb7d                	bnez	a4,ffffffffc02040f0 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02040fc:	853e                	mv	a0,a5
ffffffffc02040fe:	8082                	ret
    size_t cnt = 0;
ffffffffc0204100:	4781                	li	a5,0
}
ffffffffc0204102:	853e                	mv	a0,a5
ffffffffc0204104:	8082                	ret

ffffffffc0204106 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204106:	c185                	beqz	a1,ffffffffc0204126 <strnlen+0x20>
ffffffffc0204108:	00054783          	lbu	a5,0(a0)
ffffffffc020410c:	cf89                	beqz	a5,ffffffffc0204126 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020410e:	4781                	li	a5,0
ffffffffc0204110:	a021                	j	ffffffffc0204118 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204112:	00074703          	lbu	a4,0(a4)
ffffffffc0204116:	c711                	beqz	a4,ffffffffc0204122 <strnlen+0x1c>
        cnt ++;
ffffffffc0204118:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020411a:	00f50733          	add	a4,a0,a5
ffffffffc020411e:	fef59ae3          	bne	a1,a5,ffffffffc0204112 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204122:	853e                	mv	a0,a5
ffffffffc0204124:	8082                	ret
    size_t cnt = 0;
ffffffffc0204126:	4781                	li	a5,0
}
ffffffffc0204128:	853e                	mv	a0,a5
ffffffffc020412a:	8082                	ret

ffffffffc020412c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020412c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020412e:	0585                	addi	a1,a1,1
ffffffffc0204130:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204134:	0785                	addi	a5,a5,1
ffffffffc0204136:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020413a:	fb75                	bnez	a4,ffffffffc020412e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020413c:	8082                	ret

ffffffffc020413e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020413e:	00054783          	lbu	a5,0(a0)
ffffffffc0204142:	0005c703          	lbu	a4,0(a1)
ffffffffc0204146:	cb91                	beqz	a5,ffffffffc020415a <strcmp+0x1c>
ffffffffc0204148:	00e79c63          	bne	a5,a4,ffffffffc0204160 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020414c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020414e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204152:	0585                	addi	a1,a1,1
ffffffffc0204154:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204158:	fbe5                	bnez	a5,ffffffffc0204148 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020415a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020415c:	9d19                	subw	a0,a0,a4
ffffffffc020415e:	8082                	ret
ffffffffc0204160:	0007851b          	sext.w	a0,a5
ffffffffc0204164:	9d19                	subw	a0,a0,a4
ffffffffc0204166:	8082                	ret

ffffffffc0204168 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204168:	00054783          	lbu	a5,0(a0)
ffffffffc020416c:	cb91                	beqz	a5,ffffffffc0204180 <strchr+0x18>
        if (*s == c) {
ffffffffc020416e:	00b79563          	bne	a5,a1,ffffffffc0204178 <strchr+0x10>
ffffffffc0204172:	a809                	j	ffffffffc0204184 <strchr+0x1c>
ffffffffc0204174:	00b78763          	beq	a5,a1,ffffffffc0204182 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204178:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020417a:	00054783          	lbu	a5,0(a0)
ffffffffc020417e:	fbfd                	bnez	a5,ffffffffc0204174 <strchr+0xc>
    }
    return NULL;
ffffffffc0204180:	4501                	li	a0,0
}
ffffffffc0204182:	8082                	ret
ffffffffc0204184:	8082                	ret

ffffffffc0204186 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204186:	ca01                	beqz	a2,ffffffffc0204196 <memset+0x10>
ffffffffc0204188:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020418a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020418c:	0785                	addi	a5,a5,1
ffffffffc020418e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204192:	fec79de3          	bne	a5,a2,ffffffffc020418c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204196:	8082                	ret

ffffffffc0204198 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204198:	ca19                	beqz	a2,ffffffffc02041ae <memcpy+0x16>
ffffffffc020419a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020419c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020419e:	0585                	addi	a1,a1,1
ffffffffc02041a0:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02041a4:	0785                	addi	a5,a5,1
ffffffffc02041a6:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02041aa:	fec59ae3          	bne	a1,a2,ffffffffc020419e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02041ae:	8082                	ret

ffffffffc02041b0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02041b0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02041b4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02041b6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02041ba:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02041bc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02041c0:	f022                	sd	s0,32(sp)
ffffffffc02041c2:	ec26                	sd	s1,24(sp)
ffffffffc02041c4:	e84a                	sd	s2,16(sp)
ffffffffc02041c6:	f406                	sd	ra,40(sp)
ffffffffc02041c8:	e44e                	sd	s3,8(sp)
ffffffffc02041ca:	84aa                	mv	s1,a0
ffffffffc02041cc:	892e                	mv	s2,a1
ffffffffc02041ce:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02041d2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02041d4:	03067e63          	bleu	a6,a2,ffffffffc0204210 <printnum+0x60>
ffffffffc02041d8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02041da:	00805763          	blez	s0,ffffffffc02041e8 <printnum+0x38>
ffffffffc02041de:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02041e0:	85ca                	mv	a1,s2
ffffffffc02041e2:	854e                	mv	a0,s3
ffffffffc02041e4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02041e6:	fc65                	bnez	s0,ffffffffc02041de <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041e8:	1a02                	slli	s4,s4,0x20
ffffffffc02041ea:	020a5a13          	srli	s4,s4,0x20
ffffffffc02041ee:	00002797          	auipc	a5,0x2
ffffffffc02041f2:	26a78793          	addi	a5,a5,618 # ffffffffc0206458 <error_string+0x38>
ffffffffc02041f6:	9a3e                	add	s4,s4,a5
}
ffffffffc02041f8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02041fa:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02041fe:	70a2                	ld	ra,40(sp)
ffffffffc0204200:	69a2                	ld	s3,8(sp)
ffffffffc0204202:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204204:	85ca                	mv	a1,s2
ffffffffc0204206:	8326                	mv	t1,s1
}
ffffffffc0204208:	6942                	ld	s2,16(sp)
ffffffffc020420a:	64e2                	ld	s1,24(sp)
ffffffffc020420c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020420e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204210:	03065633          	divu	a2,a2,a6
ffffffffc0204214:	8722                	mv	a4,s0
ffffffffc0204216:	f9bff0ef          	jal	ra,ffffffffc02041b0 <printnum>
ffffffffc020421a:	b7f9                	j	ffffffffc02041e8 <printnum+0x38>

ffffffffc020421c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020421c:	7119                	addi	sp,sp,-128
ffffffffc020421e:	f4a6                	sd	s1,104(sp)
ffffffffc0204220:	f0ca                	sd	s2,96(sp)
ffffffffc0204222:	e8d2                	sd	s4,80(sp)
ffffffffc0204224:	e4d6                	sd	s5,72(sp)
ffffffffc0204226:	e0da                	sd	s6,64(sp)
ffffffffc0204228:	fc5e                	sd	s7,56(sp)
ffffffffc020422a:	f862                	sd	s8,48(sp)
ffffffffc020422c:	f06a                	sd	s10,32(sp)
ffffffffc020422e:	fc86                	sd	ra,120(sp)
ffffffffc0204230:	f8a2                	sd	s0,112(sp)
ffffffffc0204232:	ecce                	sd	s3,88(sp)
ffffffffc0204234:	f466                	sd	s9,40(sp)
ffffffffc0204236:	ec6e                	sd	s11,24(sp)
ffffffffc0204238:	892a                	mv	s2,a0
ffffffffc020423a:	84ae                	mv	s1,a1
ffffffffc020423c:	8d32                	mv	s10,a2
ffffffffc020423e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204240:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204242:	00002a17          	auipc	s4,0x2
ffffffffc0204246:	086a0a13          	addi	s4,s4,134 # ffffffffc02062c8 <default_pmm_manager+0x248>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020424a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020424e:	00002c17          	auipc	s8,0x2
ffffffffc0204252:	1d2c0c13          	addi	s8,s8,466 # ffffffffc0206420 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204256:	000d4503          	lbu	a0,0(s10)
ffffffffc020425a:	02500793          	li	a5,37
ffffffffc020425e:	001d0413          	addi	s0,s10,1
ffffffffc0204262:	00f50e63          	beq	a0,a5,ffffffffc020427e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204266:	c521                	beqz	a0,ffffffffc02042ae <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204268:	02500993          	li	s3,37
ffffffffc020426c:	a011                	j	ffffffffc0204270 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020426e:	c121                	beqz	a0,ffffffffc02042ae <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0204270:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204272:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204274:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204276:	fff44503          	lbu	a0,-1(s0)
ffffffffc020427a:	ff351ae3          	bne	a0,s3,ffffffffc020426e <vprintfmt+0x52>
ffffffffc020427e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204282:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204286:	4981                	li	s3,0
ffffffffc0204288:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020428a:	5cfd                	li	s9,-1
ffffffffc020428c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020428e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0204292:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204294:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204298:	0ff6f693          	andi	a3,a3,255
ffffffffc020429c:	00140d13          	addi	s10,s0,1
ffffffffc02042a0:	20d5e563          	bltu	a1,a3,ffffffffc02044aa <vprintfmt+0x28e>
ffffffffc02042a4:	068a                	slli	a3,a3,0x2
ffffffffc02042a6:	96d2                	add	a3,a3,s4
ffffffffc02042a8:	4294                	lw	a3,0(a3)
ffffffffc02042aa:	96d2                	add	a3,a3,s4
ffffffffc02042ac:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02042ae:	70e6                	ld	ra,120(sp)
ffffffffc02042b0:	7446                	ld	s0,112(sp)
ffffffffc02042b2:	74a6                	ld	s1,104(sp)
ffffffffc02042b4:	7906                	ld	s2,96(sp)
ffffffffc02042b6:	69e6                	ld	s3,88(sp)
ffffffffc02042b8:	6a46                	ld	s4,80(sp)
ffffffffc02042ba:	6aa6                	ld	s5,72(sp)
ffffffffc02042bc:	6b06                	ld	s6,64(sp)
ffffffffc02042be:	7be2                	ld	s7,56(sp)
ffffffffc02042c0:	7c42                	ld	s8,48(sp)
ffffffffc02042c2:	7ca2                	ld	s9,40(sp)
ffffffffc02042c4:	7d02                	ld	s10,32(sp)
ffffffffc02042c6:	6de2                	ld	s11,24(sp)
ffffffffc02042c8:	6109                	addi	sp,sp,128
ffffffffc02042ca:	8082                	ret
    if (lflag >= 2) {
ffffffffc02042cc:	4705                	li	a4,1
ffffffffc02042ce:	008a8593          	addi	a1,s5,8
ffffffffc02042d2:	01074463          	blt	a4,a6,ffffffffc02042da <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02042d6:	26080363          	beqz	a6,ffffffffc020453c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02042da:	000ab603          	ld	a2,0(s5)
ffffffffc02042de:	46c1                	li	a3,16
ffffffffc02042e0:	8aae                	mv	s5,a1
ffffffffc02042e2:	a06d                	j	ffffffffc020438c <vprintfmt+0x170>
            goto reswitch;
ffffffffc02042e4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02042e8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02042ea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02042ec:	b765                	j	ffffffffc0204294 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02042ee:	000aa503          	lw	a0,0(s5)
ffffffffc02042f2:	85a6                	mv	a1,s1
ffffffffc02042f4:	0aa1                	addi	s5,s5,8
ffffffffc02042f6:	9902                	jalr	s2
            break;
ffffffffc02042f8:	bfb9                	j	ffffffffc0204256 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02042fa:	4705                	li	a4,1
ffffffffc02042fc:	008a8993          	addi	s3,s5,8
ffffffffc0204300:	01074463          	blt	a4,a6,ffffffffc0204308 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0204304:	22080463          	beqz	a6,ffffffffc020452c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0204308:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020430c:	24044463          	bltz	s0,ffffffffc0204554 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0204310:	8622                	mv	a2,s0
ffffffffc0204312:	8ace                	mv	s5,s3
ffffffffc0204314:	46a9                	li	a3,10
ffffffffc0204316:	a89d                	j	ffffffffc020438c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0204318:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020431c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020431e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0204320:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204324:	8fb5                	xor	a5,a5,a3
ffffffffc0204326:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020432a:	1ad74363          	blt	a4,a3,ffffffffc02044d0 <vprintfmt+0x2b4>
ffffffffc020432e:	00369793          	slli	a5,a3,0x3
ffffffffc0204332:	97e2                	add	a5,a5,s8
ffffffffc0204334:	639c                	ld	a5,0(a5)
ffffffffc0204336:	18078d63          	beqz	a5,ffffffffc02044d0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020433a:	86be                	mv	a3,a5
ffffffffc020433c:	00002617          	auipc	a2,0x2
ffffffffc0204340:	1cc60613          	addi	a2,a2,460 # ffffffffc0206508 <error_string+0xe8>
ffffffffc0204344:	85a6                	mv	a1,s1
ffffffffc0204346:	854a                	mv	a0,s2
ffffffffc0204348:	240000ef          	jal	ra,ffffffffc0204588 <printfmt>
ffffffffc020434c:	b729                	j	ffffffffc0204256 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020434e:	00144603          	lbu	a2,1(s0)
ffffffffc0204352:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204354:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204356:	bf3d                	j	ffffffffc0204294 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204358:	4705                	li	a4,1
ffffffffc020435a:	008a8593          	addi	a1,s5,8
ffffffffc020435e:	01074463          	blt	a4,a6,ffffffffc0204366 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204362:	1e080263          	beqz	a6,ffffffffc0204546 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204366:	000ab603          	ld	a2,0(s5)
ffffffffc020436a:	46a1                	li	a3,8
ffffffffc020436c:	8aae                	mv	s5,a1
ffffffffc020436e:	a839                	j	ffffffffc020438c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204370:	03000513          	li	a0,48
ffffffffc0204374:	85a6                	mv	a1,s1
ffffffffc0204376:	e03e                	sd	a5,0(sp)
ffffffffc0204378:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020437a:	85a6                	mv	a1,s1
ffffffffc020437c:	07800513          	li	a0,120
ffffffffc0204380:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204382:	0aa1                	addi	s5,s5,8
ffffffffc0204384:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204388:	6782                	ld	a5,0(sp)
ffffffffc020438a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020438c:	876e                	mv	a4,s11
ffffffffc020438e:	85a6                	mv	a1,s1
ffffffffc0204390:	854a                	mv	a0,s2
ffffffffc0204392:	e1fff0ef          	jal	ra,ffffffffc02041b0 <printnum>
            break;
ffffffffc0204396:	b5c1                	j	ffffffffc0204256 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204398:	000ab603          	ld	a2,0(s5)
ffffffffc020439c:	0aa1                	addi	s5,s5,8
ffffffffc020439e:	1c060663          	beqz	a2,ffffffffc020456a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02043a2:	00160413          	addi	s0,a2,1
ffffffffc02043a6:	17b05c63          	blez	s11,ffffffffc020451e <vprintfmt+0x302>
ffffffffc02043aa:	02d00593          	li	a1,45
ffffffffc02043ae:	14b79263          	bne	a5,a1,ffffffffc02044f2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043b2:	00064783          	lbu	a5,0(a2)
ffffffffc02043b6:	0007851b          	sext.w	a0,a5
ffffffffc02043ba:	c905                	beqz	a0,ffffffffc02043ea <vprintfmt+0x1ce>
ffffffffc02043bc:	000cc563          	bltz	s9,ffffffffc02043c6 <vprintfmt+0x1aa>
ffffffffc02043c0:	3cfd                	addiw	s9,s9,-1
ffffffffc02043c2:	036c8263          	beq	s9,s6,ffffffffc02043e6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02043c6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02043c8:	18098463          	beqz	s3,ffffffffc0204550 <vprintfmt+0x334>
ffffffffc02043cc:	3781                	addiw	a5,a5,-32
ffffffffc02043ce:	18fbf163          	bleu	a5,s7,ffffffffc0204550 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02043d2:	03f00513          	li	a0,63
ffffffffc02043d6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043d8:	0405                	addi	s0,s0,1
ffffffffc02043da:	fff44783          	lbu	a5,-1(s0)
ffffffffc02043de:	3dfd                	addiw	s11,s11,-1
ffffffffc02043e0:	0007851b          	sext.w	a0,a5
ffffffffc02043e4:	fd61                	bnez	a0,ffffffffc02043bc <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02043e6:	e7b058e3          	blez	s11,ffffffffc0204256 <vprintfmt+0x3a>
ffffffffc02043ea:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02043ec:	85a6                	mv	a1,s1
ffffffffc02043ee:	02000513          	li	a0,32
ffffffffc02043f2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02043f4:	e60d81e3          	beqz	s11,ffffffffc0204256 <vprintfmt+0x3a>
ffffffffc02043f8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02043fa:	85a6                	mv	a1,s1
ffffffffc02043fc:	02000513          	li	a0,32
ffffffffc0204400:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204402:	fe0d94e3          	bnez	s11,ffffffffc02043ea <vprintfmt+0x1ce>
ffffffffc0204406:	bd81                	j	ffffffffc0204256 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204408:	4705                	li	a4,1
ffffffffc020440a:	008a8593          	addi	a1,s5,8
ffffffffc020440e:	01074463          	blt	a4,a6,ffffffffc0204416 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204412:	12080063          	beqz	a6,ffffffffc0204532 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204416:	000ab603          	ld	a2,0(s5)
ffffffffc020441a:	46a9                	li	a3,10
ffffffffc020441c:	8aae                	mv	s5,a1
ffffffffc020441e:	b7bd                	j	ffffffffc020438c <vprintfmt+0x170>
ffffffffc0204420:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204424:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204428:	846a                	mv	s0,s10
ffffffffc020442a:	b5ad                	j	ffffffffc0204294 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020442c:	85a6                	mv	a1,s1
ffffffffc020442e:	02500513          	li	a0,37
ffffffffc0204432:	9902                	jalr	s2
            break;
ffffffffc0204434:	b50d                	j	ffffffffc0204256 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204436:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020443a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020443e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204440:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204442:	e40dd9e3          	bgez	s11,ffffffffc0204294 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204446:	8de6                	mv	s11,s9
ffffffffc0204448:	5cfd                	li	s9,-1
ffffffffc020444a:	b5a9                	j	ffffffffc0204294 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020444c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204450:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204454:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204456:	bd3d                	j	ffffffffc0204294 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204458:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020445c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204460:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204462:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204466:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020446a:	fcd56ce3          	bltu	a0,a3,ffffffffc0204442 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020446e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204470:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204474:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204478:	0196873b          	addw	a4,a3,s9
ffffffffc020447c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204480:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204484:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204488:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020448c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204490:	fcd57fe3          	bleu	a3,a0,ffffffffc020446e <vprintfmt+0x252>
ffffffffc0204494:	b77d                	j	ffffffffc0204442 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204496:	fffdc693          	not	a3,s11
ffffffffc020449a:	96fd                	srai	a3,a3,0x3f
ffffffffc020449c:	00ddfdb3          	and	s11,s11,a3
ffffffffc02044a0:	00144603          	lbu	a2,1(s0)
ffffffffc02044a4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02044a6:	846a                	mv	s0,s10
ffffffffc02044a8:	b3f5                	j	ffffffffc0204294 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02044aa:	85a6                	mv	a1,s1
ffffffffc02044ac:	02500513          	li	a0,37
ffffffffc02044b0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02044b2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02044b6:	02500793          	li	a5,37
ffffffffc02044ba:	8d22                	mv	s10,s0
ffffffffc02044bc:	d8f70de3          	beq	a4,a5,ffffffffc0204256 <vprintfmt+0x3a>
ffffffffc02044c0:	02500713          	li	a4,37
ffffffffc02044c4:	1d7d                	addi	s10,s10,-1
ffffffffc02044c6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02044ca:	fee79de3          	bne	a5,a4,ffffffffc02044c4 <vprintfmt+0x2a8>
ffffffffc02044ce:	b361                	j	ffffffffc0204256 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02044d0:	00002617          	auipc	a2,0x2
ffffffffc02044d4:	02860613          	addi	a2,a2,40 # ffffffffc02064f8 <error_string+0xd8>
ffffffffc02044d8:	85a6                	mv	a1,s1
ffffffffc02044da:	854a                	mv	a0,s2
ffffffffc02044dc:	0ac000ef          	jal	ra,ffffffffc0204588 <printfmt>
ffffffffc02044e0:	bb9d                	j	ffffffffc0204256 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02044e2:	00002617          	auipc	a2,0x2
ffffffffc02044e6:	00e60613          	addi	a2,a2,14 # ffffffffc02064f0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02044ea:	00002417          	auipc	s0,0x2
ffffffffc02044ee:	00740413          	addi	s0,s0,7 # ffffffffc02064f1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02044f2:	8532                	mv	a0,a2
ffffffffc02044f4:	85e6                	mv	a1,s9
ffffffffc02044f6:	e032                	sd	a2,0(sp)
ffffffffc02044f8:	e43e                	sd	a5,8(sp)
ffffffffc02044fa:	c0dff0ef          	jal	ra,ffffffffc0204106 <strnlen>
ffffffffc02044fe:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204502:	6602                	ld	a2,0(sp)
ffffffffc0204504:	01b05d63          	blez	s11,ffffffffc020451e <vprintfmt+0x302>
ffffffffc0204508:	67a2                	ld	a5,8(sp)
ffffffffc020450a:	2781                	sext.w	a5,a5
ffffffffc020450c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020450e:	6522                	ld	a0,8(sp)
ffffffffc0204510:	85a6                	mv	a1,s1
ffffffffc0204512:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204514:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204516:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204518:	6602                	ld	a2,0(sp)
ffffffffc020451a:	fe0d9ae3          	bnez	s11,ffffffffc020450e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020451e:	00064783          	lbu	a5,0(a2)
ffffffffc0204522:	0007851b          	sext.w	a0,a5
ffffffffc0204526:	e8051be3          	bnez	a0,ffffffffc02043bc <vprintfmt+0x1a0>
ffffffffc020452a:	b335                	j	ffffffffc0204256 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020452c:	000aa403          	lw	s0,0(s5)
ffffffffc0204530:	bbf1                	j	ffffffffc020430c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204532:	000ae603          	lwu	a2,0(s5)
ffffffffc0204536:	46a9                	li	a3,10
ffffffffc0204538:	8aae                	mv	s5,a1
ffffffffc020453a:	bd89                	j	ffffffffc020438c <vprintfmt+0x170>
ffffffffc020453c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204540:	46c1                	li	a3,16
ffffffffc0204542:	8aae                	mv	s5,a1
ffffffffc0204544:	b5a1                	j	ffffffffc020438c <vprintfmt+0x170>
ffffffffc0204546:	000ae603          	lwu	a2,0(s5)
ffffffffc020454a:	46a1                	li	a3,8
ffffffffc020454c:	8aae                	mv	s5,a1
ffffffffc020454e:	bd3d                	j	ffffffffc020438c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204550:	9902                	jalr	s2
ffffffffc0204552:	b559                	j	ffffffffc02043d8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204554:	85a6                	mv	a1,s1
ffffffffc0204556:	02d00513          	li	a0,45
ffffffffc020455a:	e03e                	sd	a5,0(sp)
ffffffffc020455c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020455e:	8ace                	mv	s5,s3
ffffffffc0204560:	40800633          	neg	a2,s0
ffffffffc0204564:	46a9                	li	a3,10
ffffffffc0204566:	6782                	ld	a5,0(sp)
ffffffffc0204568:	b515                	j	ffffffffc020438c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020456a:	01b05663          	blez	s11,ffffffffc0204576 <vprintfmt+0x35a>
ffffffffc020456e:	02d00693          	li	a3,45
ffffffffc0204572:	f6d798e3          	bne	a5,a3,ffffffffc02044e2 <vprintfmt+0x2c6>
ffffffffc0204576:	00002417          	auipc	s0,0x2
ffffffffc020457a:	f7b40413          	addi	s0,s0,-133 # ffffffffc02064f1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020457e:	02800513          	li	a0,40
ffffffffc0204582:	02800793          	li	a5,40
ffffffffc0204586:	bd1d                	j	ffffffffc02043bc <vprintfmt+0x1a0>

ffffffffc0204588 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204588:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020458a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020458e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204590:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204592:	ec06                	sd	ra,24(sp)
ffffffffc0204594:	f83a                	sd	a4,48(sp)
ffffffffc0204596:	fc3e                	sd	a5,56(sp)
ffffffffc0204598:	e0c2                	sd	a6,64(sp)
ffffffffc020459a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020459c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020459e:	c7fff0ef          	jal	ra,ffffffffc020421c <vprintfmt>
}
ffffffffc02045a2:	60e2                	ld	ra,24(sp)
ffffffffc02045a4:	6161                	addi	sp,sp,80
ffffffffc02045a6:	8082                	ret

ffffffffc02045a8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02045a8:	715d                	addi	sp,sp,-80
ffffffffc02045aa:	e486                	sd	ra,72(sp)
ffffffffc02045ac:	e0a2                	sd	s0,64(sp)
ffffffffc02045ae:	fc26                	sd	s1,56(sp)
ffffffffc02045b0:	f84a                	sd	s2,48(sp)
ffffffffc02045b2:	f44e                	sd	s3,40(sp)
ffffffffc02045b4:	f052                	sd	s4,32(sp)
ffffffffc02045b6:	ec56                	sd	s5,24(sp)
ffffffffc02045b8:	e85a                	sd	s6,16(sp)
ffffffffc02045ba:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02045bc:	c901                	beqz	a0,ffffffffc02045cc <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02045be:	85aa                	mv	a1,a0
ffffffffc02045c0:	00002517          	auipc	a0,0x2
ffffffffc02045c4:	f4850513          	addi	a0,a0,-184 # ffffffffc0206508 <error_string+0xe8>
ffffffffc02045c8:	af7fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02045cc:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045ce:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02045d0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02045d2:	4aa9                	li	s5,10
ffffffffc02045d4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02045d6:	0000db97          	auipc	s7,0xd
ffffffffc02045da:	a72b8b93          	addi	s7,s7,-1422 # ffffffffc0211048 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045de:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02045e2:	b15fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02045e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02045e8:	00054b63          	bltz	a0,ffffffffc02045fe <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02045ec:	00a95b63          	ble	a0,s2,ffffffffc0204602 <readline+0x5a>
ffffffffc02045f0:	029a5463          	ble	s1,s4,ffffffffc0204618 <readline+0x70>
        c = getchar();
ffffffffc02045f4:	b03fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02045f8:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02045fa:	fe0559e3          	bgez	a0,ffffffffc02045ec <readline+0x44>
            return NULL;
ffffffffc02045fe:	4501                	li	a0,0
ffffffffc0204600:	a099                	j	ffffffffc0204646 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204602:	03341463          	bne	s0,s3,ffffffffc020462a <readline+0x82>
ffffffffc0204606:	e8b9                	bnez	s1,ffffffffc020465c <readline+0xb4>
        c = getchar();
ffffffffc0204608:	aeffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020460c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020460e:	fe0548e3          	bltz	a0,ffffffffc02045fe <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204612:	fea958e3          	ble	a0,s2,ffffffffc0204602 <readline+0x5a>
ffffffffc0204616:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204618:	8522                	mv	a0,s0
ffffffffc020461a:	ad9fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020461e:	009b87b3          	add	a5,s7,s1
ffffffffc0204622:	00878023          	sb	s0,0(a5)
ffffffffc0204626:	2485                	addiw	s1,s1,1
ffffffffc0204628:	bf6d                	j	ffffffffc02045e2 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020462a:	01540463          	beq	s0,s5,ffffffffc0204632 <readline+0x8a>
ffffffffc020462e:	fb641ae3          	bne	s0,s6,ffffffffc02045e2 <readline+0x3a>
            cputchar(c);
ffffffffc0204632:	8522                	mv	a0,s0
ffffffffc0204634:	abffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204638:	0000d517          	auipc	a0,0xd
ffffffffc020463c:	a1050513          	addi	a0,a0,-1520 # ffffffffc0211048 <buf>
ffffffffc0204640:	94aa                	add	s1,s1,a0
ffffffffc0204642:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204646:	60a6                	ld	ra,72(sp)
ffffffffc0204648:	6406                	ld	s0,64(sp)
ffffffffc020464a:	74e2                	ld	s1,56(sp)
ffffffffc020464c:	7942                	ld	s2,48(sp)
ffffffffc020464e:	79a2                	ld	s3,40(sp)
ffffffffc0204650:	7a02                	ld	s4,32(sp)
ffffffffc0204652:	6ae2                	ld	s5,24(sp)
ffffffffc0204654:	6b42                	ld	s6,16(sp)
ffffffffc0204656:	6ba2                	ld	s7,8(sp)
ffffffffc0204658:	6161                	addi	sp,sp,80
ffffffffc020465a:	8082                	ret
            cputchar(c);
ffffffffc020465c:	4521                	li	a0,8
ffffffffc020465e:	a95fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204662:	34fd                	addiw	s1,s1,-1
ffffffffc0204664:	bfbd                	j	ffffffffc02045e2 <readline+0x3a>
