
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
ffffffffc020004e:	22a010ef          	jal	ra,ffffffffc0201278 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	74250513          	addi	a0,a0,1858 # ffffffffc0201798 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	13c000ef          	jal	ra,ffffffffc020019e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	7f3000ef          	jal	ra,ffffffffc020105c <pmm_init>

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
ffffffffc02000aa:	24c010ef          	jal	ra,ffffffffc02012f6 <vprintfmt>
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
ffffffffc02000de:	218010ef          	jal	ra,ffffffffc02012f6 <vprintfmt>
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
ffffffffc0200170:	00001517          	auipc	a0,0x1
ffffffffc0200174:	64850513          	addi	a0,a0,1608 # ffffffffc02017b8 <etext+0x22>
    va_start(ap, fmt);
ffffffffc0200178:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020017a:	f3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020017e:	65a2                	ld	a1,8(sp)
ffffffffc0200180:	8522                	mv	a0,s0
ffffffffc0200182:	f15ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc0200186:	00001517          	auipc	a0,0x1
ffffffffc020018a:	74a50513          	addi	a0,a0,1866 # ffffffffc02018d0 <etext+0x13a>
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
ffffffffc02001a0:	00001517          	auipc	a0,0x1
ffffffffc02001a4:	66850513          	addi	a0,a0,1640 # ffffffffc0201808 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	e8858593          	addi	a1,a1,-376 # ffffffffc0200036 <kern_init>
ffffffffc02001b6:	00001517          	auipc	a0,0x1
ffffffffc02001ba:	67250513          	addi	a0,a0,1650 # ffffffffc0201828 <etext+0x92>
ffffffffc02001be:	ef9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00001597          	auipc	a1,0x1
ffffffffc02001c6:	5d458593          	addi	a1,a1,1492 # ffffffffc0201796 <etext>
ffffffffc02001ca:	00001517          	auipc	a0,0x1
ffffffffc02001ce:	67e50513          	addi	a0,a0,1662 # ffffffffc0201848 <etext+0xb2>
ffffffffc02001d2:	ee5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00006597          	auipc	a1,0x6
ffffffffc02001da:	e3a58593          	addi	a1,a1,-454 # ffffffffc0206010 <edata>
ffffffffc02001de:	00001517          	auipc	a0,0x1
ffffffffc02001e2:	68a50513          	addi	a0,a0,1674 # ffffffffc0201868 <etext+0xd2>
ffffffffc02001e6:	ed1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00006597          	auipc	a1,0x6
ffffffffc02001ee:	28658593          	addi	a1,a1,646 # ffffffffc0206470 <end>
ffffffffc02001f2:	00001517          	auipc	a0,0x1
ffffffffc02001f6:	69650513          	addi	a0,a0,1686 # ffffffffc0201888 <etext+0xf2>
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
ffffffffc0200220:	00001517          	auipc	a0,0x1
ffffffffc0200224:	68850513          	addi	a0,a0,1672 # ffffffffc02018a8 <etext+0x112>
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
ffffffffc0200230:	00001617          	auipc	a2,0x1
ffffffffc0200234:	5a860613          	addi	a2,a2,1448 # ffffffffc02017d8 <etext+0x42>
ffffffffc0200238:	04e00593          	li	a1,78
ffffffffc020023c:	00001517          	auipc	a0,0x1
ffffffffc0200240:	5b450513          	addi	a0,a0,1460 # ffffffffc02017f0 <etext+0x5a>
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
ffffffffc020024c:	00001617          	auipc	a2,0x1
ffffffffc0200250:	76c60613          	addi	a2,a2,1900 # ffffffffc02019b8 <commands+0xe0>
ffffffffc0200254:	00001597          	auipc	a1,0x1
ffffffffc0200258:	78458593          	addi	a1,a1,1924 # ffffffffc02019d8 <commands+0x100>
ffffffffc020025c:	00001517          	auipc	a0,0x1
ffffffffc0200260:	78450513          	addi	a0,a0,1924 # ffffffffc02019e0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200264:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200266:	e51ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020026a:	00001617          	auipc	a2,0x1
ffffffffc020026e:	78660613          	addi	a2,a2,1926 # ffffffffc02019f0 <commands+0x118>
ffffffffc0200272:	00001597          	auipc	a1,0x1
ffffffffc0200276:	7a658593          	addi	a1,a1,1958 # ffffffffc0201a18 <commands+0x140>
ffffffffc020027a:	00001517          	auipc	a0,0x1
ffffffffc020027e:	76650513          	addi	a0,a0,1894 # ffffffffc02019e0 <commands+0x108>
ffffffffc0200282:	e35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200286:	00001617          	auipc	a2,0x1
ffffffffc020028a:	7a260613          	addi	a2,a2,1954 # ffffffffc0201a28 <commands+0x150>
ffffffffc020028e:	00001597          	auipc	a1,0x1
ffffffffc0200292:	7ba58593          	addi	a1,a1,1978 # ffffffffc0201a48 <commands+0x170>
ffffffffc0200296:	00001517          	auipc	a0,0x1
ffffffffc020029a:	74a50513          	addi	a0,a0,1866 # ffffffffc02019e0 <commands+0x108>
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
ffffffffc02002d0:	00001517          	auipc	a0,0x1
ffffffffc02002d4:	65050513          	addi	a0,a0,1616 # ffffffffc0201920 <commands+0x48>
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
ffffffffc02002f2:	00001517          	auipc	a0,0x1
ffffffffc02002f6:	65650513          	addi	a0,a0,1622 # ffffffffc0201948 <commands+0x70>
ffffffffc02002fa:	dbdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc02002fe:	000c0563          	beqz	s8,ffffffffc0200308 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200302:	8562                	mv	a0,s8
ffffffffc0200304:	346000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc0200308:	00001c97          	auipc	s9,0x1
ffffffffc020030c:	5d0c8c93          	addi	s9,s9,1488 # ffffffffc02018d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200310:	00001997          	auipc	s3,0x1
ffffffffc0200314:	66098993          	addi	s3,s3,1632 # ffffffffc0201970 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200318:	00001917          	auipc	s2,0x1
ffffffffc020031c:	66090913          	addi	s2,s2,1632 # ffffffffc0201978 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200320:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200322:	00001b17          	auipc	s6,0x1
ffffffffc0200326:	65eb0b13          	addi	s6,s6,1630 # ffffffffc0201980 <commands+0xa8>
    if (argc == 0) {
ffffffffc020032a:	00001a97          	auipc	s5,0x1
ffffffffc020032e:	6aea8a93          	addi	s5,s5,1710 # ffffffffc02019d8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200332:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200334:	854e                	mv	a0,s3
ffffffffc0200336:	34c010ef          	jal	ra,ffffffffc0201682 <readline>
ffffffffc020033a:	842a                	mv	s0,a0
ffffffffc020033c:	dd65                	beqz	a0,ffffffffc0200334 <kmonitor+0x6a>
ffffffffc020033e:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200342:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	c999                	beqz	a1,ffffffffc020035a <kmonitor+0x90>
ffffffffc0200346:	854a                	mv	a0,s2
ffffffffc0200348:	713000ef          	jal	ra,ffffffffc020125a <strchr>
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
ffffffffc020035e:	00001d17          	auipc	s10,0x1
ffffffffc0200362:	57ad0d13          	addi	s10,s10,1402 # ffffffffc02018d8 <commands>
    if (argc == 0) {
ffffffffc0200366:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200368:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020036a:	0d61                	addi	s10,s10,24
ffffffffc020036c:	6c5000ef          	jal	ra,ffffffffc0201230 <strcmp>
ffffffffc0200370:	c919                	beqz	a0,ffffffffc0200386 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200372:	2405                	addiw	s0,s0,1
ffffffffc0200374:	09740463          	beq	s0,s7,ffffffffc02003fc <kmonitor+0x132>
ffffffffc0200378:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020037c:	6582                	ld	a1,0(sp)
ffffffffc020037e:	0d61                	addi	s10,s10,24
ffffffffc0200380:	6b1000ef          	jal	ra,ffffffffc0201230 <strcmp>
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
ffffffffc02003e6:	675000ef          	jal	ra,ffffffffc020125a <strchr>
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
ffffffffc02003fe:	00001517          	auipc	a0,0x1
ffffffffc0200402:	5a250513          	addi	a0,a0,1442 # ffffffffc02019a0 <commands+0xc8>
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
ffffffffc0200424:	338010ef          	jal	ra,ffffffffc020175c <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	62650513          	addi	a0,a0,1574 # ffffffffc0201a58 <commands+0x180>
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
ffffffffc020044c:	3100106f          	j	ffffffffc020175c <sbi_set_timer>

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
ffffffffc0200456:	2ea0106f          	j	ffffffffc0201740 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	31e0106f          	j	ffffffffc0201778 <sbi_console_getchar>

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
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	6ec50513          	addi	a0,a0,1772 # ffffffffc0201b70 <commands+0x298>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	6f450513          	addi	a0,a0,1780 # ffffffffc0201b88 <commands+0x2b0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201ba0 <commands+0x2c8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	70850513          	addi	a0,a0,1800 # ffffffffc0201bb8 <commands+0x2e0>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	71250513          	addi	a0,a0,1810 # ffffffffc0201bd0 <commands+0x2f8>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	71c50513          	addi	a0,a0,1820 # ffffffffc0201be8 <commands+0x310>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	72650513          	addi	a0,a0,1830 # ffffffffc0201c00 <commands+0x328>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	73050513          	addi	a0,a0,1840 # ffffffffc0201c18 <commands+0x340>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	73a50513          	addi	a0,a0,1850 # ffffffffc0201c30 <commands+0x358>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	74450513          	addi	a0,a0,1860 # ffffffffc0201c48 <commands+0x370>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	74e50513          	addi	a0,a0,1870 # ffffffffc0201c60 <commands+0x388>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	75850513          	addi	a0,a0,1880 # ffffffffc0201c78 <commands+0x3a0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	76250513          	addi	a0,a0,1890 # ffffffffc0201c90 <commands+0x3b8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	76c50513          	addi	a0,a0,1900 # ffffffffc0201ca8 <commands+0x3d0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	77650513          	addi	a0,a0,1910 # ffffffffc0201cc0 <commands+0x3e8>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	78050513          	addi	a0,a0,1920 # ffffffffc0201cd8 <commands+0x400>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	78a50513          	addi	a0,a0,1930 # ffffffffc0201cf0 <commands+0x418>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	79450513          	addi	a0,a0,1940 # ffffffffc0201d08 <commands+0x430>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	79e50513          	addi	a0,a0,1950 # ffffffffc0201d20 <commands+0x448>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	7a850513          	addi	a0,a0,1960 # ffffffffc0201d38 <commands+0x460>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	7b250513          	addi	a0,a0,1970 # ffffffffc0201d50 <commands+0x478>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	7bc50513          	addi	a0,a0,1980 # ffffffffc0201d68 <commands+0x490>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	7c650513          	addi	a0,a0,1990 # ffffffffc0201d80 <commands+0x4a8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	7d050513          	addi	a0,a0,2000 # ffffffffc0201d98 <commands+0x4c0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	7da50513          	addi	a0,a0,2010 # ffffffffc0201db0 <commands+0x4d8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	7e450513          	addi	a0,a0,2020 # ffffffffc0201dc8 <commands+0x4f0>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	7ee50513          	addi	a0,a0,2030 # ffffffffc0201de0 <commands+0x508>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	7f850513          	addi	a0,a0,2040 # ffffffffc0201df8 <commands+0x520>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	80250513          	addi	a0,a0,-2046 # ffffffffc0201e10 <commands+0x538>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	80c50513          	addi	a0,a0,-2036 # ffffffffc0201e28 <commands+0x550>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	81650513          	addi	a0,a0,-2026 # ffffffffc0201e40 <commands+0x568>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	81c50513          	addi	a0,a0,-2020 # ffffffffc0201e58 <commands+0x580>
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
ffffffffc0200656:	81e50513          	addi	a0,a0,-2018 # ffffffffc0201e70 <commands+0x598>
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
ffffffffc020066e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0201e88 <commands+0x5b0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	82650513          	addi	a0,a0,-2010 # ffffffffc0201ea0 <commands+0x5c8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201eb8 <commands+0x5e0>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	83250513          	addi	a0,a0,-1998 # ffffffffc0201ed0 <commands+0x5f8>
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
ffffffffc02006c0:	3b870713          	addi	a4,a4,952 # ffffffffc0201a74 <commands+0x19c>
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
ffffffffc02006d2:	43a50513          	addi	a0,a0,1082 # ffffffffc0201b08 <commands+0x230>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	40e50513          	addi	a0,a0,1038 # ffffffffc0201ae8 <commands+0x210>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	3c250513          	addi	a0,a0,962 # ffffffffc0201aa8 <commands+0x1d0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	43650513          	addi	a0,a0,1078 # ffffffffc0201b28 <commands+0x250>
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
ffffffffc020072e:	42650513          	addi	a0,a0,1062 # ffffffffc0201b50 <commands+0x278>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	39250513          	addi	a0,a0,914 # ffffffffc0201ac8 <commands+0x1f0>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	3f450513          	addi	a0,a0,1012 # ffffffffc0201b40 <commands+0x268>
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
#define MAX_INIT_PAGES (1 << 14)  // 2^14 = 16384 页

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
ffffffffc0200846:	7179                	addi	sp,sp,-48
ffffffffc0200848:	f022                	sd	s0,32(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084a:	00006417          	auipc	s0,0x6
ffffffffc020084e:	bee40413          	addi	s0,s0,-1042 # ffffffffc0206438 <free_area>
ffffffffc0200852:	641c                	ld	a5,8(s0)
ffffffffc0200854:	f406                	sd	ra,40(sp)
ffffffffc0200856:	ec26                	sd	s1,24(sp)
ffffffffc0200858:	e84a                	sd	s2,16(sp)
ffffffffc020085a:	e44e                	sd	s3,8(sp)
ffffffffc020085c:	e052                	sd	s4,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;

    // 计算当前空闲块数目
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085e:	1e878463          	beq	a5,s0,ffffffffc0200a46 <buddy_system_check+0x200>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200862:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200866:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200868:	8b05                	andi	a4,a4,1
ffffffffc020086a:	24070963          	beqz	a4,ffffffffc0200abc <buddy_system_check+0x276>
    int count = 0, total = 0;
ffffffffc020086e:	4681                	li	a3,0
ffffffffc0200870:	4901                	li	s2,0
ffffffffc0200872:	a031                	j	ffffffffc020087e <buddy_system_check+0x38>
ffffffffc0200874:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200878:	8b09                	andi	a4,a4,2
ffffffffc020087a:	24070163          	beqz	a4,ffffffffc0200abc <buddy_system_check+0x276>
        count ++, total += p->property;
ffffffffc020087e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200882:	679c                	ld	a5,8(a5)
ffffffffc0200884:	2905                	addiw	s2,s2,1
ffffffffc0200886:	9eb9                	addw	a3,a3,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200888:	fe8796e3          	bne	a5,s0,ffffffffc0200874 <buddy_system_check+0x2e>
ffffffffc020088c:	84b6                	mv	s1,a3
    }
    assert(total == nr_free_pages());
ffffffffc020088e:	78e000ef          	jal	ra,ffffffffc020101c <nr_free_pages>
ffffffffc0200892:	24951563          	bne	a0,s1,ffffffffc0200adc <buddy_system_check+0x296>

    // basic_check();

    cprintf("空闲块数目为: %d\n", count);
ffffffffc0200896:	85ca                	mv	a1,s2
ffffffffc0200898:	00001517          	auipc	a0,0x1
ffffffffc020089c:	6b850513          	addi	a0,a0,1720 # ffffffffc0201f50 <commands+0x678>
ffffffffc02008a0:	817ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("空闲页数目为: %d\n", nr_free);
ffffffffc02008a4:	480c                	lw	a1,16(s0)
ffffffffc02008a6:	00001517          	auipc	a0,0x1
ffffffffc02008aa:	6c250513          	addi	a0,a0,1730 # ffffffffc0201f68 <commands+0x690>
ffffffffc02008ae:	809ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // p0 请求 7 页
    cprintf("p0请求7页\n");
ffffffffc02008b2:	00001517          	auipc	a0,0x1
ffffffffc02008b6:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201f80 <commands+0x6a8>
ffffffffc02008ba:	ffcff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p0 = alloc_pages(7);
ffffffffc02008be:	451d                	li	a0,7
ffffffffc02008c0:	6d2000ef          	jal	ra,ffffffffc0200f92 <alloc_pages>
ffffffffc02008c4:	892a                	mv	s2,a0
    assert(p0 != NULL);
ffffffffc02008c6:	24050b63          	beqz	a0,ffffffffc0200b1c <buddy_system_check+0x2d6>
ffffffffc02008ca:	651c                	ld	a5,8(a0)
ffffffffc02008cc:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02008ce:	8b85                	andi	a5,a5,1
ffffffffc02008d0:	22079663          	bnez	a5,ffffffffc0200afc <buddy_system_check+0x2b6>
    cprintf("空闲页数目为: %d\n", nr_free);
ffffffffc02008d4:	480c                	lw	a1,16(s0)
ffffffffc02008d6:	00001517          	auipc	a0,0x1
ffffffffc02008da:	69250513          	addi	a0,a0,1682 # ffffffffc0201f68 <commands+0x690>
ffffffffc02008de:	fd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // p1 请求 14 页
    cprintf("p1请求14页\n");
ffffffffc02008e2:	00001517          	auipc	a0,0x1
ffffffffc02008e6:	6d650513          	addi	a0,a0,1750 # ffffffffc0201fb8 <commands+0x6e0>
ffffffffc02008ea:	fccff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p1 = alloc_pages(14);
ffffffffc02008ee:	4539                	li	a0,14
ffffffffc02008f0:	6a2000ef          	jal	ra,ffffffffc0200f92 <alloc_pages>
ffffffffc02008f4:	8a2a                	mv	s4,a0
    assert(p1 != NULL);
ffffffffc02008f6:	2a050363          	beqz	a0,ffffffffc0200b9c <buddy_system_check+0x356>
ffffffffc02008fa:	651c                	ld	a5,8(a0)
ffffffffc02008fc:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p1));
ffffffffc02008fe:	8b85                	andi	a5,a5,1
ffffffffc0200900:	26079e63          	bnez	a5,ffffffffc0200b7c <buddy_system_check+0x336>
    cprintf("空闲页数目为: %d\n", nr_free);
