
bin/kernel:     file format elf64-littleriscv


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
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02e50513          	addi	a0,a0,46 # ffffffffc020a060 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	5c660613          	addi	a2,a2,1478 # ffffffffc0215600 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	726040ef          	jal	ra,ffffffffc0204770 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4f6000ef          	jal	ra,ffffffffc0200544 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	b7658593          	addi	a1,a1,-1162 # ffffffffc0204bc8 <etext+0x6>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0204be8 <etext+0x26>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	783000ef          	jal	ra,ffffffffc0200fec <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	548000ef          	jal	ra,ffffffffc02005b6 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5c2000ef          	jal	ra,ffffffffc0200634 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	038020ef          	jal	ra,ffffffffc02020ae <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	3c2040ef          	jal	ra,ffffffffc020443c <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	41e000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	20f020ef          	jal	ra,ffffffffc0202a90 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	46c000ef          	jal	ra,ffffffffc02004f2 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	52e000ef          	jal	ra,ffffffffc02005b8 <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	584040ef          	jal	ra,ffffffffc0204612 <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	4ac000ef          	jal	ra,ffffffffc0200546 <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	76a040ef          	jal	ra,ffffffffc020482a <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	734040ef          	jal	ra,ffffffffc020482a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a191                	j	ffffffffc0200546 <cons_putc>

ffffffffc0200104 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
ffffffffc0200106:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200108:	472000ef          	jal	ra,ffffffffc020057a <cons_getc>
ffffffffc020010c:	dd75                	beqz	a0,ffffffffc0200108 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010e:	60a2                	ld	ra,8(sp)
ffffffffc0200110:	0141                	addi	sp,sp,16
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200114:	715d                	addi	sp,sp,-80
ffffffffc0200116:	e486                	sd	ra,72(sp)
ffffffffc0200118:	e0a6                	sd	s1,64(sp)
ffffffffc020011a:	fc4a                	sd	s2,56(sp)
ffffffffc020011c:	f84e                	sd	s3,48(sp)
ffffffffc020011e:	f452                	sd	s4,40(sp)
ffffffffc0200120:	f056                	sd	s5,32(sp)
ffffffffc0200122:	ec5a                	sd	s6,24(sp)
ffffffffc0200124:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200126:	c901                	beqz	a0,ffffffffc0200136 <readline+0x22>
ffffffffc0200128:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020012a:	00005517          	auipc	a0,0x5
ffffffffc020012e:	ac650513          	addi	a0,a0,-1338 # ffffffffc0204bf0 <etext+0x2e>
ffffffffc0200132:	f9bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200136:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200138:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020013c:	4aa9                	li	s5,10
ffffffffc020013e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200140:	0000ab97          	auipc	s7,0xa
ffffffffc0200144:	f20b8b93          	addi	s7,s7,-224 # ffffffffc020a060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200148:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020014c:	fb9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200150:	00054a63          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	00a95a63          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc0200158:	029a5263          	bge	s4,s1,ffffffffc020017c <readline+0x68>
        c = getchar();
ffffffffc020015c:	fa9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200160:	fe055ae3          	bgez	a0,ffffffffc0200154 <readline+0x40>
            return NULL;
ffffffffc0200164:	4501                	li	a0,0
ffffffffc0200166:	a091                	j	ffffffffc02001aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200168:	03351463          	bne	a0,s3,ffffffffc0200190 <readline+0x7c>
ffffffffc020016c:	e8a9                	bnez	s1,ffffffffc02001be <readline+0xaa>
        c = getchar();
ffffffffc020016e:	f97ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200172:	fe0549e3          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200176:	fea959e3          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc020017a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020017c:	e42a                	sd	a0,8(sp)
ffffffffc020017e:	f85ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc0200182:	6522                	ld	a0,8(sp)
ffffffffc0200184:	009b87b3          	add	a5,s7,s1
ffffffffc0200188:	2485                	addiw	s1,s1,1
ffffffffc020018a:	00a78023          	sb	a0,0(a5)
ffffffffc020018e:	bf7d                	j	ffffffffc020014c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200190:	01550463          	beq	a0,s5,ffffffffc0200198 <readline+0x84>
ffffffffc0200194:	fb651ce3          	bne	a0,s6,ffffffffc020014c <readline+0x38>
            cputchar(c);
ffffffffc0200198:	f6bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc020019c:	0000a517          	auipc	a0,0xa
ffffffffc02001a0:	ec450513          	addi	a0,a0,-316 # ffffffffc020a060 <buf>
ffffffffc02001a4:	94aa                	add	s1,s1,a0
ffffffffc02001a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001aa:	60a6                	ld	ra,72(sp)
ffffffffc02001ac:	6486                	ld	s1,64(sp)
ffffffffc02001ae:	7962                	ld	s2,56(sp)
ffffffffc02001b0:	79c2                	ld	s3,48(sp)
ffffffffc02001b2:	7a22                	ld	s4,40(sp)
ffffffffc02001b4:	7a82                	ld	s5,32(sp)
ffffffffc02001b6:	6b62                	ld	s6,24(sp)
ffffffffc02001b8:	6bc2                	ld	s7,16(sp)
ffffffffc02001ba:	6161                	addi	sp,sp,80
ffffffffc02001bc:	8082                	ret
            cputchar(c);
ffffffffc02001be:	4521                	li	a0,8
ffffffffc02001c0:	f43ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc02001c4:	34fd                	addiw	s1,s1,-1
ffffffffc02001c6:	b759                	j	ffffffffc020014c <readline+0x38>

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00015317          	auipc	t1,0x15
ffffffffc02001cc:	2a830313          	addi	t1,t1,680 # ffffffffc0215470 <is_panic>
ffffffffc02001d0:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	e822                	sd	s0,16(sp)
ffffffffc02001da:	f436                	sd	a3,40(sp)
ffffffffc02001dc:	f83a                	sd	a4,48(sp)
ffffffffc02001de:	fc3e                	sd	a5,56(sp)
ffffffffc02001e0:	e0c2                	sd	a6,64(sp)
ffffffffc02001e2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e4:	020e1a63          	bnez	t3,ffffffffc0200218 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001e8:	4785                	li	a5,1
ffffffffc02001ea:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001ee:	8432                	mv	s0,a2
ffffffffc02001f0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f2:	862e                	mv	a2,a1
ffffffffc02001f4:	85aa                	mv	a1,a0
ffffffffc02001f6:	00005517          	auipc	a0,0x5
ffffffffc02001fa:	a0250513          	addi	a0,a0,-1534 # ffffffffc0204bf8 <etext+0x36>
    va_start(ap, fmt);
ffffffffc02001fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	ecdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200204:	65a2                	ld	a1,8(sp)
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	ea5ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020020c:	00005517          	auipc	a0,0x5
ffffffffc0200210:	78c50513          	addi	a0,a0,1932 # ffffffffc0205998 <commands+0xb48>
ffffffffc0200214:	eb9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200218:	3a6000ef          	jal	ra,ffffffffc02005be <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	130000ef          	jal	ra,ffffffffc020034e <kmonitor>
    while (1) {
ffffffffc0200222:	bfed                	j	ffffffffc020021c <__panic+0x54>

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00005517          	auipc	a0,0x5
ffffffffc020022a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204c18 <etext+0x56>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00005517          	auipc	a0,0x5
ffffffffc0200240:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0204c38 <etext+0x76>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00005597          	auipc	a1,0x5
ffffffffc020024c:	97a58593          	addi	a1,a1,-1670 # ffffffffc0204bc2 <etext>
ffffffffc0200250:	00005517          	auipc	a0,0x5
ffffffffc0200254:	a0850513          	addi	a0,a0,-1528 # ffffffffc0204c58 <etext+0x96>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	e0458593          	addi	a1,a1,-508 # ffffffffc020a060 <buf>
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204c78 <etext+0xb6>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	39058593          	addi	a1,a1,912 # ffffffffc0215600 <end>
ffffffffc0200278:	00005517          	auipc	a0,0x5
ffffffffc020027c:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204c98 <etext+0xd6>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00015597          	auipc	a1,0x15
ffffffffc0200288:	77b58593          	addi	a1,a1,1915 # ffffffffc02159ff <end+0x3ff>
ffffffffc020028c:	00000797          	auipc	a5,0x0
ffffffffc0200290:	da678793          	addi	a5,a5,-602 # ffffffffc0200032 <kern_init>
ffffffffc0200294:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00005517          	auipc	a0,0x5
ffffffffc02002aa:	a1250513          	addi	a0,a0,-1518 # ffffffffc0204cb8 <etext+0xf6>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	bd31                	j	ffffffffc02000cc <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00005617          	auipc	a2,0x5
ffffffffc02002b8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204ce8 <etext+0x126>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d00 <etext+0x13e>
void print_stackframe(void) {
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	effff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d0:	00005617          	auipc	a2,0x5
ffffffffc02002d4:	a4860613          	addi	a2,a2,-1464 # ffffffffc0204d18 <etext+0x156>
ffffffffc02002d8:	00005597          	auipc	a1,0x5
ffffffffc02002dc:	a6058593          	addi	a1,a1,-1440 # ffffffffc0204d38 <etext+0x176>
ffffffffc02002e0:	00005517          	auipc	a0,0x5
ffffffffc02002e4:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204d40 <etext+0x17e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00005617          	auipc	a2,0x5
ffffffffc02002f2:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204d50 <etext+0x18e>
ffffffffc02002f6:	00005597          	auipc	a1,0x5
ffffffffc02002fa:	a8258593          	addi	a1,a1,-1406 # ffffffffc0204d78 <etext+0x1b6>
ffffffffc02002fe:	00005517          	auipc	a0,0x5
ffffffffc0200302:	a4250513          	addi	a0,a0,-1470 # ffffffffc0204d40 <etext+0x17e>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00005617          	auipc	a2,0x5
ffffffffc020030e:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204d88 <etext+0x1c6>
ffffffffc0200312:	00005597          	auipc	a1,0x5
ffffffffc0200316:	a9658593          	addi	a1,a1,-1386 # ffffffffc0204da8 <etext+0x1e6>
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	a2650513          	addi	a0,a0,-1498 # ffffffffc0204d40 <etext+0x17e>
ffffffffc0200322:	dabff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200332:	ef3ff0ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200342:	f71ff0ef          	jal	ra,ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034e:	7115                	addi	sp,sp,-224
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	00005517          	auipc	a0,0x5
ffffffffc0200358:	a6450513          	addi	a0,a0,-1436 # ffffffffc0204db8 <etext+0x1f6>
kmonitor(struct trapframe *tf) {
ffffffffc020035c:	ed86                	sd	ra,216(sp)
ffffffffc020035e:	e9a2                	sd	s0,208(sp)
ffffffffc0200360:	e5a6                	sd	s1,200(sp)
ffffffffc0200362:	e1ca                	sd	s2,192(sp)
ffffffffc0200364:	fd4e                	sd	s3,184(sp)
ffffffffc0200366:	f952                	sd	s4,176(sp)
ffffffffc0200368:	f556                	sd	s5,168(sp)
ffffffffc020036a:	f15a                	sd	s6,160(sp)
ffffffffc020036c:	ed5e                	sd	s7,152(sp)
ffffffffc020036e:	e566                	sd	s9,136(sp)
ffffffffc0200370:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200372:	d5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200376:	00005517          	auipc	a0,0x5
ffffffffc020037a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204de0 <etext+0x21e>
ffffffffc020037e:	d4fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200382:	000c0563          	beqz	s8,ffffffffc020038c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200386:	8562                	mv	a0,s8
ffffffffc0200388:	494000ef          	jal	ra,ffffffffc020081c <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020038c:	4501                	li	a0,0
ffffffffc020038e:	4581                	li	a1,0
ffffffffc0200390:	4601                	li	a2,0
ffffffffc0200392:	48a1                	li	a7,8
ffffffffc0200394:	00000073          	ecall
ffffffffc0200398:	00005c97          	auipc	s9,0x5
ffffffffc020039c:	ab8c8c93          	addi	s9,s9,-1352 # ffffffffc0204e50 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00005997          	auipc	s3,0x5
ffffffffc02003a4:	a6898993          	addi	s3,s3,-1432 # ffffffffc0204e08 <etext+0x246>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00005917          	auipc	s2,0x5
ffffffffc02003ac:	a6890913          	addi	s2,s2,-1432 # ffffffffc0204e10 <etext+0x24e>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00005b17          	auipc	s6,0x5
ffffffffc02003b6:	a66b0b13          	addi	s6,s6,-1434 # ffffffffc0204e18 <etext+0x256>
ffffffffc02003ba:	00005a97          	auipc	s5,0x5
ffffffffc02003be:	97ea8a93          	addi	s5,s5,-1666 # ffffffffc0204d38 <etext+0x176>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003c4:	854e                	mv	a0,s3
ffffffffc02003c6:	d4fff0ef          	jal	ra,ffffffffc0200114 <readline>
ffffffffc02003ca:	842a                	mv	s0,a0
ffffffffc02003cc:	dd65                	beqz	a0,ffffffffc02003c4 <kmonitor+0x76>
ffffffffc02003ce:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003d2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	c999                	beqz	a1,ffffffffc02003ea <kmonitor+0x9c>
ffffffffc02003d6:	854a                	mv	a0,s2
ffffffffc02003d8:	382040ef          	jal	ra,ffffffffc020475a <strchr>
ffffffffc02003dc:	c925                	beqz	a0,ffffffffc020044c <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc02003de:	00144583          	lbu	a1,1(s0)
ffffffffc02003e2:	00040023          	sb	zero,0(s0)
ffffffffc02003e6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e8:	f5fd                	bnez	a1,ffffffffc02003d6 <kmonitor+0x88>
    if (argc == 0) {
ffffffffc02003ea:	dce9                	beqz	s1,ffffffffc02003c4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ec:	6582                	ld	a1,0(sp)
ffffffffc02003ee:	00005d17          	auipc	s10,0x5
ffffffffc02003f2:	a62d0d13          	addi	s10,s10,-1438 # ffffffffc0204e50 <commands>
ffffffffc02003f6:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f8:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	340040ef          	jal	ra,ffffffffc020473c <strcmp>
ffffffffc0200400:	c919                	beqz	a0,ffffffffc0200416 <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200402:	2405                	addiw	s0,s0,1
ffffffffc0200404:	09740463          	beq	s0,s7,ffffffffc020048c <kmonitor+0x13e>
ffffffffc0200408:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040c:	6582                	ld	a1,0(sp)
ffffffffc020040e:	0d61                	addi	s10,s10,24
ffffffffc0200410:	32c040ef          	jal	ra,ffffffffc020473c <strcmp>
ffffffffc0200414:	f57d                	bnez	a0,ffffffffc0200402 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200416:	00141793          	slli	a5,s0,0x1
ffffffffc020041a:	97a2                	add	a5,a5,s0
ffffffffc020041c:	078e                	slli	a5,a5,0x3
ffffffffc020041e:	97e6                	add	a5,a5,s9
ffffffffc0200420:	6b9c                	ld	a5,16(a5)
ffffffffc0200422:	8662                	mv	a2,s8
ffffffffc0200424:	002c                	addi	a1,sp,8
ffffffffc0200426:	fff4851b          	addiw	a0,s1,-1
ffffffffc020042a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020042c:	f8055ce3          	bgez	a0,ffffffffc02003c4 <kmonitor+0x76>
}
ffffffffc0200430:	60ee                	ld	ra,216(sp)
ffffffffc0200432:	644e                	ld	s0,208(sp)
ffffffffc0200434:	64ae                	ld	s1,200(sp)
ffffffffc0200436:	690e                	ld	s2,192(sp)
ffffffffc0200438:	79ea                	ld	s3,184(sp)
ffffffffc020043a:	7a4a                	ld	s4,176(sp)
ffffffffc020043c:	7aaa                	ld	s5,168(sp)
ffffffffc020043e:	7b0a                	ld	s6,160(sp)
ffffffffc0200440:	6bea                	ld	s7,152(sp)
ffffffffc0200442:	6c4a                	ld	s8,144(sp)
ffffffffc0200444:	6caa                	ld	s9,136(sp)
ffffffffc0200446:	6d0a                	ld	s10,128(sp)
ffffffffc0200448:	612d                	addi	sp,sp,224
ffffffffc020044a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020044c:	00044783          	lbu	a5,0(s0)
ffffffffc0200450:	dfc9                	beqz	a5,ffffffffc02003ea <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200452:	03448863          	beq	s1,s4,ffffffffc0200482 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc0200456:	00349793          	slli	a5,s1,0x3
ffffffffc020045a:	0118                	addi	a4,sp,128
ffffffffc020045c:	97ba                	add	a5,a5,a4
ffffffffc020045e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200462:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200466:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200468:	e591                	bnez	a1,ffffffffc0200474 <kmonitor+0x126>
ffffffffc020046a:	b749                	j	ffffffffc02003ec <kmonitor+0x9e>
ffffffffc020046c:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200470:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200472:	ddad                	beqz	a1,ffffffffc02003ec <kmonitor+0x9e>
ffffffffc0200474:	854a                	mv	a0,s2
ffffffffc0200476:	2e4040ef          	jal	ra,ffffffffc020475a <strchr>
ffffffffc020047a:	d96d                	beqz	a0,ffffffffc020046c <kmonitor+0x11e>
ffffffffc020047c:	00044583          	lbu	a1,0(s0)
ffffffffc0200480:	bf91                	j	ffffffffc02003d4 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200482:	45c1                	li	a1,16
ffffffffc0200484:	855a                	mv	a0,s6
ffffffffc0200486:	c47ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020048a:	b7f1                	j	ffffffffc0200456 <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020048c:	6582                	ld	a1,0(sp)
ffffffffc020048e:	00005517          	auipc	a0,0x5
ffffffffc0200492:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0204e38 <etext+0x276>
ffffffffc0200496:	c37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc020049a:	b72d                	j	ffffffffc02003c4 <kmonitor+0x76>

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	fb678793          	addi	a5,a5,-74 # ffffffffc020a460 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	2c0040ef          	jal	ra,ffffffffc0204782 <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004ce:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d2:	0000a517          	auipc	a0,0xa
ffffffffc02004d6:	f8e50513          	addi	a0,a0,-114 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc02004da:	1141                	addi	sp,sp,-16
ffffffffc02004dc:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	953e                	add	a0,a0,a5
ffffffffc02004e0:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004e4:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e6:	29c040ef          	jal	ra,ffffffffc0204782 <memcpy>
    return 0;
}
ffffffffc02004ea:	60a2                	ld	ra,8(sp)
ffffffffc02004ec:	4501                	li	a0,0
ffffffffc02004ee:	0141                	addi	sp,sp,16
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f2:	67e1                	lui	a5,0x18
ffffffffc02004f4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004f8:	00015717          	auipc	a4,0x15
ffffffffc02004fc:	f8f73023          	sd	a5,-128(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200500:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200504:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200506:	953e                	add	a0,a0,a5
ffffffffc0200508:	4601                	li	a2,0
ffffffffc020050a:	4881                	li	a7,0
ffffffffc020050c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200510:	02000793          	li	a5,32
ffffffffc0200514:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200518:	00005517          	auipc	a0,0x5
ffffffffc020051c:	98050513          	addi	a0,a0,-1664 # ffffffffc0204e98 <commands+0x48>
    ticks = 0;
ffffffffc0200520:	00015797          	auipc	a5,0x15
ffffffffc0200524:	fa07b823          	sd	zero,-80(a5) # ffffffffc02154d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200528:	b655                	j	ffffffffc02000cc <cprintf>

ffffffffc020052a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020052e:	00015797          	auipc	a5,0x15
ffffffffc0200532:	f4a7b783          	ld	a5,-182(a5) # ffffffffc0215478 <timebase>
ffffffffc0200536:	953e                	add	a0,a0,a5
ffffffffc0200538:	4581                	li	a1,0
ffffffffc020053a:	4601                	li	a2,0
ffffffffc020053c:	4881                	li	a7,0
ffffffffc020053e:	00000073          	ecall
ffffffffc0200542:	8082                	ret

ffffffffc0200544 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200544:	8082                	ret

ffffffffc0200546 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200546:	100027f3          	csrr	a5,sstatus
ffffffffc020054a:	8b89                	andi	a5,a5,2
ffffffffc020054c:	0ff57513          	andi	a0,a0,255
ffffffffc0200550:	e799                	bnez	a5,ffffffffc020055e <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200552:	4581                	li	a1,0
ffffffffc0200554:	4601                	li	a2,0
ffffffffc0200556:	4885                	li	a7,1
ffffffffc0200558:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020055c:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020055e:	1101                	addi	sp,sp,-32
ffffffffc0200560:	ec06                	sd	ra,24(sp)
ffffffffc0200562:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200564:	05a000ef          	jal	ra,ffffffffc02005be <intr_disable>
ffffffffc0200568:	6522                	ld	a0,8(sp)
ffffffffc020056a:	4581                	li	a1,0
ffffffffc020056c:	4601                	li	a2,0
ffffffffc020056e:	4885                	li	a7,1
ffffffffc0200570:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200574:	60e2                	ld	ra,24(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200578:	a081                	j	ffffffffc02005b8 <intr_enable>

ffffffffc020057a <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
ffffffffc0200580:	eb89                	bnez	a5,ffffffffc0200592 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200582:	4501                	li	a0,0
ffffffffc0200584:	4581                	li	a1,0
ffffffffc0200586:	4601                	li	a2,0
ffffffffc0200588:	4889                	li	a7,2
ffffffffc020058a:	00000073          	ecall
ffffffffc020058e:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200590:	8082                	ret
int cons_getc(void) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200596:	028000ef          	jal	ra,ffffffffc02005be <intr_disable>
ffffffffc020059a:	4501                	li	a0,0
ffffffffc020059c:	4581                	li	a1,0
ffffffffc020059e:	4601                	li	a2,0
ffffffffc02005a0:	4889                	li	a7,2
ffffffffc02005a2:	00000073          	ecall
ffffffffc02005a6:	2501                	sext.w	a0,a0
ffffffffc02005a8:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005aa:	00e000ef          	jal	ra,ffffffffc02005b8 <intr_enable>
}
ffffffffc02005ae:	60e2                	ld	ra,24(sp)
ffffffffc02005b0:	6522                	ld	a0,8(sp)
ffffffffc02005b2:	6105                	addi	sp,sp,32
ffffffffc02005b4:	8082                	ret

ffffffffc02005b6 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005b6:	8082                	ret

ffffffffc02005b8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005b8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005bc:	8082                	ret

ffffffffc02005be <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005be:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005c2:	8082                	ret

ffffffffc02005c4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005c4:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005c8:	1141                	addi	sp,sp,-16
ffffffffc02005ca:	e022                	sd	s0,0(sp)
ffffffffc02005cc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005ce:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d2:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005d6:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005d8:	05500613          	li	a2,85
ffffffffc02005dc:	c399                	beqz	a5,ffffffffc02005e2 <pgfault_handler+0x1e>
ffffffffc02005de:	04b00613          	li	a2,75
ffffffffc02005e2:	11843703          	ld	a4,280(s0)
ffffffffc02005e6:	47bd                	li	a5,15
ffffffffc02005e8:	05700693          	li	a3,87
ffffffffc02005ec:	00f70463          	beq	a4,a5,ffffffffc02005f4 <pgfault_handler+0x30>
ffffffffc02005f0:	05200693          	li	a3,82
ffffffffc02005f4:	00005517          	auipc	a0,0x5
ffffffffc02005f8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0204eb8 <commands+0x68>
ffffffffc02005fc:	ad1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200600:	00015517          	auipc	a0,0x15
ffffffffc0200604:	f0853503          	ld	a0,-248(a0) # ffffffffc0215508 <check_mm_struct>
ffffffffc0200608:	c911                	beqz	a0,ffffffffc020061c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020060a:	11043603          	ld	a2,272(s0)
ffffffffc020060e:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200612:	6402                	ld	s0,0(sp)
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200618:	7d30106f          	j	ffffffffc02025ea <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020061c:	00005617          	auipc	a2,0x5
ffffffffc0200620:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204ed8 <commands+0x88>
ffffffffc0200624:	06200593          	li	a1,98
ffffffffc0200628:	00005517          	auipc	a0,0x5
ffffffffc020062c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204ef0 <commands+0xa0>
ffffffffc0200630:	b99ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200634 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200634:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200638:	00000797          	auipc	a5,0x0
ffffffffc020063c:	47c78793          	addi	a5,a5,1148 # ffffffffc0200ab4 <__alltraps>
ffffffffc0200640:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200644:	000407b7          	lui	a5,0x40
ffffffffc0200648:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020064e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200650:	1141                	addi	sp,sp,-16
ffffffffc0200652:	e022                	sd	s0,0(sp)
ffffffffc0200654:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200656:	00005517          	auipc	a0,0x5
ffffffffc020065a:	8b250513          	addi	a0,a0,-1870 # ffffffffc0204f08 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc020065e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200660:	a6dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200664:	640c                	ld	a1,8(s0)
ffffffffc0200666:	00005517          	auipc	a0,0x5
ffffffffc020066a:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0204f20 <commands+0xd0>
ffffffffc020066e:	a5fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200672:	680c                	ld	a1,16(s0)
ffffffffc0200674:	00005517          	auipc	a0,0x5
ffffffffc0200678:	8c450513          	addi	a0,a0,-1852 # ffffffffc0204f38 <commands+0xe8>
ffffffffc020067c:	a51ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200680:	6c0c                	ld	a1,24(s0)
ffffffffc0200682:	00005517          	auipc	a0,0x5
ffffffffc0200686:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0204f50 <commands+0x100>
ffffffffc020068a:	a43ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020068e:	700c                	ld	a1,32(s0)
ffffffffc0200690:	00005517          	auipc	a0,0x5
ffffffffc0200694:	8d850513          	addi	a0,a0,-1832 # ffffffffc0204f68 <commands+0x118>
ffffffffc0200698:	a35ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020069c:	740c                	ld	a1,40(s0)
ffffffffc020069e:	00005517          	auipc	a0,0x5
ffffffffc02006a2:	8e250513          	addi	a0,a0,-1822 # ffffffffc0204f80 <commands+0x130>
ffffffffc02006a6:	a27ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006aa:	780c                	ld	a1,48(s0)
ffffffffc02006ac:	00005517          	auipc	a0,0x5
ffffffffc02006b0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0204f98 <commands+0x148>
ffffffffc02006b4:	a19ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006b8:	7c0c                	ld	a1,56(s0)
ffffffffc02006ba:	00005517          	auipc	a0,0x5
ffffffffc02006be:	8f650513          	addi	a0,a0,-1802 # ffffffffc0204fb0 <commands+0x160>
ffffffffc02006c2:	a0bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c6:	602c                	ld	a1,64(s0)
ffffffffc02006c8:	00005517          	auipc	a0,0x5
ffffffffc02006cc:	90050513          	addi	a0,a0,-1792 # ffffffffc0204fc8 <commands+0x178>
ffffffffc02006d0:	9fdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006d4:	642c                	ld	a1,72(s0)
ffffffffc02006d6:	00005517          	auipc	a0,0x5
ffffffffc02006da:	90a50513          	addi	a0,a0,-1782 # ffffffffc0204fe0 <commands+0x190>
ffffffffc02006de:	9efff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006e2:	682c                	ld	a1,80(s0)
ffffffffc02006e4:	00005517          	auipc	a0,0x5
ffffffffc02006e8:	91450513          	addi	a0,a0,-1772 # ffffffffc0204ff8 <commands+0x1a8>
ffffffffc02006ec:	9e1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006f0:	6c2c                	ld	a1,88(s0)
ffffffffc02006f2:	00005517          	auipc	a0,0x5
ffffffffc02006f6:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205010 <commands+0x1c0>
ffffffffc02006fa:	9d3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006fe:	702c                	ld	a1,96(s0)
ffffffffc0200700:	00005517          	auipc	a0,0x5
ffffffffc0200704:	92850513          	addi	a0,a0,-1752 # ffffffffc0205028 <commands+0x1d8>
ffffffffc0200708:	9c5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020070c:	742c                	ld	a1,104(s0)
ffffffffc020070e:	00005517          	auipc	a0,0x5
ffffffffc0200712:	93250513          	addi	a0,a0,-1742 # ffffffffc0205040 <commands+0x1f0>
ffffffffc0200716:	9b7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020071a:	782c                	ld	a1,112(s0)
ffffffffc020071c:	00005517          	auipc	a0,0x5
ffffffffc0200720:	93c50513          	addi	a0,a0,-1732 # ffffffffc0205058 <commands+0x208>
ffffffffc0200724:	9a9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200728:	7c2c                	ld	a1,120(s0)
ffffffffc020072a:	00005517          	auipc	a0,0x5
ffffffffc020072e:	94650513          	addi	a0,a0,-1722 # ffffffffc0205070 <commands+0x220>
ffffffffc0200732:	99bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200736:	604c                	ld	a1,128(s0)
ffffffffc0200738:	00005517          	auipc	a0,0x5
ffffffffc020073c:	95050513          	addi	a0,a0,-1712 # ffffffffc0205088 <commands+0x238>
ffffffffc0200740:	98dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200744:	644c                	ld	a1,136(s0)
ffffffffc0200746:	00005517          	auipc	a0,0x5
ffffffffc020074a:	95a50513          	addi	a0,a0,-1702 # ffffffffc02050a0 <commands+0x250>
ffffffffc020074e:	97fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200752:	684c                	ld	a1,144(s0)
ffffffffc0200754:	00005517          	auipc	a0,0x5
ffffffffc0200758:	96450513          	addi	a0,a0,-1692 # ffffffffc02050b8 <commands+0x268>
ffffffffc020075c:	971ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200760:	6c4c                	ld	a1,152(s0)
ffffffffc0200762:	00005517          	auipc	a0,0x5
ffffffffc0200766:	96e50513          	addi	a0,a0,-1682 # ffffffffc02050d0 <commands+0x280>
ffffffffc020076a:	963ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020076e:	704c                	ld	a1,160(s0)
ffffffffc0200770:	00005517          	auipc	a0,0x5
ffffffffc0200774:	97850513          	addi	a0,a0,-1672 # ffffffffc02050e8 <commands+0x298>
ffffffffc0200778:	955ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020077c:	744c                	ld	a1,168(s0)
ffffffffc020077e:	00005517          	auipc	a0,0x5
ffffffffc0200782:	98250513          	addi	a0,a0,-1662 # ffffffffc0205100 <commands+0x2b0>
ffffffffc0200786:	947ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020078a:	784c                	ld	a1,176(s0)
ffffffffc020078c:	00005517          	auipc	a0,0x5
ffffffffc0200790:	98c50513          	addi	a0,a0,-1652 # ffffffffc0205118 <commands+0x2c8>
ffffffffc0200794:	939ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200798:	7c4c                	ld	a1,184(s0)
ffffffffc020079a:	00005517          	auipc	a0,0x5
ffffffffc020079e:	99650513          	addi	a0,a0,-1642 # ffffffffc0205130 <commands+0x2e0>
ffffffffc02007a2:	92bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a6:	606c                	ld	a1,192(s0)
ffffffffc02007a8:	00005517          	auipc	a0,0x5
ffffffffc02007ac:	9a050513          	addi	a0,a0,-1632 # ffffffffc0205148 <commands+0x2f8>
ffffffffc02007b0:	91dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007b4:	646c                	ld	a1,200(s0)
ffffffffc02007b6:	00005517          	auipc	a0,0x5
ffffffffc02007ba:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205160 <commands+0x310>
ffffffffc02007be:	90fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007c2:	686c                	ld	a1,208(s0)
ffffffffc02007c4:	00005517          	auipc	a0,0x5
ffffffffc02007c8:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205178 <commands+0x328>
ffffffffc02007cc:	901ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007d0:	6c6c                	ld	a1,216(s0)
ffffffffc02007d2:	00005517          	auipc	a0,0x5
ffffffffc02007d6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205190 <commands+0x340>
ffffffffc02007da:	8f3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007de:	706c                	ld	a1,224(s0)
ffffffffc02007e0:	00005517          	auipc	a0,0x5
ffffffffc02007e4:	9c850513          	addi	a0,a0,-1592 # ffffffffc02051a8 <commands+0x358>
ffffffffc02007e8:	8e5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007ec:	746c                	ld	a1,232(s0)
ffffffffc02007ee:	00005517          	auipc	a0,0x5
ffffffffc02007f2:	9d250513          	addi	a0,a0,-1582 # ffffffffc02051c0 <commands+0x370>
ffffffffc02007f6:	8d7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007fa:	786c                	ld	a1,240(s0)
ffffffffc02007fc:	00005517          	auipc	a0,0x5
ffffffffc0200800:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02051d8 <commands+0x388>
ffffffffc0200804:	8c9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200808:	7c6c                	ld	a1,248(s0)
}
ffffffffc020080a:	6402                	ld	s0,0(sp)
ffffffffc020080c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020080e:	00005517          	auipc	a0,0x5
ffffffffc0200812:	9e250513          	addi	a0,a0,-1566 # ffffffffc02051f0 <commands+0x3a0>
}
ffffffffc0200816:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200818:	8b5ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020081c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020081c:	1141                	addi	sp,sp,-16
ffffffffc020081e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200820:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200822:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200824:	00005517          	auipc	a0,0x5
ffffffffc0200828:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205208 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020082c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020082e:	89fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200832:	8522                	mv	a0,s0
ffffffffc0200834:	e1bff0ef          	jal	ra,ffffffffc020064e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200838:	10043583          	ld	a1,256(s0)
ffffffffc020083c:	00005517          	auipc	a0,0x5
ffffffffc0200840:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205220 <commands+0x3d0>
ffffffffc0200844:	889ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200848:	10843583          	ld	a1,264(s0)
ffffffffc020084c:	00005517          	auipc	a0,0x5
ffffffffc0200850:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0205238 <commands+0x3e8>
ffffffffc0200854:	879ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200858:	11043583          	ld	a1,272(s0)
ffffffffc020085c:	00005517          	auipc	a0,0x5
ffffffffc0200860:	9f450513          	addi	a0,a0,-1548 # ffffffffc0205250 <commands+0x400>
ffffffffc0200864:	869ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200868:	11843583          	ld	a1,280(s0)
}
ffffffffc020086c:	6402                	ld	s0,0(sp)
ffffffffc020086e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200870:	00005517          	auipc	a0,0x5
ffffffffc0200874:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205268 <commands+0x418>
}
ffffffffc0200878:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	853ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc020087e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020087e:	11853783          	ld	a5,280(a0)
ffffffffc0200882:	472d                	li	a4,11
ffffffffc0200884:	0786                	slli	a5,a5,0x1
ffffffffc0200886:	8385                	srli	a5,a5,0x1
ffffffffc0200888:	06f76c63          	bltu	a4,a5,ffffffffc0200900 <interrupt_handler+0x82>
ffffffffc020088c:	00005717          	auipc	a4,0x5
ffffffffc0200890:	aa470713          	addi	a4,a4,-1372 # ffffffffc0205330 <commands+0x4e0>
ffffffffc0200894:	078a                	slli	a5,a5,0x2
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	439c                	lw	a5,0(a5)
ffffffffc020089a:	97ba                	add	a5,a5,a4
ffffffffc020089c:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020089e:	00005517          	auipc	a0,0x5
ffffffffc02008a2:	a4250513          	addi	a0,a0,-1470 # ffffffffc02052e0 <commands+0x490>
ffffffffc02008a6:	827ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008aa:	00005517          	auipc	a0,0x5
ffffffffc02008ae:	a1650513          	addi	a0,a0,-1514 # ffffffffc02052c0 <commands+0x470>
ffffffffc02008b2:	81bff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008b6:	00005517          	auipc	a0,0x5
ffffffffc02008ba:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205280 <commands+0x430>
ffffffffc02008be:	80fff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008c2:	00005517          	auipc	a0,0x5
ffffffffc02008c6:	9de50513          	addi	a0,a0,-1570 # ffffffffc02052a0 <commands+0x450>
ffffffffc02008ca:	803ff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008ce:	1141                	addi	sp,sp,-16
ffffffffc02008d0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008d2:	c59ff0ef          	jal	ra,ffffffffc020052a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008d6:	00015697          	auipc	a3,0x15
ffffffffc02008da:	bfa68693          	addi	a3,a3,-1030 # ffffffffc02154d0 <ticks>
ffffffffc02008de:	629c                	ld	a5,0(a3)
ffffffffc02008e0:	06400713          	li	a4,100
ffffffffc02008e4:	0785                	addi	a5,a5,1
ffffffffc02008e6:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ea:	e29c                	sd	a5,0(a3)
ffffffffc02008ec:	cb19                	beqz	a4,ffffffffc0200902 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008ee:	60a2                	ld	ra,8(sp)
ffffffffc02008f0:	0141                	addi	sp,sp,16
ffffffffc02008f2:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008f4:	00005517          	auipc	a0,0x5
ffffffffc02008f8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0205310 <commands+0x4c0>
ffffffffc02008fc:	fd0ff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc0200900:	bf31                	j	ffffffffc020081c <print_trapframe>
}
ffffffffc0200902:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200904:	06400593          	li	a1,100
ffffffffc0200908:	00005517          	auipc	a0,0x5
ffffffffc020090c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205300 <commands+0x4b0>
}
ffffffffc0200910:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200912:	fbaff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200916 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200916:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020091a:	1101                	addi	sp,sp,-32
ffffffffc020091c:	e822                	sd	s0,16(sp)
ffffffffc020091e:	ec06                	sd	ra,24(sp)
ffffffffc0200920:	e426                	sd	s1,8(sp)
ffffffffc0200922:	473d                	li	a4,15
ffffffffc0200924:	842a                	mv	s0,a0
ffffffffc0200926:	14f76a63          	bltu	a4,a5,ffffffffc0200a7a <exception_handler+0x164>
ffffffffc020092a:	00005717          	auipc	a4,0x5
ffffffffc020092e:	bee70713          	addi	a4,a4,-1042 # ffffffffc0205518 <commands+0x6c8>
ffffffffc0200932:	078a                	slli	a5,a5,0x2
ffffffffc0200934:	97ba                	add	a5,a5,a4
ffffffffc0200936:	439c                	lw	a5,0(a5)
ffffffffc0200938:	97ba                	add	a5,a5,a4
ffffffffc020093a:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020093c:	00005517          	auipc	a0,0x5
ffffffffc0200940:	bc450513          	addi	a0,a0,-1084 # ffffffffc0205500 <commands+0x6b0>
ffffffffc0200944:	f88ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200948:	8522                	mv	a0,s0
ffffffffc020094a:	c7bff0ef          	jal	ra,ffffffffc02005c4 <pgfault_handler>
ffffffffc020094e:	84aa                	mv	s1,a0
ffffffffc0200950:	12051b63          	bnez	a0,ffffffffc0200a86 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200954:	60e2                	ld	ra,24(sp)
ffffffffc0200956:	6442                	ld	s0,16(sp)
ffffffffc0200958:	64a2                	ld	s1,8(sp)
ffffffffc020095a:	6105                	addi	sp,sp,32
ffffffffc020095c:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020095e:	00005517          	auipc	a0,0x5
ffffffffc0200962:	a0250513          	addi	a0,a0,-1534 # ffffffffc0205360 <commands+0x510>
}
ffffffffc0200966:	6442                	ld	s0,16(sp)
ffffffffc0200968:	60e2                	ld	ra,24(sp)
ffffffffc020096a:	64a2                	ld	s1,8(sp)
ffffffffc020096c:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc020096e:	f5eff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200972:	00005517          	auipc	a0,0x5
ffffffffc0200976:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0205380 <commands+0x530>
ffffffffc020097a:	b7f5                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020097c:	00005517          	auipc	a0,0x5
ffffffffc0200980:	a2450513          	addi	a0,a0,-1500 # ffffffffc02053a0 <commands+0x550>
ffffffffc0200984:	b7cd                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200986:	00005517          	auipc	a0,0x5
ffffffffc020098a:	a3250513          	addi	a0,a0,-1486 # ffffffffc02053b8 <commands+0x568>
ffffffffc020098e:	bfe1                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200990:	00005517          	auipc	a0,0x5
ffffffffc0200994:	a3850513          	addi	a0,a0,-1480 # ffffffffc02053c8 <commands+0x578>
ffffffffc0200998:	b7f9                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099a:	00005517          	auipc	a0,0x5
ffffffffc020099e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02053e8 <commands+0x598>
ffffffffc02009a2:	f2aff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a6:	8522                	mv	a0,s0
ffffffffc02009a8:	c1dff0ef          	jal	ra,ffffffffc02005c4 <pgfault_handler>
ffffffffc02009ac:	84aa                	mv	s1,a0
ffffffffc02009ae:	d15d                	beqz	a0,ffffffffc0200954 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b0:	8522                	mv	a0,s0
ffffffffc02009b2:	e6bff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009b6:	86a6                	mv	a3,s1
ffffffffc02009b8:	00005617          	auipc	a2,0x5
ffffffffc02009bc:	a4860613          	addi	a2,a2,-1464 # ffffffffc0205400 <commands+0x5b0>
ffffffffc02009c0:	0b300593          	li	a1,179
ffffffffc02009c4:	00004517          	auipc	a0,0x4
ffffffffc02009c8:	52c50513          	addi	a0,a0,1324 # ffffffffc0204ef0 <commands+0xa0>
ffffffffc02009cc:	ffcff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d0:	00005517          	auipc	a0,0x5
ffffffffc02009d4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0205420 <commands+0x5d0>
ffffffffc02009d8:	b779                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009da:	00005517          	auipc	a0,0x5
ffffffffc02009de:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205438 <commands+0x5e8>
ffffffffc02009e2:	eeaff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009e6:	8522                	mv	a0,s0
ffffffffc02009e8:	bddff0ef          	jal	ra,ffffffffc02005c4 <pgfault_handler>
ffffffffc02009ec:	84aa                	mv	s1,a0
ffffffffc02009ee:	d13d                	beqz	a0,ffffffffc0200954 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f0:	8522                	mv	a0,s0
ffffffffc02009f2:	e2bff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009f6:	86a6                	mv	a3,s1
ffffffffc02009f8:	00005617          	auipc	a2,0x5
ffffffffc02009fc:	a0860613          	addi	a2,a2,-1528 # ffffffffc0205400 <commands+0x5b0>
ffffffffc0200a00:	0bd00593          	li	a1,189
ffffffffc0200a04:	00004517          	auipc	a0,0x4
ffffffffc0200a08:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204ef0 <commands+0xa0>
ffffffffc0200a0c:	fbcff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	a4050513          	addi	a0,a0,-1472 # ffffffffc0205450 <commands+0x600>
ffffffffc0200a18:	b7b9                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1a:	00005517          	auipc	a0,0x5
ffffffffc0200a1e:	a5650513          	addi	a0,a0,-1450 # ffffffffc0205470 <commands+0x620>
ffffffffc0200a22:	b791                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a24:	00005517          	auipc	a0,0x5
ffffffffc0200a28:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0205490 <commands+0x640>
ffffffffc0200a2c:	bf2d                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a2e:	00005517          	auipc	a0,0x5
ffffffffc0200a32:	a8250513          	addi	a0,a0,-1406 # ffffffffc02054b0 <commands+0x660>
ffffffffc0200a36:	bf05                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	a9850513          	addi	a0,a0,-1384 # ffffffffc02054d0 <commands+0x680>
ffffffffc0200a40:	b71d                	j	ffffffffc0200966 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	aa650513          	addi	a0,a0,-1370 # ffffffffc02054e8 <commands+0x698>
ffffffffc0200a4a:	e82ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a4e:	8522                	mv	a0,s0
ffffffffc0200a50:	b75ff0ef          	jal	ra,ffffffffc02005c4 <pgfault_handler>
ffffffffc0200a54:	84aa                	mv	s1,a0
ffffffffc0200a56:	ee050fe3          	beqz	a0,ffffffffc0200954 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5a:	8522                	mv	a0,s0
ffffffffc0200a5c:	dc1ff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a60:	86a6                	mv	a3,s1
ffffffffc0200a62:	00005617          	auipc	a2,0x5
ffffffffc0200a66:	99e60613          	addi	a2,a2,-1634 # ffffffffc0205400 <commands+0x5b0>
ffffffffc0200a6a:	0d300593          	li	a1,211
ffffffffc0200a6e:	00004517          	auipc	a0,0x4
ffffffffc0200a72:	48250513          	addi	a0,a0,1154 # ffffffffc0204ef0 <commands+0xa0>
ffffffffc0200a76:	f52ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            print_trapframe(tf);
ffffffffc0200a7a:	8522                	mv	a0,s0
}
ffffffffc0200a7c:	6442                	ld	s0,16(sp)
ffffffffc0200a7e:	60e2                	ld	ra,24(sp)
ffffffffc0200a80:	64a2                	ld	s1,8(sp)
ffffffffc0200a82:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a84:	bb61                	j	ffffffffc020081c <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a86:	8522                	mv	a0,s0
ffffffffc0200a88:	d95ff0ef          	jal	ra,ffffffffc020081c <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a8c:	86a6                	mv	a3,s1
ffffffffc0200a8e:	00005617          	auipc	a2,0x5
ffffffffc0200a92:	97260613          	addi	a2,a2,-1678 # ffffffffc0205400 <commands+0x5b0>
ffffffffc0200a96:	0da00593          	li	a1,218
ffffffffc0200a9a:	00004517          	auipc	a0,0x4
ffffffffc0200a9e:	45650513          	addi	a0,a0,1110 # ffffffffc0204ef0 <commands+0xa0>
ffffffffc0200aa2:	f26ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200aa6 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aa6:	11853783          	ld	a5,280(a0)
ffffffffc0200aaa:	0007c363          	bltz	a5,ffffffffc0200ab0 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200aae:	b5a5                	j	ffffffffc0200916 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200ab0:	b3f9                	j	ffffffffc020087e <interrupt_handler>
	...

ffffffffc0200ab4 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ab4:	14011073          	csrw	sscratch,sp
ffffffffc0200ab8:	712d                	addi	sp,sp,-288
ffffffffc0200aba:	e406                	sd	ra,8(sp)
ffffffffc0200abc:	ec0e                	sd	gp,24(sp)
ffffffffc0200abe:	f012                	sd	tp,32(sp)
ffffffffc0200ac0:	f416                	sd	t0,40(sp)
ffffffffc0200ac2:	f81a                	sd	t1,48(sp)
ffffffffc0200ac4:	fc1e                	sd	t2,56(sp)
ffffffffc0200ac6:	e0a2                	sd	s0,64(sp)
ffffffffc0200ac8:	e4a6                	sd	s1,72(sp)
ffffffffc0200aca:	e8aa                	sd	a0,80(sp)
ffffffffc0200acc:	ecae                	sd	a1,88(sp)
ffffffffc0200ace:	f0b2                	sd	a2,96(sp)
ffffffffc0200ad0:	f4b6                	sd	a3,104(sp)
ffffffffc0200ad2:	f8ba                	sd	a4,112(sp)
ffffffffc0200ad4:	fcbe                	sd	a5,120(sp)
ffffffffc0200ad6:	e142                	sd	a6,128(sp)
ffffffffc0200ad8:	e546                	sd	a7,136(sp)
ffffffffc0200ada:	e94a                	sd	s2,144(sp)
ffffffffc0200adc:	ed4e                	sd	s3,152(sp)
ffffffffc0200ade:	f152                	sd	s4,160(sp)
ffffffffc0200ae0:	f556                	sd	s5,168(sp)
ffffffffc0200ae2:	f95a                	sd	s6,176(sp)
ffffffffc0200ae4:	fd5e                	sd	s7,184(sp)
ffffffffc0200ae6:	e1e2                	sd	s8,192(sp)
ffffffffc0200ae8:	e5e6                	sd	s9,200(sp)
ffffffffc0200aea:	e9ea                	sd	s10,208(sp)
ffffffffc0200aec:	edee                	sd	s11,216(sp)
ffffffffc0200aee:	f1f2                	sd	t3,224(sp)
ffffffffc0200af0:	f5f6                	sd	t4,232(sp)
ffffffffc0200af2:	f9fa                	sd	t5,240(sp)
ffffffffc0200af4:	fdfe                	sd	t6,248(sp)
ffffffffc0200af6:	14002473          	csrr	s0,sscratch
ffffffffc0200afa:	100024f3          	csrr	s1,sstatus
ffffffffc0200afe:	14102973          	csrr	s2,sepc
ffffffffc0200b02:	143029f3          	csrr	s3,stval
ffffffffc0200b06:	14202a73          	csrr	s4,scause
ffffffffc0200b0a:	e822                	sd	s0,16(sp)
ffffffffc0200b0c:	e226                	sd	s1,256(sp)
ffffffffc0200b0e:	e64a                	sd	s2,264(sp)
ffffffffc0200b10:	ea4e                	sd	s3,272(sp)
ffffffffc0200b12:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b14:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b16:	f91ff0ef          	jal	ra,ffffffffc0200aa6 <trap>

ffffffffc0200b1a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b1a:	6492                	ld	s1,256(sp)
ffffffffc0200b1c:	6932                	ld	s2,264(sp)
ffffffffc0200b1e:	10049073          	csrw	sstatus,s1
ffffffffc0200b22:	14191073          	csrw	sepc,s2
ffffffffc0200b26:	60a2                	ld	ra,8(sp)
ffffffffc0200b28:	61e2                	ld	gp,24(sp)
ffffffffc0200b2a:	7202                	ld	tp,32(sp)
ffffffffc0200b2c:	72a2                	ld	t0,40(sp)
ffffffffc0200b2e:	7342                	ld	t1,48(sp)
ffffffffc0200b30:	73e2                	ld	t2,56(sp)
ffffffffc0200b32:	6406                	ld	s0,64(sp)
ffffffffc0200b34:	64a6                	ld	s1,72(sp)
ffffffffc0200b36:	6546                	ld	a0,80(sp)
ffffffffc0200b38:	65e6                	ld	a1,88(sp)
ffffffffc0200b3a:	7606                	ld	a2,96(sp)
ffffffffc0200b3c:	76a6                	ld	a3,104(sp)
ffffffffc0200b3e:	7746                	ld	a4,112(sp)
ffffffffc0200b40:	77e6                	ld	a5,120(sp)
ffffffffc0200b42:	680a                	ld	a6,128(sp)
ffffffffc0200b44:	68aa                	ld	a7,136(sp)
ffffffffc0200b46:	694a                	ld	s2,144(sp)
ffffffffc0200b48:	69ea                	ld	s3,152(sp)
ffffffffc0200b4a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b4c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b4e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b50:	7bea                	ld	s7,184(sp)
ffffffffc0200b52:	6c0e                	ld	s8,192(sp)
ffffffffc0200b54:	6cae                	ld	s9,200(sp)
ffffffffc0200b56:	6d4e                	ld	s10,208(sp)
ffffffffc0200b58:	6dee                	ld	s11,216(sp)
ffffffffc0200b5a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b5c:	7eae                	ld	t4,232(sp)
ffffffffc0200b5e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b60:	7fee                	ld	t6,248(sp)
ffffffffc0200b62:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200b64:	10200073          	sret

ffffffffc0200b68 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b68:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b6a:	bf45                	j	ffffffffc0200b1a <__trapret>
	...

ffffffffc0200b6e <pa2page.part.0>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
ffffffffc0200b6e:	1141                	addi	sp,sp,-16
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
ffffffffc0200b70:	00005617          	auipc	a2,0x5
ffffffffc0200b74:	9e860613          	addi	a2,a2,-1560 # ffffffffc0205558 <commands+0x708>
ffffffffc0200b78:	06200593          	li	a1,98
ffffffffc0200b7c:	00005517          	auipc	a0,0x5
ffffffffc0200b80:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205578 <commands+0x728>
pa2page(uintptr_t pa) {
ffffffffc0200b84:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0200b86:	e42ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200b8a <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0200b8a:	7139                	addi	sp,sp,-64
ffffffffc0200b8c:	f426                	sd	s1,40(sp)
ffffffffc0200b8e:	f04a                	sd	s2,32(sp)
ffffffffc0200b90:	ec4e                	sd	s3,24(sp)
ffffffffc0200b92:	e852                	sd	s4,16(sp)
ffffffffc0200b94:	e456                	sd	s5,8(sp)
ffffffffc0200b96:	e05a                	sd	s6,0(sp)
ffffffffc0200b98:	fc06                	sd	ra,56(sp)
ffffffffc0200b9a:	f822                	sd	s0,48(sp)
ffffffffc0200b9c:	84aa                	mv	s1,a0
ffffffffc0200b9e:	00015917          	auipc	s2,0x15
ffffffffc0200ba2:	93a90913          	addi	s2,s2,-1734 # ffffffffc02154d8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200ba6:	4a05                	li	s4,1
ffffffffc0200ba8:	00015a97          	auipc	s5,0x15
ffffffffc0200bac:	900a8a93          	addi	s5,s5,-1792 # ffffffffc02154a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bb0:	0005099b          	sext.w	s3,a0
ffffffffc0200bb4:	00015b17          	auipc	s6,0x15
ffffffffc0200bb8:	954b0b13          	addi	s6,s6,-1708 # ffffffffc0215508 <check_mm_struct>
ffffffffc0200bbc:	a01d                	j	ffffffffc0200be2 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0200bbe:	00093783          	ld	a5,0(s2)
ffffffffc0200bc2:	6f9c                	ld	a5,24(a5)
ffffffffc0200bc4:	9782                	jalr	a5
ffffffffc0200bc6:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bc8:	4601                	li	a2,0
ffffffffc0200bca:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200bcc:	ec0d                	bnez	s0,ffffffffc0200c06 <alloc_pages+0x7c>
ffffffffc0200bce:	029a6c63          	bltu	s4,s1,ffffffffc0200c06 <alloc_pages+0x7c>
ffffffffc0200bd2:	000aa783          	lw	a5,0(s5)
ffffffffc0200bd6:	2781                	sext.w	a5,a5
ffffffffc0200bd8:	c79d                	beqz	a5,ffffffffc0200c06 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200bda:	000b3503          	ld	a0,0(s6)
ffffffffc0200bde:	604020ef          	jal	ra,ffffffffc02031e2 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200be2:	100027f3          	csrr	a5,sstatus
ffffffffc0200be6:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0200be8:	8526                	mv	a0,s1
ffffffffc0200bea:	dbf1                	beqz	a5,ffffffffc0200bbe <alloc_pages+0x34>
        intr_disable();
ffffffffc0200bec:	9d3ff0ef          	jal	ra,ffffffffc02005be <intr_disable>
ffffffffc0200bf0:	00093783          	ld	a5,0(s2)
ffffffffc0200bf4:	8526                	mv	a0,s1
ffffffffc0200bf6:	6f9c                	ld	a5,24(a5)
ffffffffc0200bf8:	9782                	jalr	a5
ffffffffc0200bfa:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200bfc:	9bdff0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0200c00:	4601                	li	a2,0
ffffffffc0200c02:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0200c04:	d469                	beqz	s0,ffffffffc0200bce <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0200c06:	70e2                	ld	ra,56(sp)
ffffffffc0200c08:	8522                	mv	a0,s0
ffffffffc0200c0a:	7442                	ld	s0,48(sp)
ffffffffc0200c0c:	74a2                	ld	s1,40(sp)
ffffffffc0200c0e:	7902                	ld	s2,32(sp)
ffffffffc0200c10:	69e2                	ld	s3,24(sp)
ffffffffc0200c12:	6a42                	ld	s4,16(sp)
ffffffffc0200c14:	6aa2                	ld	s5,8(sp)
ffffffffc0200c16:	6b02                	ld	s6,0(sp)
ffffffffc0200c18:	6121                	addi	sp,sp,64
ffffffffc0200c1a:	8082                	ret

ffffffffc0200c1c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c1c:	100027f3          	csrr	a5,sstatus
ffffffffc0200c20:	8b89                	andi	a5,a5,2
ffffffffc0200c22:	eb81                	bnez	a5,ffffffffc0200c32 <free_pages+0x16>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200c24:	00015797          	auipc	a5,0x15
ffffffffc0200c28:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c2c:	0207b303          	ld	t1,32(a5)
ffffffffc0200c30:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200c32:	1101                	addi	sp,sp,-32
ffffffffc0200c34:	ec06                	sd	ra,24(sp)
ffffffffc0200c36:	e822                	sd	s0,16(sp)
ffffffffc0200c38:	e426                	sd	s1,8(sp)
ffffffffc0200c3a:	842a                	mv	s0,a0
ffffffffc0200c3c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200c3e:	981ff0ef          	jal	ra,ffffffffc02005be <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200c42:	00015797          	auipc	a5,0x15
ffffffffc0200c46:	8967b783          	ld	a5,-1898(a5) # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c4a:	739c                	ld	a5,32(a5)
ffffffffc0200c4c:	85a6                	mv	a1,s1
ffffffffc0200c4e:	8522                	mv	a0,s0
ffffffffc0200c50:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200c52:	6442                	ld	s0,16(sp)
ffffffffc0200c54:	60e2                	ld	ra,24(sp)
ffffffffc0200c56:	64a2                	ld	s1,8(sp)
ffffffffc0200c58:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200c5a:	95fff06f          	j	ffffffffc02005b8 <intr_enable>

ffffffffc0200c5e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c5e:	100027f3          	csrr	a5,sstatus
ffffffffc0200c62:	8b89                	andi	a5,a5,2
ffffffffc0200c64:	eb81                	bnez	a5,ffffffffc0200c74 <nr_free_pages+0x16>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c66:	00015797          	auipc	a5,0x15
ffffffffc0200c6a:	8727b783          	ld	a5,-1934(a5) # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c6e:	0287b303          	ld	t1,40(a5)
ffffffffc0200c72:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0200c74:	1141                	addi	sp,sp,-16
ffffffffc0200c76:	e406                	sd	ra,8(sp)
ffffffffc0200c78:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200c7a:	945ff0ef          	jal	ra,ffffffffc02005be <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200c7e:	00015797          	auipc	a5,0x15
ffffffffc0200c82:	85a7b783          	ld	a5,-1958(a5) # ffffffffc02154d8 <pmm_manager>
ffffffffc0200c86:	779c                	ld	a5,40(a5)
ffffffffc0200c88:	9782                	jalr	a5
ffffffffc0200c8a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200c8c:	92dff0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200c90:	60a2                	ld	ra,8(sp)
ffffffffc0200c92:	8522                	mv	a0,s0
ffffffffc0200c94:	6402                	ld	s0,0(sp)
ffffffffc0200c96:	0141                	addi	sp,sp,16
ffffffffc0200c98:	8082                	ret

ffffffffc0200c9a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200c9a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200c9e:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200ca2:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200ca4:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200ca6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200ca8:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cac:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cae:	f04a                	sd	s2,32(sp)
ffffffffc0200cb0:	ec4e                	sd	s3,24(sp)
ffffffffc0200cb2:	e852                	sd	s4,16(sp)
ffffffffc0200cb4:	fc06                	sd	ra,56(sp)
ffffffffc0200cb6:	f822                	sd	s0,48(sp)
ffffffffc0200cb8:	e456                	sd	s5,8(sp)
ffffffffc0200cba:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200cbc:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0200cc0:	892e                	mv	s2,a1
ffffffffc0200cc2:	89b2                	mv	s3,a2
ffffffffc0200cc4:	00014a17          	auipc	s4,0x14
ffffffffc0200cc8:	7c4a0a13          	addi	s4,s4,1988 # ffffffffc0215488 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0200ccc:	e7b5                	bnez	a5,ffffffffc0200d38 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200cce:	12060b63          	beqz	a2,ffffffffc0200e04 <get_pte+0x16a>
ffffffffc0200cd2:	4505                	li	a0,1
ffffffffc0200cd4:	eb7ff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0200cd8:	842a                	mv	s0,a0
ffffffffc0200cda:	12050563          	beqz	a0,ffffffffc0200e04 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200cde:	00015b17          	auipc	s6,0x15
ffffffffc0200ce2:	812b0b13          	addi	s6,s6,-2030 # ffffffffc02154f0 <pages>
ffffffffc0200ce6:	000b3503          	ld	a0,0(s6)
ffffffffc0200cea:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200cee:	00014a17          	auipc	s4,0x14
ffffffffc0200cf2:	79aa0a13          	addi	s4,s4,1946 # ffffffffc0215488 <npage>
ffffffffc0200cf6:	40a40533          	sub	a0,s0,a0
ffffffffc0200cfa:	8519                	srai	a0,a0,0x6
ffffffffc0200cfc:	9556                	add	a0,a0,s5
ffffffffc0200cfe:	000a3703          	ld	a4,0(s4)
ffffffffc0200d02:	00c51793          	slli	a5,a0,0xc
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0200d06:	4685                	li	a3,1
ffffffffc0200d08:	c014                	sw	a3,0(s0)
ffffffffc0200d0a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d0c:	0532                	slli	a0,a0,0xc
ffffffffc0200d0e:	14e7f263          	bgeu	a5,a4,ffffffffc0200e52 <get_pte+0x1b8>
ffffffffc0200d12:	00014797          	auipc	a5,0x14
ffffffffc0200d16:	7ce7b783          	ld	a5,1998(a5) # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d1a:	6605                	lui	a2,0x1
ffffffffc0200d1c:	4581                	li	a1,0
ffffffffc0200d1e:	953e                	add	a0,a0,a5
ffffffffc0200d20:	251030ef          	jal	ra,ffffffffc0204770 <memset>
    return page - pages + nbase;
ffffffffc0200d24:	000b3683          	ld	a3,0(s6)
ffffffffc0200d28:	40d406b3          	sub	a3,s0,a3
ffffffffc0200d2c:	8699                	srai	a3,a3,0x6
ffffffffc0200d2e:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200d30:	06aa                	slli	a3,a3,0xa
ffffffffc0200d32:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200d36:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d38:	77fd                	lui	a5,0xfffff
ffffffffc0200d3a:	068a                	slli	a3,a3,0x2
ffffffffc0200d3c:	000a3703          	ld	a4,0(s4)
ffffffffc0200d40:	8efd                	and	a3,a3,a5
ffffffffc0200d42:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200d46:	0ce7f163          	bgeu	a5,a4,ffffffffc0200e08 <get_pte+0x16e>
ffffffffc0200d4a:	00014a97          	auipc	s5,0x14
ffffffffc0200d4e:	796a8a93          	addi	s5,s5,1942 # ffffffffc02154e0 <va_pa_offset>
ffffffffc0200d52:	000ab403          	ld	s0,0(s5)
ffffffffc0200d56:	01595793          	srli	a5,s2,0x15
ffffffffc0200d5a:	1ff7f793          	andi	a5,a5,511
ffffffffc0200d5e:	96a2                	add	a3,a3,s0
ffffffffc0200d60:	00379413          	slli	s0,a5,0x3
ffffffffc0200d64:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0200d66:	6014                	ld	a3,0(s0)
ffffffffc0200d68:	0016f793          	andi	a5,a3,1
ffffffffc0200d6c:	e3ad                	bnez	a5,ffffffffc0200dce <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200d6e:	08098b63          	beqz	s3,ffffffffc0200e04 <get_pte+0x16a>
ffffffffc0200d72:	4505                	li	a0,1
ffffffffc0200d74:	e17ff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0200d78:	84aa                	mv	s1,a0
ffffffffc0200d7a:	c549                	beqz	a0,ffffffffc0200e04 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0200d7c:	00014b17          	auipc	s6,0x14
ffffffffc0200d80:	774b0b13          	addi	s6,s6,1908 # ffffffffc02154f0 <pages>
ffffffffc0200d84:	000b3503          	ld	a0,0(s6)
ffffffffc0200d88:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d8c:	000a3703          	ld	a4,0(s4)
ffffffffc0200d90:	40a48533          	sub	a0,s1,a0
ffffffffc0200d94:	8519                	srai	a0,a0,0x6
ffffffffc0200d96:	954e                	add	a0,a0,s3
ffffffffc0200d98:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0200d9c:	4685                	li	a3,1
ffffffffc0200d9e:	c094                	sw	a3,0(s1)
ffffffffc0200da0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200da2:	0532                	slli	a0,a0,0xc
ffffffffc0200da4:	08e7fa63          	bgeu	a5,a4,ffffffffc0200e38 <get_pte+0x19e>
ffffffffc0200da8:	000ab783          	ld	a5,0(s5)
ffffffffc0200dac:	6605                	lui	a2,0x1
ffffffffc0200dae:	4581                	li	a1,0
ffffffffc0200db0:	953e                	add	a0,a0,a5
ffffffffc0200db2:	1bf030ef          	jal	ra,ffffffffc0204770 <memset>
    return page - pages + nbase;
ffffffffc0200db6:	000b3683          	ld	a3,0(s6)
ffffffffc0200dba:	40d486b3          	sub	a3,s1,a3
ffffffffc0200dbe:	8699                	srai	a3,a3,0x6
ffffffffc0200dc0:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200dc2:	06aa                	slli	a3,a3,0xa
ffffffffc0200dc4:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200dc8:	e014                	sd	a3,0(s0)
ffffffffc0200dca:	000a3703          	ld	a4,0(s4)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200dce:	068a                	slli	a3,a3,0x2
ffffffffc0200dd0:	757d                	lui	a0,0xfffff
ffffffffc0200dd2:	8ee9                	and	a3,a3,a0
ffffffffc0200dd4:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200dd8:	04e7f463          	bgeu	a5,a4,ffffffffc0200e20 <get_pte+0x186>
ffffffffc0200ddc:	000ab503          	ld	a0,0(s5)
ffffffffc0200de0:	00c95913          	srli	s2,s2,0xc
ffffffffc0200de4:	1ff97913          	andi	s2,s2,511
ffffffffc0200de8:	96aa                	add	a3,a3,a0
ffffffffc0200dea:	00391513          	slli	a0,s2,0x3
ffffffffc0200dee:	9536                	add	a0,a0,a3
}
ffffffffc0200df0:	70e2                	ld	ra,56(sp)
ffffffffc0200df2:	7442                	ld	s0,48(sp)
ffffffffc0200df4:	74a2                	ld	s1,40(sp)
ffffffffc0200df6:	7902                	ld	s2,32(sp)
ffffffffc0200df8:	69e2                	ld	s3,24(sp)
ffffffffc0200dfa:	6a42                	ld	s4,16(sp)
ffffffffc0200dfc:	6aa2                	ld	s5,8(sp)
ffffffffc0200dfe:	6b02                	ld	s6,0(sp)
ffffffffc0200e00:	6121                	addi	sp,sp,64
ffffffffc0200e02:	8082                	ret
            return NULL;
ffffffffc0200e04:	4501                	li	a0,0
ffffffffc0200e06:	b7ed                	j	ffffffffc0200df0 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200e08:	00004617          	auipc	a2,0x4
ffffffffc0200e0c:	78060613          	addi	a2,a2,1920 # ffffffffc0205588 <commands+0x738>
ffffffffc0200e10:	0e400593          	li	a1,228
ffffffffc0200e14:	00004517          	auipc	a0,0x4
ffffffffc0200e18:	79c50513          	addi	a0,a0,1948 # ffffffffc02055b0 <commands+0x760>
ffffffffc0200e1c:	bacff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200e20:	00004617          	auipc	a2,0x4
ffffffffc0200e24:	76860613          	addi	a2,a2,1896 # ffffffffc0205588 <commands+0x738>
ffffffffc0200e28:	0ef00593          	li	a1,239
ffffffffc0200e2c:	00004517          	auipc	a0,0x4
ffffffffc0200e30:	78450513          	addi	a0,a0,1924 # ffffffffc02055b0 <commands+0x760>
ffffffffc0200e34:	b94ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e38:	86aa                	mv	a3,a0
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	74e60613          	addi	a2,a2,1870 # ffffffffc0205588 <commands+0x738>
ffffffffc0200e42:	0ec00593          	li	a1,236
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	76a50513          	addi	a0,a0,1898 # ffffffffc02055b0 <commands+0x760>
ffffffffc0200e4e:	b7aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200e52:	86aa                	mv	a3,a0
ffffffffc0200e54:	00004617          	auipc	a2,0x4
ffffffffc0200e58:	73460613          	addi	a2,a2,1844 # ffffffffc0205588 <commands+0x738>
ffffffffc0200e5c:	0e100593          	li	a1,225
ffffffffc0200e60:	00004517          	auipc	a0,0x4
ffffffffc0200e64:	75050513          	addi	a0,a0,1872 # ffffffffc02055b0 <commands+0x760>
ffffffffc0200e68:	b60ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200e6c <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e6c:	1141                	addi	sp,sp,-16
ffffffffc0200e6e:	e022                	sd	s0,0(sp)
ffffffffc0200e70:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e72:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0200e74:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200e76:	e25ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
    if (ptep_store != NULL) {
ffffffffc0200e7a:	c011                	beqz	s0,ffffffffc0200e7e <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0200e7c:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e7e:	c511                	beqz	a0,ffffffffc0200e8a <get_page+0x1e>
ffffffffc0200e80:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0200e82:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0200e84:	0017f713          	andi	a4,a5,1
ffffffffc0200e88:	e709                	bnez	a4,ffffffffc0200e92 <get_page+0x26>
}
ffffffffc0200e8a:	60a2                	ld	ra,8(sp)
ffffffffc0200e8c:	6402                	ld	s0,0(sp)
ffffffffc0200e8e:	0141                	addi	sp,sp,16
ffffffffc0200e90:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200e92:	078a                	slli	a5,a5,0x2
ffffffffc0200e94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200e96:	00014717          	auipc	a4,0x14
ffffffffc0200e9a:	5f273703          	ld	a4,1522(a4) # ffffffffc0215488 <npage>
ffffffffc0200e9e:	00e7ff63          	bgeu	a5,a4,ffffffffc0200ebc <get_page+0x50>
ffffffffc0200ea2:	60a2                	ld	ra,8(sp)
ffffffffc0200ea4:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0200ea6:	fff80537          	lui	a0,0xfff80
ffffffffc0200eaa:	97aa                	add	a5,a5,a0
ffffffffc0200eac:	079a                	slli	a5,a5,0x6
ffffffffc0200eae:	00014517          	auipc	a0,0x14
ffffffffc0200eb2:	64253503          	ld	a0,1602(a0) # ffffffffc02154f0 <pages>
ffffffffc0200eb6:	953e                	add	a0,a0,a5
ffffffffc0200eb8:	0141                	addi	sp,sp,16
ffffffffc0200eba:	8082                	ret
ffffffffc0200ebc:	cb3ff0ef          	jal	ra,ffffffffc0200b6e <pa2page.part.0>

ffffffffc0200ec0 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ec0:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ec2:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0200ec4:	e426                	sd	s1,8(sp)
ffffffffc0200ec6:	ec06                	sd	ra,24(sp)
ffffffffc0200ec8:	e822                	sd	s0,16(sp)
ffffffffc0200eca:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0200ecc:	dcfff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
    if (ptep != NULL) {
ffffffffc0200ed0:	c511                	beqz	a0,ffffffffc0200edc <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0200ed2:	611c                	ld	a5,0(a0)
ffffffffc0200ed4:	842a                	mv	s0,a0
ffffffffc0200ed6:	0017f713          	andi	a4,a5,1
ffffffffc0200eda:	e711                	bnez	a4,ffffffffc0200ee6 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0200edc:	60e2                	ld	ra,24(sp)
ffffffffc0200ede:	6442                	ld	s0,16(sp)
ffffffffc0200ee0:	64a2                	ld	s1,8(sp)
ffffffffc0200ee2:	6105                	addi	sp,sp,32
ffffffffc0200ee4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200ee6:	078a                	slli	a5,a5,0x2
ffffffffc0200ee8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200eea:	00014717          	auipc	a4,0x14
ffffffffc0200eee:	59e73703          	ld	a4,1438(a4) # ffffffffc0215488 <npage>
ffffffffc0200ef2:	02e7fd63          	bgeu	a5,a4,ffffffffc0200f2c <page_remove+0x6c>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ef6:	fff80537          	lui	a0,0xfff80
ffffffffc0200efa:	97aa                	add	a5,a5,a0
ffffffffc0200efc:	079a                	slli	a5,a5,0x6
ffffffffc0200efe:	00014517          	auipc	a0,0x14
ffffffffc0200f02:	5f253503          	ld	a0,1522(a0) # ffffffffc02154f0 <pages>
ffffffffc0200f06:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0200f08:	411c                	lw	a5,0(a0)
ffffffffc0200f0a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200f0e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0200f10:	cb11                	beqz	a4,ffffffffc0200f24 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0200f12:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f16:	12048073          	sfence.vma	s1
}
ffffffffc0200f1a:	60e2                	ld	ra,24(sp)
ffffffffc0200f1c:	6442                	ld	s0,16(sp)
ffffffffc0200f1e:	64a2                	ld	s1,8(sp)
ffffffffc0200f20:	6105                	addi	sp,sp,32
ffffffffc0200f22:	8082                	ret
            free_page(page);
ffffffffc0200f24:	4585                	li	a1,1
ffffffffc0200f26:	cf7ff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
ffffffffc0200f2a:	b7e5                	j	ffffffffc0200f12 <page_remove+0x52>
ffffffffc0200f2c:	c43ff0ef          	jal	ra,ffffffffc0200b6e <pa2page.part.0>

ffffffffc0200f30 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f30:	7179                	addi	sp,sp,-48
ffffffffc0200f32:	e44e                	sd	s3,8(sp)
ffffffffc0200f34:	89b2                	mv	s3,a2
ffffffffc0200f36:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f38:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f3a:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f3c:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0200f3e:	ec26                	sd	s1,24(sp)
ffffffffc0200f40:	f406                	sd	ra,40(sp)
ffffffffc0200f42:	e84a                	sd	s2,16(sp)
ffffffffc0200f44:	e052                	sd	s4,0(sp)
ffffffffc0200f46:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f48:	d53ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
    if (ptep == NULL) {
ffffffffc0200f4c:	cd41                	beqz	a0,ffffffffc0200fe4 <page_insert+0xb4>
    page->ref += 1;
ffffffffc0200f4e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0200f50:	611c                	ld	a5,0(a0)
ffffffffc0200f52:	892a                	mv	s2,a0
ffffffffc0200f54:	0016871b          	addiw	a4,a3,1
ffffffffc0200f58:	c018                	sw	a4,0(s0)
ffffffffc0200f5a:	0017f713          	andi	a4,a5,1
ffffffffc0200f5e:	eb1d                	bnez	a4,ffffffffc0200f94 <page_insert+0x64>
ffffffffc0200f60:	00014717          	auipc	a4,0x14
ffffffffc0200f64:	59073703          	ld	a4,1424(a4) # ffffffffc02154f0 <pages>
    return page - pages + nbase;
ffffffffc0200f68:	8c19                	sub	s0,s0,a4
ffffffffc0200f6a:	000807b7          	lui	a5,0x80
ffffffffc0200f6e:	8419                	srai	s0,s0,0x6
ffffffffc0200f70:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f72:	042a                	slli	s0,s0,0xa
ffffffffc0200f74:	8c45                	or	s0,s0,s1
ffffffffc0200f76:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200f7a:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200f7e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0200f82:	4501                	li	a0,0
}
ffffffffc0200f84:	70a2                	ld	ra,40(sp)
ffffffffc0200f86:	7402                	ld	s0,32(sp)
ffffffffc0200f88:	64e2                	ld	s1,24(sp)
ffffffffc0200f8a:	6942                	ld	s2,16(sp)
ffffffffc0200f8c:	69a2                	ld	s3,8(sp)
ffffffffc0200f8e:	6a02                	ld	s4,0(sp)
ffffffffc0200f90:	6145                	addi	sp,sp,48
ffffffffc0200f92:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0200f94:	078a                	slli	a5,a5,0x2
ffffffffc0200f96:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f98:	00014717          	auipc	a4,0x14
ffffffffc0200f9c:	4f073703          	ld	a4,1264(a4) # ffffffffc0215488 <npage>
ffffffffc0200fa0:	04e7f463          	bgeu	a5,a4,ffffffffc0200fe8 <page_insert+0xb8>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fa4:	00014a17          	auipc	s4,0x14
ffffffffc0200fa8:	54ca0a13          	addi	s4,s4,1356 # ffffffffc02154f0 <pages>
ffffffffc0200fac:	000a3703          	ld	a4,0(s4)
ffffffffc0200fb0:	fff80537          	lui	a0,0xfff80
ffffffffc0200fb4:	97aa                	add	a5,a5,a0
ffffffffc0200fb6:	079a                	slli	a5,a5,0x6
ffffffffc0200fb8:	97ba                	add	a5,a5,a4
        if (p == page) {
ffffffffc0200fba:	00f40a63          	beq	s0,a5,ffffffffc0200fce <page_insert+0x9e>
    page->ref -= 1;
ffffffffc0200fbe:	4394                	lw	a3,0(a5)
ffffffffc0200fc0:	fff6861b          	addiw	a2,a3,-1
ffffffffc0200fc4:	c390                	sw	a2,0(a5)
        if (page_ref(page) ==
ffffffffc0200fc6:	c611                	beqz	a2,ffffffffc0200fd2 <page_insert+0xa2>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fc8:	12098073          	sfence.vma	s3
}
ffffffffc0200fcc:	bf71                	j	ffffffffc0200f68 <page_insert+0x38>
ffffffffc0200fce:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0200fd0:	bf61                	j	ffffffffc0200f68 <page_insert+0x38>
            free_page(page);
ffffffffc0200fd2:	4585                	li	a1,1
ffffffffc0200fd4:	853e                	mv	a0,a5
ffffffffc0200fd6:	c47ff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
ffffffffc0200fda:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fde:	12098073          	sfence.vma	s3
ffffffffc0200fe2:	b759                	j	ffffffffc0200f68 <page_insert+0x38>
        return -E_NO_MEM;
ffffffffc0200fe4:	5571                	li	a0,-4
ffffffffc0200fe6:	bf79                	j	ffffffffc0200f84 <page_insert+0x54>
ffffffffc0200fe8:	b87ff0ef          	jal	ra,ffffffffc0200b6e <pa2page.part.0>

ffffffffc0200fec <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0200fec:	00006797          	auipc	a5,0x6
ffffffffc0200ff0:	83478793          	addi	a5,a5,-1996 # ffffffffc0206820 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ff4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0200ff6:	715d                	addi	sp,sp,-80
ffffffffc0200ff8:	e486                	sd	ra,72(sp)
ffffffffc0200ffa:	e0a2                	sd	s0,64(sp)
ffffffffc0200ffc:	fc26                	sd	s1,56(sp)
ffffffffc0200ffe:	f84a                	sd	s2,48(sp)
ffffffffc0201000:	f44e                	sd	s3,40(sp)
ffffffffc0201002:	f052                	sd	s4,32(sp)
ffffffffc0201004:	ec56                	sd	s5,24(sp)
ffffffffc0201006:	e85a                	sd	s6,16(sp)
ffffffffc0201008:	e45e                	sd	s7,8(sp)
ffffffffc020100a:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020100c:	00014417          	auipc	s0,0x14
ffffffffc0201010:	4cc40413          	addi	s0,s0,1228 # ffffffffc02154d8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201014:	00004517          	auipc	a0,0x4
ffffffffc0201018:	5ac50513          	addi	a0,a0,1452 # ffffffffc02055c0 <commands+0x770>
    pmm_manager = &default_pmm_manager;
ffffffffc020101c:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020101e:	8aeff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc0201022:	601c                	ld	a5,0(s0)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201024:	00014997          	auipc	s3,0x14
ffffffffc0201028:	4bc98993          	addi	s3,s3,1212 # ffffffffc02154e0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020102c:	00014497          	auipc	s1,0x14
ffffffffc0201030:	45c48493          	addi	s1,s1,1116 # ffffffffc0215488 <npage>
    pmm_manager->init();
ffffffffc0201034:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201036:	00014917          	auipc	s2,0x14
ffffffffc020103a:	4ba90913          	addi	s2,s2,1210 # ffffffffc02154f0 <pages>
    pmm_manager->init();
ffffffffc020103e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201040:	57f5                	li	a5,-3
ffffffffc0201042:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201044:	00004517          	auipc	a0,0x4
ffffffffc0201048:	59450513          	addi	a0,a0,1428 # ffffffffc02055d8 <commands+0x788>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020104c:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0201050:	87cff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201054:	46c5                	li	a3,17
ffffffffc0201056:	06ee                	slli	a3,a3,0x1b
ffffffffc0201058:	40100613          	li	a2,1025
ffffffffc020105c:	0656                	slli	a2,a2,0x15
ffffffffc020105e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201062:	16fd                	addi	a3,a3,-1
ffffffffc0201064:	00004517          	auipc	a0,0x4
ffffffffc0201068:	58c50513          	addi	a0,a0,1420 # ffffffffc02055f0 <commands+0x7a0>
ffffffffc020106c:	860ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201070:	777d                	lui	a4,0xfffff
ffffffffc0201072:	00015797          	auipc	a5,0x15
ffffffffc0201076:	58d78793          	addi	a5,a5,1421 # ffffffffc02165ff <end+0xfff>
ffffffffc020107a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020107c:	00088737          	lui	a4,0x88
ffffffffc0201080:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201082:	00f93023          	sd	a5,0(s2)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201086:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201088:	4585                	li	a1,1
ffffffffc020108a:	fff80637          	lui	a2,0xfff80
ffffffffc020108e:	a019                	j	ffffffffc0201094 <pmm_init+0xa8>
ffffffffc0201090:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201094:	00671693          	slli	a3,a4,0x6
ffffffffc0201098:	97b6                	add	a5,a5,a3
ffffffffc020109a:	07a1                	addi	a5,a5,8
ffffffffc020109c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02010a0:	0004b803          	ld	a6,0(s1)
ffffffffc02010a4:	0705                	addi	a4,a4,1
ffffffffc02010a6:	00c806b3          	add	a3,a6,a2
ffffffffc02010aa:	fed763e3          	bltu	a4,a3,ffffffffc0201090 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010ae:	00093503          	ld	a0,0(s2)
ffffffffc02010b2:	069a                	slli	a3,a3,0x6
ffffffffc02010b4:	c02007b7          	lui	a5,0xc0200
ffffffffc02010b8:	96aa                	add	a3,a3,a0
ffffffffc02010ba:	4ef6e763          	bltu	a3,a5,ffffffffc02015a8 <pmm_init+0x5bc>
ffffffffc02010be:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02010c2:	47c5                	li	a5,17
ffffffffc02010c4:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010c6:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02010c8:	02f6f963          	bgeu	a3,a5,ffffffffc02010fa <pmm_init+0x10e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010cc:	6585                	lui	a1,0x1
ffffffffc02010ce:	15fd                	addi	a1,a1,-1
ffffffffc02010d0:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02010d2:	00c6d713          	srli	a4,a3,0xc
ffffffffc02010d6:	47077f63          	bgeu	a4,a6,ffffffffc0201554 <pmm_init+0x568>
    pmm_manager->init_memmap(base, n);
ffffffffc02010da:	00043803          	ld	a6,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010de:	75fd                	lui	a1,0xfffff
ffffffffc02010e0:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02010e2:	9732                	add	a4,a4,a2
    pmm_manager->init_memmap(base, n);
ffffffffc02010e4:	01083603          	ld	a2,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010e8:	40d786b3          	sub	a3,a5,a3
ffffffffc02010ec:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02010ee:	00c6d593          	srli	a1,a3,0xc
ffffffffc02010f2:	953a                	add	a0,a0,a4
ffffffffc02010f4:	9602                	jalr	a2
ffffffffc02010f6:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc02010fa:	00004517          	auipc	a0,0x4
ffffffffc02010fe:	54650513          	addi	a0,a0,1350 # ffffffffc0205640 <commands+0x7f0>
ffffffffc0201102:	fcbfe0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201106:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201108:	00014417          	auipc	s0,0x14
ffffffffc020110c:	37840413          	addi	s0,s0,888 # ffffffffc0215480 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201110:	7b9c                	ld	a5,48(a5)
ffffffffc0201112:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201114:	00004517          	auipc	a0,0x4
ffffffffc0201118:	54450513          	addi	a0,a0,1348 # ffffffffc0205658 <commands+0x808>
ffffffffc020111c:	fb1fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201120:	00008697          	auipc	a3,0x8
ffffffffc0201124:	ee068693          	addi	a3,a3,-288 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201128:	e014                	sd	a3,0(s0)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020112a:	c02007b7          	lui	a5,0xc0200
ffffffffc020112e:	7af6e063          	bltu	a3,a5,ffffffffc02018ce <pmm_init+0x8e2>
ffffffffc0201132:	0009b783          	ld	a5,0(s3)
ffffffffc0201136:	8e9d                	sub	a3,a3,a5
ffffffffc0201138:	00014797          	auipc	a5,0x14
ffffffffc020113c:	3ad7b823          	sd	a3,944(a5) # ffffffffc02154e8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201140:	b1fff0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201144:	6098                	ld	a4,0(s1)
ffffffffc0201146:	c80007b7          	lui	a5,0xc8000
ffffffffc020114a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020114c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020114e:	78e7ec63          	bltu	a5,a4,ffffffffc02018e6 <pmm_init+0x8fa>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201152:	6008                	ld	a0,0(s0)
ffffffffc0201154:	40050263          	beqz	a0,ffffffffc0201558 <pmm_init+0x56c>
ffffffffc0201158:	03451793          	slli	a5,a0,0x34
ffffffffc020115c:	3e079e63          	bnez	a5,ffffffffc0201558 <pmm_init+0x56c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201160:	4601                	li	a2,0
ffffffffc0201162:	4581                	li	a1,0
ffffffffc0201164:	d09ff0ef          	jal	ra,ffffffffc0200e6c <get_page>
ffffffffc0201168:	02051fe3          	bnez	a0,ffffffffc02019a6 <pmm_init+0x9ba>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020116c:	4505                	li	a0,1
ffffffffc020116e:	a1dff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0201172:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201174:	6008                	ld	a0,0(s0)
ffffffffc0201176:	4681                	li	a3,0
ffffffffc0201178:	4601                	li	a2,0
ffffffffc020117a:	85d6                	mv	a1,s5
ffffffffc020117c:	db5ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc0201180:	000513e3          	bnez	a0,ffffffffc0201986 <pmm_init+0x99a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201184:	6008                	ld	a0,0(s0)
ffffffffc0201186:	4601                	li	a2,0
ffffffffc0201188:	4581                	li	a1,0
ffffffffc020118a:	b11ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020118e:	7c050c63          	beqz	a0,ffffffffc0201966 <pmm_init+0x97a>
    assert(pte2page(*ptep) == p1);
ffffffffc0201192:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201194:	0017f713          	andi	a4,a5,1
ffffffffc0201198:	3e070c63          	beqz	a4,ffffffffc0201590 <pmm_init+0x5a4>
    if (PPN(pa) >= npage) {
ffffffffc020119c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020119e:	078a                	slli	a5,a5,0x2
ffffffffc02011a0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02011a2:	3ae7f963          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc02011a6:	00093683          	ld	a3,0(s2)
ffffffffc02011aa:	fff80637          	lui	a2,0xfff80
ffffffffc02011ae:	97b2                	add	a5,a5,a2
ffffffffc02011b0:	079a                	slli	a5,a5,0x6
ffffffffc02011b2:	97b6                	add	a5,a5,a3
ffffffffc02011b4:	48fa9063          	bne	s5,a5,ffffffffc0201634 <pmm_init+0x648>
    assert(page_ref(p1) == 1);
ffffffffc02011b8:	000aab83          	lw	s7,0(s5)
ffffffffc02011bc:	4785                	li	a5,1
ffffffffc02011be:	44fb9b63          	bne	s7,a5,ffffffffc0201614 <pmm_init+0x628>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02011c2:	6008                	ld	a0,0(s0)
ffffffffc02011c4:	76fd                	lui	a3,0xfffff
ffffffffc02011c6:	611c                	ld	a5,0(a0)
ffffffffc02011c8:	078a                	slli	a5,a5,0x2
ffffffffc02011ca:	8ff5                	and	a5,a5,a3
ffffffffc02011cc:	00c7d613          	srli	a2,a5,0xc
ffffffffc02011d0:	42e67563          	bgeu	a2,a4,ffffffffc02015fa <pmm_init+0x60e>
ffffffffc02011d4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011d8:	97e2                	add	a5,a5,s8
ffffffffc02011da:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deaa00>
ffffffffc02011de:	0b0a                	slli	s6,s6,0x2
ffffffffc02011e0:	00db7b33          	and	s6,s6,a3
ffffffffc02011e4:	00cb5793          	srli	a5,s6,0xc
ffffffffc02011e8:	3ee7fc63          	bgeu	a5,a4,ffffffffc02015e0 <pmm_init+0x5f4>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011ec:	4601                	li	a2,0
ffffffffc02011ee:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011f0:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011f2:	aa9ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02011f6:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02011f8:	53651e63          	bne	a0,s6,ffffffffc0201734 <pmm_init+0x748>

    p2 = alloc_page();
ffffffffc02011fc:	4505                	li	a0,1
ffffffffc02011fe:	98dff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0201202:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201204:	6008                	ld	a0,0(s0)
ffffffffc0201206:	46d1                	li	a3,20
ffffffffc0201208:	6605                	lui	a2,0x1
ffffffffc020120a:	85da                	mv	a1,s6
ffffffffc020120c:	d25ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc0201210:	50051263          	bnez	a0,ffffffffc0201714 <pmm_init+0x728>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201214:	6008                	ld	a0,0(s0)
ffffffffc0201216:	4601                	li	a2,0
ffffffffc0201218:	6585                	lui	a1,0x1
ffffffffc020121a:	a81ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020121e:	4c050b63          	beqz	a0,ffffffffc02016f4 <pmm_init+0x708>
    assert(*ptep & PTE_U);
ffffffffc0201222:	611c                	ld	a5,0(a0)
ffffffffc0201224:	0107f713          	andi	a4,a5,16
ffffffffc0201228:	4a070663          	beqz	a4,ffffffffc02016d4 <pmm_init+0x6e8>
    assert(*ptep & PTE_W);
ffffffffc020122c:	8b91                	andi	a5,a5,4
ffffffffc020122e:	48078363          	beqz	a5,ffffffffc02016b4 <pmm_init+0x6c8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201232:	6008                	ld	a0,0(s0)
ffffffffc0201234:	611c                	ld	a5,0(a0)
ffffffffc0201236:	8bc1                	andi	a5,a5,16
ffffffffc0201238:	44078e63          	beqz	a5,ffffffffc0201694 <pmm_init+0x6a8>
    assert(page_ref(p2) == 1);
ffffffffc020123c:	000b2783          	lw	a5,0(s6)
ffffffffc0201240:	43779a63          	bne	a5,s7,ffffffffc0201674 <pmm_init+0x688>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201244:	4681                	li	a3,0
ffffffffc0201246:	6605                	lui	a2,0x1
ffffffffc0201248:	85d6                	mv	a1,s5
ffffffffc020124a:	ce7ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc020124e:	40051363          	bnez	a0,ffffffffc0201654 <pmm_init+0x668>
    assert(page_ref(p1) == 2);
ffffffffc0201252:	000aa703          	lw	a4,0(s5)
ffffffffc0201256:	4789                	li	a5,2
ffffffffc0201258:	7cf71763          	bne	a4,a5,ffffffffc0201a26 <pmm_init+0xa3a>
    assert(page_ref(p2) == 0);
ffffffffc020125c:	000b2783          	lw	a5,0(s6)
ffffffffc0201260:	7a079363          	bnez	a5,ffffffffc0201a06 <pmm_init+0xa1a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201264:	6008                	ld	a0,0(s0)
ffffffffc0201266:	4601                	li	a2,0
ffffffffc0201268:	6585                	lui	a1,0x1
ffffffffc020126a:	a31ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020126e:	76050c63          	beqz	a0,ffffffffc02019e6 <pmm_init+0x9fa>
    assert(pte2page(*ptep) == p1);
ffffffffc0201272:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201274:	00177793          	andi	a5,a4,1
ffffffffc0201278:	30078c63          	beqz	a5,ffffffffc0201590 <pmm_init+0x5a4>
    if (PPN(pa) >= npage) {
ffffffffc020127c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020127e:	00271793          	slli	a5,a4,0x2
ffffffffc0201282:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201284:	2cd7f863          	bgeu	a5,a3,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc0201288:	00093683          	ld	a3,0(s2)
ffffffffc020128c:	fff80637          	lui	a2,0xfff80
ffffffffc0201290:	97b2                	add	a5,a5,a2
ffffffffc0201292:	079a                	slli	a5,a5,0x6
ffffffffc0201294:	97b6                	add	a5,a5,a3
ffffffffc0201296:	72fa9863          	bne	s5,a5,ffffffffc02019c6 <pmm_init+0x9da>
    assert((*ptep & PTE_U) == 0);
ffffffffc020129a:	8b41                	andi	a4,a4,16
ffffffffc020129c:	60071963          	bnez	a4,ffffffffc02018ae <pmm_init+0x8c2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02012a0:	6008                	ld	a0,0(s0)
ffffffffc02012a2:	4581                	li	a1,0
ffffffffc02012a4:	c1dff0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02012a8:	000aa703          	lw	a4,0(s5)
ffffffffc02012ac:	4785                	li	a5,1
ffffffffc02012ae:	5ef71063          	bne	a4,a5,ffffffffc020188e <pmm_init+0x8a2>
    assert(page_ref(p2) == 0);
ffffffffc02012b2:	000b2783          	lw	a5,0(s6)
ffffffffc02012b6:	5a079c63          	bnez	a5,ffffffffc020186e <pmm_init+0x882>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02012ba:	6008                	ld	a0,0(s0)
ffffffffc02012bc:	6585                	lui	a1,0x1
ffffffffc02012be:	c03ff0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02012c2:	000aa783          	lw	a5,0(s5)
ffffffffc02012c6:	58079463          	bnez	a5,ffffffffc020184e <pmm_init+0x862>
    assert(page_ref(p2) == 0);
ffffffffc02012ca:	000b2783          	lw	a5,0(s6)
ffffffffc02012ce:	4e079063          	bnez	a5,ffffffffc02017ae <pmm_init+0x7c2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02012d2:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02012d6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02012d8:	000b3783          	ld	a5,0(s6)
ffffffffc02012dc:	078a                	slli	a5,a5,0x2
ffffffffc02012de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02012e0:	26e7fa63          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc02012e4:	fff806b7          	lui	a3,0xfff80
ffffffffc02012e8:	00093503          	ld	a0,0(s2)
ffffffffc02012ec:	97b6                	add	a5,a5,a3
ffffffffc02012ee:	079a                	slli	a5,a5,0x6
ffffffffc02012f0:	00f506b3          	add	a3,a0,a5
ffffffffc02012f4:	4290                	lw	a2,0(a3)
ffffffffc02012f6:	4685                	li	a3,1
ffffffffc02012f8:	48d61b63          	bne	a2,a3,ffffffffc020178e <pmm_init+0x7a2>
    return page - pages + nbase;
ffffffffc02012fc:	8799                	srai	a5,a5,0x6
ffffffffc02012fe:	00080ab7          	lui	s5,0x80
ffffffffc0201302:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0201304:	00c79693          	slli	a3,a5,0xc
ffffffffc0201308:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020130a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020130c:	46e6f463          	bgeu	a3,a4,ffffffffc0201774 <pmm_init+0x788>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201310:	0009b683          	ld	a3,0(s3)
ffffffffc0201314:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201316:	639c                	ld	a5,0(a5)
ffffffffc0201318:	078a                	slli	a5,a5,0x2
ffffffffc020131a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020131c:	22e7fc63          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc0201320:	415787b3          	sub	a5,a5,s5
ffffffffc0201324:	079a                	slli	a5,a5,0x6
ffffffffc0201326:	953e                	add	a0,a0,a5
ffffffffc0201328:	4585                	li	a1,1
ffffffffc020132a:	8f3ff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020132e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201332:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201334:	078a                	slli	a5,a5,0x2
ffffffffc0201336:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201338:	20e7fe63          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc020133c:	00093503          	ld	a0,0(s2)
ffffffffc0201340:	415787b3          	sub	a5,a5,s5
ffffffffc0201344:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201346:	953e                	add	a0,a0,a5
ffffffffc0201348:	4585                	li	a1,1
ffffffffc020134a:	8d3ff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020134e:	601c                	ld	a5,0(s0)
ffffffffc0201350:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0201354:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0201358:	907ff0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc020135c:	3eaa1c63          	bne	s4,a0,ffffffffc0201754 <pmm_init+0x768>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201360:	00004517          	auipc	a0,0x4
ffffffffc0201364:	62050513          	addi	a0,a0,1568 # ffffffffc0205980 <commands+0xb30>
ffffffffc0201368:	d65fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc020136c:	8f3ff0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201370:	609c                	ld	a5,0(s1)
ffffffffc0201372:	c0200ab7          	lui	s5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201376:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201378:	00c79713          	slli	a4,a5,0xc
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020137c:	7bfd                	lui	s7,0xfffff
ffffffffc020137e:	6b05                	lui	s6,0x1
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201380:	02eafb63          	bgeu	s5,a4,ffffffffc02013b6 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201384:	00cad713          	srli	a4,s5,0xc
ffffffffc0201388:	6008                	ld	a0,0(s0)
ffffffffc020138a:	16f77863          	bgeu	a4,a5,ffffffffc02014fa <pmm_init+0x50e>
ffffffffc020138e:	0009b583          	ld	a1,0(s3)
ffffffffc0201392:	4601                	li	a2,0
ffffffffc0201394:	95d6                	add	a1,a1,s5
ffffffffc0201396:	905ff0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020139a:	16050d63          	beqz	a0,ffffffffc0201514 <pmm_init+0x528>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020139e:	611c                	ld	a5,0(a0)
ffffffffc02013a0:	078a                	slli	a5,a5,0x2
ffffffffc02013a2:	0177f7b3          	and	a5,a5,s7
ffffffffc02013a6:	19579763          	bne	a5,s5,ffffffffc0201534 <pmm_init+0x548>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02013aa:	609c                	ld	a5,0(s1)
ffffffffc02013ac:	9ada                	add	s5,s5,s6
ffffffffc02013ae:	00c79713          	slli	a4,a5,0xc
ffffffffc02013b2:	fceae9e3          	bltu	s5,a4,ffffffffc0201384 <pmm_init+0x398>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02013b6:	601c                	ld	a5,0(s0)
ffffffffc02013b8:	639c                	ld	a5,0(a5)
ffffffffc02013ba:	56079663          	bnez	a5,ffffffffc0201926 <pmm_init+0x93a>

    struct Page *p;
    p = alloc_page();
ffffffffc02013be:	4505                	li	a0,1
ffffffffc02013c0:	fcaff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02013c4:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02013c6:	6008                	ld	a0,0(s0)
ffffffffc02013c8:	4699                	li	a3,6
ffffffffc02013ca:	10000613          	li	a2,256
ffffffffc02013ce:	85d6                	mv	a1,s5
ffffffffc02013d0:	b61ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc02013d4:	52051963          	bnez	a0,ffffffffc0201906 <pmm_init+0x91a>
    assert(page_ref(p) == 1);
ffffffffc02013d8:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc02013dc:	4785                	li	a5,1
ffffffffc02013de:	44f71863          	bne	a4,a5,ffffffffc020182e <pmm_init+0x842>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02013e2:	6008                	ld	a0,0(s0)
ffffffffc02013e4:	6b05                	lui	s6,0x1
ffffffffc02013e6:	4699                	li	a3,6
ffffffffc02013e8:	100b0613          	addi	a2,s6,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02013ec:	85d6                	mv	a1,s5
ffffffffc02013ee:	b43ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc02013f2:	40051e63          	bnez	a0,ffffffffc020180e <pmm_init+0x822>
    assert(page_ref(p) == 2);
ffffffffc02013f6:	000aa703          	lw	a4,0(s5)
ffffffffc02013fa:	4789                	li	a5,2
ffffffffc02013fc:	3ef71963          	bne	a4,a5,ffffffffc02017ee <pmm_init+0x802>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201400:	00004597          	auipc	a1,0x4
ffffffffc0201404:	6b858593          	addi	a1,a1,1720 # ffffffffc0205ab8 <commands+0xc68>
ffffffffc0201408:	10000513          	li	a0,256
ffffffffc020140c:	31e030ef          	jal	ra,ffffffffc020472a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201410:	100b0593          	addi	a1,s6,256
ffffffffc0201414:	10000513          	li	a0,256
ffffffffc0201418:	324030ef          	jal	ra,ffffffffc020473c <strcmp>
ffffffffc020141c:	3a051963          	bnez	a0,ffffffffc02017ce <pmm_init+0x7e2>
    return page - pages + nbase;
ffffffffc0201420:	00093683          	ld	a3,0(s2)
ffffffffc0201424:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0201428:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc020142a:	40da86b3          	sub	a3,s5,a3
ffffffffc020142e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201430:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0201432:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0201434:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0201438:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020143c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020143e:	12f77d63          	bgeu	a4,a5,ffffffffc0201578 <pmm_init+0x58c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201442:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201446:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020144a:	96be                	add	a3,a3,a5
ffffffffc020144c:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6ab00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201450:	2a4030ef          	jal	ra,ffffffffc02046f4 <strlen>
ffffffffc0201454:	4e051963          	bnez	a0,ffffffffc0201946 <pmm_init+0x95a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201458:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020145c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020145e:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a00>
ffffffffc0201462:	068a                	slli	a3,a3,0x2
ffffffffc0201464:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201466:	0ef6f763          	bgeu	a3,a5,ffffffffc0201554 <pmm_init+0x568>
    return KADDR(page2pa(page));
ffffffffc020146a:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc020146e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201470:	10fb7463          	bgeu	s6,a5,ffffffffc0201578 <pmm_init+0x58c>
ffffffffc0201474:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201478:	4585                	li	a1,1
ffffffffc020147a:	8556                	mv	a0,s5
ffffffffc020147c:	99b6                	add	s3,s3,a3
ffffffffc020147e:	f9eff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201482:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201486:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201488:	078a                	slli	a5,a5,0x2
ffffffffc020148a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020148c:	0ce7f463          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc0201490:	00093503          	ld	a0,0(s2)
ffffffffc0201494:	fff809b7          	lui	s3,0xfff80
ffffffffc0201498:	97ce                	add	a5,a5,s3
ffffffffc020149a:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020149c:	953e                	add	a0,a0,a5
ffffffffc020149e:	4585                	li	a1,1
ffffffffc02014a0:	f7cff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02014a4:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02014a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02014aa:	078a                	slli	a5,a5,0x2
ffffffffc02014ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02014ae:	0ae7f363          	bgeu	a5,a4,ffffffffc0201554 <pmm_init+0x568>
    return &pages[PPN(pa) - nbase];
ffffffffc02014b2:	00093503          	ld	a0,0(s2)
ffffffffc02014b6:	97ce                	add	a5,a5,s3
ffffffffc02014b8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02014ba:	953e                	add	a0,a0,a5
ffffffffc02014bc:	4585                	li	a1,1
ffffffffc02014be:	f5eff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02014c2:	601c                	ld	a5,0(s0)
ffffffffc02014c4:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02014c8:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02014cc:	f92ff0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc02014d0:	0eaa1863          	bne	s4,a0,ffffffffc02015c0 <pmm_init+0x5d4>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02014d4:	00004517          	auipc	a0,0x4
ffffffffc02014d8:	65c50513          	addi	a0,a0,1628 # ffffffffc0205b30 <commands+0xce0>
ffffffffc02014dc:	bf1fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02014e0:	6406                	ld	s0,64(sp)
ffffffffc02014e2:	60a6                	ld	ra,72(sp)
ffffffffc02014e4:	74e2                	ld	s1,56(sp)
ffffffffc02014e6:	7942                	ld	s2,48(sp)
ffffffffc02014e8:	79a2                	ld	s3,40(sp)
ffffffffc02014ea:	7a02                	ld	s4,32(sp)
ffffffffc02014ec:	6ae2                	ld	s5,24(sp)
ffffffffc02014ee:	6b42                	ld	s6,16(sp)
ffffffffc02014f0:	6ba2                	ld	s7,8(sp)
ffffffffc02014f2:	6c02                	ld	s8,0(sp)
ffffffffc02014f4:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc02014f6:	3d00106f          	j	ffffffffc02028c6 <kmalloc_init>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02014fa:	86d6                	mv	a3,s5
ffffffffc02014fc:	00004617          	auipc	a2,0x4
ffffffffc0201500:	08c60613          	addi	a2,a2,140 # ffffffffc0205588 <commands+0x738>
ffffffffc0201504:	19d00593          	li	a1,413
ffffffffc0201508:	00004517          	auipc	a0,0x4
ffffffffc020150c:	0a850513          	addi	a0,a0,168 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201510:	cb9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0201514:	00004697          	auipc	a3,0x4
ffffffffc0201518:	48c68693          	addi	a3,a3,1164 # ffffffffc02059a0 <commands+0xb50>
ffffffffc020151c:	00004617          	auipc	a2,0x4
ffffffffc0201520:	17c60613          	addi	a2,a2,380 # ffffffffc0205698 <commands+0x848>
ffffffffc0201524:	19d00593          	li	a1,413
ffffffffc0201528:	00004517          	auipc	a0,0x4
ffffffffc020152c:	08850513          	addi	a0,a0,136 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201530:	c99fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201534:	00004697          	auipc	a3,0x4
ffffffffc0201538:	4ac68693          	addi	a3,a3,1196 # ffffffffc02059e0 <commands+0xb90>
ffffffffc020153c:	00004617          	auipc	a2,0x4
ffffffffc0201540:	15c60613          	addi	a2,a2,348 # ffffffffc0205698 <commands+0x848>
ffffffffc0201544:	19e00593          	li	a1,414
ffffffffc0201548:	00004517          	auipc	a0,0x4
ffffffffc020154c:	06850513          	addi	a0,a0,104 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201550:	c79fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0201554:	e1aff0ef          	jal	ra,ffffffffc0200b6e <pa2page.part.0>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201558:	00004697          	auipc	a3,0x4
ffffffffc020155c:	15868693          	addi	a3,a3,344 # ffffffffc02056b0 <commands+0x860>
ffffffffc0201560:	00004617          	auipc	a2,0x4
ffffffffc0201564:	13860613          	addi	a2,a2,312 # ffffffffc0205698 <commands+0x848>
ffffffffc0201568:	16100593          	li	a1,353
ffffffffc020156c:	00004517          	auipc	a0,0x4
ffffffffc0201570:	04450513          	addi	a0,a0,68 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201574:	c55fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201578:	00004617          	auipc	a2,0x4
ffffffffc020157c:	01060613          	addi	a2,a2,16 # ffffffffc0205588 <commands+0x738>
ffffffffc0201580:	06900593          	li	a1,105
ffffffffc0201584:	00004517          	auipc	a0,0x4
ffffffffc0201588:	ff450513          	addi	a0,a0,-12 # ffffffffc0205578 <commands+0x728>
ffffffffc020158c:	c3dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201590:	00004617          	auipc	a2,0x4
ffffffffc0201594:	1e060613          	addi	a2,a2,480 # ffffffffc0205770 <commands+0x920>
ffffffffc0201598:	07400593          	li	a1,116
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205578 <commands+0x728>
ffffffffc02015a4:	c25fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	07060613          	addi	a2,a2,112 # ffffffffc0205618 <commands+0x7c8>
ffffffffc02015b0:	07f00593          	li	a1,127
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	ffc50513          	addi	a0,a0,-4 # ffffffffc02055b0 <commands+0x760>
ffffffffc02015bc:	c0dfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02015c0:	00004697          	auipc	a3,0x4
ffffffffc02015c4:	3a068693          	addi	a3,a3,928 # ffffffffc0205960 <commands+0xb10>
ffffffffc02015c8:	00004617          	auipc	a2,0x4
ffffffffc02015cc:	0d060613          	addi	a2,a2,208 # ffffffffc0205698 <commands+0x848>
ffffffffc02015d0:	1b800593          	li	a1,440
ffffffffc02015d4:	00004517          	auipc	a0,0x4
ffffffffc02015d8:	fdc50513          	addi	a0,a0,-36 # ffffffffc02055b0 <commands+0x760>
ffffffffc02015dc:	bedfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02015e0:	86da                	mv	a3,s6
ffffffffc02015e2:	00004617          	auipc	a2,0x4
ffffffffc02015e6:	fa660613          	addi	a2,a2,-90 # ffffffffc0205588 <commands+0x738>
ffffffffc02015ea:	16e00593          	li	a1,366
ffffffffc02015ee:	00004517          	auipc	a0,0x4
ffffffffc02015f2:	fc250513          	addi	a0,a0,-62 # ffffffffc02055b0 <commands+0x760>
ffffffffc02015f6:	bd3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02015fa:	86be                	mv	a3,a5
ffffffffc02015fc:	00004617          	auipc	a2,0x4
ffffffffc0201600:	f8c60613          	addi	a2,a2,-116 # ffffffffc0205588 <commands+0x738>
ffffffffc0201604:	16d00593          	li	a1,365
ffffffffc0201608:	00004517          	auipc	a0,0x4
ffffffffc020160c:	fa850513          	addi	a0,a0,-88 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201610:	bb9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0201614:	00004697          	auipc	a3,0x4
ffffffffc0201618:	19c68693          	addi	a3,a3,412 # ffffffffc02057b0 <commands+0x960>
ffffffffc020161c:	00004617          	auipc	a2,0x4
ffffffffc0201620:	07c60613          	addi	a2,a2,124 # ffffffffc0205698 <commands+0x848>
ffffffffc0201624:	16b00593          	li	a1,363
ffffffffc0201628:	00004517          	auipc	a0,0x4
ffffffffc020162c:	f8850513          	addi	a0,a0,-120 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201630:	b99fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0201634:	00004697          	auipc	a3,0x4
ffffffffc0201638:	16468693          	addi	a3,a3,356 # ffffffffc0205798 <commands+0x948>
ffffffffc020163c:	00004617          	auipc	a2,0x4
ffffffffc0201640:	05c60613          	addi	a2,a2,92 # ffffffffc0205698 <commands+0x848>
ffffffffc0201644:	16a00593          	li	a1,362
ffffffffc0201648:	00004517          	auipc	a0,0x4
ffffffffc020164c:	f6850513          	addi	a0,a0,-152 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201650:	b79fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201654:	00004697          	auipc	a3,0x4
ffffffffc0201658:	25468693          	addi	a3,a3,596 # ffffffffc02058a8 <commands+0xa58>
ffffffffc020165c:	00004617          	auipc	a2,0x4
ffffffffc0201660:	03c60613          	addi	a2,a2,60 # ffffffffc0205698 <commands+0x848>
ffffffffc0201664:	17900593          	li	a1,377
ffffffffc0201668:	00004517          	auipc	a0,0x4
ffffffffc020166c:	f4850513          	addi	a0,a0,-184 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201670:	b59fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0201674:	00004697          	auipc	a3,0x4
ffffffffc0201678:	21c68693          	addi	a3,a3,540 # ffffffffc0205890 <commands+0xa40>
ffffffffc020167c:	00004617          	auipc	a2,0x4
ffffffffc0201680:	01c60613          	addi	a2,a2,28 # ffffffffc0205698 <commands+0x848>
ffffffffc0201684:	17700593          	li	a1,375
ffffffffc0201688:	00004517          	auipc	a0,0x4
ffffffffc020168c:	f2850513          	addi	a0,a0,-216 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201690:	b39fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201694:	00004697          	auipc	a3,0x4
ffffffffc0201698:	1e468693          	addi	a3,a3,484 # ffffffffc0205878 <commands+0xa28>
ffffffffc020169c:	00004617          	auipc	a2,0x4
ffffffffc02016a0:	ffc60613          	addi	a2,a2,-4 # ffffffffc0205698 <commands+0x848>
ffffffffc02016a4:	17600593          	li	a1,374
ffffffffc02016a8:	00004517          	auipc	a0,0x4
ffffffffc02016ac:	f0850513          	addi	a0,a0,-248 # ffffffffc02055b0 <commands+0x760>
ffffffffc02016b0:	b19fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02016b4:	00004697          	auipc	a3,0x4
ffffffffc02016b8:	1b468693          	addi	a3,a3,436 # ffffffffc0205868 <commands+0xa18>
ffffffffc02016bc:	00004617          	auipc	a2,0x4
ffffffffc02016c0:	fdc60613          	addi	a2,a2,-36 # ffffffffc0205698 <commands+0x848>
ffffffffc02016c4:	17500593          	li	a1,373
ffffffffc02016c8:	00004517          	auipc	a0,0x4
ffffffffc02016cc:	ee850513          	addi	a0,a0,-280 # ffffffffc02055b0 <commands+0x760>
ffffffffc02016d0:	af9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02016d4:	00004697          	auipc	a3,0x4
ffffffffc02016d8:	18468693          	addi	a3,a3,388 # ffffffffc0205858 <commands+0xa08>
ffffffffc02016dc:	00004617          	auipc	a2,0x4
ffffffffc02016e0:	fbc60613          	addi	a2,a2,-68 # ffffffffc0205698 <commands+0x848>
ffffffffc02016e4:	17400593          	li	a1,372
ffffffffc02016e8:	00004517          	auipc	a0,0x4
ffffffffc02016ec:	ec850513          	addi	a0,a0,-312 # ffffffffc02055b0 <commands+0x760>
ffffffffc02016f0:	ad9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02016f4:	00004697          	auipc	a3,0x4
ffffffffc02016f8:	13468693          	addi	a3,a3,308 # ffffffffc0205828 <commands+0x9d8>
ffffffffc02016fc:	00004617          	auipc	a2,0x4
ffffffffc0201700:	f9c60613          	addi	a2,a2,-100 # ffffffffc0205698 <commands+0x848>
ffffffffc0201704:	17300593          	li	a1,371
ffffffffc0201708:	00004517          	auipc	a0,0x4
ffffffffc020170c:	ea850513          	addi	a0,a0,-344 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201710:	ab9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201714:	00004697          	auipc	a3,0x4
ffffffffc0201718:	0dc68693          	addi	a3,a3,220 # ffffffffc02057f0 <commands+0x9a0>
ffffffffc020171c:	00004617          	auipc	a2,0x4
ffffffffc0201720:	f7c60613          	addi	a2,a2,-132 # ffffffffc0205698 <commands+0x848>
ffffffffc0201724:	17200593          	li	a1,370
ffffffffc0201728:	00004517          	auipc	a0,0x4
ffffffffc020172c:	e8850513          	addi	a0,a0,-376 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201730:	a99fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201734:	00004697          	auipc	a3,0x4
ffffffffc0201738:	09468693          	addi	a3,a3,148 # ffffffffc02057c8 <commands+0x978>
ffffffffc020173c:	00004617          	auipc	a2,0x4
ffffffffc0201740:	f5c60613          	addi	a2,a2,-164 # ffffffffc0205698 <commands+0x848>
ffffffffc0201744:	16f00593          	li	a1,367
ffffffffc0201748:	00004517          	auipc	a0,0x4
ffffffffc020174c:	e6850513          	addi	a0,a0,-408 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201750:	a79fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0201754:	00004697          	auipc	a3,0x4
ffffffffc0201758:	20c68693          	addi	a3,a3,524 # ffffffffc0205960 <commands+0xb10>
ffffffffc020175c:	00004617          	auipc	a2,0x4
ffffffffc0201760:	f3c60613          	addi	a2,a2,-196 # ffffffffc0205698 <commands+0x848>
ffffffffc0201764:	19000593          	li	a1,400
ffffffffc0201768:	00004517          	auipc	a0,0x4
ffffffffc020176c:	e4850513          	addi	a0,a0,-440 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201770:	a59fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201774:	86be                	mv	a3,a5
ffffffffc0201776:	00004617          	auipc	a2,0x4
ffffffffc020177a:	e1260613          	addi	a2,a2,-494 # ffffffffc0205588 <commands+0x738>
ffffffffc020177e:	06900593          	li	a1,105
ffffffffc0201782:	00004517          	auipc	a0,0x4
ffffffffc0201786:	df650513          	addi	a0,a0,-522 # ffffffffc0205578 <commands+0x728>
ffffffffc020178a:	a3ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020178e:	00004697          	auipc	a3,0x4
ffffffffc0201792:	1aa68693          	addi	a3,a3,426 # ffffffffc0205938 <commands+0xae8>
ffffffffc0201796:	00004617          	auipc	a2,0x4
ffffffffc020179a:	f0260613          	addi	a2,a2,-254 # ffffffffc0205698 <commands+0x848>
ffffffffc020179e:	18800593          	li	a1,392
ffffffffc02017a2:	00004517          	auipc	a0,0x4
ffffffffc02017a6:	e0e50513          	addi	a0,a0,-498 # ffffffffc02055b0 <commands+0x760>
ffffffffc02017aa:	a1ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02017ae:	00004697          	auipc	a3,0x4
ffffffffc02017b2:	14268693          	addi	a3,a3,322 # ffffffffc02058f0 <commands+0xaa0>
ffffffffc02017b6:	00004617          	auipc	a2,0x4
ffffffffc02017ba:	ee260613          	addi	a2,a2,-286 # ffffffffc0205698 <commands+0x848>
ffffffffc02017be:	18600593          	li	a1,390
ffffffffc02017c2:	00004517          	auipc	a0,0x4
ffffffffc02017c6:	dee50513          	addi	a0,a0,-530 # ffffffffc02055b0 <commands+0x760>
ffffffffc02017ca:	9fffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02017ce:	00004697          	auipc	a3,0x4
ffffffffc02017d2:	30268693          	addi	a3,a3,770 # ffffffffc0205ad0 <commands+0xc80>
ffffffffc02017d6:	00004617          	auipc	a2,0x4
ffffffffc02017da:	ec260613          	addi	a2,a2,-318 # ffffffffc0205698 <commands+0x848>
ffffffffc02017de:	1ac00593          	li	a1,428
ffffffffc02017e2:	00004517          	auipc	a0,0x4
ffffffffc02017e6:	dce50513          	addi	a0,a0,-562 # ffffffffc02055b0 <commands+0x760>
ffffffffc02017ea:	9dffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02017ee:	00004697          	auipc	a3,0x4
ffffffffc02017f2:	2b268693          	addi	a3,a3,690 # ffffffffc0205aa0 <commands+0xc50>
ffffffffc02017f6:	00004617          	auipc	a2,0x4
ffffffffc02017fa:	ea260613          	addi	a2,a2,-350 # ffffffffc0205698 <commands+0x848>
ffffffffc02017fe:	1a800593          	li	a1,424
ffffffffc0201802:	00004517          	auipc	a0,0x4
ffffffffc0201806:	dae50513          	addi	a0,a0,-594 # ffffffffc02055b0 <commands+0x760>
ffffffffc020180a:	9bffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020180e:	00004697          	auipc	a3,0x4
ffffffffc0201812:	25268693          	addi	a3,a3,594 # ffffffffc0205a60 <commands+0xc10>
ffffffffc0201816:	00004617          	auipc	a2,0x4
ffffffffc020181a:	e8260613          	addi	a2,a2,-382 # ffffffffc0205698 <commands+0x848>
ffffffffc020181e:	1a700593          	li	a1,423
ffffffffc0201822:	00004517          	auipc	a0,0x4
ffffffffc0201826:	d8e50513          	addi	a0,a0,-626 # ffffffffc02055b0 <commands+0x760>
ffffffffc020182a:	99ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020182e:	00004697          	auipc	a3,0x4
ffffffffc0201832:	21a68693          	addi	a3,a3,538 # ffffffffc0205a48 <commands+0xbf8>
ffffffffc0201836:	00004617          	auipc	a2,0x4
ffffffffc020183a:	e6260613          	addi	a2,a2,-414 # ffffffffc0205698 <commands+0x848>
ffffffffc020183e:	1a600593          	li	a1,422
ffffffffc0201842:	00004517          	auipc	a0,0x4
ffffffffc0201846:	d6e50513          	addi	a0,a0,-658 # ffffffffc02055b0 <commands+0x760>
ffffffffc020184a:	97ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020184e:	00004697          	auipc	a3,0x4
ffffffffc0201852:	0d268693          	addi	a3,a3,210 # ffffffffc0205920 <commands+0xad0>
ffffffffc0201856:	00004617          	auipc	a2,0x4
ffffffffc020185a:	e4260613          	addi	a2,a2,-446 # ffffffffc0205698 <commands+0x848>
ffffffffc020185e:	18500593          	li	a1,389
ffffffffc0201862:	00004517          	auipc	a0,0x4
ffffffffc0201866:	d4e50513          	addi	a0,a0,-690 # ffffffffc02055b0 <commands+0x760>
ffffffffc020186a:	95ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020186e:	00004697          	auipc	a3,0x4
ffffffffc0201872:	08268693          	addi	a3,a3,130 # ffffffffc02058f0 <commands+0xaa0>
ffffffffc0201876:	00004617          	auipc	a2,0x4
ffffffffc020187a:	e2260613          	addi	a2,a2,-478 # ffffffffc0205698 <commands+0x848>
ffffffffc020187e:	18200593          	li	a1,386
ffffffffc0201882:	00004517          	auipc	a0,0x4
ffffffffc0201886:	d2e50513          	addi	a0,a0,-722 # ffffffffc02055b0 <commands+0x760>
ffffffffc020188a:	93ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020188e:	00004697          	auipc	a3,0x4
ffffffffc0201892:	f2268693          	addi	a3,a3,-222 # ffffffffc02057b0 <commands+0x960>
ffffffffc0201896:	00004617          	auipc	a2,0x4
ffffffffc020189a:	e0260613          	addi	a2,a2,-510 # ffffffffc0205698 <commands+0x848>
ffffffffc020189e:	18100593          	li	a1,385
ffffffffc02018a2:	00004517          	auipc	a0,0x4
ffffffffc02018a6:	d0e50513          	addi	a0,a0,-754 # ffffffffc02055b0 <commands+0x760>
ffffffffc02018aa:	91ffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02018ae:	00004697          	auipc	a3,0x4
ffffffffc02018b2:	05a68693          	addi	a3,a3,90 # ffffffffc0205908 <commands+0xab8>
ffffffffc02018b6:	00004617          	auipc	a2,0x4
ffffffffc02018ba:	de260613          	addi	a2,a2,-542 # ffffffffc0205698 <commands+0x848>
ffffffffc02018be:	17e00593          	li	a1,382
ffffffffc02018c2:	00004517          	auipc	a0,0x4
ffffffffc02018c6:	cee50513          	addi	a0,a0,-786 # ffffffffc02055b0 <commands+0x760>
ffffffffc02018ca:	8fffe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02018ce:	00004617          	auipc	a2,0x4
ffffffffc02018d2:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205618 <commands+0x7c8>
ffffffffc02018d6:	0c300593          	li	a1,195
ffffffffc02018da:	00004517          	auipc	a0,0x4
ffffffffc02018de:	cd650513          	addi	a0,a0,-810 # ffffffffc02055b0 <commands+0x760>
ffffffffc02018e2:	8e7fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02018e6:	00004697          	auipc	a3,0x4
ffffffffc02018ea:	d9268693          	addi	a3,a3,-622 # ffffffffc0205678 <commands+0x828>
ffffffffc02018ee:	00004617          	auipc	a2,0x4
ffffffffc02018f2:	daa60613          	addi	a2,a2,-598 # ffffffffc0205698 <commands+0x848>
ffffffffc02018f6:	16000593          	li	a1,352
ffffffffc02018fa:	00004517          	auipc	a0,0x4
ffffffffc02018fe:	cb650513          	addi	a0,a0,-842 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201902:	8c7fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201906:	00004697          	auipc	a3,0x4
ffffffffc020190a:	10a68693          	addi	a3,a3,266 # ffffffffc0205a10 <commands+0xbc0>
ffffffffc020190e:	00004617          	auipc	a2,0x4
ffffffffc0201912:	d8a60613          	addi	a2,a2,-630 # ffffffffc0205698 <commands+0x848>
ffffffffc0201916:	1a500593          	li	a1,421
ffffffffc020191a:	00004517          	auipc	a0,0x4
ffffffffc020191e:	c9650513          	addi	a0,a0,-874 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201922:	8a7fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0201926:	00004697          	auipc	a3,0x4
ffffffffc020192a:	0d268693          	addi	a3,a3,210 # ffffffffc02059f8 <commands+0xba8>
ffffffffc020192e:	00004617          	auipc	a2,0x4
ffffffffc0201932:	d6a60613          	addi	a2,a2,-662 # ffffffffc0205698 <commands+0x848>
ffffffffc0201936:	1a100593          	li	a1,417
ffffffffc020193a:	00004517          	auipc	a0,0x4
ffffffffc020193e:	c7650513          	addi	a0,a0,-906 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201942:	887fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201946:	00004697          	auipc	a3,0x4
ffffffffc020194a:	1c268693          	addi	a3,a3,450 # ffffffffc0205b08 <commands+0xcb8>
ffffffffc020194e:	00004617          	auipc	a2,0x4
ffffffffc0201952:	d4a60613          	addi	a2,a2,-694 # ffffffffc0205698 <commands+0x848>
ffffffffc0201956:	1af00593          	li	a1,431
ffffffffc020195a:	00004517          	auipc	a0,0x4
ffffffffc020195e:	c5650513          	addi	a0,a0,-938 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201962:	867fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201966:	00004697          	auipc	a3,0x4
ffffffffc020196a:	dda68693          	addi	a3,a3,-550 # ffffffffc0205740 <commands+0x8f0>
ffffffffc020196e:	00004617          	auipc	a2,0x4
ffffffffc0201972:	d2a60613          	addi	a2,a2,-726 # ffffffffc0205698 <commands+0x848>
ffffffffc0201976:	16900593          	li	a1,361
ffffffffc020197a:	00004517          	auipc	a0,0x4
ffffffffc020197e:	c3650513          	addi	a0,a0,-970 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201982:	847fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201986:	00004697          	auipc	a3,0x4
ffffffffc020198a:	d8a68693          	addi	a3,a3,-630 # ffffffffc0205710 <commands+0x8c0>
ffffffffc020198e:	00004617          	auipc	a2,0x4
ffffffffc0201992:	d0a60613          	addi	a2,a2,-758 # ffffffffc0205698 <commands+0x848>
ffffffffc0201996:	16600593          	li	a1,358
ffffffffc020199a:	00004517          	auipc	a0,0x4
ffffffffc020199e:	c1650513          	addi	a0,a0,-1002 # ffffffffc02055b0 <commands+0x760>
ffffffffc02019a2:	827fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02019a6:	00004697          	auipc	a3,0x4
ffffffffc02019aa:	d4268693          	addi	a3,a3,-702 # ffffffffc02056e8 <commands+0x898>
ffffffffc02019ae:	00004617          	auipc	a2,0x4
ffffffffc02019b2:	cea60613          	addi	a2,a2,-790 # ffffffffc0205698 <commands+0x848>
ffffffffc02019b6:	16200593          	li	a1,354
ffffffffc02019ba:	00004517          	auipc	a0,0x4
ffffffffc02019be:	bf650513          	addi	a0,a0,-1034 # ffffffffc02055b0 <commands+0x760>
ffffffffc02019c2:	807fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02019c6:	00004697          	auipc	a3,0x4
ffffffffc02019ca:	dd268693          	addi	a3,a3,-558 # ffffffffc0205798 <commands+0x948>
ffffffffc02019ce:	00004617          	auipc	a2,0x4
ffffffffc02019d2:	cca60613          	addi	a2,a2,-822 # ffffffffc0205698 <commands+0x848>
ffffffffc02019d6:	17d00593          	li	a1,381
ffffffffc02019da:	00004517          	auipc	a0,0x4
ffffffffc02019de:	bd650513          	addi	a0,a0,-1066 # ffffffffc02055b0 <commands+0x760>
ffffffffc02019e2:	fe6fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02019e6:	00004697          	auipc	a3,0x4
ffffffffc02019ea:	e4268693          	addi	a3,a3,-446 # ffffffffc0205828 <commands+0x9d8>
ffffffffc02019ee:	00004617          	auipc	a2,0x4
ffffffffc02019f2:	caa60613          	addi	a2,a2,-854 # ffffffffc0205698 <commands+0x848>
ffffffffc02019f6:	17c00593          	li	a1,380
ffffffffc02019fa:	00004517          	auipc	a0,0x4
ffffffffc02019fe:	bb650513          	addi	a0,a0,-1098 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201a02:	fc6fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0201a06:	00004697          	auipc	a3,0x4
ffffffffc0201a0a:	eea68693          	addi	a3,a3,-278 # ffffffffc02058f0 <commands+0xaa0>
ffffffffc0201a0e:	00004617          	auipc	a2,0x4
ffffffffc0201a12:	c8a60613          	addi	a2,a2,-886 # ffffffffc0205698 <commands+0x848>
ffffffffc0201a16:	17b00593          	li	a1,379
ffffffffc0201a1a:	00004517          	auipc	a0,0x4
ffffffffc0201a1e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201a22:	fa6fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0201a26:	00004697          	auipc	a3,0x4
ffffffffc0201a2a:	eb268693          	addi	a3,a3,-334 # ffffffffc02058d8 <commands+0xa88>
ffffffffc0201a2e:	00004617          	auipc	a2,0x4
ffffffffc0201a32:	c6a60613          	addi	a2,a2,-918 # ffffffffc0205698 <commands+0x848>
ffffffffc0201a36:	17a00593          	li	a1,378
ffffffffc0201a3a:	00004517          	auipc	a0,0x4
ffffffffc0201a3e:	b7650513          	addi	a0,a0,-1162 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201a42:	f86fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201a46 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201a46:	12058073          	sfence.vma	a1
}
ffffffffc0201a4a:	8082                	ret

ffffffffc0201a4c <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a4c:	7179                	addi	sp,sp,-48
ffffffffc0201a4e:	e84a                	sd	s2,16(sp)
ffffffffc0201a50:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0201a52:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0201a54:	f022                	sd	s0,32(sp)
ffffffffc0201a56:	ec26                	sd	s1,24(sp)
ffffffffc0201a58:	e44e                	sd	s3,8(sp)
ffffffffc0201a5a:	f406                	sd	ra,40(sp)
ffffffffc0201a5c:	84ae                	mv	s1,a1
ffffffffc0201a5e:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0201a60:	92aff0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0201a64:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0201a66:	cd09                	beqz	a0,ffffffffc0201a80 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201a68:	85aa                	mv	a1,a0
ffffffffc0201a6a:	86ce                	mv	a3,s3
ffffffffc0201a6c:	8626                	mv	a2,s1
ffffffffc0201a6e:	854a                	mv	a0,s2
ffffffffc0201a70:	cc0ff0ef          	jal	ra,ffffffffc0200f30 <page_insert>
ffffffffc0201a74:	ed21                	bnez	a0,ffffffffc0201acc <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0201a76:	00014797          	auipc	a5,0x14
ffffffffc0201a7a:	a327a783          	lw	a5,-1486(a5) # ffffffffc02154a8 <swap_init_ok>
ffffffffc0201a7e:	eb89                	bnez	a5,ffffffffc0201a90 <pgdir_alloc_page+0x44>
}
ffffffffc0201a80:	70a2                	ld	ra,40(sp)
ffffffffc0201a82:	8522                	mv	a0,s0
ffffffffc0201a84:	7402                	ld	s0,32(sp)
ffffffffc0201a86:	64e2                	ld	s1,24(sp)
ffffffffc0201a88:	6942                	ld	s2,16(sp)
ffffffffc0201a8a:	69a2                	ld	s3,8(sp)
ffffffffc0201a8c:	6145                	addi	sp,sp,48
ffffffffc0201a8e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0201a90:	4681                	li	a3,0
ffffffffc0201a92:	8622                	mv	a2,s0
ffffffffc0201a94:	85a6                	mv	a1,s1
ffffffffc0201a96:	00014517          	auipc	a0,0x14
ffffffffc0201a9a:	a7253503          	ld	a0,-1422(a0) # ffffffffc0215508 <check_mm_struct>
ffffffffc0201a9e:	736010ef          	jal	ra,ffffffffc02031d4 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0201aa2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0201aa4:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0201aa6:	4785                	li	a5,1
ffffffffc0201aa8:	fcf70ce3          	beq	a4,a5,ffffffffc0201a80 <pgdir_alloc_page+0x34>
ffffffffc0201aac:	00004697          	auipc	a3,0x4
ffffffffc0201ab0:	0a468693          	addi	a3,a3,164 # ffffffffc0205b50 <commands+0xd00>
ffffffffc0201ab4:	00004617          	auipc	a2,0x4
ffffffffc0201ab8:	be460613          	addi	a2,a2,-1052 # ffffffffc0205698 <commands+0x848>
ffffffffc0201abc:	14800593          	li	a1,328
ffffffffc0201ac0:	00004517          	auipc	a0,0x4
ffffffffc0201ac4:	af050513          	addi	a0,a0,-1296 # ffffffffc02055b0 <commands+0x760>
ffffffffc0201ac8:	f00fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
            free_page(page);
ffffffffc0201acc:	8522                	mv	a0,s0
ffffffffc0201ace:	4585                	li	a1,1
ffffffffc0201ad0:	94cff0ef          	jal	ra,ffffffffc0200c1c <free_pages>
            return NULL;
ffffffffc0201ad4:	4401                	li	s0,0
ffffffffc0201ad6:	b76d                	j	ffffffffc0201a80 <pgdir_alloc_page+0x34>

ffffffffc0201ad8 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201ad8:	00014797          	auipc	a5,0x14
ffffffffc0201adc:	a2078793          	addi	a5,a5,-1504 # ffffffffc02154f8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0201ae0:	f51c                	sd	a5,40(a0)
ffffffffc0201ae2:	e79c                	sd	a5,8(a5)
ffffffffc0201ae4:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0201ae6:	4501                	li	a0,0
ffffffffc0201ae8:	8082                	ret

ffffffffc0201aea <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0201aea:	4501                	li	a0,0
ffffffffc0201aec:	8082                	ret

ffffffffc0201aee <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0201aee:	4501                	li	a0,0
ffffffffc0201af0:	8082                	ret

ffffffffc0201af2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0201af2:	4501                	li	a0,0
ffffffffc0201af4:	8082                	ret

ffffffffc0201af6 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0201af6:	711d                	addi	sp,sp,-96
ffffffffc0201af8:	fc4e                	sd	s3,56(sp)
ffffffffc0201afa:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201afc:	00004517          	auipc	a0,0x4
ffffffffc0201b00:	06c50513          	addi	a0,a0,108 # ffffffffc0205b68 <commands+0xd18>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b04:	698d                	lui	s3,0x3
ffffffffc0201b06:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0201b08:	e0ca                	sd	s2,64(sp)
ffffffffc0201b0a:	ec86                	sd	ra,88(sp)
ffffffffc0201b0c:	e8a2                	sd	s0,80(sp)
ffffffffc0201b0e:	e4a6                	sd	s1,72(sp)
ffffffffc0201b10:	f456                	sd	s5,40(sp)
ffffffffc0201b12:	f05a                	sd	s6,32(sp)
ffffffffc0201b14:	ec5e                	sd	s7,24(sp)
ffffffffc0201b16:	e862                	sd	s8,16(sp)
ffffffffc0201b18:	e466                	sd	s9,8(sp)
ffffffffc0201b1a:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201b1c:	db0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201b20:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0201b24:	00014917          	auipc	s2,0x14
ffffffffc0201b28:	96c92903          	lw	s2,-1684(s2) # ffffffffc0215490 <pgfault_num>
ffffffffc0201b2c:	4791                	li	a5,4
ffffffffc0201b2e:	14f91e63          	bne	s2,a5,ffffffffc0201c8a <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b32:	00004517          	auipc	a0,0x4
ffffffffc0201b36:	08650513          	addi	a0,a0,134 # ffffffffc0205bb8 <commands+0xd68>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b3a:	6a85                	lui	s5,0x1
ffffffffc0201b3c:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201b3e:	d8efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201b42:	00014417          	auipc	s0,0x14
ffffffffc0201b46:	94e40413          	addi	s0,s0,-1714 # ffffffffc0215490 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201b4a:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0201b4e:	4004                	lw	s1,0(s0)
ffffffffc0201b50:	2481                	sext.w	s1,s1
ffffffffc0201b52:	2b249c63          	bne	s1,s2,ffffffffc0201e0a <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b56:	00004517          	auipc	a0,0x4
ffffffffc0201b5a:	08a50513          	addi	a0,a0,138 # ffffffffc0205be0 <commands+0xd90>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b5e:	6b91                	lui	s7,0x4
ffffffffc0201b60:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201b62:	d6afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201b66:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0201b6a:	00042903          	lw	s2,0(s0)
ffffffffc0201b6e:	2901                	sext.w	s2,s2
ffffffffc0201b70:	26991d63          	bne	s2,s1,ffffffffc0201dea <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b74:	00004517          	auipc	a0,0x4
ffffffffc0201b78:	09450513          	addi	a0,a0,148 # ffffffffc0205c08 <commands+0xdb8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b7c:	6c89                	lui	s9,0x2
ffffffffc0201b7e:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201b80:	d4cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201b84:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0201b88:	401c                	lw	a5,0(s0)
ffffffffc0201b8a:	2781                	sext.w	a5,a5
ffffffffc0201b8c:	23279f63          	bne	a5,s2,ffffffffc0201dca <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201b90:	00004517          	auipc	a0,0x4
ffffffffc0201b94:	0a050513          	addi	a0,a0,160 # ffffffffc0205c30 <commands+0xde0>
ffffffffc0201b98:	d34fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201b9c:	6795                	lui	a5,0x5
ffffffffc0201b9e:	4739                	li	a4,14
ffffffffc0201ba0:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0201ba4:	4004                	lw	s1,0(s0)
ffffffffc0201ba6:	4795                	li	a5,5
ffffffffc0201ba8:	2481                	sext.w	s1,s1
ffffffffc0201baa:	20f49063          	bne	s1,a5,ffffffffc0201daa <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201bae:	00004517          	auipc	a0,0x4
ffffffffc0201bb2:	05a50513          	addi	a0,a0,90 # ffffffffc0205c08 <commands+0xdb8>
ffffffffc0201bb6:	d16fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bba:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0201bbe:	401c                	lw	a5,0(s0)
ffffffffc0201bc0:	2781                	sext.w	a5,a5
ffffffffc0201bc2:	1c979463          	bne	a5,s1,ffffffffc0201d8a <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201bc6:	00004517          	auipc	a0,0x4
ffffffffc0201bca:	ff250513          	addi	a0,a0,-14 # ffffffffc0205bb8 <commands+0xd68>
ffffffffc0201bce:	cfefe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201bd2:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0201bd6:	401c                	lw	a5,0(s0)
ffffffffc0201bd8:	4719                	li	a4,6
ffffffffc0201bda:	2781                	sext.w	a5,a5
ffffffffc0201bdc:	18e79763          	bne	a5,a4,ffffffffc0201d6a <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0201be0:	00004517          	auipc	a0,0x4
ffffffffc0201be4:	02850513          	addi	a0,a0,40 # ffffffffc0205c08 <commands+0xdb8>
ffffffffc0201be8:	ce4fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0201bec:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0201bf0:	401c                	lw	a5,0(s0)
ffffffffc0201bf2:	471d                	li	a4,7
ffffffffc0201bf4:	2781                	sext.w	a5,a5
ffffffffc0201bf6:	14e79a63          	bne	a5,a4,ffffffffc0201d4a <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201bfa:	00004517          	auipc	a0,0x4
ffffffffc0201bfe:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205b68 <commands+0xd18>
ffffffffc0201c02:	ccafe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201c06:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0201c0a:	401c                	lw	a5,0(s0)
ffffffffc0201c0c:	4721                	li	a4,8
ffffffffc0201c0e:	2781                	sext.w	a5,a5
ffffffffc0201c10:	10e79d63          	bne	a5,a4,ffffffffc0201d2a <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201c14:	00004517          	auipc	a0,0x4
ffffffffc0201c18:	fcc50513          	addi	a0,a0,-52 # ffffffffc0205be0 <commands+0xd90>
ffffffffc0201c1c:	cb0fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201c20:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0201c24:	401c                	lw	a5,0(s0)
ffffffffc0201c26:	4725                	li	a4,9
ffffffffc0201c28:	2781                	sext.w	a5,a5
ffffffffc0201c2a:	0ee79063          	bne	a5,a4,ffffffffc0201d0a <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0201c2e:	00004517          	auipc	a0,0x4
ffffffffc0201c32:	00250513          	addi	a0,a0,2 # ffffffffc0205c30 <commands+0xde0>
ffffffffc0201c36:	c96fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0201c3a:	6795                	lui	a5,0x5
ffffffffc0201c3c:	4739                	li	a4,14
ffffffffc0201c3e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0201c42:	4004                	lw	s1,0(s0)
ffffffffc0201c44:	47a9                	li	a5,10
ffffffffc0201c46:	2481                	sext.w	s1,s1
ffffffffc0201c48:	0af49163          	bne	s1,a5,ffffffffc0201cea <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201c4c:	00004517          	auipc	a0,0x4
ffffffffc0201c50:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205bb8 <commands+0xd68>
ffffffffc0201c54:	c78fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201c58:	6785                	lui	a5,0x1
ffffffffc0201c5a:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201c5e:	06979663          	bne	a5,s1,ffffffffc0201cca <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0201c62:	401c                	lw	a5,0(s0)
ffffffffc0201c64:	472d                	li	a4,11
ffffffffc0201c66:	2781                	sext.w	a5,a5
ffffffffc0201c68:	04e79163          	bne	a5,a4,ffffffffc0201caa <_fifo_check_swap+0x1b4>
}
ffffffffc0201c6c:	60e6                	ld	ra,88(sp)
ffffffffc0201c6e:	6446                	ld	s0,80(sp)
ffffffffc0201c70:	64a6                	ld	s1,72(sp)
ffffffffc0201c72:	6906                	ld	s2,64(sp)
ffffffffc0201c74:	79e2                	ld	s3,56(sp)
ffffffffc0201c76:	7a42                	ld	s4,48(sp)
ffffffffc0201c78:	7aa2                	ld	s5,40(sp)
ffffffffc0201c7a:	7b02                	ld	s6,32(sp)
ffffffffc0201c7c:	6be2                	ld	s7,24(sp)
ffffffffc0201c7e:	6c42                	ld	s8,16(sp)
ffffffffc0201c80:	6ca2                	ld	s9,8(sp)
ffffffffc0201c82:	6d02                	ld	s10,0(sp)
ffffffffc0201c84:	4501                	li	a0,0
ffffffffc0201c86:	6125                	addi	sp,sp,96
ffffffffc0201c88:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0201c8a:	00004697          	auipc	a3,0x4
ffffffffc0201c8e:	f0668693          	addi	a3,a3,-250 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0201c92:	00004617          	auipc	a2,0x4
ffffffffc0201c96:	a0660613          	addi	a2,a2,-1530 # ffffffffc0205698 <commands+0x848>
ffffffffc0201c9a:	05500593          	li	a1,85
ffffffffc0201c9e:	00004517          	auipc	a0,0x4
ffffffffc0201ca2:	f0250513          	addi	a0,a0,-254 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201ca6:	d22fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc0201caa:	00004697          	auipc	a3,0x4
ffffffffc0201cae:	03668693          	addi	a3,a3,54 # ffffffffc0205ce0 <commands+0xe90>
ffffffffc0201cb2:	00004617          	auipc	a2,0x4
ffffffffc0201cb6:	9e660613          	addi	a2,a2,-1562 # ffffffffc0205698 <commands+0x848>
ffffffffc0201cba:	07700593          	li	a1,119
ffffffffc0201cbe:	00004517          	auipc	a0,0x4
ffffffffc0201cc2:	ee250513          	addi	a0,a0,-286 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201cc6:	d02fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201cca:	00004697          	auipc	a3,0x4
ffffffffc0201cce:	fee68693          	addi	a3,a3,-18 # ffffffffc0205cb8 <commands+0xe68>
ffffffffc0201cd2:	00004617          	auipc	a2,0x4
ffffffffc0201cd6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0205698 <commands+0x848>
ffffffffc0201cda:	07500593          	li	a1,117
ffffffffc0201cde:	00004517          	auipc	a0,0x4
ffffffffc0201ce2:	ec250513          	addi	a0,a0,-318 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201ce6:	ce2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc0201cea:	00004697          	auipc	a3,0x4
ffffffffc0201cee:	fbe68693          	addi	a3,a3,-66 # ffffffffc0205ca8 <commands+0xe58>
ffffffffc0201cf2:	00004617          	auipc	a2,0x4
ffffffffc0201cf6:	9a660613          	addi	a2,a2,-1626 # ffffffffc0205698 <commands+0x848>
ffffffffc0201cfa:	07300593          	li	a1,115
ffffffffc0201cfe:	00004517          	auipc	a0,0x4
ffffffffc0201d02:	ea250513          	addi	a0,a0,-350 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201d06:	cc2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc0201d0a:	00004697          	auipc	a3,0x4
ffffffffc0201d0e:	f8e68693          	addi	a3,a3,-114 # ffffffffc0205c98 <commands+0xe48>
ffffffffc0201d12:	00004617          	auipc	a2,0x4
ffffffffc0201d16:	98660613          	addi	a2,a2,-1658 # ffffffffc0205698 <commands+0x848>
ffffffffc0201d1a:	07000593          	li	a1,112
ffffffffc0201d1e:	00004517          	auipc	a0,0x4
ffffffffc0201d22:	e8250513          	addi	a0,a0,-382 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201d26:	ca2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc0201d2a:	00004697          	auipc	a3,0x4
ffffffffc0201d2e:	f5e68693          	addi	a3,a3,-162 # ffffffffc0205c88 <commands+0xe38>
ffffffffc0201d32:	00004617          	auipc	a2,0x4
ffffffffc0201d36:	96660613          	addi	a2,a2,-1690 # ffffffffc0205698 <commands+0x848>
ffffffffc0201d3a:	06d00593          	li	a1,109
ffffffffc0201d3e:	00004517          	auipc	a0,0x4
ffffffffc0201d42:	e6250513          	addi	a0,a0,-414 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201d46:	c82fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc0201d4a:	00004697          	auipc	a3,0x4
ffffffffc0201d4e:	f2e68693          	addi	a3,a3,-210 # ffffffffc0205c78 <commands+0xe28>
ffffffffc0201d52:	00004617          	auipc	a2,0x4
ffffffffc0201d56:	94660613          	addi	a2,a2,-1722 # ffffffffc0205698 <commands+0x848>
ffffffffc0201d5a:	06a00593          	li	a1,106
ffffffffc0201d5e:	00004517          	auipc	a0,0x4
ffffffffc0201d62:	e4250513          	addi	a0,a0,-446 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201d66:	c62fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc0201d6a:	00004697          	auipc	a3,0x4
ffffffffc0201d6e:	efe68693          	addi	a3,a3,-258 # ffffffffc0205c68 <commands+0xe18>
ffffffffc0201d72:	00004617          	auipc	a2,0x4
ffffffffc0201d76:	92660613          	addi	a2,a2,-1754 # ffffffffc0205698 <commands+0x848>
ffffffffc0201d7a:	06700593          	li	a1,103
ffffffffc0201d7e:	00004517          	auipc	a0,0x4
ffffffffc0201d82:	e2250513          	addi	a0,a0,-478 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201d86:	c42fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201d8a:	00004697          	auipc	a3,0x4
ffffffffc0201d8e:	ece68693          	addi	a3,a3,-306 # ffffffffc0205c58 <commands+0xe08>
ffffffffc0201d92:	00004617          	auipc	a2,0x4
ffffffffc0201d96:	90660613          	addi	a2,a2,-1786 # ffffffffc0205698 <commands+0x848>
ffffffffc0201d9a:	06400593          	li	a1,100
ffffffffc0201d9e:	00004517          	auipc	a0,0x4
ffffffffc0201da2:	e0250513          	addi	a0,a0,-510 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201da6:	c22fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc0201daa:	00004697          	auipc	a3,0x4
ffffffffc0201dae:	eae68693          	addi	a3,a3,-338 # ffffffffc0205c58 <commands+0xe08>
ffffffffc0201db2:	00004617          	auipc	a2,0x4
ffffffffc0201db6:	8e660613          	addi	a2,a2,-1818 # ffffffffc0205698 <commands+0x848>
ffffffffc0201dba:	06100593          	li	a1,97
ffffffffc0201dbe:	00004517          	auipc	a0,0x4
ffffffffc0201dc2:	de250513          	addi	a0,a0,-542 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201dc6:	c02fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dca:	00004697          	auipc	a3,0x4
ffffffffc0201dce:	dc668693          	addi	a3,a3,-570 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0201dd2:	00004617          	auipc	a2,0x4
ffffffffc0201dd6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0205698 <commands+0x848>
ffffffffc0201dda:	05e00593          	li	a1,94
ffffffffc0201dde:	00004517          	auipc	a0,0x4
ffffffffc0201de2:	dc250513          	addi	a0,a0,-574 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201de6:	be2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201dea:	00004697          	auipc	a3,0x4
ffffffffc0201dee:	da668693          	addi	a3,a3,-602 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0201df2:	00004617          	auipc	a2,0x4
ffffffffc0201df6:	8a660613          	addi	a2,a2,-1882 # ffffffffc0205698 <commands+0x848>
ffffffffc0201dfa:	05b00593          	li	a1,91
ffffffffc0201dfe:	00004517          	auipc	a0,0x4
ffffffffc0201e02:	da250513          	addi	a0,a0,-606 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201e06:	bc2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc0201e0a:	00004697          	auipc	a3,0x4
ffffffffc0201e0e:	d8668693          	addi	a3,a3,-634 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0201e12:	00004617          	auipc	a2,0x4
ffffffffc0201e16:	88660613          	addi	a2,a2,-1914 # ffffffffc0205698 <commands+0x848>
ffffffffc0201e1a:	05800593          	li	a1,88
ffffffffc0201e1e:	00004517          	auipc	a0,0x4
ffffffffc0201e22:	d8250513          	addi	a0,a0,-638 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201e26:	ba2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201e2a <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e2a:	7518                	ld	a4,40(a0)
{
ffffffffc0201e2c:	1141                	addi	sp,sp,-16
ffffffffc0201e2e:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0201e30:	c731                	beqz	a4,ffffffffc0201e7c <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0201e32:	e60d                	bnez	a2,ffffffffc0201e5c <_fifo_swap_out_victim+0x32>
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0201e34:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0201e36:	00f70d63          	beq	a4,a5,ffffffffc0201e50 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201e3a:	6394                	ld	a3,0(a5)
ffffffffc0201e3c:	6798                	ld	a4,8(a5)
}
ffffffffc0201e3e:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0201e40:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201e44:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0201e46:	e314                	sd	a3,0(a4)
ffffffffc0201e48:	e19c                	sd	a5,0(a1)
}
ffffffffc0201e4a:	4501                	li	a0,0
ffffffffc0201e4c:	0141                	addi	sp,sp,16
ffffffffc0201e4e:	8082                	ret
ffffffffc0201e50:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0201e52:	0005b023          	sd	zero,0(a1)
}
ffffffffc0201e56:	4501                	li	a0,0
ffffffffc0201e58:	0141                	addi	sp,sp,16
ffffffffc0201e5a:	8082                	ret
     assert(in_tick==0);
ffffffffc0201e5c:	00004697          	auipc	a3,0x4
ffffffffc0201e60:	ea468693          	addi	a3,a3,-348 # ffffffffc0205d00 <commands+0xeb0>
ffffffffc0201e64:	00004617          	auipc	a2,0x4
ffffffffc0201e68:	83460613          	addi	a2,a2,-1996 # ffffffffc0205698 <commands+0x848>
ffffffffc0201e6c:	04200593          	li	a1,66
ffffffffc0201e70:	00004517          	auipc	a0,0x4
ffffffffc0201e74:	d3050513          	addi	a0,a0,-720 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201e78:	b50fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(head != NULL);
ffffffffc0201e7c:	00004697          	auipc	a3,0x4
ffffffffc0201e80:	e7468693          	addi	a3,a3,-396 # ffffffffc0205cf0 <commands+0xea0>
ffffffffc0201e84:	00004617          	auipc	a2,0x4
ffffffffc0201e88:	81460613          	addi	a2,a2,-2028 # ffffffffc0205698 <commands+0x848>
ffffffffc0201e8c:	04100593          	li	a1,65
ffffffffc0201e90:	00004517          	auipc	a0,0x4
ffffffffc0201e94:	d1050513          	addi	a0,a0,-752 # ffffffffc0205ba0 <commands+0xd50>
ffffffffc0201e98:	b30fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201e9c <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0201e9c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0201e9e:	cb91                	beqz	a5,ffffffffc0201eb2 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201ea0:	6794                	ld	a3,8(a5)
ffffffffc0201ea2:	02860713          	addi	a4,a2,40
}
ffffffffc0201ea6:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0201ea8:	e298                	sd	a4,0(a3)
ffffffffc0201eaa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201eac:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc0201eae:	f61c                	sd	a5,40(a2)
ffffffffc0201eb0:	8082                	ret
{
ffffffffc0201eb2:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0201eb4:	00004697          	auipc	a3,0x4
ffffffffc0201eb8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205d10 <commands+0xec0>
ffffffffc0201ebc:	00003617          	auipc	a2,0x3
ffffffffc0201ec0:	7dc60613          	addi	a2,a2,2012 # ffffffffc0205698 <commands+0x848>
ffffffffc0201ec4:	03200593          	li	a1,50
ffffffffc0201ec8:	00004517          	auipc	a0,0x4
ffffffffc0201ecc:	cd850513          	addi	a0,a0,-808 # ffffffffc0205ba0 <commands+0xd50>
{
ffffffffc0201ed0:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0201ed2:	af6fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201ed6 <check_vma_overlap.isra.0.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201ed6:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201ed8:	00004697          	auipc	a3,0x4
ffffffffc0201edc:	e7068693          	addi	a3,a3,-400 # ffffffffc0205d48 <commands+0xef8>
ffffffffc0201ee0:	00003617          	auipc	a2,0x3
ffffffffc0201ee4:	7b860613          	addi	a2,a2,1976 # ffffffffc0205698 <commands+0x848>
ffffffffc0201ee8:	07e00593          	li	a1,126
ffffffffc0201eec:	00004517          	auipc	a0,0x4
ffffffffc0201ef0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205d68 <commands+0xf18>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0201ef4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201ef6:	ad2fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201efa <mm_create>:
mm_create(void) {
ffffffffc0201efa:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201efc:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0201f00:	e022                	sd	s0,0(sp)
ffffffffc0201f02:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201f04:	1e3000ef          	jal	ra,ffffffffc02028e6 <kmalloc>
ffffffffc0201f08:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0201f0a:	c105                	beqz	a0,ffffffffc0201f2a <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc0201f0c:	e408                	sd	a0,8(s0)
ffffffffc0201f0e:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0201f10:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201f14:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201f18:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201f1c:	00013797          	auipc	a5,0x13
ffffffffc0201f20:	58c7a783          	lw	a5,1420(a5) # ffffffffc02154a8 <swap_init_ok>
ffffffffc0201f24:	eb81                	bnez	a5,ffffffffc0201f34 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0201f26:	02053423          	sd	zero,40(a0)
}
ffffffffc0201f2a:	60a2                	ld	ra,8(sp)
ffffffffc0201f2c:	8522                	mv	a0,s0
ffffffffc0201f2e:	6402                	ld	s0,0(sp)
ffffffffc0201f30:	0141                	addi	sp,sp,16
ffffffffc0201f32:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201f34:	292010ef          	jal	ra,ffffffffc02031c6 <swap_init_mm>
}
ffffffffc0201f38:	60a2                	ld	ra,8(sp)
ffffffffc0201f3a:	8522                	mv	a0,s0
ffffffffc0201f3c:	6402                	ld	s0,0(sp)
ffffffffc0201f3e:	0141                	addi	sp,sp,16
ffffffffc0201f40:	8082                	ret

ffffffffc0201f42 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201f42:	1101                	addi	sp,sp,-32
ffffffffc0201f44:	e04a                	sd	s2,0(sp)
ffffffffc0201f46:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f48:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0201f4c:	e822                	sd	s0,16(sp)
ffffffffc0201f4e:	e426                	sd	s1,8(sp)
ffffffffc0201f50:	ec06                	sd	ra,24(sp)
ffffffffc0201f52:	84ae                	mv	s1,a1
ffffffffc0201f54:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201f56:	191000ef          	jal	ra,ffffffffc02028e6 <kmalloc>
    if (vma != NULL) {
ffffffffc0201f5a:	c509                	beqz	a0,ffffffffc0201f64 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0201f5c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0201f60:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201f62:	cd00                	sw	s0,24(a0)
}
ffffffffc0201f64:	60e2                	ld	ra,24(sp)
ffffffffc0201f66:	6442                	ld	s0,16(sp)
ffffffffc0201f68:	64a2                	ld	s1,8(sp)
ffffffffc0201f6a:	6902                	ld	s2,0(sp)
ffffffffc0201f6c:	6105                	addi	sp,sp,32
ffffffffc0201f6e:	8082                	ret

ffffffffc0201f70 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0201f70:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0201f72:	c505                	beqz	a0,ffffffffc0201f9a <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201f74:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201f76:	c501                	beqz	a0,ffffffffc0201f7e <find_vma+0xe>
ffffffffc0201f78:	651c                	ld	a5,8(a0)
ffffffffc0201f7a:	02f5f263          	bgeu	a1,a5,ffffffffc0201f9e <find_vma+0x2e>
    return listelm->next;
ffffffffc0201f7e:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0201f80:	00f68d63          	beq	a3,a5,ffffffffc0201f9a <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0201f84:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201f88:	00e5e663          	bltu	a1,a4,ffffffffc0201f94 <find_vma+0x24>
ffffffffc0201f8c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201f90:	00e5ec63          	bltu	a1,a4,ffffffffc0201fa8 <find_vma+0x38>
ffffffffc0201f94:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0201f96:	fef697e3          	bne	a3,a5,ffffffffc0201f84 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201f9a:	4501                	li	a0,0
}
ffffffffc0201f9c:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0201f9e:	691c                	ld	a5,16(a0)
ffffffffc0201fa0:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201f7e <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201fa4:	ea88                	sd	a0,16(a3)
ffffffffc0201fa6:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0201fa8:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201fac:	ea88                	sd	a0,16(a3)
ffffffffc0201fae:	8082                	ret

ffffffffc0201fb0 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201fb0:	6590                	ld	a2,8(a1)
ffffffffc0201fb2:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0201fb6:	1141                	addi	sp,sp,-16
ffffffffc0201fb8:	e406                	sd	ra,8(sp)
ffffffffc0201fba:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201fbc:	01066763          	bltu	a2,a6,ffffffffc0201fca <insert_vma_struct+0x1a>
ffffffffc0201fc0:	a085                	j	ffffffffc0202020 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0201fc2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201fc6:	04e66863          	bltu	a2,a4,ffffffffc0202016 <insert_vma_struct+0x66>
ffffffffc0201fca:	86be                	mv	a3,a5
ffffffffc0201fcc:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0201fce:	fef51ae3          	bne	a0,a5,ffffffffc0201fc2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0201fd2:	02a68463          	beq	a3,a0,ffffffffc0201ffa <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201fd6:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201fda:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201fde:	08e8f163          	bgeu	a7,a4,ffffffffc0202060 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201fe2:	04e66f63          	bltu	a2,a4,ffffffffc0202040 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0201fe6:	00f50a63          	beq	a0,a5,ffffffffc0201ffa <insert_vma_struct+0x4a>
ffffffffc0201fea:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201fee:	05076963          	bltu	a4,a6,ffffffffc0202040 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0201ff2:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201ff6:	02c77363          	bgeu	a4,a2,ffffffffc020201c <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0201ffa:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201ffc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201ffe:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202002:	e390                	sd	a2,0(a5)
ffffffffc0202004:	e690                	sd	a2,8(a3)
}
ffffffffc0202006:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202008:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020200a:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc020200c:	0017079b          	addiw	a5,a4,1
ffffffffc0202010:	d11c                	sw	a5,32(a0)
}
ffffffffc0202012:	0141                	addi	sp,sp,16
ffffffffc0202014:	8082                	ret
    if (le_prev != list) {
ffffffffc0202016:	fca690e3          	bne	a3,a0,ffffffffc0201fd6 <insert_vma_struct+0x26>
ffffffffc020201a:	bfd1                	j	ffffffffc0201fee <insert_vma_struct+0x3e>
ffffffffc020201c:	ebbff0ef          	jal	ra,ffffffffc0201ed6 <check_vma_overlap.isra.0.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202020:	00004697          	auipc	a3,0x4
ffffffffc0202024:	d5868693          	addi	a3,a3,-680 # ffffffffc0205d78 <commands+0xf28>
ffffffffc0202028:	00003617          	auipc	a2,0x3
ffffffffc020202c:	67060613          	addi	a2,a2,1648 # ffffffffc0205698 <commands+0x848>
ffffffffc0202030:	08500593          	li	a1,133
ffffffffc0202034:	00004517          	auipc	a0,0x4
ffffffffc0202038:	d3450513          	addi	a0,a0,-716 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020203c:	98cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202040:	00004697          	auipc	a3,0x4
ffffffffc0202044:	d7868693          	addi	a3,a3,-648 # ffffffffc0205db8 <commands+0xf68>
ffffffffc0202048:	00003617          	auipc	a2,0x3
ffffffffc020204c:	65060613          	addi	a2,a2,1616 # ffffffffc0205698 <commands+0x848>
ffffffffc0202050:	07d00593          	li	a1,125
ffffffffc0202054:	00004517          	auipc	a0,0x4
ffffffffc0202058:	d1450513          	addi	a0,a0,-748 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020205c:	96cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202060:	00004697          	auipc	a3,0x4
ffffffffc0202064:	d3868693          	addi	a3,a3,-712 # ffffffffc0205d98 <commands+0xf48>
ffffffffc0202068:	00003617          	auipc	a2,0x3
ffffffffc020206c:	63060613          	addi	a2,a2,1584 # ffffffffc0205698 <commands+0x848>
ffffffffc0202070:	07c00593          	li	a1,124
ffffffffc0202074:	00004517          	auipc	a0,0x4
ffffffffc0202078:	cf450513          	addi	a0,a0,-780 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020207c:	94cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202080 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0202080:	1141                	addi	sp,sp,-16
ffffffffc0202082:	e022                	sd	s0,0(sp)
ffffffffc0202084:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0202086:	6508                	ld	a0,8(a0)
ffffffffc0202088:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020208a:	00a40c63          	beq	s0,a0,ffffffffc02020a2 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc020208e:	6118                	ld	a4,0(a0)
ffffffffc0202090:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0202092:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0202094:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202096:	e398                	sd	a4,0(a5)
ffffffffc0202098:	0ff000ef          	jal	ra,ffffffffc0202996 <kfree>
    return listelm->next;
ffffffffc020209c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020209e:	fea418e3          	bne	s0,a0,ffffffffc020208e <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc02020a2:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02020a4:	6402                	ld	s0,0(sp)
ffffffffc02020a6:	60a2                	ld	ra,8(sp)
ffffffffc02020a8:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02020aa:	0ed0006f          	j	ffffffffc0202996 <kfree>

ffffffffc02020ae <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02020ae:	7139                	addi	sp,sp,-64
ffffffffc02020b0:	f822                	sd	s0,48(sp)
ffffffffc02020b2:	f426                	sd	s1,40(sp)
ffffffffc02020b4:	fc06                	sd	ra,56(sp)
ffffffffc02020b6:	f04a                	sd	s2,32(sp)
ffffffffc02020b8:	ec4e                	sd	s3,24(sp)
ffffffffc02020ba:	e852                	sd	s4,16(sp)
ffffffffc02020bc:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc02020be:	e3dff0ef          	jal	ra,ffffffffc0201efa <mm_create>
    assert(mm != NULL);
ffffffffc02020c2:	842a                	mv	s0,a0
ffffffffc02020c4:	03200493          	li	s1,50
ffffffffc02020c8:	e919                	bnez	a0,ffffffffc02020de <vmm_init+0x30>
ffffffffc02020ca:	a1a1                	j	ffffffffc0202512 <vmm_init+0x464>
        vma->vm_start = vm_start;
ffffffffc02020cc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02020ce:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02020d0:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02020d4:	14ed                	addi	s1,s1,-5
ffffffffc02020d6:	8522                	mv	a0,s0
ffffffffc02020d8:	ed9ff0ef          	jal	ra,ffffffffc0201fb0 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02020dc:	c88d                	beqz	s1,ffffffffc020210e <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02020de:	03000513          	li	a0,48
ffffffffc02020e2:	005000ef          	jal	ra,ffffffffc02028e6 <kmalloc>
ffffffffc02020e6:	85aa                	mv	a1,a0
ffffffffc02020e8:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02020ec:	f165                	bnez	a0,ffffffffc02020cc <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02020ee:	00004697          	auipc	a3,0x4
ffffffffc02020f2:	f1268693          	addi	a3,a3,-238 # ffffffffc0206000 <commands+0x11b0>
ffffffffc02020f6:	00003617          	auipc	a2,0x3
ffffffffc02020fa:	5a260613          	addi	a2,a2,1442 # ffffffffc0205698 <commands+0x848>
ffffffffc02020fe:	0c900593          	li	a1,201
ffffffffc0202102:	00004517          	auipc	a0,0x4
ffffffffc0202106:	c6650513          	addi	a0,a0,-922 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020210a:	8befe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020210e:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202112:	1f900913          	li	s2,505
ffffffffc0202116:	a819                	j	ffffffffc020212c <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0202118:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020211a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020211c:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202120:	0495                	addi	s1,s1,5
ffffffffc0202122:	8522                	mv	a0,s0
ffffffffc0202124:	e8dff0ef          	jal	ra,ffffffffc0201fb0 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0202128:	03248a63          	beq	s1,s2,ffffffffc020215c <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020212c:	03000513          	li	a0,48
ffffffffc0202130:	7b6000ef          	jal	ra,ffffffffc02028e6 <kmalloc>
ffffffffc0202134:	85aa                	mv	a1,a0
ffffffffc0202136:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc020213a:	fd79                	bnez	a0,ffffffffc0202118 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc020213c:	00004697          	auipc	a3,0x4
ffffffffc0202140:	ec468693          	addi	a3,a3,-316 # ffffffffc0206000 <commands+0x11b0>
ffffffffc0202144:	00003617          	auipc	a2,0x3
ffffffffc0202148:	55460613          	addi	a2,a2,1364 # ffffffffc0205698 <commands+0x848>
ffffffffc020214c:	0cf00593          	li	a1,207
ffffffffc0202150:	00004517          	auipc	a0,0x4
ffffffffc0202154:	c1850513          	addi	a0,a0,-1000 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202158:	870fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc020215c:	6418                	ld	a4,8(s0)
ffffffffc020215e:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0202160:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0202164:	2ce40b63          	beq	s0,a4,ffffffffc020243a <vmm_init+0x38c>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202168:	fe873683          	ld	a3,-24(a4) # 7ffe8 <kern_entry-0xffffffffc0180018>
ffffffffc020216c:	ffe78613          	addi	a2,a5,-2
ffffffffc0202170:	24d61563          	bne	a2,a3,ffffffffc02023ba <vmm_init+0x30c>
ffffffffc0202174:	ff073683          	ld	a3,-16(a4)
ffffffffc0202178:	24f69163          	bne	a3,a5,ffffffffc02023ba <vmm_init+0x30c>
ffffffffc020217c:	0795                	addi	a5,a5,5
ffffffffc020217e:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0202180:	feb792e3          	bne	a5,a1,ffffffffc0202164 <vmm_init+0xb6>
ffffffffc0202184:	4a1d                	li	s4,7
ffffffffc0202186:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0202188:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020218c:	85a6                	mv	a1,s1
ffffffffc020218e:	8522                	mv	a0,s0
ffffffffc0202190:	de1ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
ffffffffc0202194:	89aa                	mv	s3,a0
        assert(vma1 != NULL);
ffffffffc0202196:	30050263          	beqz	a0,ffffffffc020249a <vmm_init+0x3ec>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020219a:	00148593          	addi	a1,s1,1
ffffffffc020219e:	8522                	mv	a0,s0
ffffffffc02021a0:	dd1ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
ffffffffc02021a4:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc02021a6:	2c050a63          	beqz	a0,ffffffffc020247a <vmm_init+0x3cc>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02021aa:	85d2                	mv	a1,s4
ffffffffc02021ac:	8522                	mv	a0,s0
ffffffffc02021ae:	dc3ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
        assert(vma3 == NULL);
ffffffffc02021b2:	2a051463          	bnez	a0,ffffffffc020245a <vmm_init+0x3ac>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02021b6:	00348593          	addi	a1,s1,3
ffffffffc02021ba:	8522                	mv	a0,s0
ffffffffc02021bc:	db5ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
        assert(vma4 == NULL);
ffffffffc02021c0:	30051d63          	bnez	a0,ffffffffc02024da <vmm_init+0x42c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02021c4:	00448593          	addi	a1,s1,4
ffffffffc02021c8:	8522                	mv	a0,s0
ffffffffc02021ca:	da7ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
        assert(vma5 == NULL);
ffffffffc02021ce:	2e051663          	bnez	a0,ffffffffc02024ba <vmm_init+0x40c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02021d2:	0089b783          	ld	a5,8(s3)
ffffffffc02021d6:	20979263          	bne	a5,s1,ffffffffc02023da <vmm_init+0x32c>
ffffffffc02021da:	0109b783          	ld	a5,16(s3)
ffffffffc02021de:	1f479e63          	bne	a5,s4,ffffffffc02023da <vmm_init+0x32c>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02021e2:	00893783          	ld	a5,8(s2)
ffffffffc02021e6:	20979a63          	bne	a5,s1,ffffffffc02023fa <vmm_init+0x34c>
ffffffffc02021ea:	01093783          	ld	a5,16(s2)
ffffffffc02021ee:	21479663          	bne	a5,s4,ffffffffc02023fa <vmm_init+0x34c>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02021f2:	0495                	addi	s1,s1,5
ffffffffc02021f4:	0a15                	addi	s4,s4,5
ffffffffc02021f6:	f9549be3          	bne	s1,s5,ffffffffc020218c <vmm_init+0xde>
ffffffffc02021fa:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02021fc:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02021fe:	85a6                	mv	a1,s1
ffffffffc0202200:	8522                	mv	a0,s0
ffffffffc0202202:	d6fff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
ffffffffc0202206:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc020220a:	c90d                	beqz	a0,ffffffffc020223c <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc020220c:	6914                	ld	a3,16(a0)
ffffffffc020220e:	6510                	ld	a2,8(a0)
ffffffffc0202210:	00004517          	auipc	a0,0x4
ffffffffc0202214:	cd850513          	addi	a0,a0,-808 # ffffffffc0205ee8 <commands+0x1098>
ffffffffc0202218:	eb5fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc020221c:	00004697          	auipc	a3,0x4
ffffffffc0202220:	cf468693          	addi	a3,a3,-780 # ffffffffc0205f10 <commands+0x10c0>
ffffffffc0202224:	00003617          	auipc	a2,0x3
ffffffffc0202228:	47460613          	addi	a2,a2,1140 # ffffffffc0205698 <commands+0x848>
ffffffffc020222c:	0f100593          	li	a1,241
ffffffffc0202230:	00004517          	auipc	a0,0x4
ffffffffc0202234:	b3850513          	addi	a0,a0,-1224 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202238:	f91fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc020223c:	14fd                	addi	s1,s1,-1
ffffffffc020223e:	fd2490e3          	bne	s1,s2,ffffffffc02021fe <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0202242:	8522                	mv	a0,s0
ffffffffc0202244:	e3dff0ef          	jal	ra,ffffffffc0202080 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202248:	00004517          	auipc	a0,0x4
ffffffffc020224c:	ce050513          	addi	a0,a0,-800 # ffffffffc0205f28 <commands+0x10d8>
ffffffffc0202250:	e7dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0202254:	a0bfe0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc0202258:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020225a:	ca1ff0ef          	jal	ra,ffffffffc0201efa <mm_create>
ffffffffc020225e:	00013797          	auipc	a5,0x13
ffffffffc0202262:	2aa7b523          	sd	a0,682(a5) # ffffffffc0215508 <check_mm_struct>
ffffffffc0202266:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0202268:	36050163          	beqz	a0,ffffffffc02025ca <vmm_init+0x51c>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020226c:	00013917          	auipc	s2,0x13
ffffffffc0202270:	21493903          	ld	s2,532(s2) # ffffffffc0215480 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0202274:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202278:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020227c:	2c079b63          	bnez	a5,ffffffffc0202552 <vmm_init+0x4a4>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202280:	03000513          	li	a0,48
ffffffffc0202284:	662000ef          	jal	ra,ffffffffc02028e6 <kmalloc>
ffffffffc0202288:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc020228a:	18050863          	beqz	a0,ffffffffc020241a <vmm_init+0x36c>
        vma->vm_end = vm_end;
ffffffffc020228e:	002007b7          	lui	a5,0x200
ffffffffc0202292:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0202294:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0202296:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0202298:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc020229a:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc020229c:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02022a0:	d11ff0ef          	jal	ra,ffffffffc0201fb0 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02022a4:	10000593          	li	a1,256
ffffffffc02022a8:	8526                	mv	a0,s1
ffffffffc02022aa:	cc7ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>
ffffffffc02022ae:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02022b2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02022b6:	2aa41e63          	bne	s0,a0,ffffffffc0202572 <vmm_init+0x4c4>
        *(char *)(addr + i) = i;
ffffffffc02022ba:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc02022be:	0785                	addi	a5,a5,1
ffffffffc02022c0:	fee79de3          	bne	a5,a4,ffffffffc02022ba <vmm_init+0x20c>
        sum += i;
ffffffffc02022c4:	6705                	lui	a4,0x1
ffffffffc02022c6:	10000793          	li	a5,256
ffffffffc02022ca:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02022ce:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02022d2:	0007c683          	lbu	a3,0(a5)
ffffffffc02022d6:	0785                	addi	a5,a5,1
ffffffffc02022d8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02022da:	fec79ce3          	bne	a5,a2,ffffffffc02022d2 <vmm_init+0x224>
    }
    assert(sum == 0);
ffffffffc02022de:	2c071663          	bnez	a4,ffffffffc02025aa <vmm_init+0x4fc>
    return pa2page(PDE_ADDR(pde));
ffffffffc02022e2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02022e6:	00013a97          	auipc	s5,0x13
ffffffffc02022ea:	1a2a8a93          	addi	s5,s5,418 # ffffffffc0215488 <npage>
ffffffffc02022ee:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022f2:	078a                	slli	a5,a5,0x2
ffffffffc02022f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022f6:	20e7f263          	bgeu	a5,a4,ffffffffc02024fa <vmm_init+0x44c>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fa:	00005a17          	auipc	s4,0x5
ffffffffc02022fe:	9aea3a03          	ld	s4,-1618(s4) # ffffffffc0206ca8 <nbase>
ffffffffc0202302:	414786b3          	sub	a3,a5,s4
ffffffffc0202306:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202308:	8699                	srai	a3,a3,0x6
ffffffffc020230a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020230c:	00c69793          	slli	a5,a3,0xc
ffffffffc0202310:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202312:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202314:	26e7ff63          	bgeu	a5,a4,ffffffffc0202592 <vmm_init+0x4e4>
ffffffffc0202318:	00013417          	auipc	s0,0x13
ffffffffc020231c:	1c843403          	ld	s0,456(s0) # ffffffffc02154e0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0202320:	4581                	li	a1,0
ffffffffc0202322:	854a                	mv	a0,s2
ffffffffc0202324:	9436                	add	s0,s0,a3
ffffffffc0202326:	b9bfe0ef          	jal	ra,ffffffffc0200ec0 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020232a:	6018                	ld	a4,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020232c:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202330:	070a                	slli	a4,a4,0x2
ffffffffc0202332:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202334:	1cf77363          	bgeu	a4,a5,ffffffffc02024fa <vmm_init+0x44c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202338:	00013417          	auipc	s0,0x13
ffffffffc020233c:	1b840413          	addi	s0,s0,440 # ffffffffc02154f0 <pages>
ffffffffc0202340:	6008                	ld	a0,0(s0)
ffffffffc0202342:	41470733          	sub	a4,a4,s4
ffffffffc0202346:	071a                	slli	a4,a4,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202348:	953a                	add	a0,a0,a4
ffffffffc020234a:	4585                	li	a1,1
ffffffffc020234c:	8d1fe0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202350:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202354:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202358:	078a                	slli	a5,a5,0x2
ffffffffc020235a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020235c:	18e7ff63          	bgeu	a5,a4,ffffffffc02024fa <vmm_init+0x44c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202360:	6008                	ld	a0,0(s0)
ffffffffc0202362:	414787b3          	sub	a5,a5,s4
ffffffffc0202366:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202368:	4585                	li	a1,1
ffffffffc020236a:	953e                	add	a0,a0,a5
ffffffffc020236c:	8b1fe0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    pgdir[0] = 0;
ffffffffc0202370:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0202374:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0202378:	8526                	mv	a0,s1
    mm->pgdir = NULL;
ffffffffc020237a:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020237e:	d03ff0ef          	jal	ra,ffffffffc0202080 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0202382:	00013797          	auipc	a5,0x13
ffffffffc0202386:	1807b323          	sd	zero,390(a5) # ffffffffc0215508 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020238a:	8d5fe0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc020238e:	1aa99263          	bne	s3,a0,ffffffffc0202532 <vmm_init+0x484>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0202392:	00004517          	auipc	a0,0x4
ffffffffc0202396:	c3650513          	addi	a0,a0,-970 # ffffffffc0205fc8 <commands+0x1178>
ffffffffc020239a:	d33fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020239e:	7442                	ld	s0,48(sp)
ffffffffc02023a0:	70e2                	ld	ra,56(sp)
ffffffffc02023a2:	74a2                	ld	s1,40(sp)
ffffffffc02023a4:	7902                	ld	s2,32(sp)
ffffffffc02023a6:	69e2                	ld	s3,24(sp)
ffffffffc02023a8:	6a42                	ld	s4,16(sp)
ffffffffc02023aa:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02023ac:	00004517          	auipc	a0,0x4
ffffffffc02023b0:	c3c50513          	addi	a0,a0,-964 # ffffffffc0205fe8 <commands+0x1198>
}
ffffffffc02023b4:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02023b6:	d17fd06f          	j	ffffffffc02000cc <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02023ba:	00004697          	auipc	a3,0x4
ffffffffc02023be:	a4668693          	addi	a3,a3,-1466 # ffffffffc0205e00 <commands+0xfb0>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	2d660613          	addi	a2,a2,726 # ffffffffc0205698 <commands+0x848>
ffffffffc02023ca:	0d800593          	li	a1,216
ffffffffc02023ce:	00004517          	auipc	a0,0x4
ffffffffc02023d2:	99a50513          	addi	a0,a0,-1638 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02023d6:	df3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02023da:	00004697          	auipc	a3,0x4
ffffffffc02023de:	aae68693          	addi	a3,a3,-1362 # ffffffffc0205e88 <commands+0x1038>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	2b660613          	addi	a2,a2,694 # ffffffffc0205698 <commands+0x848>
ffffffffc02023ea:	0e800593          	li	a1,232
ffffffffc02023ee:	00004517          	auipc	a0,0x4
ffffffffc02023f2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02023f6:	dd3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02023fa:	00004697          	auipc	a3,0x4
ffffffffc02023fe:	abe68693          	addi	a3,a3,-1346 # ffffffffc0205eb8 <commands+0x1068>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	29660613          	addi	a2,a2,662 # ffffffffc0205698 <commands+0x848>
ffffffffc020240a:	0e900593          	li	a1,233
ffffffffc020240e:	00004517          	auipc	a0,0x4
ffffffffc0202412:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202416:	db3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc020241a:	00004697          	auipc	a3,0x4
ffffffffc020241e:	be668693          	addi	a3,a3,-1050 # ffffffffc0206000 <commands+0x11b0>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	27660613          	addi	a2,a2,630 # ffffffffc0205698 <commands+0x848>
ffffffffc020242a:	10800593          	li	a1,264
ffffffffc020242e:	00004517          	auipc	a0,0x4
ffffffffc0202432:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202436:	d93fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020243a:	00004697          	auipc	a3,0x4
ffffffffc020243e:	9ae68693          	addi	a3,a3,-1618 # ffffffffc0205de8 <commands+0xf98>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	25660613          	addi	a2,a2,598 # ffffffffc0205698 <commands+0x848>
ffffffffc020244a:	0d600593          	li	a1,214
ffffffffc020244e:	00004517          	auipc	a0,0x4
ffffffffc0202452:	91a50513          	addi	a0,a0,-1766 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202456:	d73fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc020245a:	00004697          	auipc	a3,0x4
ffffffffc020245e:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0205e58 <commands+0x1008>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	23660613          	addi	a2,a2,566 # ffffffffc0205698 <commands+0x848>
ffffffffc020246a:	0e200593          	li	a1,226
ffffffffc020246e:	00004517          	auipc	a0,0x4
ffffffffc0202472:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202476:	d53fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc020247a:	00004697          	auipc	a3,0x4
ffffffffc020247e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0205e48 <commands+0xff8>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	21660613          	addi	a2,a2,534 # ffffffffc0205698 <commands+0x848>
ffffffffc020248a:	0e000593          	li	a1,224
ffffffffc020248e:	00004517          	auipc	a0,0x4
ffffffffc0202492:	8da50513          	addi	a0,a0,-1830 # ffffffffc0205d68 <commands+0xf18>
ffffffffc0202496:	d33fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc020249a:	00004697          	auipc	a3,0x4
ffffffffc020249e:	99e68693          	addi	a3,a3,-1634 # ffffffffc0205e38 <commands+0xfe8>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	1f660613          	addi	a2,a2,502 # ffffffffc0205698 <commands+0x848>
ffffffffc02024aa:	0de00593          	li	a1,222
ffffffffc02024ae:	00004517          	auipc	a0,0x4
ffffffffc02024b2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02024b6:	d13fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc02024ba:	00004697          	auipc	a3,0x4
ffffffffc02024be:	9be68693          	addi	a3,a3,-1602 # ffffffffc0205e78 <commands+0x1028>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	1d660613          	addi	a2,a2,470 # ffffffffc0205698 <commands+0x848>
ffffffffc02024ca:	0e600593          	li	a1,230
ffffffffc02024ce:	00004517          	auipc	a0,0x4
ffffffffc02024d2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02024d6:	cf3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc02024da:	00004697          	auipc	a3,0x4
ffffffffc02024de:	98e68693          	addi	a3,a3,-1650 # ffffffffc0205e68 <commands+0x1018>
ffffffffc02024e2:	00003617          	auipc	a2,0x3
ffffffffc02024e6:	1b660613          	addi	a2,a2,438 # ffffffffc0205698 <commands+0x848>
ffffffffc02024ea:	0e400593          	li	a1,228
ffffffffc02024ee:	00004517          	auipc	a0,0x4
ffffffffc02024f2:	87a50513          	addi	a0,a0,-1926 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02024f6:	cd3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024fa:	00003617          	auipc	a2,0x3
ffffffffc02024fe:	05e60613          	addi	a2,a2,94 # ffffffffc0205558 <commands+0x708>
ffffffffc0202502:	06200593          	li	a1,98
ffffffffc0202506:	00003517          	auipc	a0,0x3
ffffffffc020250a:	07250513          	addi	a0,a0,114 # ffffffffc0205578 <commands+0x728>
ffffffffc020250e:	cbbfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc0202512:	00004697          	auipc	a3,0x4
ffffffffc0202516:	8c668693          	addi	a3,a3,-1850 # ffffffffc0205dd8 <commands+0xf88>
ffffffffc020251a:	00003617          	auipc	a2,0x3
ffffffffc020251e:	17e60613          	addi	a2,a2,382 # ffffffffc0205698 <commands+0x848>
ffffffffc0202522:	0c200593          	li	a1,194
ffffffffc0202526:	00004517          	auipc	a0,0x4
ffffffffc020252a:	84250513          	addi	a0,a0,-1982 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020252e:	c9bfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0202532:	00004697          	auipc	a3,0x4
ffffffffc0202536:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0205fa0 <commands+0x1150>
ffffffffc020253a:	00003617          	auipc	a2,0x3
ffffffffc020253e:	15e60613          	addi	a2,a2,350 # ffffffffc0205698 <commands+0x848>
ffffffffc0202542:	12400593          	li	a1,292
ffffffffc0202546:	00004517          	auipc	a0,0x4
ffffffffc020254a:	82250513          	addi	a0,a0,-2014 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020254e:	c7bfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0202552:	00004697          	auipc	a3,0x4
ffffffffc0202556:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0205f60 <commands+0x1110>
ffffffffc020255a:	00003617          	auipc	a2,0x3
ffffffffc020255e:	13e60613          	addi	a2,a2,318 # ffffffffc0205698 <commands+0x848>
ffffffffc0202562:	10500593          	li	a1,261
ffffffffc0202566:	00004517          	auipc	a0,0x4
ffffffffc020256a:	80250513          	addi	a0,a0,-2046 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020256e:	c5bfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0202572:	00004697          	auipc	a3,0x4
ffffffffc0202576:	9fe68693          	addi	a3,a3,-1538 # ffffffffc0205f70 <commands+0x1120>
ffffffffc020257a:	00003617          	auipc	a2,0x3
ffffffffc020257e:	11e60613          	addi	a2,a2,286 # ffffffffc0205698 <commands+0x848>
ffffffffc0202582:	10d00593          	li	a1,269
ffffffffc0202586:	00003517          	auipc	a0,0x3
ffffffffc020258a:	7e250513          	addi	a0,a0,2018 # ffffffffc0205d68 <commands+0xf18>
ffffffffc020258e:	c3bfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202592:	00003617          	auipc	a2,0x3
ffffffffc0202596:	ff660613          	addi	a2,a2,-10 # ffffffffc0205588 <commands+0x738>
ffffffffc020259a:	06900593          	li	a1,105
ffffffffc020259e:	00003517          	auipc	a0,0x3
ffffffffc02025a2:	fda50513          	addi	a0,a0,-38 # ffffffffc0205578 <commands+0x728>
ffffffffc02025a6:	c23fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc02025aa:	00004697          	auipc	a3,0x4
ffffffffc02025ae:	9e668693          	addi	a3,a3,-1562 # ffffffffc0205f90 <commands+0x1140>
ffffffffc02025b2:	00003617          	auipc	a2,0x3
ffffffffc02025b6:	0e660613          	addi	a2,a2,230 # ffffffffc0205698 <commands+0x848>
ffffffffc02025ba:	11700593          	li	a1,279
ffffffffc02025be:	00003517          	auipc	a0,0x3
ffffffffc02025c2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02025c6:	c03fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02025ca:	00004697          	auipc	a3,0x4
ffffffffc02025ce:	97e68693          	addi	a3,a3,-1666 # ffffffffc0205f48 <commands+0x10f8>
ffffffffc02025d2:	00003617          	auipc	a2,0x3
ffffffffc02025d6:	0c660613          	addi	a2,a2,198 # ffffffffc0205698 <commands+0x848>
ffffffffc02025da:	10100593          	li	a1,257
ffffffffc02025de:	00003517          	auipc	a0,0x3
ffffffffc02025e2:	78a50513          	addi	a0,a0,1930 # ffffffffc0205d68 <commands+0xf18>
ffffffffc02025e6:	be3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02025ea <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02025ea:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02025ec:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02025ee:	f022                	sd	s0,32(sp)
ffffffffc02025f0:	ec26                	sd	s1,24(sp)
ffffffffc02025f2:	f406                	sd	ra,40(sp)
ffffffffc02025f4:	e84a                	sd	s2,16(sp)
ffffffffc02025f6:	8432                	mv	s0,a2
ffffffffc02025f8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02025fa:	977ff0ef          	jal	ra,ffffffffc0201f70 <find_vma>

    pgfault_num++;
ffffffffc02025fe:	00013797          	auipc	a5,0x13
ffffffffc0202602:	e927a783          	lw	a5,-366(a5) # ffffffffc0215490 <pgfault_num>
ffffffffc0202606:	2785                	addiw	a5,a5,1
ffffffffc0202608:	00013717          	auipc	a4,0x13
ffffffffc020260c:	e8f72423          	sw	a5,-376(a4) # ffffffffc0215490 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0202610:	c541                	beqz	a0,ffffffffc0202698 <do_pgfault+0xae>
ffffffffc0202612:	651c                	ld	a5,8(a0)
ffffffffc0202614:	08f46263          	bltu	s0,a5,ffffffffc0202698 <do_pgfault+0xae>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0202618:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020261a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020261c:	8b89                	andi	a5,a5,2
ffffffffc020261e:	ebb9                	bnez	a5,ffffffffc0202674 <do_pgfault+0x8a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202620:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202622:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0202624:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0202626:	4605                	li	a2,1
ffffffffc0202628:	85a2                	mv	a1,s0
ffffffffc020262a:	e70fe0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020262e:	c551                	beqz	a0,ffffffffc02026ba <do_pgfault+0xd0>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0202630:	610c                	ld	a1,0(a0)
ffffffffc0202632:	c1b9                	beqz	a1,ffffffffc0202678 <do_pgfault+0x8e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0202634:	00013797          	auipc	a5,0x13
ffffffffc0202638:	e747a783          	lw	a5,-396(a5) # ffffffffc02154a8 <swap_init_ok>
ffffffffc020263c:	c7bd                	beqz	a5,ffffffffc02026aa <do_pgfault+0xc0>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page);
ffffffffc020263e:	85a2                	mv	a1,s0
ffffffffc0202640:	0030                	addi	a2,sp,8
ffffffffc0202642:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0202644:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0202646:	4b1000ef          	jal	ra,ffffffffc02032f6 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc020264a:	65a2                	ld	a1,8(sp)
ffffffffc020264c:	6c88                	ld	a0,24(s1)
ffffffffc020264e:	86ca                	mv	a3,s2
ffffffffc0202650:	8622                	mv	a2,s0
ffffffffc0202652:	8dffe0ef          	jal	ra,ffffffffc0200f30 <page_insert>
            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0202656:	6622                	ld	a2,8(sp)
ffffffffc0202658:	4685                	li	a3,1
ffffffffc020265a:	85a2                	mv	a1,s0
ffffffffc020265c:	8526                	mv	a0,s1
ffffffffc020265e:	377000ef          	jal	ra,ffffffffc02031d4 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0202662:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0202664:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0202666:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0202668:	70a2                	ld	ra,40(sp)
ffffffffc020266a:	7402                	ld	s0,32(sp)
ffffffffc020266c:	64e2                	ld	s1,24(sp)
ffffffffc020266e:	6942                	ld	s2,16(sp)
ffffffffc0202670:	6145                	addi	sp,sp,48
ffffffffc0202672:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0202674:	495d                	li	s2,23
ffffffffc0202676:	b76d                	j	ffffffffc0202620 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202678:	6c88                	ld	a0,24(s1)
ffffffffc020267a:	864a                	mv	a2,s2
ffffffffc020267c:	85a2                	mv	a1,s0
ffffffffc020267e:	bceff0ef          	jal	ra,ffffffffc0201a4c <pgdir_alloc_page>
ffffffffc0202682:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0202684:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0202686:	f3ed                	bnez	a5,ffffffffc0202668 <do_pgfault+0x7e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0202688:	00004517          	auipc	a0,0x4
ffffffffc020268c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0206060 <commands+0x1210>
ffffffffc0202690:	a3dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0202694:	5571                	li	a0,-4
            goto failed;
ffffffffc0202696:	bfc9                	j	ffffffffc0202668 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0202698:	85a2                	mv	a1,s0
ffffffffc020269a:	00004517          	auipc	a0,0x4
ffffffffc020269e:	97650513          	addi	a0,a0,-1674 # ffffffffc0206010 <commands+0x11c0>
ffffffffc02026a2:	a2bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc02026a6:	5575                	li	a0,-3
        goto failed;
ffffffffc02026a8:	b7c1                	j	ffffffffc0202668 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc02026aa:	00004517          	auipc	a0,0x4
ffffffffc02026ae:	9de50513          	addi	a0,a0,-1570 # ffffffffc0206088 <commands+0x1238>
ffffffffc02026b2:	a1bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02026b6:	5571                	li	a0,-4
            goto failed;
ffffffffc02026b8:	bf45                	j	ffffffffc0202668 <do_pgfault+0x7e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc02026ba:	00004517          	auipc	a0,0x4
ffffffffc02026be:	98650513          	addi	a0,a0,-1658 # ffffffffc0206040 <commands+0x11f0>
ffffffffc02026c2:	a0bfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02026c6:	5571                	li	a0,-4
        goto failed;
ffffffffc02026c8:	b745                	j	ffffffffc0202668 <do_pgfault+0x7e>

ffffffffc02026ca <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02026ca:	c145                	beqz	a0,ffffffffc020276a <slob_free+0xa0>
{
ffffffffc02026cc:	1141                	addi	sp,sp,-16
ffffffffc02026ce:	e022                	sd	s0,0(sp)
ffffffffc02026d0:	e406                	sd	ra,8(sp)
ffffffffc02026d2:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02026d4:	edb1                	bnez	a1,ffffffffc0202730 <slob_free+0x66>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026d6:	100027f3          	csrr	a5,sstatus
ffffffffc02026da:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02026dc:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026de:	e3ad                	bnez	a5,ffffffffc0202740 <slob_free+0x76>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02026e0:	00008617          	auipc	a2,0x8
ffffffffc02026e4:	97060613          	addi	a2,a2,-1680 # ffffffffc020a050 <slobfree>
ffffffffc02026e8:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02026ea:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02026ec:	0087fa63          	bgeu	a5,s0,ffffffffc0202700 <slob_free+0x36>
ffffffffc02026f0:	00e46c63          	bltu	s0,a4,ffffffffc0202708 <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02026f4:	00e7fa63          	bgeu	a5,a4,ffffffffc0202708 <slob_free+0x3e>
    return 0;
ffffffffc02026f8:	87ba                	mv	a5,a4
ffffffffc02026fa:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02026fc:	fe87eae3          	bltu	a5,s0,ffffffffc02026f0 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0202700:	fee7ece3          	bltu	a5,a4,ffffffffc02026f8 <slob_free+0x2e>
ffffffffc0202704:	fee47ae3          	bgeu	s0,a4,ffffffffc02026f8 <slob_free+0x2e>
			break;

	if (b + b->units == cur->next) {
ffffffffc0202708:	400c                	lw	a1,0(s0)
ffffffffc020270a:	00459693          	slli	a3,a1,0x4
ffffffffc020270e:	96a2                	add	a3,a3,s0
ffffffffc0202710:	04d70763          	beq	a4,a3,ffffffffc020275e <slob_free+0x94>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;
ffffffffc0202714:	e418                	sd	a4,8(s0)

	if (cur + cur->units == b) {
ffffffffc0202716:	4394                	lw	a3,0(a5)
ffffffffc0202718:	00469713          	slli	a4,a3,0x4
ffffffffc020271c:	973e                	add	a4,a4,a5
ffffffffc020271e:	02e40a63          	beq	s0,a4,ffffffffc0202752 <slob_free+0x88>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0202722:	e780                	sd	s0,8(a5)

	slobfree = cur;
ffffffffc0202724:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc0202726:	e10d                	bnez	a0,ffffffffc0202748 <slob_free+0x7e>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0202728:	60a2                	ld	ra,8(sp)
ffffffffc020272a:	6402                	ld	s0,0(sp)
ffffffffc020272c:	0141                	addi	sp,sp,16
ffffffffc020272e:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0202730:	05bd                	addi	a1,a1,15
ffffffffc0202732:	8191                	srli	a1,a1,0x4
ffffffffc0202734:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202736:	100027f3          	csrr	a5,sstatus
ffffffffc020273a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020273c:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020273e:	d3cd                	beqz	a5,ffffffffc02026e0 <slob_free+0x16>
        intr_disable();
ffffffffc0202740:	e7ffd0ef          	jal	ra,ffffffffc02005be <intr_disable>
        return 1;
ffffffffc0202744:	4505                	li	a0,1
ffffffffc0202746:	bf69                	j	ffffffffc02026e0 <slob_free+0x16>
}
ffffffffc0202748:	6402                	ld	s0,0(sp)
ffffffffc020274a:	60a2                	ld	ra,8(sp)
ffffffffc020274c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020274e:	e6bfd06f          	j	ffffffffc02005b8 <intr_enable>
		cur->units += b->units;
ffffffffc0202752:	4018                	lw	a4,0(s0)
		cur->next = b->next;
ffffffffc0202754:	640c                	ld	a1,8(s0)
		cur->units += b->units;
ffffffffc0202756:	9eb9                	addw	a3,a3,a4
ffffffffc0202758:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc020275a:	e78c                	sd	a1,8(a5)
ffffffffc020275c:	b7e1                	j	ffffffffc0202724 <slob_free+0x5a>
		b->units += cur->next->units;
ffffffffc020275e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0202760:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0202762:	9db5                	addw	a1,a1,a3
ffffffffc0202764:	c00c                	sw	a1,0(s0)
		b->next = cur->next->next;
ffffffffc0202766:	e418                	sd	a4,8(s0)
ffffffffc0202768:	b77d                	j	ffffffffc0202716 <slob_free+0x4c>
ffffffffc020276a:	8082                	ret

ffffffffc020276c <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020276c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020276e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202770:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202774:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202776:	c14fe0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
  if(!page)
ffffffffc020277a:	c91d                	beqz	a0,ffffffffc02027b0 <__slob_get_free_pages.isra.0+0x44>
    return page - pages + nbase;
ffffffffc020277c:	00013697          	auipc	a3,0x13
ffffffffc0202780:	d746b683          	ld	a3,-652(a3) # ffffffffc02154f0 <pages>
ffffffffc0202784:	8d15                	sub	a0,a0,a3
ffffffffc0202786:	8519                	srai	a0,a0,0x6
ffffffffc0202788:	00004697          	auipc	a3,0x4
ffffffffc020278c:	5206b683          	ld	a3,1312(a3) # ffffffffc0206ca8 <nbase>
ffffffffc0202790:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0202792:	00c51793          	slli	a5,a0,0xc
ffffffffc0202796:	83b1                	srli	a5,a5,0xc
ffffffffc0202798:	00013717          	auipc	a4,0x13
ffffffffc020279c:	cf073703          	ld	a4,-784(a4) # ffffffffc0215488 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02027a0:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02027a2:	00e7fa63          	bgeu	a5,a4,ffffffffc02027b6 <__slob_get_free_pages.isra.0+0x4a>
ffffffffc02027a6:	00013697          	auipc	a3,0x13
ffffffffc02027aa:	d3a6b683          	ld	a3,-710(a3) # ffffffffc02154e0 <va_pa_offset>
ffffffffc02027ae:	9536                	add	a0,a0,a3
}
ffffffffc02027b0:	60a2                	ld	ra,8(sp)
ffffffffc02027b2:	0141                	addi	sp,sp,16
ffffffffc02027b4:	8082                	ret
ffffffffc02027b6:	86aa                	mv	a3,a0
ffffffffc02027b8:	00003617          	auipc	a2,0x3
ffffffffc02027bc:	dd060613          	addi	a2,a2,-560 # ffffffffc0205588 <commands+0x738>
ffffffffc02027c0:	06900593          	li	a1,105
ffffffffc02027c4:	00003517          	auipc	a0,0x3
ffffffffc02027c8:	db450513          	addi	a0,a0,-588 # ffffffffc0205578 <commands+0x728>
ffffffffc02027cc:	9fdfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02027d0 <slob_alloc.isra.0.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02027d0:	1101                	addi	sp,sp,-32
ffffffffc02027d2:	ec06                	sd	ra,24(sp)
ffffffffc02027d4:	e822                	sd	s0,16(sp)
ffffffffc02027d6:	e426                	sd	s1,8(sp)
ffffffffc02027d8:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02027da:	01050713          	addi	a4,a0,16
ffffffffc02027de:	6785                	lui	a5,0x1
ffffffffc02027e0:	0cf77363          	bgeu	a4,a5,ffffffffc02028a6 <slob_alloc.isra.0.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02027e4:	00f50493          	addi	s1,a0,15
ffffffffc02027e8:	8091                	srli	s1,s1,0x4
ffffffffc02027ea:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02027ec:	10002673          	csrr	a2,sstatus
ffffffffc02027f0:	8a09                	andi	a2,a2,2
ffffffffc02027f2:	e25d                	bnez	a2,ffffffffc0202898 <slob_alloc.isra.0.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02027f4:	00008917          	auipc	s2,0x8
ffffffffc02027f8:	85c90913          	addi	s2,s2,-1956 # ffffffffc020a050 <slobfree>
ffffffffc02027fc:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0202800:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0202802:	4398                	lw	a4,0(a5)
ffffffffc0202804:	08975e63          	bge	a4,s1,ffffffffc02028a0 <slob_alloc.isra.0.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0202808:	00d78b63          	beq	a5,a3,ffffffffc020281e <slob_alloc.isra.0.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020280c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020280e:	4018                	lw	a4,0(s0)
ffffffffc0202810:	02975a63          	bge	a4,s1,ffffffffc0202844 <slob_alloc.isra.0.constprop.0+0x74>
ffffffffc0202814:	00093683          	ld	a3,0(s2)
ffffffffc0202818:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc020281a:	fed799e3          	bne	a5,a3,ffffffffc020280c <slob_alloc.isra.0.constprop.0+0x3c>
    if (flag) {
ffffffffc020281e:	ee31                	bnez	a2,ffffffffc020287a <slob_alloc.isra.0.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202820:	4501                	li	a0,0
ffffffffc0202822:	f4bff0ef          	jal	ra,ffffffffc020276c <__slob_get_free_pages.isra.0>
ffffffffc0202826:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0202828:	cd05                	beqz	a0,ffffffffc0202860 <slob_alloc.isra.0.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc020282a:	6585                	lui	a1,0x1
ffffffffc020282c:	e9fff0ef          	jal	ra,ffffffffc02026ca <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202830:	10002673          	csrr	a2,sstatus
ffffffffc0202834:	8a09                	andi	a2,a2,2
ffffffffc0202836:	ee05                	bnez	a2,ffffffffc020286e <slob_alloc.isra.0.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0202838:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020283c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020283e:	4018                	lw	a4,0(s0)
ffffffffc0202840:	fc974ae3          	blt	a4,s1,ffffffffc0202814 <slob_alloc.isra.0.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0202844:	04e48763          	beq	s1,a4,ffffffffc0202892 <slob_alloc.isra.0.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0202848:	00449693          	slli	a3,s1,0x4
ffffffffc020284c:	96a2                	add	a3,a3,s0
ffffffffc020284e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0202850:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0202852:	9f05                	subw	a4,a4,s1
ffffffffc0202854:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0202856:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0202858:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc020285a:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc020285e:	e20d                	bnez	a2,ffffffffc0202880 <slob_alloc.isra.0.constprop.0+0xb0>
}
ffffffffc0202860:	60e2                	ld	ra,24(sp)
ffffffffc0202862:	8522                	mv	a0,s0
ffffffffc0202864:	6442                	ld	s0,16(sp)
ffffffffc0202866:	64a2                	ld	s1,8(sp)
ffffffffc0202868:	6902                	ld	s2,0(sp)
ffffffffc020286a:	6105                	addi	sp,sp,32
ffffffffc020286c:	8082                	ret
        intr_disable();
ffffffffc020286e:	d51fd0ef          	jal	ra,ffffffffc02005be <intr_disable>
			cur = slobfree;
ffffffffc0202872:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0202876:	4605                	li	a2,1
ffffffffc0202878:	b7d1                	j	ffffffffc020283c <slob_alloc.isra.0.constprop.0+0x6c>
        intr_enable();
ffffffffc020287a:	d3ffd0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
ffffffffc020287e:	b74d                	j	ffffffffc0202820 <slob_alloc.isra.0.constprop.0+0x50>
ffffffffc0202880:	d39fd0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
}
ffffffffc0202884:	60e2                	ld	ra,24(sp)
ffffffffc0202886:	8522                	mv	a0,s0
ffffffffc0202888:	6442                	ld	s0,16(sp)
ffffffffc020288a:	64a2                	ld	s1,8(sp)
ffffffffc020288c:	6902                	ld	s2,0(sp)
ffffffffc020288e:	6105                	addi	sp,sp,32
ffffffffc0202890:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202892:	6418                	ld	a4,8(s0)
ffffffffc0202894:	e798                	sd	a4,8(a5)
ffffffffc0202896:	b7d1                	j	ffffffffc020285a <slob_alloc.isra.0.constprop.0+0x8a>
        intr_disable();
ffffffffc0202898:	d27fd0ef          	jal	ra,ffffffffc02005be <intr_disable>
        return 1;
ffffffffc020289c:	4605                	li	a2,1
ffffffffc020289e:	bf99                	j	ffffffffc02027f4 <slob_alloc.isra.0.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02028a0:	843e                	mv	s0,a5
ffffffffc02028a2:	87b6                	mv	a5,a3
ffffffffc02028a4:	b745                	j	ffffffffc0202844 <slob_alloc.isra.0.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02028a6:	00004697          	auipc	a3,0x4
ffffffffc02028aa:	80a68693          	addi	a3,a3,-2038 # ffffffffc02060b0 <commands+0x1260>
ffffffffc02028ae:	00003617          	auipc	a2,0x3
ffffffffc02028b2:	dea60613          	addi	a2,a2,-534 # ffffffffc0205698 <commands+0x848>
ffffffffc02028b6:	06300593          	li	a1,99
ffffffffc02028ba:	00004517          	auipc	a0,0x4
ffffffffc02028be:	81650513          	addi	a0,a0,-2026 # ffffffffc02060d0 <commands+0x1280>
ffffffffc02028c2:	907fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02028c6 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc02028c6:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc02028c8:	00004517          	auipc	a0,0x4
ffffffffc02028cc:	82050513          	addi	a0,a0,-2016 # ffffffffc02060e8 <commands+0x1298>
kmalloc_init(void) {
ffffffffc02028d0:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc02028d2:	ffafd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02028d6:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02028d8:	00004517          	auipc	a0,0x4
ffffffffc02028dc:	82850513          	addi	a0,a0,-2008 # ffffffffc0206100 <commands+0x12b0>
}
ffffffffc02028e0:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02028e2:	feafd06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02028e6 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02028e6:	1101                	addi	sp,sp,-32
ffffffffc02028e8:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02028ea:	6905                	lui	s2,0x1
{
ffffffffc02028ec:	e822                	sd	s0,16(sp)
ffffffffc02028ee:	ec06                	sd	ra,24(sp)
ffffffffc02028f0:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02028f2:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc02028f6:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02028f8:	04a7f963          	bgeu	a5,a0,ffffffffc020294a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02028fc:	4561                	li	a0,24
ffffffffc02028fe:	ed3ff0ef          	jal	ra,ffffffffc02027d0 <slob_alloc.isra.0.constprop.0>
ffffffffc0202902:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0202904:	c929                	beqz	a0,ffffffffc0202956 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0202906:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020290a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020290c:	00f95763          	bge	s2,a5,ffffffffc020291a <kmalloc+0x34>
ffffffffc0202910:	6705                	lui	a4,0x1
ffffffffc0202912:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0202914:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0202916:	fef74ee3          	blt	a4,a5,ffffffffc0202912 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc020291a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc020291c:	e51ff0ef          	jal	ra,ffffffffc020276c <__slob_get_free_pages.isra.0>
ffffffffc0202920:	e488                	sd	a0,8(s1)
ffffffffc0202922:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0202924:	c525                	beqz	a0,ffffffffc020298c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202926:	100027f3          	csrr	a5,sstatus
ffffffffc020292a:	8b89                	andi	a5,a5,2
ffffffffc020292c:	ef8d                	bnez	a5,ffffffffc0202966 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc020292e:	00013797          	auipc	a5,0x13
ffffffffc0202932:	b6a78793          	addi	a5,a5,-1174 # ffffffffc0215498 <bigblocks>
ffffffffc0202936:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202938:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020293a:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc020293c:	60e2                	ld	ra,24(sp)
ffffffffc020293e:	8522                	mv	a0,s0
ffffffffc0202940:	6442                	ld	s0,16(sp)
ffffffffc0202942:	64a2                	ld	s1,8(sp)
ffffffffc0202944:	6902                	ld	s2,0(sp)
ffffffffc0202946:	6105                	addi	sp,sp,32
ffffffffc0202948:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc020294a:	0541                	addi	a0,a0,16
ffffffffc020294c:	e85ff0ef          	jal	ra,ffffffffc02027d0 <slob_alloc.isra.0.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202950:	01050413          	addi	s0,a0,16
ffffffffc0202954:	f565                	bnez	a0,ffffffffc020293c <kmalloc+0x56>
ffffffffc0202956:	4401                	li	s0,0
}
ffffffffc0202958:	60e2                	ld	ra,24(sp)
ffffffffc020295a:	8522                	mv	a0,s0
ffffffffc020295c:	6442                	ld	s0,16(sp)
ffffffffc020295e:	64a2                	ld	s1,8(sp)
ffffffffc0202960:	6902                	ld	s2,0(sp)
ffffffffc0202962:	6105                	addi	sp,sp,32
ffffffffc0202964:	8082                	ret
        intr_disable();
ffffffffc0202966:	c59fd0ef          	jal	ra,ffffffffc02005be <intr_disable>
		bb->next = bigblocks;
ffffffffc020296a:	00013797          	auipc	a5,0x13
ffffffffc020296e:	b2e78793          	addi	a5,a5,-1234 # ffffffffc0215498 <bigblocks>
ffffffffc0202972:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0202974:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0202976:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0202978:	c41fd0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
ffffffffc020297c:	6480                	ld	s0,8(s1)
}
ffffffffc020297e:	60e2                	ld	ra,24(sp)
ffffffffc0202980:	64a2                	ld	s1,8(sp)
ffffffffc0202982:	8522                	mv	a0,s0
ffffffffc0202984:	6442                	ld	s0,16(sp)
ffffffffc0202986:	6902                	ld	s2,0(sp)
ffffffffc0202988:	6105                	addi	sp,sp,32
ffffffffc020298a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020298c:	45e1                	li	a1,24
ffffffffc020298e:	8526                	mv	a0,s1
ffffffffc0202990:	d3bff0ef          	jal	ra,ffffffffc02026ca <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202994:	b765                	j	ffffffffc020293c <kmalloc+0x56>

ffffffffc0202996 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202996:	c179                	beqz	a0,ffffffffc0202a5c <kfree+0xc6>
{
ffffffffc0202998:	1101                	addi	sp,sp,-32
ffffffffc020299a:	e822                	sd	s0,16(sp)
ffffffffc020299c:	ec06                	sd	ra,24(sp)
ffffffffc020299e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc02029a0:	03451793          	slli	a5,a0,0x34
ffffffffc02029a4:	842a                	mv	s0,a0
ffffffffc02029a6:	e7d1                	bnez	a5,ffffffffc0202a32 <kfree+0x9c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02029a8:	100027f3          	csrr	a5,sstatus
ffffffffc02029ac:	8b89                	andi	a5,a5,2
ffffffffc02029ae:	ebd9                	bnez	a5,ffffffffc0202a44 <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02029b0:	00013797          	auipc	a5,0x13
ffffffffc02029b4:	ae87b783          	ld	a5,-1304(a5) # ffffffffc0215498 <bigblocks>
    return 0;
ffffffffc02029b8:	4601                	li	a2,0
ffffffffc02029ba:	cfa5                	beqz	a5,ffffffffc0202a32 <kfree+0x9c>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02029bc:	00013697          	auipc	a3,0x13
ffffffffc02029c0:	adc68693          	addi	a3,a3,-1316 # ffffffffc0215498 <bigblocks>
ffffffffc02029c4:	a021                	j	ffffffffc02029cc <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02029c6:	01048693          	addi	a3,s1,16
ffffffffc02029ca:	c3ad                	beqz	a5,ffffffffc0202a2c <kfree+0x96>
			if (bb->pages == block) {
ffffffffc02029cc:	6798                	ld	a4,8(a5)
ffffffffc02029ce:	84be                	mv	s1,a5
ffffffffc02029d0:	6b9c                	ld	a5,16(a5)
ffffffffc02029d2:	fe871ae3          	bne	a4,s0,ffffffffc02029c6 <kfree+0x30>
				*last = bb->next;
ffffffffc02029d6:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02029d8:	ee3d                	bnez	a2,ffffffffc0202a56 <kfree+0xc0>
    return pa2page(PADDR(kva));
ffffffffc02029da:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02029de:	4098                	lw	a4,0(s1)
ffffffffc02029e0:	08f46b63          	bltu	s0,a5,ffffffffc0202a76 <kfree+0xe0>
ffffffffc02029e4:	00013697          	auipc	a3,0x13
ffffffffc02029e8:	afc6b683          	ld	a3,-1284(a3) # ffffffffc02154e0 <va_pa_offset>
ffffffffc02029ec:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc02029ee:	8031                	srli	s0,s0,0xc
ffffffffc02029f0:	00013797          	auipc	a5,0x13
ffffffffc02029f4:	a987b783          	ld	a5,-1384(a5) # ffffffffc0215488 <npage>
ffffffffc02029f8:	06f47363          	bgeu	s0,a5,ffffffffc0202a5e <kfree+0xc8>
    return &pages[PPN(pa) - nbase];
ffffffffc02029fc:	00004517          	auipc	a0,0x4
ffffffffc0202a00:	2ac53503          	ld	a0,684(a0) # ffffffffc0206ca8 <nbase>
ffffffffc0202a04:	8c09                	sub	s0,s0,a0
ffffffffc0202a06:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0202a08:	00013517          	auipc	a0,0x13
ffffffffc0202a0c:	ae853503          	ld	a0,-1304(a0) # ffffffffc02154f0 <pages>
ffffffffc0202a10:	4585                	li	a1,1
ffffffffc0202a12:	9522                	add	a0,a0,s0
ffffffffc0202a14:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202a18:	a04fe0ef          	jal	ra,ffffffffc0200c1c <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0202a1c:	6442                	ld	s0,16(sp)
ffffffffc0202a1e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202a20:	8526                	mv	a0,s1
}
ffffffffc0202a22:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202a24:	45e1                	li	a1,24
}
ffffffffc0202a26:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202a28:	ca3ff06f          	j	ffffffffc02026ca <slob_free>
ffffffffc0202a2c:	c219                	beqz	a2,ffffffffc0202a32 <kfree+0x9c>
        intr_enable();
ffffffffc0202a2e:	b8bfd0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
ffffffffc0202a32:	ff040513          	addi	a0,s0,-16
}
ffffffffc0202a36:	6442                	ld	s0,16(sp)
ffffffffc0202a38:	60e2                	ld	ra,24(sp)
ffffffffc0202a3a:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202a3c:	4581                	li	a1,0
}
ffffffffc0202a3e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202a40:	c8bff06f          	j	ffffffffc02026ca <slob_free>
        intr_disable();
ffffffffc0202a44:	b7bfd0ef          	jal	ra,ffffffffc02005be <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202a48:	00013797          	auipc	a5,0x13
ffffffffc0202a4c:	a507b783          	ld	a5,-1456(a5) # ffffffffc0215498 <bigblocks>
        return 1;
ffffffffc0202a50:	4605                	li	a2,1
ffffffffc0202a52:	f7ad                	bnez	a5,ffffffffc02029bc <kfree+0x26>
ffffffffc0202a54:	bfe9                	j	ffffffffc0202a2e <kfree+0x98>
        intr_enable();
ffffffffc0202a56:	b63fd0ef          	jal	ra,ffffffffc02005b8 <intr_enable>
ffffffffc0202a5a:	b741                	j	ffffffffc02029da <kfree+0x44>
ffffffffc0202a5c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0202a5e:	00003617          	auipc	a2,0x3
ffffffffc0202a62:	afa60613          	addi	a2,a2,-1286 # ffffffffc0205558 <commands+0x708>
ffffffffc0202a66:	06200593          	li	a1,98
ffffffffc0202a6a:	00003517          	auipc	a0,0x3
ffffffffc0202a6e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0205578 <commands+0x728>
ffffffffc0202a72:	f56fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0202a76:	86a2                	mv	a3,s0
ffffffffc0202a78:	00003617          	auipc	a2,0x3
ffffffffc0202a7c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0205618 <commands+0x7c8>
ffffffffc0202a80:	06e00593          	li	a1,110
ffffffffc0202a84:	00003517          	auipc	a0,0x3
ffffffffc0202a88:	af450513          	addi	a0,a0,-1292 # ffffffffc0205578 <commands+0x728>
ffffffffc0202a8c:	f3cfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202a90 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202a90:	7135                	addi	sp,sp,-160
ffffffffc0202a92:	ed06                	sd	ra,152(sp)
ffffffffc0202a94:	e922                	sd	s0,144(sp)
ffffffffc0202a96:	e526                	sd	s1,136(sp)
ffffffffc0202a98:	e14a                	sd	s2,128(sp)
ffffffffc0202a9a:	fcce                	sd	s3,120(sp)
ffffffffc0202a9c:	f8d2                	sd	s4,112(sp)
ffffffffc0202a9e:	f4d6                	sd	s5,104(sp)
ffffffffc0202aa0:	f0da                	sd	s6,96(sp)
ffffffffc0202aa2:	ecde                	sd	s7,88(sp)
ffffffffc0202aa4:	e8e2                	sd	s8,80(sp)
ffffffffc0202aa6:	e4e6                	sd	s9,72(sp)
ffffffffc0202aa8:	e0ea                	sd	s10,64(sp)
ffffffffc0202aaa:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202aac:	368010ef          	jal	ra,ffffffffc0203e14 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202ab0:	00013697          	auipc	a3,0x13
ffffffffc0202ab4:	ae86b683          	ld	a3,-1304(a3) # ffffffffc0215598 <max_swap_offset>
ffffffffc0202ab8:	010007b7          	lui	a5,0x1000
ffffffffc0202abc:	ff968713          	addi	a4,a3,-7
ffffffffc0202ac0:	17e1                	addi	a5,a5,-8
ffffffffc0202ac2:	46e7ea63          	bltu	a5,a4,ffffffffc0202f36 <swap_init+0x4a6>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202ac6:	00007797          	auipc	a5,0x7
ffffffffc0202aca:	53a78793          	addi	a5,a5,1338 # ffffffffc020a000 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202ace:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202ad0:	00013c17          	auipc	s8,0x13
ffffffffc0202ad4:	9d0c0c13          	addi	s8,s8,-1584 # ffffffffc02154a0 <sm>
ffffffffc0202ad8:	00fc3023          	sd	a5,0(s8)
     int r = sm->init();
ffffffffc0202adc:	9702                	jalr	a4
ffffffffc0202ade:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0202ae0:	c10d                	beqz	a0,ffffffffc0202b02 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202ae2:	60ea                	ld	ra,152(sp)
ffffffffc0202ae4:	644a                	ld	s0,144(sp)
ffffffffc0202ae6:	64aa                	ld	s1,136(sp)
ffffffffc0202ae8:	79e6                	ld	s3,120(sp)
ffffffffc0202aea:	7a46                	ld	s4,112(sp)
ffffffffc0202aec:	7aa6                	ld	s5,104(sp)
ffffffffc0202aee:	7b06                	ld	s6,96(sp)
ffffffffc0202af0:	6be6                	ld	s7,88(sp)
ffffffffc0202af2:	6c46                	ld	s8,80(sp)
ffffffffc0202af4:	6ca6                	ld	s9,72(sp)
ffffffffc0202af6:	6d06                	ld	s10,64(sp)
ffffffffc0202af8:	7de2                	ld	s11,56(sp)
ffffffffc0202afa:	854a                	mv	a0,s2
ffffffffc0202afc:	690a                	ld	s2,128(sp)
ffffffffc0202afe:	610d                	addi	sp,sp,160
ffffffffc0202b00:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b02:	000c3783          	ld	a5,0(s8)
ffffffffc0202b06:	00003517          	auipc	a0,0x3
ffffffffc0202b0a:	64a50513          	addi	a0,a0,1610 # ffffffffc0206150 <commands+0x1300>
ffffffffc0202b0e:	00013417          	auipc	s0,0x13
ffffffffc0202b12:	aca40413          	addi	s0,s0,-1334 # ffffffffc02155d8 <free_area>
ffffffffc0202b16:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202b18:	4785                	li	a5,1
ffffffffc0202b1a:	00013717          	auipc	a4,0x13
ffffffffc0202b1e:	98f72723          	sw	a5,-1650(a4) # ffffffffc02154a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b22:	daafd0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202b26:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202b28:	4481                	li	s1,0
ffffffffc0202b2a:	4981                	li	s3,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b2c:	32878b63          	beq	a5,s0,ffffffffc0202e62 <swap_init+0x3d2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202b30:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202b34:	8b09                	andi	a4,a4,2
ffffffffc0202b36:	32070863          	beqz	a4,ffffffffc0202e66 <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc0202b3a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202b3e:	679c                	ld	a5,8(a5)
ffffffffc0202b40:	2985                	addiw	s3,s3,1
ffffffffc0202b42:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b44:	fe8796e3          	bne	a5,s0,ffffffffc0202b30 <swap_init+0xa0>
ffffffffc0202b48:	8a26                	mv	s4,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202b4a:	914fe0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc0202b4e:	65451c63          	bne	a0,s4,ffffffffc02031a6 <swap_init+0x716>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202b52:	8626                	mv	a2,s1
ffffffffc0202b54:	85ce                	mv	a1,s3
ffffffffc0202b56:	00003517          	auipc	a0,0x3
ffffffffc0202b5a:	64250513          	addi	a0,a0,1602 # ffffffffc0206198 <commands+0x1348>
ffffffffc0202b5e:	d6efd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202b62:	b98ff0ef          	jal	ra,ffffffffc0201efa <mm_create>
ffffffffc0202b66:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202b68:	5c050f63          	beqz	a0,ffffffffc0203146 <swap_init+0x6b6>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202b6c:	00013797          	auipc	a5,0x13
ffffffffc0202b70:	99c78793          	addi	a5,a5,-1636 # ffffffffc0215508 <check_mm_struct>
ffffffffc0202b74:	6398                	ld	a4,0(a5)
ffffffffc0202b76:	5e071863          	bnez	a4,ffffffffc0203166 <swap_init+0x6d6>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202b7a:	00013717          	auipc	a4,0x13
ffffffffc0202b7e:	90670713          	addi	a4,a4,-1786 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202b82:	00073c83          	ld	s9,0(a4)
     check_mm_struct = mm;
ffffffffc0202b86:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202b88:	000cb783          	ld	a5,0(s9)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202b8c:	01953c23          	sd	s9,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202b90:	4a079f63          	bnez	a5,ffffffffc020304e <swap_init+0x5be>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202b94:	6599                	lui	a1,0x6
ffffffffc0202b96:	460d                	li	a2,3
ffffffffc0202b98:	6505                	lui	a0,0x1
ffffffffc0202b9a:	ba8ff0ef          	jal	ra,ffffffffc0201f42 <vma_create>
ffffffffc0202b9e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202ba0:	4c050763          	beqz	a0,ffffffffc020306e <swap_init+0x5de>

     insert_vma_struct(mm, vma);
ffffffffc0202ba4:	855e                	mv	a0,s7
ffffffffc0202ba6:	c0aff0ef          	jal	ra,ffffffffc0201fb0 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202baa:	00003517          	auipc	a0,0x3
ffffffffc0202bae:	62e50513          	addi	a0,a0,1582 # ffffffffc02061d8 <commands+0x1388>
ffffffffc0202bb2:	d1afd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202bb6:	018bb503          	ld	a0,24(s7)
ffffffffc0202bba:	4605                	li	a2,1
ffffffffc0202bbc:	6585                	lui	a1,0x1
ffffffffc0202bbe:	8dcfe0ef          	jal	ra,ffffffffc0200c9a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202bc2:	4c050663          	beqz	a0,ffffffffc020308e <swap_init+0x5fe>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202bc6:	00003517          	auipc	a0,0x3
ffffffffc0202bca:	66250513          	addi	a0,a0,1634 # ffffffffc0206228 <commands+0x13d8>
ffffffffc0202bce:	00013a17          	auipc	s4,0x13
ffffffffc0202bd2:	942a0a13          	addi	s4,s4,-1726 # ffffffffc0215510 <check_rp>
ffffffffc0202bd6:	cf6fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bda:	00013a97          	auipc	s5,0x13
ffffffffc0202bde:	956a8a93          	addi	s5,s5,-1706 # ffffffffc0215530 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202be2:	8b52                	mv	s6,s4
          check_rp[i] = alloc_page();
ffffffffc0202be4:	4505                	li	a0,1
ffffffffc0202be6:	fa5fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0202bea:	00ab3023          	sd	a0,0(s6)
          assert(check_rp[i] != NULL );
ffffffffc0202bee:	30050463          	beqz	a0,ffffffffc0202ef6 <swap_init+0x466>
ffffffffc0202bf2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202bf4:	8b89                	andi	a5,a5,2
ffffffffc0202bf6:	2e079063          	bnez	a5,ffffffffc0202ed6 <swap_init+0x446>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bfa:	0b21                	addi	s6,s6,8
ffffffffc0202bfc:	ff5b14e3          	bne	s6,s5,ffffffffc0202be4 <swap_init+0x154>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202c00:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202c02:	00013b17          	auipc	s6,0x13
ffffffffc0202c06:	90eb0b13          	addi	s6,s6,-1778 # ffffffffc0215510 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc0202c0a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0202c0c:	ec3e                	sd	a5,24(sp)
ffffffffc0202c0e:	641c                	ld	a5,8(s0)
ffffffffc0202c10:	e400                	sd	s0,8(s0)
ffffffffc0202c12:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202c14:	481c                	lw	a5,16(s0)
ffffffffc0202c16:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202c18:	00013797          	auipc	a5,0x13
ffffffffc0202c1c:	9c07a823          	sw	zero,-1584(a5) # ffffffffc02155e8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202c20:	000b3503          	ld	a0,0(s6)
ffffffffc0202c24:	4585                	li	a1,1
ffffffffc0202c26:	0b21                	addi	s6,s6,8
ffffffffc0202c28:	ff5fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c2c:	ff5b1ae3          	bne	s6,s5,ffffffffc0202c20 <swap_init+0x190>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202c30:	01042b03          	lw	s6,16(s0)
ffffffffc0202c34:	4791                	li	a5,4
ffffffffc0202c36:	4efb1863          	bne	s6,a5,ffffffffc0203126 <swap_init+0x696>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	67650513          	addi	a0,a0,1654 # ffffffffc02062b0 <commands+0x1460>
ffffffffc0202c42:	c8afd0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202c46:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202c48:	00013797          	auipc	a5,0x13
ffffffffc0202c4c:	8407a423          	sw	zero,-1976(a5) # ffffffffc0215490 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202c50:	4629                	li	a2,10
ffffffffc0202c52:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202c56:	00013697          	auipc	a3,0x13
ffffffffc0202c5a:	83a6a683          	lw	a3,-1990(a3) # ffffffffc0215490 <pgfault_num>
ffffffffc0202c5e:	4585                	li	a1,1
ffffffffc0202c60:	00013797          	auipc	a5,0x13
ffffffffc0202c64:	83078793          	addi	a5,a5,-2000 # ffffffffc0215490 <pgfault_num>
ffffffffc0202c68:	36b69363          	bne	a3,a1,ffffffffc0202fce <swap_init+0x53e>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202c6c:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202c70:	4398                	lw	a4,0(a5)
ffffffffc0202c72:	2701                	sext.w	a4,a4
ffffffffc0202c74:	36d71d63          	bne	a4,a3,ffffffffc0202fee <swap_init+0x55e>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202c78:	6689                	lui	a3,0x2
ffffffffc0202c7a:	462d                	li	a2,11
ffffffffc0202c7c:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202c80:	4398                	lw	a4,0(a5)
ffffffffc0202c82:	4589                	li	a1,2
ffffffffc0202c84:	2701                	sext.w	a4,a4
ffffffffc0202c86:	2cb71463          	bne	a4,a1,ffffffffc0202f4e <swap_init+0x4be>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202c8a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202c8e:	4394                	lw	a3,0(a5)
ffffffffc0202c90:	2681                	sext.w	a3,a3
ffffffffc0202c92:	2ce69e63          	bne	a3,a4,ffffffffc0202f6e <swap_init+0x4de>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202c96:	668d                	lui	a3,0x3
ffffffffc0202c98:	4631                	li	a2,12
ffffffffc0202c9a:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202c9e:	4398                	lw	a4,0(a5)
ffffffffc0202ca0:	458d                	li	a1,3
ffffffffc0202ca2:	2701                	sext.w	a4,a4
ffffffffc0202ca4:	2eb71563          	bne	a4,a1,ffffffffc0202f8e <swap_init+0x4fe>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202ca8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202cac:	4394                	lw	a3,0(a5)
ffffffffc0202cae:	2681                	sext.w	a3,a3
ffffffffc0202cb0:	2ee69f63          	bne	a3,a4,ffffffffc0202fae <swap_init+0x51e>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202cb4:	6691                	lui	a3,0x4
ffffffffc0202cb6:	4635                	li	a2,13
ffffffffc0202cb8:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202cbc:	4398                	lw	a4,0(a5)
ffffffffc0202cbe:	2701                	sext.w	a4,a4
ffffffffc0202cc0:	35671763          	bne	a4,s6,ffffffffc020300e <swap_init+0x57e>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202cc4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202cc8:	439c                	lw	a5,0(a5)
ffffffffc0202cca:	2781                	sext.w	a5,a5
ffffffffc0202ccc:	36e79163          	bne	a5,a4,ffffffffc020302e <swap_init+0x59e>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202cd0:	481c                	lw	a5,16(s0)
ffffffffc0202cd2:	3c079e63          	bnez	a5,ffffffffc02030ae <swap_init+0x61e>
ffffffffc0202cd6:	00013797          	auipc	a5,0x13
ffffffffc0202cda:	85a78793          	addi	a5,a5,-1958 # ffffffffc0215530 <swap_in_seq_no>
ffffffffc0202cde:	00013717          	auipc	a4,0x13
ffffffffc0202ce2:	87a70713          	addi	a4,a4,-1926 # ffffffffc0215558 <swap_out_seq_no>
ffffffffc0202ce6:	00013617          	auipc	a2,0x13
ffffffffc0202cea:	87260613          	addi	a2,a2,-1934 # ffffffffc0215558 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202cee:	56fd                	li	a3,-1
ffffffffc0202cf0:	c394                	sw	a3,0(a5)
ffffffffc0202cf2:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202cf4:	0791                	addi	a5,a5,4
ffffffffc0202cf6:	0711                	addi	a4,a4,4
ffffffffc0202cf8:	fec79ce3          	bne	a5,a2,ffffffffc0202cf0 <swap_init+0x260>
ffffffffc0202cfc:	00013717          	auipc	a4,0x13
ffffffffc0202d00:	8bc70713          	addi	a4,a4,-1860 # ffffffffc02155b8 <check_ptep>
ffffffffc0202d04:	00013817          	auipc	a6,0x13
ffffffffc0202d08:	80c80813          	addi	a6,a6,-2036 # ffffffffc0215510 <check_rp>
ffffffffc0202d0c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202d0e:	00012d97          	auipc	s11,0x12
ffffffffc0202d12:	77ad8d93          	addi	s11,s11,1914 # ffffffffc0215488 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d16:	00012d17          	auipc	s10,0x12
ffffffffc0202d1a:	7dad0d13          	addi	s10,s10,2010 # ffffffffc02154f0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202d1e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202d22:	4601                	li	a2,0
ffffffffc0202d24:	8566                	mv	a0,s9
ffffffffc0202d26:	e842                	sd	a6,16(sp)
ffffffffc0202d28:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202d2a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202d2c:	f6ffd0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc0202d30:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202d32:	65a2                	ld	a1,8(sp)
ffffffffc0202d34:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202d36:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0202d38:	1c050f63          	beqz	a0,ffffffffc0202f16 <swap_init+0x486>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202d3c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202d3e:	0017f693          	andi	a3,a5,1
ffffffffc0202d42:	16068e63          	beqz	a3,ffffffffc0202ebe <swap_init+0x42e>
    if (PPN(pa) >= npage) {
ffffffffc0202d46:	000db683          	ld	a3,0(s11)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d4a:	078a                	slli	a5,a5,0x2
ffffffffc0202d4c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d4e:	12d7fc63          	bgeu	a5,a3,ffffffffc0202e86 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d52:	00004697          	auipc	a3,0x4
ffffffffc0202d56:	f5668693          	addi	a3,a3,-170 # ffffffffc0206ca8 <nbase>
ffffffffc0202d5a:	0006bb03          	ld	s6,0(a3)
ffffffffc0202d5e:	000d3683          	ld	a3,0(s10)
ffffffffc0202d62:	00083603          	ld	a2,0(a6)
ffffffffc0202d66:	416787b3          	sub	a5,a5,s6
ffffffffc0202d6a:	079a                	slli	a5,a5,0x6
ffffffffc0202d6c:	97b6                	add	a5,a5,a3
ffffffffc0202d6e:	12f61863          	bne	a2,a5,ffffffffc0202e9e <swap_init+0x40e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d72:	6785                	lui	a5,0x1
ffffffffc0202d74:	95be                	add	a1,a1,a5
ffffffffc0202d76:	6795                	lui	a5,0x5
ffffffffc0202d78:	0721                	addi	a4,a4,8
ffffffffc0202d7a:	0821                	addi	a6,a6,8
ffffffffc0202d7c:	faf591e3          	bne	a1,a5,ffffffffc0202d1e <swap_init+0x28e>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	5d850513          	addi	a0,a0,1496 # ffffffffc0206358 <commands+0x1508>
ffffffffc0202d88:	b44fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc0202d8c:	000c3783          	ld	a5,0(s8)
ffffffffc0202d90:	7f9c                	ld	a5,56(a5)
ffffffffc0202d92:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202d94:	3e051963          	bnez	a0,ffffffffc0203186 <swap_init+0x6f6>

     nr_free = nr_free_store;
ffffffffc0202d98:	77a2                	ld	a5,40(sp)
ffffffffc0202d9a:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202d9c:	67e2                	ld	a5,24(sp)
ffffffffc0202d9e:	e01c                	sd	a5,0(s0)
ffffffffc0202da0:	7782                	ld	a5,32(sp)
ffffffffc0202da2:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202da4:	000a3503          	ld	a0,0(s4)
ffffffffc0202da8:	4585                	li	a1,1
ffffffffc0202daa:	0a21                	addi	s4,s4,8
ffffffffc0202dac:	e71fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202db0:	ff5a1ae3          	bne	s4,s5,ffffffffc0202da4 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202db4:	855e                	mv	a0,s7
ffffffffc0202db6:	acaff0ef          	jal	ra,ffffffffc0202080 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202dba:	00012797          	auipc	a5,0x12
ffffffffc0202dbe:	6c678793          	addi	a5,a5,1734 # ffffffffc0215480 <boot_pgdir>
ffffffffc0202dc2:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202dc4:	000db703          	ld	a4,0(s11)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dc8:	6394                	ld	a3,0(a5)
ffffffffc0202dca:	068a                	slli	a3,a3,0x2
ffffffffc0202dcc:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dce:	0ae6fc63          	bgeu	a3,a4,ffffffffc0202e86 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dd2:	416686b3          	sub	a3,a3,s6
ffffffffc0202dd6:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202dd8:	8699                	srai	a3,a3,0x6
ffffffffc0202dda:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0202ddc:	00c69793          	slli	a5,a3,0xc
ffffffffc0202de0:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202de2:	000d3503          	ld	a0,0(s10)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202de6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202de8:	2ee7f363          	bgeu	a5,a4,ffffffffc02030ce <swap_init+0x63e>
     free_page(pde2page(pd0[0]));
ffffffffc0202dec:	00012797          	auipc	a5,0x12
ffffffffc0202df0:	6f47b783          	ld	a5,1780(a5) # ffffffffc02154e0 <va_pa_offset>
ffffffffc0202df4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202df6:	629c                	ld	a5,0(a3)
ffffffffc0202df8:	078a                	slli	a5,a5,0x2
ffffffffc0202dfa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dfc:	08e7f563          	bgeu	a5,a4,ffffffffc0202e86 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e00:	416787b3          	sub	a5,a5,s6
ffffffffc0202e04:	079a                	slli	a5,a5,0x6
ffffffffc0202e06:	953e                	add	a0,a0,a5
ffffffffc0202e08:	4585                	li	a1,1
ffffffffc0202e0a:	e13fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e0e:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0202e12:	000db703          	ld	a4,0(s11)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e16:	078a                	slli	a5,a5,0x2
ffffffffc0202e18:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e1a:	06e7f663          	bgeu	a5,a4,ffffffffc0202e86 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e1e:	000d3503          	ld	a0,0(s10)
ffffffffc0202e22:	41678b33          	sub	s6,a5,s6
ffffffffc0202e26:	0b1a                	slli	s6,s6,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202e28:	4585                	li	a1,1
ffffffffc0202e2a:	955a                	add	a0,a0,s6
ffffffffc0202e2c:	df1fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
     pgdir[0] = 0;
ffffffffc0202e30:	000cb023          	sd	zero,0(s9)
  asm volatile("sfence.vma");
ffffffffc0202e34:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202e38:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202e3a:	00878963          	beq	a5,s0,ffffffffc0202e4c <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202e3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202e42:	679c                	ld	a5,8(a5)
ffffffffc0202e44:	39fd                	addiw	s3,s3,-1
ffffffffc0202e46:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202e48:	fe879be3          	bne	a5,s0,ffffffffc0202e3e <swap_init+0x3ae>
     }
     assert(count==0);
ffffffffc0202e4c:	28099d63          	bnez	s3,ffffffffc02030e6 <swap_init+0x656>
     assert(total==0);
ffffffffc0202e50:	2a049b63          	bnez	s1,ffffffffc0203106 <swap_init+0x676>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202e54:	00003517          	auipc	a0,0x3
ffffffffc0202e58:	55450513          	addi	a0,a0,1364 # ffffffffc02063a8 <commands+0x1558>
ffffffffc0202e5c:	a70fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0202e60:	b149                	j	ffffffffc0202ae2 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202e62:	4a01                	li	s4,0
ffffffffc0202e64:	b1dd                	j	ffffffffc0202b4a <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202e66:	00003697          	auipc	a3,0x3
ffffffffc0202e6a:	30268693          	addi	a3,a3,770 # ffffffffc0206168 <commands+0x1318>
ffffffffc0202e6e:	00003617          	auipc	a2,0x3
ffffffffc0202e72:	82a60613          	addi	a2,a2,-2006 # ffffffffc0205698 <commands+0x848>
ffffffffc0202e76:	0bd00593          	li	a1,189
ffffffffc0202e7a:	00003517          	auipc	a0,0x3
ffffffffc0202e7e:	2c650513          	addi	a0,a0,710 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202e82:	b46fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202e86:	00002617          	auipc	a2,0x2
ffffffffc0202e8a:	6d260613          	addi	a2,a2,1746 # ffffffffc0205558 <commands+0x708>
ffffffffc0202e8e:	06200593          	li	a1,98
ffffffffc0202e92:	00002517          	auipc	a0,0x2
ffffffffc0202e96:	6e650513          	addi	a0,a0,1766 # ffffffffc0205578 <commands+0x728>
ffffffffc0202e9a:	b2efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202e9e:	00003697          	auipc	a3,0x3
ffffffffc0202ea2:	49268693          	addi	a3,a3,1170 # ffffffffc0206330 <commands+0x14e0>
ffffffffc0202ea6:	00002617          	auipc	a2,0x2
ffffffffc0202eaa:	7f260613          	addi	a2,a2,2034 # ffffffffc0205698 <commands+0x848>
ffffffffc0202eae:	0fd00593          	li	a1,253
ffffffffc0202eb2:	00003517          	auipc	a0,0x3
ffffffffc0202eb6:	28e50513          	addi	a0,a0,654 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202eba:	b0efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202ebe:	00003617          	auipc	a2,0x3
ffffffffc0202ec2:	8b260613          	addi	a2,a2,-1870 # ffffffffc0205770 <commands+0x920>
ffffffffc0202ec6:	07400593          	li	a1,116
ffffffffc0202eca:	00002517          	auipc	a0,0x2
ffffffffc0202ece:	6ae50513          	addi	a0,a0,1710 # ffffffffc0205578 <commands+0x728>
ffffffffc0202ed2:	af6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202ed6:	00003697          	auipc	a3,0x3
ffffffffc0202eda:	39268693          	addi	a3,a3,914 # ffffffffc0206268 <commands+0x1418>
ffffffffc0202ede:	00002617          	auipc	a2,0x2
ffffffffc0202ee2:	7ba60613          	addi	a2,a2,1978 # ffffffffc0205698 <commands+0x848>
ffffffffc0202ee6:	0de00593          	li	a1,222
ffffffffc0202eea:	00003517          	auipc	a0,0x3
ffffffffc0202eee:	25650513          	addi	a0,a0,598 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202ef2:	ad6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202ef6:	00003697          	auipc	a3,0x3
ffffffffc0202efa:	35a68693          	addi	a3,a3,858 # ffffffffc0206250 <commands+0x1400>
ffffffffc0202efe:	00002617          	auipc	a2,0x2
ffffffffc0202f02:	79a60613          	addi	a2,a2,1946 # ffffffffc0205698 <commands+0x848>
ffffffffc0202f06:	0dd00593          	li	a1,221
ffffffffc0202f0a:	00003517          	auipc	a0,0x3
ffffffffc0202f0e:	23650513          	addi	a0,a0,566 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202f12:	ab6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202f16:	00003697          	auipc	a3,0x3
ffffffffc0202f1a:	40268693          	addi	a3,a3,1026 # ffffffffc0206318 <commands+0x14c8>
ffffffffc0202f1e:	00002617          	auipc	a2,0x2
ffffffffc0202f22:	77a60613          	addi	a2,a2,1914 # ffffffffc0205698 <commands+0x848>
ffffffffc0202f26:	0fc00593          	li	a1,252
ffffffffc0202f2a:	00003517          	auipc	a0,0x3
ffffffffc0202f2e:	21650513          	addi	a0,a0,534 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202f32:	a96fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202f36:	00003617          	auipc	a2,0x3
ffffffffc0202f3a:	1ea60613          	addi	a2,a2,490 # ffffffffc0206120 <commands+0x12d0>
ffffffffc0202f3e:	02a00593          	li	a1,42
ffffffffc0202f42:	00003517          	auipc	a0,0x3
ffffffffc0202f46:	1fe50513          	addi	a0,a0,510 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202f4a:	a7efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f4e:	00003697          	auipc	a3,0x3
ffffffffc0202f52:	39a68693          	addi	a3,a3,922 # ffffffffc02062e8 <commands+0x1498>
ffffffffc0202f56:	00002617          	auipc	a2,0x2
ffffffffc0202f5a:	74260613          	addi	a2,a2,1858 # ffffffffc0205698 <commands+0x848>
ffffffffc0202f5e:	09800593          	li	a1,152
ffffffffc0202f62:	00003517          	auipc	a0,0x3
ffffffffc0202f66:	1de50513          	addi	a0,a0,478 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202f6a:	a5efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f6e:	00003697          	auipc	a3,0x3
ffffffffc0202f72:	37a68693          	addi	a3,a3,890 # ffffffffc02062e8 <commands+0x1498>
ffffffffc0202f76:	00002617          	auipc	a2,0x2
ffffffffc0202f7a:	72260613          	addi	a2,a2,1826 # ffffffffc0205698 <commands+0x848>
ffffffffc0202f7e:	09a00593          	li	a1,154
ffffffffc0202f82:	00003517          	auipc	a0,0x3
ffffffffc0202f86:	1be50513          	addi	a0,a0,446 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202f8a:	a3efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc0202f8e:	00003697          	auipc	a3,0x3
ffffffffc0202f92:	36a68693          	addi	a3,a3,874 # ffffffffc02062f8 <commands+0x14a8>
ffffffffc0202f96:	00002617          	auipc	a2,0x2
ffffffffc0202f9a:	70260613          	addi	a2,a2,1794 # ffffffffc0205698 <commands+0x848>
ffffffffc0202f9e:	09c00593          	li	a1,156
ffffffffc0202fa2:	00003517          	auipc	a0,0x3
ffffffffc0202fa6:	19e50513          	addi	a0,a0,414 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202faa:	a1efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc0202fae:	00003697          	auipc	a3,0x3
ffffffffc0202fb2:	34a68693          	addi	a3,a3,842 # ffffffffc02062f8 <commands+0x14a8>
ffffffffc0202fb6:	00002617          	auipc	a2,0x2
ffffffffc0202fba:	6e260613          	addi	a2,a2,1762 # ffffffffc0205698 <commands+0x848>
ffffffffc0202fbe:	09e00593          	li	a1,158
ffffffffc0202fc2:	00003517          	auipc	a0,0x3
ffffffffc0202fc6:	17e50513          	addi	a0,a0,382 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202fca:	9fefd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc0202fce:	00003697          	auipc	a3,0x3
ffffffffc0202fd2:	30a68693          	addi	a3,a3,778 # ffffffffc02062d8 <commands+0x1488>
ffffffffc0202fd6:	00002617          	auipc	a2,0x2
ffffffffc0202fda:	6c260613          	addi	a2,a2,1730 # ffffffffc0205698 <commands+0x848>
ffffffffc0202fde:	09400593          	li	a1,148
ffffffffc0202fe2:	00003517          	auipc	a0,0x3
ffffffffc0202fe6:	15e50513          	addi	a0,a0,350 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0202fea:	9defd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc0202fee:	00003697          	auipc	a3,0x3
ffffffffc0202ff2:	2ea68693          	addi	a3,a3,746 # ffffffffc02062d8 <commands+0x1488>
ffffffffc0202ff6:	00002617          	auipc	a2,0x2
ffffffffc0202ffa:	6a260613          	addi	a2,a2,1698 # ffffffffc0205698 <commands+0x848>
ffffffffc0202ffe:	09600593          	li	a1,150
ffffffffc0203002:	00003517          	auipc	a0,0x3
ffffffffc0203006:	13e50513          	addi	a0,a0,318 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020300a:	9befd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc020300e:	00003697          	auipc	a3,0x3
ffffffffc0203012:	b8268693          	addi	a3,a3,-1150 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0203016:	00002617          	auipc	a2,0x2
ffffffffc020301a:	68260613          	addi	a2,a2,1666 # ffffffffc0205698 <commands+0x848>
ffffffffc020301e:	0a000593          	li	a1,160
ffffffffc0203022:	00003517          	auipc	a0,0x3
ffffffffc0203026:	11e50513          	addi	a0,a0,286 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020302a:	99efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc020302e:	00003697          	auipc	a3,0x3
ffffffffc0203032:	b6268693          	addi	a3,a3,-1182 # ffffffffc0205b90 <commands+0xd40>
ffffffffc0203036:	00002617          	auipc	a2,0x2
ffffffffc020303a:	66260613          	addi	a2,a2,1634 # ffffffffc0205698 <commands+0x848>
ffffffffc020303e:	0a200593          	li	a1,162
ffffffffc0203042:	00003517          	auipc	a0,0x3
ffffffffc0203046:	0fe50513          	addi	a0,a0,254 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020304a:	97efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgdir[0] == 0);
ffffffffc020304e:	00003697          	auipc	a3,0x3
ffffffffc0203052:	f1268693          	addi	a3,a3,-238 # ffffffffc0205f60 <commands+0x1110>
ffffffffc0203056:	00002617          	auipc	a2,0x2
ffffffffc020305a:	64260613          	addi	a2,a2,1602 # ffffffffc0205698 <commands+0x848>
ffffffffc020305e:	0cd00593          	li	a1,205
ffffffffc0203062:	00003517          	auipc	a0,0x3
ffffffffc0203066:	0de50513          	addi	a0,a0,222 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020306a:	95efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(vma != NULL);
ffffffffc020306e:	00003697          	auipc	a3,0x3
ffffffffc0203072:	f9268693          	addi	a3,a3,-110 # ffffffffc0206000 <commands+0x11b0>
ffffffffc0203076:	00002617          	auipc	a2,0x2
ffffffffc020307a:	62260613          	addi	a2,a2,1570 # ffffffffc0205698 <commands+0x848>
ffffffffc020307e:	0d000593          	li	a1,208
ffffffffc0203082:	00003517          	auipc	a0,0x3
ffffffffc0203086:	0be50513          	addi	a0,a0,190 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020308a:	93efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc020308e:	00003697          	auipc	a3,0x3
ffffffffc0203092:	18268693          	addi	a3,a3,386 # ffffffffc0206210 <commands+0x13c0>
ffffffffc0203096:	00002617          	auipc	a2,0x2
ffffffffc020309a:	60260613          	addi	a2,a2,1538 # ffffffffc0205698 <commands+0x848>
ffffffffc020309e:	0d800593          	li	a1,216
ffffffffc02030a2:	00003517          	auipc	a0,0x3
ffffffffc02030a6:	09e50513          	addi	a0,a0,158 # ffffffffc0206140 <commands+0x12f0>
ffffffffc02030aa:	91efd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert( nr_free == 0);         
ffffffffc02030ae:	00003697          	auipc	a3,0x3
ffffffffc02030b2:	25a68693          	addi	a3,a3,602 # ffffffffc0206308 <commands+0x14b8>
ffffffffc02030b6:	00002617          	auipc	a2,0x2
ffffffffc02030ba:	5e260613          	addi	a2,a2,1506 # ffffffffc0205698 <commands+0x848>
ffffffffc02030be:	0f400593          	li	a1,244
ffffffffc02030c2:	00003517          	auipc	a0,0x3
ffffffffc02030c6:	07e50513          	addi	a0,a0,126 # ffffffffc0206140 <commands+0x12f0>
ffffffffc02030ca:	8fefd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc02030ce:	00002617          	auipc	a2,0x2
ffffffffc02030d2:	4ba60613          	addi	a2,a2,1210 # ffffffffc0205588 <commands+0x738>
ffffffffc02030d6:	06900593          	li	a1,105
ffffffffc02030da:	00002517          	auipc	a0,0x2
ffffffffc02030de:	49e50513          	addi	a0,a0,1182 # ffffffffc0205578 <commands+0x728>
ffffffffc02030e2:	8e6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(count==0);
ffffffffc02030e6:	00003697          	auipc	a3,0x3
ffffffffc02030ea:	2a268693          	addi	a3,a3,674 # ffffffffc0206388 <commands+0x1538>
ffffffffc02030ee:	00002617          	auipc	a2,0x2
ffffffffc02030f2:	5aa60613          	addi	a2,a2,1450 # ffffffffc0205698 <commands+0x848>
ffffffffc02030f6:	11c00593          	li	a1,284
ffffffffc02030fa:	00003517          	auipc	a0,0x3
ffffffffc02030fe:	04650513          	addi	a0,a0,70 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0203102:	8c6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total==0);
ffffffffc0203106:	00003697          	auipc	a3,0x3
ffffffffc020310a:	29268693          	addi	a3,a3,658 # ffffffffc0206398 <commands+0x1548>
ffffffffc020310e:	00002617          	auipc	a2,0x2
ffffffffc0203112:	58a60613          	addi	a2,a2,1418 # ffffffffc0205698 <commands+0x848>
ffffffffc0203116:	11d00593          	li	a1,285
ffffffffc020311a:	00003517          	auipc	a0,0x3
ffffffffc020311e:	02650513          	addi	a0,a0,38 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0203122:	8a6fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203126:	00003697          	auipc	a3,0x3
ffffffffc020312a:	16268693          	addi	a3,a3,354 # ffffffffc0206288 <commands+0x1438>
ffffffffc020312e:	00002617          	auipc	a2,0x2
ffffffffc0203132:	56a60613          	addi	a2,a2,1386 # ffffffffc0205698 <commands+0x848>
ffffffffc0203136:	0eb00593          	li	a1,235
ffffffffc020313a:	00003517          	auipc	a0,0x3
ffffffffc020313e:	00650513          	addi	a0,a0,6 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0203142:	886fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(mm != NULL);
ffffffffc0203146:	00003697          	auipc	a3,0x3
ffffffffc020314a:	c9268693          	addi	a3,a3,-878 # ffffffffc0205dd8 <commands+0xf88>
ffffffffc020314e:	00002617          	auipc	a2,0x2
ffffffffc0203152:	54a60613          	addi	a2,a2,1354 # ffffffffc0205698 <commands+0x848>
ffffffffc0203156:	0c500593          	li	a1,197
ffffffffc020315a:	00003517          	auipc	a0,0x3
ffffffffc020315e:	fe650513          	addi	a0,a0,-26 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0203162:	866fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203166:	00003697          	auipc	a3,0x3
ffffffffc020316a:	05a68693          	addi	a3,a3,90 # ffffffffc02061c0 <commands+0x1370>
ffffffffc020316e:	00002617          	auipc	a2,0x2
ffffffffc0203172:	52a60613          	addi	a2,a2,1322 # ffffffffc0205698 <commands+0x848>
ffffffffc0203176:	0c800593          	li	a1,200
ffffffffc020317a:	00003517          	auipc	a0,0x3
ffffffffc020317e:	fc650513          	addi	a0,a0,-58 # ffffffffc0206140 <commands+0x12f0>
ffffffffc0203182:	846fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(ret==0);
ffffffffc0203186:	00003697          	auipc	a3,0x3
ffffffffc020318a:	1fa68693          	addi	a3,a3,506 # ffffffffc0206380 <commands+0x1530>
ffffffffc020318e:	00002617          	auipc	a2,0x2
ffffffffc0203192:	50a60613          	addi	a2,a2,1290 # ffffffffc0205698 <commands+0x848>
ffffffffc0203196:	10300593          	li	a1,259
ffffffffc020319a:	00003517          	auipc	a0,0x3
ffffffffc020319e:	fa650513          	addi	a0,a0,-90 # ffffffffc0206140 <commands+0x12f0>
ffffffffc02031a2:	826fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total == nr_free_pages());
ffffffffc02031a6:	00003697          	auipc	a3,0x3
ffffffffc02031aa:	fd268693          	addi	a3,a3,-46 # ffffffffc0206178 <commands+0x1328>
ffffffffc02031ae:	00002617          	auipc	a2,0x2
ffffffffc02031b2:	4ea60613          	addi	a2,a2,1258 # ffffffffc0205698 <commands+0x848>
ffffffffc02031b6:	0c000593          	li	a1,192
ffffffffc02031ba:	00003517          	auipc	a0,0x3
ffffffffc02031be:	f8650513          	addi	a0,a0,-122 # ffffffffc0206140 <commands+0x12f0>
ffffffffc02031c2:	806fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02031c6 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02031c6:	00012797          	auipc	a5,0x12
ffffffffc02031ca:	2da7b783          	ld	a5,730(a5) # ffffffffc02154a0 <sm>
ffffffffc02031ce:	0107b303          	ld	t1,16(a5)
ffffffffc02031d2:	8302                	jr	t1

ffffffffc02031d4 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02031d4:	00012797          	auipc	a5,0x12
ffffffffc02031d8:	2cc7b783          	ld	a5,716(a5) # ffffffffc02154a0 <sm>
ffffffffc02031dc:	0207b303          	ld	t1,32(a5)
ffffffffc02031e0:	8302                	jr	t1

ffffffffc02031e2 <swap_out>:
{
ffffffffc02031e2:	711d                	addi	sp,sp,-96
ffffffffc02031e4:	ec86                	sd	ra,88(sp)
ffffffffc02031e6:	e8a2                	sd	s0,80(sp)
ffffffffc02031e8:	e4a6                	sd	s1,72(sp)
ffffffffc02031ea:	e0ca                	sd	s2,64(sp)
ffffffffc02031ec:	fc4e                	sd	s3,56(sp)
ffffffffc02031ee:	f852                	sd	s4,48(sp)
ffffffffc02031f0:	f456                	sd	s5,40(sp)
ffffffffc02031f2:	f05a                	sd	s6,32(sp)
ffffffffc02031f4:	ec5e                	sd	s7,24(sp)
ffffffffc02031f6:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02031f8:	cde9                	beqz	a1,ffffffffc02032d2 <swap_out+0xf0>
ffffffffc02031fa:	8a2e                	mv	s4,a1
ffffffffc02031fc:	892a                	mv	s2,a0
ffffffffc02031fe:	8ab2                	mv	s5,a2
ffffffffc0203200:	4401                	li	s0,0
ffffffffc0203202:	00012997          	auipc	s3,0x12
ffffffffc0203206:	29e98993          	addi	s3,s3,670 # ffffffffc02154a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020320a:	00003b17          	auipc	s6,0x3
ffffffffc020320e:	21eb0b13          	addi	s6,s6,542 # ffffffffc0206428 <commands+0x15d8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203212:	00003b97          	auipc	s7,0x3
ffffffffc0203216:	1feb8b93          	addi	s7,s7,510 # ffffffffc0206410 <commands+0x15c0>
ffffffffc020321a:	a825                	j	ffffffffc0203252 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc020321c:	67a2                	ld	a5,8(sp)
ffffffffc020321e:	8626                	mv	a2,s1
ffffffffc0203220:	85a2                	mv	a1,s0
ffffffffc0203222:	7f94                	ld	a3,56(a5)
ffffffffc0203224:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203226:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203228:	82b1                	srli	a3,a3,0xc
ffffffffc020322a:	0685                	addi	a3,a3,1
ffffffffc020322c:	ea1fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203230:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203232:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203234:	7d1c                	ld	a5,56(a0)
ffffffffc0203236:	83b1                	srli	a5,a5,0xc
ffffffffc0203238:	0785                	addi	a5,a5,1
ffffffffc020323a:	07a2                	slli	a5,a5,0x8
ffffffffc020323c:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203240:	9ddfd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203244:	01893503          	ld	a0,24(s2)
ffffffffc0203248:	85a6                	mv	a1,s1
ffffffffc020324a:	ffcfe0ef          	jal	ra,ffffffffc0201a46 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc020324e:	048a0d63          	beq	s4,s0,ffffffffc02032a8 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203252:	0009b783          	ld	a5,0(s3)
ffffffffc0203256:	8656                	mv	a2,s5
ffffffffc0203258:	002c                	addi	a1,sp,8
ffffffffc020325a:	7b9c                	ld	a5,48(a5)
ffffffffc020325c:	854a                	mv	a0,s2
ffffffffc020325e:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203260:	e12d                	bnez	a0,ffffffffc02032c2 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203262:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203264:	01893503          	ld	a0,24(s2)
ffffffffc0203268:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc020326a:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020326c:	85a6                	mv	a1,s1
ffffffffc020326e:	a2dfd0ef          	jal	ra,ffffffffc0200c9a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203272:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203274:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203276:	8b85                	andi	a5,a5,1
ffffffffc0203278:	cfb9                	beqz	a5,ffffffffc02032d6 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc020327a:	65a2                	ld	a1,8(sp)
ffffffffc020327c:	7d9c                	ld	a5,56(a1)
ffffffffc020327e:	83b1                	srli	a5,a5,0xc
ffffffffc0203280:	0785                	addi	a5,a5,1
ffffffffc0203282:	00879513          	slli	a0,a5,0x8
ffffffffc0203286:	455000ef          	jal	ra,ffffffffc0203eda <swapfs_write>
ffffffffc020328a:	d949                	beqz	a0,ffffffffc020321c <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc020328c:	855e                	mv	a0,s7
ffffffffc020328e:	e3ffc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203292:	0009b783          	ld	a5,0(s3)
ffffffffc0203296:	6622                	ld	a2,8(sp)
ffffffffc0203298:	4681                	li	a3,0
ffffffffc020329a:	739c                	ld	a5,32(a5)
ffffffffc020329c:	85a6                	mv	a1,s1
ffffffffc020329e:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc02032a0:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02032a2:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc02032a4:	fa8a17e3          	bne	s4,s0,ffffffffc0203252 <swap_out+0x70>
}
ffffffffc02032a8:	60e6                	ld	ra,88(sp)
ffffffffc02032aa:	8522                	mv	a0,s0
ffffffffc02032ac:	6446                	ld	s0,80(sp)
ffffffffc02032ae:	64a6                	ld	s1,72(sp)
ffffffffc02032b0:	6906                	ld	s2,64(sp)
ffffffffc02032b2:	79e2                	ld	s3,56(sp)
ffffffffc02032b4:	7a42                	ld	s4,48(sp)
ffffffffc02032b6:	7aa2                	ld	s5,40(sp)
ffffffffc02032b8:	7b02                	ld	s6,32(sp)
ffffffffc02032ba:	6be2                	ld	s7,24(sp)
ffffffffc02032bc:	6c42                	ld	s8,16(sp)
ffffffffc02032be:	6125                	addi	sp,sp,96
ffffffffc02032c0:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc02032c2:	85a2                	mv	a1,s0
ffffffffc02032c4:	00003517          	auipc	a0,0x3
ffffffffc02032c8:	10450513          	addi	a0,a0,260 # ffffffffc02063c8 <commands+0x1578>
ffffffffc02032cc:	e01fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc02032d0:	bfe1                	j	ffffffffc02032a8 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc02032d2:	4401                	li	s0,0
ffffffffc02032d4:	bfd1                	j	ffffffffc02032a8 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc02032d6:	00003697          	auipc	a3,0x3
ffffffffc02032da:	12268693          	addi	a3,a3,290 # ffffffffc02063f8 <commands+0x15a8>
ffffffffc02032de:	00002617          	auipc	a2,0x2
ffffffffc02032e2:	3ba60613          	addi	a2,a2,954 # ffffffffc0205698 <commands+0x848>
ffffffffc02032e6:	06900593          	li	a1,105
ffffffffc02032ea:	00003517          	auipc	a0,0x3
ffffffffc02032ee:	e5650513          	addi	a0,a0,-426 # ffffffffc0206140 <commands+0x12f0>
ffffffffc02032f2:	ed7fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02032f6 <swap_in>:
{
ffffffffc02032f6:	7179                	addi	sp,sp,-48
ffffffffc02032f8:	e84a                	sd	s2,16(sp)
ffffffffc02032fa:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02032fc:	4505                	li	a0,1
{
ffffffffc02032fe:	ec26                	sd	s1,24(sp)
ffffffffc0203300:	e44e                	sd	s3,8(sp)
ffffffffc0203302:	f406                	sd	ra,40(sp)
ffffffffc0203304:	f022                	sd	s0,32(sp)
ffffffffc0203306:	84ae                	mv	s1,a1
ffffffffc0203308:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc020330a:	881fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
     assert(result!=NULL);
ffffffffc020330e:	c129                	beqz	a0,ffffffffc0203350 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203310:	842a                	mv	s0,a0
ffffffffc0203312:	01893503          	ld	a0,24(s2)
ffffffffc0203316:	4601                	li	a2,0
ffffffffc0203318:	85a6                	mv	a1,s1
ffffffffc020331a:	981fd0ef          	jal	ra,ffffffffc0200c9a <get_pte>
ffffffffc020331e:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203320:	6108                	ld	a0,0(a0)
ffffffffc0203322:	85a2                	mv	a1,s0
ffffffffc0203324:	329000ef          	jal	ra,ffffffffc0203e4c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203328:	00093583          	ld	a1,0(s2)
ffffffffc020332c:	8626                	mv	a2,s1
ffffffffc020332e:	00003517          	auipc	a0,0x3
ffffffffc0203332:	14a50513          	addi	a0,a0,330 # ffffffffc0206478 <commands+0x1628>
ffffffffc0203336:	81a1                	srli	a1,a1,0x8
ffffffffc0203338:	d95fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc020333c:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020333e:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203342:	7402                	ld	s0,32(sp)
ffffffffc0203344:	64e2                	ld	s1,24(sp)
ffffffffc0203346:	6942                	ld	s2,16(sp)
ffffffffc0203348:	69a2                	ld	s3,8(sp)
ffffffffc020334a:	4501                	li	a0,0
ffffffffc020334c:	6145                	addi	sp,sp,48
ffffffffc020334e:	8082                	ret
     assert(result!=NULL);
ffffffffc0203350:	00003697          	auipc	a3,0x3
ffffffffc0203354:	11868693          	addi	a3,a3,280 # ffffffffc0206468 <commands+0x1618>
ffffffffc0203358:	00002617          	auipc	a2,0x2
ffffffffc020335c:	34060613          	addi	a2,a2,832 # ffffffffc0205698 <commands+0x848>
ffffffffc0203360:	07f00593          	li	a1,127
ffffffffc0203364:	00003517          	auipc	a0,0x3
ffffffffc0203368:	ddc50513          	addi	a0,a0,-548 # ffffffffc0206140 <commands+0x12f0>
ffffffffc020336c:	e5dfc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203370 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0203370:	00012797          	auipc	a5,0x12
ffffffffc0203374:	26878793          	addi	a5,a5,616 # ffffffffc02155d8 <free_area>
ffffffffc0203378:	e79c                	sd	a5,8(a5)
ffffffffc020337a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020337c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0203380:	8082                	ret

ffffffffc0203382 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0203382:	00012517          	auipc	a0,0x12
ffffffffc0203386:	26656503          	lwu	a0,614(a0) # ffffffffc02155e8 <free_area+0x10>
ffffffffc020338a:	8082                	ret

ffffffffc020338c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020338c:	715d                	addi	sp,sp,-80
ffffffffc020338e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0203390:	00012417          	auipc	s0,0x12
ffffffffc0203394:	24840413          	addi	s0,s0,584 # ffffffffc02155d8 <free_area>
ffffffffc0203398:	641c                	ld	a5,8(s0)
ffffffffc020339a:	e486                	sd	ra,72(sp)
ffffffffc020339c:	fc26                	sd	s1,56(sp)
ffffffffc020339e:	f84a                	sd	s2,48(sp)
ffffffffc02033a0:	f44e                	sd	s3,40(sp)
ffffffffc02033a2:	f052                	sd	s4,32(sp)
ffffffffc02033a4:	ec56                	sd	s5,24(sp)
ffffffffc02033a6:	e85a                	sd	s6,16(sp)
ffffffffc02033a8:	e45e                	sd	s7,8(sp)
ffffffffc02033aa:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033ac:	2a878d63          	beq	a5,s0,ffffffffc0203666 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02033b0:	4481                	li	s1,0
ffffffffc02033b2:	4901                	li	s2,0
ffffffffc02033b4:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02033b8:	8b09                	andi	a4,a4,2
ffffffffc02033ba:	2a070a63          	beqz	a4,ffffffffc020366e <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02033be:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033c2:	679c                	ld	a5,8(a5)
ffffffffc02033c4:	2905                	addiw	s2,s2,1
ffffffffc02033c6:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02033c8:	fe8796e3          	bne	a5,s0,ffffffffc02033b4 <default_check+0x28>
ffffffffc02033cc:	89a6                	mv	s3,s1
    }
    assert(total == nr_free_pages());
ffffffffc02033ce:	891fd0ef          	jal	ra,ffffffffc0200c5e <nr_free_pages>
ffffffffc02033d2:	6f351e63          	bne	a0,s3,ffffffffc0203ace <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02033d6:	4505                	li	a0,1
ffffffffc02033d8:	fb2fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02033dc:	8aaa                	mv	s5,a0
ffffffffc02033de:	42050863          	beqz	a0,ffffffffc020380e <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02033e2:	4505                	li	a0,1
ffffffffc02033e4:	fa6fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02033e8:	89aa                	mv	s3,a0
ffffffffc02033ea:	70050263          	beqz	a0,ffffffffc0203aee <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02033ee:	4505                	li	a0,1
ffffffffc02033f0:	f9afd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02033f4:	8a2a                	mv	s4,a0
ffffffffc02033f6:	48050c63          	beqz	a0,ffffffffc020388e <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02033fa:	293a8a63          	beq	s5,s3,ffffffffc020368e <default_check+0x302>
ffffffffc02033fe:	28aa8863          	beq	s5,a0,ffffffffc020368e <default_check+0x302>
ffffffffc0203402:	28a98663          	beq	s3,a0,ffffffffc020368e <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0203406:	000aa783          	lw	a5,0(s5)
ffffffffc020340a:	2a079263          	bnez	a5,ffffffffc02036ae <default_check+0x322>
ffffffffc020340e:	0009a783          	lw	a5,0(s3)
ffffffffc0203412:	28079e63          	bnez	a5,ffffffffc02036ae <default_check+0x322>
ffffffffc0203416:	411c                	lw	a5,0(a0)
ffffffffc0203418:	28079b63          	bnez	a5,ffffffffc02036ae <default_check+0x322>
    return page - pages + nbase;
ffffffffc020341c:	00012797          	auipc	a5,0x12
ffffffffc0203420:	0d47b783          	ld	a5,212(a5) # ffffffffc02154f0 <pages>
ffffffffc0203424:	40fa8733          	sub	a4,s5,a5
ffffffffc0203428:	00004617          	auipc	a2,0x4
ffffffffc020342c:	88063603          	ld	a2,-1920(a2) # ffffffffc0206ca8 <nbase>
ffffffffc0203430:	8719                	srai	a4,a4,0x6
ffffffffc0203432:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0203434:	00012697          	auipc	a3,0x12
ffffffffc0203438:	0546b683          	ld	a3,84(a3) # ffffffffc0215488 <npage>
ffffffffc020343c:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020343e:	0732                	slli	a4,a4,0xc
ffffffffc0203440:	28d77763          	bgeu	a4,a3,ffffffffc02036ce <default_check+0x342>
    return page - pages + nbase;
ffffffffc0203444:	40f98733          	sub	a4,s3,a5
ffffffffc0203448:	8719                	srai	a4,a4,0x6
ffffffffc020344a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020344c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020344e:	4cd77063          	bgeu	a4,a3,ffffffffc020390e <default_check+0x582>
    return page - pages + nbase;
ffffffffc0203452:	40f507b3          	sub	a5,a0,a5
ffffffffc0203456:	8799                	srai	a5,a5,0x6
ffffffffc0203458:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020345a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020345c:	30d7f963          	bgeu	a5,a3,ffffffffc020376e <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0203460:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203462:	00043c03          	ld	s8,0(s0)
ffffffffc0203466:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020346a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020346e:	e400                	sd	s0,8(s0)
ffffffffc0203470:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0203472:	00012797          	auipc	a5,0x12
ffffffffc0203476:	1607ab23          	sw	zero,374(a5) # ffffffffc02155e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020347a:	f10fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc020347e:	2c051863          	bnez	a0,ffffffffc020374e <default_check+0x3c2>
    free_page(p0);
ffffffffc0203482:	4585                	li	a1,1
ffffffffc0203484:	8556                	mv	a0,s5
ffffffffc0203486:	f96fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_page(p1);
ffffffffc020348a:	4585                	li	a1,1
ffffffffc020348c:	854e                	mv	a0,s3
ffffffffc020348e:	f8efd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_page(p2);
ffffffffc0203492:	4585                	li	a1,1
ffffffffc0203494:	8552                	mv	a0,s4
ffffffffc0203496:	f86fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    assert(nr_free == 3);
ffffffffc020349a:	4818                	lw	a4,16(s0)
ffffffffc020349c:	478d                	li	a5,3
ffffffffc020349e:	28f71863          	bne	a4,a5,ffffffffc020372e <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02034a2:	4505                	li	a0,1
ffffffffc02034a4:	ee6fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034a8:	89aa                	mv	s3,a0
ffffffffc02034aa:	26050263          	beqz	a0,ffffffffc020370e <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02034ae:	4505                	li	a0,1
ffffffffc02034b0:	edafd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034b4:	8aaa                	mv	s5,a0
ffffffffc02034b6:	3a050c63          	beqz	a0,ffffffffc020386e <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02034ba:	4505                	li	a0,1
ffffffffc02034bc:	ecefd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034c0:	8a2a                	mv	s4,a0
ffffffffc02034c2:	38050663          	beqz	a0,ffffffffc020384e <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02034c6:	4505                	li	a0,1
ffffffffc02034c8:	ec2fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034cc:	36051163          	bnez	a0,ffffffffc020382e <default_check+0x4a2>
    free_page(p0);
ffffffffc02034d0:	4585                	li	a1,1
ffffffffc02034d2:	854e                	mv	a0,s3
ffffffffc02034d4:	f48fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02034d8:	641c                	ld	a5,8(s0)
ffffffffc02034da:	20878a63          	beq	a5,s0,ffffffffc02036ee <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02034de:	4505                	li	a0,1
ffffffffc02034e0:	eaafd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034e4:	30a99563          	bne	s3,a0,ffffffffc02037ee <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	ea0fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02034ee:	2e051063          	bnez	a0,ffffffffc02037ce <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02034f2:	481c                	lw	a5,16(s0)
ffffffffc02034f4:	2a079d63          	bnez	a5,ffffffffc02037ae <default_check+0x422>
    free_page(p);
ffffffffc02034f8:	854e                	mv	a0,s3
ffffffffc02034fa:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02034fc:	01843023          	sd	s8,0(s0)
ffffffffc0203500:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0203504:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0203508:	f14fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_page(p1);
ffffffffc020350c:	4585                	li	a1,1
ffffffffc020350e:	8556                	mv	a0,s5
ffffffffc0203510:	f0cfd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_page(p2);
ffffffffc0203514:	4585                	li	a1,1
ffffffffc0203516:	8552                	mv	a0,s4
ffffffffc0203518:	f04fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020351c:	4515                	li	a0,5
ffffffffc020351e:	e6cfd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203522:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0203524:	26050563          	beqz	a0,ffffffffc020378e <default_check+0x402>
ffffffffc0203528:	651c                	ld	a5,8(a0)
ffffffffc020352a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020352c:	8b85                	andi	a5,a5,1
ffffffffc020352e:	54079063          	bnez	a5,ffffffffc0203a6e <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0203532:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0203534:	00043b03          	ld	s6,0(s0)
ffffffffc0203538:	00843a83          	ld	s5,8(s0)
ffffffffc020353c:	e000                	sd	s0,0(s0)
ffffffffc020353e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0203540:	e4afd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203544:	50051563          	bnez	a0,ffffffffc0203a4e <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0203548:	08098a13          	addi	s4,s3,128
ffffffffc020354c:	8552                	mv	a0,s4
ffffffffc020354e:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0203550:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0203554:	00012797          	auipc	a5,0x12
ffffffffc0203558:	0807aa23          	sw	zero,148(a5) # ffffffffc02155e8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020355c:	ec0fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0203560:	4511                	li	a0,4
ffffffffc0203562:	e28fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203566:	4c051463          	bnez	a0,ffffffffc0203a2e <default_check+0x6a2>
ffffffffc020356a:	0889b783          	ld	a5,136(s3)
ffffffffc020356e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203570:	8b85                	andi	a5,a5,1
ffffffffc0203572:	48078e63          	beqz	a5,ffffffffc0203a0e <default_check+0x682>
ffffffffc0203576:	0909a703          	lw	a4,144(s3)
ffffffffc020357a:	478d                	li	a5,3
ffffffffc020357c:	48f71963          	bne	a4,a5,ffffffffc0203a0e <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0203580:	450d                	li	a0,3
ffffffffc0203582:	e08fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203586:	8c2a                	mv	s8,a0
ffffffffc0203588:	46050363          	beqz	a0,ffffffffc02039ee <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020358c:	4505                	li	a0,1
ffffffffc020358e:	dfcfd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203592:	42051e63          	bnez	a0,ffffffffc02039ce <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0203596:	418a1c63          	bne	s4,s8,ffffffffc02039ae <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020359a:	4585                	li	a1,1
ffffffffc020359c:	854e                	mv	a0,s3
ffffffffc020359e:	e7efd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_pages(p1, 3);
ffffffffc02035a2:	458d                	li	a1,3
ffffffffc02035a4:	8552                	mv	a0,s4
ffffffffc02035a6:	e76fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
ffffffffc02035aa:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02035ae:	04098c13          	addi	s8,s3,64
ffffffffc02035b2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02035b4:	8b85                	andi	a5,a5,1
ffffffffc02035b6:	3c078c63          	beqz	a5,ffffffffc020398e <default_check+0x602>
ffffffffc02035ba:	0109a703          	lw	a4,16(s3)
ffffffffc02035be:	4785                	li	a5,1
ffffffffc02035c0:	3cf71763          	bne	a4,a5,ffffffffc020398e <default_check+0x602>
ffffffffc02035c4:	008a3783          	ld	a5,8(s4)
ffffffffc02035c8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02035ca:	8b85                	andi	a5,a5,1
ffffffffc02035cc:	3a078163          	beqz	a5,ffffffffc020396e <default_check+0x5e2>
ffffffffc02035d0:	010a2703          	lw	a4,16(s4)
ffffffffc02035d4:	478d                	li	a5,3
ffffffffc02035d6:	38f71c63          	bne	a4,a5,ffffffffc020396e <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02035da:	4505                	li	a0,1
ffffffffc02035dc:	daefd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02035e0:	36a99763          	bne	s3,a0,ffffffffc020394e <default_check+0x5c2>
    free_page(p0);
ffffffffc02035e4:	4585                	li	a1,1
ffffffffc02035e6:	e36fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02035ea:	4509                	li	a0,2
ffffffffc02035ec:	d9efd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc02035f0:	32aa1f63          	bne	s4,a0,ffffffffc020392e <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02035f4:	4589                	li	a1,2
ffffffffc02035f6:	e26fd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    free_page(p2);
ffffffffc02035fa:	4585                	li	a1,1
ffffffffc02035fc:	8562                	mv	a0,s8
ffffffffc02035fe:	e1efd0ef          	jal	ra,ffffffffc0200c1c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203602:	4515                	li	a0,5
ffffffffc0203604:	d86fd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203608:	89aa                	mv	s3,a0
ffffffffc020360a:	48050263          	beqz	a0,ffffffffc0203a8e <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020360e:	4505                	li	a0,1
ffffffffc0203610:	d7afd0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
ffffffffc0203614:	2c051d63          	bnez	a0,ffffffffc02038ee <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0203618:	481c                	lw	a5,16(s0)
ffffffffc020361a:	2a079a63          	bnez	a5,ffffffffc02038ce <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020361e:	4595                	li	a1,5
ffffffffc0203620:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0203622:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0203626:	01643023          	sd	s6,0(s0)
ffffffffc020362a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020362e:	deefd0ef          	jal	ra,ffffffffc0200c1c <free_pages>
    return listelm->next;
ffffffffc0203632:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203634:	00878963          	beq	a5,s0,ffffffffc0203646 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0203638:	ff87a703          	lw	a4,-8(a5)
ffffffffc020363c:	679c                	ld	a5,8(a5)
ffffffffc020363e:	397d                	addiw	s2,s2,-1
ffffffffc0203640:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203642:	fe879be3          	bne	a5,s0,ffffffffc0203638 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0203646:	26091463          	bnez	s2,ffffffffc02038ae <default_check+0x522>
    assert(total == 0);
ffffffffc020364a:	46049263          	bnez	s1,ffffffffc0203aae <default_check+0x722>
}
ffffffffc020364e:	60a6                	ld	ra,72(sp)
ffffffffc0203650:	6406                	ld	s0,64(sp)
ffffffffc0203652:	74e2                	ld	s1,56(sp)
ffffffffc0203654:	7942                	ld	s2,48(sp)
ffffffffc0203656:	79a2                	ld	s3,40(sp)
ffffffffc0203658:	7a02                	ld	s4,32(sp)
ffffffffc020365a:	6ae2                	ld	s5,24(sp)
ffffffffc020365c:	6b42                	ld	s6,16(sp)
ffffffffc020365e:	6ba2                	ld	s7,8(sp)
ffffffffc0203660:	6c02                	ld	s8,0(sp)
ffffffffc0203662:	6161                	addi	sp,sp,80
ffffffffc0203664:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203666:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0203668:	4481                	li	s1,0
ffffffffc020366a:	4901                	li	s2,0
ffffffffc020366c:	b38d                	j	ffffffffc02033ce <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020366e:	00003697          	auipc	a3,0x3
ffffffffc0203672:	afa68693          	addi	a3,a3,-1286 # ffffffffc0206168 <commands+0x1318>
ffffffffc0203676:	00002617          	auipc	a2,0x2
ffffffffc020367a:	02260613          	addi	a2,a2,34 # ffffffffc0205698 <commands+0x848>
ffffffffc020367e:	0f000593          	li	a1,240
ffffffffc0203682:	00003517          	auipc	a0,0x3
ffffffffc0203686:	e3650513          	addi	a0,a0,-458 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020368a:	b3ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020368e:	00003697          	auipc	a3,0x3
ffffffffc0203692:	ea268693          	addi	a3,a3,-350 # ffffffffc0206530 <commands+0x16e0>
ffffffffc0203696:	00002617          	auipc	a2,0x2
ffffffffc020369a:	00260613          	addi	a2,a2,2 # ffffffffc0205698 <commands+0x848>
ffffffffc020369e:	0bd00593          	li	a1,189
ffffffffc02036a2:	00003517          	auipc	a0,0x3
ffffffffc02036a6:	e1650513          	addi	a0,a0,-490 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02036aa:	b1ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02036ae:	00003697          	auipc	a3,0x3
ffffffffc02036b2:	eaa68693          	addi	a3,a3,-342 # ffffffffc0206558 <commands+0x1708>
ffffffffc02036b6:	00002617          	auipc	a2,0x2
ffffffffc02036ba:	fe260613          	addi	a2,a2,-30 # ffffffffc0205698 <commands+0x848>
ffffffffc02036be:	0be00593          	li	a1,190
ffffffffc02036c2:	00003517          	auipc	a0,0x3
ffffffffc02036c6:	df650513          	addi	a0,a0,-522 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02036ca:	afffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02036ce:	00003697          	auipc	a3,0x3
ffffffffc02036d2:	eca68693          	addi	a3,a3,-310 # ffffffffc0206598 <commands+0x1748>
ffffffffc02036d6:	00002617          	auipc	a2,0x2
ffffffffc02036da:	fc260613          	addi	a2,a2,-62 # ffffffffc0205698 <commands+0x848>
ffffffffc02036de:	0c000593          	li	a1,192
ffffffffc02036e2:	00003517          	auipc	a0,0x3
ffffffffc02036e6:	dd650513          	addi	a0,a0,-554 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02036ea:	adffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02036ee:	00003697          	auipc	a3,0x3
ffffffffc02036f2:	f3268693          	addi	a3,a3,-206 # ffffffffc0206620 <commands+0x17d0>
ffffffffc02036f6:	00002617          	auipc	a2,0x2
ffffffffc02036fa:	fa260613          	addi	a2,a2,-94 # ffffffffc0205698 <commands+0x848>
ffffffffc02036fe:	0d900593          	li	a1,217
ffffffffc0203702:	00003517          	auipc	a0,0x3
ffffffffc0203706:	db650513          	addi	a0,a0,-586 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020370a:	abffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020370e:	00003697          	auipc	a3,0x3
ffffffffc0203712:	dc268693          	addi	a3,a3,-574 # ffffffffc02064d0 <commands+0x1680>
ffffffffc0203716:	00002617          	auipc	a2,0x2
ffffffffc020371a:	f8260613          	addi	a2,a2,-126 # ffffffffc0205698 <commands+0x848>
ffffffffc020371e:	0d200593          	li	a1,210
ffffffffc0203722:	00003517          	auipc	a0,0x3
ffffffffc0203726:	d9650513          	addi	a0,a0,-618 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020372a:	a9ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc020372e:	00003697          	auipc	a3,0x3
ffffffffc0203732:	ee268693          	addi	a3,a3,-286 # ffffffffc0206610 <commands+0x17c0>
ffffffffc0203736:	00002617          	auipc	a2,0x2
ffffffffc020373a:	f6260613          	addi	a2,a2,-158 # ffffffffc0205698 <commands+0x848>
ffffffffc020373e:	0d000593          	li	a1,208
ffffffffc0203742:	00003517          	auipc	a0,0x3
ffffffffc0203746:	d7650513          	addi	a0,a0,-650 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020374a:	a7ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020374e:	00003697          	auipc	a3,0x3
ffffffffc0203752:	eaa68693          	addi	a3,a3,-342 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc0203756:	00002617          	auipc	a2,0x2
ffffffffc020375a:	f4260613          	addi	a2,a2,-190 # ffffffffc0205698 <commands+0x848>
ffffffffc020375e:	0cb00593          	li	a1,203
ffffffffc0203762:	00003517          	auipc	a0,0x3
ffffffffc0203766:	d5650513          	addi	a0,a0,-682 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020376a:	a5ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020376e:	00003697          	auipc	a3,0x3
ffffffffc0203772:	e6a68693          	addi	a3,a3,-406 # ffffffffc02065d8 <commands+0x1788>
ffffffffc0203776:	00002617          	auipc	a2,0x2
ffffffffc020377a:	f2260613          	addi	a2,a2,-222 # ffffffffc0205698 <commands+0x848>
ffffffffc020377e:	0c200593          	li	a1,194
ffffffffc0203782:	00003517          	auipc	a0,0x3
ffffffffc0203786:	d3650513          	addi	a0,a0,-714 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020378a:	a3ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc020378e:	00003697          	auipc	a3,0x3
ffffffffc0203792:	eca68693          	addi	a3,a3,-310 # ffffffffc0206658 <commands+0x1808>
ffffffffc0203796:	00002617          	auipc	a2,0x2
ffffffffc020379a:	f0260613          	addi	a2,a2,-254 # ffffffffc0205698 <commands+0x848>
ffffffffc020379e:	0f800593          	li	a1,248
ffffffffc02037a2:	00003517          	auipc	a0,0x3
ffffffffc02037a6:	d1650513          	addi	a0,a0,-746 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02037aa:	a1ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc02037ae:	00003697          	auipc	a3,0x3
ffffffffc02037b2:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0206308 <commands+0x14b8>
ffffffffc02037b6:	00002617          	auipc	a2,0x2
ffffffffc02037ba:	ee260613          	addi	a2,a2,-286 # ffffffffc0205698 <commands+0x848>
ffffffffc02037be:	0df00593          	li	a1,223
ffffffffc02037c2:	00003517          	auipc	a0,0x3
ffffffffc02037c6:	cf650513          	addi	a0,a0,-778 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02037ca:	9fffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02037ce:	00003697          	auipc	a3,0x3
ffffffffc02037d2:	e2a68693          	addi	a3,a3,-470 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc02037d6:	00002617          	auipc	a2,0x2
ffffffffc02037da:	ec260613          	addi	a2,a2,-318 # ffffffffc0205698 <commands+0x848>
ffffffffc02037de:	0dd00593          	li	a1,221
ffffffffc02037e2:	00003517          	auipc	a0,0x3
ffffffffc02037e6:	cd650513          	addi	a0,a0,-810 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02037ea:	9dffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02037ee:	00003697          	auipc	a3,0x3
ffffffffc02037f2:	e4a68693          	addi	a3,a3,-438 # ffffffffc0206638 <commands+0x17e8>
ffffffffc02037f6:	00002617          	auipc	a2,0x2
ffffffffc02037fa:	ea260613          	addi	a2,a2,-350 # ffffffffc0205698 <commands+0x848>
ffffffffc02037fe:	0dc00593          	li	a1,220
ffffffffc0203802:	00003517          	auipc	a0,0x3
ffffffffc0203806:	cb650513          	addi	a0,a0,-842 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020380a:	9bffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020380e:	00003697          	auipc	a3,0x3
ffffffffc0203812:	cc268693          	addi	a3,a3,-830 # ffffffffc02064d0 <commands+0x1680>
ffffffffc0203816:	00002617          	auipc	a2,0x2
ffffffffc020381a:	e8260613          	addi	a2,a2,-382 # ffffffffc0205698 <commands+0x848>
ffffffffc020381e:	0b900593          	li	a1,185
ffffffffc0203822:	00003517          	auipc	a0,0x3
ffffffffc0203826:	c9650513          	addi	a0,a0,-874 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020382a:	99ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020382e:	00003697          	auipc	a3,0x3
ffffffffc0203832:	dca68693          	addi	a3,a3,-566 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc0203836:	00002617          	auipc	a2,0x2
ffffffffc020383a:	e6260613          	addi	a2,a2,-414 # ffffffffc0205698 <commands+0x848>
ffffffffc020383e:	0d600593          	li	a1,214
ffffffffc0203842:	00003517          	auipc	a0,0x3
ffffffffc0203846:	c7650513          	addi	a0,a0,-906 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020384a:	97ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020384e:	00003697          	auipc	a3,0x3
ffffffffc0203852:	cc268693          	addi	a3,a3,-830 # ffffffffc0206510 <commands+0x16c0>
ffffffffc0203856:	00002617          	auipc	a2,0x2
ffffffffc020385a:	e4260613          	addi	a2,a2,-446 # ffffffffc0205698 <commands+0x848>
ffffffffc020385e:	0d400593          	li	a1,212
ffffffffc0203862:	00003517          	auipc	a0,0x3
ffffffffc0203866:	c5650513          	addi	a0,a0,-938 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020386a:	95ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020386e:	00003697          	auipc	a3,0x3
ffffffffc0203872:	c8268693          	addi	a3,a3,-894 # ffffffffc02064f0 <commands+0x16a0>
ffffffffc0203876:	00002617          	auipc	a2,0x2
ffffffffc020387a:	e2260613          	addi	a2,a2,-478 # ffffffffc0205698 <commands+0x848>
ffffffffc020387e:	0d300593          	li	a1,211
ffffffffc0203882:	00003517          	auipc	a0,0x3
ffffffffc0203886:	c3650513          	addi	a0,a0,-970 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020388a:	93ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020388e:	00003697          	auipc	a3,0x3
ffffffffc0203892:	c8268693          	addi	a3,a3,-894 # ffffffffc0206510 <commands+0x16c0>
ffffffffc0203896:	00002617          	auipc	a2,0x2
ffffffffc020389a:	e0260613          	addi	a2,a2,-510 # ffffffffc0205698 <commands+0x848>
ffffffffc020389e:	0bb00593          	li	a1,187
ffffffffc02038a2:	00003517          	auipc	a0,0x3
ffffffffc02038a6:	c1650513          	addi	a0,a0,-1002 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02038aa:	91ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc02038ae:	00003697          	auipc	a3,0x3
ffffffffc02038b2:	efa68693          	addi	a3,a3,-262 # ffffffffc02067a8 <commands+0x1958>
ffffffffc02038b6:	00002617          	auipc	a2,0x2
ffffffffc02038ba:	de260613          	addi	a2,a2,-542 # ffffffffc0205698 <commands+0x848>
ffffffffc02038be:	12500593          	li	a1,293
ffffffffc02038c2:	00003517          	auipc	a0,0x3
ffffffffc02038c6:	bf650513          	addi	a0,a0,-1034 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02038ca:	8fffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc02038ce:	00003697          	auipc	a3,0x3
ffffffffc02038d2:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0206308 <commands+0x14b8>
ffffffffc02038d6:	00002617          	auipc	a2,0x2
ffffffffc02038da:	dc260613          	addi	a2,a2,-574 # ffffffffc0205698 <commands+0x848>
ffffffffc02038de:	11a00593          	li	a1,282
ffffffffc02038e2:	00003517          	auipc	a0,0x3
ffffffffc02038e6:	bd650513          	addi	a0,a0,-1066 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02038ea:	8dffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02038ee:	00003697          	auipc	a3,0x3
ffffffffc02038f2:	d0a68693          	addi	a3,a3,-758 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc02038f6:	00002617          	auipc	a2,0x2
ffffffffc02038fa:	da260613          	addi	a2,a2,-606 # ffffffffc0205698 <commands+0x848>
ffffffffc02038fe:	11800593          	li	a1,280
ffffffffc0203902:	00003517          	auipc	a0,0x3
ffffffffc0203906:	bb650513          	addi	a0,a0,-1098 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020390a:	8bffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020390e:	00003697          	auipc	a3,0x3
ffffffffc0203912:	caa68693          	addi	a3,a3,-854 # ffffffffc02065b8 <commands+0x1768>
ffffffffc0203916:	00002617          	auipc	a2,0x2
ffffffffc020391a:	d8260613          	addi	a2,a2,-638 # ffffffffc0205698 <commands+0x848>
ffffffffc020391e:	0c100593          	li	a1,193
ffffffffc0203922:	00003517          	auipc	a0,0x3
ffffffffc0203926:	b9650513          	addi	a0,a0,-1130 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020392a:	89ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020392e:	00003697          	auipc	a3,0x3
ffffffffc0203932:	e3a68693          	addi	a3,a3,-454 # ffffffffc0206768 <commands+0x1918>
ffffffffc0203936:	00002617          	auipc	a2,0x2
ffffffffc020393a:	d6260613          	addi	a2,a2,-670 # ffffffffc0205698 <commands+0x848>
ffffffffc020393e:	11200593          	li	a1,274
ffffffffc0203942:	00003517          	auipc	a0,0x3
ffffffffc0203946:	b7650513          	addi	a0,a0,-1162 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020394a:	87ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020394e:	00003697          	auipc	a3,0x3
ffffffffc0203952:	dfa68693          	addi	a3,a3,-518 # ffffffffc0206748 <commands+0x18f8>
ffffffffc0203956:	00002617          	auipc	a2,0x2
ffffffffc020395a:	d4260613          	addi	a2,a2,-702 # ffffffffc0205698 <commands+0x848>
ffffffffc020395e:	11000593          	li	a1,272
ffffffffc0203962:	00003517          	auipc	a0,0x3
ffffffffc0203966:	b5650513          	addi	a0,a0,-1194 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020396a:	85ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020396e:	00003697          	auipc	a3,0x3
ffffffffc0203972:	db268693          	addi	a3,a3,-590 # ffffffffc0206720 <commands+0x18d0>
ffffffffc0203976:	00002617          	auipc	a2,0x2
ffffffffc020397a:	d2260613          	addi	a2,a2,-734 # ffffffffc0205698 <commands+0x848>
ffffffffc020397e:	10e00593          	li	a1,270
ffffffffc0203982:	00003517          	auipc	a0,0x3
ffffffffc0203986:	b3650513          	addi	a0,a0,-1226 # ffffffffc02064b8 <commands+0x1668>
ffffffffc020398a:	83ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020398e:	00003697          	auipc	a3,0x3
ffffffffc0203992:	d6a68693          	addi	a3,a3,-662 # ffffffffc02066f8 <commands+0x18a8>
ffffffffc0203996:	00002617          	auipc	a2,0x2
ffffffffc020399a:	d0260613          	addi	a2,a2,-766 # ffffffffc0205698 <commands+0x848>
ffffffffc020399e:	10d00593          	li	a1,269
ffffffffc02039a2:	00003517          	auipc	a0,0x3
ffffffffc02039a6:	b1650513          	addi	a0,a0,-1258 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02039aa:	81ffc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02039ae:	00003697          	auipc	a3,0x3
ffffffffc02039b2:	d3a68693          	addi	a3,a3,-710 # ffffffffc02066e8 <commands+0x1898>
ffffffffc02039b6:	00002617          	auipc	a2,0x2
ffffffffc02039ba:	ce260613          	addi	a2,a2,-798 # ffffffffc0205698 <commands+0x848>
ffffffffc02039be:	10800593          	li	a1,264
ffffffffc02039c2:	00003517          	auipc	a0,0x3
ffffffffc02039c6:	af650513          	addi	a0,a0,-1290 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02039ca:	ffefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02039ce:	00003697          	auipc	a3,0x3
ffffffffc02039d2:	c2a68693          	addi	a3,a3,-982 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc02039d6:	00002617          	auipc	a2,0x2
ffffffffc02039da:	cc260613          	addi	a2,a2,-830 # ffffffffc0205698 <commands+0x848>
ffffffffc02039de:	10700593          	li	a1,263
ffffffffc02039e2:	00003517          	auipc	a0,0x3
ffffffffc02039e6:	ad650513          	addi	a0,a0,-1322 # ffffffffc02064b8 <commands+0x1668>
ffffffffc02039ea:	fdefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02039ee:	00003697          	auipc	a3,0x3
ffffffffc02039f2:	cda68693          	addi	a3,a3,-806 # ffffffffc02066c8 <commands+0x1878>
ffffffffc02039f6:	00002617          	auipc	a2,0x2
ffffffffc02039fa:	ca260613          	addi	a2,a2,-862 # ffffffffc0205698 <commands+0x848>
ffffffffc02039fe:	10600593          	li	a1,262
ffffffffc0203a02:	00003517          	auipc	a0,0x3
ffffffffc0203a06:	ab650513          	addi	a0,a0,-1354 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203a0a:	fbefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0203a0e:	00003697          	auipc	a3,0x3
ffffffffc0203a12:	c8a68693          	addi	a3,a3,-886 # ffffffffc0206698 <commands+0x1848>
ffffffffc0203a16:	00002617          	auipc	a2,0x2
ffffffffc0203a1a:	c8260613          	addi	a2,a2,-894 # ffffffffc0205698 <commands+0x848>
ffffffffc0203a1e:	10500593          	li	a1,261
ffffffffc0203a22:	00003517          	auipc	a0,0x3
ffffffffc0203a26:	a9650513          	addi	a0,a0,-1386 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203a2a:	f9efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0203a2e:	00003697          	auipc	a3,0x3
ffffffffc0203a32:	c5268693          	addi	a3,a3,-942 # ffffffffc0206680 <commands+0x1830>
ffffffffc0203a36:	00002617          	auipc	a2,0x2
ffffffffc0203a3a:	c6260613          	addi	a2,a2,-926 # ffffffffc0205698 <commands+0x848>
ffffffffc0203a3e:	10400593          	li	a1,260
ffffffffc0203a42:	00003517          	auipc	a0,0x3
ffffffffc0203a46:	a7650513          	addi	a0,a0,-1418 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203a4a:	f7efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0203a4e:	00003697          	auipc	a3,0x3
ffffffffc0203a52:	baa68693          	addi	a3,a3,-1110 # ffffffffc02065f8 <commands+0x17a8>
ffffffffc0203a56:	00002617          	auipc	a2,0x2
ffffffffc0203a5a:	c4260613          	addi	a2,a2,-958 # ffffffffc0205698 <commands+0x848>
ffffffffc0203a5e:	0fe00593          	li	a1,254
ffffffffc0203a62:	00003517          	auipc	a0,0x3
ffffffffc0203a66:	a5650513          	addi	a0,a0,-1450 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203a6a:	f5efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0203a6e:	00003697          	auipc	a3,0x3
ffffffffc0203a72:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0206668 <commands+0x1818>
ffffffffc0203a76:	00002617          	auipc	a2,0x2
ffffffffc0203a7a:	c2260613          	addi	a2,a2,-990 # ffffffffc0205698 <commands+0x848>
ffffffffc0203a7e:	0f900593          	li	a1,249
ffffffffc0203a82:	00003517          	auipc	a0,0x3
ffffffffc0203a86:	a3650513          	addi	a0,a0,-1482 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203a8a:	f3efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0203a8e:	00003697          	auipc	a3,0x3
ffffffffc0203a92:	cfa68693          	addi	a3,a3,-774 # ffffffffc0206788 <commands+0x1938>
ffffffffc0203a96:	00002617          	auipc	a2,0x2
ffffffffc0203a9a:	c0260613          	addi	a2,a2,-1022 # ffffffffc0205698 <commands+0x848>
ffffffffc0203a9e:	11700593          	li	a1,279
ffffffffc0203aa2:	00003517          	auipc	a0,0x3
ffffffffc0203aa6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203aaa:	f1efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc0203aae:	00003697          	auipc	a3,0x3
ffffffffc0203ab2:	d0a68693          	addi	a3,a3,-758 # ffffffffc02067b8 <commands+0x1968>
ffffffffc0203ab6:	00002617          	auipc	a2,0x2
ffffffffc0203aba:	be260613          	addi	a2,a2,-1054 # ffffffffc0205698 <commands+0x848>
ffffffffc0203abe:	12600593          	li	a1,294
ffffffffc0203ac2:	00003517          	auipc	a0,0x3
ffffffffc0203ac6:	9f650513          	addi	a0,a0,-1546 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203aca:	efefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0203ace:	00002697          	auipc	a3,0x2
ffffffffc0203ad2:	6aa68693          	addi	a3,a3,1706 # ffffffffc0206178 <commands+0x1328>
ffffffffc0203ad6:	00002617          	auipc	a2,0x2
ffffffffc0203ada:	bc260613          	addi	a2,a2,-1086 # ffffffffc0205698 <commands+0x848>
ffffffffc0203ade:	0f300593          	li	a1,243
ffffffffc0203ae2:	00003517          	auipc	a0,0x3
ffffffffc0203ae6:	9d650513          	addi	a0,a0,-1578 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203aea:	edefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0203aee:	00003697          	auipc	a3,0x3
ffffffffc0203af2:	a0268693          	addi	a3,a3,-1534 # ffffffffc02064f0 <commands+0x16a0>
ffffffffc0203af6:	00002617          	auipc	a2,0x2
ffffffffc0203afa:	ba260613          	addi	a2,a2,-1118 # ffffffffc0205698 <commands+0x848>
ffffffffc0203afe:	0ba00593          	li	a1,186
ffffffffc0203b02:	00003517          	auipc	a0,0x3
ffffffffc0203b06:	9b650513          	addi	a0,a0,-1610 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203b0a:	ebefc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203b0e <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0203b0e:	1141                	addi	sp,sp,-16
ffffffffc0203b10:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203b12:	12058f63          	beqz	a1,ffffffffc0203c50 <default_free_pages+0x142>
    for (; p != base + n; p ++) {
ffffffffc0203b16:	00659693          	slli	a3,a1,0x6
ffffffffc0203b1a:	96aa                	add	a3,a3,a0
ffffffffc0203b1c:	87aa                	mv	a5,a0
ffffffffc0203b1e:	02d50263          	beq	a0,a3,ffffffffc0203b42 <default_free_pages+0x34>
ffffffffc0203b22:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203b24:	8b05                	andi	a4,a4,1
ffffffffc0203b26:	10071563          	bnez	a4,ffffffffc0203c30 <default_free_pages+0x122>
ffffffffc0203b2a:	6798                	ld	a4,8(a5)
ffffffffc0203b2c:	8b09                	andi	a4,a4,2
ffffffffc0203b2e:	10071163          	bnez	a4,ffffffffc0203c30 <default_free_pages+0x122>
        p->flags = 0;
ffffffffc0203b32:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0203b36:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203b3a:	04078793          	addi	a5,a5,64
ffffffffc0203b3e:	fed792e3          	bne	a5,a3,ffffffffc0203b22 <default_free_pages+0x14>
    base->property = n;
ffffffffc0203b42:	2581                	sext.w	a1,a1
ffffffffc0203b44:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0203b46:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203b4a:	4789                	li	a5,2
ffffffffc0203b4c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0203b50:	00012697          	auipc	a3,0x12
ffffffffc0203b54:	a8868693          	addi	a3,a3,-1400 # ffffffffc02155d8 <free_area>
ffffffffc0203b58:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203b5a:	669c                	ld	a5,8(a3)
ffffffffc0203b5c:	01850613          	addi	a2,a0,24
ffffffffc0203b60:	9db9                	addw	a1,a1,a4
ffffffffc0203b62:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203b64:	08d78f63          	beq	a5,a3,ffffffffc0203c02 <default_free_pages+0xf4>
            struct Page* page = le2page(le, page_link);
ffffffffc0203b68:	fe878713          	addi	a4,a5,-24
ffffffffc0203b6c:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203b70:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203b72:	00e56a63          	bltu	a0,a4,ffffffffc0203b86 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0203b76:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203b78:	04d70a63          	beq	a4,a3,ffffffffc0203bcc <default_free_pages+0xbe>
    for (; p != base + n; p ++) {
ffffffffc0203b7c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203b7e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203b82:	fee57ae3          	bgeu	a0,a4,ffffffffc0203b76 <default_free_pages+0x68>
ffffffffc0203b86:	c199                	beqz	a1,ffffffffc0203b8c <default_free_pages+0x7e>
ffffffffc0203b88:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203b8c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203b8e:	e390                	sd	a2,0(a5)
ffffffffc0203b90:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203b92:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203b94:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0203b96:	00d70c63          	beq	a4,a3,ffffffffc0203bae <default_free_pages+0xa0>
        if (p + p->property == base) {
ffffffffc0203b9a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0203b9e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0203ba2:	02059793          	slli	a5,a1,0x20
ffffffffc0203ba6:	83e9                	srli	a5,a5,0x1a
ffffffffc0203ba8:	97b2                	add	a5,a5,a2
ffffffffc0203baa:	02f50b63          	beq	a0,a5,ffffffffc0203be0 <default_free_pages+0xd2>
ffffffffc0203bae:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0203bb0:	00d70b63          	beq	a4,a3,ffffffffc0203bc6 <default_free_pages+0xb8>
        if (base + base->property == p) {
ffffffffc0203bb4:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0203bb6:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0203bba:	02061793          	slli	a5,a2,0x20
ffffffffc0203bbe:	83e9                	srli	a5,a5,0x1a
ffffffffc0203bc0:	97aa                	add	a5,a5,a0
ffffffffc0203bc2:	04f68763          	beq	a3,a5,ffffffffc0203c10 <default_free_pages+0x102>
}
ffffffffc0203bc6:	60a2                	ld	ra,8(sp)
ffffffffc0203bc8:	0141                	addi	sp,sp,16
ffffffffc0203bca:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203bcc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203bce:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203bd0:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203bd2:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203bd4:	02d70463          	beq	a4,a3,ffffffffc0203bfc <default_free_pages+0xee>
    prev->next = next->prev = elm;
ffffffffc0203bd8:	8832                	mv	a6,a2
ffffffffc0203bda:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203bdc:	87ba                	mv	a5,a4
ffffffffc0203bde:	b745                	j	ffffffffc0203b7e <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0203be0:	491c                	lw	a5,16(a0)
ffffffffc0203be2:	9dbd                	addw	a1,a1,a5
ffffffffc0203be4:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203be8:	57f5                	li	a5,-3
ffffffffc0203bea:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203bee:	6d0c                	ld	a1,24(a0)
ffffffffc0203bf0:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0203bf2:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0203bf4:	e59c                	sd	a5,8(a1)
    next->prev = prev;
ffffffffc0203bf6:	6718                	ld	a4,8(a4)
ffffffffc0203bf8:	e38c                	sd	a1,0(a5)
ffffffffc0203bfa:	bf5d                	j	ffffffffc0203bb0 <default_free_pages+0xa2>
ffffffffc0203bfc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203bfe:	873e                	mv	a4,a5
ffffffffc0203c00:	bf69                	j	ffffffffc0203b9a <default_free_pages+0x8c>
}
ffffffffc0203c02:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203c04:	e390                	sd	a2,0(a5)
ffffffffc0203c06:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203c08:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203c0a:	ed1c                	sd	a5,24(a0)
ffffffffc0203c0c:	0141                	addi	sp,sp,16
ffffffffc0203c0e:	8082                	ret
            base->property += p->property;
ffffffffc0203c10:	ff872783          	lw	a5,-8(a4)
ffffffffc0203c14:	ff070693          	addi	a3,a4,-16
ffffffffc0203c18:	9e3d                	addw	a2,a2,a5
ffffffffc0203c1a:	c910                	sw	a2,16(a0)
ffffffffc0203c1c:	57f5                	li	a5,-3
ffffffffc0203c1e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203c22:	6314                	ld	a3,0(a4)
ffffffffc0203c24:	671c                	ld	a5,8(a4)
}
ffffffffc0203c26:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0203c28:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0203c2a:	e394                	sd	a3,0(a5)
ffffffffc0203c2c:	0141                	addi	sp,sp,16
ffffffffc0203c2e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0203c30:	00003697          	auipc	a3,0x3
ffffffffc0203c34:	ba068693          	addi	a3,a3,-1120 # ffffffffc02067d0 <commands+0x1980>
ffffffffc0203c38:	00002617          	auipc	a2,0x2
ffffffffc0203c3c:	a6060613          	addi	a2,a2,-1440 # ffffffffc0205698 <commands+0x848>
ffffffffc0203c40:	08300593          	li	a1,131
ffffffffc0203c44:	00003517          	auipc	a0,0x3
ffffffffc0203c48:	87450513          	addi	a0,a0,-1932 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203c4c:	d7cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0203c50:	00003697          	auipc	a3,0x3
ffffffffc0203c54:	b7868693          	addi	a3,a3,-1160 # ffffffffc02067c8 <commands+0x1978>
ffffffffc0203c58:	00002617          	auipc	a2,0x2
ffffffffc0203c5c:	a4060613          	addi	a2,a2,-1472 # ffffffffc0205698 <commands+0x848>
ffffffffc0203c60:	08000593          	li	a1,128
ffffffffc0203c64:	00003517          	auipc	a0,0x3
ffffffffc0203c68:	85450513          	addi	a0,a0,-1964 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203c6c:	d5cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203c70 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0203c70:	c941                	beqz	a0,ffffffffc0203d00 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0203c72:	00012597          	auipc	a1,0x12
ffffffffc0203c76:	96658593          	addi	a1,a1,-1690 # ffffffffc02155d8 <free_area>
ffffffffc0203c7a:	0105a803          	lw	a6,16(a1)
ffffffffc0203c7e:	872a                	mv	a4,a0
ffffffffc0203c80:	02081793          	slli	a5,a6,0x20
ffffffffc0203c84:	9381                	srli	a5,a5,0x20
ffffffffc0203c86:	00a7ee63          	bltu	a5,a0,ffffffffc0203ca2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0203c8a:	87ae                	mv	a5,a1
ffffffffc0203c8c:	a801                	j	ffffffffc0203c9c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0203c8e:	ff87a683          	lw	a3,-8(a5)
ffffffffc0203c92:	02069613          	slli	a2,a3,0x20
ffffffffc0203c96:	9201                	srli	a2,a2,0x20
ffffffffc0203c98:	00e67763          	bgeu	a2,a4,ffffffffc0203ca6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0203c9c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0203c9e:	feb798e3          	bne	a5,a1,ffffffffc0203c8e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0203ca2:	4501                	li	a0,0
}
ffffffffc0203ca4:	8082                	ret
    return listelm->prev;
ffffffffc0203ca6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0203caa:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0203cae:	fe878513          	addi	a0,a5,-24
    prev->next = next;
ffffffffc0203cb2:	00070e1b          	sext.w	t3,a4
ffffffffc0203cb6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0203cba:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0203cbe:	02c77863          	bgeu	a4,a2,ffffffffc0203cee <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0203cc2:	071a                	slli	a4,a4,0x6
ffffffffc0203cc4:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0203cc6:	41c686bb          	subw	a3,a3,t3
ffffffffc0203cca:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203ccc:	00870613          	addi	a2,a4,8
ffffffffc0203cd0:	4689                	li	a3,2
ffffffffc0203cd2:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0203cd6:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0203cda:	01870613          	addi	a2,a4,24
    prev->next = next->prev = elm;
ffffffffc0203cde:	0105a803          	lw	a6,16(a1)
ffffffffc0203ce2:	e290                	sd	a2,0(a3)
ffffffffc0203ce4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0203ce8:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0203cea:	01173c23          	sd	a7,24(a4)
        nr_free -= n;
ffffffffc0203cee:	41c8083b          	subw	a6,a6,t3
ffffffffc0203cf2:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0203cf6:	5775                	li	a4,-3
ffffffffc0203cf8:	17c1                	addi	a5,a5,-16
ffffffffc0203cfa:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0203cfe:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0203d00:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0203d02:	00003697          	auipc	a3,0x3
ffffffffc0203d06:	ac668693          	addi	a3,a3,-1338 # ffffffffc02067c8 <commands+0x1978>
ffffffffc0203d0a:	00002617          	auipc	a2,0x2
ffffffffc0203d0e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0205698 <commands+0x848>
ffffffffc0203d12:	06200593          	li	a1,98
ffffffffc0203d16:	00002517          	auipc	a0,0x2
ffffffffc0203d1a:	7a250513          	addi	a0,a0,1954 # ffffffffc02064b8 <commands+0x1668>
default_alloc_pages(size_t n) {
ffffffffc0203d1e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203d20:	ca8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203d24 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0203d24:	1141                	addi	sp,sp,-16
ffffffffc0203d26:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0203d28:	c5f1                	beqz	a1,ffffffffc0203df4 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0203d2a:	00659693          	slli	a3,a1,0x6
ffffffffc0203d2e:	96aa                	add	a3,a3,a0
ffffffffc0203d30:	87aa                	mv	a5,a0
ffffffffc0203d32:	00d50f63          	beq	a0,a3,ffffffffc0203d50 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0203d36:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0203d38:	8b05                	andi	a4,a4,1
ffffffffc0203d3a:	cf49                	beqz	a4,ffffffffc0203dd4 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0203d3c:	0007a823          	sw	zero,16(a5)
ffffffffc0203d40:	0007b423          	sd	zero,8(a5)
ffffffffc0203d44:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0203d48:	04078793          	addi	a5,a5,64
ffffffffc0203d4c:	fed795e3          	bne	a5,a3,ffffffffc0203d36 <default_init_memmap+0x12>
    base->property = n;
ffffffffc0203d50:	2581                	sext.w	a1,a1
ffffffffc0203d52:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0203d54:	4789                	li	a5,2
ffffffffc0203d56:	00850713          	addi	a4,a0,8
ffffffffc0203d5a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0203d5e:	00012697          	auipc	a3,0x12
ffffffffc0203d62:	87a68693          	addi	a3,a3,-1926 # ffffffffc02155d8 <free_area>
ffffffffc0203d66:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0203d68:	669c                	ld	a5,8(a3)
ffffffffc0203d6a:	01850613          	addi	a2,a0,24
ffffffffc0203d6e:	9db9                	addw	a1,a1,a4
ffffffffc0203d70:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0203d72:	04d78a63          	beq	a5,a3,ffffffffc0203dc6 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0203d76:	fe878713          	addi	a4,a5,-24
ffffffffc0203d7a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0203d7e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0203d80:	00e56a63          	bltu	a0,a4,ffffffffc0203d94 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0203d84:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0203d86:	02d70263          	beq	a4,a3,ffffffffc0203daa <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0203d8a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0203d8c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0203d90:	fee57ae3          	bgeu	a0,a4,ffffffffc0203d84 <default_init_memmap+0x60>
ffffffffc0203d94:	c199                	beqz	a1,ffffffffc0203d9a <default_init_memmap+0x76>
ffffffffc0203d96:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203d9a:	6398                	ld	a4,0(a5)
}
ffffffffc0203d9c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0203d9e:	e390                	sd	a2,0(a5)
ffffffffc0203da0:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0203da2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203da4:	ed18                	sd	a4,24(a0)
ffffffffc0203da6:	0141                	addi	sp,sp,16
ffffffffc0203da8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0203daa:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203dac:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0203dae:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0203db0:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0203db2:	00d70663          	beq	a4,a3,ffffffffc0203dbe <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0203db6:	8832                	mv	a6,a2
ffffffffc0203db8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0203dba:	87ba                	mv	a5,a4
ffffffffc0203dbc:	bfc1                	j	ffffffffc0203d8c <default_init_memmap+0x68>
}
ffffffffc0203dbe:	60a2                	ld	ra,8(sp)
ffffffffc0203dc0:	e290                	sd	a2,0(a3)
ffffffffc0203dc2:	0141                	addi	sp,sp,16
ffffffffc0203dc4:	8082                	ret
ffffffffc0203dc6:	60a2                	ld	ra,8(sp)
ffffffffc0203dc8:	e390                	sd	a2,0(a5)
ffffffffc0203dca:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0203dcc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0203dce:	ed1c                	sd	a5,24(a0)
ffffffffc0203dd0:	0141                	addi	sp,sp,16
ffffffffc0203dd2:	8082                	ret
        assert(PageReserved(p));
ffffffffc0203dd4:	00003697          	auipc	a3,0x3
ffffffffc0203dd8:	a2468693          	addi	a3,a3,-1500 # ffffffffc02067f8 <commands+0x19a8>
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0205698 <commands+0x848>
ffffffffc0203de4:	04900593          	li	a1,73
ffffffffc0203de8:	00002517          	auipc	a0,0x2
ffffffffc0203dec:	6d050513          	addi	a0,a0,1744 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203df0:	bd8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0203df4:	00003697          	auipc	a3,0x3
ffffffffc0203df8:	9d468693          	addi	a3,a3,-1580 # ffffffffc02067c8 <commands+0x1978>
ffffffffc0203dfc:	00002617          	auipc	a2,0x2
ffffffffc0203e00:	89c60613          	addi	a2,a2,-1892 # ffffffffc0205698 <commands+0x848>
ffffffffc0203e04:	04600593          	li	a1,70
ffffffffc0203e08:	00002517          	auipc	a0,0x2
ffffffffc0203e0c:	6b050513          	addi	a0,a0,1712 # ffffffffc02064b8 <commands+0x1668>
ffffffffc0203e10:	bb8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203e14 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e14:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e16:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e18:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e1a:	e84fc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203e1e:	cd01                	beqz	a0,ffffffffc0203e36 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e20:	4505                	li	a0,1
ffffffffc0203e22:	e82fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203e26:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e28:	810d                	srli	a0,a0,0x3
ffffffffc0203e2a:	00011797          	auipc	a5,0x11
ffffffffc0203e2e:	76a7b723          	sd	a0,1902(a5) # ffffffffc0215598 <max_swap_offset>
}
ffffffffc0203e32:	0141                	addi	sp,sp,16
ffffffffc0203e34:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e36:	00003617          	auipc	a2,0x3
ffffffffc0203e3a:	a2260613          	addi	a2,a2,-1502 # ffffffffc0206858 <default_pmm_manager+0x38>
ffffffffc0203e3e:	45b5                	li	a1,13
ffffffffc0203e40:	00003517          	auipc	a0,0x3
ffffffffc0203e44:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206878 <default_pmm_manager+0x58>
ffffffffc0203e48:	b80fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203e4c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e4c:	1141                	addi	sp,sp,-16
ffffffffc0203e4e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e50:	00855793          	srli	a5,a0,0x8
ffffffffc0203e54:	cbb1                	beqz	a5,ffffffffc0203ea8 <swapfs_read+0x5c>
ffffffffc0203e56:	00011717          	auipc	a4,0x11
ffffffffc0203e5a:	74273703          	ld	a4,1858(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc0203e5e:	04e7f563          	bgeu	a5,a4,ffffffffc0203ea8 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0203e62:	00011617          	auipc	a2,0x11
ffffffffc0203e66:	68e63603          	ld	a2,1678(a2) # ffffffffc02154f0 <pages>
ffffffffc0203e6a:	8d91                	sub	a1,a1,a2
ffffffffc0203e6c:	4065d613          	srai	a2,a1,0x6
ffffffffc0203e70:	00003717          	auipc	a4,0x3
ffffffffc0203e74:	e3873703          	ld	a4,-456(a4) # ffffffffc0206ca8 <nbase>
ffffffffc0203e78:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203e7a:	00c61713          	slli	a4,a2,0xc
ffffffffc0203e7e:	8331                	srli	a4,a4,0xc
ffffffffc0203e80:	00011697          	auipc	a3,0x11
ffffffffc0203e84:	6086b683          	ld	a3,1544(a3) # ffffffffc0215488 <npage>
ffffffffc0203e88:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203e8c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203e8e:	02d77963          	bgeu	a4,a3,ffffffffc0203ec0 <swapfs_read+0x74>
}
ffffffffc0203e92:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e94:	00011797          	auipc	a5,0x11
ffffffffc0203e98:	64c7b783          	ld	a5,1612(a5) # ffffffffc02154e0 <va_pa_offset>
ffffffffc0203e9c:	46a1                	li	a3,8
ffffffffc0203e9e:	963e                	add	a2,a2,a5
ffffffffc0203ea0:	4505                	li	a0,1
}
ffffffffc0203ea2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ea4:	e06fc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203ea8:	86aa                	mv	a3,a0
ffffffffc0203eaa:	00003617          	auipc	a2,0x3
ffffffffc0203eae:	9e660613          	addi	a2,a2,-1562 # ffffffffc0206890 <default_pmm_manager+0x70>
ffffffffc0203eb2:	45d1                	li	a1,20
ffffffffc0203eb4:	00003517          	auipc	a0,0x3
ffffffffc0203eb8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0206878 <default_pmm_manager+0x58>
ffffffffc0203ebc:	b0cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203ec0:	86b2                	mv	a3,a2
ffffffffc0203ec2:	06900593          	li	a1,105
ffffffffc0203ec6:	00001617          	auipc	a2,0x1
ffffffffc0203eca:	6c260613          	addi	a2,a2,1730 # ffffffffc0205588 <commands+0x738>
ffffffffc0203ece:	00001517          	auipc	a0,0x1
ffffffffc0203ed2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205578 <commands+0x728>
ffffffffc0203ed6:	af2fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203eda <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203eda:	1141                	addi	sp,sp,-16
ffffffffc0203edc:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ede:	00855793          	srli	a5,a0,0x8
ffffffffc0203ee2:	cbb1                	beqz	a5,ffffffffc0203f36 <swapfs_write+0x5c>
ffffffffc0203ee4:	00011717          	auipc	a4,0x11
ffffffffc0203ee8:	6b473703          	ld	a4,1716(a4) # ffffffffc0215598 <max_swap_offset>
ffffffffc0203eec:	04e7f563          	bgeu	a5,a4,ffffffffc0203f36 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0203ef0:	00011617          	auipc	a2,0x11
ffffffffc0203ef4:	60063603          	ld	a2,1536(a2) # ffffffffc02154f0 <pages>
ffffffffc0203ef8:	8d91                	sub	a1,a1,a2
ffffffffc0203efa:	4065d613          	srai	a2,a1,0x6
ffffffffc0203efe:	00003717          	auipc	a4,0x3
ffffffffc0203f02:	daa73703          	ld	a4,-598(a4) # ffffffffc0206ca8 <nbase>
ffffffffc0203f06:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0203f08:	00c61713          	slli	a4,a2,0xc
ffffffffc0203f0c:	8331                	srli	a4,a4,0xc
ffffffffc0203f0e:	00011697          	auipc	a3,0x11
ffffffffc0203f12:	57a6b683          	ld	a3,1402(a3) # ffffffffc0215488 <npage>
ffffffffc0203f16:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f1a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0203f1c:	02d77963          	bgeu	a4,a3,ffffffffc0203f4e <swapfs_write+0x74>
}
ffffffffc0203f20:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f22:	00011797          	auipc	a5,0x11
ffffffffc0203f26:	5be7b783          	ld	a5,1470(a5) # ffffffffc02154e0 <va_pa_offset>
ffffffffc0203f2a:	46a1                	li	a3,8
ffffffffc0203f2c:	963e                	add	a2,a2,a5
ffffffffc0203f2e:	4505                	li	a0,1
}
ffffffffc0203f30:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f32:	d9cfc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203f36:	86aa                	mv	a3,a0
ffffffffc0203f38:	00003617          	auipc	a2,0x3
ffffffffc0203f3c:	95860613          	addi	a2,a2,-1704 # ffffffffc0206890 <default_pmm_manager+0x70>
ffffffffc0203f40:	45e5                	li	a1,25
ffffffffc0203f42:	00003517          	auipc	a0,0x3
ffffffffc0203f46:	93650513          	addi	a0,a0,-1738 # ffffffffc0206878 <default_pmm_manager+0x58>
ffffffffc0203f4a:	a7efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203f4e:	86b2                	mv	a3,a2
ffffffffc0203f50:	06900593          	li	a1,105
ffffffffc0203f54:	00001617          	auipc	a2,0x1
ffffffffc0203f58:	63460613          	addi	a2,a2,1588 # ffffffffc0205588 <commands+0x738>
ffffffffc0203f5c:	00001517          	auipc	a0,0x1
ffffffffc0203f60:	61c50513          	addi	a0,a0,1564 # ffffffffc0205578 <commands+0x728>
ffffffffc0203f64:	a64fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203f68 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203f68:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203f6a:	9402                	jalr	s0

	jal do_exit
ffffffffc0203f6c:	4b4000ef          	jal	ra,ffffffffc0204420 <do_exit>

ffffffffc0203f70 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203f70:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203f74:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203f78:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203f7a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203f7c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203f80:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203f84:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203f88:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203f8c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203f90:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203f94:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203f98:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203f9c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203fa0:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203fa4:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203fa8:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203fac:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203fae:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203fb0:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203fb4:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203fb8:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203fbc:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203fc0:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203fc4:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203fc8:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203fcc:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203fd0:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203fd4:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203fd8:	8082                	ret

ffffffffc0203fda <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0203fda:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fdc:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0203fe0:	e022                	sd	s0,0(sp)
ffffffffc0203fe2:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fe4:	903fe0ef          	jal	ra,ffffffffc02028e6 <kmalloc>
ffffffffc0203fe8:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0203fea:	c521                	beqz	a0,ffffffffc0204032 <alloc_proc+0x58>
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */

    proc->state = PROC_UNINIT;// 初始化进程状态为新建状态
ffffffffc0203fec:	57fd                	li	a5,-1
ffffffffc0203fee:	1782                	slli	a5,a5,0x20
ffffffffc0203ff0:	e11c                	sd	a5,0(a0)
    proc->runs = 0;// 初始化运行次数为0
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));// 初始化上下文结构，清空寄存器值
ffffffffc0203ff2:	07000613          	li	a2,112
ffffffffc0203ff6:	4581                	li	a1,0
    proc->runs = 0;// 初始化运行次数为0
ffffffffc0203ff8:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc0203ffc:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc0204000:	00052c23          	sw	zero,24(a0)
    proc->parent = NULL;
ffffffffc0204004:	02053023          	sd	zero,32(a0)
    proc->mm = NULL;
ffffffffc0204008:	02053423          	sd	zero,40(a0)
    memset(&(proc->context), 0, sizeof(struct context));// 初始化上下文结构，清空寄存器值
ffffffffc020400c:	03050513          	addi	a0,a0,48
ffffffffc0204010:	760000ef          	jal	ra,ffffffffc0204770 <memset>
    proc->tf = NULL;// 初始化陷阱帧为空
    proc->cr3 = boot_cr3;
ffffffffc0204014:	00011797          	auipc	a5,0x11
ffffffffc0204018:	4d47b783          	ld	a5,1236(a5) # ffffffffc02154e8 <boot_cr3>
    proc->tf = NULL;// 初始化陷阱帧为空
ffffffffc020401c:	0a043023          	sd	zero,160(s0)
    proc->cr3 = boot_cr3;
ffffffffc0204020:	f45c                	sd	a5,168(s0)
    proc->flags = 0;
ffffffffc0204022:	0a042823          	sw	zero,176(s0)
    memset(proc->name, 0, PROC_NAME_LEN + 1);
ffffffffc0204026:	4641                	li	a2,16
ffffffffc0204028:	4581                	li	a1,0
ffffffffc020402a:	0b440513          	addi	a0,s0,180
ffffffffc020402e:	742000ef          	jal	ra,ffffffffc0204770 <memset>
    }
    return proc;
}
ffffffffc0204032:	60a2                	ld	ra,8(sp)
ffffffffc0204034:	8522                	mv	a0,s0
ffffffffc0204036:	6402                	ld	s0,0(sp)
ffffffffc0204038:	0141                	addi	sp,sp,16
ffffffffc020403a:	8082                	ret

ffffffffc020403c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc020403c:	00011797          	auipc	a5,0x11
ffffffffc0204040:	4747b783          	ld	a5,1140(a5) # ffffffffc02154b0 <current>
ffffffffc0204044:	73c8                	ld	a0,160(a5)
ffffffffc0204046:	b23fc06f          	j	ffffffffc0200b68 <forkrets>

ffffffffc020404a <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020404a:	1101                	addi	sp,sp,-32
ffffffffc020404c:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020404e:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204052:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204054:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204056:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204058:	8522                	mv	a0,s0
ffffffffc020405a:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc020405c:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020405e:	712000ef          	jal	ra,ffffffffc0204770 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204062:	8522                	mv	a0,s0
}
ffffffffc0204064:	6442                	ld	s0,16(sp)
ffffffffc0204066:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204068:	85a6                	mv	a1,s1
}
ffffffffc020406a:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020406c:	463d                	li	a2,15
}
ffffffffc020406e:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204070:	af09                	j	ffffffffc0204782 <memcpy>

ffffffffc0204072 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc0204072:	1101                	addi	sp,sp,-32
ffffffffc0204074:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204076:	00011497          	auipc	s1,0x11
ffffffffc020407a:	3ea48493          	addi	s1,s1,1002 # ffffffffc0215460 <name.1545>
get_proc_name(struct proc_struct *proc) {
ffffffffc020407e:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204080:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc0204082:	842a                	mv	s0,a0
    memset(name, 0, sizeof(name));
ffffffffc0204084:	4581                	li	a1,0
ffffffffc0204086:	8526                	mv	a0,s1
get_proc_name(struct proc_struct *proc) {
ffffffffc0204088:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020408a:	6e6000ef          	jal	ra,ffffffffc0204770 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020408e:	0b440593          	addi	a1,s0,180
}
ffffffffc0204092:	6442                	ld	s0,16(sp)
ffffffffc0204094:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204096:	8526                	mv	a0,s1
}
ffffffffc0204098:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020409a:	463d                	li	a2,15
}
ffffffffc020409c:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020409e:	a5d5                	j	ffffffffc0204782 <memcpy>

ffffffffc02040a0 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02040a0:	1101                	addi	sp,sp,-32
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040a2:	00011797          	auipc	a5,0x11
ffffffffc02040a6:	40e7b783          	ld	a5,1038(a5) # ffffffffc02154b0 <current>
init_main(void *arg) {
ffffffffc02040aa:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040ac:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc02040ae:	e822                	sd	s0,16(sp)
ffffffffc02040b0:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040b2:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc02040b4:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040b6:	fbdff0ef          	jal	ra,ffffffffc0204072 <get_proc_name>
ffffffffc02040ba:	862a                	mv	a2,a0
ffffffffc02040bc:	85a6                	mv	a1,s1
ffffffffc02040be:	00002517          	auipc	a0,0x2
ffffffffc02040c2:	7f250513          	addi	a0,a0,2034 # ffffffffc02068b0 <default_pmm_manager+0x90>
ffffffffc02040c6:	806fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc02040ca:	85a2                	mv	a1,s0
ffffffffc02040cc:	00003517          	auipc	a0,0x3
ffffffffc02040d0:	80c50513          	addi	a0,a0,-2036 # ffffffffc02068d8 <default_pmm_manager+0xb8>
ffffffffc02040d4:	ff9fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02040d8:	00003517          	auipc	a0,0x3
ffffffffc02040dc:	81050513          	addi	a0,a0,-2032 # ffffffffc02068e8 <default_pmm_manager+0xc8>
ffffffffc02040e0:	fedfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
}
ffffffffc02040e4:	60e2                	ld	ra,24(sp)
ffffffffc02040e6:	6442                	ld	s0,16(sp)
ffffffffc02040e8:	64a2                	ld	s1,8(sp)
ffffffffc02040ea:	4501                	li	a0,0
ffffffffc02040ec:	6105                	addi	sp,sp,32
ffffffffc02040ee:	8082                	ret

ffffffffc02040f0 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc02040f0:	7179                	addi	sp,sp,-48
ffffffffc02040f2:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc02040f4:	00011917          	auipc	s2,0x11
ffffffffc02040f8:	3bc90913          	addi	s2,s2,956 # ffffffffc02154b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc02040fc:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc02040fe:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204102:	f406                	sd	ra,40(sp)
ffffffffc0204104:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204106:	02a48963          	beq	s1,a0,ffffffffc0204138 <proc_run+0x48>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020410a:	100027f3          	csrr	a5,sstatus
ffffffffc020410e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204110:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204112:	e3a1                	bnez	a5,ffffffffc0204152 <proc_run+0x62>
            lcr3(next->cr3);
ffffffffc0204114:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204116:	80000737          	lui	a4,0x80000
            current = proc;
ffffffffc020411a:	00a93023          	sd	a0,0(s2)
ffffffffc020411e:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204122:	8fd9                	or	a5,a5,a4
ffffffffc0204124:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204128:	03050593          	addi	a1,a0,48
ffffffffc020412c:	03048513          	addi	a0,s1,48
ffffffffc0204130:	e41ff0ef          	jal	ra,ffffffffc0203f70 <switch_to>
    if (flag) {
ffffffffc0204134:	00099863          	bnez	s3,ffffffffc0204144 <proc_run+0x54>
}
ffffffffc0204138:	70a2                	ld	ra,40(sp)
ffffffffc020413a:	7482                	ld	s1,32(sp)
ffffffffc020413c:	6962                	ld	s2,24(sp)
ffffffffc020413e:	69c2                	ld	s3,16(sp)
ffffffffc0204140:	6145                	addi	sp,sp,48
ffffffffc0204142:	8082                	ret
ffffffffc0204144:	70a2                	ld	ra,40(sp)
ffffffffc0204146:	7482                	ld	s1,32(sp)
ffffffffc0204148:	6962                	ld	s2,24(sp)
ffffffffc020414a:	69c2                	ld	s3,16(sp)
ffffffffc020414c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020414e:	c6afc06f          	j	ffffffffc02005b8 <intr_enable>
ffffffffc0204152:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204154:	c6afc0ef          	jal	ra,ffffffffc02005be <intr_disable>
        return 1;
ffffffffc0204158:	6522                	ld	a0,8(sp)
ffffffffc020415a:	4985                	li	s3,1
ffffffffc020415c:	bf65                	j	ffffffffc0204114 <proc_run+0x24>

ffffffffc020415e <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc020415e:	6789                	lui	a5,0x2
ffffffffc0204160:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204164:	17f9                	addi	a5,a5,-2
ffffffffc0204166:	04e7e063          	bltu	a5,a4,ffffffffc02041a6 <find_proc+0x48>
find_proc(int pid) {
ffffffffc020416a:	1141                	addi	sp,sp,-16
ffffffffc020416c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020416e:	45a9                	li	a1,10
ffffffffc0204170:	842a                	mv	s0,a0
ffffffffc0204172:	2501                	sext.w	a0,a0
find_proc(int pid) {
ffffffffc0204174:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204176:	237000ef          	jal	ra,ffffffffc0204bac <hash32>
ffffffffc020417a:	02051693          	slli	a3,a0,0x20
ffffffffc020417e:	0000d797          	auipc	a5,0xd
ffffffffc0204182:	2e278793          	addi	a5,a5,738 # ffffffffc0211460 <hash_list>
ffffffffc0204186:	82f1                	srli	a3,a3,0x1c
ffffffffc0204188:	96be                	add	a3,a3,a5
ffffffffc020418a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc020418c:	a029                	j	ffffffffc0204196 <find_proc+0x38>
            if (proc->pid == pid) {
ffffffffc020418e:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204192:	00870c63          	beq	a4,s0,ffffffffc02041aa <find_proc+0x4c>
    return listelm->next;
ffffffffc0204196:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204198:	fef69be3          	bne	a3,a5,ffffffffc020418e <find_proc+0x30>
}
ffffffffc020419c:	60a2                	ld	ra,8(sp)
ffffffffc020419e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02041a0:	4501                	li	a0,0
}
ffffffffc02041a2:	0141                	addi	sp,sp,16
ffffffffc02041a4:	8082                	ret
    return NULL;
ffffffffc02041a6:	4501                	li	a0,0
}
ffffffffc02041a8:	8082                	ret
ffffffffc02041aa:	60a2                	ld	ra,8(sp)
ffffffffc02041ac:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02041ae:	f2878513          	addi	a0,a5,-216
}
ffffffffc02041b2:	0141                	addi	sp,sp,16
ffffffffc02041b4:	8082                	ret

ffffffffc02041b6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02041b6:	7179                	addi	sp,sp,-48
ffffffffc02041b8:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02041ba:	00011917          	auipc	s2,0x11
ffffffffc02041be:	30e90913          	addi	s2,s2,782 # ffffffffc02154c8 <nr_process>
ffffffffc02041c2:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02041c6:	f406                	sd	ra,40(sp)
ffffffffc02041c8:	f022                	sd	s0,32(sp)
ffffffffc02041ca:	ec26                	sd	s1,24(sp)
ffffffffc02041cc:	e44e                	sd	s3,8(sp)
ffffffffc02041ce:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02041d0:	6785                	lui	a5,0x1
ffffffffc02041d2:	1af75e63          	bge	a4,a5,ffffffffc020438e <do_fork+0x1d8>
ffffffffc02041d6:	8a2e                	mv	s4,a1
ffffffffc02041d8:	89b2                	mv	s3,a2
    proc->parent = current;// 设定父线程
ffffffffc02041da:	00011497          	auipc	s1,0x11
ffffffffc02041de:	2d648493          	addi	s1,s1,726 # ffffffffc02154b0 <current>
    proc = alloc_proc();
ffffffffc02041e2:	df9ff0ef          	jal	ra,ffffffffc0203fda <alloc_proc>
    proc->parent = current;// 设定父线程
ffffffffc02041e6:	609c                	ld	a5,0(s1)
    proc = alloc_proc();
ffffffffc02041e8:	842a                	mv	s0,a0
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041ea:	4509                	li	a0,2
    proc->parent = current;// 设定父线程
ffffffffc02041ec:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041ee:	99dfc0ef          	jal	ra,ffffffffc0200b8a <alloc_pages>
    if (page != NULL) {
ffffffffc02041f2:	cd0d                	beqz	a0,ffffffffc020422c <do_fork+0x76>
    return page - pages + nbase;
ffffffffc02041f4:	00011697          	auipc	a3,0x11
ffffffffc02041f8:	2fc6b683          	ld	a3,764(a3) # ffffffffc02154f0 <pages>
ffffffffc02041fc:	40d506b3          	sub	a3,a0,a3
ffffffffc0204200:	8699                	srai	a3,a3,0x6
ffffffffc0204202:	00003517          	auipc	a0,0x3
ffffffffc0204206:	aa653503          	ld	a0,-1370(a0) # ffffffffc0206ca8 <nbase>
ffffffffc020420a:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020420c:	00c69793          	slli	a5,a3,0xc
ffffffffc0204210:	83b1                	srli	a5,a5,0xc
ffffffffc0204212:	00011717          	auipc	a4,0x11
ffffffffc0204216:	27673703          	ld	a4,630(a4) # ffffffffc0215488 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020421a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020421c:	18e7fe63          	bgeu	a5,a4,ffffffffc02043b8 <do_fork+0x202>
ffffffffc0204220:	00011797          	auipc	a5,0x11
ffffffffc0204224:	2c07b783          	ld	a5,704(a5) # ffffffffc02154e0 <va_pa_offset>
ffffffffc0204228:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020422a:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc020422c:	609c                	ld	a5,0(s1)
ffffffffc020422e:	779c                	ld	a5,40(a5)
ffffffffc0204230:	16079463          	bnez	a5,ffffffffc0204398 <do_fork+0x1e2>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204234:	681c                	ld	a5,16(s0)
ffffffffc0204236:	6709                	lui	a4,0x2
ffffffffc0204238:	ee070713          	addi	a4,a4,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc020423c:	97ba                	add	a5,a5,a4
    *(proc->tf) = *tf;
ffffffffc020423e:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204240:	f05c                	sd	a5,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204242:	873e                	mv	a4,a5
ffffffffc0204244:	12098893          	addi	a7,s3,288
ffffffffc0204248:	00063803          	ld	a6,0(a2)
ffffffffc020424c:	6608                	ld	a0,8(a2)
ffffffffc020424e:	6a0c                	ld	a1,16(a2)
ffffffffc0204250:	6e14                	ld	a3,24(a2)
ffffffffc0204252:	01073023          	sd	a6,0(a4)
ffffffffc0204256:	e708                	sd	a0,8(a4)
ffffffffc0204258:	eb0c                	sd	a1,16(a4)
ffffffffc020425a:	ef14                	sd	a3,24(a4)
ffffffffc020425c:	02060613          	addi	a2,a2,32
ffffffffc0204260:	02070713          	addi	a4,a4,32
ffffffffc0204264:	ff1612e3          	bne	a2,a7,ffffffffc0204248 <do_fork+0x92>
    proc->tf->gpr.a0 = 0;
ffffffffc0204268:	0407b823          	sd	zero,80(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020426c:	100a0563          	beqz	s4,ffffffffc0204376 <do_fork+0x1c0>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204270:	00006817          	auipc	a6,0x6
ffffffffc0204274:	de880813          	addi	a6,a6,-536 # ffffffffc020a058 <last_pid.1555>
ffffffffc0204278:	00082703          	lw	a4,0(a6)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020427c:	0147b823          	sd	s4,16(a5)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204280:	00000697          	auipc	a3,0x0
ffffffffc0204284:	dbc68693          	addi	a3,a3,-580 # ffffffffc020403c <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204288:	0017051b          	addiw	a0,a4,1
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020428c:	fc1c                	sd	a5,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020428e:	f814                	sd	a3,48(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204290:	00a82023          	sw	a0,0(a6)
ffffffffc0204294:	6789                	lui	a5,0x2
ffffffffc0204296:	06f55963          	bge	a0,a5,ffffffffc0204308 <do_fork+0x152>
    if (last_pid >= next_safe) {
ffffffffc020429a:	00006897          	auipc	a7,0x6
ffffffffc020429e:	dc288893          	addi	a7,a7,-574 # ffffffffc020a05c <next_safe.1554>
ffffffffc02042a2:	0008a783          	lw	a5,0(a7)
ffffffffc02042a6:	00011497          	auipc	s1,0x11
ffffffffc02042aa:	34a48493          	addi	s1,s1,842 # ffffffffc02155f0 <proc_list>
ffffffffc02042ae:	06f55563          	bge	a0,a5,ffffffffc0204318 <do_fork+0x162>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02042b2:	45a9                	li	a1,10
    proc->pid = pid;
ffffffffc02042b4:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02042b6:	2501                	sext.w	a0,a0
ffffffffc02042b8:	0f5000ef          	jal	ra,ffffffffc0204bac <hash32>
ffffffffc02042bc:	1502                	slli	a0,a0,0x20
ffffffffc02042be:	0000d797          	auipc	a5,0xd
ffffffffc02042c2:	1a278793          	addi	a5,a5,418 # ffffffffc0211460 <hash_list>
ffffffffc02042c6:	8171                	srli	a0,a0,0x1c
ffffffffc02042c8:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02042ca:	6518                	ld	a4,8(a0)
ffffffffc02042cc:	0d840793          	addi	a5,s0,216
ffffffffc02042d0:	6494                	ld	a3,8(s1)
    prev->next = next->prev = elm;
ffffffffc02042d2:	e31c                	sd	a5,0(a4)
ffffffffc02042d4:	e51c                	sd	a5,8(a0)
    nr_process++;// 增加全局进程计数器，记录当前系统中活跃进程的总数。
ffffffffc02042d6:	00092783          	lw	a5,0(s2)
    elm->next = next;
ffffffffc02042da:	f078                	sd	a4,224(s0)
    elm->prev = prev;
ffffffffc02042dc:	ec68                	sd	a0,216(s0)
    list_add(&proc_list, &(proc->list_link));// 将新进程插入全局进程链表 proc_list 中，用于顺序管理所有进程。
ffffffffc02042de:	0c840713          	addi	a4,s0,200
    prev->next = next->prev = elm;
ffffffffc02042e2:	e298                	sd	a4,0(a3)
    nr_process++;// 增加全局进程计数器，记录当前系统中活跃进程的总数。
ffffffffc02042e4:	2785                	addiw	a5,a5,1
    wakeup_proc(proc);
ffffffffc02042e6:	8522                	mv	a0,s0
    elm->next = next;
ffffffffc02042e8:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc02042ea:	e464                	sd	s1,200(s0)
    prev->next = next->prev = elm;
ffffffffc02042ec:	e498                	sd	a4,8(s1)
    nr_process++;// 增加全局进程计数器，记录当前系统中活跃进程的总数。
ffffffffc02042ee:	00f92023          	sw	a5,0(s2)
    wakeup_proc(proc);
ffffffffc02042f2:	33c000ef          	jal	ra,ffffffffc020462e <wakeup_proc>
    ret = proc->pid;
ffffffffc02042f6:	4048                	lw	a0,4(s0)
}
ffffffffc02042f8:	70a2                	ld	ra,40(sp)
ffffffffc02042fa:	7402                	ld	s0,32(sp)
ffffffffc02042fc:	64e2                	ld	s1,24(sp)
ffffffffc02042fe:	6942                	ld	s2,16(sp)
ffffffffc0204300:	69a2                	ld	s3,8(sp)
ffffffffc0204302:	6a02                	ld	s4,0(sp)
ffffffffc0204304:	6145                	addi	sp,sp,48
ffffffffc0204306:	8082                	ret
        last_pid = 1;
ffffffffc0204308:	4785                	li	a5,1
ffffffffc020430a:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc020430e:	4505                	li	a0,1
ffffffffc0204310:	00006897          	auipc	a7,0x6
ffffffffc0204314:	d4c88893          	addi	a7,a7,-692 # ffffffffc020a05c <next_safe.1554>
    return listelm->next;
ffffffffc0204318:	00011497          	auipc	s1,0x11
ffffffffc020431c:	2d848493          	addi	s1,s1,728 # ffffffffc02155f0 <proc_list>
ffffffffc0204320:	0084b303          	ld	t1,8(s1)
        next_safe = MAX_PID;
ffffffffc0204324:	6789                	lui	a5,0x2
ffffffffc0204326:	00f8a023          	sw	a5,0(a7)
ffffffffc020432a:	4581                	li	a1,0
ffffffffc020432c:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc020432e:	6e89                	lui	t4,0x2
ffffffffc0204330:	04930a63          	beq	t1,s1,ffffffffc0204384 <do_fork+0x1ce>
ffffffffc0204334:	8e2e                	mv	t3,a1
ffffffffc0204336:	869a                	mv	a3,t1
ffffffffc0204338:	6609                	lui	a2,0x2
ffffffffc020433a:	a811                	j	ffffffffc020434e <do_fork+0x198>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020433c:	00e7d663          	bge	a5,a4,ffffffffc0204348 <do_fork+0x192>
ffffffffc0204340:	00c75463          	bge	a4,a2,ffffffffc0204348 <do_fork+0x192>
ffffffffc0204344:	863a                	mv	a2,a4
ffffffffc0204346:	4e05                	li	t3,1
ffffffffc0204348:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc020434a:	00968d63          	beq	a3,s1,ffffffffc0204364 <do_fork+0x1ae>
            if (proc->pid == last_pid) {
ffffffffc020434e:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204352:	fee795e3          	bne	a5,a4,ffffffffc020433c <do_fork+0x186>
                if (++ last_pid >= next_safe) {
ffffffffc0204356:	2785                	addiw	a5,a5,1
ffffffffc0204358:	02c7d163          	bge	a5,a2,ffffffffc020437a <do_fork+0x1c4>
ffffffffc020435c:	6694                	ld	a3,8(a3)
ffffffffc020435e:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc0204360:	fe9697e3          	bne	a3,s1,ffffffffc020434e <do_fork+0x198>
ffffffffc0204364:	c581                	beqz	a1,ffffffffc020436c <do_fork+0x1b6>
ffffffffc0204366:	00f82023          	sw	a5,0(a6)
ffffffffc020436a:	853e                	mv	a0,a5
ffffffffc020436c:	f40e03e3          	beqz	t3,ffffffffc02042b2 <do_fork+0xfc>
ffffffffc0204370:	00c8a023          	sw	a2,0(a7)
ffffffffc0204374:	bf3d                	j	ffffffffc02042b2 <do_fork+0xfc>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204376:	8a3e                	mv	s4,a5
ffffffffc0204378:	bde5                	j	ffffffffc0204270 <do_fork+0xba>
                    if (last_pid >= MAX_PID) {
ffffffffc020437a:	01d7c363          	blt	a5,t4,ffffffffc0204380 <do_fork+0x1ca>
                        last_pid = 1;
ffffffffc020437e:	4785                	li	a5,1
                    goto repeat;
ffffffffc0204380:	4585                	li	a1,1
ffffffffc0204382:	b77d                	j	ffffffffc0204330 <do_fork+0x17a>
ffffffffc0204384:	c599                	beqz	a1,ffffffffc0204392 <do_fork+0x1dc>
ffffffffc0204386:	00f82023          	sw	a5,0(a6)
ffffffffc020438a:	853e                	mv	a0,a5
ffffffffc020438c:	b71d                	j	ffffffffc02042b2 <do_fork+0xfc>
    int ret = -E_NO_FREE_PROC;
ffffffffc020438e:	556d                	li	a0,-5
    return ret;
ffffffffc0204390:	b7a5                	j	ffffffffc02042f8 <do_fork+0x142>
ffffffffc0204392:	00082503          	lw	a0,0(a6)
ffffffffc0204396:	bf31                	j	ffffffffc02042b2 <do_fork+0xfc>
    assert(current->mm == NULL);
ffffffffc0204398:	00002697          	auipc	a3,0x2
ffffffffc020439c:	57068693          	addi	a3,a3,1392 # ffffffffc0206908 <default_pmm_manager+0xe8>
ffffffffc02043a0:	00001617          	auipc	a2,0x1
ffffffffc02043a4:	2f860613          	addi	a2,a2,760 # ffffffffc0205698 <commands+0x848>
ffffffffc02043a8:	11a00593          	li	a1,282
ffffffffc02043ac:	00002517          	auipc	a0,0x2
ffffffffc02043b0:	57450513          	addi	a0,a0,1396 # ffffffffc0206920 <default_pmm_manager+0x100>
ffffffffc02043b4:	e15fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02043b8:	00001617          	auipc	a2,0x1
ffffffffc02043bc:	1d060613          	addi	a2,a2,464 # ffffffffc0205588 <commands+0x738>
ffffffffc02043c0:	06900593          	li	a1,105
ffffffffc02043c4:	00001517          	auipc	a0,0x1
ffffffffc02043c8:	1b450513          	addi	a0,a0,436 # ffffffffc0205578 <commands+0x728>
ffffffffc02043cc:	dfdfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02043d0 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02043d0:	7129                	addi	sp,sp,-320
ffffffffc02043d2:	fa22                	sd	s0,304(sp)
ffffffffc02043d4:	f626                	sd	s1,296(sp)
ffffffffc02043d6:	f24a                	sd	s2,288(sp)
ffffffffc02043d8:	84ae                	mv	s1,a1
ffffffffc02043da:	892a                	mv	s2,a0
ffffffffc02043dc:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02043de:	4581                	li	a1,0
ffffffffc02043e0:	12000613          	li	a2,288
ffffffffc02043e4:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02043e6:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02043e8:	388000ef          	jal	ra,ffffffffc0204770 <memset>
    tf.gpr.s0 = (uintptr_t)fn; // s0 寄存器保存函数指针
ffffffffc02043ec:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg; // s1 寄存器保存函数参数
ffffffffc02043ee:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02043f0:	100027f3          	csrr	a5,sstatus
ffffffffc02043f4:	edd7f793          	andi	a5,a5,-291
ffffffffc02043f8:	1207e793          	ori	a5,a5,288
ffffffffc02043fc:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02043fe:	860a                	mv	a2,sp
ffffffffc0204400:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204404:	00000797          	auipc	a5,0x0
ffffffffc0204408:	b6478793          	addi	a5,a5,-1180 # ffffffffc0203f68 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020440c:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020440e:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204410:	da7ff0ef          	jal	ra,ffffffffc02041b6 <do_fork>
}
ffffffffc0204414:	70f2                	ld	ra,312(sp)
ffffffffc0204416:	7452                	ld	s0,304(sp)
ffffffffc0204418:	74b2                	ld	s1,296(sp)
ffffffffc020441a:	7912                	ld	s2,288(sp)
ffffffffc020441c:	6131                	addi	sp,sp,320
ffffffffc020441e:	8082                	ret

ffffffffc0204420 <do_exit>:
do_exit(int error_code) {
ffffffffc0204420:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0204422:	00002617          	auipc	a2,0x2
ffffffffc0204426:	51660613          	addi	a2,a2,1302 # ffffffffc0206938 <default_pmm_manager+0x118>
ffffffffc020442a:	17800593          	li	a1,376
ffffffffc020442e:	00002517          	auipc	a0,0x2
ffffffffc0204432:	4f250513          	addi	a0,a0,1266 # ffffffffc0206920 <default_pmm_manager+0x100>
do_exit(int error_code) {
ffffffffc0204436:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0204438:	d91fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020443c <proc_init>:

// 初始化idleproc（内核第一个线程，称为空闲线程）。 
// 创建 init_main 线程（内核第二个线程，用于系统初始化）。
void
proc_init(void) {
ffffffffc020443c:	1101                	addi	sp,sp,-32
    elm->prev = elm->next = elm;
ffffffffc020443e:	00011797          	auipc	a5,0x11
ffffffffc0204442:	1b278793          	addi	a5,a5,434 # ffffffffc02155f0 <proc_list>
ffffffffc0204446:	ec06                	sd	ra,24(sp)
ffffffffc0204448:	e822                	sd	s0,16(sp)
ffffffffc020444a:	e426                	sd	s1,8(sp)
ffffffffc020444c:	e04a                	sd	s2,0(sp)
ffffffffc020444e:	e79c                	sd	a5,8(a5)
ffffffffc0204450:	e39c                	sd	a5,0(a5)

    // 初始化全局链表 proc_list 和哈希表 hash_list
    // proc_list：用于管理所有的进程，方便遍历或调度。
    // hash_list：哈希表，用于快速查找进程（如通过 PID）。
    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204452:	00011717          	auipc	a4,0x11
ffffffffc0204456:	00e70713          	addi	a4,a4,14 # ffffffffc0215460 <name.1545>
ffffffffc020445a:	0000d797          	auipc	a5,0xd
ffffffffc020445e:	00678793          	addi	a5,a5,6 # ffffffffc0211460 <hash_list>
ffffffffc0204462:	e79c                	sd	a5,8(a5)
ffffffffc0204464:	e39c                	sd	a5,0(a5)
ffffffffc0204466:	07c1                	addi	a5,a5,16
ffffffffc0204468:	fee79de3          	bne	a5,a4,ffffffffc0204462 <proc_init+0x26>
        list_init(hash_list + i);
    }

    // 调用 alloc_proc 分配并初始化空闲线程 idleproc
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020446c:	b6fff0ef          	jal	ra,ffffffffc0203fda <alloc_proc>
ffffffffc0204470:	00011417          	auipc	s0,0x11
ffffffffc0204474:	04840413          	addi	s0,s0,72 # ffffffffc02154b8 <idleproc>
ffffffffc0204478:	e008                	sd	a0,0(s0)
ffffffffc020447a:	12050463          	beqz	a0,ffffffffc02045a2 <proc_init+0x166>
        //分配失败，触发panic终止程序，说明内核初始化失败。
        panic("cannot alloc idleproc.\n");
    }

    // 通过逐个字段对比预期值和实际值，确认 alloc_proc 是否正确初始化了进程控制块。
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020447e:	07000513          	li	a0,112
ffffffffc0204482:	c64fe0ef          	jal	ra,ffffffffc02028e6 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204486:	07000613          	li	a2,112
ffffffffc020448a:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020448c:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020448e:	2e2000ef          	jal	ra,ffffffffc0204770 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0204492:	6008                	ld	a0,0(s0)
ffffffffc0204494:	85a6                	mv	a1,s1
ffffffffc0204496:	07000613          	li	a2,112
ffffffffc020449a:	03050513          	addi	a0,a0,48
ffffffffc020449e:	2fc000ef          	jal	ra,ffffffffc020479a <memcmp>
ffffffffc02044a2:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02044a4:	453d                	li	a0,15
ffffffffc02044a6:	c40fe0ef          	jal	ra,ffffffffc02028e6 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02044aa:	463d                	li	a2,15
ffffffffc02044ac:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc02044ae:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc02044b0:	2c0000ef          	jal	ra,ffffffffc0204770 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02044b4:	6008                	ld	a0,0(s0)
ffffffffc02044b6:	463d                	li	a2,15
ffffffffc02044b8:	85a6                	mv	a1,s1
ffffffffc02044ba:	0b450513          	addi	a0,a0,180
ffffffffc02044be:	2dc000ef          	jal	ra,ffffffffc020479a <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02044c2:	601c                	ld	a5,0(s0)
ffffffffc02044c4:	00011717          	auipc	a4,0x11
ffffffffc02044c8:	02473703          	ld	a4,36(a4) # ffffffffc02154e8 <boot_cr3>
ffffffffc02044cc:	77d4                	ld	a3,168(a5)
ffffffffc02044ce:	08e68863          	beq	a3,a4,ffffffffc020455e <proc_init+0x122>

    }
    
    // 初始化空闲线程 idleproc
    idleproc->pid = 0;                      // 设置进程 ID 为 0
    idleproc->state = PROC_RUNNABLE;        // 设置状态为可运行
ffffffffc02044d2:	4709                	li	a4,2
ffffffffc02044d4:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack; // 指定内核栈指针
ffffffffc02044d6:	00003717          	auipc	a4,0x3
ffffffffc02044da:	b2a70713          	addi	a4,a4,-1238 # ffffffffc0207000 <bootstack>
ffffffffc02044de:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;             // 设置需要调度的标志
ffffffffc02044e0:	4705                	li	a4,1
ffffffffc02044e2:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");        // 设置名称为 "idle"
ffffffffc02044e4:	00002597          	auipc	a1,0x2
ffffffffc02044e8:	49c58593          	addi	a1,a1,1180 # ffffffffc0206980 <default_pmm_manager+0x160>
ffffffffc02044ec:	853e                	mv	a0,a5
ffffffffc02044ee:	b5dff0ef          	jal	ra,ffffffffc020404a <set_proc_name>
    nr_process++;                           // 增加全局进程计数
ffffffffc02044f2:	00011717          	auipc	a4,0x11
ffffffffc02044f6:	fd670713          	addi	a4,a4,-42 # ffffffffc02154c8 <nr_process>
ffffffffc02044fa:	431c                	lw	a5,0(a4)

    current = idleproc;                     // 设置当前进程为 `idleproc`
ffffffffc02044fc:	6014                	ld	a3,0(s0)


    // 创建 init_main 线程
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02044fe:	4601                	li	a2,0
    nr_process++;                           // 增加全局进程计数
ffffffffc0204500:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204502:	00002597          	auipc	a1,0x2
ffffffffc0204506:	48658593          	addi	a1,a1,1158 # ffffffffc0206988 <default_pmm_manager+0x168>
ffffffffc020450a:	00000517          	auipc	a0,0x0
ffffffffc020450e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02040a0 <init_main>
    nr_process++;                           // 增加全局进程计数
ffffffffc0204512:	c31c                	sw	a5,0(a4)
    current = idleproc;                     // 设置当前进程为 `idleproc`
ffffffffc0204514:	00011797          	auipc	a5,0x11
ffffffffc0204518:	f8d7be23          	sd	a3,-100(a5) # ffffffffc02154b0 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020451c:	eb5ff0ef          	jal	ra,ffffffffc02043d0 <kernel_thread>
    if (pid <= 0) {
ffffffffc0204520:	0ca05d63          	blez	a0,ffffffffc02045fa <proc_init+0x1be>
        panic("create init_main failed.\n");
    }
    // 通过 find_proc 获取新线程的控制块，并设置其名称为 "init"。
    initproc = find_proc(pid);
ffffffffc0204524:	c3bff0ef          	jal	ra,ffffffffc020415e <find_proc>
ffffffffc0204528:	00011497          	auipc	s1,0x11
ffffffffc020452c:	f9848493          	addi	s1,s1,-104 # ffffffffc02154c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204530:	00002597          	auipc	a1,0x2
ffffffffc0204534:	48858593          	addi	a1,a1,1160 # ffffffffc02069b8 <default_pmm_manager+0x198>
    initproc = find_proc(pid);
ffffffffc0204538:	e088                	sd	a0,0(s1)
    set_proc_name(initproc, "init");
ffffffffc020453a:	b11ff0ef          	jal	ra,ffffffffc020404a <set_proc_name>

    // 最终断言，确保 idleproc 和 initproc 均被正确初始化。
    // idleproc 的 PID 是 0，initproc 的 PID 是 1，这是内核进程初始化的基本假设。
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020453e:	601c                	ld	a5,0(s0)
ffffffffc0204540:	cfc9                	beqz	a5,ffffffffc02045da <proc_init+0x19e>
ffffffffc0204542:	43dc                	lw	a5,4(a5)
ffffffffc0204544:	ebd9                	bnez	a5,ffffffffc02045da <proc_init+0x19e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204546:	609c                	ld	a5,0(s1)
ffffffffc0204548:	cbad                	beqz	a5,ffffffffc02045ba <proc_init+0x17e>
ffffffffc020454a:	43d8                	lw	a4,4(a5)
ffffffffc020454c:	4785                	li	a5,1
ffffffffc020454e:	06f71663          	bne	a4,a5,ffffffffc02045ba <proc_init+0x17e>
}
ffffffffc0204552:	60e2                	ld	ra,24(sp)
ffffffffc0204554:	6442                	ld	s0,16(sp)
ffffffffc0204556:	64a2                	ld	s1,8(sp)
ffffffffc0204558:	6902                	ld	s2,0(sp)
ffffffffc020455a:	6105                	addi	sp,sp,32
ffffffffc020455c:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020455e:	73d8                	ld	a4,160(a5)
ffffffffc0204560:	fb2d                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
ffffffffc0204562:	f60918e3          	bnez	s2,ffffffffc02044d2 <proc_init+0x96>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204566:	6394                	ld	a3,0(a5)
ffffffffc0204568:	577d                	li	a4,-1
ffffffffc020456a:	1702                	slli	a4,a4,0x20
ffffffffc020456c:	f6e693e3          	bne	a3,a4,ffffffffc02044d2 <proc_init+0x96>
ffffffffc0204570:	4798                	lw	a4,8(a5)
ffffffffc0204572:	f325                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204574:	6b98                	ld	a4,16(a5)
ffffffffc0204576:	ff31                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
ffffffffc0204578:	4f98                	lw	a4,24(a5)
ffffffffc020457a:	2701                	sext.w	a4,a4
ffffffffc020457c:	fb39                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
ffffffffc020457e:	7398                	ld	a4,32(a5)
ffffffffc0204580:	fb29                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204582:	7798                	ld	a4,40(a5)
ffffffffc0204584:	f739                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
ffffffffc0204586:	0b07a703          	lw	a4,176(a5)
ffffffffc020458a:	8d59                	or	a0,a0,a4
ffffffffc020458c:	0005071b          	sext.w	a4,a0
ffffffffc0204590:	f329                	bnez	a4,ffffffffc02044d2 <proc_init+0x96>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204592:	00002517          	auipc	a0,0x2
ffffffffc0204596:	3d650513          	addi	a0,a0,982 # ffffffffc0206968 <default_pmm_manager+0x148>
ffffffffc020459a:	b33fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020459e:	601c                	ld	a5,0(s0)
ffffffffc02045a0:	bf0d                	j	ffffffffc02044d2 <proc_init+0x96>
        panic("cannot alloc idleproc.\n");
ffffffffc02045a2:	00002617          	auipc	a2,0x2
ffffffffc02045a6:	3ae60613          	addi	a2,a2,942 # ffffffffc0206950 <default_pmm_manager+0x130>
ffffffffc02045aa:	19500593          	li	a1,405
ffffffffc02045ae:	00002517          	auipc	a0,0x2
ffffffffc02045b2:	37250513          	addi	a0,a0,882 # ffffffffc0206920 <default_pmm_manager+0x100>
ffffffffc02045b6:	c13fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02045ba:	00002697          	auipc	a3,0x2
ffffffffc02045be:	42e68693          	addi	a3,a3,1070 # ffffffffc02069e8 <default_pmm_manager+0x1c8>
ffffffffc02045c2:	00001617          	auipc	a2,0x1
ffffffffc02045c6:	0d660613          	addi	a2,a2,214 # ffffffffc0205698 <commands+0x848>
ffffffffc02045ca:	1c100593          	li	a1,449
ffffffffc02045ce:	00002517          	auipc	a0,0x2
ffffffffc02045d2:	35250513          	addi	a0,a0,850 # ffffffffc0206920 <default_pmm_manager+0x100>
ffffffffc02045d6:	bf3fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02045da:	00002697          	auipc	a3,0x2
ffffffffc02045de:	3e668693          	addi	a3,a3,998 # ffffffffc02069c0 <default_pmm_manager+0x1a0>
ffffffffc02045e2:	00001617          	auipc	a2,0x1
ffffffffc02045e6:	0b660613          	addi	a2,a2,182 # ffffffffc0205698 <commands+0x848>
ffffffffc02045ea:	1c000593          	li	a1,448
ffffffffc02045ee:	00002517          	auipc	a0,0x2
ffffffffc02045f2:	33250513          	addi	a0,a0,818 # ffffffffc0206920 <default_pmm_manager+0x100>
ffffffffc02045f6:	bd3fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc02045fa:	00002617          	auipc	a2,0x2
ffffffffc02045fe:	39e60613          	addi	a2,a2,926 # ffffffffc0206998 <default_pmm_manager+0x178>
ffffffffc0204602:	1b800593          	li	a1,440
ffffffffc0204606:	00002517          	auipc	a0,0x2
ffffffffc020460a:	31a50513          	addi	a0,a0,794 # ffffffffc0206920 <default_pmm_manager+0x100>
ffffffffc020460e:	bbbfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204612 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204612:	1141                	addi	sp,sp,-16
ffffffffc0204614:	e022                	sd	s0,0(sp)
ffffffffc0204616:	e406                	sd	ra,8(sp)
ffffffffc0204618:	00011417          	auipc	s0,0x11
ffffffffc020461c:	e9840413          	addi	s0,s0,-360 # ffffffffc02154b0 <current>
    while (1) {
        if (current->need_resched) {// need_resched 为真则需要重新调度
ffffffffc0204620:	6018                	ld	a4,0(s0)
ffffffffc0204622:	4f1c                	lw	a5,24(a4)
ffffffffc0204624:	2781                	sext.w	a5,a5
ffffffffc0204626:	dff5                	beqz	a5,ffffffffc0204622 <cpu_idle+0x10>
            schedule();// 切换到其他进程
ffffffffc0204628:	038000ef          	jal	ra,ffffffffc0204660 <schedule>
ffffffffc020462c:	bfd5                	j	ffffffffc0204620 <cpu_idle+0xe>

ffffffffc020462e <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020462e:	411c                	lw	a5,0(a0)
ffffffffc0204630:	4705                	li	a4,1
ffffffffc0204632:	37f9                	addiw	a5,a5,-2
ffffffffc0204634:	00f77563          	bgeu	a4,a5,ffffffffc020463e <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204638:	4789                	li	a5,2
ffffffffc020463a:	c11c                	sw	a5,0(a0)
ffffffffc020463c:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc020463e:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204640:	00002697          	auipc	a3,0x2
ffffffffc0204644:	3d068693          	addi	a3,a3,976 # ffffffffc0206a10 <default_pmm_manager+0x1f0>
ffffffffc0204648:	00001617          	auipc	a2,0x1
ffffffffc020464c:	05060613          	addi	a2,a2,80 # ffffffffc0205698 <commands+0x848>
ffffffffc0204650:	45a5                	li	a1,9
ffffffffc0204652:	00002517          	auipc	a0,0x2
ffffffffc0204656:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206a50 <default_pmm_manager+0x230>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020465a:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020465c:	b6dfb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204660 <schedule>:
}

// 进程调度
void
schedule(void) {
ffffffffc0204660:	1141                	addi	sp,sp,-16
ffffffffc0204662:	e406                	sd	ra,8(sp)
ffffffffc0204664:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204666:	100027f3          	csrr	a5,sstatus
ffffffffc020466a:	8b89                	andi	a5,a5,2
ffffffffc020466c:	4401                	li	s0,0
ffffffffc020466e:	efbd                	bnez	a5,ffffffffc02046ec <schedule+0x8c>
    list_entry_t *le, *last;// 进程链表迭代器，分别用于遍历进程和保存当前进程位置
    struct proc_struct *next = NULL;// 指向下一个要运行的进程
    // 保存当前中断状态，并禁止中断
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;// 设置当前进程不需要调度
ffffffffc0204670:	00011897          	auipc	a7,0x11
ffffffffc0204674:	e408b883          	ld	a7,-448(a7) # ffffffffc02154b0 <current>
ffffffffc0204678:	0008ac23          	sw	zero,24(a7)
        // 判断当前进程是否为空闲进程，是则从头遍历，否则从当前遍历
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020467c:	00011517          	auipc	a0,0x11
ffffffffc0204680:	e3c53503          	ld	a0,-452(a0) # ffffffffc02154b8 <idleproc>
ffffffffc0204684:	04a88e63          	beq	a7,a0,ffffffffc02046e0 <schedule+0x80>
ffffffffc0204688:	0c888693          	addi	a3,a7,200
ffffffffc020468c:	00011617          	auipc	a2,0x11
ffffffffc0204690:	f6460613          	addi	a2,a2,-156 # ffffffffc02155f0 <proc_list>
        le = last;
ffffffffc0204694:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;// 指向下一个要运行的进程
ffffffffc0204696:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204698:	4809                	li	a6,2
    return listelm->next;
ffffffffc020469a:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020469c:	00c78863          	beq	a5,a2,ffffffffc02046ac <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02046a0:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02046a4:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02046a8:	03070163          	beq	a4,a6,ffffffffc02046ca <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02046ac:	fef697e3          	bne	a3,a5,ffffffffc020469a <schedule+0x3a>
        // 若未找到，则将next设为空闲进程，保证系统不会无进程可运行
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02046b0:	ed89                	bnez	a1,ffffffffc02046ca <schedule+0x6a>
            next = idleproc;
        }
        // 上下文切换
        next->runs ++;// 选中进程的运行次数+1
ffffffffc02046b2:	451c                	lw	a5,8(a0)
ffffffffc02046b4:	2785                	addiw	a5,a5,1
ffffffffc02046b6:	c51c                	sw	a5,8(a0)
        //若选中进程不是当前运行进程，则调用 proc_run(next) 进行上下文切换，切换到 next。
        if (next != current) {
ffffffffc02046b8:	00a88463          	beq	a7,a0,ffffffffc02046c0 <schedule+0x60>
            proc_run(next);
ffffffffc02046bc:	a35ff0ef          	jal	ra,ffffffffc02040f0 <proc_run>
    if (flag) {
ffffffffc02046c0:	e819                	bnez	s0,ffffffffc02046d6 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);// 恢复中断
}
ffffffffc02046c2:	60a2                	ld	ra,8(sp)
ffffffffc02046c4:	6402                	ld	s0,0(sp)
ffffffffc02046c6:	0141                	addi	sp,sp,16
ffffffffc02046c8:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02046ca:	4198                	lw	a4,0(a1)
ffffffffc02046cc:	4789                	li	a5,2
ffffffffc02046ce:	fef712e3          	bne	a4,a5,ffffffffc02046b2 <schedule+0x52>
ffffffffc02046d2:	852e                	mv	a0,a1
ffffffffc02046d4:	bff9                	j	ffffffffc02046b2 <schedule+0x52>
}
ffffffffc02046d6:	6402                	ld	s0,0(sp)
ffffffffc02046d8:	60a2                	ld	ra,8(sp)
ffffffffc02046da:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02046dc:	eddfb06f          	j	ffffffffc02005b8 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02046e0:	00011617          	auipc	a2,0x11
ffffffffc02046e4:	f1060613          	addi	a2,a2,-240 # ffffffffc02155f0 <proc_list>
ffffffffc02046e8:	86b2                	mv	a3,a2
ffffffffc02046ea:	b76d                	j	ffffffffc0204694 <schedule+0x34>
        intr_disable();
ffffffffc02046ec:	ed3fb0ef          	jal	ra,ffffffffc02005be <intr_disable>
        return 1;
ffffffffc02046f0:	4405                	li	s0,1
ffffffffc02046f2:	bfbd                	j	ffffffffc0204670 <schedule+0x10>

ffffffffc02046f4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02046f4:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02046f8:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02046fa:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02046fc:	cb81                	beqz	a5,ffffffffc020470c <strlen+0x18>
        cnt ++;
ffffffffc02046fe:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204700:	00a707b3          	add	a5,a4,a0
ffffffffc0204704:	0007c783          	lbu	a5,0(a5)
ffffffffc0204708:	fbfd                	bnez	a5,ffffffffc02046fe <strlen+0xa>
ffffffffc020470a:	8082                	ret
    }
    return cnt;
}
ffffffffc020470c:	8082                	ret

ffffffffc020470e <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
ffffffffc020470e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204710:	4501                	li	a0,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204712:	e589                	bnez	a1,ffffffffc020471c <strnlen+0xe>
ffffffffc0204714:	a811                	j	ffffffffc0204728 <strnlen+0x1a>
        cnt ++;
ffffffffc0204716:	0505                	addi	a0,a0,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204718:	00a58763          	beq	a1,a0,ffffffffc0204726 <strnlen+0x18>
ffffffffc020471c:	00a707b3          	add	a5,a4,a0
ffffffffc0204720:	0007c783          	lbu	a5,0(a5)
ffffffffc0204724:	fbed                	bnez	a5,ffffffffc0204716 <strnlen+0x8>
    }
    return cnt;
}
ffffffffc0204726:	8082                	ret
ffffffffc0204728:	8082                	ret

ffffffffc020472a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020472a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020472c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204730:	0785                	addi	a5,a5,1
ffffffffc0204732:	0585                	addi	a1,a1,1
ffffffffc0204734:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204738:	fb75                	bnez	a4,ffffffffc020472c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020473a:	8082                	ret

ffffffffc020473c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020473c:	00054783          	lbu	a5,0(a0)
ffffffffc0204740:	0005c703          	lbu	a4,0(a1)
ffffffffc0204744:	cb89                	beqz	a5,ffffffffc0204756 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0204746:	0505                	addi	a0,a0,1
ffffffffc0204748:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020474a:	fee789e3          	beq	a5,a4,ffffffffc020473c <strcmp>
ffffffffc020474e:	0007851b          	sext.w	a0,a5
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204752:	9d19                	subw	a0,a0,a4
ffffffffc0204754:	8082                	ret
ffffffffc0204756:	4501                	li	a0,0
ffffffffc0204758:	bfed                	j	ffffffffc0204752 <strcmp+0x16>

ffffffffc020475a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020475a:	00054783          	lbu	a5,0(a0)
ffffffffc020475e:	c799                	beqz	a5,ffffffffc020476c <strchr+0x12>
        if (*s == c) {
ffffffffc0204760:	00f58763          	beq	a1,a5,ffffffffc020476e <strchr+0x14>
    while (*s != '\0') {
ffffffffc0204764:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204768:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020476a:	fbfd                	bnez	a5,ffffffffc0204760 <strchr+0x6>
    }
    return NULL;
ffffffffc020476c:	4501                	li	a0,0
}
ffffffffc020476e:	8082                	ret

ffffffffc0204770 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204770:	ca01                	beqz	a2,ffffffffc0204780 <memset+0x10>
ffffffffc0204772:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204774:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204776:	0785                	addi	a5,a5,1
ffffffffc0204778:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020477c:	fec79de3          	bne	a5,a2,ffffffffc0204776 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204780:	8082                	ret

ffffffffc0204782 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204782:	ca19                	beqz	a2,ffffffffc0204798 <memcpy+0x16>
ffffffffc0204784:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204786:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204788:	0005c703          	lbu	a4,0(a1)
ffffffffc020478c:	0585                	addi	a1,a1,1
ffffffffc020478e:	0785                	addi	a5,a5,1
ffffffffc0204790:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204794:	fec59ae3          	bne	a1,a2,ffffffffc0204788 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204798:	8082                	ret

ffffffffc020479a <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc020479a:	c205                	beqz	a2,ffffffffc02047ba <memcmp+0x20>
ffffffffc020479c:	962e                	add	a2,a2,a1
ffffffffc020479e:	a019                	j	ffffffffc02047a4 <memcmp+0xa>
ffffffffc02047a0:	00c58d63          	beq	a1,a2,ffffffffc02047ba <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc02047a4:	00054783          	lbu	a5,0(a0)
ffffffffc02047a8:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc02047ac:	0505                	addi	a0,a0,1
ffffffffc02047ae:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc02047b0:	fee788e3          	beq	a5,a4,ffffffffc02047a0 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02047b4:	40e7853b          	subw	a0,a5,a4
ffffffffc02047b8:	8082                	ret
    }
    return 0;
ffffffffc02047ba:	4501                	li	a0,0
}
ffffffffc02047bc:	8082                	ret

ffffffffc02047be <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02047be:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02047c2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02047c4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02047c8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02047ca:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02047ce:	f022                	sd	s0,32(sp)
ffffffffc02047d0:	ec26                	sd	s1,24(sp)
ffffffffc02047d2:	e84a                	sd	s2,16(sp)
ffffffffc02047d4:	f406                	sd	ra,40(sp)
ffffffffc02047d6:	e44e                	sd	s3,8(sp)
ffffffffc02047d8:	84aa                	mv	s1,a0
ffffffffc02047da:	892e                	mv	s2,a1
ffffffffc02047dc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02047e0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02047e2:	03067e63          	bgeu	a2,a6,ffffffffc020481e <printnum+0x60>
ffffffffc02047e6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02047e8:	00805763          	blez	s0,ffffffffc02047f6 <printnum+0x38>
ffffffffc02047ec:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02047ee:	85ca                	mv	a1,s2
ffffffffc02047f0:	854e                	mv	a0,s3
ffffffffc02047f2:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02047f4:	fc65                	bnez	s0,ffffffffc02047ec <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02047f6:	1a02                	slli	s4,s4,0x20
ffffffffc02047f8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02047fc:	00002797          	auipc	a5,0x2
ffffffffc0204800:	26c78793          	addi	a5,a5,620 # ffffffffc0206a68 <default_pmm_manager+0x248>
}
ffffffffc0204804:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204806:	9a3e                	add	s4,s4,a5
ffffffffc0204808:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020480c:	70a2                	ld	ra,40(sp)
ffffffffc020480e:	69a2                	ld	s3,8(sp)
ffffffffc0204810:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204812:	85ca                	mv	a1,s2
ffffffffc0204814:	8326                	mv	t1,s1
}
ffffffffc0204816:	6942                	ld	s2,16(sp)
ffffffffc0204818:	64e2                	ld	s1,24(sp)
ffffffffc020481a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020481c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020481e:	03065633          	divu	a2,a2,a6
ffffffffc0204822:	8722                	mv	a4,s0
ffffffffc0204824:	f9bff0ef          	jal	ra,ffffffffc02047be <printnum>
ffffffffc0204828:	b7f9                	j	ffffffffc02047f6 <printnum+0x38>

ffffffffc020482a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020482a:	7119                	addi	sp,sp,-128
ffffffffc020482c:	f4a6                	sd	s1,104(sp)
ffffffffc020482e:	f0ca                	sd	s2,96(sp)
ffffffffc0204830:	ecce                	sd	s3,88(sp)
ffffffffc0204832:	e8d2                	sd	s4,80(sp)
ffffffffc0204834:	e4d6                	sd	s5,72(sp)
ffffffffc0204836:	e0da                	sd	s6,64(sp)
ffffffffc0204838:	fc5e                	sd	s7,56(sp)
ffffffffc020483a:	f06a                	sd	s10,32(sp)
ffffffffc020483c:	fc86                	sd	ra,120(sp)
ffffffffc020483e:	f8a2                	sd	s0,112(sp)
ffffffffc0204840:	f862                	sd	s8,48(sp)
ffffffffc0204842:	f466                	sd	s9,40(sp)
ffffffffc0204844:	ec6e                	sd	s11,24(sp)
ffffffffc0204846:	892a                	mv	s2,a0
ffffffffc0204848:	84ae                	mv	s1,a1
ffffffffc020484a:	8d32                	mv	s10,a2
ffffffffc020484c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020484e:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204852:	5b7d                	li	s6,-1
ffffffffc0204854:	00002a97          	auipc	s5,0x2
ffffffffc0204858:	240a8a93          	addi	s5,s5,576 # ffffffffc0206a94 <default_pmm_manager+0x274>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020485c:	00002b97          	auipc	s7,0x2
ffffffffc0204860:	414b8b93          	addi	s7,s7,1044 # ffffffffc0206c70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204864:	000d4503          	lbu	a0,0(s10)
ffffffffc0204868:	001d0413          	addi	s0,s10,1
ffffffffc020486c:	01350a63          	beq	a0,s3,ffffffffc0204880 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204870:	c121                	beqz	a0,ffffffffc02048b0 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204872:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204874:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204876:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204878:	fff44503          	lbu	a0,-1(s0)
ffffffffc020487c:	ff351ae3          	bne	a0,s3,ffffffffc0204870 <vprintfmt+0x46>
ffffffffc0204880:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0204884:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204888:	4c81                	li	s9,0
ffffffffc020488a:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020488c:	5c7d                	li	s8,-1
ffffffffc020488e:	5dfd                	li	s11,-1
ffffffffc0204890:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0204894:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204896:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020489a:	0ff5f593          	andi	a1,a1,255
ffffffffc020489e:	00140d13          	addi	s10,s0,1
ffffffffc02048a2:	04b56263          	bltu	a0,a1,ffffffffc02048e6 <vprintfmt+0xbc>
ffffffffc02048a6:	058a                	slli	a1,a1,0x2
ffffffffc02048a8:	95d6                	add	a1,a1,s5
ffffffffc02048aa:	4194                	lw	a3,0(a1)
ffffffffc02048ac:	96d6                	add	a3,a3,s5
ffffffffc02048ae:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02048b0:	70e6                	ld	ra,120(sp)
ffffffffc02048b2:	7446                	ld	s0,112(sp)
ffffffffc02048b4:	74a6                	ld	s1,104(sp)
ffffffffc02048b6:	7906                	ld	s2,96(sp)
ffffffffc02048b8:	69e6                	ld	s3,88(sp)
ffffffffc02048ba:	6a46                	ld	s4,80(sp)
ffffffffc02048bc:	6aa6                	ld	s5,72(sp)
ffffffffc02048be:	6b06                	ld	s6,64(sp)
ffffffffc02048c0:	7be2                	ld	s7,56(sp)
ffffffffc02048c2:	7c42                	ld	s8,48(sp)
ffffffffc02048c4:	7ca2                	ld	s9,40(sp)
ffffffffc02048c6:	7d02                	ld	s10,32(sp)
ffffffffc02048c8:	6de2                	ld	s11,24(sp)
ffffffffc02048ca:	6109                	addi	sp,sp,128
ffffffffc02048cc:	8082                	ret
            padc = '0';
ffffffffc02048ce:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02048d0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02048d4:	846a                	mv	s0,s10
ffffffffc02048d6:	00140d13          	addi	s10,s0,1
ffffffffc02048da:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02048de:	0ff5f593          	andi	a1,a1,255
ffffffffc02048e2:	fcb572e3          	bgeu	a0,a1,ffffffffc02048a6 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02048e6:	85a6                	mv	a1,s1
ffffffffc02048e8:	02500513          	li	a0,37
ffffffffc02048ec:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02048ee:	fff44783          	lbu	a5,-1(s0)
ffffffffc02048f2:	8d22                	mv	s10,s0
ffffffffc02048f4:	f73788e3          	beq	a5,s3,ffffffffc0204864 <vprintfmt+0x3a>
ffffffffc02048f8:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02048fc:	1d7d                	addi	s10,s10,-1
ffffffffc02048fe:	ff379de3          	bne	a5,s3,ffffffffc02048f8 <vprintfmt+0xce>
ffffffffc0204902:	b78d                	j	ffffffffc0204864 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0204904:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204908:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020490c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020490e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204912:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204916:	02d86463          	bltu	a6,a3,ffffffffc020493e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020491a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020491e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0204922:	0186873b          	addw	a4,a3,s8
ffffffffc0204926:	0017171b          	slliw	a4,a4,0x1
ffffffffc020492a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020492c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0204930:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204932:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204936:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020493a:	fed870e3          	bgeu	a6,a3,ffffffffc020491a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020493e:	f40ddce3          	bgez	s11,ffffffffc0204896 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204942:	8de2                	mv	s11,s8
ffffffffc0204944:	5c7d                	li	s8,-1
ffffffffc0204946:	bf81                	j	ffffffffc0204896 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204948:	fffdc693          	not	a3,s11
ffffffffc020494c:	96fd                	srai	a3,a3,0x3f
ffffffffc020494e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204952:	00144603          	lbu	a2,1(s0)
ffffffffc0204956:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204958:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020495a:	bf35                	j	ffffffffc0204896 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020495c:	000a2c03          	lw	s8,0(s4)
            goto process_precision;
ffffffffc0204960:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204964:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204966:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204968:	bfd9                	j	ffffffffc020493e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020496a:	4705                	li	a4,1
ffffffffc020496c:	008a0593          	addi	a1,s4,8
ffffffffc0204970:	01174463          	blt	a4,a7,ffffffffc0204978 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0204974:	1a088e63          	beqz	a7,ffffffffc0204b30 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204978:	000a3603          	ld	a2,0(s4)
ffffffffc020497c:	46c1                	li	a3,16
ffffffffc020497e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204980:	2781                	sext.w	a5,a5
ffffffffc0204982:	876e                	mv	a4,s11
ffffffffc0204984:	85a6                	mv	a1,s1
ffffffffc0204986:	854a                	mv	a0,s2
ffffffffc0204988:	e37ff0ef          	jal	ra,ffffffffc02047be <printnum>
            break;
ffffffffc020498c:	bde1                	j	ffffffffc0204864 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020498e:	000a2503          	lw	a0,0(s4)
ffffffffc0204992:	85a6                	mv	a1,s1
ffffffffc0204994:	0a21                	addi	s4,s4,8
ffffffffc0204996:	9902                	jalr	s2
            break;
ffffffffc0204998:	b5f1                	j	ffffffffc0204864 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020499a:	4705                	li	a4,1
ffffffffc020499c:	008a0593          	addi	a1,s4,8
ffffffffc02049a0:	01174463          	blt	a4,a7,ffffffffc02049a8 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02049a4:	18088163          	beqz	a7,ffffffffc0204b26 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02049a8:	000a3603          	ld	a2,0(s4)
ffffffffc02049ac:	46a9                	li	a3,10
ffffffffc02049ae:	8a2e                	mv	s4,a1
ffffffffc02049b0:	bfc1                	j	ffffffffc0204980 <vprintfmt+0x156>
            goto reswitch;
ffffffffc02049b2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02049b6:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02049ba:	bdf1                	j	ffffffffc0204896 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02049bc:	85a6                	mv	a1,s1
ffffffffc02049be:	02500513          	li	a0,37
ffffffffc02049c2:	9902                	jalr	s2
            break;
ffffffffc02049c4:	b545                	j	ffffffffc0204864 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02049c6:	00144603          	lbu	a2,1(s0)
ffffffffc02049ca:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049cc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02049ce:	b5e1                	j	ffffffffc0204896 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02049d0:	4705                	li	a4,1
ffffffffc02049d2:	008a0593          	addi	a1,s4,8
ffffffffc02049d6:	01174463          	blt	a4,a7,ffffffffc02049de <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02049da:	14088163          	beqz	a7,ffffffffc0204b1c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02049de:	000a3603          	ld	a2,0(s4)
ffffffffc02049e2:	46a1                	li	a3,8
ffffffffc02049e4:	8a2e                	mv	s4,a1
ffffffffc02049e6:	bf69                	j	ffffffffc0204980 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02049e8:	03000513          	li	a0,48
ffffffffc02049ec:	85a6                	mv	a1,s1
ffffffffc02049ee:	e03e                	sd	a5,0(sp)
ffffffffc02049f0:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02049f2:	85a6                	mv	a1,s1
ffffffffc02049f4:	07800513          	li	a0,120
ffffffffc02049f8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02049fa:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02049fc:	6782                	ld	a5,0(sp)
ffffffffc02049fe:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204a00:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0204a04:	bfb5                	j	ffffffffc0204980 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204a06:	000a3403          	ld	s0,0(s4)
ffffffffc0204a0a:	008a0713          	addi	a4,s4,8
ffffffffc0204a0e:	e03a                	sd	a4,0(sp)
ffffffffc0204a10:	14040263          	beqz	s0,ffffffffc0204b54 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0204a14:	0fb05763          	blez	s11,ffffffffc0204b02 <vprintfmt+0x2d8>
ffffffffc0204a18:	02d00693          	li	a3,45
ffffffffc0204a1c:	0cd79163          	bne	a5,a3,ffffffffc0204ade <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204a20:	00044783          	lbu	a5,0(s0)
ffffffffc0204a24:	0007851b          	sext.w	a0,a5
ffffffffc0204a28:	cf85                	beqz	a5,ffffffffc0204a60 <vprintfmt+0x236>
ffffffffc0204a2a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204a2e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204a32:	000c4563          	bltz	s8,ffffffffc0204a3c <vprintfmt+0x212>
ffffffffc0204a36:	3c7d                	addiw	s8,s8,-1
ffffffffc0204a38:	036c0263          	beq	s8,s6,ffffffffc0204a5c <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204a3c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204a3e:	0e0c8e63          	beqz	s9,ffffffffc0204b3a <vprintfmt+0x310>
ffffffffc0204a42:	3781                	addiw	a5,a5,-32
ffffffffc0204a44:	0ef47b63          	bgeu	s0,a5,ffffffffc0204b3a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204a48:	03f00513          	li	a0,63
ffffffffc0204a4c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204a4e:	000a4783          	lbu	a5,0(s4)
ffffffffc0204a52:	3dfd                	addiw	s11,s11,-1
ffffffffc0204a54:	0a05                	addi	s4,s4,1
ffffffffc0204a56:	0007851b          	sext.w	a0,a5
ffffffffc0204a5a:	ffe1                	bnez	a5,ffffffffc0204a32 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204a5c:	01b05963          	blez	s11,ffffffffc0204a6e <vprintfmt+0x244>
ffffffffc0204a60:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204a62:	85a6                	mv	a1,s1
ffffffffc0204a64:	02000513          	li	a0,32
ffffffffc0204a68:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204a6a:	fe0d9be3          	bnez	s11,ffffffffc0204a60 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204a6e:	6a02                	ld	s4,0(sp)
ffffffffc0204a70:	bbd5                	j	ffffffffc0204864 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204a72:	4705                	li	a4,1
ffffffffc0204a74:	008a0c93          	addi	s9,s4,8
ffffffffc0204a78:	01174463          	blt	a4,a7,ffffffffc0204a80 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204a7c:	08088d63          	beqz	a7,ffffffffc0204b16 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204a80:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0204a84:	0a044d63          	bltz	s0,ffffffffc0204b3e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204a88:	8622                	mv	a2,s0
ffffffffc0204a8a:	8a66                	mv	s4,s9
ffffffffc0204a8c:	46a9                	li	a3,10
ffffffffc0204a8e:	bdcd                	j	ffffffffc0204980 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204a90:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204a94:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0204a96:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0204a98:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204a9c:	8fb5                	xor	a5,a5,a3
ffffffffc0204a9e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204aa2:	02d74163          	blt	a4,a3,ffffffffc0204ac4 <vprintfmt+0x29a>
ffffffffc0204aa6:	00369793          	slli	a5,a3,0x3
ffffffffc0204aaa:	97de                	add	a5,a5,s7
ffffffffc0204aac:	639c                	ld	a5,0(a5)
ffffffffc0204aae:	cb99                	beqz	a5,ffffffffc0204ac4 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204ab0:	86be                	mv	a3,a5
ffffffffc0204ab2:	00000617          	auipc	a2,0x0
ffffffffc0204ab6:	13e60613          	addi	a2,a2,318 # ffffffffc0204bf0 <etext+0x2e>
ffffffffc0204aba:	85a6                	mv	a1,s1
ffffffffc0204abc:	854a                	mv	a0,s2
ffffffffc0204abe:	0ce000ef          	jal	ra,ffffffffc0204b8c <printfmt>
ffffffffc0204ac2:	b34d                	j	ffffffffc0204864 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204ac4:	00002617          	auipc	a2,0x2
ffffffffc0204ac8:	fc460613          	addi	a2,a2,-60 # ffffffffc0206a88 <default_pmm_manager+0x268>
ffffffffc0204acc:	85a6                	mv	a1,s1
ffffffffc0204ace:	854a                	mv	a0,s2
ffffffffc0204ad0:	0bc000ef          	jal	ra,ffffffffc0204b8c <printfmt>
ffffffffc0204ad4:	bb41                	j	ffffffffc0204864 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204ad6:	00002417          	auipc	s0,0x2
ffffffffc0204ada:	faa40413          	addi	s0,s0,-86 # ffffffffc0206a80 <default_pmm_manager+0x260>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204ade:	85e2                	mv	a1,s8
ffffffffc0204ae0:	8522                	mv	a0,s0
ffffffffc0204ae2:	e43e                	sd	a5,8(sp)
ffffffffc0204ae4:	c2bff0ef          	jal	ra,ffffffffc020470e <strnlen>
ffffffffc0204ae8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204aec:	01b05b63          	blez	s11,ffffffffc0204b02 <vprintfmt+0x2d8>
ffffffffc0204af0:	67a2                	ld	a5,8(sp)
ffffffffc0204af2:	00078a1b          	sext.w	s4,a5
ffffffffc0204af6:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204af8:	85a6                	mv	a1,s1
ffffffffc0204afa:	8552                	mv	a0,s4
ffffffffc0204afc:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204afe:	fe0d9ce3          	bnez	s11,ffffffffc0204af6 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b02:	00044783          	lbu	a5,0(s0)
ffffffffc0204b06:	00140a13          	addi	s4,s0,1
ffffffffc0204b0a:	0007851b          	sext.w	a0,a5
ffffffffc0204b0e:	d3a5                	beqz	a5,ffffffffc0204a6e <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b10:	05e00413          	li	s0,94
ffffffffc0204b14:	bf39                	j	ffffffffc0204a32 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204b16:	000a2403          	lw	s0,0(s4)
ffffffffc0204b1a:	b7ad                	j	ffffffffc0204a84 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204b1c:	000a6603          	lwu	a2,0(s4)
ffffffffc0204b20:	46a1                	li	a3,8
ffffffffc0204b22:	8a2e                	mv	s4,a1
ffffffffc0204b24:	bdb1                	j	ffffffffc0204980 <vprintfmt+0x156>
ffffffffc0204b26:	000a6603          	lwu	a2,0(s4)
ffffffffc0204b2a:	46a9                	li	a3,10
ffffffffc0204b2c:	8a2e                	mv	s4,a1
ffffffffc0204b2e:	bd89                	j	ffffffffc0204980 <vprintfmt+0x156>
ffffffffc0204b30:	000a6603          	lwu	a2,0(s4)
ffffffffc0204b34:	46c1                	li	a3,16
ffffffffc0204b36:	8a2e                	mv	s4,a1
ffffffffc0204b38:	b5a1                	j	ffffffffc0204980 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204b3a:	9902                	jalr	s2
ffffffffc0204b3c:	bf09                	j	ffffffffc0204a4e <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204b3e:	85a6                	mv	a1,s1
ffffffffc0204b40:	02d00513          	li	a0,45
ffffffffc0204b44:	e03e                	sd	a5,0(sp)
ffffffffc0204b46:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204b48:	6782                	ld	a5,0(sp)
ffffffffc0204b4a:	8a66                	mv	s4,s9
ffffffffc0204b4c:	40800633          	neg	a2,s0
ffffffffc0204b50:	46a9                	li	a3,10
ffffffffc0204b52:	b53d                	j	ffffffffc0204980 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0204b54:	03b05163          	blez	s11,ffffffffc0204b76 <vprintfmt+0x34c>
ffffffffc0204b58:	02d00693          	li	a3,45
ffffffffc0204b5c:	f6d79de3          	bne	a5,a3,ffffffffc0204ad6 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204b60:	00002417          	auipc	s0,0x2
ffffffffc0204b64:	f2040413          	addi	s0,s0,-224 # ffffffffc0206a80 <default_pmm_manager+0x260>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204b68:	02800793          	li	a5,40
ffffffffc0204b6c:	02800513          	li	a0,40
ffffffffc0204b70:	00140a13          	addi	s4,s0,1
ffffffffc0204b74:	bd6d                	j	ffffffffc0204a2e <vprintfmt+0x204>
ffffffffc0204b76:	00002a17          	auipc	s4,0x2
ffffffffc0204b7a:	f0ba0a13          	addi	s4,s4,-245 # ffffffffc0206a81 <default_pmm_manager+0x261>
ffffffffc0204b7e:	02800513          	li	a0,40
ffffffffc0204b82:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204b86:	05e00413          	li	s0,94
ffffffffc0204b8a:	b565                	j	ffffffffc0204a32 <vprintfmt+0x208>

ffffffffc0204b8c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204b8c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204b8e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204b92:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204b94:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204b96:	ec06                	sd	ra,24(sp)
ffffffffc0204b98:	f83a                	sd	a4,48(sp)
ffffffffc0204b9a:	fc3e                	sd	a5,56(sp)
ffffffffc0204b9c:	e0c2                	sd	a6,64(sp)
ffffffffc0204b9e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204ba0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204ba2:	c89ff0ef          	jal	ra,ffffffffc020482a <vprintfmt>
}
ffffffffc0204ba6:	60e2                	ld	ra,24(sp)
ffffffffc0204ba8:	6161                	addi	sp,sp,80
ffffffffc0204baa:	8082                	ret

ffffffffc0204bac <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204bac:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204bb0:	2785                	addiw	a5,a5,1
ffffffffc0204bb2:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0204bb6:	02000793          	li	a5,32
ffffffffc0204bba:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204bbc:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204bc0:	8082                	ret