ffffffffc0200904:	480c                	lw	a1,16(s0)
ffffffffc0200906:	00001517          	auipc	a0,0x1
ffffffffc020090a:	66250513          	addi	a0,a0,1634 # ffffffffc0201f68 <commands+0x690>
ffffffffc020090e:	fa8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // p2 请求 21 页
    cprintf("p2请求21页\n");
ffffffffc0200912:	00001517          	auipc	a0,0x1
ffffffffc0200916:	6de50513          	addi	a0,a0,1758 # ffffffffc0201ff0 <commands+0x718>
ffffffffc020091a:	f9cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page *p2 = alloc_pages(21);
ffffffffc020091e:	4555                	li	a0,21
ffffffffc0200920:	672000ef          	jal	ra,ffffffffc0200f92 <alloc_pages>
ffffffffc0200924:	89aa                	mv	s3,a0
    assert(p2 != NULL);
ffffffffc0200926:	22050b63          	beqz	a0,ffffffffc0200b5c <buddy_system_check+0x316>
ffffffffc020092a:	6504                	ld	s1,8(a0)
ffffffffc020092c:	8085                	srli	s1,s1,0x1
ffffffffc020092e:	8885                	andi	s1,s1,1
    assert(!PageProperty(p2));
ffffffffc0200930:	20049663          	bnez	s1,ffffffffc0200b3c <buddy_system_check+0x2f6>
    cprintf("空闲页数目为: %d\n", nr_free);
ffffffffc0200934:	480c                	lw	a1,16(s0)
ffffffffc0200936:	00001517          	auipc	a0,0x1
ffffffffc020093a:	63250513          	addi	a0,a0,1586 # ffffffffc0201f68 <commands+0x690>
ffffffffc020093e:	f78ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // 释放 p0
    free_pages(p0, 7);
ffffffffc0200942:	459d                	li	a1,7
ffffffffc0200944:	854a                	mv	a0,s2
ffffffffc0200946:	690000ef          	jal	ra,ffffffffc0200fd6 <free_pages>
ffffffffc020094a:	641c                	ld	a5,8(s0)
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020094c:	10878063          	beq	a5,s0,ffffffffc0200a4c <buddy_system_check+0x206>
ffffffffc0200950:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200954:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200956:	8b05                	andi	a4,a4,1
ffffffffc0200958:	10070263          	beqz	a4,ffffffffc0200a5c <buddy_system_check+0x216>
    count = 0, total = 0;
ffffffffc020095c:	4901                	li	s2,0
ffffffffc020095e:	4581                	li	a1,0
ffffffffc0200960:	a031                	j	ffffffffc020096c <buddy_system_check+0x126>
ffffffffc0200962:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200966:	8b09                	andi	a4,a4,2
ffffffffc0200968:	0e070a63          	beqz	a4,ffffffffc0200a5c <buddy_system_check+0x216>
        count ++, total += p->property;
ffffffffc020096c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200970:	679c                	ld	a5,8(a5)
ffffffffc0200972:	2585                	addiw	a1,a1,1
ffffffffc0200974:	0127093b          	addw	s2,a4,s2
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200978:	fe8795e3          	bne	a5,s0,ffffffffc0200962 <buddy_system_check+0x11c>
    }
    cprintf("释放p0后，空闲块数目为: %d\n", count);
ffffffffc020097c:	00001517          	auipc	a0,0x1
ffffffffc0200980:	6ac50513          	addi	a0,a0,1708 # ffffffffc0202028 <commands+0x750>
ffffffffc0200984:	f32ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p0后，空闲页数目为: %d\n", total);
ffffffffc0200988:	85ca                	mv	a1,s2
ffffffffc020098a:	00001517          	auipc	a0,0x1
ffffffffc020098e:	6c650513          	addi	a0,a0,1734 # ffffffffc0202050 <commands+0x778>
ffffffffc0200992:	f24ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // 释放 p1
    free_pages(p1, 14);
ffffffffc0200996:	45b9                	li	a1,14
ffffffffc0200998:	8552                	mv	a0,s4
ffffffffc020099a:	63c000ef          	jal	ra,ffffffffc0200fd6 <free_pages>
ffffffffc020099e:	641c                	ld	a5,8(s0)
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009a0:	0a878963          	beq	a5,s0,ffffffffc0200a52 <buddy_system_check+0x20c>
ffffffffc02009a4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02009a8:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009aa:	8b05                	andi	a4,a4,1
ffffffffc02009ac:	0e070863          	beqz	a4,ffffffffc0200a9c <buddy_system_check+0x256>
    count = 0, total = 0;
ffffffffc02009b0:	4901                	li	s2,0
ffffffffc02009b2:	4581                	li	a1,0
ffffffffc02009b4:	a029                	j	ffffffffc02009be <buddy_system_check+0x178>
ffffffffc02009b6:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc02009ba:	8b09                	andi	a4,a4,2
ffffffffc02009bc:	c365                	beqz	a4,ffffffffc0200a9c <buddy_system_check+0x256>
        count ++, total += p->property;
ffffffffc02009be:	ff87a703          	lw	a4,-8(a5)
ffffffffc02009c2:	679c                	ld	a5,8(a5)
ffffffffc02009c4:	2585                	addiw	a1,a1,1
ffffffffc02009c6:	0127093b          	addw	s2,a4,s2
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009ca:	fe8796e3          	bne	a5,s0,ffffffffc02009b6 <buddy_system_check+0x170>
    }
    cprintf("释放p1后，空闲块数目为: %d\n", count);
ffffffffc02009ce:	00001517          	auipc	a0,0x1
ffffffffc02009d2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0202078 <commands+0x7a0>
ffffffffc02009d6:	ee0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("释放p1后，空闲页数目为: %d\n", total);
ffffffffc02009da:	85ca                	mv	a1,s2
ffffffffc02009dc:	00001517          	auipc	a0,0x1
ffffffffc02009e0:	6c450513          	addi	a0,a0,1732 # ffffffffc02020a0 <commands+0x7c8>
ffffffffc02009e4:	ed2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    // 释放 p2
    free_pages(p2, 21);
ffffffffc02009e8:	45d5                	li	a1,21
ffffffffc02009ea:	854e                	mv	a0,s3
ffffffffc02009ec:	5ea000ef          	jal	ra,ffffffffc0200fd6 <free_pages>
ffffffffc02009f0:	641c                	ld	a5,8(s0)
    le = &free_list;
    count = 0, total = 0;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009f2:	06878363          	beq	a5,s0,ffffffffc0200a58 <buddy_system_check+0x212>
ffffffffc02009f6:	ff07b703          	ld	a4,-16(a5)
ffffffffc02009fa:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009fc:	8b05                	andi	a4,a4,1
ffffffffc02009fe:	cf3d                	beqz	a4,ffffffffc0200a7c <buddy_system_check+0x236>
    count = 0, total = 0;
ffffffffc0200a00:	4901                	li	s2,0
ffffffffc0200a02:	a029                	j	ffffffffc0200a0c <buddy_system_check+0x1c6>
ffffffffc0200a04:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200a08:	8b09                	andi	a4,a4,2
ffffffffc0200a0a:	cb2d                	beqz	a4,ffffffffc0200a7c <buddy_system_check+0x236>
        count ++, total += p->property;
ffffffffc0200a0c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a10:	679c                	ld	a5,8(a5)
ffffffffc0200a12:	2485                	addiw	s1,s1,1
ffffffffc0200a14:	0127093b          	addw	s2,a4,s2
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a18:	fe8796e3          	bne	a5,s0,ffffffffc0200a04 <buddy_system_check+0x1be>
    }
    cprintf("释放p2后，空闲块数目为: %d\n", count);
ffffffffc0200a1c:	85a6                	mv	a1,s1
ffffffffc0200a1e:	00001517          	auipc	a0,0x1
ffffffffc0200a22:	6aa50513          	addi	a0,a0,1706 # ffffffffc02020c8 <commands+0x7f0>
ffffffffc0200a26:	e90ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    //     struct Page *p = le2page(le, page_link);
    //     count --, total -= p->property;
    // }
    // assert(count == 0);
    // assert(total == 0);
}
ffffffffc0200a2a:	7402                	ld	s0,32(sp)
ffffffffc0200a2c:	70a2                	ld	ra,40(sp)
ffffffffc0200a2e:	64e2                	ld	s1,24(sp)
ffffffffc0200a30:	69a2                	ld	s3,8(sp)
ffffffffc0200a32:	6a02                	ld	s4,0(sp)
    cprintf("释放p2后，空闲页数目为: %d\n", total);
ffffffffc0200a34:	85ca                	mv	a1,s2
}
ffffffffc0200a36:	6942                	ld	s2,16(sp)
    cprintf("释放p2后，空闲页数目为: %d\n", total);
ffffffffc0200a38:	00001517          	auipc	a0,0x1
ffffffffc0200a3c:	6b850513          	addi	a0,a0,1720 # ffffffffc02020f0 <commands+0x818>
}
ffffffffc0200a40:	6145                	addi	sp,sp,48
    cprintf("释放p2后，空闲页数目为: %d\n", total);
ffffffffc0200a42:	e74ff06f          	j	ffffffffc02000b6 <cprintf>
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a46:	4481                	li	s1,0
    int count = 0, total = 0;
ffffffffc0200a48:	4901                	li	s2,0
ffffffffc0200a4a:	b591                	j	ffffffffc020088e <buddy_system_check+0x48>
    count = 0, total = 0;
ffffffffc0200a4c:	4901                	li	s2,0
ffffffffc0200a4e:	4581                	li	a1,0
ffffffffc0200a50:	b735                	j	ffffffffc020097c <buddy_system_check+0x136>
    count = 0, total = 0;
ffffffffc0200a52:	4901                	li	s2,0
ffffffffc0200a54:	4581                	li	a1,0
ffffffffc0200a56:	bfa5                	j	ffffffffc02009ce <buddy_system_check+0x188>
    count = 0, total = 0;
ffffffffc0200a58:	4901                	li	s2,0
ffffffffc0200a5a:	b7c9                	j	ffffffffc0200a1c <buddy_system_check+0x1d6>
        assert(PageProperty(p));
ffffffffc0200a5c:	00001697          	auipc	a3,0x1
ffffffffc0200a60:	48c68693          	addi	a3,a3,1164 # ffffffffc0201ee8 <commands+0x610>
ffffffffc0200a64:	00001617          	auipc	a2,0x1
ffffffffc0200a68:	49460613          	addi	a2,a2,1172 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200a6c:	11500593          	li	a1,277
ffffffffc0200a70:	00001517          	auipc	a0,0x1
ffffffffc0200a74:	4a050513          	addi	a0,a0,1184 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200a78:	ec6ff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200a7c:	00001697          	auipc	a3,0x1
ffffffffc0200a80:	46c68693          	addi	a3,a3,1132 # ffffffffc0201ee8 <commands+0x610>
ffffffffc0200a84:	00001617          	auipc	a2,0x1
ffffffffc0200a88:	47460613          	addi	a2,a2,1140 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200a8c:	12d00593          	li	a1,301
ffffffffc0200a90:	00001517          	auipc	a0,0x1
ffffffffc0200a94:	48050513          	addi	a0,a0,1152 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200a98:	ea6ff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200a9c:	00001697          	auipc	a3,0x1
ffffffffc0200aa0:	44c68693          	addi	a3,a3,1100 # ffffffffc0201ee8 <commands+0x610>
ffffffffc0200aa4:	00001617          	auipc	a2,0x1
ffffffffc0200aa8:	45460613          	addi	a2,a2,1108 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200aac:	12100593          	li	a1,289
ffffffffc0200ab0:	00001517          	auipc	a0,0x1
ffffffffc0200ab4:	46050513          	addi	a0,a0,1120 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200ab8:	e86ff0ef          	jal	ra,ffffffffc020013e <__panic>
        assert(PageProperty(p));
ffffffffc0200abc:	00001697          	auipc	a3,0x1
ffffffffc0200ac0:	42c68693          	addi	a3,a3,1068 # ffffffffc0201ee8 <commands+0x610>
ffffffffc0200ac4:	00001617          	auipc	a2,0x1
ffffffffc0200ac8:	43460613          	addi	a2,a2,1076 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200acc:	0f000593          	li	a1,240
ffffffffc0200ad0:	00001517          	auipc	a0,0x1
ffffffffc0200ad4:	44050513          	addi	a0,a0,1088 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200ad8:	e66ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(total == nr_free_pages());
ffffffffc0200adc:	00001697          	auipc	a3,0x1
ffffffffc0200ae0:	45468693          	addi	a3,a3,1108 # ffffffffc0201f30 <commands+0x658>
ffffffffc0200ae4:	00001617          	auipc	a2,0x1
ffffffffc0200ae8:	41460613          	addi	a2,a2,1044 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200aec:	0f300593          	li	a1,243
ffffffffc0200af0:	00001517          	auipc	a0,0x1
ffffffffc0200af4:	42050513          	addi	a0,a0,1056 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200af8:	e46ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p0));
ffffffffc0200afc:	00001697          	auipc	a3,0x1
ffffffffc0200b00:	4a468693          	addi	a3,a3,1188 # ffffffffc0201fa0 <commands+0x6c8>
ffffffffc0200b04:	00001617          	auipc	a2,0x1
ffffffffc0200b08:	3f460613          	addi	a2,a2,1012 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200b0c:	0fe00593          	li	a1,254
ffffffffc0200b10:	00001517          	auipc	a0,0x1
ffffffffc0200b14:	40050513          	addi	a0,a0,1024 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200b18:	e26ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p0 != NULL);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	47468693          	addi	a3,a3,1140 # ffffffffc0201f90 <commands+0x6b8>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	3d460613          	addi	a2,a2,980 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200b2c:	0fd00593          	li	a1,253
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	3e050513          	addi	a0,a0,992 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200b38:	e06ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p2));
ffffffffc0200b3c:	00001697          	auipc	a3,0x1
ffffffffc0200b40:	4d468693          	addi	a3,a3,1236 # ffffffffc0202010 <commands+0x738>
ffffffffc0200b44:	00001617          	auipc	a2,0x1
ffffffffc0200b48:	3b460613          	addi	a2,a2,948 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200b4c:	10c00593          	li	a1,268
ffffffffc0200b50:	00001517          	auipc	a0,0x1
ffffffffc0200b54:	3c050513          	addi	a0,a0,960 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200b58:	de6ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p2 != NULL);
ffffffffc0200b5c:	00001697          	auipc	a3,0x1
ffffffffc0200b60:	4a468693          	addi	a3,a3,1188 # ffffffffc0202000 <commands+0x728>
ffffffffc0200b64:	00001617          	auipc	a2,0x1
ffffffffc0200b68:	39460613          	addi	a2,a2,916 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200b6c:	10b00593          	li	a1,267
ffffffffc0200b70:	00001517          	auipc	a0,0x1
ffffffffc0200b74:	3a050513          	addi	a0,a0,928 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200b78:	dc6ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(!PageProperty(p1));
ffffffffc0200b7c:	00001697          	auipc	a3,0x1
ffffffffc0200b80:	45c68693          	addi	a3,a3,1116 # ffffffffc0201fd8 <commands+0x700>
ffffffffc0200b84:	00001617          	auipc	a2,0x1
ffffffffc0200b88:	37460613          	addi	a2,a2,884 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200b8c:	10500593          	li	a1,261
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	38050513          	addi	a0,a0,896 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200b98:	da6ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(p1 != NULL);
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	42c68693          	addi	a3,a3,1068 # ffffffffc0201fc8 <commands+0x6f0>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	35460613          	addi	a2,a2,852 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200bac:	10400593          	li	a1,260
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	36050513          	addi	a0,a0,864 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200bb8:	d86ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200bbc <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200bbc:	1141                	addi	sp,sp,-16
ffffffffc0200bbe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200bc0:	1c058763          	beqz	a1,ffffffffc0200d8e <buddy_system_free_pages+0x1d2>
    size_t size = 1;
ffffffffc0200bc4:	4605                	li	a2,1
ffffffffc0200bc6:	02850693          	addi	a3,a0,40
    while (size < n) {
ffffffffc0200bca:	00b67c63          	bleu	a1,a2,ffffffffc0200be2 <buddy_system_free_pages+0x26>
        size <<= 1;
ffffffffc0200bce:	0606                	slli	a2,a2,0x1
    while (size < n) {
ffffffffc0200bd0:	feb66fe3          	bltu	a2,a1,ffffffffc0200bce <buddy_system_free_pages+0x12>
ffffffffc0200bd4:	00261693          	slli	a3,a2,0x2
ffffffffc0200bd8:	96b2                	add	a3,a3,a2
ffffffffc0200bda:	068e                	slli	a3,a3,0x3
    for (; p != base + n; p ++) {
ffffffffc0200bdc:	96aa                	add	a3,a3,a0
ffffffffc0200bde:	02d50d63          	beq	a0,a3,ffffffffc0200c18 <buddy_system_free_pages+0x5c>
ffffffffc0200be2:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200be4:	8b85                	andi	a5,a5,1
ffffffffc0200be6:	18079463          	bnez	a5,ffffffffc0200d6e <buddy_system_free_pages+0x1b2>
ffffffffc0200bea:	651c                	ld	a5,8(a0)
ffffffffc0200bec:	8385                	srli	a5,a5,0x1
ffffffffc0200bee:	8b85                	andi	a5,a5,1
ffffffffc0200bf0:	16079f63          	bnez	a5,ffffffffc0200d6e <buddy_system_free_pages+0x1b2>
ffffffffc0200bf4:	87aa                	mv	a5,a0
ffffffffc0200bf6:	a809                	j	ffffffffc0200c08 <buddy_system_free_pages+0x4c>
ffffffffc0200bf8:	6798                	ld	a4,8(a5)
ffffffffc0200bfa:	8b05                	andi	a4,a4,1
ffffffffc0200bfc:	16071963          	bnez	a4,ffffffffc0200d6e <buddy_system_free_pages+0x1b2>
ffffffffc0200c00:	6798                	ld	a4,8(a5)
ffffffffc0200c02:	8b09                	andi	a4,a4,2
ffffffffc0200c04:	16071563          	bnez	a4,ffffffffc0200d6e <buddy_system_free_pages+0x1b2>
        p->flags = 0;
ffffffffc0200c08:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200c0c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200c10:	02878793          	addi	a5,a5,40
ffffffffc0200c14:	fed792e3          	bne	a5,a3,ffffffffc0200bf8 <buddy_system_free_pages+0x3c>
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
ffffffffc0200c18:	2601                	sext.w	a2,a2
ffffffffc0200c1a:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c1c:	4789                	li	a5,2
ffffffffc0200c1e:	00850713          	addi	a4,a0,8
ffffffffc0200c22:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;// 更新空闲页计数器
ffffffffc0200c26:	00006817          	auipc	a6,0x6
ffffffffc0200c2a:	81280813          	addi	a6,a6,-2030 # ffffffffc0206438 <free_area>
ffffffffc0200c2e:	01082703          	lw	a4,16(a6)
    return list->next == list;
ffffffffc0200c32:	00883783          	ld	a5,8(a6)
ffffffffc0200c36:	9e39                	addw	a2,a2,a4
ffffffffc0200c38:	00006717          	auipc	a4,0x6
ffffffffc0200c3c:	80c72823          	sw	a2,-2032(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0200c40:	11078a63          	beq	a5,a6,ffffffffc0200d54 <buddy_system_free_pages+0x198>
            struct Page* page = le2page(le, page_link);
ffffffffc0200c44:	fe878713          	addi	a4,a5,-24
ffffffffc0200c48:	00083603          	ld	a2,0(a6)
    if (list_empty(&free_list)) {
ffffffffc0200c4c:	4581                	li	a1,0
ffffffffc0200c4e:	01850693          	addi	a3,a0,24
            if (base < page) {
ffffffffc0200c52:	00e56a63          	bltu	a0,a4,ffffffffc0200c66 <buddy_system_free_pages+0xaa>
    return listelm->next;
ffffffffc0200c56:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200c58:	09070263          	beq	a4,a6,ffffffffc0200cdc <buddy_system_free_pages+0x120>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200c5c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200c5e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200c62:	fee57ae3          	bleu	a4,a0,ffffffffc0200c56 <buddy_system_free_pages+0x9a>
ffffffffc0200c66:	c589                	beqz	a1,ffffffffc0200c70 <buddy_system_free_pages+0xb4>
ffffffffc0200c68:	00005717          	auipc	a4,0x5
ffffffffc0200c6c:	7cc73823          	sd	a2,2000(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200c70:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200c72:	e394                	sd	a3,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200c74:	58f5                	li	a7,-3
ffffffffc0200c76:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200c78:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200c7a:	ed18                	sd	a4,24(a0)
        if (le != &free_list) {
ffffffffc0200c7c:	03070063          	beq	a4,a6,ffffffffc0200c9c <buddy_system_free_pages+0xe0>
            if (p + p->property == base && p->property == base->property) {
ffffffffc0200c80:	ff872603          	lw	a2,-8(a4)
            p = le2page(le, page_link);
ffffffffc0200c84:	fe870593          	addi	a1,a4,-24
            if (p + p->property == base && p->property == base->property) {
ffffffffc0200c88:	02061693          	slli	a3,a2,0x20
ffffffffc0200c8c:	9281                	srli	a3,a3,0x20
ffffffffc0200c8e:	00269793          	slli	a5,a3,0x2
ffffffffc0200c92:	97b6                	add	a5,a5,a3
ffffffffc0200c94:	078e                	slli	a5,a5,0x3
ffffffffc0200c96:	97ae                	add	a5,a5,a1
ffffffffc0200c98:	06f50263          	beq	a0,a5,ffffffffc0200cfc <buddy_system_free_pages+0x140>
    return listelm->next;
ffffffffc0200c9c:	711c                	ld	a5,32(a0)
        if (le != &free_list) {
ffffffffc0200c9e:	0b078863          	beq	a5,a6,ffffffffc0200d4e <buddy_system_free_pages+0x192>
            if (base + base->property == p && base->property == p->property) {
ffffffffc0200ca2:	4914                	lw	a3,16(a0)
            p = le2page(le, page_link);
ffffffffc0200ca4:	fe878613          	addi	a2,a5,-24
            if (base + base->property == p && base->property == p->property) {
ffffffffc0200ca8:	02069593          	slli	a1,a3,0x20
ffffffffc0200cac:	9181                	srli	a1,a1,0x20
ffffffffc0200cae:	00259713          	slli	a4,a1,0x2
ffffffffc0200cb2:	972e                	add	a4,a4,a1
ffffffffc0200cb4:	070e                	slli	a4,a4,0x3
ffffffffc0200cb6:	972a                	add	a4,a4,a0
ffffffffc0200cb8:	08e61b63          	bne	a2,a4,ffffffffc0200d4e <buddy_system_free_pages+0x192>
ffffffffc0200cbc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200cc0:	08e69763          	bne	a3,a4,ffffffffc0200d4e <buddy_system_free_pages+0x192>
                base->property += p->property;
ffffffffc0200cc4:	9eb9                	addw	a3,a3,a4
ffffffffc0200cc6:	c914                	sw	a3,16(a0)
ffffffffc0200cc8:	ff078713          	addi	a4,a5,-16
ffffffffc0200ccc:	6117302f          	amoand.d	zero,a7,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200cd0:	6398                	ld	a4,0(a5)
ffffffffc0200cd2:	679c                	ld	a5,8(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200cd4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200cd6:	e398                	sd	a4,0(a5)
                merged = 1;  // 标记为合并
ffffffffc0200cd8:	6d18                	ld	a4,24(a0)
ffffffffc0200cda:	b74d                	j	ffffffffc0200c7c <buddy_system_free_pages+0xc0>
    prev->next = next->prev = elm;
ffffffffc0200cdc:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc0200cde:	03053023          	sd	a6,32(a0)
ffffffffc0200ce2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200ce4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0200ce6:	8636                	mv	a2,a3
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200ce8:	01070563          	beq	a4,a6,ffffffffc0200cf2 <buddy_system_free_pages+0x136>
ffffffffc0200cec:	4585                	li	a1,1
ffffffffc0200cee:	87ba                	mv	a5,a4
ffffffffc0200cf0:	b7bd                	j	ffffffffc0200c5e <buddy_system_free_pages+0xa2>
ffffffffc0200cf2:	873e                	mv	a4,a5
ffffffffc0200cf4:	00d83023          	sd	a3,0(a6)
ffffffffc0200cf8:	58f5                	li	a7,-3
ffffffffc0200cfa:	b749                	j	ffffffffc0200c7c <buddy_system_free_pages+0xc0>
            if (p + p->property == base && p->property == base->property) {
ffffffffc0200cfc:	491c                	lw	a5,16(a0)
ffffffffc0200cfe:	f8f61fe3          	bne	a2,a5,ffffffffc0200c9c <buddy_system_free_pages+0xe0>
                p->property += base->property;
ffffffffc0200d02:	0016161b          	slliw	a2,a2,0x1
ffffffffc0200d06:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200d0a:	00850793          	addi	a5,a0,8
ffffffffc0200d0e:	6117b02f          	amoand.d	zero,a7,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d12:	6d10                	ld	a2,24(a0)
ffffffffc0200d14:	7114                	ld	a3,32(a0)
    prev->next = next;
ffffffffc0200d16:	e614                	sd	a3,8(a2)
    return listelm->next;
ffffffffc0200d18:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0200d1a:	e290                	sd	a2,0(a3)
        if (le != &free_list) {
ffffffffc0200d1c:	03078063          	beq	a5,a6,ffffffffc0200d3c <buddy_system_free_pages+0x180>
            if (base + base->property == p && base->property == p->property) {
ffffffffc0200d20:	ff872683          	lw	a3,-8(a4)
            p = le2page(le, page_link);
ffffffffc0200d24:	fe878613          	addi	a2,a5,-24
            if (base + base->property == p && base->property == p->property) {
ffffffffc0200d28:	02069513          	slli	a0,a3,0x20
ffffffffc0200d2c:	9101                	srli	a0,a0,0x20
ffffffffc0200d2e:	00251713          	slli	a4,a0,0x2
ffffffffc0200d32:	972a                	add	a4,a4,a0
ffffffffc0200d34:	070e                	slli	a4,a4,0x3
ffffffffc0200d36:	972e                	add	a4,a4,a1
ffffffffc0200d38:	00c70563          	beq	a4,a2,ffffffffc0200d42 <buddy_system_free_pages+0x186>
ffffffffc0200d3c:	852e                	mv	a0,a1
ffffffffc0200d3e:	6d18                	ld	a4,24(a0)
ffffffffc0200d40:	bf35                	j	ffffffffc0200c7c <buddy_system_free_pages+0xc0>
ffffffffc0200d42:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d46:	fee69be3          	bne	a3,a4,ffffffffc0200d3c <buddy_system_free_pages+0x180>
ffffffffc0200d4a:	852e                	mv	a0,a1
ffffffffc0200d4c:	bfa5                	j	ffffffffc0200cc4 <buddy_system_free_pages+0x108>
}
ffffffffc0200d4e:	60a2                	ld	ra,8(sp)
ffffffffc0200d50:	0141                	addi	sp,sp,16
ffffffffc0200d52:	8082                	ret
        list_add(&free_list, &(base->page_link));
ffffffffc0200d54:	01850793          	addi	a5,a0,24
    prev->next = next->prev = elm;
ffffffffc0200d58:	00f83023          	sd	a5,0(a6)
ffffffffc0200d5c:	00f83423          	sd	a5,8(a6)
    elm->next = next;
ffffffffc0200d60:	03053023          	sd	a6,32(a0)
    elm->prev = prev;
ffffffffc0200d64:	01053c23          	sd	a6,24(a0)
ffffffffc0200d68:	8742                	mv	a4,a6
ffffffffc0200d6a:	58f5                	li	a7,-3
ffffffffc0200d6c:	bf01                	j	ffffffffc0200c7c <buddy_system_free_pages+0xc0>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200d6e:	00001697          	auipc	a3,0x1
ffffffffc0200d72:	3b268693          	addi	a3,a3,946 # ffffffffc0202120 <commands+0x848>
ffffffffc0200d76:	00001617          	auipc	a2,0x1
ffffffffc0200d7a:	18260613          	addi	a2,a2,386 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200d7e:	06900593          	li	a1,105
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	18e50513          	addi	a0,a0,398 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200d8a:	bb4ff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc0200d8e:	00001697          	auipc	a3,0x1
ffffffffc0200d92:	38a68693          	addi	a3,a3,906 # ffffffffc0202118 <commands+0x840>
ffffffffc0200d96:	00001617          	auipc	a2,0x1
ffffffffc0200d9a:	16260613          	addi	a2,a2,354 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200d9e:	06300593          	li	a1,99
ffffffffc0200da2:	00001517          	auipc	a0,0x1
ffffffffc0200da6:	16e50513          	addi	a0,a0,366 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200daa:	b94ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200dae <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0200dae:	c169                	beqz	a0,ffffffffc0200e70 <buddy_system_alloc_pages+0xc2>
    size_t size = 1;
ffffffffc0200db0:	4605                	li	a2,1
    while (size < n) {
ffffffffc0200db2:	00a67563          	bleu	a0,a2,ffffffffc0200dbc <buddy_system_alloc_pages+0xe>
        size <<= 1;
ffffffffc0200db6:	0606                	slli	a2,a2,0x1
    while (size < n) {
ffffffffc0200db8:	fea66fe3          	bltu	a2,a0,ffffffffc0200db6 <buddy_system_alloc_pages+0x8>
    if (n > nr_free) {
ffffffffc0200dbc:	00005317          	auipc	t1,0x5
ffffffffc0200dc0:	67c30313          	addi	t1,t1,1660 # ffffffffc0206438 <free_area>
ffffffffc0200dc4:	01032803          	lw	a6,16(t1)
ffffffffc0200dc8:	02081793          	slli	a5,a6,0x20
ffffffffc0200dcc:	9381                	srli	a5,a5,0x20
ffffffffc0200dce:	00c7ee63          	bltu	a5,a2,ffffffffc0200dea <buddy_system_alloc_pages+0x3c>
    list_entry_t *le = &free_list;
ffffffffc0200dd2:	869a                	mv	a3,t1
ffffffffc0200dd4:	a801                	j	ffffffffc0200de4 <buddy_system_alloc_pages+0x36>
        if (p->property >= n) {
ffffffffc0200dd6:	ff86a783          	lw	a5,-8(a3)
ffffffffc0200dda:	02079713          	slli	a4,a5,0x20
ffffffffc0200dde:	9301                	srli	a4,a4,0x20
ffffffffc0200de0:	00c77763          	bleu	a2,a4,ffffffffc0200dee <buddy_system_alloc_pages+0x40>
    return listelm->next;
ffffffffc0200de4:	6694                	ld	a3,8(a3)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de6:	fe6698e3          	bne	a3,t1,ffffffffc0200dd6 <buddy_system_alloc_pages+0x28>
        return NULL;// 如果请求的页数大于可用页数，返回 NULL
ffffffffc0200dea:	4501                	li	a0,0
}
ffffffffc0200dec:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0200dee:	fe868513          	addi	a0,a3,-24
    if (page != NULL) {
ffffffffc0200df2:	dd6d                	beqz	a0,ffffffffc0200dec <buddy_system_alloc_pages+0x3e>
    return listelm->prev;
ffffffffc0200df4:	628c                	ld	a1,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200df6:	0086b883          	ld	a7,8(a3)
    prev->next = next;
ffffffffc0200dfa:	0115b423          	sd	a7,8(a1)
    next->prev = prev;
ffffffffc0200dfe:	00b8b023          	sd	a1,0(a7)
        while (page->property > n) {
ffffffffc0200e02:	04e67b63          	bleu	a4,a2,ffffffffc0200e58 <buddy_system_alloc_pages+0xaa>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e06:	4e09                	li	t3,2
            struct Page *p = page + (page->property >> 1);// 分裂当前空闲块成两个块
ffffffffc0200e08:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200e0c:	02079813          	slli	a6,a5,0x20
ffffffffc0200e10:	02085813          	srli	a6,a6,0x20
ffffffffc0200e14:	00281713          	slli	a4,a6,0x2
ffffffffc0200e18:	9742                	add	a4,a4,a6
ffffffffc0200e1a:	070e                	slli	a4,a4,0x3
ffffffffc0200e1c:	972a                	add	a4,a4,a0
            p->property = page->property >> 1;// 设置 p 的大小为空闲块的一半
ffffffffc0200e1e:	cb1c                	sw	a5,16(a4)
ffffffffc0200e20:	00870793          	addi	a5,a4,8
ffffffffc0200e24:	41c7b02f          	amoor.d	zero,t3,(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200e28:	0085b803          	ld	a6,8(a1)
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc0200e2c:	ff86a783          	lw	a5,-8(a3)
            list_add(prev, &(p->page_link));// 将 p 插入到空闲块链表中
ffffffffc0200e30:	01870893          	addi	a7,a4,24
    prev->next = next->prev = elm;
ffffffffc0200e34:	01183023          	sd	a7,0(a6)
ffffffffc0200e38:	0115b423          	sd	a7,8(a1)
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc0200e3c:	0017d79b          	srliw	a5,a5,0x1
    elm->next = next;
ffffffffc0200e40:	03073023          	sd	a6,32(a4)
    elm->prev = prev;
ffffffffc0200e44:	ef0c                	sd	a1,24(a4)
        while (page->property > n) {
ffffffffc0200e46:	02079713          	slli	a4,a5,0x20
            page->property >>= 1;// 将当前空闲块的大小减半
ffffffffc0200e4a:	fef6ac23          	sw	a5,-8(a3)
        while (page->property > n) {
ffffffffc0200e4e:	9301                	srli	a4,a4,0x20
ffffffffc0200e50:	fae66ce3          	bltu	a2,a4,ffffffffc0200e08 <buddy_system_alloc_pages+0x5a>
ffffffffc0200e54:	01032803          	lw	a6,16(t1)
        nr_free -= n;// 更新空闲页计数器
ffffffffc0200e58:	40c8063b          	subw	a2,a6,a2
ffffffffc0200e5c:	00005797          	auipc	a5,0x5
ffffffffc0200e60:	5ec7a623          	sw	a2,1516(a5) # ffffffffc0206448 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200e64:	57f5                	li	a5,-3
ffffffffc0200e66:	ff068713          	addi	a4,a3,-16
ffffffffc0200e6a:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc0200e6e:	8082                	ret
buddy_system_alloc_pages(size_t n) {
ffffffffc0200e70:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200e72:	00001697          	auipc	a3,0x1
ffffffffc0200e76:	2a668693          	addi	a3,a3,678 # ffffffffc0202118 <commands+0x840>
ffffffffc0200e7a:	00001617          	auipc	a2,0x1
ffffffffc0200e7e:	07e60613          	addi	a2,a2,126 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200e82:	03e00593          	li	a1,62
ffffffffc0200e86:	00001517          	auipc	a0,0x1
ffffffffc0200e8a:	08a50513          	addi	a0,a0,138 # ffffffffc0201f10 <commands+0x638>
buddy_system_alloc_pages(size_t n) {
ffffffffc0200e8e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e90:	aaeff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200e94 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e94:	1141                	addi	sp,sp,-16
ffffffffc0200e96:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e98:	cdf1                	beqz	a1,ffffffffc0200f74 <buddy_system_init_memmap+0xe0>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e9a:	6518                	ld	a4,8(a0)
    for (; p != base + n; p ++) {
ffffffffc0200e9c:	000a06b7          	lui	a3,0xa0
ffffffffc0200ea0:	96aa                	add	a3,a3,a0
        assert(PageReserved(p));
ffffffffc0200ea2:	8b05                	andi	a4,a4,1
ffffffffc0200ea4:	87aa                	mv	a5,a0
ffffffffc0200ea6:	e709                	bnez	a4,ffffffffc0200eb0 <buddy_system_init_memmap+0x1c>
ffffffffc0200ea8:	a07d                	j	ffffffffc0200f56 <buddy_system_init_memmap+0xc2>
ffffffffc0200eaa:	6798                	ld	a4,8(a5)
ffffffffc0200eac:	8b05                	andi	a4,a4,1
ffffffffc0200eae:	c745                	beqz	a4,ffffffffc0200f56 <buddy_system_init_memmap+0xc2>
        p->flags = p->property = 0;
ffffffffc0200eb0:	0007a823          	sw	zero,16(a5)
ffffffffc0200eb4:	0007b423          	sd	zero,8(a5)
ffffffffc0200eb8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200ebc:	02878793          	addi	a5,a5,40
ffffffffc0200ec0:	fed795e3          	bne	a5,a3,ffffffffc0200eaa <buddy_system_init_memmap+0x16>
    base->property = n;// 将起始页的 property 设置为 n，表示这是一个大小为 n 页的空闲块
ffffffffc0200ec4:	6611                	lui	a2,0x4
ffffffffc0200ec6:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ec8:	4789                	li	a5,2
ffffffffc0200eca:	00850713          	addi	a4,a0,8
ffffffffc0200ece:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;// 更新空闲页计数器
ffffffffc0200ed2:	00005697          	auipc	a3,0x5
ffffffffc0200ed6:	56668693          	addi	a3,a3,1382 # ffffffffc0206438 <free_area>
ffffffffc0200eda:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200edc:	669c                	ld	a5,8(a3)
ffffffffc0200ede:	9f31                	addw	a4,a4,a2
ffffffffc0200ee0:	00005617          	auipc	a2,0x5
ffffffffc0200ee4:	56e62423          	sw	a4,1384(a2) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0200ee8:	04d78a63          	beq	a5,a3,ffffffffc0200f3c <buddy_system_init_memmap+0xa8>
            struct Page* page = le2page(le, page_link);
ffffffffc0200eec:	fe878713          	addi	a4,a5,-24
ffffffffc0200ef0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200ef2:	4801                	li	a6,0
ffffffffc0200ef4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200ef8:	00e56a63          	bltu	a0,a4,ffffffffc0200f0c <buddy_system_init_memmap+0x78>
    return listelm->next;
ffffffffc0200efc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200efe:	02d70563          	beq	a4,a3,ffffffffc0200f28 <buddy_system_init_memmap+0x94>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200f02:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f04:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f08:	fee57ae3          	bleu	a4,a0,ffffffffc0200efc <buddy_system_init_memmap+0x68>
ffffffffc0200f0c:	00080663          	beqz	a6,ffffffffc0200f18 <buddy_system_init_memmap+0x84>
ffffffffc0200f10:	00005717          	auipc	a4,0x5
ffffffffc0200f14:	52b73423          	sd	a1,1320(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f18:	6398                	ld	a4,0(a5)
}
ffffffffc0200f1a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200f1c:	e390                	sd	a2,0(a5)
ffffffffc0200f1e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200f20:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f22:	ed18                	sd	a4,24(a0)
ffffffffc0200f24:	0141                	addi	sp,sp,16
ffffffffc0200f26:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200f28:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200f2a:	f114                	sd	a3,32(a0)
ffffffffc0200f2c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200f2e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0200f30:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200f32:	00d70e63          	beq	a4,a3,ffffffffc0200f4e <buddy_system_init_memmap+0xba>
ffffffffc0200f36:	4805                	li	a6,1
ffffffffc0200f38:	87ba                	mv	a5,a4
ffffffffc0200f3a:	b7e9                	j	ffffffffc0200f04 <buddy_system_init_memmap+0x70>
}
ffffffffc0200f3c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f3e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0200f42:	e398                	sd	a4,0(a5)
ffffffffc0200f44:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200f46:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f48:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200f4a:	0141                	addi	sp,sp,16
ffffffffc0200f4c:	8082                	ret
ffffffffc0200f4e:	60a2                	ld	ra,8(sp)
ffffffffc0200f50:	e290                	sd	a2,0(a3)
ffffffffc0200f52:	0141                	addi	sp,sp,16
ffffffffc0200f54:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200f56:	00001697          	auipc	a3,0x1
ffffffffc0200f5a:	1f268693          	addi	a3,a3,498 # ffffffffc0202148 <commands+0x870>
ffffffffc0200f5e:	00001617          	auipc	a2,0x1
ffffffffc0200f62:	f9a60613          	addi	a2,a2,-102 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200f66:	45f1                	li	a1,28
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	fa850513          	addi	a0,a0,-88 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200f70:	9ceff0ef          	jal	ra,ffffffffc020013e <__panic>
    assert(n > 0);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	1a468693          	addi	a3,a3,420 # ffffffffc0202118 <commands+0x840>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	f7c60613          	addi	a2,a2,-132 # ffffffffc0201ef8 <commands+0x620>
ffffffffc0200f84:	45d5                	li	a1,21
ffffffffc0200f86:	00001517          	auipc	a0,0x1
ffffffffc0200f8a:	f8a50513          	addi	a0,a0,-118 # ffffffffc0201f10 <commands+0x638>
ffffffffc0200f8e:	9b0ff0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc0200f92 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f92:	100027f3          	csrr	a5,sstatus
ffffffffc0200f96:	8b89                	andi	a5,a5,2
ffffffffc0200f98:	eb89                	bnez	a5,ffffffffc0200faa <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f9a:	00005797          	auipc	a5,0x5
ffffffffc0200f9e:	4be78793          	addi	a5,a5,1214 # ffffffffc0206458 <pmm_manager>
ffffffffc0200fa2:	639c                	ld	a5,0(a5)
ffffffffc0200fa4:	0187b303          	ld	t1,24(a5)
ffffffffc0200fa8:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200faa:	1141                	addi	sp,sp,-16
ffffffffc0200fac:	e406                	sd	ra,8(sp)
ffffffffc0200fae:	e022                	sd	s0,0(sp)
ffffffffc0200fb0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200fb2:	cb2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200fb6:	00005797          	auipc	a5,0x5
ffffffffc0200fba:	4a278793          	addi	a5,a5,1186 # ffffffffc0206458 <pmm_manager>
ffffffffc0200fbe:	639c                	ld	a5,0(a5)
ffffffffc0200fc0:	8522                	mv	a0,s0
ffffffffc0200fc2:	6f9c                	ld	a5,24(a5)
ffffffffc0200fc4:	9782                	jalr	a5
ffffffffc0200fc6:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200fc8:	c96ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200fcc:	8522                	mv	a0,s0
ffffffffc0200fce:	60a2                	ld	ra,8(sp)
ffffffffc0200fd0:	6402                	ld	s0,0(sp)
ffffffffc0200fd2:	0141                	addi	sp,sp,16
ffffffffc0200fd4:	8082                	ret

ffffffffc0200fd6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200fd6:	100027f3          	csrr	a5,sstatus
ffffffffc0200fda:	8b89                	andi	a5,a5,2
ffffffffc0200fdc:	eb89                	bnez	a5,ffffffffc0200fee <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200fde:	00005797          	auipc	a5,0x5
ffffffffc0200fe2:	47a78793          	addi	a5,a5,1146 # ffffffffc0206458 <pmm_manager>
ffffffffc0200fe6:	639c                	ld	a5,0(a5)
ffffffffc0200fe8:	0207b303          	ld	t1,32(a5)
ffffffffc0200fec:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200fee:	1101                	addi	sp,sp,-32
ffffffffc0200ff0:	ec06                	sd	ra,24(sp)
ffffffffc0200ff2:	e822                	sd	s0,16(sp)
ffffffffc0200ff4:	e426                	sd	s1,8(sp)
ffffffffc0200ff6:	842a                	mv	s0,a0
ffffffffc0200ff8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ffa:	c6aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ffe:	00005797          	auipc	a5,0x5
ffffffffc0201002:	45a78793          	addi	a5,a5,1114 # ffffffffc0206458 <pmm_manager>
ffffffffc0201006:	639c                	ld	a5,0(a5)
ffffffffc0201008:	85a6                	mv	a1,s1
ffffffffc020100a:	8522                	mv	a0,s0
ffffffffc020100c:	739c                	ld	a5,32(a5)
ffffffffc020100e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201010:	6442                	ld	s0,16(sp)
ffffffffc0201012:	60e2                	ld	ra,24(sp)
ffffffffc0201014:	64a2                	ld	s1,8(sp)
ffffffffc0201016:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201018:	c46ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020101c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020101c:	100027f3          	csrr	a5,sstatus
ffffffffc0201020:	8b89                	andi	a5,a5,2
ffffffffc0201022:	eb89                	bnez	a5,ffffffffc0201034 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201024:	00005797          	auipc	a5,0x5
ffffffffc0201028:	43478793          	addi	a5,a5,1076 # ffffffffc0206458 <pmm_manager>
ffffffffc020102c:	639c                	ld	a5,0(a5)
ffffffffc020102e:	0287b303          	ld	t1,40(a5)
ffffffffc0201032:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201034:	1141                	addi	sp,sp,-16
ffffffffc0201036:	e406                	sd	ra,8(sp)
ffffffffc0201038:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020103a:	c2aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020103e:	00005797          	auipc	a5,0x5
ffffffffc0201042:	41a78793          	addi	a5,a5,1050 # ffffffffc0206458 <pmm_manager>
ffffffffc0201046:	639c                	ld	a5,0(a5)
ffffffffc0201048:	779c                	ld	a5,40(a5)
ffffffffc020104a:	9782                	jalr	a5
ffffffffc020104c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020104e:	c10ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201052:	8522                	mv	a0,s0
ffffffffc0201054:	60a2                	ld	ra,8(sp)
ffffffffc0201056:	6402                	ld	s0,0(sp)
ffffffffc0201058:	0141                	addi	sp,sp,16
ffffffffc020105a:	8082                	ret

ffffffffc020105c <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc020105c:	00001797          	auipc	a5,0x1
ffffffffc0201060:	0fc78793          	addi	a5,a5,252 # ffffffffc0202158 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201064:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201066:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	14850513          	addi	a0,a0,328 # ffffffffc02021b0 <buddy_system_pmm_manager+0x58>
void pmm_init(void) {
ffffffffc0201070:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc0201072:	00005717          	auipc	a4,0x5
ffffffffc0201076:	3ef73323          	sd	a5,998(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc020107a:	e822                	sd	s0,16(sp)
ffffffffc020107c:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;    
ffffffffc020107e:	00005417          	auipc	s0,0x5
ffffffffc0201082:	3da40413          	addi	s0,s0,986 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201086:	830ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020108a:	601c                	ld	a5,0(s0)
ffffffffc020108c:	679c                	ld	a5,8(a5)
ffffffffc020108e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201090:	57f5                	li	a5,-3
ffffffffc0201092:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201094:	00001517          	auipc	a0,0x1
ffffffffc0201098:	13450513          	addi	a0,a0,308 # ffffffffc02021c8 <buddy_system_pmm_manager+0x70>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020109c:	00005717          	auipc	a4,0x5
ffffffffc02010a0:	3cf73223          	sd	a5,964(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02010a4:	812ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02010a8:	46c5                	li	a3,17
ffffffffc02010aa:	06ee                	slli	a3,a3,0x1b
ffffffffc02010ac:	40100613          	li	a2,1025
ffffffffc02010b0:	16fd                	addi	a3,a3,-1
ffffffffc02010b2:	0656                	slli	a2,a2,0x15
ffffffffc02010b4:	07e005b7          	lui	a1,0x7e00
ffffffffc02010b8:	00001517          	auipc	a0,0x1
ffffffffc02010bc:	12850513          	addi	a0,a0,296 # ffffffffc02021e0 <buddy_system_pmm_manager+0x88>
ffffffffc02010c0:	ff7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010c4:	777d                	lui	a4,0xfffff
ffffffffc02010c6:	00006797          	auipc	a5,0x6
ffffffffc02010ca:	3a978793          	addi	a5,a5,937 # ffffffffc020746f <end+0xfff>
ffffffffc02010ce:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010d0:	00088737          	lui	a4,0x88
ffffffffc02010d4:	00005697          	auipc	a3,0x5
ffffffffc02010d8:	34e6b223          	sd	a4,836(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010dc:	4601                	li	a2,0
ffffffffc02010de:	00005717          	auipc	a4,0x5
ffffffffc02010e2:	38f73523          	sd	a5,906(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010e6:	4681                	li	a3,0
ffffffffc02010e8:	00005897          	auipc	a7,0x5
ffffffffc02010ec:	33088893          	addi	a7,a7,816 # ffffffffc0206418 <npage>
ffffffffc02010f0:	00005597          	auipc	a1,0x5
ffffffffc02010f4:	37858593          	addi	a1,a1,888 # ffffffffc0206468 <pages>
ffffffffc02010f8:	4805                	li	a6,1
ffffffffc02010fa:	fff80537          	lui	a0,0xfff80
ffffffffc02010fe:	a011                	j	ffffffffc0201102 <pmm_init+0xa6>
ffffffffc0201100:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201102:	97b2                	add	a5,a5,a2
ffffffffc0201104:	07a1                	addi	a5,a5,8
ffffffffc0201106:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020110a:	0008b703          	ld	a4,0(a7)
ffffffffc020110e:	0685                	addi	a3,a3,1
ffffffffc0201110:	02860613          	addi	a2,a2,40
ffffffffc0201114:	00a707b3          	add	a5,a4,a0
ffffffffc0201118:	fef6e4e3          	bltu	a3,a5,ffffffffc0201100 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020111c:	6190                	ld	a2,0(a1)
ffffffffc020111e:	00271793          	slli	a5,a4,0x2
ffffffffc0201122:	97ba                	add	a5,a5,a4
ffffffffc0201124:	fec006b7          	lui	a3,0xfec00
ffffffffc0201128:	078e                	slli	a5,a5,0x3
ffffffffc020112a:	96b2                	add	a3,a3,a2
ffffffffc020112c:	96be                	add	a3,a3,a5
ffffffffc020112e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201132:	08f6e863          	bltu	a3,a5,ffffffffc02011c2 <pmm_init+0x166>
ffffffffc0201136:	00005497          	auipc	s1,0x5
ffffffffc020113a:	32a48493          	addi	s1,s1,810 # ffffffffc0206460 <va_pa_offset>
ffffffffc020113e:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201140:	45c5                	li	a1,17
ffffffffc0201142:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201144:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201146:	04b6e963          	bltu	a3,a1,ffffffffc0201198 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020114a:	601c                	ld	a5,0(s0)
ffffffffc020114c:	7b9c                	ld	a5,48(a5)
ffffffffc020114e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201150:	00001517          	auipc	a0,0x1
ffffffffc0201154:	12850513          	addi	a0,a0,296 # ffffffffc0202278 <buddy_system_pmm_manager+0x120>
ffffffffc0201158:	f5ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020115c:	00004697          	auipc	a3,0x4
ffffffffc0201160:	ea468693          	addi	a3,a3,-348 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201164:	00005797          	auipc	a5,0x5
ffffffffc0201168:	2ad7be23          	sd	a3,700(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020116c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201170:	06f6e563          	bltu	a3,a5,ffffffffc02011da <pmm_init+0x17e>
ffffffffc0201174:	609c                	ld	a5,0(s1)
}
ffffffffc0201176:	6442                	ld	s0,16(sp)
ffffffffc0201178:	60e2                	ld	ra,24(sp)
ffffffffc020117a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020117c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020117e:	8e9d                	sub	a3,a3,a5
ffffffffc0201180:	00005797          	auipc	a5,0x5
ffffffffc0201184:	2cd7b823          	sd	a3,720(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201188:	00001517          	auipc	a0,0x1
ffffffffc020118c:	11050513          	addi	a0,a0,272 # ffffffffc0202298 <buddy_system_pmm_manager+0x140>
ffffffffc0201190:	8636                	mv	a2,a3
}
ffffffffc0201192:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201194:	f23fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201198:	6785                	lui	a5,0x1
ffffffffc020119a:	17fd                	addi	a5,a5,-1
ffffffffc020119c:	96be                	add	a3,a3,a5
ffffffffc020119e:	77fd                	lui	a5,0xfffff
ffffffffc02011a0:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011a2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02011a6:	04e7f663          	bleu	a4,a5,ffffffffc02011f2 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02011aa:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011ac:	97aa                	add	a5,a5,a0
ffffffffc02011ae:	00279513          	slli	a0,a5,0x2
ffffffffc02011b2:	953e                	add	a0,a0,a5
ffffffffc02011b4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011b6:	8d95                	sub	a1,a1,a3
ffffffffc02011b8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02011ba:	81b1                	srli	a1,a1,0xc
ffffffffc02011bc:	9532                	add	a0,a0,a2
ffffffffc02011be:	9782                	jalr	a5
ffffffffc02011c0:	b769                	j	ffffffffc020114a <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011c2:	00001617          	auipc	a2,0x1
ffffffffc02011c6:	04e60613          	addi	a2,a2,78 # ffffffffc0202210 <buddy_system_pmm_manager+0xb8>
ffffffffc02011ca:	07000593          	li	a1,112
ffffffffc02011ce:	00001517          	auipc	a0,0x1
ffffffffc02011d2:	06a50513          	addi	a0,a0,106 # ffffffffc0202238 <buddy_system_pmm_manager+0xe0>
ffffffffc02011d6:	f69fe0ef          	jal	ra,ffffffffc020013e <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011da:	00001617          	auipc	a2,0x1
ffffffffc02011de:	03660613          	addi	a2,a2,54 # ffffffffc0202210 <buddy_system_pmm_manager+0xb8>
ffffffffc02011e2:	08b00593          	li	a1,139
ffffffffc02011e6:	00001517          	auipc	a0,0x1
ffffffffc02011ea:	05250513          	addi	a0,a0,82 # ffffffffc0202238 <buddy_system_pmm_manager+0xe0>
ffffffffc02011ee:	f51fe0ef          	jal	ra,ffffffffc020013e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011f2:	00001617          	auipc	a2,0x1
ffffffffc02011f6:	05660613          	addi	a2,a2,86 # ffffffffc0202248 <buddy_system_pmm_manager+0xf0>
ffffffffc02011fa:	06b00593          	li	a1,107
ffffffffc02011fe:	00001517          	auipc	a0,0x1
ffffffffc0201202:	06a50513          	addi	a0,a0,106 # ffffffffc0202268 <buddy_system_pmm_manager+0x110>
ffffffffc0201206:	f39fe0ef          	jal	ra,ffffffffc020013e <__panic>

ffffffffc020120a <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc020120a:	c185                	beqz	a1,ffffffffc020122a <strnlen+0x20>
ffffffffc020120c:	00054783          	lbu	a5,0(a0)
ffffffffc0201210:	cf89                	beqz	a5,ffffffffc020122a <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201212:	4781                	li	a5,0
ffffffffc0201214:	a021                	j	ffffffffc020121c <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201216:	00074703          	lbu	a4,0(a4)
ffffffffc020121a:	c711                	beqz	a4,ffffffffc0201226 <strnlen+0x1c>
        cnt ++;
ffffffffc020121c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020121e:	00f50733          	add	a4,a0,a5
ffffffffc0201222:	fef59ae3          	bne	a1,a5,ffffffffc0201216 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201226:	853e                	mv	a0,a5
ffffffffc0201228:	8082                	ret
    size_t cnt = 0;
ffffffffc020122a:	4781                	li	a5,0
}
ffffffffc020122c:	853e                	mv	a0,a5
ffffffffc020122e:	8082                	ret

ffffffffc0201230 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201230:	00054783          	lbu	a5,0(a0)
ffffffffc0201234:	0005c703          	lbu	a4,0(a1)
ffffffffc0201238:	cb91                	beqz	a5,ffffffffc020124c <strcmp+0x1c>
ffffffffc020123a:	00e79c63          	bne	a5,a4,ffffffffc0201252 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020123e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201240:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201244:	0585                	addi	a1,a1,1
ffffffffc0201246:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020124a:	fbe5                	bnez	a5,ffffffffc020123a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020124c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020124e:	9d19                	subw	a0,a0,a4
ffffffffc0201250:	8082                	ret
ffffffffc0201252:	0007851b          	sext.w	a0,a5
ffffffffc0201256:	9d19                	subw	a0,a0,a4
ffffffffc0201258:	8082                	ret

ffffffffc020125a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020125a:	00054783          	lbu	a5,0(a0)
ffffffffc020125e:	cb91                	beqz	a5,ffffffffc0201272 <strchr+0x18>
        if (*s == c) {
ffffffffc0201260:	00b79563          	bne	a5,a1,ffffffffc020126a <strchr+0x10>
ffffffffc0201264:	a809                	j	ffffffffc0201276 <strchr+0x1c>
ffffffffc0201266:	00b78763          	beq	a5,a1,ffffffffc0201274 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020126a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020126c:	00054783          	lbu	a5,0(a0)
ffffffffc0201270:	fbfd                	bnez	a5,ffffffffc0201266 <strchr+0xc>
    }
    return NULL;
ffffffffc0201272:	4501                	li	a0,0
}
ffffffffc0201274:	8082                	ret
ffffffffc0201276:	8082                	ret

ffffffffc0201278 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201278:	ca01                	beqz	a2,ffffffffc0201288 <memset+0x10>
ffffffffc020127a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020127c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020127e:	0785                	addi	a5,a5,1
ffffffffc0201280:	feb78fa3          	sb	a1,-1(a5) # ffffffffffffefff <end+0x3fdf8b8f>
    while (n -- > 0) {
ffffffffc0201284:	fec79de3          	bne	a5,a2,ffffffffc020127e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201288:	8082                	ret

ffffffffc020128a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020128a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020128e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201290:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201294:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201296:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020129a:	f022                	sd	s0,32(sp)
ffffffffc020129c:	ec26                	sd	s1,24(sp)
ffffffffc020129e:	e84a                	sd	s2,16(sp)
ffffffffc02012a0:	f406                	sd	ra,40(sp)
ffffffffc02012a2:	e44e                	sd	s3,8(sp)
ffffffffc02012a4:	84aa                	mv	s1,a0
ffffffffc02012a6:	892e                	mv	s2,a1
ffffffffc02012a8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02012ac:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02012ae:	03067e63          	bleu	a6,a2,ffffffffc02012ea <printnum+0x60>
ffffffffc02012b2:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012b4:	00805763          	blez	s0,ffffffffc02012c2 <printnum+0x38>
ffffffffc02012b8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02012ba:	85ca                	mv	a1,s2
ffffffffc02012bc:	854e                	mv	a0,s3
ffffffffc02012be:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02012c0:	fc65                	bnez	s0,ffffffffc02012b8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012c2:	1a02                	slli	s4,s4,0x20
ffffffffc02012c4:	020a5a13          	srli	s4,s4,0x20
ffffffffc02012c8:	00001797          	auipc	a5,0x1
ffffffffc02012cc:	1a078793          	addi	a5,a5,416 # ffffffffc0202468 <error_string+0x38>
ffffffffc02012d0:	9a3e                	add	s4,s4,a5
}
ffffffffc02012d2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012d4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02012d8:	70a2                	ld	ra,40(sp)
ffffffffc02012da:	69a2                	ld	s3,8(sp)
ffffffffc02012dc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012de:	85ca                	mv	a1,s2
ffffffffc02012e0:	8326                	mv	t1,s1
}
ffffffffc02012e2:	6942                	ld	s2,16(sp)
ffffffffc02012e4:	64e2                	ld	s1,24(sp)
ffffffffc02012e6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012e8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02012ea:	03065633          	divu	a2,a2,a6
ffffffffc02012ee:	8722                	mv	a4,s0
ffffffffc02012f0:	f9bff0ef          	jal	ra,ffffffffc020128a <printnum>
ffffffffc02012f4:	b7f9                	j	ffffffffc02012c2 <printnum+0x38>

ffffffffc02012f6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02012f6:	7119                	addi	sp,sp,-128
ffffffffc02012f8:	f4a6                	sd	s1,104(sp)
ffffffffc02012fa:	f0ca                	sd	s2,96(sp)
ffffffffc02012fc:	e8d2                	sd	s4,80(sp)
ffffffffc02012fe:	e4d6                	sd	s5,72(sp)
ffffffffc0201300:	e0da                	sd	s6,64(sp)
ffffffffc0201302:	fc5e                	sd	s7,56(sp)
ffffffffc0201304:	f862                	sd	s8,48(sp)
ffffffffc0201306:	f06a                	sd	s10,32(sp)
ffffffffc0201308:	fc86                	sd	ra,120(sp)
ffffffffc020130a:	f8a2                	sd	s0,112(sp)
ffffffffc020130c:	ecce                	sd	s3,88(sp)
ffffffffc020130e:	f466                	sd	s9,40(sp)
ffffffffc0201310:	ec6e                	sd	s11,24(sp)
ffffffffc0201312:	892a                	mv	s2,a0
ffffffffc0201314:	84ae                	mv	s1,a1
ffffffffc0201316:	8d32                	mv	s10,a2
ffffffffc0201318:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020131a:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020131c:	00001a17          	auipc	s4,0x1
ffffffffc0201320:	fbca0a13          	addi	s4,s4,-68 # ffffffffc02022d8 <buddy_system_pmm_manager+0x180>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201324:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201328:	00001c17          	auipc	s8,0x1
ffffffffc020132c:	108c0c13          	addi	s8,s8,264 # ffffffffc0202430 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201330:	000d4503          	lbu	a0,0(s10)
ffffffffc0201334:	02500793          	li	a5,37
ffffffffc0201338:	001d0413          	addi	s0,s10,1
ffffffffc020133c:	00f50e63          	beq	a0,a5,ffffffffc0201358 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0201340:	c521                	beqz	a0,ffffffffc0201388 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201342:	02500993          	li	s3,37
ffffffffc0201346:	a011                	j	ffffffffc020134a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201348:	c121                	beqz	a0,ffffffffc0201388 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020134a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020134c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020134e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201350:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201354:	ff351ae3          	bne	a0,s3,ffffffffc0201348 <vprintfmt+0x52>
ffffffffc0201358:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020135c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201360:	4981                	li	s3,0
ffffffffc0201362:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201364:	5cfd                	li	s9,-1
ffffffffc0201366:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201368:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020136c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020136e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201372:	0ff6f693          	andi	a3,a3,255
ffffffffc0201376:	00140d13          	addi	s10,s0,1
ffffffffc020137a:	20d5e563          	bltu	a1,a3,ffffffffc0201584 <vprintfmt+0x28e>
ffffffffc020137e:	068a                	slli	a3,a3,0x2
ffffffffc0201380:	96d2                	add	a3,a3,s4
ffffffffc0201382:	4294                	lw	a3,0(a3)
ffffffffc0201384:	96d2                	add	a3,a3,s4
ffffffffc0201386:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201388:	70e6                	ld	ra,120(sp)
ffffffffc020138a:	7446                	ld	s0,112(sp)
ffffffffc020138c:	74a6                	ld	s1,104(sp)
ffffffffc020138e:	7906                	ld	s2,96(sp)
ffffffffc0201390:	69e6                	ld	s3,88(sp)
ffffffffc0201392:	6a46                	ld	s4,80(sp)
ffffffffc0201394:	6aa6                	ld	s5,72(sp)
ffffffffc0201396:	6b06                	ld	s6,64(sp)
ffffffffc0201398:	7be2                	ld	s7,56(sp)
ffffffffc020139a:	7c42                	ld	s8,48(sp)
ffffffffc020139c:	7ca2                	ld	s9,40(sp)
ffffffffc020139e:	7d02                	ld	s10,32(sp)
ffffffffc02013a0:	6de2                	ld	s11,24(sp)
ffffffffc02013a2:	6109                	addi	sp,sp,128
ffffffffc02013a4:	8082                	ret
    if (lflag >= 2) {
ffffffffc02013a6:	4705                	li	a4,1
ffffffffc02013a8:	008a8593          	addi	a1,s5,8
ffffffffc02013ac:	01074463          	blt	a4,a6,ffffffffc02013b4 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02013b0:	26080363          	beqz	a6,ffffffffc0201616 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02013b4:	000ab603          	ld	a2,0(s5)
ffffffffc02013b8:	46c1                	li	a3,16
ffffffffc02013ba:	8aae                	mv	s5,a1
ffffffffc02013bc:	a06d                	j	ffffffffc0201466 <vprintfmt+0x170>
            goto reswitch;
ffffffffc02013be:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02013c2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013c6:	b765                	j	ffffffffc020136e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc02013c8:	000aa503          	lw	a0,0(s5)
ffffffffc02013cc:	85a6                	mv	a1,s1
ffffffffc02013ce:	0aa1                	addi	s5,s5,8
ffffffffc02013d0:	9902                	jalr	s2
            break;
ffffffffc02013d2:	bfb9                	j	ffffffffc0201330 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013d4:	4705                	li	a4,1
ffffffffc02013d6:	008a8993          	addi	s3,s5,8
ffffffffc02013da:	01074463          	blt	a4,a6,ffffffffc02013e2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02013de:	22080463          	beqz	a6,ffffffffc0201606 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02013e2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02013e6:	24044463          	bltz	s0,ffffffffc020162e <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02013ea:	8622                	mv	a2,s0
ffffffffc02013ec:	8ace                	mv	s5,s3
ffffffffc02013ee:	46a9                	li	a3,10
ffffffffc02013f0:	a89d                	j	ffffffffc0201466 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02013f2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013f6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02013f8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02013fa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02013fe:	8fb5                	xor	a5,a5,a3
ffffffffc0201400:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201404:	1ad74363          	blt	a4,a3,ffffffffc02015aa <vprintfmt+0x2b4>
ffffffffc0201408:	00369793          	slli	a5,a3,0x3
ffffffffc020140c:	97e2                	add	a5,a5,s8
ffffffffc020140e:	639c                	ld	a5,0(a5)
ffffffffc0201410:	18078d63          	beqz	a5,ffffffffc02015aa <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201414:	86be                	mv	a3,a5
ffffffffc0201416:	00001617          	auipc	a2,0x1
ffffffffc020141a:	10260613          	addi	a2,a2,258 # ffffffffc0202518 <error_string+0xe8>
ffffffffc020141e:	85a6                	mv	a1,s1
ffffffffc0201420:	854a                	mv	a0,s2
ffffffffc0201422:	240000ef          	jal	ra,ffffffffc0201662 <printfmt>
ffffffffc0201426:	b729                	j	ffffffffc0201330 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201428:	00144603          	lbu	a2,1(s0)
ffffffffc020142c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020142e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201430:	bf3d                	j	ffffffffc020136e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201432:	4705                	li	a4,1
ffffffffc0201434:	008a8593          	addi	a1,s5,8
ffffffffc0201438:	01074463          	blt	a4,a6,ffffffffc0201440 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020143c:	1e080263          	beqz	a6,ffffffffc0201620 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0201440:	000ab603          	ld	a2,0(s5)
ffffffffc0201444:	46a1                	li	a3,8
ffffffffc0201446:	8aae                	mv	s5,a1
ffffffffc0201448:	a839                	j	ffffffffc0201466 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020144a:	03000513          	li	a0,48
ffffffffc020144e:	85a6                	mv	a1,s1
ffffffffc0201450:	e03e                	sd	a5,0(sp)
ffffffffc0201452:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201454:	85a6                	mv	a1,s1
ffffffffc0201456:	07800513          	li	a0,120
ffffffffc020145a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020145c:	0aa1                	addi	s5,s5,8
ffffffffc020145e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201462:	6782                	ld	a5,0(sp)
ffffffffc0201464:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201466:	876e                	mv	a4,s11
ffffffffc0201468:	85a6                	mv	a1,s1
ffffffffc020146a:	854a                	mv	a0,s2
ffffffffc020146c:	e1fff0ef          	jal	ra,ffffffffc020128a <printnum>
            break;
ffffffffc0201470:	b5c1                	j	ffffffffc0201330 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201472:	000ab603          	ld	a2,0(s5)
ffffffffc0201476:	0aa1                	addi	s5,s5,8
ffffffffc0201478:	1c060663          	beqz	a2,ffffffffc0201644 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020147c:	00160413          	addi	s0,a2,1
ffffffffc0201480:	17b05c63          	blez	s11,ffffffffc02015f8 <vprintfmt+0x302>
ffffffffc0201484:	02d00593          	li	a1,45
ffffffffc0201488:	14b79263          	bne	a5,a1,ffffffffc02015cc <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020148c:	00064783          	lbu	a5,0(a2)
ffffffffc0201490:	0007851b          	sext.w	a0,a5
ffffffffc0201494:	c905                	beqz	a0,ffffffffc02014c4 <vprintfmt+0x1ce>
ffffffffc0201496:	000cc563          	bltz	s9,ffffffffc02014a0 <vprintfmt+0x1aa>
ffffffffc020149a:	3cfd                	addiw	s9,s9,-1
ffffffffc020149c:	036c8263          	beq	s9,s6,ffffffffc02014c0 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02014a0:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014a2:	18098463          	beqz	s3,ffffffffc020162a <vprintfmt+0x334>
ffffffffc02014a6:	3781                	addiw	a5,a5,-32
ffffffffc02014a8:	18fbf163          	bleu	a5,s7,ffffffffc020162a <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02014ac:	03f00513          	li	a0,63
ffffffffc02014b0:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014b2:	0405                	addi	s0,s0,1
ffffffffc02014b4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02014b8:	3dfd                	addiw	s11,s11,-1
ffffffffc02014ba:	0007851b          	sext.w	a0,a5
ffffffffc02014be:	fd61                	bnez	a0,ffffffffc0201496 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc02014c0:	e7b058e3          	blez	s11,ffffffffc0201330 <vprintfmt+0x3a>
ffffffffc02014c4:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014c6:	85a6                	mv	a1,s1
ffffffffc02014c8:	02000513          	li	a0,32
ffffffffc02014cc:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014ce:	e60d81e3          	beqz	s11,ffffffffc0201330 <vprintfmt+0x3a>
ffffffffc02014d2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02014d4:	85a6                	mv	a1,s1
ffffffffc02014d6:	02000513          	li	a0,32
ffffffffc02014da:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014dc:	fe0d94e3          	bnez	s11,ffffffffc02014c4 <vprintfmt+0x1ce>
ffffffffc02014e0:	bd81                	j	ffffffffc0201330 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014e2:	4705                	li	a4,1
ffffffffc02014e4:	008a8593          	addi	a1,s5,8
ffffffffc02014e8:	01074463          	blt	a4,a6,ffffffffc02014f0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02014ec:	12080063          	beqz	a6,ffffffffc020160c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02014f0:	000ab603          	ld	a2,0(s5)
ffffffffc02014f4:	46a9                	li	a3,10
ffffffffc02014f6:	8aae                	mv	s5,a1
ffffffffc02014f8:	b7bd                	j	ffffffffc0201466 <vprintfmt+0x170>
ffffffffc02014fa:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02014fe:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201502:	846a                	mv	s0,s10
ffffffffc0201504:	b5ad                	j	ffffffffc020136e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201506:	85a6                	mv	a1,s1
ffffffffc0201508:	02500513          	li	a0,37
ffffffffc020150c:	9902                	jalr	s2
            break;
ffffffffc020150e:	b50d                	j	ffffffffc0201330 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0201510:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201514:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201518:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020151a:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020151c:	e40dd9e3          	bgez	s11,ffffffffc020136e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201520:	8de6                	mv	s11,s9
ffffffffc0201522:	5cfd                	li	s9,-1
ffffffffc0201524:	b5a9                	j	ffffffffc020136e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0201526:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020152a:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020152e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201530:	bd3d                	j	ffffffffc020136e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0201532:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201536:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020153a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020153c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201540:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201544:	fcd56ce3          	bltu	a0,a3,ffffffffc020151c <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201548:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020154a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc020154e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201552:	0196873b          	addw	a4,a3,s9
ffffffffc0201556:	0017171b          	slliw	a4,a4,0x1
ffffffffc020155a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc020155e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201562:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201566:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020156a:	fcd57fe3          	bleu	a3,a0,ffffffffc0201548 <vprintfmt+0x252>
ffffffffc020156e:	b77d                	j	ffffffffc020151c <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201570:	fffdc693          	not	a3,s11
ffffffffc0201574:	96fd                	srai	a3,a3,0x3f
ffffffffc0201576:	00ddfdb3          	and	s11,s11,a3
ffffffffc020157a:	00144603          	lbu	a2,1(s0)
ffffffffc020157e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201580:	846a                	mv	s0,s10
ffffffffc0201582:	b3f5                	j	ffffffffc020136e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201584:	85a6                	mv	a1,s1
ffffffffc0201586:	02500513          	li	a0,37
ffffffffc020158a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020158c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201590:	02500793          	li	a5,37
ffffffffc0201594:	8d22                	mv	s10,s0
ffffffffc0201596:	d8f70de3          	beq	a4,a5,ffffffffc0201330 <vprintfmt+0x3a>
ffffffffc020159a:	02500713          	li	a4,37
ffffffffc020159e:	1d7d                	addi	s10,s10,-1
ffffffffc02015a0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02015a4:	fee79de3          	bne	a5,a4,ffffffffc020159e <vprintfmt+0x2a8>
ffffffffc02015a8:	b361                	j	ffffffffc0201330 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015aa:	00001617          	auipc	a2,0x1
ffffffffc02015ae:	f5e60613          	addi	a2,a2,-162 # ffffffffc0202508 <error_string+0xd8>
ffffffffc02015b2:	85a6                	mv	a1,s1
ffffffffc02015b4:	854a                	mv	a0,s2
ffffffffc02015b6:	0ac000ef          	jal	ra,ffffffffc0201662 <printfmt>
ffffffffc02015ba:	bb9d                	j	ffffffffc0201330 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02015bc:	00001617          	auipc	a2,0x1
ffffffffc02015c0:	f4460613          	addi	a2,a2,-188 # ffffffffc0202500 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02015c4:	00001417          	auipc	s0,0x1
ffffffffc02015c8:	f3d40413          	addi	s0,s0,-195 # ffffffffc0202501 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015cc:	8532                	mv	a0,a2
ffffffffc02015ce:	85e6                	mv	a1,s9
ffffffffc02015d0:	e032                	sd	a2,0(sp)
ffffffffc02015d2:	e43e                	sd	a5,8(sp)
ffffffffc02015d4:	c37ff0ef          	jal	ra,ffffffffc020120a <strnlen>
ffffffffc02015d8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02015dc:	6602                	ld	a2,0(sp)
ffffffffc02015de:	01b05d63          	blez	s11,ffffffffc02015f8 <vprintfmt+0x302>
ffffffffc02015e2:	67a2                	ld	a5,8(sp)
ffffffffc02015e4:	2781                	sext.w	a5,a5
ffffffffc02015e6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02015e8:	6522                	ld	a0,8(sp)
ffffffffc02015ea:	85a6                	mv	a1,s1
ffffffffc02015ec:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015ee:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02015f0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015f2:	6602                	ld	a2,0(sp)
ffffffffc02015f4:	fe0d9ae3          	bnez	s11,ffffffffc02015e8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015f8:	00064783          	lbu	a5,0(a2)
ffffffffc02015fc:	0007851b          	sext.w	a0,a5
ffffffffc0201600:	e8051be3          	bnez	a0,ffffffffc0201496 <vprintfmt+0x1a0>
ffffffffc0201604:	b335                	j	ffffffffc0201330 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201606:	000aa403          	lw	s0,0(s5)
ffffffffc020160a:	bbf1                	j	ffffffffc02013e6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020160c:	000ae603          	lwu	a2,0(s5)
ffffffffc0201610:	46a9                	li	a3,10
ffffffffc0201612:	8aae                	mv	s5,a1
ffffffffc0201614:	bd89                	j	ffffffffc0201466 <vprintfmt+0x170>
ffffffffc0201616:	000ae603          	lwu	a2,0(s5)
ffffffffc020161a:	46c1                	li	a3,16
ffffffffc020161c:	8aae                	mv	s5,a1
ffffffffc020161e:	b5a1                	j	ffffffffc0201466 <vprintfmt+0x170>
ffffffffc0201620:	000ae603          	lwu	a2,0(s5)
ffffffffc0201624:	46a1                	li	a3,8
ffffffffc0201626:	8aae                	mv	s5,a1
ffffffffc0201628:	bd3d                	j	ffffffffc0201466 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020162a:	9902                	jalr	s2
ffffffffc020162c:	b559                	j	ffffffffc02014b2 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc020162e:	85a6                	mv	a1,s1
ffffffffc0201630:	02d00513          	li	a0,45
ffffffffc0201634:	e03e                	sd	a5,0(sp)
ffffffffc0201636:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201638:	8ace                	mv	s5,s3
ffffffffc020163a:	40800633          	neg	a2,s0
ffffffffc020163e:	46a9                	li	a3,10
ffffffffc0201640:	6782                	ld	a5,0(sp)
ffffffffc0201642:	b515                	j	ffffffffc0201466 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0201644:	01b05663          	blez	s11,ffffffffc0201650 <vprintfmt+0x35a>
ffffffffc0201648:	02d00693          	li	a3,45
ffffffffc020164c:	f6d798e3          	bne	a5,a3,ffffffffc02015bc <vprintfmt+0x2c6>
ffffffffc0201650:	00001417          	auipc	s0,0x1
ffffffffc0201654:	eb140413          	addi	s0,s0,-335 # ffffffffc0202501 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201658:	02800513          	li	a0,40
ffffffffc020165c:	02800793          	li	a5,40
ffffffffc0201660:	bd1d                	j	ffffffffc0201496 <vprintfmt+0x1a0>

ffffffffc0201662 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201662:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201664:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201668:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020166a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020166c:	ec06                	sd	ra,24(sp)
ffffffffc020166e:	f83a                	sd	a4,48(sp)
ffffffffc0201670:	fc3e                	sd	a5,56(sp)
ffffffffc0201672:	e0c2                	sd	a6,64(sp)
ffffffffc0201674:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201676:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201678:	c7fff0ef          	jal	ra,ffffffffc02012f6 <vprintfmt>
}
ffffffffc020167c:	60e2                	ld	ra,24(sp)
ffffffffc020167e:	6161                	addi	sp,sp,80
ffffffffc0201680:	8082                	ret

ffffffffc0201682 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201682:	715d                	addi	sp,sp,-80
ffffffffc0201684:	e486                	sd	ra,72(sp)
ffffffffc0201686:	e0a2                	sd	s0,64(sp)
ffffffffc0201688:	fc26                	sd	s1,56(sp)
ffffffffc020168a:	f84a                	sd	s2,48(sp)
ffffffffc020168c:	f44e                	sd	s3,40(sp)
ffffffffc020168e:	f052                	sd	s4,32(sp)
ffffffffc0201690:	ec56                	sd	s5,24(sp)
ffffffffc0201692:	e85a                	sd	s6,16(sp)
ffffffffc0201694:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201696:	c901                	beqz	a0,ffffffffc02016a6 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201698:	85aa                	mv	a1,a0
ffffffffc020169a:	00001517          	auipc	a0,0x1
ffffffffc020169e:	e7e50513          	addi	a0,a0,-386 # ffffffffc0202518 <error_string+0xe8>
ffffffffc02016a2:	a15fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02016a6:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016a8:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02016aa:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02016ac:	4aa9                	li	s5,10
ffffffffc02016ae:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02016b0:	00005b97          	auipc	s7,0x5
ffffffffc02016b4:	960b8b93          	addi	s7,s7,-1696 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016b8:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02016bc:	a73fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02016c0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02016c2:	00054b63          	bltz	a0,ffffffffc02016d8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016c6:	00a95b63          	ble	a0,s2,ffffffffc02016dc <readline+0x5a>
ffffffffc02016ca:	029a5463          	ble	s1,s4,ffffffffc02016f2 <readline+0x70>
        c = getchar();
ffffffffc02016ce:	a61fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02016d2:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02016d4:	fe0559e3          	bgez	a0,ffffffffc02016c6 <readline+0x44>
            return NULL;
ffffffffc02016d8:	4501                	li	a0,0
ffffffffc02016da:	a099                	j	ffffffffc0201720 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02016dc:	03341463          	bne	s0,s3,ffffffffc0201704 <readline+0x82>
ffffffffc02016e0:	e8b9                	bnez	s1,ffffffffc0201736 <readline+0xb4>
        c = getchar();
ffffffffc02016e2:	a4dfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02016e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02016e8:	fe0548e3          	bltz	a0,ffffffffc02016d8 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016ec:	fea958e3          	ble	a0,s2,ffffffffc02016dc <readline+0x5a>
ffffffffc02016f0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02016f2:	8522                	mv	a0,s0
ffffffffc02016f4:	9f7fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02016f8:	009b87b3          	add	a5,s7,s1
ffffffffc02016fc:	00878023          	sb	s0,0(a5)
ffffffffc0201700:	2485                	addiw	s1,s1,1
ffffffffc0201702:	bf6d                	j	ffffffffc02016bc <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201704:	01540463          	beq	s0,s5,ffffffffc020170c <readline+0x8a>
ffffffffc0201708:	fb641ae3          	bne	s0,s6,ffffffffc02016bc <readline+0x3a>
            cputchar(c);
ffffffffc020170c:	8522                	mv	a0,s0
ffffffffc020170e:	9ddfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc0201712:	00005517          	auipc	a0,0x5
ffffffffc0201716:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206010 <edata>
ffffffffc020171a:	94aa                	add	s1,s1,a0
ffffffffc020171c:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201720:	60a6                	ld	ra,72(sp)
ffffffffc0201722:	6406                	ld	s0,64(sp)
ffffffffc0201724:	74e2                	ld	s1,56(sp)
ffffffffc0201726:	7942                	ld	s2,48(sp)
ffffffffc0201728:	79a2                	ld	s3,40(sp)
ffffffffc020172a:	7a02                	ld	s4,32(sp)
ffffffffc020172c:	6ae2                	ld	s5,24(sp)
ffffffffc020172e:	6b42                	ld	s6,16(sp)
ffffffffc0201730:	6ba2                	ld	s7,8(sp)
ffffffffc0201732:	6161                	addi	sp,sp,80
ffffffffc0201734:	8082                	ret
            cputchar(c);
ffffffffc0201736:	4521                	li	a0,8
ffffffffc0201738:	9b3fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc020173c:	34fd                	addiw	s1,s1,-1
ffffffffc020173e:	bfbd                	j	ffffffffc02016bc <readline+0x3a>

ffffffffc0201740 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201740:	00005797          	auipc	a5,0x5
ffffffffc0201744:	8c878793          	addi	a5,a5,-1848 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201748:	6398                	ld	a4,0(a5)
ffffffffc020174a:	4781                	li	a5,0
ffffffffc020174c:	88ba                	mv	a7,a4
ffffffffc020174e:	852a                	mv	a0,a0
ffffffffc0201750:	85be                	mv	a1,a5
ffffffffc0201752:	863e                	mv	a2,a5
ffffffffc0201754:	00000073          	ecall
ffffffffc0201758:	87aa                	mv	a5,a0
}
ffffffffc020175a:	8082                	ret

ffffffffc020175c <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc020175c:	00005797          	auipc	a5,0x5
ffffffffc0201760:	ccc78793          	addi	a5,a5,-820 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201764:	6398                	ld	a4,0(a5)
ffffffffc0201766:	4781                	li	a5,0
ffffffffc0201768:	88ba                	mv	a7,a4
ffffffffc020176a:	852a                	mv	a0,a0
ffffffffc020176c:	85be                	mv	a1,a5
ffffffffc020176e:	863e                	mv	a2,a5
ffffffffc0201770:	00000073          	ecall
ffffffffc0201774:	87aa                	mv	a5,a0
}
ffffffffc0201776:	8082                	ret

ffffffffc0201778 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201778:	00005797          	auipc	a5,0x5
ffffffffc020177c:	88878793          	addi	a5,a5,-1912 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201780:	639c                	ld	a5,0(a5)
ffffffffc0201782:	4501                	li	a0,0
ffffffffc0201784:	88be                	mv	a7,a5
ffffffffc0201786:	852a                	mv	a0,a0
ffffffffc0201788:	85aa                	mv	a1,a0
ffffffffc020178a:	862a                	mv	a2,a0
ffffffffc020178c:	00000073          	ecall
ffffffffc0201790:	852a                	mv	a0,a0
ffffffffc0201792:	2501                	sext.w	a0,a0
ffffffffc0201794:	8082                	ret
