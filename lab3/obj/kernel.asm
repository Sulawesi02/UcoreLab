
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
ffffffffc0200020:	18029073          	csrw	satp,t0
ffffffffc0200024:	12000073          	sfence.vma
ffffffffc0200028:	c0209137          	lui	sp,0xc0209
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	01250513          	addi	a0,a0,18 # ffffffffc020a048 <ide>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	56260613          	addi	a2,a2,1378 # ffffffffc02115a0 <end>
ffffffffc0200046:	1141                	addi	sp,sp,-16
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
ffffffffc020004c:	e406                	sd	ra,8(sp)
ffffffffc020004e:	613030ef          	jal	ra,ffffffffc0203e60 <memset>
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2ee58593          	addi	a1,a1,750 # ffffffffc0204340 <etext>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	30650513          	addi	a0,a0,774 # ffffffffc0204360 <etext+0x20>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200066:	0fe000ef          	jal	ra,ffffffffc0200164 <print_kerninfo>
ffffffffc020006a:	36a010ef          	jal	ra,ffffffffc02013d4 <pmm_init>
ffffffffc020006e:	4fc000ef          	jal	ra,ffffffffc020056a <idt_init>
ffffffffc0200072:	236020ef          	jal	ra,ffffffffc02022a8 <vmm_init>
ffffffffc0200076:	35a000ef          	jal	ra,ffffffffc02003d0 <ide_init>
ffffffffc020007a:	041020ef          	jal	ra,ffffffffc02028ba <swap_init>
ffffffffc020007e:	3aa000ef          	jal	ra,ffffffffc0200428 <clock_init>
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
ffffffffc020008c:	3f0000ef          	jal	ra,ffffffffc020047c <cons_putc>
ffffffffc0200090:	401c                	lw	a5,0(s0)
ffffffffc0200092:	60a2                	ld	ra,8(sp)
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
ffffffffc020009e:	1101                	addi	sp,sp,-32
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
ffffffffc02000b0:	c602                	sw	zero,12(sp)
ffffffffc02000b2:	645030ef          	jal	ra,ffffffffc0203ef6 <vprintfmt>
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
ffffffffc02000be:	711d                	addi	sp,sp,-96
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
ffffffffc02000e4:	c202                	sw	zero,4(sp)
ffffffffc02000e6:	611030ef          	jal	ra,ffffffffc0203ef6 <vprintfmt>
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:
ffffffffc02000f2:	a669                	j	ffffffffc020047c <cons_putc>

ffffffffc02000f4 <getchar>:
ffffffffc02000f4:	1141                	addi	sp,sp,-16
ffffffffc02000f6:	e406                	sd	ra,8(sp)
ffffffffc02000f8:	3b8000ef          	jal	ra,ffffffffc02004b0 <cons_getc>
ffffffffc02000fc:	dd75                	beqz	a0,ffffffffc02000f8 <getchar+0x4>
ffffffffc02000fe:	60a2                	ld	ra,8(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <__panic>:
ffffffffc0200104:	00011317          	auipc	t1,0x11
ffffffffc0200108:	34430313          	addi	t1,t1,836 # ffffffffc0211448 <is_panic>
ffffffffc020010c:	00032303          	lw	t1,0(t1)
ffffffffc0200110:	715d                	addi	sp,sp,-80
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e822                	sd	s0,16(sp)
ffffffffc0200116:	f436                	sd	a3,40(sp)
ffffffffc0200118:	f83a                	sd	a4,48(sp)
ffffffffc020011a:	fc3e                	sd	a5,56(sp)
ffffffffc020011c:	e0c2                	sd	a6,64(sp)
ffffffffc020011e:	e4c6                	sd	a7,72(sp)
ffffffffc0200120:	02031c63          	bnez	t1,ffffffffc0200158 <__panic+0x54>
ffffffffc0200124:	4785                	li	a5,1
ffffffffc0200126:	8432                	mv	s0,a2
ffffffffc0200128:	00011717          	auipc	a4,0x11
ffffffffc020012c:	32f72023          	sw	a5,800(a4) # ffffffffc0211448 <is_panic>
ffffffffc0200130:	862e                	mv	a2,a1
ffffffffc0200132:	103c                	addi	a5,sp,40
ffffffffc0200134:	85aa                	mv	a1,a0
ffffffffc0200136:	00004517          	auipc	a0,0x4
ffffffffc020013a:	23250513          	addi	a0,a0,562 # ffffffffc0204368 <etext+0x28>
ffffffffc020013e:	e43e                	sd	a5,8(sp)
ffffffffc0200140:	f7fff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200144:	65a2                	ld	a1,8(sp)
ffffffffc0200146:	8522                	mv	a0,s0
ffffffffc0200148:	f57ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
ffffffffc020014c:	00005517          	auipc	a0,0x5
ffffffffc0200150:	20c50513          	addi	a0,a0,524 # ffffffffc0205358 <commands+0xed0>
ffffffffc0200154:	f6bff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200158:	39a000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020015c:	4501                	li	a0,0
ffffffffc020015e:	130000ef          	jal	ra,ffffffffc020028e <kmonitor>
ffffffffc0200162:	bfed                	j	ffffffffc020015c <__panic+0x58>

ffffffffc0200164 <print_kerninfo>:
ffffffffc0200164:	1141                	addi	sp,sp,-16
ffffffffc0200166:	00004517          	auipc	a0,0x4
ffffffffc020016a:	25250513          	addi	a0,a0,594 # ffffffffc02043b8 <etext+0x78>
ffffffffc020016e:	e406                	sd	ra,8(sp)
ffffffffc0200170:	f4fff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200174:	00000597          	auipc	a1,0x0
ffffffffc0200178:	ec258593          	addi	a1,a1,-318 # ffffffffc0200036 <kern_init>
ffffffffc020017c:	00004517          	auipc	a0,0x4
ffffffffc0200180:	25c50513          	addi	a0,a0,604 # ffffffffc02043d8 <etext+0x98>
ffffffffc0200184:	f3bff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200188:	00004597          	auipc	a1,0x4
ffffffffc020018c:	1b858593          	addi	a1,a1,440 # ffffffffc0204340 <etext>
ffffffffc0200190:	00004517          	auipc	a0,0x4
ffffffffc0200194:	26850513          	addi	a0,a0,616 # ffffffffc02043f8 <etext+0xb8>
ffffffffc0200198:	f27ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020019c:	0000a597          	auipc	a1,0xa
ffffffffc02001a0:	eac58593          	addi	a1,a1,-340 # ffffffffc020a048 <ide>
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	27450513          	addi	a0,a0,628 # ffffffffc0204418 <etext+0xd8>
ffffffffc02001ac:	f13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001b0:	00011597          	auipc	a1,0x11
ffffffffc02001b4:	3f058593          	addi	a1,a1,1008 # ffffffffc02115a0 <end>
ffffffffc02001b8:	00004517          	auipc	a0,0x4
ffffffffc02001bc:	28050513          	addi	a0,a0,640 # ffffffffc0204438 <etext+0xf8>
ffffffffc02001c0:	effff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001c4:	00011597          	auipc	a1,0x11
ffffffffc02001c8:	7db58593          	addi	a1,a1,2011 # ffffffffc021199f <end+0x3ff>
ffffffffc02001cc:	00000797          	auipc	a5,0x0
ffffffffc02001d0:	e6a78793          	addi	a5,a5,-406 # ffffffffc0200036 <kern_init>
ffffffffc02001d4:	40f587b3          	sub	a5,a1,a5
ffffffffc02001d8:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02001dc:	60a2                	ld	ra,8(sp)
ffffffffc02001de:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001e2:	95be                	add	a1,a1,a5
ffffffffc02001e4:	85a9                	srai	a1,a1,0xa
ffffffffc02001e6:	00004517          	auipc	a0,0x4
ffffffffc02001ea:	27250513          	addi	a0,a0,626 # ffffffffc0204458 <etext+0x118>
ffffffffc02001ee:	0141                	addi	sp,sp,16
ffffffffc02001f0:	b5f9                	j	ffffffffc02000be <cprintf>

ffffffffc02001f2 <print_stackframe>:
ffffffffc02001f2:	1141                	addi	sp,sp,-16
ffffffffc02001f4:	00004617          	auipc	a2,0x4
ffffffffc02001f8:	19460613          	addi	a2,a2,404 # ffffffffc0204388 <etext+0x48>
ffffffffc02001fc:	04e00593          	li	a1,78
ffffffffc0200200:	00004517          	auipc	a0,0x4
ffffffffc0200204:	1a050513          	addi	a0,a0,416 # ffffffffc02043a0 <etext+0x60>
ffffffffc0200208:	e406                	sd	ra,8(sp)
ffffffffc020020a:	efbff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020020e <mon_help>:
ffffffffc020020e:	1141                	addi	sp,sp,-16
ffffffffc0200210:	00004617          	auipc	a2,0x4
ffffffffc0200214:	35060613          	addi	a2,a2,848 # ffffffffc0204560 <commands+0xd8>
ffffffffc0200218:	00004597          	auipc	a1,0x4
ffffffffc020021c:	36858593          	addi	a1,a1,872 # ffffffffc0204580 <commands+0xf8>
ffffffffc0200220:	00004517          	auipc	a0,0x4
ffffffffc0200224:	36850513          	addi	a0,a0,872 # ffffffffc0204588 <commands+0x100>
ffffffffc0200228:	e406                	sd	ra,8(sp)
ffffffffc020022a:	e95ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020022e:	00004617          	auipc	a2,0x4
ffffffffc0200232:	36a60613          	addi	a2,a2,874 # ffffffffc0204598 <commands+0x110>
ffffffffc0200236:	00004597          	auipc	a1,0x4
ffffffffc020023a:	38a58593          	addi	a1,a1,906 # ffffffffc02045c0 <commands+0x138>
ffffffffc020023e:	00004517          	auipc	a0,0x4
ffffffffc0200242:	34a50513          	addi	a0,a0,842 # ffffffffc0204588 <commands+0x100>
ffffffffc0200246:	e79ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020024a:	00004617          	auipc	a2,0x4
ffffffffc020024e:	38660613          	addi	a2,a2,902 # ffffffffc02045d0 <commands+0x148>
ffffffffc0200252:	00004597          	auipc	a1,0x4
ffffffffc0200256:	39e58593          	addi	a1,a1,926 # ffffffffc02045f0 <commands+0x168>
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	32e50513          	addi	a0,a0,814 # ffffffffc0204588 <commands+0x100>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200266:	60a2                	ld	ra,8(sp)
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	0141                	addi	sp,sp,16
ffffffffc020026c:	8082                	ret

ffffffffc020026e <mon_kerninfo>:
ffffffffc020026e:	1141                	addi	sp,sp,-16
ffffffffc0200270:	e406                	sd	ra,8(sp)
ffffffffc0200272:	ef3ff0ef          	jal	ra,ffffffffc0200164 <print_kerninfo>
ffffffffc0200276:	60a2                	ld	ra,8(sp)
ffffffffc0200278:	4501                	li	a0,0
ffffffffc020027a:	0141                	addi	sp,sp,16
ffffffffc020027c:	8082                	ret

ffffffffc020027e <mon_backtrace>:
ffffffffc020027e:	1141                	addi	sp,sp,-16
ffffffffc0200280:	e406                	sd	ra,8(sp)
ffffffffc0200282:	f71ff0ef          	jal	ra,ffffffffc02001f2 <print_stackframe>
ffffffffc0200286:	60a2                	ld	ra,8(sp)
ffffffffc0200288:	4501                	li	a0,0
ffffffffc020028a:	0141                	addi	sp,sp,16
ffffffffc020028c:	8082                	ret

ffffffffc020028e <kmonitor>:
ffffffffc020028e:	7115                	addi	sp,sp,-224
ffffffffc0200290:	e962                	sd	s8,144(sp)
ffffffffc0200292:	8c2a                	mv	s8,a0
ffffffffc0200294:	00004517          	auipc	a0,0x4
ffffffffc0200298:	23c50513          	addi	a0,a0,572 # ffffffffc02044d0 <commands+0x48>
ffffffffc020029c:	ed86                	sd	ra,216(sp)
ffffffffc020029e:	e9a2                	sd	s0,208(sp)
ffffffffc02002a0:	e5a6                	sd	s1,200(sp)
ffffffffc02002a2:	e1ca                	sd	s2,192(sp)
ffffffffc02002a4:	fd4e                	sd	s3,184(sp)
ffffffffc02002a6:	f952                	sd	s4,176(sp)
ffffffffc02002a8:	f556                	sd	s5,168(sp)
ffffffffc02002aa:	f15a                	sd	s6,160(sp)
ffffffffc02002ac:	ed5e                	sd	s7,152(sp)
ffffffffc02002ae:	e566                	sd	s9,136(sp)
ffffffffc02002b0:	e16a                	sd	s10,128(sp)
ffffffffc02002b2:	e0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02002b6:	00004517          	auipc	a0,0x4
ffffffffc02002ba:	24250513          	addi	a0,a0,578 # ffffffffc02044f8 <commands+0x70>
ffffffffc02002be:	e01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02002c2:	000c0563          	beqz	s8,ffffffffc02002cc <kmonitor+0x3e>
ffffffffc02002c6:	8562                	mv	a0,s8
ffffffffc02002c8:	48c000ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc02002cc:	00004c97          	auipc	s9,0x4
ffffffffc02002d0:	1bcc8c93          	addi	s9,s9,444 # ffffffffc0204488 <commands>
ffffffffc02002d4:	00006997          	auipc	s3,0x6
ffffffffc02002d8:	82498993          	addi	s3,s3,-2012 # ffffffffc0205af8 <commands+0x1670>
ffffffffc02002dc:	00004917          	auipc	s2,0x4
ffffffffc02002e0:	24490913          	addi	s2,s2,580 # ffffffffc0204520 <commands+0x98>
ffffffffc02002e4:	4a3d                	li	s4,15
ffffffffc02002e6:	00004b17          	auipc	s6,0x4
ffffffffc02002ea:	242b0b13          	addi	s6,s6,578 # ffffffffc0204528 <commands+0xa0>
ffffffffc02002ee:	00004a97          	auipc	s5,0x4
ffffffffc02002f2:	292a8a93          	addi	s5,s5,658 # ffffffffc0204580 <commands+0xf8>
ffffffffc02002f6:	4b8d                	li	s7,3
ffffffffc02002f8:	854e                	mv	a0,s3
ffffffffc02002fa:	789030ef          	jal	ra,ffffffffc0204282 <readline>
ffffffffc02002fe:	842a                	mv	s0,a0
ffffffffc0200300:	dd65                	beqz	a0,ffffffffc02002f8 <kmonitor+0x6a>
ffffffffc0200302:	00054583          	lbu	a1,0(a0)
ffffffffc0200306:	4481                	li	s1,0
ffffffffc0200308:	c999                	beqz	a1,ffffffffc020031e <kmonitor+0x90>
ffffffffc020030a:	854a                	mv	a0,s2
ffffffffc020030c:	337030ef          	jal	ra,ffffffffc0203e42 <strchr>
ffffffffc0200310:	c925                	beqz	a0,ffffffffc0200380 <kmonitor+0xf2>
ffffffffc0200312:	00144583          	lbu	a1,1(s0)
ffffffffc0200316:	00040023          	sb	zero,0(s0)
ffffffffc020031a:	0405                	addi	s0,s0,1
ffffffffc020031c:	f5fd                	bnez	a1,ffffffffc020030a <kmonitor+0x7c>
ffffffffc020031e:	dce9                	beqz	s1,ffffffffc02002f8 <kmonitor+0x6a>
ffffffffc0200320:	6582                	ld	a1,0(sp)
ffffffffc0200322:	00004d17          	auipc	s10,0x4
ffffffffc0200326:	166d0d13          	addi	s10,s10,358 # ffffffffc0204488 <commands>
ffffffffc020032a:	8556                	mv	a0,s5
ffffffffc020032c:	4401                	li	s0,0
ffffffffc020032e:	0d61                	addi	s10,s10,24
ffffffffc0200330:	2e9030ef          	jal	ra,ffffffffc0203e18 <strcmp>
ffffffffc0200334:	c919                	beqz	a0,ffffffffc020034a <kmonitor+0xbc>
ffffffffc0200336:	2405                	addiw	s0,s0,1
ffffffffc0200338:	09740463          	beq	s0,s7,ffffffffc02003c0 <kmonitor+0x132>
ffffffffc020033c:	000d3503          	ld	a0,0(s10)
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	0d61                	addi	s10,s10,24
ffffffffc0200344:	2d5030ef          	jal	ra,ffffffffc0203e18 <strcmp>
ffffffffc0200348:	f57d                	bnez	a0,ffffffffc0200336 <kmonitor+0xa8>
ffffffffc020034a:	00141793          	slli	a5,s0,0x1
ffffffffc020034e:	97a2                	add	a5,a5,s0
ffffffffc0200350:	078e                	slli	a5,a5,0x3
ffffffffc0200352:	97e6                	add	a5,a5,s9
ffffffffc0200354:	6b9c                	ld	a5,16(a5)
ffffffffc0200356:	8662                	mv	a2,s8
ffffffffc0200358:	002c                	addi	a1,sp,8
ffffffffc020035a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020035e:	9782                	jalr	a5
ffffffffc0200360:	f8055ce3          	bgez	a0,ffffffffc02002f8 <kmonitor+0x6a>
ffffffffc0200364:	60ee                	ld	ra,216(sp)
ffffffffc0200366:	644e                	ld	s0,208(sp)
ffffffffc0200368:	64ae                	ld	s1,200(sp)
ffffffffc020036a:	690e                	ld	s2,192(sp)
ffffffffc020036c:	79ea                	ld	s3,184(sp)
ffffffffc020036e:	7a4a                	ld	s4,176(sp)
ffffffffc0200370:	7aaa                	ld	s5,168(sp)
ffffffffc0200372:	7b0a                	ld	s6,160(sp)
ffffffffc0200374:	6bea                	ld	s7,152(sp)
ffffffffc0200376:	6c4a                	ld	s8,144(sp)
ffffffffc0200378:	6caa                	ld	s9,136(sp)
ffffffffc020037a:	6d0a                	ld	s10,128(sp)
ffffffffc020037c:	612d                	addi	sp,sp,224
ffffffffc020037e:	8082                	ret
ffffffffc0200380:	00044783          	lbu	a5,0(s0)
ffffffffc0200384:	dfc9                	beqz	a5,ffffffffc020031e <kmonitor+0x90>
ffffffffc0200386:	03448863          	beq	s1,s4,ffffffffc02003b6 <kmonitor+0x128>
ffffffffc020038a:	00349793          	slli	a5,s1,0x3
ffffffffc020038e:	0118                	addi	a4,sp,128
ffffffffc0200390:	97ba                	add	a5,a5,a4
ffffffffc0200392:	f887b023          	sd	s0,-128(a5)
ffffffffc0200396:	00044583          	lbu	a1,0(s0)
ffffffffc020039a:	2485                	addiw	s1,s1,1
ffffffffc020039c:	e591                	bnez	a1,ffffffffc02003a8 <kmonitor+0x11a>
ffffffffc020039e:	b749                	j	ffffffffc0200320 <kmonitor+0x92>
ffffffffc02003a0:	0405                	addi	s0,s0,1
ffffffffc02003a2:	00044583          	lbu	a1,0(s0)
ffffffffc02003a6:	ddad                	beqz	a1,ffffffffc0200320 <kmonitor+0x92>
ffffffffc02003a8:	854a                	mv	a0,s2
ffffffffc02003aa:	299030ef          	jal	ra,ffffffffc0203e42 <strchr>
ffffffffc02003ae:	d96d                	beqz	a0,ffffffffc02003a0 <kmonitor+0x112>
ffffffffc02003b0:	00044583          	lbu	a1,0(s0)
ffffffffc02003b4:	bf91                	j	ffffffffc0200308 <kmonitor+0x7a>
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003be:	b7f1                	j	ffffffffc020038a <kmonitor+0xfc>
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	18650513          	addi	a0,a0,390 # ffffffffc0204548 <commands+0xc0>
ffffffffc02003ca:	cf5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02003ce:	b72d                	j	ffffffffc02002f8 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6a78793          	addi	a5,a5,-918 # ffffffffc020a048 <ide>
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
ffffffffc02003f4:	e406                	sd	ra,8(sp)
ffffffffc02003f6:	27d030ef          	jal	ra,ffffffffc0203e72 <memcpy>
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:
ffffffffc0200402:	8732                	mv	a4,a2
ffffffffc0200404:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200408:	0000a517          	auipc	a0,0xa
ffffffffc020040c:	c4050513          	addi	a0,a0,-960 # ffffffffc020a048 <ide>
ffffffffc0200410:	1141                	addi	sp,sp,-16
ffffffffc0200412:	00969613          	slli	a2,a3,0x9
ffffffffc0200416:	85ba                	mv	a1,a4
ffffffffc0200418:	953e                	add	a0,a0,a5
ffffffffc020041a:	e406                	sd	ra,8(sp)
ffffffffc020041c:	257030ef          	jal	ra,ffffffffc0203e72 <memcpy>
ffffffffc0200420:	60a2                	ld	ra,8(sp)
ffffffffc0200422:	4501                	li	a0,0
ffffffffc0200424:	0141                	addi	sp,sp,16
ffffffffc0200426:	8082                	ret

ffffffffc0200428 <clock_init>:
ffffffffc0200428:	67e1                	lui	a5,0x18
ffffffffc020042a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042e:	00011717          	auipc	a4,0x11
ffffffffc0200432:	02f73123          	sd	a5,34(a4) # ffffffffc0211450 <timebase>
ffffffffc0200436:	c0102573          	rdtime	a0
ffffffffc020043a:	4581                	li	a1,0
ffffffffc020043c:	953e                	add	a0,a0,a5
ffffffffc020043e:	4601                	li	a2,0
ffffffffc0200440:	4881                	li	a7,0
ffffffffc0200442:	00000073          	ecall
ffffffffc0200446:	02000793          	li	a5,32
ffffffffc020044a:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc020044e:	00004517          	auipc	a0,0x4
ffffffffc0200452:	1b250513          	addi	a0,a0,434 # ffffffffc0204600 <commands+0x178>
ffffffffc0200456:	00011797          	auipc	a5,0x11
ffffffffc020045a:	0207b523          	sd	zero,42(a5) # ffffffffc0211480 <ticks>
ffffffffc020045e:	b185                	j	ffffffffc02000be <cprintf>

ffffffffc0200460 <clock_set_next_event>:
ffffffffc0200460:	c0102573          	rdtime	a0
ffffffffc0200464:	00011797          	auipc	a5,0x11
ffffffffc0200468:	fec78793          	addi	a5,a5,-20 # ffffffffc0211450 <timebase>
ffffffffc020046c:	639c                	ld	a5,0(a5)
ffffffffc020046e:	4581                	li	a1,0
ffffffffc0200470:	4601                	li	a2,0
ffffffffc0200472:	953e                	add	a0,a0,a5
ffffffffc0200474:	4881                	li	a7,0
ffffffffc0200476:	00000073          	ecall
ffffffffc020047a:	8082                	ret

ffffffffc020047c <cons_putc>:
ffffffffc020047c:	100027f3          	csrr	a5,sstatus
ffffffffc0200480:	8b89                	andi	a5,a5,2
ffffffffc0200482:	0ff57513          	andi	a0,a0,255
ffffffffc0200486:	e799                	bnez	a5,ffffffffc0200494 <cons_putc+0x18>
ffffffffc0200488:	4581                	li	a1,0
ffffffffc020048a:	4601                	li	a2,0
ffffffffc020048c:	4885                	li	a7,1
ffffffffc020048e:	00000073          	ecall
ffffffffc0200492:	8082                	ret
ffffffffc0200494:	1101                	addi	sp,sp,-32
ffffffffc0200496:	ec06                	sd	ra,24(sp)
ffffffffc0200498:	e42a                	sd	a0,8(sp)
ffffffffc020049a:	058000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020049e:	6522                	ld	a0,8(sp)
ffffffffc02004a0:	4581                	li	a1,0
ffffffffc02004a2:	4601                	li	a2,0
ffffffffc02004a4:	4885                	li	a7,1
ffffffffc02004a6:	00000073          	ecall
ffffffffc02004aa:	60e2                	ld	ra,24(sp)
ffffffffc02004ac:	6105                	addi	sp,sp,32
ffffffffc02004ae:	a83d                	j	ffffffffc02004ec <intr_enable>

ffffffffc02004b0 <cons_getc>:
ffffffffc02004b0:	100027f3          	csrr	a5,sstatus
ffffffffc02004b4:	8b89                	andi	a5,a5,2
ffffffffc02004b6:	eb89                	bnez	a5,ffffffffc02004c8 <cons_getc+0x18>
ffffffffc02004b8:	4501                	li	a0,0
ffffffffc02004ba:	4581                	li	a1,0
ffffffffc02004bc:	4601                	li	a2,0
ffffffffc02004be:	4889                	li	a7,2
ffffffffc02004c0:	00000073          	ecall
ffffffffc02004c4:	2501                	sext.w	a0,a0
ffffffffc02004c6:	8082                	ret
ffffffffc02004c8:	1101                	addi	sp,sp,-32
ffffffffc02004ca:	ec06                	sd	ra,24(sp)
ffffffffc02004cc:	026000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc02004d0:	4501                	li	a0,0
ffffffffc02004d2:	4581                	li	a1,0
ffffffffc02004d4:	4601                	li	a2,0
ffffffffc02004d6:	4889                	li	a7,2
ffffffffc02004d8:	00000073          	ecall
ffffffffc02004dc:	2501                	sext.w	a0,a0
ffffffffc02004de:	e42a                	sd	a0,8(sp)
ffffffffc02004e0:	00c000ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02004e4:	60e2                	ld	ra,24(sp)
ffffffffc02004e6:	6522                	ld	a0,8(sp)
ffffffffc02004e8:	6105                	addi	sp,sp,32
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <intr_enable>:
ffffffffc02004ec:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <intr_disable>:
ffffffffc02004f2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <pgfault_handler>:
ffffffffc02004f8:	10053783          	ld	a5,256(a0)
ffffffffc02004fc:	1141                	addi	sp,sp,-16
ffffffffc02004fe:	e022                	sd	s0,0(sp)
ffffffffc0200500:	e406                	sd	ra,8(sp)
ffffffffc0200502:	1007f793          	andi	a5,a5,256
ffffffffc0200506:	842a                	mv	s0,a0
ffffffffc0200508:	11053583          	ld	a1,272(a0)
ffffffffc020050c:	05500613          	li	a2,85
ffffffffc0200510:	c399                	beqz	a5,ffffffffc0200516 <pgfault_handler+0x1e>
ffffffffc0200512:	04b00613          	li	a2,75
ffffffffc0200516:	11843703          	ld	a4,280(s0)
ffffffffc020051a:	47bd                	li	a5,15
ffffffffc020051c:	05700693          	li	a3,87
ffffffffc0200520:	00f70463          	beq	a4,a5,ffffffffc0200528 <pgfault_handler+0x30>
ffffffffc0200524:	05200693          	li	a3,82
ffffffffc0200528:	00004517          	auipc	a0,0x4
ffffffffc020052c:	3d050513          	addi	a0,a0,976 # ffffffffc02048f8 <commands+0x470>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200534:	00011797          	auipc	a5,0x11
ffffffffc0200538:	f8478793          	addi	a5,a5,-124 # ffffffffc02114b8 <check_mm_struct>
ffffffffc020053c:	6388                	ld	a0,0(a5)
ffffffffc020053e:	c911                	beqz	a0,ffffffffc0200552 <pgfault_handler+0x5a>
ffffffffc0200540:	11043603          	ld	a2,272(s0)
ffffffffc0200544:	11843583          	ld	a1,280(s0)
ffffffffc0200548:	6402                	ld	s0,0(sp)
ffffffffc020054a:	60a2                	ld	ra,8(sp)
ffffffffc020054c:	0141                	addi	sp,sp,16
ffffffffc020054e:	2980206f          	j	ffffffffc02027e6 <do_pgfault>
ffffffffc0200552:	00004617          	auipc	a2,0x4
ffffffffc0200556:	3c660613          	addi	a2,a2,966 # ffffffffc0204918 <commands+0x490>
ffffffffc020055a:	07800593          	li	a1,120
ffffffffc020055e:	00004517          	auipc	a0,0x4
ffffffffc0200562:	3d250513          	addi	a0,a0,978 # ffffffffc0204930 <commands+0x4a8>
ffffffffc0200566:	b9fff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020056a <idt_init>:
ffffffffc020056a:	14005073          	csrwi	sscratch,0
ffffffffc020056e:	00000797          	auipc	a5,0x0
ffffffffc0200572:	49278793          	addi	a5,a5,1170 # ffffffffc0200a00 <__alltraps>
ffffffffc0200576:	10579073          	csrw	stvec,a5
ffffffffc020057a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020057e:	000407b7          	lui	a5,0x40
ffffffffc0200582:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <print_regs>:
ffffffffc0200588:	610c                	ld	a1,0(a0)
ffffffffc020058a:	1141                	addi	sp,sp,-16
ffffffffc020058c:	e022                	sd	s0,0(sp)
ffffffffc020058e:	842a                	mv	s0,a0
ffffffffc0200590:	00004517          	auipc	a0,0x4
ffffffffc0200594:	3b850513          	addi	a0,a0,952 # ffffffffc0204948 <commands+0x4c0>
ffffffffc0200598:	e406                	sd	ra,8(sp)
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020059e:	640c                	ld	a1,8(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	3c050513          	addi	a0,a0,960 # ffffffffc0204960 <commands+0x4d8>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005ac:	680c                	ld	a1,16(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	3ca50513          	addi	a0,a0,970 # ffffffffc0204978 <commands+0x4f0>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005ba:	6c0c                	ld	a1,24(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	3d450513          	addi	a0,a0,980 # ffffffffc0204990 <commands+0x508>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005c8:	700c                	ld	a1,32(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	3de50513          	addi	a0,a0,990 # ffffffffc02049a8 <commands+0x520>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005d6:	740c                	ld	a1,40(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	3e850513          	addi	a0,a0,1000 # ffffffffc02049c0 <commands+0x538>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005e4:	780c                	ld	a1,48(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	3f250513          	addi	a0,a0,1010 # ffffffffc02049d8 <commands+0x550>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02005f2:	7c0c                	ld	a1,56(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	3fc50513          	addi	a0,a0,1020 # ffffffffc02049f0 <commands+0x568>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200600:	602c                	ld	a1,64(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	40650513          	addi	a0,a0,1030 # ffffffffc0204a08 <commands+0x580>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020060e:	642c                	ld	a1,72(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	41050513          	addi	a0,a0,1040 # ffffffffc0204a20 <commands+0x598>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020061c:	682c                	ld	a1,80(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	41a50513          	addi	a0,a0,1050 # ffffffffc0204a38 <commands+0x5b0>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020062a:	6c2c                	ld	a1,88(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	42450513          	addi	a0,a0,1060 # ffffffffc0204a50 <commands+0x5c8>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200638:	702c                	ld	a1,96(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	42e50513          	addi	a0,a0,1070 # ffffffffc0204a68 <commands+0x5e0>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200646:	742c                	ld	a1,104(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	43850513          	addi	a0,a0,1080 # ffffffffc0204a80 <commands+0x5f8>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200654:	782c                	ld	a1,112(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	44250513          	addi	a0,a0,1090 # ffffffffc0204a98 <commands+0x610>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200662:	7c2c                	ld	a1,120(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	44c50513          	addi	a0,a0,1100 # ffffffffc0204ab0 <commands+0x628>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200670:	604c                	ld	a1,128(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	45650513          	addi	a0,a0,1110 # ffffffffc0204ac8 <commands+0x640>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020067e:	644c                	ld	a1,136(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	46050513          	addi	a0,a0,1120 # ffffffffc0204ae0 <commands+0x658>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020068c:	684c                	ld	a1,144(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	46a50513          	addi	a0,a0,1130 # ffffffffc0204af8 <commands+0x670>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020069a:	6c4c                	ld	a1,152(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	47450513          	addi	a0,a0,1140 # ffffffffc0204b10 <commands+0x688>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006a8:	704c                	ld	a1,160(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	47e50513          	addi	a0,a0,1150 # ffffffffc0204b28 <commands+0x6a0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006b6:	744c                	ld	a1,168(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	48850513          	addi	a0,a0,1160 # ffffffffc0204b40 <commands+0x6b8>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006c4:	784c                	ld	a1,176(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	49250513          	addi	a0,a0,1170 # ffffffffc0204b58 <commands+0x6d0>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006d2:	7c4c                	ld	a1,184(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	49c50513          	addi	a0,a0,1180 # ffffffffc0204b70 <commands+0x6e8>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006e0:	606c                	ld	a1,192(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	4a650513          	addi	a0,a0,1190 # ffffffffc0204b88 <commands+0x700>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006ee:	646c                	ld	a1,200(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	4b050513          	addi	a0,a0,1200 # ffffffffc0204ba0 <commands+0x718>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02006fc:	686c                	ld	a1,208(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204bb8 <commands+0x730>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020070a:	6c6c                	ld	a1,216(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	4c450513          	addi	a0,a0,1220 # ffffffffc0204bd0 <commands+0x748>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200718:	706c                	ld	a1,224(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0204be8 <commands+0x760>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200726:	746c                	ld	a1,232(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	4d850513          	addi	a0,a0,1240 # ffffffffc0204c00 <commands+0x778>
ffffffffc0200730:	98fff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200734:	786c                	ld	a1,240(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	4e250513          	addi	a0,a0,1250 # ffffffffc0204c18 <commands+0x790>
ffffffffc020073e:	981ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200742:	7c6c                	ld	a1,248(s0)
ffffffffc0200744:	6402                	ld	s0,0(sp)
ffffffffc0200746:	60a2                	ld	ra,8(sp)
ffffffffc0200748:	00004517          	auipc	a0,0x4
ffffffffc020074c:	4e850513          	addi	a0,a0,1256 # ffffffffc0204c30 <commands+0x7a8>
ffffffffc0200750:	0141                	addi	sp,sp,16
ffffffffc0200752:	b2b5                	j	ffffffffc02000be <cprintf>

ffffffffc0200754 <print_trapframe>:
ffffffffc0200754:	1141                	addi	sp,sp,-16
ffffffffc0200756:	e022                	sd	s0,0(sp)
ffffffffc0200758:	85aa                	mv	a1,a0
ffffffffc020075a:	842a                	mv	s0,a0
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204c48 <commands+0x7c0>
ffffffffc0200764:	e406                	sd	ra,8(sp)
ffffffffc0200766:	959ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020076a:	8522                	mv	a0,s0
ffffffffc020076c:	e1dff0ef          	jal	ra,ffffffffc0200588 <print_regs>
ffffffffc0200770:	10043583          	ld	a1,256(s0)
ffffffffc0200774:	00004517          	auipc	a0,0x4
ffffffffc0200778:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204c60 <commands+0x7d8>
ffffffffc020077c:	943ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200780:	10843583          	ld	a1,264(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	4f450513          	addi	a0,a0,1268 # ffffffffc0204c78 <commands+0x7f0>
ffffffffc020078c:	933ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200790:	11043583          	ld	a1,272(s0)
ffffffffc0200794:	00004517          	auipc	a0,0x4
ffffffffc0200798:	4fc50513          	addi	a0,a0,1276 # ffffffffc0204c90 <commands+0x808>
ffffffffc020079c:	923ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02007a0:	11843583          	ld	a1,280(s0)
ffffffffc02007a4:	6402                	ld	s0,0(sp)
ffffffffc02007a6:	60a2                	ld	ra,8(sp)
ffffffffc02007a8:	00004517          	auipc	a0,0x4
ffffffffc02007ac:	50050513          	addi	a0,a0,1280 # ffffffffc0204ca8 <commands+0x820>
ffffffffc02007b0:	0141                	addi	sp,sp,16
ffffffffc02007b2:	90dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007b6 <interrupt_handler>:
ffffffffc02007b6:	11853783          	ld	a5,280(a0)
ffffffffc02007ba:	577d                	li	a4,-1
ffffffffc02007bc:	8305                	srli	a4,a4,0x1
ffffffffc02007be:	8ff9                	and	a5,a5,a4
ffffffffc02007c0:	472d                	li	a4,11
ffffffffc02007c2:	06f76f63          	bltu	a4,a5,ffffffffc0200840 <interrupt_handler+0x8a>
ffffffffc02007c6:	00004717          	auipc	a4,0x4
ffffffffc02007ca:	e5670713          	addi	a4,a4,-426 # ffffffffc020461c <commands+0x194>
ffffffffc02007ce:	078a                	slli	a5,a5,0x2
ffffffffc02007d0:	97ba                	add	a5,a5,a4
ffffffffc02007d2:	439c                	lw	a5,0(a5)
ffffffffc02007d4:	97ba                	add	a5,a5,a4
ffffffffc02007d6:	8782                	jr	a5
ffffffffc02007d8:	00004517          	auipc	a0,0x4
ffffffffc02007dc:	0d050513          	addi	a0,a0,208 # ffffffffc02048a8 <commands+0x420>
ffffffffc02007e0:	8dfff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02007e4:	00004517          	auipc	a0,0x4
ffffffffc02007e8:	0a450513          	addi	a0,a0,164 # ffffffffc0204888 <commands+0x400>
ffffffffc02007ec:	8d3ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02007f0:	00004517          	auipc	a0,0x4
ffffffffc02007f4:	05850513          	addi	a0,a0,88 # ffffffffc0204848 <commands+0x3c0>
ffffffffc02007f8:	8c7ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02007fc:	00004517          	auipc	a0,0x4
ffffffffc0200800:	06c50513          	addi	a0,a0,108 # ffffffffc0204868 <commands+0x3e0>
ffffffffc0200804:	8bbff06f          	j	ffffffffc02000be <cprintf>
ffffffffc0200808:	00004517          	auipc	a0,0x4
ffffffffc020080c:	0d050513          	addi	a0,a0,208 # ffffffffc02048d8 <commands+0x450>
ffffffffc0200810:	8afff06f          	j	ffffffffc02000be <cprintf>
ffffffffc0200814:	1141                	addi	sp,sp,-16
ffffffffc0200816:	e406                	sd	ra,8(sp)
ffffffffc0200818:	c49ff0ef          	jal	ra,ffffffffc0200460 <clock_set_next_event>
ffffffffc020081c:	00011797          	auipc	a5,0x11
ffffffffc0200820:	c6478793          	addi	a5,a5,-924 # ffffffffc0211480 <ticks>
ffffffffc0200824:	639c                	ld	a5,0(a5)
ffffffffc0200826:	06400713          	li	a4,100
ffffffffc020082a:	0785                	addi	a5,a5,1
ffffffffc020082c:	02e7f733          	remu	a4,a5,a4
ffffffffc0200830:	00011697          	auipc	a3,0x11
ffffffffc0200834:	c4f6b823          	sd	a5,-944(a3) # ffffffffc0211480 <ticks>
ffffffffc0200838:	c709                	beqz	a4,ffffffffc0200842 <interrupt_handler+0x8c>
ffffffffc020083a:	60a2                	ld	ra,8(sp)
ffffffffc020083c:	0141                	addi	sp,sp,16
ffffffffc020083e:	8082                	ret
ffffffffc0200840:	bf11                	j	ffffffffc0200754 <print_trapframe>
ffffffffc0200842:	60a2                	ld	ra,8(sp)
ffffffffc0200844:	06400593          	li	a1,100
ffffffffc0200848:	00004517          	auipc	a0,0x4
ffffffffc020084c:	08050513          	addi	a0,a0,128 # ffffffffc02048c8 <commands+0x440>
ffffffffc0200850:	0141                	addi	sp,sp,16
ffffffffc0200852:	86dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200856 <exception_handler>:
ffffffffc0200856:	11853783          	ld	a5,280(a0)
ffffffffc020085a:	473d                	li	a4,15
ffffffffc020085c:	16f76463          	bltu	a4,a5,ffffffffc02009c4 <exception_handler+0x16e>
ffffffffc0200860:	00004717          	auipc	a4,0x4
ffffffffc0200864:	dec70713          	addi	a4,a4,-532 # ffffffffc020464c <commands+0x1c4>
ffffffffc0200868:	078a                	slli	a5,a5,0x2
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	439c                	lw	a5,0(a5)
ffffffffc020086e:	1101                	addi	sp,sp,-32
ffffffffc0200870:	e822                	sd	s0,16(sp)
ffffffffc0200872:	ec06                	sd	ra,24(sp)
ffffffffc0200874:	e426                	sd	s1,8(sp)
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	842a                	mv	s0,a0
ffffffffc020087a:	8782                	jr	a5
ffffffffc020087c:	00004517          	auipc	a0,0x4
ffffffffc0200880:	fb450513          	addi	a0,a0,-76 # ffffffffc0204830 <commands+0x3a8>
ffffffffc0200884:	83bff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200888:	8522                	mv	a0,s0
ffffffffc020088a:	c6fff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020088e:	84aa                	mv	s1,a0
ffffffffc0200890:	12051b63          	bnez	a0,ffffffffc02009c6 <exception_handler+0x170>
ffffffffc0200894:	60e2                	ld	ra,24(sp)
ffffffffc0200896:	6442                	ld	s0,16(sp)
ffffffffc0200898:	64a2                	ld	s1,8(sp)
ffffffffc020089a:	6105                	addi	sp,sp,32
ffffffffc020089c:	8082                	ret
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	df250513          	addi	a0,a0,-526 # ffffffffc0204690 <commands+0x208>
ffffffffc02008a6:	6442                	ld	s0,16(sp)
ffffffffc02008a8:	60e2                	ld	ra,24(sp)
ffffffffc02008aa:	64a2                	ld	s1,8(sp)
ffffffffc02008ac:	6105                	addi	sp,sp,32
ffffffffc02008ae:	811ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008b2:	00004517          	auipc	a0,0x4
ffffffffc02008b6:	dfe50513          	addi	a0,a0,-514 # ffffffffc02046b0 <commands+0x228>
ffffffffc02008ba:	b7f5                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	e1450513          	addi	a0,a0,-492 # ffffffffc02046d0 <commands+0x248>
ffffffffc02008c4:	b7cd                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc02008c6:	00004517          	auipc	a0,0x4
ffffffffc02008ca:	e2250513          	addi	a0,a0,-478 # ffffffffc02046e8 <commands+0x260>
ffffffffc02008ce:	bfe1                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc02008d0:	00004517          	auipc	a0,0x4
ffffffffc02008d4:	e2850513          	addi	a0,a0,-472 # ffffffffc02046f8 <commands+0x270>
ffffffffc02008d8:	b7f9                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc02008da:	00004517          	auipc	a0,0x4
ffffffffc02008de:	e3e50513          	addi	a0,a0,-450 # ffffffffc0204718 <commands+0x290>
ffffffffc02008e2:	fdcff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02008e6:	8522                	mv	a0,s0
ffffffffc02008e8:	c11ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02008ec:	84aa                	mv	s1,a0
ffffffffc02008ee:	d15d                	beqz	a0,ffffffffc0200894 <exception_handler+0x3e>
ffffffffc02008f0:	8522                	mv	a0,s0
ffffffffc02008f2:	e63ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc02008f6:	86a6                	mv	a3,s1
ffffffffc02008f8:	00004617          	auipc	a2,0x4
ffffffffc02008fc:	e3860613          	addi	a2,a2,-456 # ffffffffc0204730 <commands+0x2a8>
ffffffffc0200900:	0ca00593          	li	a1,202
ffffffffc0200904:	00004517          	auipc	a0,0x4
ffffffffc0200908:	02c50513          	addi	a0,a0,44 # ffffffffc0204930 <commands+0x4a8>
ffffffffc020090c:	ff8ff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	e4050513          	addi	a0,a0,-448 # ffffffffc0204750 <commands+0x2c8>
ffffffffc0200918:	b779                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc020091a:	00004517          	auipc	a0,0x4
ffffffffc020091e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204768 <commands+0x2e0>
ffffffffc0200922:	f9cff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200926:	8522                	mv	a0,s0
ffffffffc0200928:	bd1ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020092c:	84aa                	mv	s1,a0
ffffffffc020092e:	d13d                	beqz	a0,ffffffffc0200894 <exception_handler+0x3e>
ffffffffc0200930:	8522                	mv	a0,s0
ffffffffc0200932:	e23ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc0200936:	86a6                	mv	a3,s1
ffffffffc0200938:	00004617          	auipc	a2,0x4
ffffffffc020093c:	df860613          	addi	a2,a2,-520 # ffffffffc0204730 <commands+0x2a8>
ffffffffc0200940:	0d400593          	li	a1,212
ffffffffc0200944:	00004517          	auipc	a0,0x4
ffffffffc0200948:	fec50513          	addi	a0,a0,-20 # ffffffffc0204930 <commands+0x4a8>
ffffffffc020094c:	fb8ff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	e3050513          	addi	a0,a0,-464 # ffffffffc0204780 <commands+0x2f8>
ffffffffc0200958:	b7b9                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	e4650513          	addi	a0,a0,-442 # ffffffffc02047a0 <commands+0x318>
ffffffffc0200962:	b791                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	e5c50513          	addi	a0,a0,-420 # ffffffffc02047c0 <commands+0x338>
ffffffffc020096c:	bf2d                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc020096e:	00004517          	auipc	a0,0x4
ffffffffc0200972:	e7250513          	addi	a0,a0,-398 # ffffffffc02047e0 <commands+0x358>
ffffffffc0200976:	bf05                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc0200978:	00004517          	auipc	a0,0x4
ffffffffc020097c:	e8850513          	addi	a0,a0,-376 # ffffffffc0204800 <commands+0x378>
ffffffffc0200980:	b71d                	j	ffffffffc02008a6 <exception_handler+0x50>
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	e9650513          	addi	a0,a0,-362 # ffffffffc0204818 <commands+0x390>
ffffffffc020098a:	f34ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020098e:	8522                	mv	a0,s0
ffffffffc0200990:	b69ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200994:	84aa                	mv	s1,a0
ffffffffc0200996:	ee050fe3          	beqz	a0,ffffffffc0200894 <exception_handler+0x3e>
ffffffffc020099a:	8522                	mv	a0,s0
ffffffffc020099c:	db9ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc02009a0:	86a6                	mv	a3,s1
ffffffffc02009a2:	00004617          	auipc	a2,0x4
ffffffffc02009a6:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204730 <commands+0x2a8>
ffffffffc02009aa:	0ea00593          	li	a1,234
ffffffffc02009ae:	00004517          	auipc	a0,0x4
ffffffffc02009b2:	f8250513          	addi	a0,a0,-126 # ffffffffc0204930 <commands+0x4a8>
ffffffffc02009b6:	f4eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02009ba:	6442                	ld	s0,16(sp)
ffffffffc02009bc:	60e2                	ld	ra,24(sp)
ffffffffc02009be:	64a2                	ld	s1,8(sp)
ffffffffc02009c0:	6105                	addi	sp,sp,32
ffffffffc02009c2:	bb49                	j	ffffffffc0200754 <print_trapframe>
ffffffffc02009c4:	bb41                	j	ffffffffc0200754 <print_trapframe>
ffffffffc02009c6:	8522                	mv	a0,s0
ffffffffc02009c8:	d8dff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc02009cc:	86a6                	mv	a3,s1
ffffffffc02009ce:	00004617          	auipc	a2,0x4
ffffffffc02009d2:	d6260613          	addi	a2,a2,-670 # ffffffffc0204730 <commands+0x2a8>
ffffffffc02009d6:	0f100593          	li	a1,241
ffffffffc02009da:	00004517          	auipc	a0,0x4
ffffffffc02009de:	f5650513          	addi	a0,a0,-170 # ffffffffc0204930 <commands+0x4a8>
ffffffffc02009e2:	f22ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02009e6 <trap>:
ffffffffc02009e6:	11853783          	ld	a5,280(a0)
ffffffffc02009ea:	0007c363          	bltz	a5,ffffffffc02009f0 <trap+0xa>
ffffffffc02009ee:	b5a5                	j	ffffffffc0200856 <exception_handler>
ffffffffc02009f0:	b3d9                	j	ffffffffc02007b6 <interrupt_handler>
	...

ffffffffc0200a00 <__alltraps>:
ffffffffc0200a00:	14011073          	csrw	sscratch,sp
ffffffffc0200a04:	712d                	addi	sp,sp,-288
ffffffffc0200a06:	e406                	sd	ra,8(sp)
ffffffffc0200a08:	ec0e                	sd	gp,24(sp)
ffffffffc0200a0a:	f012                	sd	tp,32(sp)
ffffffffc0200a0c:	f416                	sd	t0,40(sp)
ffffffffc0200a0e:	f81a                	sd	t1,48(sp)
ffffffffc0200a10:	fc1e                	sd	t2,56(sp)
ffffffffc0200a12:	e0a2                	sd	s0,64(sp)
ffffffffc0200a14:	e4a6                	sd	s1,72(sp)
ffffffffc0200a16:	e8aa                	sd	a0,80(sp)
ffffffffc0200a18:	ecae                	sd	a1,88(sp)
ffffffffc0200a1a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a1c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a1e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a20:	fcbe                	sd	a5,120(sp)
ffffffffc0200a22:	e142                	sd	a6,128(sp)
ffffffffc0200a24:	e546                	sd	a7,136(sp)
ffffffffc0200a26:	e94a                	sd	s2,144(sp)
ffffffffc0200a28:	ed4e                	sd	s3,152(sp)
ffffffffc0200a2a:	f152                	sd	s4,160(sp)
ffffffffc0200a2c:	f556                	sd	s5,168(sp)
ffffffffc0200a2e:	f95a                	sd	s6,176(sp)
ffffffffc0200a30:	fd5e                	sd	s7,184(sp)
ffffffffc0200a32:	e1e2                	sd	s8,192(sp)
ffffffffc0200a34:	e5e6                	sd	s9,200(sp)
ffffffffc0200a36:	e9ea                	sd	s10,208(sp)
ffffffffc0200a38:	edee                	sd	s11,216(sp)
ffffffffc0200a3a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a3c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a3e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a40:	fdfe                	sd	t6,248(sp)
ffffffffc0200a42:	14002473          	csrr	s0,sscratch
ffffffffc0200a46:	100024f3          	csrr	s1,sstatus
ffffffffc0200a4a:	14102973          	csrr	s2,sepc
ffffffffc0200a4e:	143029f3          	csrr	s3,stval
ffffffffc0200a52:	14202a73          	csrr	s4,scause
ffffffffc0200a56:	e822                	sd	s0,16(sp)
ffffffffc0200a58:	e226                	sd	s1,256(sp)
ffffffffc0200a5a:	e64a                	sd	s2,264(sp)
ffffffffc0200a5c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a5e:	ee52                	sd	s4,280(sp)
ffffffffc0200a60:	850a                	mv	a0,sp
ffffffffc0200a62:	f85ff0ef          	jal	ra,ffffffffc02009e6 <trap>

ffffffffc0200a66 <__trapret>:
ffffffffc0200a66:	6492                	ld	s1,256(sp)
ffffffffc0200a68:	6932                	ld	s2,264(sp)
ffffffffc0200a6a:	10049073          	csrw	sstatus,s1
ffffffffc0200a6e:	14191073          	csrw	sepc,s2
ffffffffc0200a72:	60a2                	ld	ra,8(sp)
ffffffffc0200a74:	61e2                	ld	gp,24(sp)
ffffffffc0200a76:	7202                	ld	tp,32(sp)
ffffffffc0200a78:	72a2                	ld	t0,40(sp)
ffffffffc0200a7a:	7342                	ld	t1,48(sp)
ffffffffc0200a7c:	73e2                	ld	t2,56(sp)
ffffffffc0200a7e:	6406                	ld	s0,64(sp)
ffffffffc0200a80:	64a6                	ld	s1,72(sp)
ffffffffc0200a82:	6546                	ld	a0,80(sp)
ffffffffc0200a84:	65e6                	ld	a1,88(sp)
ffffffffc0200a86:	7606                	ld	a2,96(sp)
ffffffffc0200a88:	76a6                	ld	a3,104(sp)
ffffffffc0200a8a:	7746                	ld	a4,112(sp)
ffffffffc0200a8c:	77e6                	ld	a5,120(sp)
ffffffffc0200a8e:	680a                	ld	a6,128(sp)
ffffffffc0200a90:	68aa                	ld	a7,136(sp)
ffffffffc0200a92:	694a                	ld	s2,144(sp)
ffffffffc0200a94:	69ea                	ld	s3,152(sp)
ffffffffc0200a96:	7a0a                	ld	s4,160(sp)
ffffffffc0200a98:	7aaa                	ld	s5,168(sp)
ffffffffc0200a9a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a9c:	7bea                	ld	s7,184(sp)
ffffffffc0200a9e:	6c0e                	ld	s8,192(sp)
ffffffffc0200aa0:	6cae                	ld	s9,200(sp)
ffffffffc0200aa2:	6d4e                	ld	s10,208(sp)
ffffffffc0200aa4:	6dee                	ld	s11,216(sp)
ffffffffc0200aa6:	7e0e                	ld	t3,224(sp)
ffffffffc0200aa8:	7eae                	ld	t4,232(sp)
ffffffffc0200aaa:	7f4e                	ld	t5,240(sp)
ffffffffc0200aac:	7fee                	ld	t6,248(sp)
ffffffffc0200aae:	6142                	ld	sp,16(sp)
ffffffffc0200ab0:	10200073          	sret
	...

ffffffffc0200ac0 <_lru_init_mm>:
ffffffffc0200ac0:	00011797          	auipc	a5,0x11
ffffffffc0200ac4:	9c878793          	addi	a5,a5,-1592 # ffffffffc0211488 <pra_list_head>
ffffffffc0200ac8:	f51c                	sd	a5,40(a0)
ffffffffc0200aca:	e79c                	sd	a5,8(a5)
ffffffffc0200acc:	e39c                	sd	a5,0(a5)
ffffffffc0200ace:	4501                	li	a0,0
ffffffffc0200ad0:	8082                	ret

ffffffffc0200ad2 <_lru_init>:
ffffffffc0200ad2:	4501                	li	a0,0
ffffffffc0200ad4:	8082                	ret

ffffffffc0200ad6 <_lru_set_unswappable>:
ffffffffc0200ad6:	4501                	li	a0,0
ffffffffc0200ad8:	8082                	ret

ffffffffc0200ada <_lru_tick_event>:
ffffffffc0200ada:	4501                	li	a0,0
ffffffffc0200adc:	8082                	ret

ffffffffc0200ade <_lru_check_swap>:
ffffffffc0200ade:	711d                	addi	sp,sp,-96
ffffffffc0200ae0:	fc4e                	sd	s3,56(sp)
ffffffffc0200ae2:	f852                	sd	s4,48(sp)
ffffffffc0200ae4:	00004517          	auipc	a0,0x4
ffffffffc0200ae8:	1dc50513          	addi	a0,a0,476 # ffffffffc0204cc0 <commands+0x838>
ffffffffc0200aec:	698d                	lui	s3,0x3
ffffffffc0200aee:	4a31                	li	s4,12
ffffffffc0200af0:	e8a2                	sd	s0,80(sp)
ffffffffc0200af2:	e4a6                	sd	s1,72(sp)
ffffffffc0200af4:	ec86                	sd	ra,88(sp)
ffffffffc0200af6:	e0ca                	sd	s2,64(sp)
ffffffffc0200af8:	f456                	sd	s5,40(sp)
ffffffffc0200afa:	f05a                	sd	s6,32(sp)
ffffffffc0200afc:	ec5e                	sd	s7,24(sp)
ffffffffc0200afe:	e862                	sd	s8,16(sp)
ffffffffc0200b00:	e466                	sd	s9,8(sp)
ffffffffc0200b02:	00011417          	auipc	s0,0x11
ffffffffc0200b06:	96640413          	addi	s0,s0,-1690 # ffffffffc0211468 <pgfault_num>
ffffffffc0200b0a:	db4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b0e:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0200b12:	4004                	lw	s1,0(s0)
ffffffffc0200b14:	4791                	li	a5,4
ffffffffc0200b16:	2481                	sext.w	s1,s1
ffffffffc0200b18:	14f49963          	bne	s1,a5,ffffffffc0200c6a <_lru_check_swap+0x18c>
ffffffffc0200b1c:	00004517          	auipc	a0,0x4
ffffffffc0200b20:	20c50513          	addi	a0,a0,524 # ffffffffc0204d28 <commands+0x8a0>
ffffffffc0200b24:	6a85                	lui	s5,0x1
ffffffffc0200b26:	4b29                	li	s6,10
ffffffffc0200b28:	d96ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b2c:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200b30:	00042903          	lw	s2,0(s0)
ffffffffc0200b34:	2901                	sext.w	s2,s2
ffffffffc0200b36:	2a991a63          	bne	s2,s1,ffffffffc0200dea <_lru_check_swap+0x30c>
ffffffffc0200b3a:	00004517          	auipc	a0,0x4
ffffffffc0200b3e:	21650513          	addi	a0,a0,534 # ffffffffc0204d50 <commands+0x8c8>
ffffffffc0200b42:	6b91                	lui	s7,0x4
ffffffffc0200b44:	4c35                	li	s8,13
ffffffffc0200b46:	d78ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b4a:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0200b4e:	4004                	lw	s1,0(s0)
ffffffffc0200b50:	2481                	sext.w	s1,s1
ffffffffc0200b52:	27249c63          	bne	s1,s2,ffffffffc0200dca <_lru_check_swap+0x2ec>
ffffffffc0200b56:	00004517          	auipc	a0,0x4
ffffffffc0200b5a:	22250513          	addi	a0,a0,546 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200b5e:	6909                	lui	s2,0x2
ffffffffc0200b60:	4cad                	li	s9,11
ffffffffc0200b62:	d5cff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b66:	01990023          	sb	s9,0(s2) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0200b6a:	401c                	lw	a5,0(s0)
ffffffffc0200b6c:	2781                	sext.w	a5,a5
ffffffffc0200b6e:	22979e63          	bne	a5,s1,ffffffffc0200daa <_lru_check_swap+0x2cc>
ffffffffc0200b72:	00004517          	auipc	a0,0x4
ffffffffc0200b76:	22e50513          	addi	a0,a0,558 # ffffffffc0204da0 <commands+0x918>
ffffffffc0200b7a:	d44ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b7e:	6795                	lui	a5,0x5
ffffffffc0200b80:	4739                	li	a4,14
ffffffffc0200b82:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0200b86:	4004                	lw	s1,0(s0)
ffffffffc0200b88:	4795                	li	a5,5
ffffffffc0200b8a:	2481                	sext.w	s1,s1
ffffffffc0200b8c:	1ef49f63          	bne	s1,a5,ffffffffc0200d8a <_lru_check_swap+0x2ac>
ffffffffc0200b90:	00004517          	auipc	a0,0x4
ffffffffc0200b94:	1e850513          	addi	a0,a0,488 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200b98:	d26ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200b9c:	01990023          	sb	s9,0(s2)
ffffffffc0200ba0:	401c                	lw	a5,0(s0)
ffffffffc0200ba2:	2781                	sext.w	a5,a5
ffffffffc0200ba4:	1c979363          	bne	a5,s1,ffffffffc0200d6a <_lru_check_swap+0x28c>
ffffffffc0200ba8:	00004517          	auipc	a0,0x4
ffffffffc0200bac:	18050513          	addi	a0,a0,384 # ffffffffc0204d28 <commands+0x8a0>
ffffffffc0200bb0:	d0eff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200bb4:	016a8023          	sb	s6,0(s5)
ffffffffc0200bb8:	401c                	lw	a5,0(s0)
ffffffffc0200bba:	4719                	li	a4,6
ffffffffc0200bbc:	2781                	sext.w	a5,a5
ffffffffc0200bbe:	18e79663          	bne	a5,a4,ffffffffc0200d4a <_lru_check_swap+0x26c>
ffffffffc0200bc2:	00004517          	auipc	a0,0x4
ffffffffc0200bc6:	1b650513          	addi	a0,a0,438 # ffffffffc0204d78 <commands+0x8f0>
ffffffffc0200bca:	cf4ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200bce:	01990023          	sb	s9,0(s2)
ffffffffc0200bd2:	401c                	lw	a5,0(s0)
ffffffffc0200bd4:	471d                	li	a4,7
ffffffffc0200bd6:	2781                	sext.w	a5,a5
ffffffffc0200bd8:	14e79963          	bne	a5,a4,ffffffffc0200d2a <_lru_check_swap+0x24c>
ffffffffc0200bdc:	00004517          	auipc	a0,0x4
ffffffffc0200be0:	0e450513          	addi	a0,a0,228 # ffffffffc0204cc0 <commands+0x838>
ffffffffc0200be4:	cdaff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200be8:	01498023          	sb	s4,0(s3)
ffffffffc0200bec:	401c                	lw	a5,0(s0)
ffffffffc0200bee:	4721                	li	a4,8
ffffffffc0200bf0:	2781                	sext.w	a5,a5
ffffffffc0200bf2:	10e79c63          	bne	a5,a4,ffffffffc0200d0a <_lru_check_swap+0x22c>
ffffffffc0200bf6:	00004517          	auipc	a0,0x4
ffffffffc0200bfa:	15a50513          	addi	a0,a0,346 # ffffffffc0204d50 <commands+0x8c8>
ffffffffc0200bfe:	cc0ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200c02:	018b8023          	sb	s8,0(s7)
ffffffffc0200c06:	401c                	lw	a5,0(s0)
ffffffffc0200c08:	4725                	li	a4,9
ffffffffc0200c0a:	2781                	sext.w	a5,a5
ffffffffc0200c0c:	0ce79f63          	bne	a5,a4,ffffffffc0200cea <_lru_check_swap+0x20c>
ffffffffc0200c10:	00004517          	auipc	a0,0x4
ffffffffc0200c14:	19050513          	addi	a0,a0,400 # ffffffffc0204da0 <commands+0x918>
ffffffffc0200c18:	ca6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200c1c:	6795                	lui	a5,0x5
ffffffffc0200c1e:	4739                	li	a4,14
ffffffffc0200c20:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0200c24:	4004                	lw	s1,0(s0)
ffffffffc0200c26:	47a9                	li	a5,10
ffffffffc0200c28:	2481                	sext.w	s1,s1
ffffffffc0200c2a:	0af49063          	bne	s1,a5,ffffffffc0200cca <_lru_check_swap+0x1ec>
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	0fa50513          	addi	a0,a0,250 # ffffffffc0204d28 <commands+0x8a0>
ffffffffc0200c36:	c88ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200c3a:	6785                	lui	a5,0x1
ffffffffc0200c3c:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0200c40:	06979563          	bne	a5,s1,ffffffffc0200caa <_lru_check_swap+0x1cc>
ffffffffc0200c44:	401c                	lw	a5,0(s0)
ffffffffc0200c46:	472d                	li	a4,11
ffffffffc0200c48:	2781                	sext.w	a5,a5
ffffffffc0200c4a:	04e79063          	bne	a5,a4,ffffffffc0200c8a <_lru_check_swap+0x1ac>
ffffffffc0200c4e:	60e6                	ld	ra,88(sp)
ffffffffc0200c50:	6446                	ld	s0,80(sp)
ffffffffc0200c52:	64a6                	ld	s1,72(sp)
ffffffffc0200c54:	6906                	ld	s2,64(sp)
ffffffffc0200c56:	79e2                	ld	s3,56(sp)
ffffffffc0200c58:	7a42                	ld	s4,48(sp)
ffffffffc0200c5a:	7aa2                	ld	s5,40(sp)
ffffffffc0200c5c:	7b02                	ld	s6,32(sp)
ffffffffc0200c5e:	6be2                	ld	s7,24(sp)
ffffffffc0200c60:	6c42                	ld	s8,16(sp)
ffffffffc0200c62:	6ca2                	ld	s9,8(sp)
ffffffffc0200c64:	4501                	li	a0,0
ffffffffc0200c66:	6125                	addi	sp,sp,96
ffffffffc0200c68:	8082                	ret
ffffffffc0200c6a:	00004697          	auipc	a3,0x4
ffffffffc0200c6e:	07e68693          	addi	a3,a3,126 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0200c72:	00004617          	auipc	a2,0x4
ffffffffc0200c76:	08660613          	addi	a2,a2,134 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200c7a:	04400593          	li	a1,68
ffffffffc0200c7e:	00004517          	auipc	a0,0x4
ffffffffc0200c82:	09250513          	addi	a0,a0,146 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200c86:	c7eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200c8a:	00004697          	auipc	a3,0x4
ffffffffc0200c8e:	1c668693          	addi	a3,a3,454 # ffffffffc0204e50 <commands+0x9c8>
ffffffffc0200c92:	00004617          	auipc	a2,0x4
ffffffffc0200c96:	06660613          	addi	a2,a2,102 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200c9a:	06600593          	li	a1,102
ffffffffc0200c9e:	00004517          	auipc	a0,0x4
ffffffffc0200ca2:	07250513          	addi	a0,a0,114 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200ca6:	c5eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200caa:	00004697          	auipc	a3,0x4
ffffffffc0200cae:	17e68693          	addi	a3,a3,382 # ffffffffc0204e28 <commands+0x9a0>
ffffffffc0200cb2:	00004617          	auipc	a2,0x4
ffffffffc0200cb6:	04660613          	addi	a2,a2,70 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200cba:	06400593          	li	a1,100
ffffffffc0200cbe:	00004517          	auipc	a0,0x4
ffffffffc0200cc2:	05250513          	addi	a0,a0,82 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200cc6:	c3eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200cca:	00004697          	auipc	a3,0x4
ffffffffc0200cce:	14e68693          	addi	a3,a3,334 # ffffffffc0204e18 <commands+0x990>
ffffffffc0200cd2:	00004617          	auipc	a2,0x4
ffffffffc0200cd6:	02660613          	addi	a2,a2,38 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200cda:	06200593          	li	a1,98
ffffffffc0200cde:	00004517          	auipc	a0,0x4
ffffffffc0200ce2:	03250513          	addi	a0,a0,50 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200ce6:	c1eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200cea:	00004697          	auipc	a3,0x4
ffffffffc0200cee:	11e68693          	addi	a3,a3,286 # ffffffffc0204e08 <commands+0x980>
ffffffffc0200cf2:	00004617          	auipc	a2,0x4
ffffffffc0200cf6:	00660613          	addi	a2,a2,6 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200cfa:	05f00593          	li	a1,95
ffffffffc0200cfe:	00004517          	auipc	a0,0x4
ffffffffc0200d02:	01250513          	addi	a0,a0,18 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200d06:	bfeff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200d0a:	00004697          	auipc	a3,0x4
ffffffffc0200d0e:	0ee68693          	addi	a3,a3,238 # ffffffffc0204df8 <commands+0x970>
ffffffffc0200d12:	00004617          	auipc	a2,0x4
ffffffffc0200d16:	fe660613          	addi	a2,a2,-26 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200d1a:	05c00593          	li	a1,92
ffffffffc0200d1e:	00004517          	auipc	a0,0x4
ffffffffc0200d22:	ff250513          	addi	a0,a0,-14 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200d26:	bdeff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200d2a:	00004697          	auipc	a3,0x4
ffffffffc0200d2e:	0be68693          	addi	a3,a3,190 # ffffffffc0204de8 <commands+0x960>
ffffffffc0200d32:	00004617          	auipc	a2,0x4
ffffffffc0200d36:	fc660613          	addi	a2,a2,-58 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200d3a:	05900593          	li	a1,89
ffffffffc0200d3e:	00004517          	auipc	a0,0x4
ffffffffc0200d42:	fd250513          	addi	a0,a0,-46 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200d46:	bbeff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200d4a:	00004697          	auipc	a3,0x4
ffffffffc0200d4e:	08e68693          	addi	a3,a3,142 # ffffffffc0204dd8 <commands+0x950>
ffffffffc0200d52:	00004617          	auipc	a2,0x4
ffffffffc0200d56:	fa660613          	addi	a2,a2,-90 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200d5a:	05600593          	li	a1,86
ffffffffc0200d5e:	00004517          	auipc	a0,0x4
ffffffffc0200d62:	fb250513          	addi	a0,a0,-78 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200d66:	b9eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200d6a:	00004697          	auipc	a3,0x4
ffffffffc0200d6e:	05e68693          	addi	a3,a3,94 # ffffffffc0204dc8 <commands+0x940>
ffffffffc0200d72:	00004617          	auipc	a2,0x4
ffffffffc0200d76:	f8660613          	addi	a2,a2,-122 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200d7a:	05300593          	li	a1,83
ffffffffc0200d7e:	00004517          	auipc	a0,0x4
ffffffffc0200d82:	f9250513          	addi	a0,a0,-110 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200d86:	b7eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200d8a:	00004697          	auipc	a3,0x4
ffffffffc0200d8e:	03e68693          	addi	a3,a3,62 # ffffffffc0204dc8 <commands+0x940>
ffffffffc0200d92:	00004617          	auipc	a2,0x4
ffffffffc0200d96:	f6660613          	addi	a2,a2,-154 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200d9a:	05000593          	li	a1,80
ffffffffc0200d9e:	00004517          	auipc	a0,0x4
ffffffffc0200da2:	f7250513          	addi	a0,a0,-142 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200da6:	b5eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200daa:	00004697          	auipc	a3,0x4
ffffffffc0200dae:	f3e68693          	addi	a3,a3,-194 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0200db2:	00004617          	auipc	a2,0x4
ffffffffc0200db6:	f4660613          	addi	a2,a2,-186 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200dba:	04d00593          	li	a1,77
ffffffffc0200dbe:	00004517          	auipc	a0,0x4
ffffffffc0200dc2:	f5250513          	addi	a0,a0,-174 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200dc6:	b3eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200dca:	00004697          	auipc	a3,0x4
ffffffffc0200dce:	f1e68693          	addi	a3,a3,-226 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0200dd2:	00004617          	auipc	a2,0x4
ffffffffc0200dd6:	f2660613          	addi	a2,a2,-218 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200dda:	04a00593          	li	a1,74
ffffffffc0200dde:	00004517          	auipc	a0,0x4
ffffffffc0200de2:	f3250513          	addi	a0,a0,-206 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200de6:	b1eff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200dea:	00004697          	auipc	a3,0x4
ffffffffc0200dee:	efe68693          	addi	a3,a3,-258 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0200df2:	00004617          	auipc	a2,0x4
ffffffffc0200df6:	f0660613          	addi	a2,a2,-250 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200dfa:	04700593          	li	a1,71
ffffffffc0200dfe:	00004517          	auipc	a0,0x4
ffffffffc0200e02:	f1250513          	addi	a0,a0,-238 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200e06:	afeff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200e0a <_lru_update_swaplist>:
ffffffffc0200e0a:	03058713          	addi	a4,a1,48
ffffffffc0200e0e:	751c                	ld	a5,40(a0)
ffffffffc0200e10:	c305                	beqz	a4,ffffffffc0200e30 <_lru_update_swaplist+0x26>
ffffffffc0200e12:	cf99                	beqz	a5,ffffffffc0200e30 <_lru_update_swaplist+0x26>
ffffffffc0200e14:	0305b803          	ld	a6,48(a1)
ffffffffc0200e18:	7d90                	ld	a2,56(a1)
ffffffffc0200e1a:	4501                	li	a0,0
ffffffffc0200e1c:	00c83423          	sd	a2,8(a6)
ffffffffc0200e20:	6794                	ld	a3,8(a5)
ffffffffc0200e22:	01063023          	sd	a6,0(a2)
ffffffffc0200e26:	e298                	sd	a4,0(a3)
ffffffffc0200e28:	e798                	sd	a4,8(a5)
ffffffffc0200e2a:	fd94                	sd	a3,56(a1)
ffffffffc0200e2c:	f99c                	sd	a5,48(a1)
ffffffffc0200e2e:	8082                	ret
ffffffffc0200e30:	1141                	addi	sp,sp,-16
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	04e68693          	addi	a3,a3,78 # ffffffffc0204e80 <commands+0x9f8>
ffffffffc0200e3a:	00004617          	auipc	a2,0x4
ffffffffc0200e3e:	ebe60613          	addi	a2,a2,-322 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200e42:	02800593          	li	a1,40
ffffffffc0200e46:	00004517          	auipc	a0,0x4
ffffffffc0200e4a:	eca50513          	addi	a0,a0,-310 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200e4e:	e406                	sd	ra,8(sp)
ffffffffc0200e50:	ab4ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200e54 <_lru_swap_out_victim>:
ffffffffc0200e54:	7518                	ld	a4,40(a0)
ffffffffc0200e56:	1141                	addi	sp,sp,-16
ffffffffc0200e58:	e406                	sd	ra,8(sp)
ffffffffc0200e5a:	c731                	beqz	a4,ffffffffc0200ea6 <_lru_swap_out_victim+0x52>
ffffffffc0200e5c:	e60d                	bnez	a2,ffffffffc0200e86 <_lru_swap_out_victim+0x32>
ffffffffc0200e5e:	631c                	ld	a5,0(a4)
ffffffffc0200e60:	00f70d63          	beq	a4,a5,ffffffffc0200e7a <_lru_swap_out_victim+0x26>
ffffffffc0200e64:	6394                	ld	a3,0(a5)
ffffffffc0200e66:	6798                	ld	a4,8(a5)
ffffffffc0200e68:	60a2                	ld	ra,8(sp)
ffffffffc0200e6a:	fd078793          	addi	a5,a5,-48
ffffffffc0200e6e:	e698                	sd	a4,8(a3)
ffffffffc0200e70:	e314                	sd	a3,0(a4)
ffffffffc0200e72:	e19c                	sd	a5,0(a1)
ffffffffc0200e74:	4501                	li	a0,0
ffffffffc0200e76:	0141                	addi	sp,sp,16
ffffffffc0200e78:	8082                	ret
ffffffffc0200e7a:	60a2                	ld	ra,8(sp)
ffffffffc0200e7c:	0005b023          	sd	zero,0(a1)
ffffffffc0200e80:	4501                	li	a0,0
ffffffffc0200e82:	0141                	addi	sp,sp,16
ffffffffc0200e84:	8082                	ret
ffffffffc0200e86:	00004697          	auipc	a3,0x4
ffffffffc0200e8a:	fea68693          	addi	a3,a3,-22 # ffffffffc0204e70 <commands+0x9e8>
ffffffffc0200e8e:	00004617          	auipc	a2,0x4
ffffffffc0200e92:	e6a60613          	addi	a2,a2,-406 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200e96:	03400593          	li	a1,52
ffffffffc0200e9a:	00004517          	auipc	a0,0x4
ffffffffc0200e9e:	e7650513          	addi	a0,a0,-394 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200ea2:	a62ff0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0200ea6:	00004697          	auipc	a3,0x4
ffffffffc0200eaa:	fba68693          	addi	a3,a3,-70 # ffffffffc0204e60 <commands+0x9d8>
ffffffffc0200eae:	00004617          	auipc	a2,0x4
ffffffffc0200eb2:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200eb6:	03300593          	li	a1,51
ffffffffc0200eba:	00004517          	auipc	a0,0x4
ffffffffc0200ebe:	e5650513          	addi	a0,a0,-426 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200ec2:	a42ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200ec6 <_lru_map_swappable>:
ffffffffc0200ec6:	03060713          	addi	a4,a2,48
ffffffffc0200eca:	751c                	ld	a5,40(a0)
ffffffffc0200ecc:	cb09                	beqz	a4,ffffffffc0200ede <_lru_map_swappable+0x18>
ffffffffc0200ece:	cb81                	beqz	a5,ffffffffc0200ede <_lru_map_swappable+0x18>
ffffffffc0200ed0:	6794                	ld	a3,8(a5)
ffffffffc0200ed2:	4501                	li	a0,0
ffffffffc0200ed4:	e298                	sd	a4,0(a3)
ffffffffc0200ed6:	e798                	sd	a4,8(a5)
ffffffffc0200ed8:	fe14                	sd	a3,56(a2)
ffffffffc0200eda:	fa1c                	sd	a5,48(a2)
ffffffffc0200edc:	8082                	ret
ffffffffc0200ede:	1141                	addi	sp,sp,-16
ffffffffc0200ee0:	00004697          	auipc	a3,0x4
ffffffffc0200ee4:	fa068693          	addi	a3,a3,-96 # ffffffffc0204e80 <commands+0x9f8>
ffffffffc0200ee8:	00004617          	auipc	a2,0x4
ffffffffc0200eec:	e1060613          	addi	a2,a2,-496 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0200ef0:	45ed                	li	a1,27
ffffffffc0200ef2:	00004517          	auipc	a0,0x4
ffffffffc0200ef6:	e1e50513          	addi	a0,a0,-482 # ffffffffc0204d10 <commands+0x888>
ffffffffc0200efa:	e406                	sd	ra,8(sp)
ffffffffc0200efc:	a08ff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200f00 <pa2page.part.4>:
ffffffffc0200f00:	1141                	addi	sp,sp,-16
ffffffffc0200f02:	00004617          	auipc	a2,0x4
ffffffffc0200f06:	03660613          	addi	a2,a2,54 # ffffffffc0204f38 <commands+0xab0>
ffffffffc0200f0a:	06500593          	li	a1,101
ffffffffc0200f0e:	00004517          	auipc	a0,0x4
ffffffffc0200f12:	04a50513          	addi	a0,a0,74 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0200f16:	e406                	sd	ra,8(sp)
ffffffffc0200f18:	9ecff0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0200f1c <alloc_pages>:
ffffffffc0200f1c:	715d                	addi	sp,sp,-80
ffffffffc0200f1e:	e0a2                	sd	s0,64(sp)
ffffffffc0200f20:	fc26                	sd	s1,56(sp)
ffffffffc0200f22:	f84a                	sd	s2,48(sp)
ffffffffc0200f24:	f44e                	sd	s3,40(sp)
ffffffffc0200f26:	f052                	sd	s4,32(sp)
ffffffffc0200f28:	ec56                	sd	s5,24(sp)
ffffffffc0200f2a:	e486                	sd	ra,72(sp)
ffffffffc0200f2c:	842a                	mv	s0,a0
ffffffffc0200f2e:	00010497          	auipc	s1,0x10
ffffffffc0200f32:	56a48493          	addi	s1,s1,1386 # ffffffffc0211498 <pmm_manager>
ffffffffc0200f36:	4985                	li	s3,1
ffffffffc0200f38:	00010a17          	auipc	s4,0x10
ffffffffc0200f3c:	540a0a13          	addi	s4,s4,1344 # ffffffffc0211478 <swap_init_ok>
ffffffffc0200f40:	0005091b          	sext.w	s2,a0
ffffffffc0200f44:	00010a97          	auipc	s5,0x10
ffffffffc0200f48:	574a8a93          	addi	s5,s5,1396 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0200f4c:	a00d                	j	ffffffffc0200f6e <alloc_pages+0x52>
ffffffffc0200f4e:	609c                	ld	a5,0(s1)
ffffffffc0200f50:	6f9c                	ld	a5,24(a5)
ffffffffc0200f52:	9782                	jalr	a5
ffffffffc0200f54:	4601                	li	a2,0
ffffffffc0200f56:	85ca                	mv	a1,s2
ffffffffc0200f58:	ed0d                	bnez	a0,ffffffffc0200f92 <alloc_pages+0x76>
ffffffffc0200f5a:	0289ec63          	bltu	s3,s0,ffffffffc0200f92 <alloc_pages+0x76>
ffffffffc0200f5e:	000a2783          	lw	a5,0(s4)
ffffffffc0200f62:	2781                	sext.w	a5,a5
ffffffffc0200f64:	c79d                	beqz	a5,ffffffffc0200f92 <alloc_pages+0x76>
ffffffffc0200f66:	000ab503          	ld	a0,0(s5)
ffffffffc0200f6a:	7d5010ef          	jal	ra,ffffffffc0202f3e <swap_out>
ffffffffc0200f6e:	100027f3          	csrr	a5,sstatus
ffffffffc0200f72:	8b89                	andi	a5,a5,2
ffffffffc0200f74:	8522                	mv	a0,s0
ffffffffc0200f76:	dfe1                	beqz	a5,ffffffffc0200f4e <alloc_pages+0x32>
ffffffffc0200f78:	d7aff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200f7c:	609c                	ld	a5,0(s1)
ffffffffc0200f7e:	8522                	mv	a0,s0
ffffffffc0200f80:	6f9c                	ld	a5,24(a5)
ffffffffc0200f82:	9782                	jalr	a5
ffffffffc0200f84:	e42a                	sd	a0,8(sp)
ffffffffc0200f86:	d66ff0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0200f8a:	6522                	ld	a0,8(sp)
ffffffffc0200f8c:	4601                	li	a2,0
ffffffffc0200f8e:	85ca                	mv	a1,s2
ffffffffc0200f90:	d569                	beqz	a0,ffffffffc0200f5a <alloc_pages+0x3e>
ffffffffc0200f92:	60a6                	ld	ra,72(sp)
ffffffffc0200f94:	6406                	ld	s0,64(sp)
ffffffffc0200f96:	74e2                	ld	s1,56(sp)
ffffffffc0200f98:	7942                	ld	s2,48(sp)
ffffffffc0200f9a:	79a2                	ld	s3,40(sp)
ffffffffc0200f9c:	7a02                	ld	s4,32(sp)
ffffffffc0200f9e:	6ae2                	ld	s5,24(sp)
ffffffffc0200fa0:	6161                	addi	sp,sp,80
ffffffffc0200fa2:	8082                	ret

ffffffffc0200fa4 <free_pages>:
ffffffffc0200fa4:	100027f3          	csrr	a5,sstatus
ffffffffc0200fa8:	8b89                	andi	a5,a5,2
ffffffffc0200faa:	eb89                	bnez	a5,ffffffffc0200fbc <free_pages+0x18>
ffffffffc0200fac:	00010797          	auipc	a5,0x10
ffffffffc0200fb0:	4ec78793          	addi	a5,a5,1260 # ffffffffc0211498 <pmm_manager>
ffffffffc0200fb4:	639c                	ld	a5,0(a5)
ffffffffc0200fb6:	0207b303          	ld	t1,32(a5)
ffffffffc0200fba:	8302                	jr	t1
ffffffffc0200fbc:	1101                	addi	sp,sp,-32
ffffffffc0200fbe:	ec06                	sd	ra,24(sp)
ffffffffc0200fc0:	e822                	sd	s0,16(sp)
ffffffffc0200fc2:	e426                	sd	s1,8(sp)
ffffffffc0200fc4:	842a                	mv	s0,a0
ffffffffc0200fc6:	84ae                	mv	s1,a1
ffffffffc0200fc8:	d2aff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200fcc:	00010797          	auipc	a5,0x10
ffffffffc0200fd0:	4cc78793          	addi	a5,a5,1228 # ffffffffc0211498 <pmm_manager>
ffffffffc0200fd4:	639c                	ld	a5,0(a5)
ffffffffc0200fd6:	85a6                	mv	a1,s1
ffffffffc0200fd8:	8522                	mv	a0,s0
ffffffffc0200fda:	739c                	ld	a5,32(a5)
ffffffffc0200fdc:	9782                	jalr	a5
ffffffffc0200fde:	6442                	ld	s0,16(sp)
ffffffffc0200fe0:	60e2                	ld	ra,24(sp)
ffffffffc0200fe2:	64a2                	ld	s1,8(sp)
ffffffffc0200fe4:	6105                	addi	sp,sp,32
ffffffffc0200fe6:	d06ff06f          	j	ffffffffc02004ec <intr_enable>

ffffffffc0200fea <nr_free_pages>:
ffffffffc0200fea:	100027f3          	csrr	a5,sstatus
ffffffffc0200fee:	8b89                	andi	a5,a5,2
ffffffffc0200ff0:	eb89                	bnez	a5,ffffffffc0201002 <nr_free_pages+0x18>
ffffffffc0200ff2:	00010797          	auipc	a5,0x10
ffffffffc0200ff6:	4a678793          	addi	a5,a5,1190 # ffffffffc0211498 <pmm_manager>
ffffffffc0200ffa:	639c                	ld	a5,0(a5)
ffffffffc0200ffc:	0287b303          	ld	t1,40(a5)
ffffffffc0201000:	8302                	jr	t1
ffffffffc0201002:	1141                	addi	sp,sp,-16
ffffffffc0201004:	e406                	sd	ra,8(sp)
ffffffffc0201006:	e022                	sd	s0,0(sp)
ffffffffc0201008:	ceaff0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020100c:	00010797          	auipc	a5,0x10
ffffffffc0201010:	48c78793          	addi	a5,a5,1164 # ffffffffc0211498 <pmm_manager>
ffffffffc0201014:	639c                	ld	a5,0(a5)
ffffffffc0201016:	779c                	ld	a5,40(a5)
ffffffffc0201018:	9782                	jalr	a5
ffffffffc020101a:	842a                	mv	s0,a0
ffffffffc020101c:	cd0ff0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc0201020:	8522                	mv	a0,s0
ffffffffc0201022:	60a2                	ld	ra,8(sp)
ffffffffc0201024:	6402                	ld	s0,0(sp)
ffffffffc0201026:	0141                	addi	sp,sp,16
ffffffffc0201028:	8082                	ret

ffffffffc020102a <get_pte>:
ffffffffc020102a:	715d                	addi	sp,sp,-80
ffffffffc020102c:	fc26                	sd	s1,56(sp)
ffffffffc020102e:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201032:	1ff4f493          	andi	s1,s1,511
ffffffffc0201036:	048e                	slli	s1,s1,0x3
ffffffffc0201038:	94aa                	add	s1,s1,a0
ffffffffc020103a:	6094                	ld	a3,0(s1)
ffffffffc020103c:	f84a                	sd	s2,48(sp)
ffffffffc020103e:	f44e                	sd	s3,40(sp)
ffffffffc0201040:	f052                	sd	s4,32(sp)
ffffffffc0201042:	e486                	sd	ra,72(sp)
ffffffffc0201044:	e0a2                	sd	s0,64(sp)
ffffffffc0201046:	ec56                	sd	s5,24(sp)
ffffffffc0201048:	e85a                	sd	s6,16(sp)
ffffffffc020104a:	e45e                	sd	s7,8(sp)
ffffffffc020104c:	0016f793          	andi	a5,a3,1
ffffffffc0201050:	892e                	mv	s2,a1
ffffffffc0201052:	8a32                	mv	s4,a2
ffffffffc0201054:	00010997          	auipc	s3,0x10
ffffffffc0201058:	40c98993          	addi	s3,s3,1036 # ffffffffc0211460 <npage>
ffffffffc020105c:	e3c9                	bnez	a5,ffffffffc02010de <get_pte+0xb4>
ffffffffc020105e:	16060163          	beqz	a2,ffffffffc02011c0 <get_pte+0x196>
ffffffffc0201062:	4505                	li	a0,1
ffffffffc0201064:	eb9ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201068:	842a                	mv	s0,a0
ffffffffc020106a:	14050b63          	beqz	a0,ffffffffc02011c0 <get_pte+0x196>
ffffffffc020106e:	00010b97          	auipc	s7,0x10
ffffffffc0201072:	442b8b93          	addi	s7,s7,1090 # ffffffffc02114b0 <pages>
ffffffffc0201076:	000bb503          	ld	a0,0(s7)
ffffffffc020107a:	00004797          	auipc	a5,0x4
ffffffffc020107e:	e3e78793          	addi	a5,a5,-450 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0201082:	0007bb03          	ld	s6,0(a5)
ffffffffc0201086:	40a40533          	sub	a0,s0,a0
ffffffffc020108a:	850d                	srai	a0,a0,0x3
ffffffffc020108c:	03650533          	mul	a0,a0,s6
ffffffffc0201090:	4785                	li	a5,1
ffffffffc0201092:	00010997          	auipc	s3,0x10
ffffffffc0201096:	3ce98993          	addi	s3,s3,974 # ffffffffc0211460 <npage>
ffffffffc020109a:	00080ab7          	lui	s5,0x80
ffffffffc020109e:	0009b703          	ld	a4,0(s3)
ffffffffc02010a2:	c01c                	sw	a5,0(s0)
ffffffffc02010a4:	57fd                	li	a5,-1
ffffffffc02010a6:	83b1                	srli	a5,a5,0xc
ffffffffc02010a8:	9556                	add	a0,a0,s5
ffffffffc02010aa:	8fe9                	and	a5,a5,a0
ffffffffc02010ac:	0532                	slli	a0,a0,0xc
ffffffffc02010ae:	16e7f063          	bgeu	a5,a4,ffffffffc020120e <get_pte+0x1e4>
ffffffffc02010b2:	00010797          	auipc	a5,0x10
ffffffffc02010b6:	3ee78793          	addi	a5,a5,1006 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02010ba:	639c                	ld	a5,0(a5)
ffffffffc02010bc:	6605                	lui	a2,0x1
ffffffffc02010be:	4581                	li	a1,0
ffffffffc02010c0:	953e                	add	a0,a0,a5
ffffffffc02010c2:	59f020ef          	jal	ra,ffffffffc0203e60 <memset>
ffffffffc02010c6:	000bb683          	ld	a3,0(s7)
ffffffffc02010ca:	40d406b3          	sub	a3,s0,a3
ffffffffc02010ce:	868d                	srai	a3,a3,0x3
ffffffffc02010d0:	036686b3          	mul	a3,a3,s6
ffffffffc02010d4:	96d6                	add	a3,a3,s5
ffffffffc02010d6:	06aa                	slli	a3,a3,0xa
ffffffffc02010d8:	0116e693          	ori	a3,a3,17
ffffffffc02010dc:	e094                	sd	a3,0(s1)
ffffffffc02010de:	77fd                	lui	a5,0xfffff
ffffffffc02010e0:	068a                	slli	a3,a3,0x2
ffffffffc02010e2:	0009b703          	ld	a4,0(s3)
ffffffffc02010e6:	8efd                	and	a3,a3,a5
ffffffffc02010e8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02010ec:	0ce7fc63          	bgeu	a5,a4,ffffffffc02011c4 <get_pte+0x19a>
ffffffffc02010f0:	00010a97          	auipc	s5,0x10
ffffffffc02010f4:	3b0a8a93          	addi	s5,s5,944 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02010f8:	000ab403          	ld	s0,0(s5)
ffffffffc02010fc:	01595793          	srli	a5,s2,0x15
ffffffffc0201100:	1ff7f793          	andi	a5,a5,511
ffffffffc0201104:	96a2                	add	a3,a3,s0
ffffffffc0201106:	00379413          	slli	s0,a5,0x3
ffffffffc020110a:	9436                	add	s0,s0,a3
ffffffffc020110c:	6014                	ld	a3,0(s0)
ffffffffc020110e:	0016f793          	andi	a5,a3,1
ffffffffc0201112:	ebbd                	bnez	a5,ffffffffc0201188 <get_pte+0x15e>
ffffffffc0201114:	0a0a0663          	beqz	s4,ffffffffc02011c0 <get_pte+0x196>
ffffffffc0201118:	4505                	li	a0,1
ffffffffc020111a:	e03ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020111e:	84aa                	mv	s1,a0
ffffffffc0201120:	c145                	beqz	a0,ffffffffc02011c0 <get_pte+0x196>
ffffffffc0201122:	00010b97          	auipc	s7,0x10
ffffffffc0201126:	38eb8b93          	addi	s7,s7,910 # ffffffffc02114b0 <pages>
ffffffffc020112a:	000bb503          	ld	a0,0(s7)
ffffffffc020112e:	00004797          	auipc	a5,0x4
ffffffffc0201132:	d8a78793          	addi	a5,a5,-630 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0201136:	0007bb03          	ld	s6,0(a5)
ffffffffc020113a:	40a48533          	sub	a0,s1,a0
ffffffffc020113e:	850d                	srai	a0,a0,0x3
ffffffffc0201140:	03650533          	mul	a0,a0,s6
ffffffffc0201144:	4785                	li	a5,1
ffffffffc0201146:	00080a37          	lui	s4,0x80
ffffffffc020114a:	0009b703          	ld	a4,0(s3)
ffffffffc020114e:	c09c                	sw	a5,0(s1)
ffffffffc0201150:	57fd                	li	a5,-1
ffffffffc0201152:	83b1                	srli	a5,a5,0xc
ffffffffc0201154:	9552                	add	a0,a0,s4
ffffffffc0201156:	8fe9                	and	a5,a5,a0
ffffffffc0201158:	0532                	slli	a0,a0,0xc
ffffffffc020115a:	08e7fd63          	bgeu	a5,a4,ffffffffc02011f4 <get_pte+0x1ca>
ffffffffc020115e:	000ab783          	ld	a5,0(s5)
ffffffffc0201162:	6605                	lui	a2,0x1
ffffffffc0201164:	4581                	li	a1,0
ffffffffc0201166:	953e                	add	a0,a0,a5
ffffffffc0201168:	4f9020ef          	jal	ra,ffffffffc0203e60 <memset>
ffffffffc020116c:	000bb683          	ld	a3,0(s7)
ffffffffc0201170:	40d486b3          	sub	a3,s1,a3
ffffffffc0201174:	868d                	srai	a3,a3,0x3
ffffffffc0201176:	036686b3          	mul	a3,a3,s6
ffffffffc020117a:	96d2                	add	a3,a3,s4
ffffffffc020117c:	06aa                	slli	a3,a3,0xa
ffffffffc020117e:	0116e693          	ori	a3,a3,17
ffffffffc0201182:	e014                	sd	a3,0(s0)
ffffffffc0201184:	0009b703          	ld	a4,0(s3)
ffffffffc0201188:	068a                	slli	a3,a3,0x2
ffffffffc020118a:	757d                	lui	a0,0xfffff
ffffffffc020118c:	8ee9                	and	a3,a3,a0
ffffffffc020118e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201192:	04e7f563          	bgeu	a5,a4,ffffffffc02011dc <get_pte+0x1b2>
ffffffffc0201196:	000ab503          	ld	a0,0(s5)
ffffffffc020119a:	00c95793          	srli	a5,s2,0xc
ffffffffc020119e:	1ff7f793          	andi	a5,a5,511
ffffffffc02011a2:	96aa                	add	a3,a3,a0
ffffffffc02011a4:	00379513          	slli	a0,a5,0x3
ffffffffc02011a8:	9536                	add	a0,a0,a3
ffffffffc02011aa:	60a6                	ld	ra,72(sp)
ffffffffc02011ac:	6406                	ld	s0,64(sp)
ffffffffc02011ae:	74e2                	ld	s1,56(sp)
ffffffffc02011b0:	7942                	ld	s2,48(sp)
ffffffffc02011b2:	79a2                	ld	s3,40(sp)
ffffffffc02011b4:	7a02                	ld	s4,32(sp)
ffffffffc02011b6:	6ae2                	ld	s5,24(sp)
ffffffffc02011b8:	6b42                	ld	s6,16(sp)
ffffffffc02011ba:	6ba2                	ld	s7,8(sp)
ffffffffc02011bc:	6161                	addi	sp,sp,80
ffffffffc02011be:	8082                	ret
ffffffffc02011c0:	4501                	li	a0,0
ffffffffc02011c2:	b7e5                	j	ffffffffc02011aa <get_pte+0x180>
ffffffffc02011c4:	00004617          	auipc	a2,0x4
ffffffffc02011c8:	cfc60613          	addi	a2,a2,-772 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc02011cc:	10200593          	li	a1,258
ffffffffc02011d0:	00004517          	auipc	a0,0x4
ffffffffc02011d4:	d1850513          	addi	a0,a0,-744 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc02011d8:	f2dfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	ce460613          	addi	a2,a2,-796 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc02011e4:	10f00593          	li	a1,271
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	d0050513          	addi	a0,a0,-768 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc02011f0:	f15fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02011f4:	86aa                	mv	a3,a0
ffffffffc02011f6:	00004617          	auipc	a2,0x4
ffffffffc02011fa:	cca60613          	addi	a2,a2,-822 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc02011fe:	10b00593          	li	a1,267
ffffffffc0201202:	00004517          	auipc	a0,0x4
ffffffffc0201206:	ce650513          	addi	a0,a0,-794 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc020120a:	efbfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020120e:	86aa                	mv	a3,a0
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	cb060613          	addi	a2,a2,-848 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0201218:	0ff00593          	li	a1,255
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	ccc50513          	addi	a0,a0,-820 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201224:	ee1fe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201228 <get_page>:
ffffffffc0201228:	1141                	addi	sp,sp,-16
ffffffffc020122a:	e022                	sd	s0,0(sp)
ffffffffc020122c:	8432                	mv	s0,a2
ffffffffc020122e:	4601                	li	a2,0
ffffffffc0201230:	e406                	sd	ra,8(sp)
ffffffffc0201232:	df9ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0201236:	c011                	beqz	s0,ffffffffc020123a <get_page+0x12>
ffffffffc0201238:	e008                	sd	a0,0(s0)
ffffffffc020123a:	c521                	beqz	a0,ffffffffc0201282 <get_page+0x5a>
ffffffffc020123c:	611c                	ld	a5,0(a0)
ffffffffc020123e:	4501                	li	a0,0
ffffffffc0201240:	0017f713          	andi	a4,a5,1
ffffffffc0201244:	e709                	bnez	a4,ffffffffc020124e <get_page+0x26>
ffffffffc0201246:	60a2                	ld	ra,8(sp)
ffffffffc0201248:	6402                	ld	s0,0(sp)
ffffffffc020124a:	0141                	addi	sp,sp,16
ffffffffc020124c:	8082                	ret
ffffffffc020124e:	00010717          	auipc	a4,0x10
ffffffffc0201252:	21270713          	addi	a4,a4,530 # ffffffffc0211460 <npage>
ffffffffc0201256:	6318                	ld	a4,0(a4)
ffffffffc0201258:	078a                	slli	a5,a5,0x2
ffffffffc020125a:	83b1                	srli	a5,a5,0xc
ffffffffc020125c:	02e7f863          	bgeu	a5,a4,ffffffffc020128c <get_page+0x64>
ffffffffc0201260:	fff80537          	lui	a0,0xfff80
ffffffffc0201264:	97aa                	add	a5,a5,a0
ffffffffc0201266:	00010697          	auipc	a3,0x10
ffffffffc020126a:	24a68693          	addi	a3,a3,586 # ffffffffc02114b0 <pages>
ffffffffc020126e:	6288                	ld	a0,0(a3)
ffffffffc0201270:	60a2                	ld	ra,8(sp)
ffffffffc0201272:	6402                	ld	s0,0(sp)
ffffffffc0201274:	00379713          	slli	a4,a5,0x3
ffffffffc0201278:	97ba                	add	a5,a5,a4
ffffffffc020127a:	078e                	slli	a5,a5,0x3
ffffffffc020127c:	953e                	add	a0,a0,a5
ffffffffc020127e:	0141                	addi	sp,sp,16
ffffffffc0201280:	8082                	ret
ffffffffc0201282:	60a2                	ld	ra,8(sp)
ffffffffc0201284:	6402                	ld	s0,0(sp)
ffffffffc0201286:	4501                	li	a0,0
ffffffffc0201288:	0141                	addi	sp,sp,16
ffffffffc020128a:	8082                	ret
ffffffffc020128c:	c75ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc0201290 <page_remove>:
ffffffffc0201290:	1141                	addi	sp,sp,-16
ffffffffc0201292:	4601                	li	a2,0
ffffffffc0201294:	e406                	sd	ra,8(sp)
ffffffffc0201296:	e022                	sd	s0,0(sp)
ffffffffc0201298:	d93ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020129c:	c511                	beqz	a0,ffffffffc02012a8 <page_remove+0x18>
ffffffffc020129e:	611c                	ld	a5,0(a0)
ffffffffc02012a0:	842a                	mv	s0,a0
ffffffffc02012a2:	0017f713          	andi	a4,a5,1
ffffffffc02012a6:	e709                	bnez	a4,ffffffffc02012b0 <page_remove+0x20>
ffffffffc02012a8:	60a2                	ld	ra,8(sp)
ffffffffc02012aa:	6402                	ld	s0,0(sp)
ffffffffc02012ac:	0141                	addi	sp,sp,16
ffffffffc02012ae:	8082                	ret
ffffffffc02012b0:	00010717          	auipc	a4,0x10
ffffffffc02012b4:	1b070713          	addi	a4,a4,432 # ffffffffc0211460 <npage>
ffffffffc02012b8:	6318                	ld	a4,0(a4)
ffffffffc02012ba:	078a                	slli	a5,a5,0x2
ffffffffc02012bc:	83b1                	srli	a5,a5,0xc
ffffffffc02012be:	04e7f063          	bgeu	a5,a4,ffffffffc02012fe <page_remove+0x6e>
ffffffffc02012c2:	fff80737          	lui	a4,0xfff80
ffffffffc02012c6:	97ba                	add	a5,a5,a4
ffffffffc02012c8:	00010717          	auipc	a4,0x10
ffffffffc02012cc:	1e870713          	addi	a4,a4,488 # ffffffffc02114b0 <pages>
ffffffffc02012d0:	6308                	ld	a0,0(a4)
ffffffffc02012d2:	00379713          	slli	a4,a5,0x3
ffffffffc02012d6:	97ba                	add	a5,a5,a4
ffffffffc02012d8:	078e                	slli	a5,a5,0x3
ffffffffc02012da:	953e                	add	a0,a0,a5
ffffffffc02012dc:	411c                	lw	a5,0(a0)
ffffffffc02012de:	fff7871b          	addiw	a4,a5,-1
ffffffffc02012e2:	c118                	sw	a4,0(a0)
ffffffffc02012e4:	cb09                	beqz	a4,ffffffffc02012f6 <page_remove+0x66>
ffffffffc02012e6:	00043023          	sd	zero,0(s0)
ffffffffc02012ea:	12000073          	sfence.vma
ffffffffc02012ee:	60a2                	ld	ra,8(sp)
ffffffffc02012f0:	6402                	ld	s0,0(sp)
ffffffffc02012f2:	0141                	addi	sp,sp,16
ffffffffc02012f4:	8082                	ret
ffffffffc02012f6:	4585                	li	a1,1
ffffffffc02012f8:	cadff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02012fc:	b7ed                	j	ffffffffc02012e6 <page_remove+0x56>
ffffffffc02012fe:	c03ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc0201302 <page_insert>:
ffffffffc0201302:	7179                	addi	sp,sp,-48
ffffffffc0201304:	87b2                	mv	a5,a2
ffffffffc0201306:	f022                	sd	s0,32(sp)
ffffffffc0201308:	4605                	li	a2,1
ffffffffc020130a:	842e                	mv	s0,a1
ffffffffc020130c:	85be                	mv	a1,a5
ffffffffc020130e:	ec26                	sd	s1,24(sp)
ffffffffc0201310:	f406                	sd	ra,40(sp)
ffffffffc0201312:	e84a                	sd	s2,16(sp)
ffffffffc0201314:	e44e                	sd	s3,8(sp)
ffffffffc0201316:	84b6                	mv	s1,a3
ffffffffc0201318:	d13ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020131c:	c945                	beqz	a0,ffffffffc02013cc <page_insert+0xca>
ffffffffc020131e:	4014                	lw	a3,0(s0)
ffffffffc0201320:	611c                	ld	a5,0(a0)
ffffffffc0201322:	892a                	mv	s2,a0
ffffffffc0201324:	0016871b          	addiw	a4,a3,1
ffffffffc0201328:	c018                	sw	a4,0(s0)
ffffffffc020132a:	0017f713          	andi	a4,a5,1
ffffffffc020132e:	e339                	bnez	a4,ffffffffc0201374 <page_insert+0x72>
ffffffffc0201330:	00010797          	auipc	a5,0x10
ffffffffc0201334:	18078793          	addi	a5,a5,384 # ffffffffc02114b0 <pages>
ffffffffc0201338:	639c                	ld	a5,0(a5)
ffffffffc020133a:	00004717          	auipc	a4,0x4
ffffffffc020133e:	b7e70713          	addi	a4,a4,-1154 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0201342:	40f407b3          	sub	a5,s0,a5
ffffffffc0201346:	6300                	ld	s0,0(a4)
ffffffffc0201348:	878d                	srai	a5,a5,0x3
ffffffffc020134a:	000806b7          	lui	a3,0x80
ffffffffc020134e:	028787b3          	mul	a5,a5,s0
ffffffffc0201352:	97b6                	add	a5,a5,a3
ffffffffc0201354:	07aa                	slli	a5,a5,0xa
ffffffffc0201356:	8fc5                	or	a5,a5,s1
ffffffffc0201358:	0017e793          	ori	a5,a5,1
ffffffffc020135c:	00f93023          	sd	a5,0(s2)
ffffffffc0201360:	12000073          	sfence.vma
ffffffffc0201364:	4501                	li	a0,0
ffffffffc0201366:	70a2                	ld	ra,40(sp)
ffffffffc0201368:	7402                	ld	s0,32(sp)
ffffffffc020136a:	64e2                	ld	s1,24(sp)
ffffffffc020136c:	6942                	ld	s2,16(sp)
ffffffffc020136e:	69a2                	ld	s3,8(sp)
ffffffffc0201370:	6145                	addi	sp,sp,48
ffffffffc0201372:	8082                	ret
ffffffffc0201374:	00010717          	auipc	a4,0x10
ffffffffc0201378:	0ec70713          	addi	a4,a4,236 # ffffffffc0211460 <npage>
ffffffffc020137c:	6318                	ld	a4,0(a4)
ffffffffc020137e:	00279513          	slli	a0,a5,0x2
ffffffffc0201382:	8131                	srli	a0,a0,0xc
ffffffffc0201384:	04e57663          	bgeu	a0,a4,ffffffffc02013d0 <page_insert+0xce>
ffffffffc0201388:	fff807b7          	lui	a5,0xfff80
ffffffffc020138c:	953e                	add	a0,a0,a5
ffffffffc020138e:	00010997          	auipc	s3,0x10
ffffffffc0201392:	12298993          	addi	s3,s3,290 # ffffffffc02114b0 <pages>
ffffffffc0201396:	0009b783          	ld	a5,0(s3)
ffffffffc020139a:	00351713          	slli	a4,a0,0x3
ffffffffc020139e:	953a                	add	a0,a0,a4
ffffffffc02013a0:	050e                	slli	a0,a0,0x3
ffffffffc02013a2:	953e                	add	a0,a0,a5
ffffffffc02013a4:	00a40e63          	beq	s0,a0,ffffffffc02013c0 <page_insert+0xbe>
ffffffffc02013a8:	411c                	lw	a5,0(a0)
ffffffffc02013aa:	fff7871b          	addiw	a4,a5,-1
ffffffffc02013ae:	c118                	sw	a4,0(a0)
ffffffffc02013b0:	cb11                	beqz	a4,ffffffffc02013c4 <page_insert+0xc2>
ffffffffc02013b2:	00093023          	sd	zero,0(s2)
ffffffffc02013b6:	12000073          	sfence.vma
ffffffffc02013ba:	0009b783          	ld	a5,0(s3)
ffffffffc02013be:	bfb5                	j	ffffffffc020133a <page_insert+0x38>
ffffffffc02013c0:	c014                	sw	a3,0(s0)
ffffffffc02013c2:	bfa5                	j	ffffffffc020133a <page_insert+0x38>
ffffffffc02013c4:	4585                	li	a1,1
ffffffffc02013c6:	bdfff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02013ca:	b7e5                	j	ffffffffc02013b2 <page_insert+0xb0>
ffffffffc02013cc:	5571                	li	a0,-4
ffffffffc02013ce:	bf61                	j	ffffffffc0201366 <page_insert+0x64>
ffffffffc02013d0:	b31ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>

ffffffffc02013d4 <pmm_init>:
ffffffffc02013d4:	00005797          	auipc	a5,0x5
ffffffffc02013d8:	b6c78793          	addi	a5,a5,-1172 # ffffffffc0205f40 <default_pmm_manager>
ffffffffc02013dc:	638c                	ld	a1,0(a5)
ffffffffc02013de:	711d                	addi	sp,sp,-96
ffffffffc02013e0:	00004517          	auipc	a0,0x4
ffffffffc02013e4:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204f80 <commands+0xaf8>
ffffffffc02013e8:	ec86                	sd	ra,88(sp)
ffffffffc02013ea:	00010717          	auipc	a4,0x10
ffffffffc02013ee:	0af73723          	sd	a5,174(a4) # ffffffffc0211498 <pmm_manager>
ffffffffc02013f2:	e8a2                	sd	s0,80(sp)
ffffffffc02013f4:	e4a6                	sd	s1,72(sp)
ffffffffc02013f6:	e0ca                	sd	s2,64(sp)
ffffffffc02013f8:	fc4e                	sd	s3,56(sp)
ffffffffc02013fa:	f852                	sd	s4,48(sp)
ffffffffc02013fc:	f456                	sd	s5,40(sp)
ffffffffc02013fe:	f05a                	sd	s6,32(sp)
ffffffffc0201400:	ec5e                	sd	s7,24(sp)
ffffffffc0201402:	e862                	sd	s8,16(sp)
ffffffffc0201404:	e466                	sd	s9,8(sp)
ffffffffc0201406:	00010417          	auipc	s0,0x10
ffffffffc020140a:	09240413          	addi	s0,s0,146 # ffffffffc0211498 <pmm_manager>
ffffffffc020140e:	cb1fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201412:	601c                	ld	a5,0(s0)
ffffffffc0201414:	49c5                	li	s3,17
ffffffffc0201416:	40100a13          	li	s4,1025
ffffffffc020141a:	679c                	ld	a5,8(a5)
ffffffffc020141c:	00010497          	auipc	s1,0x10
ffffffffc0201420:	04448493          	addi	s1,s1,68 # ffffffffc0211460 <npage>
ffffffffc0201424:	00010917          	auipc	s2,0x10
ffffffffc0201428:	08c90913          	addi	s2,s2,140 # ffffffffc02114b0 <pages>
ffffffffc020142c:	9782                	jalr	a5
ffffffffc020142e:	57f5                	li	a5,-3
ffffffffc0201430:	07fa                	slli	a5,a5,0x1e
ffffffffc0201432:	07e006b7          	lui	a3,0x7e00
ffffffffc0201436:	01b99613          	slli	a2,s3,0x1b
ffffffffc020143a:	015a1593          	slli	a1,s4,0x15
ffffffffc020143e:	00004517          	auipc	a0,0x4
ffffffffc0201442:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0204f98 <commands+0xb10>
ffffffffc0201446:	00010717          	auipc	a4,0x10
ffffffffc020144a:	04f73d23          	sd	a5,90(a4) # ffffffffc02114a0 <va_pa_offset>
ffffffffc020144e:	c71fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201452:	00004517          	auipc	a0,0x4
ffffffffc0201456:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204fc8 <commands+0xb40>
ffffffffc020145a:	c65fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020145e:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201462:	16fd                	addi	a3,a3,-1
ffffffffc0201464:	015a1613          	slli	a2,s4,0x15
ffffffffc0201468:	07e005b7          	lui	a1,0x7e00
ffffffffc020146c:	00004517          	auipc	a0,0x4
ffffffffc0201470:	b7450513          	addi	a0,a0,-1164 # ffffffffc0204fe0 <commands+0xb58>
ffffffffc0201474:	c4bfe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201478:	777d                	lui	a4,0xfffff
ffffffffc020147a:	00011797          	auipc	a5,0x11
ffffffffc020147e:	12578793          	addi	a5,a5,293 # ffffffffc021259f <end+0xfff>
ffffffffc0201482:	8ff9                	and	a5,a5,a4
ffffffffc0201484:	00088737          	lui	a4,0x88
ffffffffc0201488:	00010697          	auipc	a3,0x10
ffffffffc020148c:	fce6bc23          	sd	a4,-40(a3) # ffffffffc0211460 <npage>
ffffffffc0201490:	00010717          	auipc	a4,0x10
ffffffffc0201494:	02f73023          	sd	a5,32(a4) # ffffffffc02114b0 <pages>
ffffffffc0201498:	4681                	li	a3,0
ffffffffc020149a:	4701                	li	a4,0
ffffffffc020149c:	4585                	li	a1,1
ffffffffc020149e:	fff80637          	lui	a2,0xfff80
ffffffffc02014a2:	a019                	j	ffffffffc02014a8 <pmm_init+0xd4>
ffffffffc02014a4:	00093783          	ld	a5,0(s2)
ffffffffc02014a8:	97b6                	add	a5,a5,a3
ffffffffc02014aa:	07a1                	addi	a5,a5,8
ffffffffc02014ac:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc02014b0:	609c                	ld	a5,0(s1)
ffffffffc02014b2:	0705                	addi	a4,a4,1
ffffffffc02014b4:	04868693          	addi	a3,a3,72
ffffffffc02014b8:	00c78533          	add	a0,a5,a2
ffffffffc02014bc:	fea764e3          	bltu	a4,a0,ffffffffc02014a4 <pmm_init+0xd0>
ffffffffc02014c0:	00093503          	ld	a0,0(s2)
ffffffffc02014c4:	00379693          	slli	a3,a5,0x3
ffffffffc02014c8:	96be                	add	a3,a3,a5
ffffffffc02014ca:	fdc00737          	lui	a4,0xfdc00
ffffffffc02014ce:	972a                	add	a4,a4,a0
ffffffffc02014d0:	068e                	slli	a3,a3,0x3
ffffffffc02014d2:	96ba                	add	a3,a3,a4
ffffffffc02014d4:	c0200737          	lui	a4,0xc0200
ffffffffc02014d8:	58e6ea63          	bltu	a3,a4,ffffffffc0201a6c <pmm_init+0x698>
ffffffffc02014dc:	00010997          	auipc	s3,0x10
ffffffffc02014e0:	fc498993          	addi	s3,s3,-60 # ffffffffc02114a0 <va_pa_offset>
ffffffffc02014e4:	0009b703          	ld	a4,0(s3)
ffffffffc02014e8:	45c5                	li	a1,17
ffffffffc02014ea:	05ee                	slli	a1,a1,0x1b
ffffffffc02014ec:	8e99                	sub	a3,a3,a4
ffffffffc02014ee:	44b6ef63          	bltu	a3,a1,ffffffffc020194c <pmm_init+0x578>
ffffffffc02014f2:	601c                	ld	a5,0(s0)
ffffffffc02014f4:	00010417          	auipc	s0,0x10
ffffffffc02014f8:	f6440413          	addi	s0,s0,-156 # ffffffffc0211458 <boot_pgdir>
ffffffffc02014fc:	7b9c                	ld	a5,48(a5)
ffffffffc02014fe:	9782                	jalr	a5
ffffffffc0201500:	00004517          	auipc	a0,0x4
ffffffffc0201504:	b3050513          	addi	a0,a0,-1232 # ffffffffc0205030 <commands+0xba8>
ffffffffc0201508:	bb7fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020150c:	00008697          	auipc	a3,0x8
ffffffffc0201510:	af468693          	addi	a3,a3,-1292 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201514:	00010797          	auipc	a5,0x10
ffffffffc0201518:	f4d7b223          	sd	a3,-188(a5) # ffffffffc0211458 <boot_pgdir>
ffffffffc020151c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201520:	0ef6ece3          	bltu	a3,a5,ffffffffc0201e18 <pmm_init+0xa44>
ffffffffc0201524:	0009b783          	ld	a5,0(s3)
ffffffffc0201528:	8e9d                	sub	a3,a3,a5
ffffffffc020152a:	00010797          	auipc	a5,0x10
ffffffffc020152e:	f6d7bf23          	sd	a3,-130(a5) # ffffffffc02114a8 <boot_cr3>
ffffffffc0201532:	ab9ff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201536:	6098                	ld	a4,0(s1)
ffffffffc0201538:	c80007b7          	lui	a5,0xc8000
ffffffffc020153c:	83b1                	srli	a5,a5,0xc
ffffffffc020153e:	8a2a                	mv	s4,a0
ffffffffc0201540:	0ae7ece3          	bltu	a5,a4,ffffffffc0201df8 <pmm_init+0xa24>
ffffffffc0201544:	6008                	ld	a0,0(s0)
ffffffffc0201546:	4c050363          	beqz	a0,ffffffffc0201a0c <pmm_init+0x638>
ffffffffc020154a:	6785                	lui	a5,0x1
ffffffffc020154c:	17fd                	addi	a5,a5,-1
ffffffffc020154e:	8fe9                	and	a5,a5,a0
ffffffffc0201550:	2781                	sext.w	a5,a5
ffffffffc0201552:	4a079d63          	bnez	a5,ffffffffc0201a0c <pmm_init+0x638>
ffffffffc0201556:	4601                	li	a2,0
ffffffffc0201558:	4581                	li	a1,0
ffffffffc020155a:	ccfff0ef          	jal	ra,ffffffffc0201228 <get_page>
ffffffffc020155e:	4c051763          	bnez	a0,ffffffffc0201a2c <pmm_init+0x658>
ffffffffc0201562:	4505                	li	a0,1
ffffffffc0201564:	9b9ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201568:	8aaa                	mv	s5,a0
ffffffffc020156a:	6008                	ld	a0,0(s0)
ffffffffc020156c:	4681                	li	a3,0
ffffffffc020156e:	4601                	li	a2,0
ffffffffc0201570:	85d6                	mv	a1,s5
ffffffffc0201572:	d91ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201576:	52051763          	bnez	a0,ffffffffc0201aa4 <pmm_init+0x6d0>
ffffffffc020157a:	6008                	ld	a0,0(s0)
ffffffffc020157c:	4601                	li	a2,0
ffffffffc020157e:	4581                	li	a1,0
ffffffffc0201580:	aabff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0201584:	50050063          	beqz	a0,ffffffffc0201a84 <pmm_init+0x6b0>
ffffffffc0201588:	611c                	ld	a5,0(a0)
ffffffffc020158a:	0017f713          	andi	a4,a5,1
ffffffffc020158e:	46070363          	beqz	a4,ffffffffc02019f4 <pmm_init+0x620>
ffffffffc0201592:	6090                	ld	a2,0(s1)
ffffffffc0201594:	078a                	slli	a5,a5,0x2
ffffffffc0201596:	83b1                	srli	a5,a5,0xc
ffffffffc0201598:	44c7f063          	bgeu	a5,a2,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc020159c:	fff80737          	lui	a4,0xfff80
ffffffffc02015a0:	97ba                	add	a5,a5,a4
ffffffffc02015a2:	00379713          	slli	a4,a5,0x3
ffffffffc02015a6:	00093683          	ld	a3,0(s2)
ffffffffc02015aa:	97ba                	add	a5,a5,a4
ffffffffc02015ac:	078e                	slli	a5,a5,0x3
ffffffffc02015ae:	97b6                	add	a5,a5,a3
ffffffffc02015b0:	5efa9463          	bne	s5,a5,ffffffffc0201b98 <pmm_init+0x7c4>
ffffffffc02015b4:	000aab83          	lw	s7,0(s5)
ffffffffc02015b8:	4785                	li	a5,1
ffffffffc02015ba:	5afb9f63          	bne	s7,a5,ffffffffc0201b78 <pmm_init+0x7a4>
ffffffffc02015be:	6008                	ld	a0,0(s0)
ffffffffc02015c0:	76fd                	lui	a3,0xfffff
ffffffffc02015c2:	611c                	ld	a5,0(a0)
ffffffffc02015c4:	078a                	slli	a5,a5,0x2
ffffffffc02015c6:	8ff5                	and	a5,a5,a3
ffffffffc02015c8:	00c7d713          	srli	a4,a5,0xc
ffffffffc02015cc:	58c77963          	bgeu	a4,a2,ffffffffc0201b5e <pmm_init+0x78a>
ffffffffc02015d0:	0009bc03          	ld	s8,0(s3)
ffffffffc02015d4:	97e2                	add	a5,a5,s8
ffffffffc02015d6:	0007bb03          	ld	s6,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02015da:	0b0a                	slli	s6,s6,0x2
ffffffffc02015dc:	00db7b33          	and	s6,s6,a3
ffffffffc02015e0:	00cb5793          	srli	a5,s6,0xc
ffffffffc02015e4:	56c7f063          	bgeu	a5,a2,ffffffffc0201b44 <pmm_init+0x770>
ffffffffc02015e8:	4601                	li	a2,0
ffffffffc02015ea:	6585                	lui	a1,0x1
ffffffffc02015ec:	9b62                	add	s6,s6,s8
ffffffffc02015ee:	a3dff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc02015f2:	0b21                	addi	s6,s6,8
ffffffffc02015f4:	53651863          	bne	a0,s6,ffffffffc0201b24 <pmm_init+0x750>
ffffffffc02015f8:	4505                	li	a0,1
ffffffffc02015fa:	923ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02015fe:	8b2a                	mv	s6,a0
ffffffffc0201600:	6008                	ld	a0,0(s0)
ffffffffc0201602:	46d1                	li	a3,20
ffffffffc0201604:	6605                	lui	a2,0x1
ffffffffc0201606:	85da                	mv	a1,s6
ffffffffc0201608:	cfbff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc020160c:	4e051c63          	bnez	a0,ffffffffc0201b04 <pmm_init+0x730>
ffffffffc0201610:	6008                	ld	a0,0(s0)
ffffffffc0201612:	4601                	li	a2,0
ffffffffc0201614:	6585                	lui	a1,0x1
ffffffffc0201616:	a15ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020161a:	4c050563          	beqz	a0,ffffffffc0201ae4 <pmm_init+0x710>
ffffffffc020161e:	611c                	ld	a5,0(a0)
ffffffffc0201620:	0107f713          	andi	a4,a5,16
ffffffffc0201624:	4a070063          	beqz	a4,ffffffffc0201ac4 <pmm_init+0x6f0>
ffffffffc0201628:	8b91                	andi	a5,a5,4
ffffffffc020162a:	66078763          	beqz	a5,ffffffffc0201c98 <pmm_init+0x8c4>
ffffffffc020162e:	6008                	ld	a0,0(s0)
ffffffffc0201630:	611c                	ld	a5,0(a0)
ffffffffc0201632:	8bc1                	andi	a5,a5,16
ffffffffc0201634:	64078263          	beqz	a5,ffffffffc0201c78 <pmm_init+0x8a4>
ffffffffc0201638:	000b2783          	lw	a5,0(s6)
ffffffffc020163c:	61779e63          	bne	a5,s7,ffffffffc0201c58 <pmm_init+0x884>
ffffffffc0201640:	4681                	li	a3,0
ffffffffc0201642:	6605                	lui	a2,0x1
ffffffffc0201644:	85d6                	mv	a1,s5
ffffffffc0201646:	cbdff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc020164a:	5e051763          	bnez	a0,ffffffffc0201c38 <pmm_init+0x864>
ffffffffc020164e:	000aa703          	lw	a4,0(s5)
ffffffffc0201652:	4789                	li	a5,2
ffffffffc0201654:	5cf71263          	bne	a4,a5,ffffffffc0201c18 <pmm_init+0x844>
ffffffffc0201658:	000b2783          	lw	a5,0(s6)
ffffffffc020165c:	58079e63          	bnez	a5,ffffffffc0201bf8 <pmm_init+0x824>
ffffffffc0201660:	6008                	ld	a0,0(s0)
ffffffffc0201662:	4601                	li	a2,0
ffffffffc0201664:	6585                	lui	a1,0x1
ffffffffc0201666:	9c5ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020166a:	56050763          	beqz	a0,ffffffffc0201bd8 <pmm_init+0x804>
ffffffffc020166e:	6114                	ld	a3,0(a0)
ffffffffc0201670:	0016f793          	andi	a5,a3,1
ffffffffc0201674:	38078063          	beqz	a5,ffffffffc02019f4 <pmm_init+0x620>
ffffffffc0201678:	6098                	ld	a4,0(s1)
ffffffffc020167a:	00269793          	slli	a5,a3,0x2
ffffffffc020167e:	83b1                	srli	a5,a5,0xc
ffffffffc0201680:	34e7fc63          	bgeu	a5,a4,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc0201684:	fff80737          	lui	a4,0xfff80
ffffffffc0201688:	97ba                	add	a5,a5,a4
ffffffffc020168a:	00379713          	slli	a4,a5,0x3
ffffffffc020168e:	00093603          	ld	a2,0(s2)
ffffffffc0201692:	97ba                	add	a5,a5,a4
ffffffffc0201694:	078e                	slli	a5,a5,0x3
ffffffffc0201696:	97b2                	add	a5,a5,a2
ffffffffc0201698:	52fa9063          	bne	s5,a5,ffffffffc0201bb8 <pmm_init+0x7e4>
ffffffffc020169c:	8ac1                	andi	a3,a3,16
ffffffffc020169e:	6e069d63          	bnez	a3,ffffffffc0201d98 <pmm_init+0x9c4>
ffffffffc02016a2:	6008                	ld	a0,0(s0)
ffffffffc02016a4:	4581                	li	a1,0
ffffffffc02016a6:	bebff0ef          	jal	ra,ffffffffc0201290 <page_remove>
ffffffffc02016aa:	000aa703          	lw	a4,0(s5)
ffffffffc02016ae:	4785                	li	a5,1
ffffffffc02016b0:	6cf71463          	bne	a4,a5,ffffffffc0201d78 <pmm_init+0x9a4>
ffffffffc02016b4:	000b2783          	lw	a5,0(s6)
ffffffffc02016b8:	6a079063          	bnez	a5,ffffffffc0201d58 <pmm_init+0x984>
ffffffffc02016bc:	6008                	ld	a0,0(s0)
ffffffffc02016be:	6585                	lui	a1,0x1
ffffffffc02016c0:	bd1ff0ef          	jal	ra,ffffffffc0201290 <page_remove>
ffffffffc02016c4:	000aa783          	lw	a5,0(s5)
ffffffffc02016c8:	66079863          	bnez	a5,ffffffffc0201d38 <pmm_init+0x964>
ffffffffc02016cc:	000b2783          	lw	a5,0(s6)
ffffffffc02016d0:	70079463          	bnez	a5,ffffffffc0201dd8 <pmm_init+0xa04>
ffffffffc02016d4:	00043b03          	ld	s6,0(s0)
ffffffffc02016d8:	608c                	ld	a1,0(s1)
ffffffffc02016da:	000b3783          	ld	a5,0(s6)
ffffffffc02016de:	078a                	slli	a5,a5,0x2
ffffffffc02016e0:	83b1                	srli	a5,a5,0xc
ffffffffc02016e2:	2eb7fb63          	bgeu	a5,a1,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc02016e6:	fff80737          	lui	a4,0xfff80
ffffffffc02016ea:	973e                	add	a4,a4,a5
ffffffffc02016ec:	00371793          	slli	a5,a4,0x3
ffffffffc02016f0:	00093603          	ld	a2,0(s2)
ffffffffc02016f4:	97ba                	add	a5,a5,a4
ffffffffc02016f6:	078e                	slli	a5,a5,0x3
ffffffffc02016f8:	00f60733          	add	a4,a2,a5
ffffffffc02016fc:	4314                	lw	a3,0(a4)
ffffffffc02016fe:	4705                	li	a4,1
ffffffffc0201700:	6ae69c63          	bne	a3,a4,ffffffffc0201db8 <pmm_init+0x9e4>
ffffffffc0201704:	00003a97          	auipc	s5,0x3
ffffffffc0201708:	7b4a8a93          	addi	s5,s5,1972 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc020170c:	000ab703          	ld	a4,0(s5)
ffffffffc0201710:	4037d693          	srai	a3,a5,0x3
ffffffffc0201714:	00080bb7          	lui	s7,0x80
ffffffffc0201718:	02e686b3          	mul	a3,a3,a4
ffffffffc020171c:	577d                	li	a4,-1
ffffffffc020171e:	8331                	srli	a4,a4,0xc
ffffffffc0201720:	96de                	add	a3,a3,s7
ffffffffc0201722:	8f75                	and	a4,a4,a3
ffffffffc0201724:	06b2                	slli	a3,a3,0xc
ffffffffc0201726:	2ab77b63          	bgeu	a4,a1,ffffffffc02019dc <pmm_init+0x608>
ffffffffc020172a:	0009b783          	ld	a5,0(s3)
ffffffffc020172e:	96be                	add	a3,a3,a5
ffffffffc0201730:	629c                	ld	a5,0(a3)
ffffffffc0201732:	078a                	slli	a5,a5,0x2
ffffffffc0201734:	83b1                	srli	a5,a5,0xc
ffffffffc0201736:	2ab7f163          	bgeu	a5,a1,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc020173a:	417787b3          	sub	a5,a5,s7
ffffffffc020173e:	00379513          	slli	a0,a5,0x3
ffffffffc0201742:	97aa                	add	a5,a5,a0
ffffffffc0201744:	00379513          	slli	a0,a5,0x3
ffffffffc0201748:	9532                	add	a0,a0,a2
ffffffffc020174a:	4585                	li	a1,1
ffffffffc020174c:	859ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0201750:	000b3503          	ld	a0,0(s6)
ffffffffc0201754:	609c                	ld	a5,0(s1)
ffffffffc0201756:	050a                	slli	a0,a0,0x2
ffffffffc0201758:	8131                	srli	a0,a0,0xc
ffffffffc020175a:	26f57f63          	bgeu	a0,a5,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc020175e:	417507b3          	sub	a5,a0,s7
ffffffffc0201762:	00379513          	slli	a0,a5,0x3
ffffffffc0201766:	00093703          	ld	a4,0(s2)
ffffffffc020176a:	953e                	add	a0,a0,a5
ffffffffc020176c:	050e                	slli	a0,a0,0x3
ffffffffc020176e:	4585                	li	a1,1
ffffffffc0201770:	953a                	add	a0,a0,a4
ffffffffc0201772:	833ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0201776:	601c                	ld	a5,0(s0)
ffffffffc0201778:	0007b023          	sd	zero,0(a5)
ffffffffc020177c:	86fff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201780:	2caa1663          	bne	s4,a0,ffffffffc0201a4c <pmm_init+0x678>
ffffffffc0201784:	00004517          	auipc	a0,0x4
ffffffffc0201788:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0205340 <commands+0xeb8>
ffffffffc020178c:	933fe0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0201790:	85bff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201794:	6098                	ld	a4,0(s1)
ffffffffc0201796:	c02007b7          	lui	a5,0xc0200
ffffffffc020179a:	8b2a                	mv	s6,a0
ffffffffc020179c:	00c71693          	slli	a3,a4,0xc
ffffffffc02017a0:	1cd7fd63          	bgeu	a5,a3,ffffffffc020197a <pmm_init+0x5a6>
ffffffffc02017a4:	83b1                	srli	a5,a5,0xc
ffffffffc02017a6:	6008                	ld	a0,0(s0)
ffffffffc02017a8:	c0200a37          	lui	s4,0xc0200
ffffffffc02017ac:	1ce7f963          	bgeu	a5,a4,ffffffffc020197e <pmm_init+0x5aa>
ffffffffc02017b0:	7c7d                	lui	s8,0xfffff
ffffffffc02017b2:	6b85                	lui	s7,0x1
ffffffffc02017b4:	a029                	j	ffffffffc02017be <pmm_init+0x3ea>
ffffffffc02017b6:	00ca5713          	srli	a4,s4,0xc
ffffffffc02017ba:	1cf77263          	bgeu	a4,a5,ffffffffc020197e <pmm_init+0x5aa>
ffffffffc02017be:	0009b583          	ld	a1,0(s3)
ffffffffc02017c2:	4601                	li	a2,0
ffffffffc02017c4:	95d2                	add	a1,a1,s4
ffffffffc02017c6:	865ff0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc02017ca:	1c050763          	beqz	a0,ffffffffc0201998 <pmm_init+0x5c4>
ffffffffc02017ce:	611c                	ld	a5,0(a0)
ffffffffc02017d0:	078a                	slli	a5,a5,0x2
ffffffffc02017d2:	0187f7b3          	and	a5,a5,s8
ffffffffc02017d6:	1f479163          	bne	a5,s4,ffffffffc02019b8 <pmm_init+0x5e4>
ffffffffc02017da:	609c                	ld	a5,0(s1)
ffffffffc02017dc:	9a5e                	add	s4,s4,s7
ffffffffc02017de:	6008                	ld	a0,0(s0)
ffffffffc02017e0:	00c79713          	slli	a4,a5,0xc
ffffffffc02017e4:	fcea69e3          	bltu	s4,a4,ffffffffc02017b6 <pmm_init+0x3e2>
ffffffffc02017e8:	611c                	ld	a5,0(a0)
ffffffffc02017ea:	6a079363          	bnez	a5,ffffffffc0201e90 <pmm_init+0xabc>
ffffffffc02017ee:	4505                	li	a0,1
ffffffffc02017f0:	f2cff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02017f4:	8a2a                	mv	s4,a0
ffffffffc02017f6:	6008                	ld	a0,0(s0)
ffffffffc02017f8:	4699                	li	a3,6
ffffffffc02017fa:	10000613          	li	a2,256
ffffffffc02017fe:	85d2                	mv	a1,s4
ffffffffc0201800:	b03ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201804:	66051663          	bnez	a0,ffffffffc0201e70 <pmm_init+0xa9c>
ffffffffc0201808:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc020180c:	4785                	li	a5,1
ffffffffc020180e:	64f71163          	bne	a4,a5,ffffffffc0201e50 <pmm_init+0xa7c>
ffffffffc0201812:	6008                	ld	a0,0(s0)
ffffffffc0201814:	6b85                	lui	s7,0x1
ffffffffc0201816:	4699                	li	a3,6
ffffffffc0201818:	100b8613          	addi	a2,s7,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020181c:	85d2                	mv	a1,s4
ffffffffc020181e:	ae5ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201822:	60051763          	bnez	a0,ffffffffc0201e30 <pmm_init+0xa5c>
ffffffffc0201826:	000a2703          	lw	a4,0(s4)
ffffffffc020182a:	4789                	li	a5,2
ffffffffc020182c:	4ef71663          	bne	a4,a5,ffffffffc0201d18 <pmm_init+0x944>
ffffffffc0201830:	00004597          	auipc	a1,0x4
ffffffffc0201834:	c4858593          	addi	a1,a1,-952 # ffffffffc0205478 <commands+0xff0>
ffffffffc0201838:	10000513          	li	a0,256
ffffffffc020183c:	5ca020ef          	jal	ra,ffffffffc0203e06 <strcpy>
ffffffffc0201840:	100b8593          	addi	a1,s7,256
ffffffffc0201844:	10000513          	li	a0,256
ffffffffc0201848:	5d0020ef          	jal	ra,ffffffffc0203e18 <strcmp>
ffffffffc020184c:	4a051663          	bnez	a0,ffffffffc0201cf8 <pmm_init+0x924>
ffffffffc0201850:	00093683          	ld	a3,0(s2)
ffffffffc0201854:	000abc83          	ld	s9,0(s5)
ffffffffc0201858:	00080c37          	lui	s8,0x80
ffffffffc020185c:	40da06b3          	sub	a3,s4,a3
ffffffffc0201860:	868d                	srai	a3,a3,0x3
ffffffffc0201862:	039686b3          	mul	a3,a3,s9
ffffffffc0201866:	5afd                	li	s5,-1
ffffffffc0201868:	609c                	ld	a5,0(s1)
ffffffffc020186a:	00cada93          	srli	s5,s5,0xc
ffffffffc020186e:	96e2                	add	a3,a3,s8
ffffffffc0201870:	0156f733          	and	a4,a3,s5
ffffffffc0201874:	06b2                	slli	a3,a3,0xc
ffffffffc0201876:	16f77363          	bgeu	a4,a5,ffffffffc02019dc <pmm_init+0x608>
ffffffffc020187a:	0009b783          	ld	a5,0(s3)
ffffffffc020187e:	10000513          	li	a0,256
ffffffffc0201882:	96be                	add	a3,a3,a5
ffffffffc0201884:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb60>
ffffffffc0201888:	53a020ef          	jal	ra,ffffffffc0203dc2 <strlen>
ffffffffc020188c:	44051663          	bnez	a0,ffffffffc0201cd8 <pmm_init+0x904>
ffffffffc0201890:	00043b83          	ld	s7,0(s0)
ffffffffc0201894:	6098                	ld	a4,0(s1)
ffffffffc0201896:	000bb783          	ld	a5,0(s7)
ffffffffc020189a:	078a                	slli	a5,a5,0x2
ffffffffc020189c:	83b1                	srli	a5,a5,0xc
ffffffffc020189e:	12e7fd63          	bgeu	a5,a4,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc02018a2:	418787b3          	sub	a5,a5,s8
ffffffffc02018a6:	00379693          	slli	a3,a5,0x3
ffffffffc02018aa:	96be                	add	a3,a3,a5
ffffffffc02018ac:	039686b3          	mul	a3,a3,s9
ffffffffc02018b0:	96e2                	add	a3,a3,s8
ffffffffc02018b2:	0156fab3          	and	s5,a3,s5
ffffffffc02018b6:	06b2                	slli	a3,a3,0xc
ffffffffc02018b8:	12eaf263          	bgeu	s5,a4,ffffffffc02019dc <pmm_init+0x608>
ffffffffc02018bc:	0009b983          	ld	s3,0(s3)
ffffffffc02018c0:	4585                	li	a1,1
ffffffffc02018c2:	8552                	mv	a0,s4
ffffffffc02018c4:	99b6                	add	s3,s3,a3
ffffffffc02018c6:	edeff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02018ca:	0009b783          	ld	a5,0(s3)
ffffffffc02018ce:	6098                	ld	a4,0(s1)
ffffffffc02018d0:	078a                	slli	a5,a5,0x2
ffffffffc02018d2:	83b1                	srli	a5,a5,0xc
ffffffffc02018d4:	10e7f263          	bgeu	a5,a4,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc02018d8:	fff809b7          	lui	s3,0xfff80
ffffffffc02018dc:	97ce                	add	a5,a5,s3
ffffffffc02018de:	00379513          	slli	a0,a5,0x3
ffffffffc02018e2:	00093703          	ld	a4,0(s2)
ffffffffc02018e6:	97aa                	add	a5,a5,a0
ffffffffc02018e8:	00379513          	slli	a0,a5,0x3
ffffffffc02018ec:	953a                	add	a0,a0,a4
ffffffffc02018ee:	4585                	li	a1,1
ffffffffc02018f0:	eb4ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02018f4:	000bb503          	ld	a0,0(s7)
ffffffffc02018f8:	609c                	ld	a5,0(s1)
ffffffffc02018fa:	050a                	slli	a0,a0,0x2
ffffffffc02018fc:	8131                	srli	a0,a0,0xc
ffffffffc02018fe:	0cf57d63          	bgeu	a0,a5,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc0201902:	013507b3          	add	a5,a0,s3
ffffffffc0201906:	00379513          	slli	a0,a5,0x3
ffffffffc020190a:	00093703          	ld	a4,0(s2)
ffffffffc020190e:	953e                	add	a0,a0,a5
ffffffffc0201910:	050e                	slli	a0,a0,0x3
ffffffffc0201912:	4585                	li	a1,1
ffffffffc0201914:	953a                	add	a0,a0,a4
ffffffffc0201916:	e8eff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020191a:	601c                	ld	a5,0(s0)
ffffffffc020191c:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
ffffffffc0201920:	ecaff0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0201924:	38ab1a63          	bne	s6,a0,ffffffffc0201cb8 <pmm_init+0x8e4>
ffffffffc0201928:	6446                	ld	s0,80(sp)
ffffffffc020192a:	60e6                	ld	ra,88(sp)
ffffffffc020192c:	64a6                	ld	s1,72(sp)
ffffffffc020192e:	6906                	ld	s2,64(sp)
ffffffffc0201930:	79e2                	ld	s3,56(sp)
ffffffffc0201932:	7a42                	ld	s4,48(sp)
ffffffffc0201934:	7aa2                	ld	s5,40(sp)
ffffffffc0201936:	7b02                	ld	s6,32(sp)
ffffffffc0201938:	6be2                	ld	s7,24(sp)
ffffffffc020193a:	6c42                	ld	s8,16(sp)
ffffffffc020193c:	6ca2                	ld	s9,8(sp)
ffffffffc020193e:	00004517          	auipc	a0,0x4
ffffffffc0201942:	bb250513          	addi	a0,a0,-1102 # ffffffffc02054f0 <commands+0x1068>
ffffffffc0201946:	6125                	addi	sp,sp,96
ffffffffc0201948:	f76fe06f          	j	ffffffffc02000be <cprintf>
ffffffffc020194c:	6705                	lui	a4,0x1
ffffffffc020194e:	177d                	addi	a4,a4,-1
ffffffffc0201950:	96ba                	add	a3,a3,a4
ffffffffc0201952:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201956:	08f77163          	bgeu	a4,a5,ffffffffc02019d8 <pmm_init+0x604>
ffffffffc020195a:	00043803          	ld	a6,0(s0)
ffffffffc020195e:	9732                	add	a4,a4,a2
ffffffffc0201960:	00371793          	slli	a5,a4,0x3
ffffffffc0201964:	767d                	lui	a2,0xfffff
ffffffffc0201966:	8ef1                	and	a3,a3,a2
ffffffffc0201968:	97ba                	add	a5,a5,a4
ffffffffc020196a:	01083703          	ld	a4,16(a6)
ffffffffc020196e:	8d95                	sub	a1,a1,a3
ffffffffc0201970:	078e                	slli	a5,a5,0x3
ffffffffc0201972:	81b1                	srli	a1,a1,0xc
ffffffffc0201974:	953e                	add	a0,a0,a5
ffffffffc0201976:	9702                	jalr	a4
ffffffffc0201978:	bead                	j	ffffffffc02014f2 <pmm_init+0x11e>
ffffffffc020197a:	6008                	ld	a0,0(s0)
ffffffffc020197c:	b5b5                	j	ffffffffc02017e8 <pmm_init+0x414>
ffffffffc020197e:	86d2                	mv	a3,s4
ffffffffc0201980:	00003617          	auipc	a2,0x3
ffffffffc0201984:	54060613          	addi	a2,a2,1344 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0201988:	1cd00593          	li	a1,461
ffffffffc020198c:	00003517          	auipc	a0,0x3
ffffffffc0201990:	55c50513          	addi	a0,a0,1372 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201994:	f70fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201998:	00004697          	auipc	a3,0x4
ffffffffc020199c:	9c868693          	addi	a3,a3,-1592 # ffffffffc0205360 <commands+0xed8>
ffffffffc02019a0:	00003617          	auipc	a2,0x3
ffffffffc02019a4:	35860613          	addi	a2,a2,856 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02019a8:	1cd00593          	li	a1,461
ffffffffc02019ac:	00003517          	auipc	a0,0x3
ffffffffc02019b0:	53c50513          	addi	a0,a0,1340 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc02019b4:	f50fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02019b8:	00004697          	auipc	a3,0x4
ffffffffc02019bc:	9e868693          	addi	a3,a3,-1560 # ffffffffc02053a0 <commands+0xf18>
ffffffffc02019c0:	00003617          	auipc	a2,0x3
ffffffffc02019c4:	33860613          	addi	a2,a2,824 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02019c8:	1ce00593          	li	a1,462
ffffffffc02019cc:	00003517          	auipc	a0,0x3
ffffffffc02019d0:	51c50513          	addi	a0,a0,1308 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc02019d4:	f30fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02019d8:	d28ff0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>
ffffffffc02019dc:	00003617          	auipc	a2,0x3
ffffffffc02019e0:	4e460613          	addi	a2,a2,1252 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc02019e4:	06a00593          	li	a1,106
ffffffffc02019e8:	00003517          	auipc	a0,0x3
ffffffffc02019ec:	57050513          	addi	a0,a0,1392 # ffffffffc0204f58 <commands+0xad0>
ffffffffc02019f0:	f14fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02019f4:	00003617          	auipc	a2,0x3
ffffffffc02019f8:	73c60613          	addi	a2,a2,1852 # ffffffffc0205130 <commands+0xca8>
ffffffffc02019fc:	07000593          	li	a1,112
ffffffffc0201a00:	00003517          	auipc	a0,0x3
ffffffffc0201a04:	55850513          	addi	a0,a0,1368 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0201a08:	efcfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201a0c:	00003697          	auipc	a3,0x3
ffffffffc0201a10:	66468693          	addi	a3,a3,1636 # ffffffffc0205070 <commands+0xbe8>
ffffffffc0201a14:	00003617          	auipc	a2,0x3
ffffffffc0201a18:	2e460613          	addi	a2,a2,740 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201a1c:	19300593          	li	a1,403
ffffffffc0201a20:	00003517          	auipc	a0,0x3
ffffffffc0201a24:	4c850513          	addi	a0,a0,1224 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201a28:	edcfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201a2c:	00003697          	auipc	a3,0x3
ffffffffc0201a30:	67c68693          	addi	a3,a3,1660 # ffffffffc02050a8 <commands+0xc20>
ffffffffc0201a34:	00003617          	auipc	a2,0x3
ffffffffc0201a38:	2c460613          	addi	a2,a2,708 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201a3c:	19400593          	li	a1,404
ffffffffc0201a40:	00003517          	auipc	a0,0x3
ffffffffc0201a44:	4a850513          	addi	a0,a0,1192 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201a48:	ebcfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201a4c:	00004697          	auipc	a3,0x4
ffffffffc0201a50:	8d468693          	addi	a3,a3,-1836 # ffffffffc0205320 <commands+0xe98>
ffffffffc0201a54:	00003617          	auipc	a2,0x3
ffffffffc0201a58:	2a460613          	addi	a2,a2,676 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201a5c:	1c000593          	li	a1,448
ffffffffc0201a60:	00003517          	auipc	a0,0x3
ffffffffc0201a64:	48850513          	addi	a0,a0,1160 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201a68:	e9cfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201a6c:	00003617          	auipc	a2,0x3
ffffffffc0201a70:	59c60613          	addi	a2,a2,1436 # ffffffffc0205008 <commands+0xb80>
ffffffffc0201a74:	07700593          	li	a1,119
ffffffffc0201a78:	00003517          	auipc	a0,0x3
ffffffffc0201a7c:	47050513          	addi	a0,a0,1136 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201a80:	e84fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201a84:	00003697          	auipc	a3,0x3
ffffffffc0201a88:	67c68693          	addi	a3,a3,1660 # ffffffffc0205100 <commands+0xc78>
ffffffffc0201a8c:	00003617          	auipc	a2,0x3
ffffffffc0201a90:	26c60613          	addi	a2,a2,620 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201a94:	19a00593          	li	a1,410
ffffffffc0201a98:	00003517          	auipc	a0,0x3
ffffffffc0201a9c:	45050513          	addi	a0,a0,1104 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201aa0:	e64fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201aa4:	00003697          	auipc	a3,0x3
ffffffffc0201aa8:	62c68693          	addi	a3,a3,1580 # ffffffffc02050d0 <commands+0xc48>
ffffffffc0201aac:	00003617          	auipc	a2,0x3
ffffffffc0201ab0:	24c60613          	addi	a2,a2,588 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ab4:	19800593          	li	a1,408
ffffffffc0201ab8:	00003517          	auipc	a0,0x3
ffffffffc0201abc:	43050513          	addi	a0,a0,1072 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201ac0:	e44fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201ac4:	00003697          	auipc	a3,0x3
ffffffffc0201ac8:	75468693          	addi	a3,a3,1876 # ffffffffc0205218 <commands+0xd90>
ffffffffc0201acc:	00003617          	auipc	a2,0x3
ffffffffc0201ad0:	22c60613          	addi	a2,a2,556 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ad4:	1a500593          	li	a1,421
ffffffffc0201ad8:	00003517          	auipc	a0,0x3
ffffffffc0201adc:	41050513          	addi	a0,a0,1040 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201ae0:	e24fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201ae4:	00003697          	auipc	a3,0x3
ffffffffc0201ae8:	70468693          	addi	a3,a3,1796 # ffffffffc02051e8 <commands+0xd60>
ffffffffc0201aec:	00003617          	auipc	a2,0x3
ffffffffc0201af0:	20c60613          	addi	a2,a2,524 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201af4:	1a400593          	li	a1,420
ffffffffc0201af8:	00003517          	auipc	a0,0x3
ffffffffc0201afc:	3f050513          	addi	a0,a0,1008 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b00:	e04fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b04:	00003697          	auipc	a3,0x3
ffffffffc0201b08:	6ac68693          	addi	a3,a3,1708 # ffffffffc02051b0 <commands+0xd28>
ffffffffc0201b0c:	00003617          	auipc	a2,0x3
ffffffffc0201b10:	1ec60613          	addi	a2,a2,492 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201b14:	1a300593          	li	a1,419
ffffffffc0201b18:	00003517          	auipc	a0,0x3
ffffffffc0201b1c:	3d050513          	addi	a0,a0,976 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b20:	de4fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b24:	00003697          	auipc	a3,0x3
ffffffffc0201b28:	66468693          	addi	a3,a3,1636 # ffffffffc0205188 <commands+0xd00>
ffffffffc0201b2c:	00003617          	auipc	a2,0x3
ffffffffc0201b30:	1cc60613          	addi	a2,a2,460 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201b34:	1a000593          	li	a1,416
ffffffffc0201b38:	00003517          	auipc	a0,0x3
ffffffffc0201b3c:	3b050513          	addi	a0,a0,944 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b40:	dc4fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b44:	86da                	mv	a3,s6
ffffffffc0201b46:	00003617          	auipc	a2,0x3
ffffffffc0201b4a:	37a60613          	addi	a2,a2,890 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0201b4e:	19f00593          	li	a1,415
ffffffffc0201b52:	00003517          	auipc	a0,0x3
ffffffffc0201b56:	39650513          	addi	a0,a0,918 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b5a:	daafe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b5e:	86be                	mv	a3,a5
ffffffffc0201b60:	00003617          	auipc	a2,0x3
ffffffffc0201b64:	36060613          	addi	a2,a2,864 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0201b68:	19e00593          	li	a1,414
ffffffffc0201b6c:	00003517          	auipc	a0,0x3
ffffffffc0201b70:	37c50513          	addi	a0,a0,892 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b74:	d90fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b78:	00003697          	auipc	a3,0x3
ffffffffc0201b7c:	5f868693          	addi	a3,a3,1528 # ffffffffc0205170 <commands+0xce8>
ffffffffc0201b80:	00003617          	auipc	a2,0x3
ffffffffc0201b84:	17860613          	addi	a2,a2,376 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201b88:	19c00593          	li	a1,412
ffffffffc0201b8c:	00003517          	auipc	a0,0x3
ffffffffc0201b90:	35c50513          	addi	a0,a0,860 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201b94:	d70fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201b98:	00003697          	auipc	a3,0x3
ffffffffc0201b9c:	5c068693          	addi	a3,a3,1472 # ffffffffc0205158 <commands+0xcd0>
ffffffffc0201ba0:	00003617          	auipc	a2,0x3
ffffffffc0201ba4:	15860613          	addi	a2,a2,344 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ba8:	19b00593          	li	a1,411
ffffffffc0201bac:	00003517          	auipc	a0,0x3
ffffffffc0201bb0:	33c50513          	addi	a0,a0,828 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201bb4:	d50fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201bb8:	00003697          	auipc	a3,0x3
ffffffffc0201bbc:	5a068693          	addi	a3,a3,1440 # ffffffffc0205158 <commands+0xcd0>
ffffffffc0201bc0:	00003617          	auipc	a2,0x3
ffffffffc0201bc4:	13860613          	addi	a2,a2,312 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201bc8:	1ae00593          	li	a1,430
ffffffffc0201bcc:	00003517          	auipc	a0,0x3
ffffffffc0201bd0:	31c50513          	addi	a0,a0,796 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201bd4:	d30fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201bd8:	00003697          	auipc	a3,0x3
ffffffffc0201bdc:	61068693          	addi	a3,a3,1552 # ffffffffc02051e8 <commands+0xd60>
ffffffffc0201be0:	00003617          	auipc	a2,0x3
ffffffffc0201be4:	11860613          	addi	a2,a2,280 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201be8:	1ad00593          	li	a1,429
ffffffffc0201bec:	00003517          	auipc	a0,0x3
ffffffffc0201bf0:	2fc50513          	addi	a0,a0,764 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201bf4:	d10fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201bf8:	00003697          	auipc	a3,0x3
ffffffffc0201bfc:	6b868693          	addi	a3,a3,1720 # ffffffffc02052b0 <commands+0xe28>
ffffffffc0201c00:	00003617          	auipc	a2,0x3
ffffffffc0201c04:	0f860613          	addi	a2,a2,248 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201c08:	1ac00593          	li	a1,428
ffffffffc0201c0c:	00003517          	auipc	a0,0x3
ffffffffc0201c10:	2dc50513          	addi	a0,a0,732 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201c14:	cf0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c18:	00003697          	auipc	a3,0x3
ffffffffc0201c1c:	68068693          	addi	a3,a3,1664 # ffffffffc0205298 <commands+0xe10>
ffffffffc0201c20:	00003617          	auipc	a2,0x3
ffffffffc0201c24:	0d860613          	addi	a2,a2,216 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201c28:	1ab00593          	li	a1,427
ffffffffc0201c2c:	00003517          	auipc	a0,0x3
ffffffffc0201c30:	2bc50513          	addi	a0,a0,700 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201c34:	cd0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c38:	00003697          	auipc	a3,0x3
ffffffffc0201c3c:	63068693          	addi	a3,a3,1584 # ffffffffc0205268 <commands+0xde0>
ffffffffc0201c40:	00003617          	auipc	a2,0x3
ffffffffc0201c44:	0b860613          	addi	a2,a2,184 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201c48:	1aa00593          	li	a1,426
ffffffffc0201c4c:	00003517          	auipc	a0,0x3
ffffffffc0201c50:	29c50513          	addi	a0,a0,668 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201c54:	cb0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c58:	00003697          	auipc	a3,0x3
ffffffffc0201c5c:	5f868693          	addi	a3,a3,1528 # ffffffffc0205250 <commands+0xdc8>
ffffffffc0201c60:	00003617          	auipc	a2,0x3
ffffffffc0201c64:	09860613          	addi	a2,a2,152 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201c68:	1a800593          	li	a1,424
ffffffffc0201c6c:	00003517          	auipc	a0,0x3
ffffffffc0201c70:	27c50513          	addi	a0,a0,636 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201c74:	c90fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c78:	00003697          	auipc	a3,0x3
ffffffffc0201c7c:	5c068693          	addi	a3,a3,1472 # ffffffffc0205238 <commands+0xdb0>
ffffffffc0201c80:	00003617          	auipc	a2,0x3
ffffffffc0201c84:	07860613          	addi	a2,a2,120 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201c88:	1a700593          	li	a1,423
ffffffffc0201c8c:	00003517          	auipc	a0,0x3
ffffffffc0201c90:	25c50513          	addi	a0,a0,604 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201c94:	c70fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201c98:	00003697          	auipc	a3,0x3
ffffffffc0201c9c:	59068693          	addi	a3,a3,1424 # ffffffffc0205228 <commands+0xda0>
ffffffffc0201ca0:	00003617          	auipc	a2,0x3
ffffffffc0201ca4:	05860613          	addi	a2,a2,88 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ca8:	1a600593          	li	a1,422
ffffffffc0201cac:	00003517          	auipc	a0,0x3
ffffffffc0201cb0:	23c50513          	addi	a0,a0,572 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201cb4:	c50fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201cb8:	00003697          	auipc	a3,0x3
ffffffffc0201cbc:	66868693          	addi	a3,a3,1640 # ffffffffc0205320 <commands+0xe98>
ffffffffc0201cc0:	00003617          	auipc	a2,0x3
ffffffffc0201cc4:	03860613          	addi	a2,a2,56 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201cc8:	1e800593          	li	a1,488
ffffffffc0201ccc:	00003517          	auipc	a0,0x3
ffffffffc0201cd0:	21c50513          	addi	a0,a0,540 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201cd4:	c30fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201cd8:	00003697          	auipc	a3,0x3
ffffffffc0201cdc:	7f068693          	addi	a3,a3,2032 # ffffffffc02054c8 <commands+0x1040>
ffffffffc0201ce0:	00003617          	auipc	a2,0x3
ffffffffc0201ce4:	01860613          	addi	a2,a2,24 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ce8:	1e000593          	li	a1,480
ffffffffc0201cec:	00003517          	auipc	a0,0x3
ffffffffc0201cf0:	1fc50513          	addi	a0,a0,508 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201cf4:	c10fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201cf8:	00003697          	auipc	a3,0x3
ffffffffc0201cfc:	79868693          	addi	a3,a3,1944 # ffffffffc0205490 <commands+0x1008>
ffffffffc0201d00:	00003617          	auipc	a2,0x3
ffffffffc0201d04:	ff860613          	addi	a2,a2,-8 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201d08:	1dd00593          	li	a1,477
ffffffffc0201d0c:	00003517          	auipc	a0,0x3
ffffffffc0201d10:	1dc50513          	addi	a0,a0,476 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201d14:	bf0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201d18:	00003697          	auipc	a3,0x3
ffffffffc0201d1c:	74868693          	addi	a3,a3,1864 # ffffffffc0205460 <commands+0xfd8>
ffffffffc0201d20:	00003617          	auipc	a2,0x3
ffffffffc0201d24:	fd860613          	addi	a2,a2,-40 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201d28:	1d900593          	li	a1,473
ffffffffc0201d2c:	00003517          	auipc	a0,0x3
ffffffffc0201d30:	1bc50513          	addi	a0,a0,444 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201d34:	bd0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201d38:	00003697          	auipc	a3,0x3
ffffffffc0201d3c:	5a868693          	addi	a3,a3,1448 # ffffffffc02052e0 <commands+0xe58>
ffffffffc0201d40:	00003617          	auipc	a2,0x3
ffffffffc0201d44:	fb860613          	addi	a2,a2,-72 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201d48:	1b600593          	li	a1,438
ffffffffc0201d4c:	00003517          	auipc	a0,0x3
ffffffffc0201d50:	19c50513          	addi	a0,a0,412 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201d54:	bb0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201d58:	00003697          	auipc	a3,0x3
ffffffffc0201d5c:	55868693          	addi	a3,a3,1368 # ffffffffc02052b0 <commands+0xe28>
ffffffffc0201d60:	00003617          	auipc	a2,0x3
ffffffffc0201d64:	f9860613          	addi	a2,a2,-104 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201d68:	1b300593          	li	a1,435
ffffffffc0201d6c:	00003517          	auipc	a0,0x3
ffffffffc0201d70:	17c50513          	addi	a0,a0,380 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201d74:	b90fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201d78:	00003697          	auipc	a3,0x3
ffffffffc0201d7c:	3f868693          	addi	a3,a3,1016 # ffffffffc0205170 <commands+0xce8>
ffffffffc0201d80:	00003617          	auipc	a2,0x3
ffffffffc0201d84:	f7860613          	addi	a2,a2,-136 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201d88:	1b200593          	li	a1,434
ffffffffc0201d8c:	00003517          	auipc	a0,0x3
ffffffffc0201d90:	15c50513          	addi	a0,a0,348 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201d94:	b70fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201d98:	00003697          	auipc	a3,0x3
ffffffffc0201d9c:	53068693          	addi	a3,a3,1328 # ffffffffc02052c8 <commands+0xe40>
ffffffffc0201da0:	00003617          	auipc	a2,0x3
ffffffffc0201da4:	f5860613          	addi	a2,a2,-168 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201da8:	1af00593          	li	a1,431
ffffffffc0201dac:	00003517          	auipc	a0,0x3
ffffffffc0201db0:	13c50513          	addi	a0,a0,316 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201db4:	b50fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201db8:	00003697          	auipc	a3,0x3
ffffffffc0201dbc:	54068693          	addi	a3,a3,1344 # ffffffffc02052f8 <commands+0xe70>
ffffffffc0201dc0:	00003617          	auipc	a2,0x3
ffffffffc0201dc4:	f3860613          	addi	a2,a2,-200 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201dc8:	1b900593          	li	a1,441
ffffffffc0201dcc:	00003517          	auipc	a0,0x3
ffffffffc0201dd0:	11c50513          	addi	a0,a0,284 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201dd4:	b30fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201dd8:	00003697          	auipc	a3,0x3
ffffffffc0201ddc:	4d868693          	addi	a3,a3,1240 # ffffffffc02052b0 <commands+0xe28>
ffffffffc0201de0:	00003617          	auipc	a2,0x3
ffffffffc0201de4:	f1860613          	addi	a2,a2,-232 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201de8:	1b700593          	li	a1,439
ffffffffc0201dec:	00003517          	auipc	a0,0x3
ffffffffc0201df0:	0fc50513          	addi	a0,a0,252 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201df4:	b10fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201df8:	00003697          	auipc	a3,0x3
ffffffffc0201dfc:	25868693          	addi	a3,a3,600 # ffffffffc0205050 <commands+0xbc8>
ffffffffc0201e00:	00003617          	auipc	a2,0x3
ffffffffc0201e04:	ef860613          	addi	a2,a2,-264 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201e08:	19200593          	li	a1,402
ffffffffc0201e0c:	00003517          	auipc	a0,0x3
ffffffffc0201e10:	0dc50513          	addi	a0,a0,220 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201e14:	af0fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201e18:	00003617          	auipc	a2,0x3
ffffffffc0201e1c:	1f060613          	addi	a2,a2,496 # ffffffffc0205008 <commands+0xb80>
ffffffffc0201e20:	0bd00593          	li	a1,189
ffffffffc0201e24:	00003517          	auipc	a0,0x3
ffffffffc0201e28:	0c450513          	addi	a0,a0,196 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201e2c:	ad8fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201e30:	00003697          	auipc	a3,0x3
ffffffffc0201e34:	5f068693          	addi	a3,a3,1520 # ffffffffc0205420 <commands+0xf98>
ffffffffc0201e38:	00003617          	auipc	a2,0x3
ffffffffc0201e3c:	ec060613          	addi	a2,a2,-320 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201e40:	1d800593          	li	a1,472
ffffffffc0201e44:	00003517          	auipc	a0,0x3
ffffffffc0201e48:	0a450513          	addi	a0,a0,164 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201e4c:	ab8fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201e50:	00003697          	auipc	a3,0x3
ffffffffc0201e54:	5b868693          	addi	a3,a3,1464 # ffffffffc0205408 <commands+0xf80>
ffffffffc0201e58:	00003617          	auipc	a2,0x3
ffffffffc0201e5c:	ea060613          	addi	a2,a2,-352 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201e60:	1d700593          	li	a1,471
ffffffffc0201e64:	00003517          	auipc	a0,0x3
ffffffffc0201e68:	08450513          	addi	a0,a0,132 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201e6c:	a98fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201e70:	00003697          	auipc	a3,0x3
ffffffffc0201e74:	56068693          	addi	a3,a3,1376 # ffffffffc02053d0 <commands+0xf48>
ffffffffc0201e78:	00003617          	auipc	a2,0x3
ffffffffc0201e7c:	e8060613          	addi	a2,a2,-384 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201e80:	1d600593          	li	a1,470
ffffffffc0201e84:	00003517          	auipc	a0,0x3
ffffffffc0201e88:	06450513          	addi	a0,a0,100 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201e8c:	a78fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201e90:	00003697          	auipc	a3,0x3
ffffffffc0201e94:	52868693          	addi	a3,a3,1320 # ffffffffc02053b8 <commands+0xf30>
ffffffffc0201e98:	00003617          	auipc	a2,0x3
ffffffffc0201e9c:	e6060613          	addi	a2,a2,-416 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ea0:	1d200593          	li	a1,466
ffffffffc0201ea4:	00003517          	auipc	a0,0x3
ffffffffc0201ea8:	04450513          	addi	a0,a0,68 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201eac:	a58fe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0201eb0 <tlb_invalidate>:
ffffffffc0201eb0:	12000073          	sfence.vma
ffffffffc0201eb4:	8082                	ret

ffffffffc0201eb6 <pgdir_alloc_page>:
ffffffffc0201eb6:	7179                	addi	sp,sp,-48
ffffffffc0201eb8:	e84a                	sd	s2,16(sp)
ffffffffc0201eba:	892a                	mv	s2,a0
ffffffffc0201ebc:	4505                	li	a0,1
ffffffffc0201ebe:	f022                	sd	s0,32(sp)
ffffffffc0201ec0:	ec26                	sd	s1,24(sp)
ffffffffc0201ec2:	e44e                	sd	s3,8(sp)
ffffffffc0201ec4:	f406                	sd	ra,40(sp)
ffffffffc0201ec6:	84ae                	mv	s1,a1
ffffffffc0201ec8:	89b2                	mv	s3,a2
ffffffffc0201eca:	852ff0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201ece:	842a                	mv	s0,a0
ffffffffc0201ed0:	cd19                	beqz	a0,ffffffffc0201eee <pgdir_alloc_page+0x38>
ffffffffc0201ed2:	85aa                	mv	a1,a0
ffffffffc0201ed4:	86ce                	mv	a3,s3
ffffffffc0201ed6:	8626                	mv	a2,s1
ffffffffc0201ed8:	854a                	mv	a0,s2
ffffffffc0201eda:	c28ff0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0201ede:	ed39                	bnez	a0,ffffffffc0201f3c <pgdir_alloc_page+0x86>
ffffffffc0201ee0:	0000f797          	auipc	a5,0xf
ffffffffc0201ee4:	59878793          	addi	a5,a5,1432 # ffffffffc0211478 <swap_init_ok>
ffffffffc0201ee8:	439c                	lw	a5,0(a5)
ffffffffc0201eea:	2781                	sext.w	a5,a5
ffffffffc0201eec:	eb89                	bnez	a5,ffffffffc0201efe <pgdir_alloc_page+0x48>
ffffffffc0201eee:	8522                	mv	a0,s0
ffffffffc0201ef0:	70a2                	ld	ra,40(sp)
ffffffffc0201ef2:	7402                	ld	s0,32(sp)
ffffffffc0201ef4:	64e2                	ld	s1,24(sp)
ffffffffc0201ef6:	6942                	ld	s2,16(sp)
ffffffffc0201ef8:	69a2                	ld	s3,8(sp)
ffffffffc0201efa:	6145                	addi	sp,sp,48
ffffffffc0201efc:	8082                	ret
ffffffffc0201efe:	0000f797          	auipc	a5,0xf
ffffffffc0201f02:	5ba78793          	addi	a5,a5,1466 # ffffffffc02114b8 <check_mm_struct>
ffffffffc0201f06:	6388                	ld	a0,0(a5)
ffffffffc0201f08:	4681                	li	a3,0
ffffffffc0201f0a:	8622                	mv	a2,s0
ffffffffc0201f0c:	85a6                	mv	a1,s1
ffffffffc0201f0e:	022010ef          	jal	ra,ffffffffc0202f30 <swap_map_swappable>
ffffffffc0201f12:	4018                	lw	a4,0(s0)
ffffffffc0201f14:	e024                	sd	s1,64(s0)
ffffffffc0201f16:	4785                	li	a5,1
ffffffffc0201f18:	fcf70be3          	beq	a4,a5,ffffffffc0201eee <pgdir_alloc_page+0x38>
ffffffffc0201f1c:	00003697          	auipc	a3,0x3
ffffffffc0201f20:	04c68693          	addi	a3,a3,76 # ffffffffc0204f68 <commands+0xae0>
ffffffffc0201f24:	00003617          	auipc	a2,0x3
ffffffffc0201f28:	dd460613          	addi	a2,a2,-556 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201f2c:	17a00593          	li	a1,378
ffffffffc0201f30:	00003517          	auipc	a0,0x3
ffffffffc0201f34:	fb850513          	addi	a0,a0,-72 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201f38:	9ccfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201f3c:	8522                	mv	a0,s0
ffffffffc0201f3e:	4585                	li	a1,1
ffffffffc0201f40:	864ff0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0201f44:	4401                	li	s0,0
ffffffffc0201f46:	b765                	j	ffffffffc0201eee <pgdir_alloc_page+0x38>

ffffffffc0201f48 <kmalloc>:
ffffffffc0201f48:	1141                	addi	sp,sp,-16
ffffffffc0201f4a:	67d5                	lui	a5,0x15
ffffffffc0201f4c:	e406                	sd	ra,8(sp)
ffffffffc0201f4e:	fff50713          	addi	a4,a0,-1
ffffffffc0201f52:	17f9                	addi	a5,a5,-2
ffffffffc0201f54:	04e7ee63          	bltu	a5,a4,ffffffffc0201fb0 <kmalloc+0x68>
ffffffffc0201f58:	6785                	lui	a5,0x1
ffffffffc0201f5a:	17fd                	addi	a5,a5,-1
ffffffffc0201f5c:	953e                	add	a0,a0,a5
ffffffffc0201f5e:	8131                	srli	a0,a0,0xc
ffffffffc0201f60:	fbdfe0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0201f64:	c159                	beqz	a0,ffffffffc0201fea <kmalloc+0xa2>
ffffffffc0201f66:	0000f797          	auipc	a5,0xf
ffffffffc0201f6a:	54a78793          	addi	a5,a5,1354 # ffffffffc02114b0 <pages>
ffffffffc0201f6e:	639c                	ld	a5,0(a5)
ffffffffc0201f70:	8d1d                	sub	a0,a0,a5
ffffffffc0201f72:	00003797          	auipc	a5,0x3
ffffffffc0201f76:	f4678793          	addi	a5,a5,-186 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0201f7a:	6394                	ld	a3,0(a5)
ffffffffc0201f7c:	850d                	srai	a0,a0,0x3
ffffffffc0201f7e:	0000f797          	auipc	a5,0xf
ffffffffc0201f82:	4e278793          	addi	a5,a5,1250 # ffffffffc0211460 <npage>
ffffffffc0201f86:	02d50533          	mul	a0,a0,a3
ffffffffc0201f8a:	6398                	ld	a4,0(a5)
ffffffffc0201f8c:	000806b7          	lui	a3,0x80
ffffffffc0201f90:	57fd                	li	a5,-1
ffffffffc0201f92:	83b1                	srli	a5,a5,0xc
ffffffffc0201f94:	9536                	add	a0,a0,a3
ffffffffc0201f96:	8fe9                	and	a5,a5,a0
ffffffffc0201f98:	0532                	slli	a0,a0,0xc
ffffffffc0201f9a:	02e7fb63          	bgeu	a5,a4,ffffffffc0201fd0 <kmalloc+0x88>
ffffffffc0201f9e:	0000f797          	auipc	a5,0xf
ffffffffc0201fa2:	50278793          	addi	a5,a5,1282 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0201fa6:	639c                	ld	a5,0(a5)
ffffffffc0201fa8:	60a2                	ld	ra,8(sp)
ffffffffc0201faa:	953e                	add	a0,a0,a5
ffffffffc0201fac:	0141                	addi	sp,sp,16
ffffffffc0201fae:	8082                	ret
ffffffffc0201fb0:	00003697          	auipc	a3,0x3
ffffffffc0201fb4:	f5868693          	addi	a3,a3,-168 # ffffffffc0204f08 <commands+0xa80>
ffffffffc0201fb8:	00003617          	auipc	a2,0x3
ffffffffc0201fbc:	d4060613          	addi	a2,a2,-704 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201fc0:	1f000593          	li	a1,496
ffffffffc0201fc4:	00003517          	auipc	a0,0x3
ffffffffc0201fc8:	f2450513          	addi	a0,a0,-220 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0201fcc:	938fe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201fd0:	86aa                	mv	a3,a0
ffffffffc0201fd2:	00003617          	auipc	a2,0x3
ffffffffc0201fd6:	eee60613          	addi	a2,a2,-274 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0201fda:	06a00593          	li	a1,106
ffffffffc0201fde:	00003517          	auipc	a0,0x3
ffffffffc0201fe2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0201fe6:	91efe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0201fea:	00003697          	auipc	a3,0x3
ffffffffc0201fee:	f3e68693          	addi	a3,a3,-194 # ffffffffc0204f28 <commands+0xaa0>
ffffffffc0201ff2:	00003617          	auipc	a2,0x3
ffffffffc0201ff6:	d0660613          	addi	a2,a2,-762 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0201ffa:	1f300593          	li	a1,499
ffffffffc0201ffe:	00003517          	auipc	a0,0x3
ffffffffc0202002:	eea50513          	addi	a0,a0,-278 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0202006:	8fefe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc020200a <kfree>:
ffffffffc020200a:	1141                	addi	sp,sp,-16
ffffffffc020200c:	67d5                	lui	a5,0x15
ffffffffc020200e:	e406                	sd	ra,8(sp)
ffffffffc0202010:	fff58713          	addi	a4,a1,-1
ffffffffc0202014:	17f9                	addi	a5,a5,-2
ffffffffc0202016:	04e7eb63          	bltu	a5,a4,ffffffffc020206c <kfree+0x62>
ffffffffc020201a:	c941                	beqz	a0,ffffffffc02020aa <kfree+0xa0>
ffffffffc020201c:	6785                	lui	a5,0x1
ffffffffc020201e:	17fd                	addi	a5,a5,-1
ffffffffc0202020:	95be                	add	a1,a1,a5
ffffffffc0202022:	c02007b7          	lui	a5,0xc0200
ffffffffc0202026:	81b1                	srli	a1,a1,0xc
ffffffffc0202028:	06f56463          	bltu	a0,a5,ffffffffc0202090 <kfree+0x86>
ffffffffc020202c:	0000f797          	auipc	a5,0xf
ffffffffc0202030:	47478793          	addi	a5,a5,1140 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0202034:	639c                	ld	a5,0(a5)
ffffffffc0202036:	0000f717          	auipc	a4,0xf
ffffffffc020203a:	42a70713          	addi	a4,a4,1066 # ffffffffc0211460 <npage>
ffffffffc020203e:	6318                	ld	a4,0(a4)
ffffffffc0202040:	40f507b3          	sub	a5,a0,a5
ffffffffc0202044:	83b1                	srli	a5,a5,0xc
ffffffffc0202046:	04e7f363          	bgeu	a5,a4,ffffffffc020208c <kfree+0x82>
ffffffffc020204a:	fff80537          	lui	a0,0xfff80
ffffffffc020204e:	97aa                	add	a5,a5,a0
ffffffffc0202050:	0000f697          	auipc	a3,0xf
ffffffffc0202054:	46068693          	addi	a3,a3,1120 # ffffffffc02114b0 <pages>
ffffffffc0202058:	6288                	ld	a0,0(a3)
ffffffffc020205a:	00379713          	slli	a4,a5,0x3
ffffffffc020205e:	60a2                	ld	ra,8(sp)
ffffffffc0202060:	97ba                	add	a5,a5,a4
ffffffffc0202062:	078e                	slli	a5,a5,0x3
ffffffffc0202064:	953e                	add	a0,a0,a5
ffffffffc0202066:	0141                	addi	sp,sp,16
ffffffffc0202068:	f3dfe06f          	j	ffffffffc0200fa4 <free_pages>
ffffffffc020206c:	00003697          	auipc	a3,0x3
ffffffffc0202070:	e9c68693          	addi	a3,a3,-356 # ffffffffc0204f08 <commands+0xa80>
ffffffffc0202074:	00003617          	auipc	a2,0x3
ffffffffc0202078:	c8460613          	addi	a2,a2,-892 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020207c:	1f900593          	li	a1,505
ffffffffc0202080:	00003517          	auipc	a0,0x3
ffffffffc0202084:	e6850513          	addi	a0,a0,-408 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc0202088:	87cfe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020208c:	e75fe0ef          	jal	ra,ffffffffc0200f00 <pa2page.part.4>
ffffffffc0202090:	86aa                	mv	a3,a0
ffffffffc0202092:	00003617          	auipc	a2,0x3
ffffffffc0202096:	f7660613          	addi	a2,a2,-138 # ffffffffc0205008 <commands+0xb80>
ffffffffc020209a:	06c00593          	li	a1,108
ffffffffc020209e:	00003517          	auipc	a0,0x3
ffffffffc02020a2:	eba50513          	addi	a0,a0,-326 # ffffffffc0204f58 <commands+0xad0>
ffffffffc02020a6:	85efe0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02020aa:	00003697          	auipc	a3,0x3
ffffffffc02020ae:	e4e68693          	addi	a3,a3,-434 # ffffffffc0204ef8 <commands+0xa70>
ffffffffc02020b2:	00003617          	auipc	a2,0x3
ffffffffc02020b6:	c4660613          	addi	a2,a2,-954 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02020ba:	1fa00593          	li	a1,506
ffffffffc02020be:	00003517          	auipc	a0,0x3
ffffffffc02020c2:	e2a50513          	addi	a0,a0,-470 # ffffffffc0204ee8 <commands+0xa60>
ffffffffc02020c6:	83efe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02020ca <check_vma_overlap.isra.0.part.1>:
ffffffffc02020ca:	1141                	addi	sp,sp,-16
ffffffffc02020cc:	00003697          	auipc	a3,0x3
ffffffffc02020d0:	44468693          	addi	a3,a3,1092 # ffffffffc0205510 <commands+0x1088>
ffffffffc02020d4:	00003617          	auipc	a2,0x3
ffffffffc02020d8:	c2460613          	addi	a2,a2,-988 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02020dc:	07d00593          	li	a1,125
ffffffffc02020e0:	00003517          	auipc	a0,0x3
ffffffffc02020e4:	45050513          	addi	a0,a0,1104 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02020e8:	e406                	sd	ra,8(sp)
ffffffffc02020ea:	81afe0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02020ee <mm_create>:
ffffffffc02020ee:	1141                	addi	sp,sp,-16
ffffffffc02020f0:	03000513          	li	a0,48
ffffffffc02020f4:	e022                	sd	s0,0(sp)
ffffffffc02020f6:	e406                	sd	ra,8(sp)
ffffffffc02020f8:	e51ff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc02020fc:	842a                	mv	s0,a0
ffffffffc02020fe:	c115                	beqz	a0,ffffffffc0202122 <mm_create+0x34>
ffffffffc0202100:	0000f797          	auipc	a5,0xf
ffffffffc0202104:	37878793          	addi	a5,a5,888 # ffffffffc0211478 <swap_init_ok>
ffffffffc0202108:	439c                	lw	a5,0(a5)
ffffffffc020210a:	e408                	sd	a0,8(s0)
ffffffffc020210c:	e008                	sd	a0,0(s0)
ffffffffc020210e:	00053823          	sd	zero,16(a0)
ffffffffc0202112:	00053c23          	sd	zero,24(a0)
ffffffffc0202116:	02052023          	sw	zero,32(a0)
ffffffffc020211a:	2781                	sext.w	a5,a5
ffffffffc020211c:	eb81                	bnez	a5,ffffffffc020212c <mm_create+0x3e>
ffffffffc020211e:	02053423          	sd	zero,40(a0)
ffffffffc0202122:	8522                	mv	a0,s0
ffffffffc0202124:	60a2                	ld	ra,8(sp)
ffffffffc0202126:	6402                	ld	s0,0(sp)
ffffffffc0202128:	0141                	addi	sp,sp,16
ffffffffc020212a:	8082                	ret
ffffffffc020212c:	5f7000ef          	jal	ra,ffffffffc0202f22 <swap_init_mm>
ffffffffc0202130:	8522                	mv	a0,s0
ffffffffc0202132:	60a2                	ld	ra,8(sp)
ffffffffc0202134:	6402                	ld	s0,0(sp)
ffffffffc0202136:	0141                	addi	sp,sp,16
ffffffffc0202138:	8082                	ret

ffffffffc020213a <vma_create>:
ffffffffc020213a:	1101                	addi	sp,sp,-32
ffffffffc020213c:	e04a                	sd	s2,0(sp)
ffffffffc020213e:	892a                	mv	s2,a0
ffffffffc0202140:	03000513          	li	a0,48
ffffffffc0202144:	e822                	sd	s0,16(sp)
ffffffffc0202146:	e426                	sd	s1,8(sp)
ffffffffc0202148:	ec06                	sd	ra,24(sp)
ffffffffc020214a:	84ae                	mv	s1,a1
ffffffffc020214c:	8432                	mv	s0,a2
ffffffffc020214e:	dfbff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc0202152:	c509                	beqz	a0,ffffffffc020215c <vma_create+0x22>
ffffffffc0202154:	01253423          	sd	s2,8(a0)
ffffffffc0202158:	e904                	sd	s1,16(a0)
ffffffffc020215a:	ed00                	sd	s0,24(a0)
ffffffffc020215c:	60e2                	ld	ra,24(sp)
ffffffffc020215e:	6442                	ld	s0,16(sp)
ffffffffc0202160:	64a2                	ld	s1,8(sp)
ffffffffc0202162:	6902                	ld	s2,0(sp)
ffffffffc0202164:	6105                	addi	sp,sp,32
ffffffffc0202166:	8082                	ret

ffffffffc0202168 <find_vma>:
ffffffffc0202168:	c51d                	beqz	a0,ffffffffc0202196 <find_vma+0x2e>
ffffffffc020216a:	691c                	ld	a5,16(a0)
ffffffffc020216c:	c781                	beqz	a5,ffffffffc0202174 <find_vma+0xc>
ffffffffc020216e:	6798                	ld	a4,8(a5)
ffffffffc0202170:	02e5f663          	bgeu	a1,a4,ffffffffc020219c <find_vma+0x34>
ffffffffc0202174:	87aa                	mv	a5,a0
ffffffffc0202176:	679c                	ld	a5,8(a5)
ffffffffc0202178:	00f50f63          	beq	a0,a5,ffffffffc0202196 <find_vma+0x2e>
ffffffffc020217c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202180:	fee5ebe3          	bltu	a1,a4,ffffffffc0202176 <find_vma+0xe>
ffffffffc0202184:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202188:	fee5f7e3          	bgeu	a1,a4,ffffffffc0202176 <find_vma+0xe>
ffffffffc020218c:	1781                	addi	a5,a5,-32
ffffffffc020218e:	c781                	beqz	a5,ffffffffc0202196 <find_vma+0x2e>
ffffffffc0202190:	e91c                	sd	a5,16(a0)
ffffffffc0202192:	853e                	mv	a0,a5
ffffffffc0202194:	8082                	ret
ffffffffc0202196:	4781                	li	a5,0
ffffffffc0202198:	853e                	mv	a0,a5
ffffffffc020219a:	8082                	ret
ffffffffc020219c:	6b98                	ld	a4,16(a5)
ffffffffc020219e:	fce5fbe3          	bgeu	a1,a4,ffffffffc0202174 <find_vma+0xc>
ffffffffc02021a2:	e91c                	sd	a5,16(a0)
ffffffffc02021a4:	b7fd                	j	ffffffffc0202192 <find_vma+0x2a>

ffffffffc02021a6 <insert_vma_struct>:
ffffffffc02021a6:	6590                	ld	a2,8(a1)
ffffffffc02021a8:	0105b803          	ld	a6,16(a1)
ffffffffc02021ac:	1141                	addi	sp,sp,-16
ffffffffc02021ae:	e406                	sd	ra,8(sp)
ffffffffc02021b0:	872a                	mv	a4,a0
ffffffffc02021b2:	01066863          	bltu	a2,a6,ffffffffc02021c2 <insert_vma_struct+0x1c>
ffffffffc02021b6:	a8b9                	j	ffffffffc0202214 <insert_vma_struct+0x6e>
ffffffffc02021b8:	fe87b683          	ld	a3,-24(a5)
ffffffffc02021bc:	04d66763          	bltu	a2,a3,ffffffffc020220a <insert_vma_struct+0x64>
ffffffffc02021c0:	873e                	mv	a4,a5
ffffffffc02021c2:	671c                	ld	a5,8(a4)
ffffffffc02021c4:	fef51ae3          	bne	a0,a5,ffffffffc02021b8 <insert_vma_struct+0x12>
ffffffffc02021c8:	02a70463          	beq	a4,a0,ffffffffc02021f0 <insert_vma_struct+0x4a>
ffffffffc02021cc:	ff073683          	ld	a3,-16(a4)
ffffffffc02021d0:	fe873883          	ld	a7,-24(a4)
ffffffffc02021d4:	08d8f063          	bgeu	a7,a3,ffffffffc0202254 <insert_vma_struct+0xae>
ffffffffc02021d8:	04d66e63          	bltu	a2,a3,ffffffffc0202234 <insert_vma_struct+0x8e>
ffffffffc02021dc:	00f50a63          	beq	a0,a5,ffffffffc02021f0 <insert_vma_struct+0x4a>
ffffffffc02021e0:	fe87b683          	ld	a3,-24(a5)
ffffffffc02021e4:	0506e863          	bltu	a3,a6,ffffffffc0202234 <insert_vma_struct+0x8e>
ffffffffc02021e8:	ff07b603          	ld	a2,-16(a5)
ffffffffc02021ec:	02c6f263          	bgeu	a3,a2,ffffffffc0202210 <insert_vma_struct+0x6a>
ffffffffc02021f0:	5114                	lw	a3,32(a0)
ffffffffc02021f2:	e188                	sd	a0,0(a1)
ffffffffc02021f4:	02058613          	addi	a2,a1,32
ffffffffc02021f8:	e390                	sd	a2,0(a5)
ffffffffc02021fa:	e710                	sd	a2,8(a4)
ffffffffc02021fc:	60a2                	ld	ra,8(sp)
ffffffffc02021fe:	f59c                	sd	a5,40(a1)
ffffffffc0202200:	f198                	sd	a4,32(a1)
ffffffffc0202202:	2685                	addiw	a3,a3,1
ffffffffc0202204:	d114                	sw	a3,32(a0)
ffffffffc0202206:	0141                	addi	sp,sp,16
ffffffffc0202208:	8082                	ret
ffffffffc020220a:	fca711e3          	bne	a4,a0,ffffffffc02021cc <insert_vma_struct+0x26>
ffffffffc020220e:	bfd9                	j	ffffffffc02021e4 <insert_vma_struct+0x3e>
ffffffffc0202210:	ebbff0ef          	jal	ra,ffffffffc02020ca <check_vma_overlap.isra.0.part.1>
ffffffffc0202214:	00003697          	auipc	a3,0x3
ffffffffc0202218:	3ac68693          	addi	a3,a3,940 # ffffffffc02055c0 <commands+0x1138>
ffffffffc020221c:	00003617          	auipc	a2,0x3
ffffffffc0202220:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202224:	08400593          	li	a1,132
ffffffffc0202228:	00003517          	auipc	a0,0x3
ffffffffc020222c:	30850513          	addi	a0,a0,776 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202230:	ed5fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0202234:	00003697          	auipc	a3,0x3
ffffffffc0202238:	3cc68693          	addi	a3,a3,972 # ffffffffc0205600 <commands+0x1178>
ffffffffc020223c:	00003617          	auipc	a2,0x3
ffffffffc0202240:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202244:	07c00593          	li	a1,124
ffffffffc0202248:	00003517          	auipc	a0,0x3
ffffffffc020224c:	2e850513          	addi	a0,a0,744 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202250:	eb5fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0202254:	00003697          	auipc	a3,0x3
ffffffffc0202258:	38c68693          	addi	a3,a3,908 # ffffffffc02055e0 <commands+0x1158>
ffffffffc020225c:	00003617          	auipc	a2,0x3
ffffffffc0202260:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202264:	07b00593          	li	a1,123
ffffffffc0202268:	00003517          	auipc	a0,0x3
ffffffffc020226c:	2c850513          	addi	a0,a0,712 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202270:	e95fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202274 <mm_destroy>:
ffffffffc0202274:	1141                	addi	sp,sp,-16
ffffffffc0202276:	e022                	sd	s0,0(sp)
ffffffffc0202278:	842a                	mv	s0,a0
ffffffffc020227a:	6508                	ld	a0,8(a0)
ffffffffc020227c:	e406                	sd	ra,8(sp)
ffffffffc020227e:	00a40e63          	beq	s0,a0,ffffffffc020229a <mm_destroy+0x26>
ffffffffc0202282:	6118                	ld	a4,0(a0)
ffffffffc0202284:	651c                	ld	a5,8(a0)
ffffffffc0202286:	03000593          	li	a1,48
ffffffffc020228a:	1501                	addi	a0,a0,-32
ffffffffc020228c:	e71c                	sd	a5,8(a4)
ffffffffc020228e:	e398                	sd	a4,0(a5)
ffffffffc0202290:	d7bff0ef          	jal	ra,ffffffffc020200a <kfree>
ffffffffc0202294:	6408                	ld	a0,8(s0)
ffffffffc0202296:	fea416e3          	bne	s0,a0,ffffffffc0202282 <mm_destroy+0xe>
ffffffffc020229a:	8522                	mv	a0,s0
ffffffffc020229c:	6402                	ld	s0,0(sp)
ffffffffc020229e:	60a2                	ld	ra,8(sp)
ffffffffc02022a0:	03000593          	li	a1,48
ffffffffc02022a4:	0141                	addi	sp,sp,16
ffffffffc02022a6:	b395                	j	ffffffffc020200a <kfree>

ffffffffc02022a8 <vmm_init>:
ffffffffc02022a8:	715d                	addi	sp,sp,-80
ffffffffc02022aa:	e486                	sd	ra,72(sp)
ffffffffc02022ac:	e0a2                	sd	s0,64(sp)
ffffffffc02022ae:	fc26                	sd	s1,56(sp)
ffffffffc02022b0:	f84a                	sd	s2,48(sp)
ffffffffc02022b2:	f052                	sd	s4,32(sp)
ffffffffc02022b4:	f44e                	sd	s3,40(sp)
ffffffffc02022b6:	ec56                	sd	s5,24(sp)
ffffffffc02022b8:	e85a                	sd	s6,16(sp)
ffffffffc02022ba:	e45e                	sd	s7,8(sp)
ffffffffc02022bc:	d2ffe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc02022c0:	892a                	mv	s2,a0
ffffffffc02022c2:	d29fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc02022c6:	8a2a                	mv	s4,a0
ffffffffc02022c8:	e27ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
ffffffffc02022cc:	842a                	mv	s0,a0
ffffffffc02022ce:	03200493          	li	s1,50
ffffffffc02022d2:	e919                	bnez	a0,ffffffffc02022e8 <vmm_init+0x40>
ffffffffc02022d4:	aeed                	j	ffffffffc02026ce <vmm_init+0x426>
ffffffffc02022d6:	e504                	sd	s1,8(a0)
ffffffffc02022d8:	e91c                	sd	a5,16(a0)
ffffffffc02022da:	00053c23          	sd	zero,24(a0)
ffffffffc02022de:	14ed                	addi	s1,s1,-5
ffffffffc02022e0:	8522                	mv	a0,s0
ffffffffc02022e2:	ec5ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
ffffffffc02022e6:	c88d                	beqz	s1,ffffffffc0202318 <vmm_init+0x70>
ffffffffc02022e8:	03000513          	li	a0,48
ffffffffc02022ec:	c5dff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc02022f0:	85aa                	mv	a1,a0
ffffffffc02022f2:	00248793          	addi	a5,s1,2
ffffffffc02022f6:	f165                	bnez	a0,ffffffffc02022d6 <vmm_init+0x2e>
ffffffffc02022f8:	00003697          	auipc	a3,0x3
ffffffffc02022fc:	55068693          	addi	a3,a3,1360 # ffffffffc0205848 <commands+0x13c0>
ffffffffc0202300:	00003617          	auipc	a2,0x3
ffffffffc0202304:	9f860613          	addi	a2,a2,-1544 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202308:	0ce00593          	li	a1,206
ffffffffc020230c:	00003517          	auipc	a0,0x3
ffffffffc0202310:	22450513          	addi	a0,a0,548 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202314:	df1fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0202318:	03700493          	li	s1,55
ffffffffc020231c:	1f900993          	li	s3,505
ffffffffc0202320:	a819                	j	ffffffffc0202336 <vmm_init+0x8e>
ffffffffc0202322:	e504                	sd	s1,8(a0)
ffffffffc0202324:	e91c                	sd	a5,16(a0)
ffffffffc0202326:	00053c23          	sd	zero,24(a0)
ffffffffc020232a:	0495                	addi	s1,s1,5
ffffffffc020232c:	8522                	mv	a0,s0
ffffffffc020232e:	e79ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
ffffffffc0202332:	03348a63          	beq	s1,s3,ffffffffc0202366 <vmm_init+0xbe>
ffffffffc0202336:	03000513          	li	a0,48
ffffffffc020233a:	c0fff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc020233e:	85aa                	mv	a1,a0
ffffffffc0202340:	00248793          	addi	a5,s1,2
ffffffffc0202344:	fd79                	bnez	a0,ffffffffc0202322 <vmm_init+0x7a>
ffffffffc0202346:	00003697          	auipc	a3,0x3
ffffffffc020234a:	50268693          	addi	a3,a3,1282 # ffffffffc0205848 <commands+0x13c0>
ffffffffc020234e:	00003617          	auipc	a2,0x3
ffffffffc0202352:	9aa60613          	addi	a2,a2,-1622 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202356:	0d400593          	li	a1,212
ffffffffc020235a:	00003517          	auipc	a0,0x3
ffffffffc020235e:	1d650513          	addi	a0,a0,470 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202362:	da3fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0202366:	6418                	ld	a4,8(s0)
ffffffffc0202368:	479d                	li	a5,7
ffffffffc020236a:	1fb00593          	li	a1,507
ffffffffc020236e:	2ae40063          	beq	s0,a4,ffffffffc020260e <vmm_init+0x366>
ffffffffc0202372:	fe873603          	ld	a2,-24(a4)
ffffffffc0202376:	ffe78693          	addi	a3,a5,-2
ffffffffc020237a:	20d61a63          	bne	a2,a3,ffffffffc020258e <vmm_init+0x2e6>
ffffffffc020237e:	ff073683          	ld	a3,-16(a4)
ffffffffc0202382:	20d79663          	bne	a5,a3,ffffffffc020258e <vmm_init+0x2e6>
ffffffffc0202386:	0795                	addi	a5,a5,5
ffffffffc0202388:	6718                	ld	a4,8(a4)
ffffffffc020238a:	feb792e3          	bne	a5,a1,ffffffffc020236e <vmm_init+0xc6>
ffffffffc020238e:	499d                	li	s3,7
ffffffffc0202390:	4495                	li	s1,5
ffffffffc0202392:	1f900b93          	li	s7,505
ffffffffc0202396:	85a6                	mv	a1,s1
ffffffffc0202398:	8522                	mv	a0,s0
ffffffffc020239a:	dcfff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc020239e:	8b2a                	mv	s6,a0
ffffffffc02023a0:	2e050763          	beqz	a0,ffffffffc020268e <vmm_init+0x3e6>
ffffffffc02023a4:	00148593          	addi	a1,s1,1
ffffffffc02023a8:	8522                	mv	a0,s0
ffffffffc02023aa:	dbfff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023ae:	8aaa                	mv	s5,a0
ffffffffc02023b0:	2a050f63          	beqz	a0,ffffffffc020266e <vmm_init+0x3c6>
ffffffffc02023b4:	85ce                	mv	a1,s3
ffffffffc02023b6:	8522                	mv	a0,s0
ffffffffc02023b8:	db1ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023bc:	28051963          	bnez	a0,ffffffffc020264e <vmm_init+0x3a6>
ffffffffc02023c0:	00348593          	addi	a1,s1,3
ffffffffc02023c4:	8522                	mv	a0,s0
ffffffffc02023c6:	da3ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023ca:	26051263          	bnez	a0,ffffffffc020262e <vmm_init+0x386>
ffffffffc02023ce:	00448593          	addi	a1,s1,4
ffffffffc02023d2:	8522                	mv	a0,s0
ffffffffc02023d4:	d95ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02023d8:	2c051b63          	bnez	a0,ffffffffc02026ae <vmm_init+0x406>
ffffffffc02023dc:	008b3783          	ld	a5,8(s6)
ffffffffc02023e0:	1c979763          	bne	a5,s1,ffffffffc02025ae <vmm_init+0x306>
ffffffffc02023e4:	010b3783          	ld	a5,16(s6)
ffffffffc02023e8:	1d379363          	bne	a5,s3,ffffffffc02025ae <vmm_init+0x306>
ffffffffc02023ec:	008ab783          	ld	a5,8(s5)
ffffffffc02023f0:	1c979f63          	bne	a5,s1,ffffffffc02025ce <vmm_init+0x326>
ffffffffc02023f4:	010ab783          	ld	a5,16(s5)
ffffffffc02023f8:	1d379b63          	bne	a5,s3,ffffffffc02025ce <vmm_init+0x326>
ffffffffc02023fc:	0495                	addi	s1,s1,5
ffffffffc02023fe:	0995                	addi	s3,s3,5
ffffffffc0202400:	f9749be3          	bne	s1,s7,ffffffffc0202396 <vmm_init+0xee>
ffffffffc0202404:	4491                	li	s1,4
ffffffffc0202406:	59fd                	li	s3,-1
ffffffffc0202408:	85a6                	mv	a1,s1
ffffffffc020240a:	8522                	mv	a0,s0
ffffffffc020240c:	d5dff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc0202410:	0004859b          	sext.w	a1,s1
ffffffffc0202414:	c90d                	beqz	a0,ffffffffc0202446 <vmm_init+0x19e>
ffffffffc0202416:	6914                	ld	a3,16(a0)
ffffffffc0202418:	6510                	ld	a2,8(a0)
ffffffffc020241a:	00003517          	auipc	a0,0x3
ffffffffc020241e:	31650513          	addi	a0,a0,790 # ffffffffc0205730 <commands+0x12a8>
ffffffffc0202422:	c9dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202426:	00003697          	auipc	a3,0x3
ffffffffc020242a:	33268693          	addi	a3,a3,818 # ffffffffc0205758 <commands+0x12d0>
ffffffffc020242e:	00003617          	auipc	a2,0x3
ffffffffc0202432:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202436:	0f600593          	li	a1,246
ffffffffc020243a:	00003517          	auipc	a0,0x3
ffffffffc020243e:	0f650513          	addi	a0,a0,246 # ffffffffc0205530 <commands+0x10a8>
ffffffffc0202442:	cc3fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0202446:	14fd                	addi	s1,s1,-1
ffffffffc0202448:	fd3490e3          	bne	s1,s3,ffffffffc0202408 <vmm_init+0x160>
ffffffffc020244c:	8522                	mv	a0,s0
ffffffffc020244e:	e27ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>
ffffffffc0202452:	b99fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202456:	28aa1c63          	bne	s4,a0,ffffffffc02026ee <vmm_init+0x446>
ffffffffc020245a:	00003517          	auipc	a0,0x3
ffffffffc020245e:	33e50513          	addi	a0,a0,830 # ffffffffc0205798 <commands+0x1310>
ffffffffc0202462:	c5dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202466:	b85fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc020246a:	89aa                	mv	s3,a0
ffffffffc020246c:	c83ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
ffffffffc0202470:	0000f797          	auipc	a5,0xf
ffffffffc0202474:	04a7b423          	sd	a0,72(a5) # ffffffffc02114b8 <check_mm_struct>
ffffffffc0202478:	842a                	mv	s0,a0
ffffffffc020247a:	2a050a63          	beqz	a0,ffffffffc020272e <vmm_init+0x486>
ffffffffc020247e:	0000f797          	auipc	a5,0xf
ffffffffc0202482:	fda78793          	addi	a5,a5,-38 # ffffffffc0211458 <boot_pgdir>
ffffffffc0202486:	6384                	ld	s1,0(a5)
ffffffffc0202488:	609c                	ld	a5,0(s1)
ffffffffc020248a:	ed04                	sd	s1,24(a0)
ffffffffc020248c:	32079d63          	bnez	a5,ffffffffc02027c6 <vmm_init+0x51e>
ffffffffc0202490:	03000513          	li	a0,48
ffffffffc0202494:	ab5ff0ef          	jal	ra,ffffffffc0201f48 <kmalloc>
ffffffffc0202498:	8a2a                	mv	s4,a0
ffffffffc020249a:	14050a63          	beqz	a0,ffffffffc02025ee <vmm_init+0x346>
ffffffffc020249e:	002007b7          	lui	a5,0x200
ffffffffc02024a2:	00fa3823          	sd	a5,16(s4)
ffffffffc02024a6:	4789                	li	a5,2
ffffffffc02024a8:	85aa                	mv	a1,a0
ffffffffc02024aa:	00fa3c23          	sd	a5,24(s4)
ffffffffc02024ae:	8522                	mv	a0,s0
ffffffffc02024b0:	000a3423          	sd	zero,8(s4)
ffffffffc02024b4:	cf3ff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>
ffffffffc02024b8:	10000593          	li	a1,256
ffffffffc02024bc:	8522                	mv	a0,s0
ffffffffc02024be:	cabff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02024c2:	10000793          	li	a5,256
ffffffffc02024c6:	16400713          	li	a4,356
ffffffffc02024ca:	2aaa1263          	bne	s4,a0,ffffffffc020276e <vmm_init+0x4c6>
ffffffffc02024ce:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
ffffffffc02024d2:	0785                	addi	a5,a5,1
ffffffffc02024d4:	fee79de3          	bne	a5,a4,ffffffffc02024ce <vmm_init+0x226>
ffffffffc02024d8:	6705                	lui	a4,0x1
ffffffffc02024da:	10000793          	li	a5,256
ffffffffc02024de:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc02024e2:	16400613          	li	a2,356
ffffffffc02024e6:	0007c683          	lbu	a3,0(a5)
ffffffffc02024ea:	0785                	addi	a5,a5,1
ffffffffc02024ec:	9f15                	subw	a4,a4,a3
ffffffffc02024ee:	fec79ce3          	bne	a5,a2,ffffffffc02024e6 <vmm_init+0x23e>
ffffffffc02024f2:	2a071a63          	bnez	a4,ffffffffc02027a6 <vmm_init+0x4fe>
ffffffffc02024f6:	4581                	li	a1,0
ffffffffc02024f8:	8526                	mv	a0,s1
ffffffffc02024fa:	d97fe0ef          	jal	ra,ffffffffc0201290 <page_remove>
ffffffffc02024fe:	609c                	ld	a5,0(s1)
ffffffffc0202500:	0000f717          	auipc	a4,0xf
ffffffffc0202504:	f6070713          	addi	a4,a4,-160 # ffffffffc0211460 <npage>
ffffffffc0202508:	6318                	ld	a4,0(a4)
ffffffffc020250a:	078a                	slli	a5,a5,0x2
ffffffffc020250c:	83b1                	srli	a5,a5,0xc
ffffffffc020250e:	28e7f063          	bgeu	a5,a4,ffffffffc020278e <vmm_init+0x4e6>
ffffffffc0202512:	00004717          	auipc	a4,0x4
ffffffffc0202516:	d1e70713          	addi	a4,a4,-738 # ffffffffc0206230 <nbase>
ffffffffc020251a:	6318                	ld	a4,0(a4)
ffffffffc020251c:	0000f697          	auipc	a3,0xf
ffffffffc0202520:	f9468693          	addi	a3,a3,-108 # ffffffffc02114b0 <pages>
ffffffffc0202524:	6288                	ld	a0,0(a3)
ffffffffc0202526:	8f99                	sub	a5,a5,a4
ffffffffc0202528:	00379713          	slli	a4,a5,0x3
ffffffffc020252c:	97ba                	add	a5,a5,a4
ffffffffc020252e:	078e                	slli	a5,a5,0x3
ffffffffc0202530:	953e                	add	a0,a0,a5
ffffffffc0202532:	4585                	li	a1,1
ffffffffc0202534:	a71fe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0202538:	0004b023          	sd	zero,0(s1)
ffffffffc020253c:	8522                	mv	a0,s0
ffffffffc020253e:	00043c23          	sd	zero,24(s0)
ffffffffc0202542:	d33ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>
ffffffffc0202546:	19fd                	addi	s3,s3,-1
ffffffffc0202548:	0000f797          	auipc	a5,0xf
ffffffffc020254c:	f607b823          	sd	zero,-144(a5) # ffffffffc02114b8 <check_mm_struct>
ffffffffc0202550:	a9bfe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202554:	1aa99d63          	bne	s3,a0,ffffffffc020270e <vmm_init+0x466>
ffffffffc0202558:	00003517          	auipc	a0,0x3
ffffffffc020255c:	2b850513          	addi	a0,a0,696 # ffffffffc0205810 <commands+0x1388>
ffffffffc0202560:	b5ffd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202564:	a87fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202568:	197d                	addi	s2,s2,-1
ffffffffc020256a:	1ea91263          	bne	s2,a0,ffffffffc020274e <vmm_init+0x4a6>
ffffffffc020256e:	6406                	ld	s0,64(sp)
ffffffffc0202570:	60a6                	ld	ra,72(sp)
ffffffffc0202572:	74e2                	ld	s1,56(sp)
ffffffffc0202574:	7942                	ld	s2,48(sp)
ffffffffc0202576:	79a2                	ld	s3,40(sp)
ffffffffc0202578:	7a02                	ld	s4,32(sp)
ffffffffc020257a:	6ae2                	ld	s5,24(sp)
ffffffffc020257c:	6b42                	ld	s6,16(sp)
ffffffffc020257e:	6ba2                	ld	s7,8(sp)
ffffffffc0202580:	00003517          	auipc	a0,0x3
ffffffffc0202584:	2b050513          	addi	a0,a0,688 # ffffffffc0205830 <commands+0x13a8>
ffffffffc0202588:	6161                	addi	sp,sp,80
ffffffffc020258a:	b35fd06f          	j	ffffffffc02000be <cprintf>
ffffffffc020258e:	00003697          	auipc	a3,0x3
ffffffffc0202592:	0ba68693          	addi	a3,a3,186 # ffffffffc0205648 <commands+0x11c0>
ffffffffc0202596:	00002617          	auipc	a2,0x2
ffffffffc020259a:	76260613          	addi	a2,a2,1890 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020259e:	0dd00593          	li	a1,221
ffffffffc02025a2:	00003517          	auipc	a0,0x3
ffffffffc02025a6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02025aa:	b5bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02025ae:	00003697          	auipc	a3,0x3
ffffffffc02025b2:	12268693          	addi	a3,a3,290 # ffffffffc02056d0 <commands+0x1248>
ffffffffc02025b6:	00002617          	auipc	a2,0x2
ffffffffc02025ba:	74260613          	addi	a2,a2,1858 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02025be:	0ed00593          	li	a1,237
ffffffffc02025c2:	00003517          	auipc	a0,0x3
ffffffffc02025c6:	f6e50513          	addi	a0,a0,-146 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02025ca:	b3bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02025ce:	00003697          	auipc	a3,0x3
ffffffffc02025d2:	13268693          	addi	a3,a3,306 # ffffffffc0205700 <commands+0x1278>
ffffffffc02025d6:	00002617          	auipc	a2,0x2
ffffffffc02025da:	72260613          	addi	a2,a2,1826 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02025de:	0ee00593          	li	a1,238
ffffffffc02025e2:	00003517          	auipc	a0,0x3
ffffffffc02025e6:	f4e50513          	addi	a0,a0,-178 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02025ea:	b1bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02025ee:	00003697          	auipc	a3,0x3
ffffffffc02025f2:	25a68693          	addi	a3,a3,602 # ffffffffc0205848 <commands+0x13c0>
ffffffffc02025f6:	00002617          	auipc	a2,0x2
ffffffffc02025fa:	70260613          	addi	a2,a2,1794 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02025fe:	11100593          	li	a1,273
ffffffffc0202602:	00003517          	auipc	a0,0x3
ffffffffc0202606:	f2e50513          	addi	a0,a0,-210 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020260a:	afbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020260e:	00003697          	auipc	a3,0x3
ffffffffc0202612:	02268693          	addi	a3,a3,34 # ffffffffc0205630 <commands+0x11a8>
ffffffffc0202616:	00002617          	auipc	a2,0x2
ffffffffc020261a:	6e260613          	addi	a2,a2,1762 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020261e:	0db00593          	li	a1,219
ffffffffc0202622:	00003517          	auipc	a0,0x3
ffffffffc0202626:	f0e50513          	addi	a0,a0,-242 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020262a:	adbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020262e:	00003697          	auipc	a3,0x3
ffffffffc0202632:	08268693          	addi	a3,a3,130 # ffffffffc02056b0 <commands+0x1228>
ffffffffc0202636:	00002617          	auipc	a2,0x2
ffffffffc020263a:	6c260613          	addi	a2,a2,1730 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020263e:	0e900593          	li	a1,233
ffffffffc0202642:	00003517          	auipc	a0,0x3
ffffffffc0202646:	eee50513          	addi	a0,a0,-274 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020264a:	abbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020264e:	00003697          	auipc	a3,0x3
ffffffffc0202652:	05268693          	addi	a3,a3,82 # ffffffffc02056a0 <commands+0x1218>
ffffffffc0202656:	00002617          	auipc	a2,0x2
ffffffffc020265a:	6a260613          	addi	a2,a2,1698 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020265e:	0e700593          	li	a1,231
ffffffffc0202662:	00003517          	auipc	a0,0x3
ffffffffc0202666:	ece50513          	addi	a0,a0,-306 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020266a:	a9bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020266e:	00003697          	auipc	a3,0x3
ffffffffc0202672:	02268693          	addi	a3,a3,34 # ffffffffc0205690 <commands+0x1208>
ffffffffc0202676:	00002617          	auipc	a2,0x2
ffffffffc020267a:	68260613          	addi	a2,a2,1666 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020267e:	0e500593          	li	a1,229
ffffffffc0202682:	00003517          	auipc	a0,0x3
ffffffffc0202686:	eae50513          	addi	a0,a0,-338 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020268a:	a7bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020268e:	00003697          	auipc	a3,0x3
ffffffffc0202692:	ff268693          	addi	a3,a3,-14 # ffffffffc0205680 <commands+0x11f8>
ffffffffc0202696:	00002617          	auipc	a2,0x2
ffffffffc020269a:	66260613          	addi	a2,a2,1634 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020269e:	0e300593          	li	a1,227
ffffffffc02026a2:	00003517          	auipc	a0,0x3
ffffffffc02026a6:	e8e50513          	addi	a0,a0,-370 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02026aa:	a5bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02026ae:	00003697          	auipc	a3,0x3
ffffffffc02026b2:	01268693          	addi	a3,a3,18 # ffffffffc02056c0 <commands+0x1238>
ffffffffc02026b6:	00002617          	auipc	a2,0x2
ffffffffc02026ba:	64260613          	addi	a2,a2,1602 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02026be:	0eb00593          	li	a1,235
ffffffffc02026c2:	00003517          	auipc	a0,0x3
ffffffffc02026c6:	e6e50513          	addi	a0,a0,-402 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02026ca:	a3bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02026ce:	00003697          	auipc	a3,0x3
ffffffffc02026d2:	f5268693          	addi	a3,a3,-174 # ffffffffc0205620 <commands+0x1198>
ffffffffc02026d6:	00002617          	auipc	a2,0x2
ffffffffc02026da:	62260613          	addi	a2,a2,1570 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02026de:	0c700593          	li	a1,199
ffffffffc02026e2:	00003517          	auipc	a0,0x3
ffffffffc02026e6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02026ea:	a1bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02026ee:	00003697          	auipc	a3,0x3
ffffffffc02026f2:	08268693          	addi	a3,a3,130 # ffffffffc0205770 <commands+0x12e8>
ffffffffc02026f6:	00002617          	auipc	a2,0x2
ffffffffc02026fa:	60260613          	addi	a2,a2,1538 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02026fe:	0fb00593          	li	a1,251
ffffffffc0202702:	00003517          	auipc	a0,0x3
ffffffffc0202706:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020270a:	9fbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020270e:	00003697          	auipc	a3,0x3
ffffffffc0202712:	06268693          	addi	a3,a3,98 # ffffffffc0205770 <commands+0x12e8>
ffffffffc0202716:	00002617          	auipc	a2,0x2
ffffffffc020271a:	5e260613          	addi	a2,a2,1506 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020271e:	12e00593          	li	a1,302
ffffffffc0202722:	00003517          	auipc	a0,0x3
ffffffffc0202726:	e0e50513          	addi	a0,a0,-498 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020272a:	9dbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020272e:	00003697          	auipc	a3,0x3
ffffffffc0202732:	08a68693          	addi	a3,a3,138 # ffffffffc02057b8 <commands+0x1330>
ffffffffc0202736:	00002617          	auipc	a2,0x2
ffffffffc020273a:	5c260613          	addi	a2,a2,1474 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020273e:	10a00593          	li	a1,266
ffffffffc0202742:	00003517          	auipc	a0,0x3
ffffffffc0202746:	dee50513          	addi	a0,a0,-530 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020274a:	9bbfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020274e:	00003697          	auipc	a3,0x3
ffffffffc0202752:	02268693          	addi	a3,a3,34 # ffffffffc0205770 <commands+0x12e8>
ffffffffc0202756:	00002617          	auipc	a2,0x2
ffffffffc020275a:	5a260613          	addi	a2,a2,1442 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020275e:	0bd00593          	li	a1,189
ffffffffc0202762:	00003517          	auipc	a0,0x3
ffffffffc0202766:	dce50513          	addi	a0,a0,-562 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020276a:	99bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020276e:	00003697          	auipc	a3,0x3
ffffffffc0202772:	07268693          	addi	a3,a3,114 # ffffffffc02057e0 <commands+0x1358>
ffffffffc0202776:	00002617          	auipc	a2,0x2
ffffffffc020277a:	58260613          	addi	a2,a2,1410 # ffffffffc0204cf8 <commands+0x870>
ffffffffc020277e:	11600593          	li	a1,278
ffffffffc0202782:	00003517          	auipc	a0,0x3
ffffffffc0202786:	dae50513          	addi	a0,a0,-594 # ffffffffc0205530 <commands+0x10a8>
ffffffffc020278a:	97bfd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc020278e:	00002617          	auipc	a2,0x2
ffffffffc0202792:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204f38 <commands+0xab0>
ffffffffc0202796:	06500593          	li	a1,101
ffffffffc020279a:	00002517          	auipc	a0,0x2
ffffffffc020279e:	7be50513          	addi	a0,a0,1982 # ffffffffc0204f58 <commands+0xad0>
ffffffffc02027a2:	963fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02027a6:	00003697          	auipc	a3,0x3
ffffffffc02027aa:	05a68693          	addi	a3,a3,90 # ffffffffc0205800 <commands+0x1378>
ffffffffc02027ae:	00002617          	auipc	a2,0x2
ffffffffc02027b2:	54a60613          	addi	a2,a2,1354 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02027b6:	12000593          	li	a1,288
ffffffffc02027ba:	00003517          	auipc	a0,0x3
ffffffffc02027be:	d7650513          	addi	a0,a0,-650 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02027c2:	943fd0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02027c6:	00003697          	auipc	a3,0x3
ffffffffc02027ca:	00a68693          	addi	a3,a3,10 # ffffffffc02057d0 <commands+0x1348>
ffffffffc02027ce:	00002617          	auipc	a2,0x2
ffffffffc02027d2:	52a60613          	addi	a2,a2,1322 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02027d6:	10d00593          	li	a1,269
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	d5650513          	addi	a0,a0,-682 # ffffffffc0205530 <commands+0x10a8>
ffffffffc02027e2:	923fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02027e6 <do_pgfault>:
ffffffffc02027e6:	7179                	addi	sp,sp,-48
ffffffffc02027e8:	85b2                	mv	a1,a2
ffffffffc02027ea:	f022                	sd	s0,32(sp)
ffffffffc02027ec:	ec26                	sd	s1,24(sp)
ffffffffc02027ee:	f406                	sd	ra,40(sp)
ffffffffc02027f0:	e84a                	sd	s2,16(sp)
ffffffffc02027f2:	8432                	mv	s0,a2
ffffffffc02027f4:	84aa                	mv	s1,a0
ffffffffc02027f6:	973ff0ef          	jal	ra,ffffffffc0202168 <find_vma>
ffffffffc02027fa:	0000f797          	auipc	a5,0xf
ffffffffc02027fe:	c6e78793          	addi	a5,a5,-914 # ffffffffc0211468 <pgfault_num>
ffffffffc0202802:	439c                	lw	a5,0(a5)
ffffffffc0202804:	2785                	addiw	a5,a5,1
ffffffffc0202806:	0000f717          	auipc	a4,0xf
ffffffffc020280a:	c6f72123          	sw	a5,-926(a4) # ffffffffc0211468 <pgfault_num>
ffffffffc020280e:	c549                	beqz	a0,ffffffffc0202898 <do_pgfault+0xb2>
ffffffffc0202810:	651c                	ld	a5,8(a0)
ffffffffc0202812:	08f46363          	bltu	s0,a5,ffffffffc0202898 <do_pgfault+0xb2>
ffffffffc0202816:	6d1c                	ld	a5,24(a0)
ffffffffc0202818:	4941                	li	s2,16
ffffffffc020281a:	8b89                	andi	a5,a5,2
ffffffffc020281c:	efa9                	bnez	a5,ffffffffc0202876 <do_pgfault+0x90>
ffffffffc020281e:	767d                	lui	a2,0xfffff
ffffffffc0202820:	6c88                	ld	a0,24(s1)
ffffffffc0202822:	8c71                	and	s0,s0,a2
ffffffffc0202824:	85a2                	mv	a1,s0
ffffffffc0202826:	4605                	li	a2,1
ffffffffc0202828:	803fe0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020282c:	610c                	ld	a1,0(a0)
ffffffffc020282e:	c5b1                	beqz	a1,ffffffffc020287a <do_pgfault+0x94>
ffffffffc0202830:	0000f797          	auipc	a5,0xf
ffffffffc0202834:	c4878793          	addi	a5,a5,-952 # ffffffffc0211478 <swap_init_ok>
ffffffffc0202838:	439c                	lw	a5,0(a5)
ffffffffc020283a:	2781                	sext.w	a5,a5
ffffffffc020283c:	c7bd                	beqz	a5,ffffffffc02028aa <do_pgfault+0xc4>
ffffffffc020283e:	85a2                	mv	a1,s0
ffffffffc0202840:	0030                	addi	a2,sp,8
ffffffffc0202842:	8526                	mv	a0,s1
ffffffffc0202844:	e402                	sd	zero,8(sp)
ffffffffc0202846:	00d000ef          	jal	ra,ffffffffc0203052 <swap_in>
ffffffffc020284a:	65a2                	ld	a1,8(sp)
ffffffffc020284c:	6c88                	ld	a0,24(s1)
ffffffffc020284e:	86ca                	mv	a3,s2
ffffffffc0202850:	8622                	mv	a2,s0
ffffffffc0202852:	ab1fe0ef          	jal	ra,ffffffffc0201302 <page_insert>
ffffffffc0202856:	6622                	ld	a2,8(sp)
ffffffffc0202858:	4685                	li	a3,1
ffffffffc020285a:	85a2                	mv	a1,s0
ffffffffc020285c:	8526                	mv	a0,s1
ffffffffc020285e:	6d2000ef          	jal	ra,ffffffffc0202f30 <swap_map_swappable>
ffffffffc0202862:	6722                	ld	a4,8(sp)
ffffffffc0202864:	4781                	li	a5,0
ffffffffc0202866:	e320                	sd	s0,64(a4)
ffffffffc0202868:	70a2                	ld	ra,40(sp)
ffffffffc020286a:	7402                	ld	s0,32(sp)
ffffffffc020286c:	64e2                	ld	s1,24(sp)
ffffffffc020286e:	6942                	ld	s2,16(sp)
ffffffffc0202870:	853e                	mv	a0,a5
ffffffffc0202872:	6145                	addi	sp,sp,48
ffffffffc0202874:	8082                	ret
ffffffffc0202876:	4959                	li	s2,22
ffffffffc0202878:	b75d                	j	ffffffffc020281e <do_pgfault+0x38>
ffffffffc020287a:	6c88                	ld	a0,24(s1)
ffffffffc020287c:	864a                	mv	a2,s2
ffffffffc020287e:	85a2                	mv	a1,s0
ffffffffc0202880:	e36ff0ef          	jal	ra,ffffffffc0201eb6 <pgdir_alloc_page>
ffffffffc0202884:	4781                	li	a5,0
ffffffffc0202886:	f16d                	bnez	a0,ffffffffc0202868 <do_pgfault+0x82>
ffffffffc0202888:	00003517          	auipc	a0,0x3
ffffffffc020288c:	ce850513          	addi	a0,a0,-792 # ffffffffc0205570 <commands+0x10e8>
ffffffffc0202890:	82ffd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202894:	57f1                	li	a5,-4
ffffffffc0202896:	bfc9                	j	ffffffffc0202868 <do_pgfault+0x82>
ffffffffc0202898:	85a2                	mv	a1,s0
ffffffffc020289a:	00003517          	auipc	a0,0x3
ffffffffc020289e:	ca650513          	addi	a0,a0,-858 # ffffffffc0205540 <commands+0x10b8>
ffffffffc02028a2:	81dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028a6:	57f5                	li	a5,-3
ffffffffc02028a8:	b7c1                	j	ffffffffc0202868 <do_pgfault+0x82>
ffffffffc02028aa:	00003517          	auipc	a0,0x3
ffffffffc02028ae:	cee50513          	addi	a0,a0,-786 # ffffffffc0205598 <commands+0x1110>
ffffffffc02028b2:	80dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028b6:	57f1                	li	a5,-4
ffffffffc02028b8:	bf45                	j	ffffffffc0202868 <do_pgfault+0x82>

ffffffffc02028ba <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02028ba:	7135                	addi	sp,sp,-160
ffffffffc02028bc:	ed06                	sd	ra,152(sp)
ffffffffc02028be:	e922                	sd	s0,144(sp)
ffffffffc02028c0:	e526                	sd	s1,136(sp)
ffffffffc02028c2:	e14a                	sd	s2,128(sp)
ffffffffc02028c4:	fcce                	sd	s3,120(sp)
ffffffffc02028c6:	f8d2                	sd	s4,112(sp)
ffffffffc02028c8:	f4d6                	sd	s5,104(sp)
ffffffffc02028ca:	f0da                	sd	s6,96(sp)
ffffffffc02028cc:	ecde                	sd	s7,88(sp)
ffffffffc02028ce:	e8e2                	sd	s8,80(sp)
ffffffffc02028d0:	e4e6                	sd	s9,72(sp)
ffffffffc02028d2:	e0ea                	sd	s10,64(sp)
ffffffffc02028d4:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02028d6:	368010ef          	jal	ra,ffffffffc0203c3e <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02028da:	0000f697          	auipc	a3,0xf
ffffffffc02028de:	c6e6b683          	ld	a3,-914(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc02028e2:	010007b7          	lui	a5,0x1000
ffffffffc02028e6:	ff968713          	addi	a4,a3,-7
ffffffffc02028ea:	17e1                	addi	a5,a5,-8
ffffffffc02028ec:	3ee7ef63          	bltu	a5,a4,ffffffffc0202cea <swap_init+0x430>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc02028f0:	00007797          	auipc	a5,0x7
ffffffffc02028f4:	71078793          	addi	a5,a5,1808 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc02028f8:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc02028fa:	0000fc17          	auipc	s8,0xf
ffffffffc02028fe:	b76c0c13          	addi	s8,s8,-1162 # ffffffffc0211470 <sm>
ffffffffc0202902:	00fc3023          	sd	a5,0(s8)
     int r = sm->init();
ffffffffc0202906:	9702                	jalr	a4
ffffffffc0202908:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020290a:	c10d                	beqz	a0,ffffffffc020292c <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020290c:	60ea                	ld	ra,152(sp)
ffffffffc020290e:	644a                	ld	s0,144(sp)
ffffffffc0202910:	64aa                	ld	s1,136(sp)
ffffffffc0202912:	79e6                	ld	s3,120(sp)
ffffffffc0202914:	7a46                	ld	s4,112(sp)
ffffffffc0202916:	7aa6                	ld	s5,104(sp)
ffffffffc0202918:	7b06                	ld	s6,96(sp)
ffffffffc020291a:	6be6                	ld	s7,88(sp)
ffffffffc020291c:	6c46                	ld	s8,80(sp)
ffffffffc020291e:	6ca6                	ld	s9,72(sp)
ffffffffc0202920:	6d06                	ld	s10,64(sp)
ffffffffc0202922:	7de2                	ld	s11,56(sp)
ffffffffc0202924:	854a                	mv	a0,s2
ffffffffc0202926:	690a                	ld	s2,128(sp)
ffffffffc0202928:	610d                	addi	sp,sp,160
ffffffffc020292a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020292c:	000c3783          	ld	a5,0(s8)
ffffffffc0202930:	00003517          	auipc	a0,0x3
ffffffffc0202934:	f5850513          	addi	a0,a0,-168 # ffffffffc0205888 <commands+0x1400>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0202938:	0000f417          	auipc	s0,0xf
ffffffffc020293c:	c5040413          	addi	s0,s0,-944 # ffffffffc0211588 <free_area>
ffffffffc0202940:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202942:	4785                	li	a5,1
ffffffffc0202944:	0000f717          	auipc	a4,0xf
ffffffffc0202948:	b2f72a23          	sw	a5,-1228(a4) # ffffffffc0211478 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020294c:	f72fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202950:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202952:	4481                	li	s1,0
ffffffffc0202954:	4981                	li	s3,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202956:	2c878063          	beq	a5,s0,ffffffffc0202c16 <swap_init+0x35c>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020295a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020295e:	8b09                	andi	a4,a4,2
ffffffffc0202960:	2a070d63          	beqz	a4,ffffffffc0202c1a <swap_init+0x360>
        count ++, total += p->property;
ffffffffc0202964:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202968:	679c                	ld	a5,8(a5)
ffffffffc020296a:	2985                	addiw	s3,s3,1
ffffffffc020296c:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020296e:	fe8796e3          	bne	a5,s0,ffffffffc020295a <swap_init+0xa0>
ffffffffc0202972:	8a26                	mv	s4,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202974:	e76fe0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc0202978:	58aa1563          	bne	s4,a0,ffffffffc0202f02 <swap_init+0x648>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020297c:	8626                	mv	a2,s1
ffffffffc020297e:	85ce                	mv	a1,s3
ffffffffc0202980:	00003517          	auipc	a0,0x3
ffffffffc0202984:	f5050513          	addi	a0,a0,-176 # ffffffffc02058d0 <commands+0x1448>
ffffffffc0202988:	f36fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020298c:	f62ff0ef          	jal	ra,ffffffffc02020ee <mm_create>
ffffffffc0202990:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202992:	4e050863          	beqz	a0,ffffffffc0202e82 <swap_init+0x5c8>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202996:	0000f797          	auipc	a5,0xf
ffffffffc020299a:	b2278793          	addi	a5,a5,-1246 # ffffffffc02114b8 <check_mm_struct>
ffffffffc020299e:	6398                	ld	a4,0(a5)
ffffffffc02029a0:	50071163          	bnez	a4,ffffffffc0202ea2 <swap_init+0x5e8>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029a4:	0000fc97          	auipc	s9,0xf
ffffffffc02029a8:	ab4cbc83          	ld	s9,-1356(s9) # ffffffffc0211458 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc02029ac:	000cb703          	ld	a4,0(s9)
     check_mm_struct = mm;
ffffffffc02029b0:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02029b2:	01953c23          	sd	s9,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02029b6:	50071663          	bnez	a4,ffffffffc0202ec2 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02029ba:	6599                	lui	a1,0x6
ffffffffc02029bc:	460d                	li	a2,3
ffffffffc02029be:	6505                	lui	a0,0x1
ffffffffc02029c0:	f7aff0ef          	jal	ra,ffffffffc020213a <vma_create>
ffffffffc02029c4:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02029c6:	50050e63          	beqz	a0,ffffffffc0202ee2 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02029ca:	855e                	mv	a0,s7
ffffffffc02029cc:	fdaff0ef          	jal	ra,ffffffffc02021a6 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02029d0:	00003517          	auipc	a0,0x3
ffffffffc02029d4:	f4050513          	addi	a0,a0,-192 # ffffffffc0205910 <commands+0x1488>
ffffffffc02029d8:	ee6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02029dc:	018bb503          	ld	a0,24(s7)
ffffffffc02029e0:	4605                	li	a2,1
ffffffffc02029e2:	6585                	lui	a1,0x1
ffffffffc02029e4:	e46fe0ef          	jal	ra,ffffffffc020102a <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02029e8:	3e050d63          	beqz	a0,ffffffffc0202de2 <swap_init+0x528>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029ec:	00003517          	auipc	a0,0x3
ffffffffc02029f0:	f7450513          	addi	a0,a0,-140 # ffffffffc0205960 <commands+0x14d8>
ffffffffc02029f4:	0000fa97          	auipc	s5,0xf
ffffffffc02029f8:	acca8a93          	addi	s5,s5,-1332 # ffffffffc02114c0 <check_rp>
ffffffffc02029fc:	ec2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a00:	0000fb17          	auipc	s6,0xf
ffffffffc0202a04:	ae0b0b13          	addi	s6,s6,-1312 # ffffffffc02114e0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a08:	8a56                	mv	s4,s5
          check_rp[i] = alloc_page();
ffffffffc0202a0a:	4505                	li	a0,1
ffffffffc0202a0c:	d10fe0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0202a10:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0202a14:	28050b63          	beqz	a0,ffffffffc0202caa <swap_init+0x3f0>
ffffffffc0202a18:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202a1a:	8b89                	andi	a5,a5,2
ffffffffc0202a1c:	26079763          	bnez	a5,ffffffffc0202c8a <swap_init+0x3d0>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a20:	0a21                	addi	s4,s4,8
ffffffffc0202a22:	ff6a14e3          	bne	s4,s6,ffffffffc0202a0a <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202a26:	601c                	ld	a5,0(s0)
ffffffffc0202a28:	00843a03          	ld	s4,8(s0)
    elm->prev = elm->next = elm;
ffffffffc0202a2c:	e000                	sd	s0,0(s0)
ffffffffc0202a2e:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202a30:	481c                	lw	a5,16(s0)
ffffffffc0202a32:	e400                	sd	s0,8(s0)
     nr_free = 0;
ffffffffc0202a34:	0000fd17          	auipc	s10,0xf
ffffffffc0202a38:	a8cd0d13          	addi	s10,s10,-1396 # ffffffffc02114c0 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202a3c:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202a3e:	0000f797          	auipc	a5,0xf
ffffffffc0202a42:	b407ad23          	sw	zero,-1190(a5) # ffffffffc0211598 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202a46:	000d3503          	ld	a0,0(s10)
ffffffffc0202a4a:	4585                	li	a1,1
ffffffffc0202a4c:	0d21                	addi	s10,s10,8
ffffffffc0202a4e:	d56fe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a52:	ff6d1ae3          	bne	s10,s6,ffffffffc0202a46 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a56:	01042d03          	lw	s10,16(s0)
ffffffffc0202a5a:	4791                	li	a5,4
ffffffffc0202a5c:	36fd1363          	bne	s10,a5,ffffffffc0202dc2 <swap_init+0x508>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a60:	00003517          	auipc	a0,0x3
ffffffffc0202a64:	f8850513          	addi	a0,a0,-120 # ffffffffc02059e8 <commands+0x1560>
ffffffffc0202a68:	e56fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a6c:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a6e:	0000f797          	auipc	a5,0xf
ffffffffc0202a72:	9e07ad23          	sw	zero,-1542(a5) # ffffffffc0211468 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a76:	4629                	li	a2,10
ffffffffc0202a78:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a7c:	0000f697          	auipc	a3,0xf
ffffffffc0202a80:	9ec6a683          	lw	a3,-1556(a3) # ffffffffc0211468 <pgfault_num>
ffffffffc0202a84:	4585                	li	a1,1
ffffffffc0202a86:	0000f797          	auipc	a5,0xf
ffffffffc0202a8a:	9e278793          	addi	a5,a5,-1566 # ffffffffc0211468 <pgfault_num>
ffffffffc0202a8e:	2eb69a63          	bne	a3,a1,ffffffffc0202d82 <swap_init+0x4c8>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a92:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc0202a96:	4398                	lw	a4,0(a5)
ffffffffc0202a98:	2701                	sext.w	a4,a4
ffffffffc0202a9a:	30d71463          	bne	a4,a3,ffffffffc0202da2 <swap_init+0x4e8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a9e:	6689                	lui	a3,0x2
ffffffffc0202aa0:	462d                	li	a2,11
ffffffffc0202aa2:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202aa6:	4398                	lw	a4,0(a5)
ffffffffc0202aa8:	4589                	li	a1,2
ffffffffc0202aaa:	2701                	sext.w	a4,a4
ffffffffc0202aac:	24b71b63          	bne	a4,a1,ffffffffc0202d02 <swap_init+0x448>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202ab0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202ab4:	4394                	lw	a3,0(a5)
ffffffffc0202ab6:	2681                	sext.w	a3,a3
ffffffffc0202ab8:	26e69563          	bne	a3,a4,ffffffffc0202d22 <swap_init+0x468>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202abc:	668d                	lui	a3,0x3
ffffffffc0202abe:	4631                	li	a2,12
ffffffffc0202ac0:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202ac4:	4398                	lw	a4,0(a5)
ffffffffc0202ac6:	458d                	li	a1,3
ffffffffc0202ac8:	2701                	sext.w	a4,a4
ffffffffc0202aca:	26b71c63          	bne	a4,a1,ffffffffc0202d42 <swap_init+0x488>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202ace:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202ad2:	4394                	lw	a3,0(a5)
ffffffffc0202ad4:	2681                	sext.w	a3,a3
ffffffffc0202ad6:	28e69663          	bne	a3,a4,ffffffffc0202d62 <swap_init+0x4a8>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202ada:	6691                	lui	a3,0x4
ffffffffc0202adc:	4635                	li	a2,13
ffffffffc0202ade:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202ae2:	4398                	lw	a4,0(a5)
ffffffffc0202ae4:	2701                	sext.w	a4,a4
ffffffffc0202ae6:	31a71e63          	bne	a4,s10,ffffffffc0202e02 <swap_init+0x548>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202aea:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202aee:	439c                	lw	a5,0(a5)
ffffffffc0202af0:	2781                	sext.w	a5,a5
ffffffffc0202af2:	32e79863          	bne	a5,a4,ffffffffc0202e22 <swap_init+0x568>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202af6:	481c                	lw	a5,16(s0)
ffffffffc0202af8:	34079563          	bnez	a5,ffffffffc0202e42 <swap_init+0x588>
ffffffffc0202afc:	0000f797          	auipc	a5,0xf
ffffffffc0202b00:	9e478793          	addi	a5,a5,-1564 # ffffffffc02114e0 <swap_in_seq_no>
ffffffffc0202b04:	0000f717          	auipc	a4,0xf
ffffffffc0202b08:	a0470713          	addi	a4,a4,-1532 # ffffffffc0211508 <swap_out_seq_no>
ffffffffc0202b0c:	0000f617          	auipc	a2,0xf
ffffffffc0202b10:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0211508 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202b14:	56fd                	li	a3,-1
ffffffffc0202b16:	c394                	sw	a3,0(a5)
ffffffffc0202b18:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202b1a:	0791                	addi	a5,a5,4
ffffffffc0202b1c:	0711                	addi	a4,a4,4
ffffffffc0202b1e:	fef61ce3          	bne	a2,a5,ffffffffc0202b16 <swap_init+0x25c>
ffffffffc0202b22:	0000f697          	auipc	a3,0xf
ffffffffc0202b26:	a4668693          	addi	a3,a3,-1466 # ffffffffc0211568 <check_ptep>
ffffffffc0202b2a:	0000f817          	auipc	a6,0xf
ffffffffc0202b2e:	99680813          	addi	a6,a6,-1642 # ffffffffc02114c0 <check_rp>
ffffffffc0202b32:	6585                	lui	a1,0x1

static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0202b34:	0000fd97          	auipc	s11,0xf
ffffffffc0202b38:	97cd8d93          	addi	s11,s11,-1668 # ffffffffc02114b0 <pages>
ffffffffc0202b3c:	00003d17          	auipc	s10,0x3
ffffffffc0202b40:	6f4d0d13          	addi	s10,s10,1780 # ffffffffc0206230 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202b44:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b48:	4601                	li	a2,0
ffffffffc0202b4a:	8566                	mv	a0,s9
ffffffffc0202b4c:	ec42                	sd	a6,24(sp)
ffffffffc0202b4e:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202b50:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b52:	cd8fe0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc0202b56:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b58:	65c2                	ld	a1,16(sp)
ffffffffc0202b5a:	6862                	ld	a6,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b5c:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b5e:	0000fe17          	auipc	t3,0xf
ffffffffc0202b62:	902e0e13          	addi	t3,t3,-1790 # ffffffffc0211460 <npage>
ffffffffc0202b66:	16050263          	beqz	a0,ffffffffc0202cca <swap_init+0x410>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b6a:	611c                	ld	a5,0(a0)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

static inline struct Page *pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
ffffffffc0202b6c:	0017f713          	andi	a4,a5,1
ffffffffc0202b70:	0e070563          	beqz	a4,ffffffffc0202c5a <swap_init+0x3a0>
    if (PPN(pa) >= npage) {
ffffffffc0202b74:	000e3703          	ld	a4,0(t3)
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b78:	078a                	slli	a5,a5,0x2
ffffffffc0202b7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b7c:	0ee7fb63          	bgeu	a5,a4,ffffffffc0202c72 <swap_init+0x3b8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b80:	000d3703          	ld	a4,0(s10)
ffffffffc0202b84:	000db603          	ld	a2,0(s11)
ffffffffc0202b88:	00083503          	ld	a0,0(a6)
ffffffffc0202b8c:	8f99                	sub	a5,a5,a4
ffffffffc0202b8e:	00379713          	slli	a4,a5,0x3
ffffffffc0202b92:	97ba                	add	a5,a5,a4
ffffffffc0202b94:	078e                	slli	a5,a5,0x3
ffffffffc0202b96:	97b2                	add	a5,a5,a2
ffffffffc0202b98:	0af51163          	bne	a0,a5,ffffffffc0202c3a <swap_init+0x380>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b9c:	6785                	lui	a5,0x1
ffffffffc0202b9e:	95be                	add	a1,a1,a5
ffffffffc0202ba0:	6795                	lui	a5,0x5
ffffffffc0202ba2:	06a1                	addi	a3,a3,8
ffffffffc0202ba4:	0821                	addi	a6,a6,8
ffffffffc0202ba6:	f8f59fe3          	bne	a1,a5,ffffffffc0202b44 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202baa:	00003517          	auipc	a0,0x3
ffffffffc0202bae:	ee650513          	addi	a0,a0,-282 # ffffffffc0205a90 <commands+0x1608>
ffffffffc0202bb2:	d0cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202bb6:	000c3783          	ld	a5,0(s8)
ffffffffc0202bba:	7f9c                	ld	a5,56(a5)
ffffffffc0202bbc:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202bbe:	2a051263          	bnez	a0,ffffffffc0202e62 <swap_init+0x5a8>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202bc2:	000ab503          	ld	a0,0(s5)
ffffffffc0202bc6:	4585                	li	a1,1
ffffffffc0202bc8:	0aa1                	addi	s5,s5,8
ffffffffc0202bca:	bdafe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bce:	ff6a9ae3          	bne	s5,s6,ffffffffc0202bc2 <swap_init+0x308>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202bd2:	855e                	mv	a0,s7
ffffffffc0202bd4:	ea0ff0ef          	jal	ra,ffffffffc0202274 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202bd8:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202bda:	01443423          	sd	s4,8(s0)
     nr_free = nr_free_store;
ffffffffc0202bde:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0202be0:	7782                	ld	a5,32(sp)
ffffffffc0202be2:	e01c                	sd	a5,0(s0)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202be4:	008a0a63          	beq	s4,s0,ffffffffc0202bf8 <swap_init+0x33e>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202be8:	ff8a2783          	lw	a5,-8(s4)
    return listelm->next;
ffffffffc0202bec:	008a3a03          	ld	s4,8(s4)
ffffffffc0202bf0:	39fd                	addiw	s3,s3,-1
ffffffffc0202bf2:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bf4:	fe8a1ae3          	bne	s4,s0,ffffffffc0202be8 <swap_init+0x32e>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bf8:	8626                	mv	a2,s1
ffffffffc0202bfa:	85ce                	mv	a1,s3
ffffffffc0202bfc:	00003517          	auipc	a0,0x3
ffffffffc0202c00:	ec450513          	addi	a0,a0,-316 # ffffffffc0205ac0 <commands+0x1638>
ffffffffc0202c04:	cbafd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	ed850513          	addi	a0,a0,-296 # ffffffffc0205ae0 <commands+0x1658>
ffffffffc0202c10:	caefd0ef          	jal	ra,ffffffffc02000be <cprintf>
     // }
     // cprintf("count is %d, total is %d\n",count,total);
     // //assert(count == 0);
     
     // cprintf("check_swap() succeeded!\n");
ffffffffc0202c14:	b9e5                	j	ffffffffc020290c <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202c16:	4a01                	li	s4,0
ffffffffc0202c18:	bbb1                	j	ffffffffc0202974 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202c1a:	00003697          	auipc	a3,0x3
ffffffffc0202c1e:	c8668693          	addi	a3,a3,-890 # ffffffffc02058a0 <commands+0x1418>
ffffffffc0202c22:	00002617          	auipc	a2,0x2
ffffffffc0202c26:	0d660613          	addi	a2,a2,214 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202c2a:	0c700593          	li	a1,199
ffffffffc0202c2e:	00003517          	auipc	a0,0x3
ffffffffc0202c32:	c4a50513          	addi	a0,a0,-950 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202c36:	ccefd0ef          	jal	ra,ffffffffc0200104 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c3a:	00003697          	auipc	a3,0x3
ffffffffc0202c3e:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205a68 <commands+0x15e0>
ffffffffc0202c42:	00002617          	auipc	a2,0x2
ffffffffc0202c46:	0b660613          	addi	a2,a2,182 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202c4a:	10700593          	li	a1,263
ffffffffc0202c4e:	00003517          	auipc	a0,0x3
ffffffffc0202c52:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202c56:	caefd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c5a:	00002617          	auipc	a2,0x2
ffffffffc0202c5e:	4d660613          	addi	a2,a2,1238 # ffffffffc0205130 <commands+0xca8>
ffffffffc0202c62:	07000593          	li	a1,112
ffffffffc0202c66:	00002517          	auipc	a0,0x2
ffffffffc0202c6a:	2f250513          	addi	a0,a0,754 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0202c6e:	c96fd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c72:	00002617          	auipc	a2,0x2
ffffffffc0202c76:	2c660613          	addi	a2,a2,710 # ffffffffc0204f38 <commands+0xab0>
ffffffffc0202c7a:	06500593          	li	a1,101
ffffffffc0202c7e:	00002517          	auipc	a0,0x2
ffffffffc0202c82:	2da50513          	addi	a0,a0,730 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0202c86:	c7efd0ef          	jal	ra,ffffffffc0200104 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c8a:	00003697          	auipc	a3,0x3
ffffffffc0202c8e:	d1668693          	addi	a3,a3,-746 # ffffffffc02059a0 <commands+0x1518>
ffffffffc0202c92:	00002617          	auipc	a2,0x2
ffffffffc0202c96:	06660613          	addi	a2,a2,102 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202c9a:	0e800593          	li	a1,232
ffffffffc0202c9e:	00003517          	auipc	a0,0x3
ffffffffc0202ca2:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202ca6:	c5efd0ef          	jal	ra,ffffffffc0200104 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202caa:	00003697          	auipc	a3,0x3
ffffffffc0202cae:	cde68693          	addi	a3,a3,-802 # ffffffffc0205988 <commands+0x1500>
ffffffffc0202cb2:	00002617          	auipc	a2,0x2
ffffffffc0202cb6:	04660613          	addi	a2,a2,70 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202cba:	0e700593          	li	a1,231
ffffffffc0202cbe:	00003517          	auipc	a0,0x3
ffffffffc0202cc2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202cc6:	c3efd0ef          	jal	ra,ffffffffc0200104 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202cca:	00003697          	auipc	a3,0x3
ffffffffc0202cce:	d8668693          	addi	a3,a3,-634 # ffffffffc0205a50 <commands+0x15c8>
ffffffffc0202cd2:	00002617          	auipc	a2,0x2
ffffffffc0202cd6:	02660613          	addi	a2,a2,38 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202cda:	10600593          	li	a1,262
ffffffffc0202cde:	00003517          	auipc	a0,0x3
ffffffffc0202ce2:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202ce6:	c1efd0ef          	jal	ra,ffffffffc0200104 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202cea:	00003617          	auipc	a2,0x3
ffffffffc0202cee:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0205858 <commands+0x13d0>
ffffffffc0202cf2:	02800593          	li	a1,40
ffffffffc0202cf6:	00003517          	auipc	a0,0x3
ffffffffc0202cfa:	b8250513          	addi	a0,a0,-1150 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202cfe:	c06fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==2);
ffffffffc0202d02:	00003697          	auipc	a3,0x3
ffffffffc0202d06:	d1e68693          	addi	a3,a3,-738 # ffffffffc0205a20 <commands+0x1598>
ffffffffc0202d0a:	00002617          	auipc	a2,0x2
ffffffffc0202d0e:	fee60613          	addi	a2,a2,-18 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202d12:	09600593          	li	a1,150
ffffffffc0202d16:	00003517          	auipc	a0,0x3
ffffffffc0202d1a:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202d1e:	be6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==2);
ffffffffc0202d22:	00003697          	auipc	a3,0x3
ffffffffc0202d26:	cfe68693          	addi	a3,a3,-770 # ffffffffc0205a20 <commands+0x1598>
ffffffffc0202d2a:	00002617          	auipc	a2,0x2
ffffffffc0202d2e:	fce60613          	addi	a2,a2,-50 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202d32:	09800593          	li	a1,152
ffffffffc0202d36:	00003517          	auipc	a0,0x3
ffffffffc0202d3a:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202d3e:	bc6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d42:	00003697          	auipc	a3,0x3
ffffffffc0202d46:	cee68693          	addi	a3,a3,-786 # ffffffffc0205a30 <commands+0x15a8>
ffffffffc0202d4a:	00002617          	auipc	a2,0x2
ffffffffc0202d4e:	fae60613          	addi	a2,a2,-82 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202d52:	09a00593          	li	a1,154
ffffffffc0202d56:	00003517          	auipc	a0,0x3
ffffffffc0202d5a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202d5e:	ba6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d62:	00003697          	auipc	a3,0x3
ffffffffc0202d66:	cce68693          	addi	a3,a3,-818 # ffffffffc0205a30 <commands+0x15a8>
ffffffffc0202d6a:	00002617          	auipc	a2,0x2
ffffffffc0202d6e:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202d72:	09c00593          	li	a1,156
ffffffffc0202d76:	00003517          	auipc	a0,0x3
ffffffffc0202d7a:	b0250513          	addi	a0,a0,-1278 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202d7e:	b86fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d82:	00003697          	auipc	a3,0x3
ffffffffc0202d86:	c8e68693          	addi	a3,a3,-882 # ffffffffc0205a10 <commands+0x1588>
ffffffffc0202d8a:	00002617          	auipc	a2,0x2
ffffffffc0202d8e:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202d92:	09200593          	li	a1,146
ffffffffc0202d96:	00003517          	auipc	a0,0x3
ffffffffc0202d9a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202d9e:	b66fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==1);
ffffffffc0202da2:	00003697          	auipc	a3,0x3
ffffffffc0202da6:	c6e68693          	addi	a3,a3,-914 # ffffffffc0205a10 <commands+0x1588>
ffffffffc0202daa:	00002617          	auipc	a2,0x2
ffffffffc0202dae:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202db2:	09400593          	li	a1,148
ffffffffc0202db6:	00003517          	auipc	a0,0x3
ffffffffc0202dba:	ac250513          	addi	a0,a0,-1342 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202dbe:	b46fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202dc2:	00003697          	auipc	a3,0x3
ffffffffc0202dc6:	bfe68693          	addi	a3,a3,-1026 # ffffffffc02059c0 <commands+0x1538>
ffffffffc0202dca:	00002617          	auipc	a2,0x2
ffffffffc0202dce:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202dd2:	0f500593          	li	a1,245
ffffffffc0202dd6:	00003517          	auipc	a0,0x3
ffffffffc0202dda:	aa250513          	addi	a0,a0,-1374 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202dde:	b26fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202de2:	00003697          	auipc	a3,0x3
ffffffffc0202de6:	b6668693          	addi	a3,a3,-1178 # ffffffffc0205948 <commands+0x14c0>
ffffffffc0202dea:	00002617          	auipc	a2,0x2
ffffffffc0202dee:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202df2:	0e200593          	li	a1,226
ffffffffc0202df6:	00003517          	auipc	a0,0x3
ffffffffc0202dfa:	a8250513          	addi	a0,a0,-1406 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202dfe:	b06fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e02:	00002697          	auipc	a3,0x2
ffffffffc0202e06:	ee668693          	addi	a3,a3,-282 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0202e0a:	00002617          	auipc	a2,0x2
ffffffffc0202e0e:	eee60613          	addi	a2,a2,-274 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202e12:	09e00593          	li	a1,158
ffffffffc0202e16:	00003517          	auipc	a0,0x3
ffffffffc0202e1a:	a6250513          	addi	a0,a0,-1438 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202e1e:	ae6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e22:	00002697          	auipc	a3,0x2
ffffffffc0202e26:	ec668693          	addi	a3,a3,-314 # ffffffffc0204ce8 <commands+0x860>
ffffffffc0202e2a:	00002617          	auipc	a2,0x2
ffffffffc0202e2e:	ece60613          	addi	a2,a2,-306 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202e32:	0a000593          	li	a1,160
ffffffffc0202e36:	00003517          	auipc	a0,0x3
ffffffffc0202e3a:	a4250513          	addi	a0,a0,-1470 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202e3e:	ac6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e42:	00003697          	auipc	a3,0x3
ffffffffc0202e46:	bfe68693          	addi	a3,a3,-1026 # ffffffffc0205a40 <commands+0x15b8>
ffffffffc0202e4a:	00002617          	auipc	a2,0x2
ffffffffc0202e4e:	eae60613          	addi	a2,a2,-338 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202e52:	0fe00593          	li	a1,254
ffffffffc0202e56:	00003517          	auipc	a0,0x3
ffffffffc0202e5a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202e5e:	aa6fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(ret==0);
ffffffffc0202e62:	00003697          	auipc	a3,0x3
ffffffffc0202e66:	c5668693          	addi	a3,a3,-938 # ffffffffc0205ab8 <commands+0x1630>
ffffffffc0202e6a:	00002617          	auipc	a2,0x2
ffffffffc0202e6e:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202e72:	10d00593          	li	a1,269
ffffffffc0202e76:	00003517          	auipc	a0,0x3
ffffffffc0202e7a:	a0250513          	addi	a0,a0,-1534 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202e7e:	a86fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(mm != NULL);
ffffffffc0202e82:	00002697          	auipc	a3,0x2
ffffffffc0202e86:	79e68693          	addi	a3,a3,1950 # ffffffffc0205620 <commands+0x1198>
ffffffffc0202e8a:	00002617          	auipc	a2,0x2
ffffffffc0202e8e:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202e92:	0cf00593          	li	a1,207
ffffffffc0202e96:	00003517          	auipc	a0,0x3
ffffffffc0202e9a:	9e250513          	addi	a0,a0,-1566 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202e9e:	a66fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202ea2:	00003697          	auipc	a3,0x3
ffffffffc0202ea6:	a5668693          	addi	a3,a3,-1450 # ffffffffc02058f8 <commands+0x1470>
ffffffffc0202eaa:	00002617          	auipc	a2,0x2
ffffffffc0202eae:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202eb2:	0d200593          	li	a1,210
ffffffffc0202eb6:	00003517          	auipc	a0,0x3
ffffffffc0202eba:	9c250513          	addi	a0,a0,-1598 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202ebe:	a46fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202ec2:	00003697          	auipc	a3,0x3
ffffffffc0202ec6:	90e68693          	addi	a3,a3,-1778 # ffffffffc02057d0 <commands+0x1348>
ffffffffc0202eca:	00002617          	auipc	a2,0x2
ffffffffc0202ece:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202ed2:	0d700593          	li	a1,215
ffffffffc0202ed6:	00003517          	auipc	a0,0x3
ffffffffc0202eda:	9a250513          	addi	a0,a0,-1630 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202ede:	a26fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(vma != NULL);
ffffffffc0202ee2:	00003697          	auipc	a3,0x3
ffffffffc0202ee6:	96668693          	addi	a3,a3,-1690 # ffffffffc0205848 <commands+0x13c0>
ffffffffc0202eea:	00002617          	auipc	a2,0x2
ffffffffc0202eee:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202ef2:	0da00593          	li	a1,218
ffffffffc0202ef6:	00003517          	auipc	a0,0x3
ffffffffc0202efa:	98250513          	addi	a0,a0,-1662 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202efe:	a06fd0ef          	jal	ra,ffffffffc0200104 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202f02:	00003697          	auipc	a3,0x3
ffffffffc0202f06:	9ae68693          	addi	a3,a3,-1618 # ffffffffc02058b0 <commands+0x1428>
ffffffffc0202f0a:	00002617          	auipc	a2,0x2
ffffffffc0202f0e:	dee60613          	addi	a2,a2,-530 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0202f12:	0ca00593          	li	a1,202
ffffffffc0202f16:	00003517          	auipc	a0,0x3
ffffffffc0202f1a:	96250513          	addi	a0,a0,-1694 # ffffffffc0205878 <commands+0x13f0>
ffffffffc0202f1e:	9e6fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0202f22 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202f22:	0000e797          	auipc	a5,0xe
ffffffffc0202f26:	54e7b783          	ld	a5,1358(a5) # ffffffffc0211470 <sm>
ffffffffc0202f2a:	0107b303          	ld	t1,16(a5)
ffffffffc0202f2e:	8302                	jr	t1

ffffffffc0202f30 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202f30:	0000e797          	auipc	a5,0xe
ffffffffc0202f34:	5407b783          	ld	a5,1344(a5) # ffffffffc0211470 <sm>
ffffffffc0202f38:	0207b303          	ld	t1,32(a5)
ffffffffc0202f3c:	8302                	jr	t1

ffffffffc0202f3e <swap_out>:
{
ffffffffc0202f3e:	711d                	addi	sp,sp,-96
ffffffffc0202f40:	ec86                	sd	ra,88(sp)
ffffffffc0202f42:	e8a2                	sd	s0,80(sp)
ffffffffc0202f44:	e4a6                	sd	s1,72(sp)
ffffffffc0202f46:	e0ca                	sd	s2,64(sp)
ffffffffc0202f48:	fc4e                	sd	s3,56(sp)
ffffffffc0202f4a:	f852                	sd	s4,48(sp)
ffffffffc0202f4c:	f456                	sd	s5,40(sp)
ffffffffc0202f4e:	f05a                	sd	s6,32(sp)
ffffffffc0202f50:	ec5e                	sd	s7,24(sp)
ffffffffc0202f52:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f54:	cde9                	beqz	a1,ffffffffc020302e <swap_out+0xf0>
ffffffffc0202f56:	8a2e                	mv	s4,a1
ffffffffc0202f58:	892a                	mv	s2,a0
ffffffffc0202f5a:	8ab2                	mv	s5,a2
ffffffffc0202f5c:	4401                	li	s0,0
ffffffffc0202f5e:	0000e997          	auipc	s3,0xe
ffffffffc0202f62:	51298993          	addi	s3,s3,1298 # ffffffffc0211470 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f66:	00003b17          	auipc	s6,0x3
ffffffffc0202f6a:	bfab0b13          	addi	s6,s6,-1030 # ffffffffc0205b60 <commands+0x16d8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f6e:	00003b97          	auipc	s7,0x3
ffffffffc0202f72:	bdab8b93          	addi	s7,s7,-1062 # ffffffffc0205b48 <commands+0x16c0>
ffffffffc0202f76:	a825                	j	ffffffffc0202fae <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f78:	67a2                	ld	a5,8(sp)
ffffffffc0202f7a:	8626                	mv	a2,s1
ffffffffc0202f7c:	85a2                	mv	a1,s0
ffffffffc0202f7e:	63b4                	ld	a3,64(a5)
ffffffffc0202f80:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f82:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f84:	82b1                	srli	a3,a3,0xc
ffffffffc0202f86:	0685                	addi	a3,a3,1
ffffffffc0202f88:	936fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f8c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f8e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f90:	613c                	ld	a5,64(a0)
ffffffffc0202f92:	83b1                	srli	a5,a5,0xc
ffffffffc0202f94:	0785                	addi	a5,a5,1
ffffffffc0202f96:	07a2                	slli	a5,a5,0x8
ffffffffc0202f98:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0202f9c:	808fe0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202fa0:	01893503          	ld	a0,24(s2)
ffffffffc0202fa4:	85a6                	mv	a1,s1
ffffffffc0202fa6:	f0bfe0ef          	jal	ra,ffffffffc0201eb0 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202faa:	048a0d63          	beq	s4,s0,ffffffffc0203004 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202fae:	0009b783          	ld	a5,0(s3)
ffffffffc0202fb2:	8656                	mv	a2,s5
ffffffffc0202fb4:	002c                	addi	a1,sp,8
ffffffffc0202fb6:	7b9c                	ld	a5,48(a5)
ffffffffc0202fb8:	854a                	mv	a0,s2
ffffffffc0202fba:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202fbc:	e12d                	bnez	a0,ffffffffc020301e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202fbe:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fc0:	01893503          	ld	a0,24(s2)
ffffffffc0202fc4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202fc6:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fc8:	85a6                	mv	a1,s1
ffffffffc0202fca:	860fe0ef          	jal	ra,ffffffffc020102a <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fce:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202fd0:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fd2:	8b85                	andi	a5,a5,1
ffffffffc0202fd4:	cfb9                	beqz	a5,ffffffffc0203032 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fd6:	65a2                	ld	a1,8(sp)
ffffffffc0202fd8:	61bc                	ld	a5,64(a1)
ffffffffc0202fda:	83b1                	srli	a5,a5,0xc
ffffffffc0202fdc:	0785                	addi	a5,a5,1
ffffffffc0202fde:	00879513          	slli	a0,a5,0x8
ffffffffc0202fe2:	53b000ef          	jal	ra,ffffffffc0203d1c <swapfs_write>
ffffffffc0202fe6:	d949                	beqz	a0,ffffffffc0202f78 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fe8:	855e                	mv	a0,s7
ffffffffc0202fea:	8d4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fee:	0009b783          	ld	a5,0(s3)
ffffffffc0202ff2:	6622                	ld	a2,8(sp)
ffffffffc0202ff4:	4681                	li	a3,0
ffffffffc0202ff6:	739c                	ld	a5,32(a5)
ffffffffc0202ff8:	85a6                	mv	a1,s1
ffffffffc0202ffa:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202ffc:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202ffe:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203000:	fa8a17e3          	bne	s4,s0,ffffffffc0202fae <swap_out+0x70>
}
ffffffffc0203004:	60e6                	ld	ra,88(sp)
ffffffffc0203006:	8522                	mv	a0,s0
ffffffffc0203008:	6446                	ld	s0,80(sp)
ffffffffc020300a:	64a6                	ld	s1,72(sp)
ffffffffc020300c:	6906                	ld	s2,64(sp)
ffffffffc020300e:	79e2                	ld	s3,56(sp)
ffffffffc0203010:	7a42                	ld	s4,48(sp)
ffffffffc0203012:	7aa2                	ld	s5,40(sp)
ffffffffc0203014:	7b02                	ld	s6,32(sp)
ffffffffc0203016:	6be2                	ld	s7,24(sp)
ffffffffc0203018:	6c42                	ld	s8,16(sp)
ffffffffc020301a:	6125                	addi	sp,sp,96
ffffffffc020301c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020301e:	85a2                	mv	a1,s0
ffffffffc0203020:	00003517          	auipc	a0,0x3
ffffffffc0203024:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205b00 <commands+0x1678>
ffffffffc0203028:	896fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc020302c:	bfe1                	j	ffffffffc0203004 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020302e:	4401                	li	s0,0
ffffffffc0203030:	bfd1                	j	ffffffffc0203004 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203032:	00003697          	auipc	a3,0x3
ffffffffc0203036:	afe68693          	addi	a3,a3,-1282 # ffffffffc0205b30 <commands+0x16a8>
ffffffffc020303a:	00002617          	auipc	a2,0x2
ffffffffc020303e:	cbe60613          	addi	a2,a2,-834 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203042:	06700593          	li	a1,103
ffffffffc0203046:	00003517          	auipc	a0,0x3
ffffffffc020304a:	83250513          	addi	a0,a0,-1998 # ffffffffc0205878 <commands+0x13f0>
ffffffffc020304e:	8b6fd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203052 <swap_in>:
{
ffffffffc0203052:	7179                	addi	sp,sp,-48
ffffffffc0203054:	e84a                	sd	s2,16(sp)
ffffffffc0203056:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203058:	4505                	li	a0,1
{
ffffffffc020305a:	ec26                	sd	s1,24(sp)
ffffffffc020305c:	e44e                	sd	s3,8(sp)
ffffffffc020305e:	f406                	sd	ra,40(sp)
ffffffffc0203060:	f022                	sd	s0,32(sp)
ffffffffc0203062:	84ae                	mv	s1,a1
ffffffffc0203064:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203066:	eb7fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
     assert(result!=NULL);
ffffffffc020306a:	c129                	beqz	a0,ffffffffc02030ac <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020306c:	842a                	mv	s0,a0
ffffffffc020306e:	01893503          	ld	a0,24(s2)
ffffffffc0203072:	4601                	li	a2,0
ffffffffc0203074:	85a6                	mv	a1,s1
ffffffffc0203076:	fb5fd0ef          	jal	ra,ffffffffc020102a <get_pte>
ffffffffc020307a:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020307c:	6108                	ld	a0,0(a0)
ffffffffc020307e:	85a2                	mv	a1,s0
ffffffffc0203080:	3f7000ef          	jal	ra,ffffffffc0203c76 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203084:	00093583          	ld	a1,0(s2)
ffffffffc0203088:	8626                	mv	a2,s1
ffffffffc020308a:	00003517          	auipc	a0,0x3
ffffffffc020308e:	b2650513          	addi	a0,a0,-1242 # ffffffffc0205bb0 <commands+0x1728>
ffffffffc0203092:	81a1                	srli	a1,a1,0x8
ffffffffc0203094:	82afd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203098:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020309a:	0089b023          	sd	s0,0(s3)
}
ffffffffc020309e:	7402                	ld	s0,32(sp)
ffffffffc02030a0:	64e2                	ld	s1,24(sp)
ffffffffc02030a2:	6942                	ld	s2,16(sp)
ffffffffc02030a4:	69a2                	ld	s3,8(sp)
ffffffffc02030a6:	4501                	li	a0,0
ffffffffc02030a8:	6145                	addi	sp,sp,48
ffffffffc02030aa:	8082                	ret
     assert(result!=NULL);
ffffffffc02030ac:	00003697          	auipc	a3,0x3
ffffffffc02030b0:	af468693          	addi	a3,a3,-1292 # ffffffffc0205ba0 <commands+0x1718>
ffffffffc02030b4:	00002617          	auipc	a2,0x2
ffffffffc02030b8:	c4460613          	addi	a2,a2,-956 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02030bc:	07d00593          	li	a1,125
ffffffffc02030c0:	00002517          	auipc	a0,0x2
ffffffffc02030c4:	7b850513          	addi	a0,a0,1976 # ffffffffc0205878 <commands+0x13f0>
ffffffffc02030c8:	83cfd0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02030cc <default_init>:
ffffffffc02030cc:	0000e797          	auipc	a5,0xe
ffffffffc02030d0:	4bc78793          	addi	a5,a5,1212 # ffffffffc0211588 <free_area>
ffffffffc02030d4:	e79c                	sd	a5,8(a5)
ffffffffc02030d6:	e39c                	sd	a5,0(a5)
ffffffffc02030d8:	0007a823          	sw	zero,16(a5)
ffffffffc02030dc:	8082                	ret

ffffffffc02030de <default_nr_free_pages>:
ffffffffc02030de:	0000e517          	auipc	a0,0xe
ffffffffc02030e2:	4ba56503          	lwu	a0,1210(a0) # ffffffffc0211598 <free_area+0x10>
ffffffffc02030e6:	8082                	ret

ffffffffc02030e8 <default_check>:
ffffffffc02030e8:	715d                	addi	sp,sp,-80
ffffffffc02030ea:	f84a                	sd	s2,48(sp)
ffffffffc02030ec:	0000e917          	auipc	s2,0xe
ffffffffc02030f0:	49c90913          	addi	s2,s2,1180 # ffffffffc0211588 <free_area>
ffffffffc02030f4:	00893783          	ld	a5,8(s2)
ffffffffc02030f8:	e486                	sd	ra,72(sp)
ffffffffc02030fa:	e0a2                	sd	s0,64(sp)
ffffffffc02030fc:	fc26                	sd	s1,56(sp)
ffffffffc02030fe:	f44e                	sd	s3,40(sp)
ffffffffc0203100:	f052                	sd	s4,32(sp)
ffffffffc0203102:	ec56                	sd	s5,24(sp)
ffffffffc0203104:	e85a                	sd	s6,16(sp)
ffffffffc0203106:	e45e                	sd	s7,8(sp)
ffffffffc0203108:	e062                	sd	s8,0(sp)
ffffffffc020310a:	31278f63          	beq	a5,s2,ffffffffc0203428 <default_check+0x340>
ffffffffc020310e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203112:	8305                	srli	a4,a4,0x1
ffffffffc0203114:	8b05                	andi	a4,a4,1
ffffffffc0203116:	30070d63          	beqz	a4,ffffffffc0203430 <default_check+0x348>
ffffffffc020311a:	4401                	li	s0,0
ffffffffc020311c:	4481                	li	s1,0
ffffffffc020311e:	a031                	j	ffffffffc020312a <default_check+0x42>
ffffffffc0203120:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203124:	8b09                	andi	a4,a4,2
ffffffffc0203126:	30070563          	beqz	a4,ffffffffc0203430 <default_check+0x348>
ffffffffc020312a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020312e:	679c                	ld	a5,8(a5)
ffffffffc0203130:	2485                	addiw	s1,s1,1
ffffffffc0203132:	9c39                	addw	s0,s0,a4
ffffffffc0203134:	ff2796e3          	bne	a5,s2,ffffffffc0203120 <default_check+0x38>
ffffffffc0203138:	89a2                	mv	s3,s0
ffffffffc020313a:	eb1fd0ef          	jal	ra,ffffffffc0200fea <nr_free_pages>
ffffffffc020313e:	75351963          	bne	a0,s3,ffffffffc0203890 <default_check+0x7a8>
ffffffffc0203142:	4505                	li	a0,1
ffffffffc0203144:	dd9fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203148:	8a2a                	mv	s4,a0
ffffffffc020314a:	48050363          	beqz	a0,ffffffffc02035d0 <default_check+0x4e8>
ffffffffc020314e:	4505                	li	a0,1
ffffffffc0203150:	dcdfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203154:	89aa                	mv	s3,a0
ffffffffc0203156:	74050d63          	beqz	a0,ffffffffc02038b0 <default_check+0x7c8>
ffffffffc020315a:	4505                	li	a0,1
ffffffffc020315c:	dc1fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203160:	8aaa                	mv	s5,a0
ffffffffc0203162:	4e050763          	beqz	a0,ffffffffc0203650 <default_check+0x568>
ffffffffc0203166:	2f3a0563          	beq	s4,s3,ffffffffc0203450 <default_check+0x368>
ffffffffc020316a:	2eaa0363          	beq	s4,a0,ffffffffc0203450 <default_check+0x368>
ffffffffc020316e:	2ea98163          	beq	s3,a0,ffffffffc0203450 <default_check+0x368>
ffffffffc0203172:	000a2783          	lw	a5,0(s4)
ffffffffc0203176:	2e079d63          	bnez	a5,ffffffffc0203470 <default_check+0x388>
ffffffffc020317a:	0009a783          	lw	a5,0(s3)
ffffffffc020317e:	2e079963          	bnez	a5,ffffffffc0203470 <default_check+0x388>
ffffffffc0203182:	411c                	lw	a5,0(a0)
ffffffffc0203184:	2e079663          	bnez	a5,ffffffffc0203470 <default_check+0x388>
ffffffffc0203188:	0000e797          	auipc	a5,0xe
ffffffffc020318c:	32878793          	addi	a5,a5,808 # ffffffffc02114b0 <pages>
ffffffffc0203190:	639c                	ld	a5,0(a5)
ffffffffc0203192:	00002717          	auipc	a4,0x2
ffffffffc0203196:	d2670713          	addi	a4,a4,-730 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc020319a:	630c                	ld	a1,0(a4)
ffffffffc020319c:	40fa0733          	sub	a4,s4,a5
ffffffffc02031a0:	870d                	srai	a4,a4,0x3
ffffffffc02031a2:	02b70733          	mul	a4,a4,a1
ffffffffc02031a6:	00003697          	auipc	a3,0x3
ffffffffc02031aa:	08a68693          	addi	a3,a3,138 # ffffffffc0206230 <nbase>
ffffffffc02031ae:	6290                	ld	a2,0(a3)
ffffffffc02031b0:	0000e697          	auipc	a3,0xe
ffffffffc02031b4:	2b068693          	addi	a3,a3,688 # ffffffffc0211460 <npage>
ffffffffc02031b8:	6294                	ld	a3,0(a3)
ffffffffc02031ba:	06b2                	slli	a3,a3,0xc
ffffffffc02031bc:	9732                	add	a4,a4,a2
ffffffffc02031be:	0732                	slli	a4,a4,0xc
ffffffffc02031c0:	2cd77863          	bgeu	a4,a3,ffffffffc0203490 <default_check+0x3a8>
ffffffffc02031c4:	40f98733          	sub	a4,s3,a5
ffffffffc02031c8:	870d                	srai	a4,a4,0x3
ffffffffc02031ca:	02b70733          	mul	a4,a4,a1
ffffffffc02031ce:	9732                	add	a4,a4,a2
ffffffffc02031d0:	0732                	slli	a4,a4,0xc
ffffffffc02031d2:	4ed77f63          	bgeu	a4,a3,ffffffffc02036d0 <default_check+0x5e8>
ffffffffc02031d6:	40f507b3          	sub	a5,a0,a5
ffffffffc02031da:	878d                	srai	a5,a5,0x3
ffffffffc02031dc:	02b787b3          	mul	a5,a5,a1
ffffffffc02031e0:	97b2                	add	a5,a5,a2
ffffffffc02031e2:	07b2                	slli	a5,a5,0xc
ffffffffc02031e4:	34d7f663          	bgeu	a5,a3,ffffffffc0203530 <default_check+0x448>
ffffffffc02031e8:	4505                	li	a0,1
ffffffffc02031ea:	00093c03          	ld	s8,0(s2)
ffffffffc02031ee:	00893b83          	ld	s7,8(s2)
ffffffffc02031f2:	01092b03          	lw	s6,16(s2)
ffffffffc02031f6:	0000e797          	auipc	a5,0xe
ffffffffc02031fa:	3927bd23          	sd	s2,922(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc02031fe:	0000e797          	auipc	a5,0xe
ffffffffc0203202:	3927b523          	sd	s2,906(a5) # ffffffffc0211588 <free_area>
ffffffffc0203206:	0000e797          	auipc	a5,0xe
ffffffffc020320a:	3807a923          	sw	zero,914(a5) # ffffffffc0211598 <free_area+0x10>
ffffffffc020320e:	d0ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203212:	2e051f63          	bnez	a0,ffffffffc0203510 <default_check+0x428>
ffffffffc0203216:	4585                	li	a1,1
ffffffffc0203218:	8552                	mv	a0,s4
ffffffffc020321a:	d8bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020321e:	4585                	li	a1,1
ffffffffc0203220:	854e                	mv	a0,s3
ffffffffc0203222:	d83fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0203226:	4585                	li	a1,1
ffffffffc0203228:	8556                	mv	a0,s5
ffffffffc020322a:	d7bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020322e:	01092703          	lw	a4,16(s2)
ffffffffc0203232:	478d                	li	a5,3
ffffffffc0203234:	2af71e63          	bne	a4,a5,ffffffffc02034f0 <default_check+0x408>
ffffffffc0203238:	4505                	li	a0,1
ffffffffc020323a:	ce3fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020323e:	89aa                	mv	s3,a0
ffffffffc0203240:	28050863          	beqz	a0,ffffffffc02034d0 <default_check+0x3e8>
ffffffffc0203244:	4505                	li	a0,1
ffffffffc0203246:	cd7fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020324a:	8aaa                	mv	s5,a0
ffffffffc020324c:	3e050263          	beqz	a0,ffffffffc0203630 <default_check+0x548>
ffffffffc0203250:	4505                	li	a0,1
ffffffffc0203252:	ccbfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203256:	8a2a                	mv	s4,a0
ffffffffc0203258:	3a050c63          	beqz	a0,ffffffffc0203610 <default_check+0x528>
ffffffffc020325c:	4505                	li	a0,1
ffffffffc020325e:	cbffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203262:	38051763          	bnez	a0,ffffffffc02035f0 <default_check+0x508>
ffffffffc0203266:	4585                	li	a1,1
ffffffffc0203268:	854e                	mv	a0,s3
ffffffffc020326a:	d3bfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020326e:	00893783          	ld	a5,8(s2)
ffffffffc0203272:	23278f63          	beq	a5,s2,ffffffffc02034b0 <default_check+0x3c8>
ffffffffc0203276:	4505                	li	a0,1
ffffffffc0203278:	ca5fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc020327c:	32a99a63          	bne	s3,a0,ffffffffc02035b0 <default_check+0x4c8>
ffffffffc0203280:	4505                	li	a0,1
ffffffffc0203282:	c9bfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203286:	30051563          	bnez	a0,ffffffffc0203590 <default_check+0x4a8>
ffffffffc020328a:	01092783          	lw	a5,16(s2)
ffffffffc020328e:	2e079163          	bnez	a5,ffffffffc0203570 <default_check+0x488>
ffffffffc0203292:	854e                	mv	a0,s3
ffffffffc0203294:	4585                	li	a1,1
ffffffffc0203296:	0000e797          	auipc	a5,0xe
ffffffffc020329a:	2f87b923          	sd	s8,754(a5) # ffffffffc0211588 <free_area>
ffffffffc020329e:	0000e797          	auipc	a5,0xe
ffffffffc02032a2:	2f77b923          	sd	s7,754(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc02032a6:	0000e797          	auipc	a5,0xe
ffffffffc02032aa:	2f67a923          	sw	s6,754(a5) # ffffffffc0211598 <free_area+0x10>
ffffffffc02032ae:	cf7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02032b2:	4585                	li	a1,1
ffffffffc02032b4:	8556                	mv	a0,s5
ffffffffc02032b6:	ceffd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02032ba:	4585                	li	a1,1
ffffffffc02032bc:	8552                	mv	a0,s4
ffffffffc02032be:	ce7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02032c2:	4515                	li	a0,5
ffffffffc02032c4:	c59fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02032c8:	89aa                	mv	s3,a0
ffffffffc02032ca:	28050363          	beqz	a0,ffffffffc0203550 <default_check+0x468>
ffffffffc02032ce:	651c                	ld	a5,8(a0)
ffffffffc02032d0:	8385                	srli	a5,a5,0x1
ffffffffc02032d2:	8b85                	andi	a5,a5,1
ffffffffc02032d4:	54079e63          	bnez	a5,ffffffffc0203830 <default_check+0x748>
ffffffffc02032d8:	4505                	li	a0,1
ffffffffc02032da:	00093b03          	ld	s6,0(s2)
ffffffffc02032de:	00893a83          	ld	s5,8(s2)
ffffffffc02032e2:	0000e797          	auipc	a5,0xe
ffffffffc02032e6:	2b27b323          	sd	s2,678(a5) # ffffffffc0211588 <free_area>
ffffffffc02032ea:	0000e797          	auipc	a5,0xe
ffffffffc02032ee:	2b27b323          	sd	s2,678(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc02032f2:	c2bfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02032f6:	50051d63          	bnez	a0,ffffffffc0203810 <default_check+0x728>
ffffffffc02032fa:	09098a13          	addi	s4,s3,144
ffffffffc02032fe:	8552                	mv	a0,s4
ffffffffc0203300:	458d                	li	a1,3
ffffffffc0203302:	01092b83          	lw	s7,16(s2)
ffffffffc0203306:	0000e797          	auipc	a5,0xe
ffffffffc020330a:	2807a923          	sw	zero,658(a5) # ffffffffc0211598 <free_area+0x10>
ffffffffc020330e:	c97fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0203312:	4511                	li	a0,4
ffffffffc0203314:	c09fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203318:	4c051c63          	bnez	a0,ffffffffc02037f0 <default_check+0x708>
ffffffffc020331c:	0989b783          	ld	a5,152(s3)
ffffffffc0203320:	8385                	srli	a5,a5,0x1
ffffffffc0203322:	8b85                	andi	a5,a5,1
ffffffffc0203324:	4a078663          	beqz	a5,ffffffffc02037d0 <default_check+0x6e8>
ffffffffc0203328:	0a89a703          	lw	a4,168(s3)
ffffffffc020332c:	478d                	li	a5,3
ffffffffc020332e:	4af71163          	bne	a4,a5,ffffffffc02037d0 <default_check+0x6e8>
ffffffffc0203332:	450d                	li	a0,3
ffffffffc0203334:	be9fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203338:	8c2a                	mv	s8,a0
ffffffffc020333a:	46050b63          	beqz	a0,ffffffffc02037b0 <default_check+0x6c8>
ffffffffc020333e:	4505                	li	a0,1
ffffffffc0203340:	bddfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203344:	44051663          	bnez	a0,ffffffffc0203790 <default_check+0x6a8>
ffffffffc0203348:	438a1463          	bne	s4,s8,ffffffffc0203770 <default_check+0x688>
ffffffffc020334c:	4585                	li	a1,1
ffffffffc020334e:	854e                	mv	a0,s3
ffffffffc0203350:	c55fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc0203354:	458d                	li	a1,3
ffffffffc0203356:	8552                	mv	a0,s4
ffffffffc0203358:	c4dfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020335c:	0089b783          	ld	a5,8(s3)
ffffffffc0203360:	04898c13          	addi	s8,s3,72
ffffffffc0203364:	8385                	srli	a5,a5,0x1
ffffffffc0203366:	8b85                	andi	a5,a5,1
ffffffffc0203368:	3e078463          	beqz	a5,ffffffffc0203750 <default_check+0x668>
ffffffffc020336c:	0189a703          	lw	a4,24(s3)
ffffffffc0203370:	4785                	li	a5,1
ffffffffc0203372:	3cf71f63          	bne	a4,a5,ffffffffc0203750 <default_check+0x668>
ffffffffc0203376:	008a3783          	ld	a5,8(s4)
ffffffffc020337a:	8385                	srli	a5,a5,0x1
ffffffffc020337c:	8b85                	andi	a5,a5,1
ffffffffc020337e:	3a078963          	beqz	a5,ffffffffc0203730 <default_check+0x648>
ffffffffc0203382:	018a2703          	lw	a4,24(s4)
ffffffffc0203386:	478d                	li	a5,3
ffffffffc0203388:	3af71463          	bne	a4,a5,ffffffffc0203730 <default_check+0x648>
ffffffffc020338c:	4505                	li	a0,1
ffffffffc020338e:	b8ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc0203392:	36a99f63          	bne	s3,a0,ffffffffc0203710 <default_check+0x628>
ffffffffc0203396:	4585                	li	a1,1
ffffffffc0203398:	c0dfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc020339c:	4509                	li	a0,2
ffffffffc020339e:	b7ffd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02033a2:	34aa1763          	bne	s4,a0,ffffffffc02036f0 <default_check+0x608>
ffffffffc02033a6:	4589                	li	a1,2
ffffffffc02033a8:	bfdfd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02033ac:	4585                	li	a1,1
ffffffffc02033ae:	8562                	mv	a0,s8
ffffffffc02033b0:	bf5fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02033b4:	4515                	li	a0,5
ffffffffc02033b6:	b67fd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02033ba:	89aa                	mv	s3,a0
ffffffffc02033bc:	48050a63          	beqz	a0,ffffffffc0203850 <default_check+0x768>
ffffffffc02033c0:	4505                	li	a0,1
ffffffffc02033c2:	b5bfd0ef          	jal	ra,ffffffffc0200f1c <alloc_pages>
ffffffffc02033c6:	2e051563          	bnez	a0,ffffffffc02036b0 <default_check+0x5c8>
ffffffffc02033ca:	01092783          	lw	a5,16(s2)
ffffffffc02033ce:	2c079163          	bnez	a5,ffffffffc0203690 <default_check+0x5a8>
ffffffffc02033d2:	4595                	li	a1,5
ffffffffc02033d4:	854e                	mv	a0,s3
ffffffffc02033d6:	0000e797          	auipc	a5,0xe
ffffffffc02033da:	1d77a123          	sw	s7,450(a5) # ffffffffc0211598 <free_area+0x10>
ffffffffc02033de:	0000e797          	auipc	a5,0xe
ffffffffc02033e2:	1b67b523          	sd	s6,426(a5) # ffffffffc0211588 <free_area>
ffffffffc02033e6:	0000e797          	auipc	a5,0xe
ffffffffc02033ea:	1b57b523          	sd	s5,426(a5) # ffffffffc0211590 <free_area+0x8>
ffffffffc02033ee:	bb7fd0ef          	jal	ra,ffffffffc0200fa4 <free_pages>
ffffffffc02033f2:	00893783          	ld	a5,8(s2)
ffffffffc02033f6:	01278963          	beq	a5,s2,ffffffffc0203408 <default_check+0x320>
ffffffffc02033fa:	ff87a703          	lw	a4,-8(a5)
ffffffffc02033fe:	679c                	ld	a5,8(a5)
ffffffffc0203400:	34fd                	addiw	s1,s1,-1
ffffffffc0203402:	9c19                	subw	s0,s0,a4
ffffffffc0203404:	ff279be3          	bne	a5,s2,ffffffffc02033fa <default_check+0x312>
ffffffffc0203408:	26049463          	bnez	s1,ffffffffc0203670 <default_check+0x588>
ffffffffc020340c:	46041263          	bnez	s0,ffffffffc0203870 <default_check+0x788>
ffffffffc0203410:	60a6                	ld	ra,72(sp)
ffffffffc0203412:	6406                	ld	s0,64(sp)
ffffffffc0203414:	74e2                	ld	s1,56(sp)
ffffffffc0203416:	7942                	ld	s2,48(sp)
ffffffffc0203418:	79a2                	ld	s3,40(sp)
ffffffffc020341a:	7a02                	ld	s4,32(sp)
ffffffffc020341c:	6ae2                	ld	s5,24(sp)
ffffffffc020341e:	6b42                	ld	s6,16(sp)
ffffffffc0203420:	6ba2                	ld	s7,8(sp)
ffffffffc0203422:	6c02                	ld	s8,0(sp)
ffffffffc0203424:	6161                	addi	sp,sp,80
ffffffffc0203426:	8082                	ret
ffffffffc0203428:	4981                	li	s3,0
ffffffffc020342a:	4401                	li	s0,0
ffffffffc020342c:	4481                	li	s1,0
ffffffffc020342e:	b331                	j	ffffffffc020313a <default_check+0x52>
ffffffffc0203430:	00002697          	auipc	a3,0x2
ffffffffc0203434:	47068693          	addi	a3,a3,1136 # ffffffffc02058a0 <commands+0x1418>
ffffffffc0203438:	00002617          	auipc	a2,0x2
ffffffffc020343c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203440:	0f000593          	li	a1,240
ffffffffc0203444:	00002517          	auipc	a0,0x2
ffffffffc0203448:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020344c:	cb9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203450:	00003697          	auipc	a3,0x3
ffffffffc0203454:	81868693          	addi	a3,a3,-2024 # ffffffffc0205c68 <commands+0x17e0>
ffffffffc0203458:	00002617          	auipc	a2,0x2
ffffffffc020345c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203460:	0bd00593          	li	a1,189
ffffffffc0203464:	00002517          	auipc	a0,0x2
ffffffffc0203468:	78c50513          	addi	a0,a0,1932 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020346c:	c99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203470:	00003697          	auipc	a3,0x3
ffffffffc0203474:	82068693          	addi	a3,a3,-2016 # ffffffffc0205c90 <commands+0x1808>
ffffffffc0203478:	00002617          	auipc	a2,0x2
ffffffffc020347c:	88060613          	addi	a2,a2,-1920 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203480:	0be00593          	li	a1,190
ffffffffc0203484:	00002517          	auipc	a0,0x2
ffffffffc0203488:	76c50513          	addi	a0,a0,1900 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020348c:	c79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203490:	00003697          	auipc	a3,0x3
ffffffffc0203494:	84068693          	addi	a3,a3,-1984 # ffffffffc0205cd0 <commands+0x1848>
ffffffffc0203498:	00002617          	auipc	a2,0x2
ffffffffc020349c:	86060613          	addi	a2,a2,-1952 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02034a0:	0c000593          	li	a1,192
ffffffffc02034a4:	00002517          	auipc	a0,0x2
ffffffffc02034a8:	74c50513          	addi	a0,a0,1868 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02034ac:	c59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02034b0:	00003697          	auipc	a3,0x3
ffffffffc02034b4:	8a868693          	addi	a3,a3,-1880 # ffffffffc0205d58 <commands+0x18d0>
ffffffffc02034b8:	00002617          	auipc	a2,0x2
ffffffffc02034bc:	84060613          	addi	a2,a2,-1984 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02034c0:	0d900593          	li	a1,217
ffffffffc02034c4:	00002517          	auipc	a0,0x2
ffffffffc02034c8:	72c50513          	addi	a0,a0,1836 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02034cc:	c39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02034d0:	00002697          	auipc	a3,0x2
ffffffffc02034d4:	73868693          	addi	a3,a3,1848 # ffffffffc0205c08 <commands+0x1780>
ffffffffc02034d8:	00002617          	auipc	a2,0x2
ffffffffc02034dc:	82060613          	addi	a2,a2,-2016 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02034e0:	0d200593          	li	a1,210
ffffffffc02034e4:	00002517          	auipc	a0,0x2
ffffffffc02034e8:	70c50513          	addi	a0,a0,1804 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02034ec:	c19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02034f0:	00003697          	auipc	a3,0x3
ffffffffc02034f4:	85868693          	addi	a3,a3,-1960 # ffffffffc0205d48 <commands+0x18c0>
ffffffffc02034f8:	00002617          	auipc	a2,0x2
ffffffffc02034fc:	80060613          	addi	a2,a2,-2048 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203500:	0d000593          	li	a1,208
ffffffffc0203504:	00002517          	auipc	a0,0x2
ffffffffc0203508:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020350c:	bf9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203510:	00003697          	auipc	a3,0x3
ffffffffc0203514:	82068693          	addi	a3,a3,-2016 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc0203518:	00001617          	auipc	a2,0x1
ffffffffc020351c:	7e060613          	addi	a2,a2,2016 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203520:	0cb00593          	li	a1,203
ffffffffc0203524:	00002517          	auipc	a0,0x2
ffffffffc0203528:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020352c:	bd9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203530:	00002697          	auipc	a3,0x2
ffffffffc0203534:	7e068693          	addi	a3,a3,2016 # ffffffffc0205d10 <commands+0x1888>
ffffffffc0203538:	00001617          	auipc	a2,0x1
ffffffffc020353c:	7c060613          	addi	a2,a2,1984 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203540:	0c200593          	li	a1,194
ffffffffc0203544:	00002517          	auipc	a0,0x2
ffffffffc0203548:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020354c:	bb9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203550:	00003697          	auipc	a3,0x3
ffffffffc0203554:	84068693          	addi	a3,a3,-1984 # ffffffffc0205d90 <commands+0x1908>
ffffffffc0203558:	00001617          	auipc	a2,0x1
ffffffffc020355c:	7a060613          	addi	a2,a2,1952 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203560:	0f800593          	li	a1,248
ffffffffc0203564:	00002517          	auipc	a0,0x2
ffffffffc0203568:	68c50513          	addi	a0,a0,1676 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020356c:	b99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203570:	00002697          	auipc	a3,0x2
ffffffffc0203574:	4d068693          	addi	a3,a3,1232 # ffffffffc0205a40 <commands+0x15b8>
ffffffffc0203578:	00001617          	auipc	a2,0x1
ffffffffc020357c:	78060613          	addi	a2,a2,1920 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203580:	0df00593          	li	a1,223
ffffffffc0203584:	00002517          	auipc	a0,0x2
ffffffffc0203588:	66c50513          	addi	a0,a0,1644 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020358c:	b79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203590:	00002697          	auipc	a3,0x2
ffffffffc0203594:	7a068693          	addi	a3,a3,1952 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc0203598:	00001617          	auipc	a2,0x1
ffffffffc020359c:	76060613          	addi	a2,a2,1888 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02035a0:	0dd00593          	li	a1,221
ffffffffc02035a4:	00002517          	auipc	a0,0x2
ffffffffc02035a8:	64c50513          	addi	a0,a0,1612 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02035ac:	b59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02035b0:	00002697          	auipc	a3,0x2
ffffffffc02035b4:	7c068693          	addi	a3,a3,1984 # ffffffffc0205d70 <commands+0x18e8>
ffffffffc02035b8:	00001617          	auipc	a2,0x1
ffffffffc02035bc:	74060613          	addi	a2,a2,1856 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02035c0:	0dc00593          	li	a1,220
ffffffffc02035c4:	00002517          	auipc	a0,0x2
ffffffffc02035c8:	62c50513          	addi	a0,a0,1580 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02035cc:	b39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02035d0:	00002697          	auipc	a3,0x2
ffffffffc02035d4:	63868693          	addi	a3,a3,1592 # ffffffffc0205c08 <commands+0x1780>
ffffffffc02035d8:	00001617          	auipc	a2,0x1
ffffffffc02035dc:	72060613          	addi	a2,a2,1824 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02035e0:	0b900593          	li	a1,185
ffffffffc02035e4:	00002517          	auipc	a0,0x2
ffffffffc02035e8:	60c50513          	addi	a0,a0,1548 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02035ec:	b19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02035f0:	00002697          	auipc	a3,0x2
ffffffffc02035f4:	74068693          	addi	a3,a3,1856 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc02035f8:	00001617          	auipc	a2,0x1
ffffffffc02035fc:	70060613          	addi	a2,a2,1792 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203600:	0d600593          	li	a1,214
ffffffffc0203604:	00002517          	auipc	a0,0x2
ffffffffc0203608:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020360c:	af9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203610:	00002697          	auipc	a3,0x2
ffffffffc0203614:	63868693          	addi	a3,a3,1592 # ffffffffc0205c48 <commands+0x17c0>
ffffffffc0203618:	00001617          	auipc	a2,0x1
ffffffffc020361c:	6e060613          	addi	a2,a2,1760 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203620:	0d400593          	li	a1,212
ffffffffc0203624:	00002517          	auipc	a0,0x2
ffffffffc0203628:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020362c:	ad9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203630:	00002697          	auipc	a3,0x2
ffffffffc0203634:	5f868693          	addi	a3,a3,1528 # ffffffffc0205c28 <commands+0x17a0>
ffffffffc0203638:	00001617          	auipc	a2,0x1
ffffffffc020363c:	6c060613          	addi	a2,a2,1728 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203640:	0d300593          	li	a1,211
ffffffffc0203644:	00002517          	auipc	a0,0x2
ffffffffc0203648:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020364c:	ab9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203650:	00002697          	auipc	a3,0x2
ffffffffc0203654:	5f868693          	addi	a3,a3,1528 # ffffffffc0205c48 <commands+0x17c0>
ffffffffc0203658:	00001617          	auipc	a2,0x1
ffffffffc020365c:	6a060613          	addi	a2,a2,1696 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203660:	0bb00593          	li	a1,187
ffffffffc0203664:	00002517          	auipc	a0,0x2
ffffffffc0203668:	58c50513          	addi	a0,a0,1420 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020366c:	a99fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203670:	00003697          	auipc	a3,0x3
ffffffffc0203674:	87068693          	addi	a3,a3,-1936 # ffffffffc0205ee0 <commands+0x1a58>
ffffffffc0203678:	00001617          	auipc	a2,0x1
ffffffffc020367c:	68060613          	addi	a2,a2,1664 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203680:	12500593          	li	a1,293
ffffffffc0203684:	00002517          	auipc	a0,0x2
ffffffffc0203688:	56c50513          	addi	a0,a0,1388 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020368c:	a79fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203690:	00002697          	auipc	a3,0x2
ffffffffc0203694:	3b068693          	addi	a3,a3,944 # ffffffffc0205a40 <commands+0x15b8>
ffffffffc0203698:	00001617          	auipc	a2,0x1
ffffffffc020369c:	66060613          	addi	a2,a2,1632 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02036a0:	11a00593          	li	a1,282
ffffffffc02036a4:	00002517          	auipc	a0,0x2
ffffffffc02036a8:	54c50513          	addi	a0,a0,1356 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02036ac:	a59fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02036b0:	00002697          	auipc	a3,0x2
ffffffffc02036b4:	68068693          	addi	a3,a3,1664 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc02036b8:	00001617          	auipc	a2,0x1
ffffffffc02036bc:	64060613          	addi	a2,a2,1600 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02036c0:	11800593          	li	a1,280
ffffffffc02036c4:	00002517          	auipc	a0,0x2
ffffffffc02036c8:	52c50513          	addi	a0,a0,1324 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02036cc:	a39fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02036d0:	00002697          	auipc	a3,0x2
ffffffffc02036d4:	62068693          	addi	a3,a3,1568 # ffffffffc0205cf0 <commands+0x1868>
ffffffffc02036d8:	00001617          	auipc	a2,0x1
ffffffffc02036dc:	62060613          	addi	a2,a2,1568 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02036e0:	0c100593          	li	a1,193
ffffffffc02036e4:	00002517          	auipc	a0,0x2
ffffffffc02036e8:	50c50513          	addi	a0,a0,1292 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02036ec:	a19fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02036f0:	00002697          	auipc	a3,0x2
ffffffffc02036f4:	7b068693          	addi	a3,a3,1968 # ffffffffc0205ea0 <commands+0x1a18>
ffffffffc02036f8:	00001617          	auipc	a2,0x1
ffffffffc02036fc:	60060613          	addi	a2,a2,1536 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203700:	11200593          	li	a1,274
ffffffffc0203704:	00002517          	auipc	a0,0x2
ffffffffc0203708:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020370c:	9f9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203710:	00002697          	auipc	a3,0x2
ffffffffc0203714:	77068693          	addi	a3,a3,1904 # ffffffffc0205e80 <commands+0x19f8>
ffffffffc0203718:	00001617          	auipc	a2,0x1
ffffffffc020371c:	5e060613          	addi	a2,a2,1504 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203720:	11000593          	li	a1,272
ffffffffc0203724:	00002517          	auipc	a0,0x2
ffffffffc0203728:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020372c:	9d9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203730:	00002697          	auipc	a3,0x2
ffffffffc0203734:	72868693          	addi	a3,a3,1832 # ffffffffc0205e58 <commands+0x19d0>
ffffffffc0203738:	00001617          	auipc	a2,0x1
ffffffffc020373c:	5c060613          	addi	a2,a2,1472 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203740:	10e00593          	li	a1,270
ffffffffc0203744:	00002517          	auipc	a0,0x2
ffffffffc0203748:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020374c:	9b9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203750:	00002697          	auipc	a3,0x2
ffffffffc0203754:	6e068693          	addi	a3,a3,1760 # ffffffffc0205e30 <commands+0x19a8>
ffffffffc0203758:	00001617          	auipc	a2,0x1
ffffffffc020375c:	5a060613          	addi	a2,a2,1440 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203760:	10d00593          	li	a1,269
ffffffffc0203764:	00002517          	auipc	a0,0x2
ffffffffc0203768:	48c50513          	addi	a0,a0,1164 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020376c:	999fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203770:	00002697          	auipc	a3,0x2
ffffffffc0203774:	6b068693          	addi	a3,a3,1712 # ffffffffc0205e20 <commands+0x1998>
ffffffffc0203778:	00001617          	auipc	a2,0x1
ffffffffc020377c:	58060613          	addi	a2,a2,1408 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203780:	10800593          	li	a1,264
ffffffffc0203784:	00002517          	auipc	a0,0x2
ffffffffc0203788:	46c50513          	addi	a0,a0,1132 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020378c:	979fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203790:	00002697          	auipc	a3,0x2
ffffffffc0203794:	5a068693          	addi	a3,a3,1440 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc0203798:	00001617          	auipc	a2,0x1
ffffffffc020379c:	56060613          	addi	a2,a2,1376 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02037a0:	10700593          	li	a1,263
ffffffffc02037a4:	00002517          	auipc	a0,0x2
ffffffffc02037a8:	44c50513          	addi	a0,a0,1100 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02037ac:	959fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02037b0:	00002697          	auipc	a3,0x2
ffffffffc02037b4:	65068693          	addi	a3,a3,1616 # ffffffffc0205e00 <commands+0x1978>
ffffffffc02037b8:	00001617          	auipc	a2,0x1
ffffffffc02037bc:	54060613          	addi	a2,a2,1344 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02037c0:	10600593          	li	a1,262
ffffffffc02037c4:	00002517          	auipc	a0,0x2
ffffffffc02037c8:	42c50513          	addi	a0,a0,1068 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02037cc:	939fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02037d0:	00002697          	auipc	a3,0x2
ffffffffc02037d4:	60068693          	addi	a3,a3,1536 # ffffffffc0205dd0 <commands+0x1948>
ffffffffc02037d8:	00001617          	auipc	a2,0x1
ffffffffc02037dc:	52060613          	addi	a2,a2,1312 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02037e0:	10500593          	li	a1,261
ffffffffc02037e4:	00002517          	auipc	a0,0x2
ffffffffc02037e8:	40c50513          	addi	a0,a0,1036 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02037ec:	919fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02037f0:	00002697          	auipc	a3,0x2
ffffffffc02037f4:	5c868693          	addi	a3,a3,1480 # ffffffffc0205db8 <commands+0x1930>
ffffffffc02037f8:	00001617          	auipc	a2,0x1
ffffffffc02037fc:	50060613          	addi	a2,a2,1280 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203800:	10400593          	li	a1,260
ffffffffc0203804:	00002517          	auipc	a0,0x2
ffffffffc0203808:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020380c:	8f9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203810:	00002697          	auipc	a3,0x2
ffffffffc0203814:	52068693          	addi	a3,a3,1312 # ffffffffc0205d30 <commands+0x18a8>
ffffffffc0203818:	00001617          	auipc	a2,0x1
ffffffffc020381c:	4e060613          	addi	a2,a2,1248 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203820:	0fe00593          	li	a1,254
ffffffffc0203824:	00002517          	auipc	a0,0x2
ffffffffc0203828:	3cc50513          	addi	a0,a0,972 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020382c:	8d9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203830:	00002697          	auipc	a3,0x2
ffffffffc0203834:	57068693          	addi	a3,a3,1392 # ffffffffc0205da0 <commands+0x1918>
ffffffffc0203838:	00001617          	auipc	a2,0x1
ffffffffc020383c:	4c060613          	addi	a2,a2,1216 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203840:	0f900593          	li	a1,249
ffffffffc0203844:	00002517          	auipc	a0,0x2
ffffffffc0203848:	3ac50513          	addi	a0,a0,940 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020384c:	8b9fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203850:	00002697          	auipc	a3,0x2
ffffffffc0203854:	67068693          	addi	a3,a3,1648 # ffffffffc0205ec0 <commands+0x1a38>
ffffffffc0203858:	00001617          	auipc	a2,0x1
ffffffffc020385c:	4a060613          	addi	a2,a2,1184 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203860:	11700593          	li	a1,279
ffffffffc0203864:	00002517          	auipc	a0,0x2
ffffffffc0203868:	38c50513          	addi	a0,a0,908 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020386c:	899fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203870:	00002697          	auipc	a3,0x2
ffffffffc0203874:	68068693          	addi	a3,a3,1664 # ffffffffc0205ef0 <commands+0x1a68>
ffffffffc0203878:	00001617          	auipc	a2,0x1
ffffffffc020387c:	48060613          	addi	a2,a2,1152 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203880:	12600593          	li	a1,294
ffffffffc0203884:	00002517          	auipc	a0,0x2
ffffffffc0203888:	36c50513          	addi	a0,a0,876 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc020388c:	879fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203890:	00002697          	auipc	a3,0x2
ffffffffc0203894:	02068693          	addi	a3,a3,32 # ffffffffc02058b0 <commands+0x1428>
ffffffffc0203898:	00001617          	auipc	a2,0x1
ffffffffc020389c:	46060613          	addi	a2,a2,1120 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02038a0:	0f300593          	li	a1,243
ffffffffc02038a4:	00002517          	auipc	a0,0x2
ffffffffc02038a8:	34c50513          	addi	a0,a0,844 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02038ac:	859fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc02038b0:	00002697          	auipc	a3,0x2
ffffffffc02038b4:	37868693          	addi	a3,a3,888 # ffffffffc0205c28 <commands+0x17a0>
ffffffffc02038b8:	00001617          	auipc	a2,0x1
ffffffffc02038bc:	44060613          	addi	a2,a2,1088 # ffffffffc0204cf8 <commands+0x870>
ffffffffc02038c0:	0ba00593          	li	a1,186
ffffffffc02038c4:	00002517          	auipc	a0,0x2
ffffffffc02038c8:	32c50513          	addi	a0,a0,812 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc02038cc:	839fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc02038d0 <default_free_pages>:
ffffffffc02038d0:	1141                	addi	sp,sp,-16
ffffffffc02038d2:	e406                	sd	ra,8(sp)
ffffffffc02038d4:	18058063          	beqz	a1,ffffffffc0203a54 <default_free_pages+0x184>
ffffffffc02038d8:	00359693          	slli	a3,a1,0x3
ffffffffc02038dc:	96ae                	add	a3,a3,a1
ffffffffc02038de:	068e                	slli	a3,a3,0x3
ffffffffc02038e0:	96aa                	add	a3,a3,a0
ffffffffc02038e2:	02d50d63          	beq	a0,a3,ffffffffc020391c <default_free_pages+0x4c>
ffffffffc02038e6:	651c                	ld	a5,8(a0)
ffffffffc02038e8:	8b85                	andi	a5,a5,1
ffffffffc02038ea:	14079563          	bnez	a5,ffffffffc0203a34 <default_free_pages+0x164>
ffffffffc02038ee:	651c                	ld	a5,8(a0)
ffffffffc02038f0:	8385                	srli	a5,a5,0x1
ffffffffc02038f2:	8b85                	andi	a5,a5,1
ffffffffc02038f4:	14079063          	bnez	a5,ffffffffc0203a34 <default_free_pages+0x164>
ffffffffc02038f8:	87aa                	mv	a5,a0
ffffffffc02038fa:	a809                	j	ffffffffc020390c <default_free_pages+0x3c>
ffffffffc02038fc:	6798                	ld	a4,8(a5)
ffffffffc02038fe:	8b05                	andi	a4,a4,1
ffffffffc0203900:	12071a63          	bnez	a4,ffffffffc0203a34 <default_free_pages+0x164>
ffffffffc0203904:	6798                	ld	a4,8(a5)
ffffffffc0203906:	8b09                	andi	a4,a4,2
ffffffffc0203908:	12071663          	bnez	a4,ffffffffc0203a34 <default_free_pages+0x164>
ffffffffc020390c:	0007b423          	sd	zero,8(a5)
ffffffffc0203910:	0007a023          	sw	zero,0(a5)
ffffffffc0203914:	04878793          	addi	a5,a5,72
ffffffffc0203918:	fed792e3          	bne	a5,a3,ffffffffc02038fc <default_free_pages+0x2c>
ffffffffc020391c:	2581                	sext.w	a1,a1
ffffffffc020391e:	cd0c                	sw	a1,24(a0)
ffffffffc0203920:	00850893          	addi	a7,a0,8
ffffffffc0203924:	4789                	li	a5,2
ffffffffc0203926:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc020392a:	0000e697          	auipc	a3,0xe
ffffffffc020392e:	c5e68693          	addi	a3,a3,-930 # ffffffffc0211588 <free_area>
ffffffffc0203932:	4a98                	lw	a4,16(a3)
ffffffffc0203934:	669c                	ld	a5,8(a3)
ffffffffc0203936:	9db9                	addw	a1,a1,a4
ffffffffc0203938:	0000e717          	auipc	a4,0xe
ffffffffc020393c:	c6b72023          	sw	a1,-928(a4) # ffffffffc0211598 <free_area+0x10>
ffffffffc0203940:	08d78f63          	beq	a5,a3,ffffffffc02039de <default_free_pages+0x10e>
ffffffffc0203944:	fe078713          	addi	a4,a5,-32
ffffffffc0203948:	628c                	ld	a1,0(a3)
ffffffffc020394a:	4801                	li	a6,0
ffffffffc020394c:	02050613          	addi	a2,a0,32
ffffffffc0203950:	00e56a63          	bltu	a0,a4,ffffffffc0203964 <default_free_pages+0x94>
ffffffffc0203954:	6798                	ld	a4,8(a5)
ffffffffc0203956:	02d70563          	beq	a4,a3,ffffffffc0203980 <default_free_pages+0xb0>
ffffffffc020395a:	87ba                	mv	a5,a4
ffffffffc020395c:	fe078713          	addi	a4,a5,-32
ffffffffc0203960:	fee57ae3          	bgeu	a0,a4,ffffffffc0203954 <default_free_pages+0x84>
ffffffffc0203964:	00080663          	beqz	a6,ffffffffc0203970 <default_free_pages+0xa0>
ffffffffc0203968:	0000e817          	auipc	a6,0xe
ffffffffc020396c:	c2b83023          	sd	a1,-992(a6) # ffffffffc0211588 <free_area>
ffffffffc0203970:	638c                	ld	a1,0(a5)
ffffffffc0203972:	e390                	sd	a2,0(a5)
ffffffffc0203974:	e590                	sd	a2,8(a1)
ffffffffc0203976:	f51c                	sd	a5,40(a0)
ffffffffc0203978:	f10c                	sd	a1,32(a0)
ffffffffc020397a:	02d59163          	bne	a1,a3,ffffffffc020399c <default_free_pages+0xcc>
ffffffffc020397e:	a091                	j	ffffffffc02039c2 <default_free_pages+0xf2>
ffffffffc0203980:	e790                	sd	a2,8(a5)
ffffffffc0203982:	f514                	sd	a3,40(a0)
ffffffffc0203984:	6798                	ld	a4,8(a5)
ffffffffc0203986:	f11c                	sd	a5,32(a0)
ffffffffc0203988:	85b2                	mv	a1,a2
ffffffffc020398a:	00d70563          	beq	a4,a3,ffffffffc0203994 <default_free_pages+0xc4>
ffffffffc020398e:	4805                	li	a6,1
ffffffffc0203990:	87ba                	mv	a5,a4
ffffffffc0203992:	b7e9                	j	ffffffffc020395c <default_free_pages+0x8c>
ffffffffc0203994:	e290                	sd	a2,0(a3)
ffffffffc0203996:	85be                	mv	a1,a5
ffffffffc0203998:	02d78163          	beq	a5,a3,ffffffffc02039ba <default_free_pages+0xea>
ffffffffc020399c:	ff85a803          	lw	a6,-8(a1) # ff8 <kern_entry-0xffffffffc01ff008>
ffffffffc02039a0:	fe058613          	addi	a2,a1,-32
ffffffffc02039a4:	02081713          	slli	a4,a6,0x20
ffffffffc02039a8:	9301                	srli	a4,a4,0x20
ffffffffc02039aa:	00371793          	slli	a5,a4,0x3
ffffffffc02039ae:	97ba                	add	a5,a5,a4
ffffffffc02039b0:	078e                	slli	a5,a5,0x3
ffffffffc02039b2:	97b2                	add	a5,a5,a2
ffffffffc02039b4:	02f50e63          	beq	a0,a5,ffffffffc02039f0 <default_free_pages+0x120>
ffffffffc02039b8:	751c                	ld	a5,40(a0)
ffffffffc02039ba:	fe078713          	addi	a4,a5,-32
ffffffffc02039be:	00d78d63          	beq	a5,a3,ffffffffc02039d8 <default_free_pages+0x108>
ffffffffc02039c2:	4d0c                	lw	a1,24(a0)
ffffffffc02039c4:	02059613          	slli	a2,a1,0x20
ffffffffc02039c8:	9201                	srli	a2,a2,0x20
ffffffffc02039ca:	00361693          	slli	a3,a2,0x3
ffffffffc02039ce:	96b2                	add	a3,a3,a2
ffffffffc02039d0:	068e                	slli	a3,a3,0x3
ffffffffc02039d2:	96aa                	add	a3,a3,a0
ffffffffc02039d4:	04d70063          	beq	a4,a3,ffffffffc0203a14 <default_free_pages+0x144>
ffffffffc02039d8:	60a2                	ld	ra,8(sp)
ffffffffc02039da:	0141                	addi	sp,sp,16
ffffffffc02039dc:	8082                	ret
ffffffffc02039de:	60a2                	ld	ra,8(sp)
ffffffffc02039e0:	02050713          	addi	a4,a0,32
ffffffffc02039e4:	e398                	sd	a4,0(a5)
ffffffffc02039e6:	e798                	sd	a4,8(a5)
ffffffffc02039e8:	f51c                	sd	a5,40(a0)
ffffffffc02039ea:	f11c                	sd	a5,32(a0)
ffffffffc02039ec:	0141                	addi	sp,sp,16
ffffffffc02039ee:	8082                	ret
ffffffffc02039f0:	4d1c                	lw	a5,24(a0)
ffffffffc02039f2:	0107883b          	addw	a6,a5,a6
ffffffffc02039f6:	ff05ac23          	sw	a6,-8(a1)
ffffffffc02039fa:	57f5                	li	a5,-3
ffffffffc02039fc:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc0203a00:	02053803          	ld	a6,32(a0)
ffffffffc0203a04:	7518                	ld	a4,40(a0)
ffffffffc0203a06:	8532                	mv	a0,a2
ffffffffc0203a08:	00e83423          	sd	a4,8(a6)
ffffffffc0203a0c:	659c                	ld	a5,8(a1)
ffffffffc0203a0e:	01073023          	sd	a6,0(a4)
ffffffffc0203a12:	b765                	j	ffffffffc02039ba <default_free_pages+0xea>
ffffffffc0203a14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203a18:	fe878693          	addi	a3,a5,-24
ffffffffc0203a1c:	9db9                	addw	a1,a1,a4
ffffffffc0203a1e:	cd0c                	sw	a1,24(a0)
ffffffffc0203a20:	5775                	li	a4,-3
ffffffffc0203a22:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc0203a26:	6398                	ld	a4,0(a5)
ffffffffc0203a28:	679c                	ld	a5,8(a5)
ffffffffc0203a2a:	60a2                	ld	ra,8(sp)
ffffffffc0203a2c:	e71c                	sd	a5,8(a4)
ffffffffc0203a2e:	e398                	sd	a4,0(a5)
ffffffffc0203a30:	0141                	addi	sp,sp,16
ffffffffc0203a32:	8082                	ret
ffffffffc0203a34:	00002697          	auipc	a3,0x2
ffffffffc0203a38:	4cc68693          	addi	a3,a3,1228 # ffffffffc0205f00 <commands+0x1a78>
ffffffffc0203a3c:	00001617          	auipc	a2,0x1
ffffffffc0203a40:	2bc60613          	addi	a2,a2,700 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203a44:	08300593          	li	a1,131
ffffffffc0203a48:	00002517          	auipc	a0,0x2
ffffffffc0203a4c:	1a850513          	addi	a0,a0,424 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc0203a50:	eb4fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203a54:	00002697          	auipc	a3,0x2
ffffffffc0203a58:	4d468693          	addi	a3,a3,1236 # ffffffffc0205f28 <commands+0x1aa0>
ffffffffc0203a5c:	00001617          	auipc	a2,0x1
ffffffffc0203a60:	29c60613          	addi	a2,a2,668 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203a64:	08000593          	li	a1,128
ffffffffc0203a68:	00002517          	auipc	a0,0x2
ffffffffc0203a6c:	18850513          	addi	a0,a0,392 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc0203a70:	e94fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203a74 <default_alloc_pages>:
ffffffffc0203a74:	cd51                	beqz	a0,ffffffffc0203b10 <default_alloc_pages+0x9c>
ffffffffc0203a76:	0000e597          	auipc	a1,0xe
ffffffffc0203a7a:	b1258593          	addi	a1,a1,-1262 # ffffffffc0211588 <free_area>
ffffffffc0203a7e:	0105a803          	lw	a6,16(a1)
ffffffffc0203a82:	862a                	mv	a2,a0
ffffffffc0203a84:	02081793          	slli	a5,a6,0x20
ffffffffc0203a88:	9381                	srli	a5,a5,0x20
ffffffffc0203a8a:	00a7ee63          	bltu	a5,a0,ffffffffc0203aa6 <default_alloc_pages+0x32>
ffffffffc0203a8e:	87ae                	mv	a5,a1
ffffffffc0203a90:	a801                	j	ffffffffc0203aa0 <default_alloc_pages+0x2c>
ffffffffc0203a92:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203a96:	02071693          	slli	a3,a4,0x20
ffffffffc0203a9a:	9281                	srli	a3,a3,0x20
ffffffffc0203a9c:	00c6f763          	bgeu	a3,a2,ffffffffc0203aaa <default_alloc_pages+0x36>
ffffffffc0203aa0:	679c                	ld	a5,8(a5)
ffffffffc0203aa2:	feb798e3          	bne	a5,a1,ffffffffc0203a92 <default_alloc_pages+0x1e>
ffffffffc0203aa6:	4501                	li	a0,0
ffffffffc0203aa8:	8082                	ret
ffffffffc0203aaa:	fe078513          	addi	a0,a5,-32
ffffffffc0203aae:	dd6d                	beqz	a0,ffffffffc0203aa8 <default_alloc_pages+0x34>
ffffffffc0203ab0:	0007b883          	ld	a7,0(a5)
ffffffffc0203ab4:	0087b303          	ld	t1,8(a5)
ffffffffc0203ab8:	00060e1b          	sext.w	t3,a2
ffffffffc0203abc:	0068b423          	sd	t1,8(a7)
ffffffffc0203ac0:	01133023          	sd	a7,0(t1)
ffffffffc0203ac4:	02d67b63          	bgeu	a2,a3,ffffffffc0203afa <default_alloc_pages+0x86>
ffffffffc0203ac8:	00361693          	slli	a3,a2,0x3
ffffffffc0203acc:	96b2                	add	a3,a3,a2
ffffffffc0203ace:	068e                	slli	a3,a3,0x3
ffffffffc0203ad0:	96aa                	add	a3,a3,a0
ffffffffc0203ad2:	41c7073b          	subw	a4,a4,t3
ffffffffc0203ad6:	ce98                	sw	a4,24(a3)
ffffffffc0203ad8:	00868613          	addi	a2,a3,8
ffffffffc0203adc:	4709                	li	a4,2
ffffffffc0203ade:	40e6302f          	amoor.d	zero,a4,(a2)
ffffffffc0203ae2:	0088b703          	ld	a4,8(a7)
ffffffffc0203ae6:	02068613          	addi	a2,a3,32
ffffffffc0203aea:	0105a803          	lw	a6,16(a1)
ffffffffc0203aee:	e310                	sd	a2,0(a4)
ffffffffc0203af0:	00c8b423          	sd	a2,8(a7)
ffffffffc0203af4:	f698                	sd	a4,40(a3)
ffffffffc0203af6:	0316b023          	sd	a7,32(a3)
ffffffffc0203afa:	41c8083b          	subw	a6,a6,t3
ffffffffc0203afe:	0000e717          	auipc	a4,0xe
ffffffffc0203b02:	a9072d23          	sw	a6,-1382(a4) # ffffffffc0211598 <free_area+0x10>
ffffffffc0203b06:	5775                	li	a4,-3
ffffffffc0203b08:	17a1                	addi	a5,a5,-24
ffffffffc0203b0a:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0203b0e:	8082                	ret
ffffffffc0203b10:	1141                	addi	sp,sp,-16
ffffffffc0203b12:	00002697          	auipc	a3,0x2
ffffffffc0203b16:	41668693          	addi	a3,a3,1046 # ffffffffc0205f28 <commands+0x1aa0>
ffffffffc0203b1a:	00001617          	auipc	a2,0x1
ffffffffc0203b1e:	1de60613          	addi	a2,a2,478 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203b22:	06200593          	li	a1,98
ffffffffc0203b26:	00002517          	auipc	a0,0x2
ffffffffc0203b2a:	0ca50513          	addi	a0,a0,202 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc0203b2e:	e406                	sd	ra,8(sp)
ffffffffc0203b30:	dd4fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203b34 <default_init_memmap>:
ffffffffc0203b34:	1141                	addi	sp,sp,-16
ffffffffc0203b36:	e406                	sd	ra,8(sp)
ffffffffc0203b38:	c1fd                	beqz	a1,ffffffffc0203c1e <default_init_memmap+0xea>
ffffffffc0203b3a:	00359693          	slli	a3,a1,0x3
ffffffffc0203b3e:	96ae                	add	a3,a3,a1
ffffffffc0203b40:	068e                	slli	a3,a3,0x3
ffffffffc0203b42:	96aa                	add	a3,a3,a0
ffffffffc0203b44:	02d50463          	beq	a0,a3,ffffffffc0203b6c <default_init_memmap+0x38>
ffffffffc0203b48:	6518                	ld	a4,8(a0)
ffffffffc0203b4a:	87aa                	mv	a5,a0
ffffffffc0203b4c:	8b05                	andi	a4,a4,1
ffffffffc0203b4e:	e709                	bnez	a4,ffffffffc0203b58 <default_init_memmap+0x24>
ffffffffc0203b50:	a07d                	j	ffffffffc0203bfe <default_init_memmap+0xca>
ffffffffc0203b52:	6798                	ld	a4,8(a5)
ffffffffc0203b54:	8b05                	andi	a4,a4,1
ffffffffc0203b56:	c745                	beqz	a4,ffffffffc0203bfe <default_init_memmap+0xca>
ffffffffc0203b58:	0007ac23          	sw	zero,24(a5)
ffffffffc0203b5c:	0007b423          	sd	zero,8(a5)
ffffffffc0203b60:	0007a023          	sw	zero,0(a5)
ffffffffc0203b64:	04878793          	addi	a5,a5,72
ffffffffc0203b68:	fed795e3          	bne	a5,a3,ffffffffc0203b52 <default_init_memmap+0x1e>
ffffffffc0203b6c:	2581                	sext.w	a1,a1
ffffffffc0203b6e:	cd0c                	sw	a1,24(a0)
ffffffffc0203b70:	4789                	li	a5,2
ffffffffc0203b72:	00850713          	addi	a4,a0,8
ffffffffc0203b76:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0203b7a:	0000e697          	auipc	a3,0xe
ffffffffc0203b7e:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0211588 <free_area>
ffffffffc0203b82:	4a98                	lw	a4,16(a3)
ffffffffc0203b84:	669c                	ld	a5,8(a3)
ffffffffc0203b86:	9db9                	addw	a1,a1,a4
ffffffffc0203b88:	0000e717          	auipc	a4,0xe
ffffffffc0203b8c:	a0b72823          	sw	a1,-1520(a4) # ffffffffc0211598 <free_area+0x10>
ffffffffc0203b90:	04d78a63          	beq	a5,a3,ffffffffc0203be4 <default_init_memmap+0xb0>
ffffffffc0203b94:	fe078713          	addi	a4,a5,-32
ffffffffc0203b98:	628c                	ld	a1,0(a3)
ffffffffc0203b9a:	4801                	li	a6,0
ffffffffc0203b9c:	02050613          	addi	a2,a0,32
ffffffffc0203ba0:	00e56a63          	bltu	a0,a4,ffffffffc0203bb4 <default_init_memmap+0x80>
ffffffffc0203ba4:	6798                	ld	a4,8(a5)
ffffffffc0203ba6:	02d70563          	beq	a4,a3,ffffffffc0203bd0 <default_init_memmap+0x9c>
ffffffffc0203baa:	87ba                	mv	a5,a4
ffffffffc0203bac:	fe078713          	addi	a4,a5,-32
ffffffffc0203bb0:	fee57ae3          	bgeu	a0,a4,ffffffffc0203ba4 <default_init_memmap+0x70>
ffffffffc0203bb4:	00080663          	beqz	a6,ffffffffc0203bc0 <default_init_memmap+0x8c>
ffffffffc0203bb8:	0000e717          	auipc	a4,0xe
ffffffffc0203bbc:	9cb73823          	sd	a1,-1584(a4) # ffffffffc0211588 <free_area>
ffffffffc0203bc0:	6398                	ld	a4,0(a5)
ffffffffc0203bc2:	60a2                	ld	ra,8(sp)
ffffffffc0203bc4:	e390                	sd	a2,0(a5)
ffffffffc0203bc6:	e710                	sd	a2,8(a4)
ffffffffc0203bc8:	f51c                	sd	a5,40(a0)
ffffffffc0203bca:	f118                	sd	a4,32(a0)
ffffffffc0203bcc:	0141                	addi	sp,sp,16
ffffffffc0203bce:	8082                	ret
ffffffffc0203bd0:	e790                	sd	a2,8(a5)
ffffffffc0203bd2:	f514                	sd	a3,40(a0)
ffffffffc0203bd4:	6798                	ld	a4,8(a5)
ffffffffc0203bd6:	f11c                	sd	a5,32(a0)
ffffffffc0203bd8:	85b2                	mv	a1,a2
ffffffffc0203bda:	00d70e63          	beq	a4,a3,ffffffffc0203bf6 <default_init_memmap+0xc2>
ffffffffc0203bde:	4805                	li	a6,1
ffffffffc0203be0:	87ba                	mv	a5,a4
ffffffffc0203be2:	b7e9                	j	ffffffffc0203bac <default_init_memmap+0x78>
ffffffffc0203be4:	60a2                	ld	ra,8(sp)
ffffffffc0203be6:	02050713          	addi	a4,a0,32
ffffffffc0203bea:	e398                	sd	a4,0(a5)
ffffffffc0203bec:	e798                	sd	a4,8(a5)
ffffffffc0203bee:	f51c                	sd	a5,40(a0)
ffffffffc0203bf0:	f11c                	sd	a5,32(a0)
ffffffffc0203bf2:	0141                	addi	sp,sp,16
ffffffffc0203bf4:	8082                	ret
ffffffffc0203bf6:	60a2                	ld	ra,8(sp)
ffffffffc0203bf8:	e290                	sd	a2,0(a3)
ffffffffc0203bfa:	0141                	addi	sp,sp,16
ffffffffc0203bfc:	8082                	ret
ffffffffc0203bfe:	00002697          	auipc	a3,0x2
ffffffffc0203c02:	33268693          	addi	a3,a3,818 # ffffffffc0205f30 <commands+0x1aa8>
ffffffffc0203c06:	00001617          	auipc	a2,0x1
ffffffffc0203c0a:	0f260613          	addi	a2,a2,242 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203c0e:	04900593          	li	a1,73
ffffffffc0203c12:	00002517          	auipc	a0,0x2
ffffffffc0203c16:	fde50513          	addi	a0,a0,-34 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc0203c1a:	ceafc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203c1e:	00002697          	auipc	a3,0x2
ffffffffc0203c22:	30a68693          	addi	a3,a3,778 # ffffffffc0205f28 <commands+0x1aa0>
ffffffffc0203c26:	00001617          	auipc	a2,0x1
ffffffffc0203c2a:	0d260613          	addi	a2,a2,210 # ffffffffc0204cf8 <commands+0x870>
ffffffffc0203c2e:	04600593          	li	a1,70
ffffffffc0203c32:	00002517          	auipc	a0,0x2
ffffffffc0203c36:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205bf0 <commands+0x1768>
ffffffffc0203c3a:	ccafc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203c3e <swapfs_init>:
ffffffffc0203c3e:	1141                	addi	sp,sp,-16
ffffffffc0203c40:	4505                	li	a0,1
ffffffffc0203c42:	e406                	sd	ra,8(sp)
ffffffffc0203c44:	f8efc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203c48:	cd01                	beqz	a0,ffffffffc0203c60 <swapfs_init+0x22>
ffffffffc0203c4a:	4505                	li	a0,1
ffffffffc0203c4c:	f8cfc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
ffffffffc0203c50:	60a2                	ld	ra,8(sp)
ffffffffc0203c52:	810d                	srli	a0,a0,0x3
ffffffffc0203c54:	0000e797          	auipc	a5,0xe
ffffffffc0203c58:	8ea7ba23          	sd	a0,-1804(a5) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203c5c:	0141                	addi	sp,sp,16
ffffffffc0203c5e:	8082                	ret
ffffffffc0203c60:	00002617          	auipc	a2,0x2
ffffffffc0203c64:	33060613          	addi	a2,a2,816 # ffffffffc0205f90 <default_pmm_manager+0x50>
ffffffffc0203c68:	45b5                	li	a1,13
ffffffffc0203c6a:	00002517          	auipc	a0,0x2
ffffffffc0203c6e:	34650513          	addi	a0,a0,838 # ffffffffc0205fb0 <default_pmm_manager+0x70>
ffffffffc0203c72:	c92fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203c76 <swapfs_read>:
ffffffffc0203c76:	1141                	addi	sp,sp,-16
ffffffffc0203c78:	e406                	sd	ra,8(sp)
ffffffffc0203c7a:	00855793          	srli	a5,a0,0x8
ffffffffc0203c7e:	c7b5                	beqz	a5,ffffffffc0203cea <swapfs_read+0x74>
ffffffffc0203c80:	0000e717          	auipc	a4,0xe
ffffffffc0203c84:	8c870713          	addi	a4,a4,-1848 # ffffffffc0211548 <max_swap_offset>
ffffffffc0203c88:	6318                	ld	a4,0(a4)
ffffffffc0203c8a:	06e7f063          	bgeu	a5,a4,ffffffffc0203cea <swapfs_read+0x74>
ffffffffc0203c8e:	0000e717          	auipc	a4,0xe
ffffffffc0203c92:	82270713          	addi	a4,a4,-2014 # ffffffffc02114b0 <pages>
ffffffffc0203c96:	6310                	ld	a2,0(a4)
ffffffffc0203c98:	00001717          	auipc	a4,0x1
ffffffffc0203c9c:	22070713          	addi	a4,a4,544 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0203ca0:	00002697          	auipc	a3,0x2
ffffffffc0203ca4:	59068693          	addi	a3,a3,1424 # ffffffffc0206230 <nbase>
ffffffffc0203ca8:	40c58633          	sub	a2,a1,a2
ffffffffc0203cac:	630c                	ld	a1,0(a4)
ffffffffc0203cae:	860d                	srai	a2,a2,0x3
ffffffffc0203cb0:	0000d717          	auipc	a4,0xd
ffffffffc0203cb4:	7b070713          	addi	a4,a4,1968 # ffffffffc0211460 <npage>
ffffffffc0203cb8:	02b60633          	mul	a2,a2,a1
ffffffffc0203cbc:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cc0:	629c                	ld	a5,0(a3)
ffffffffc0203cc2:	6318                	ld	a4,0(a4)
ffffffffc0203cc4:	963e                	add	a2,a2,a5
ffffffffc0203cc6:	57fd                	li	a5,-1
ffffffffc0203cc8:	83b1                	srli	a5,a5,0xc
ffffffffc0203cca:	8ff1                	and	a5,a5,a2
ffffffffc0203ccc:	0632                	slli	a2,a2,0xc
ffffffffc0203cce:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d02 <swapfs_read+0x8c>
ffffffffc0203cd2:	0000d797          	auipc	a5,0xd
ffffffffc0203cd6:	7ce78793          	addi	a5,a5,1998 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203cda:	639c                	ld	a5,0(a5)
ffffffffc0203cdc:	60a2                	ld	ra,8(sp)
ffffffffc0203cde:	46a1                	li	a3,8
ffffffffc0203ce0:	963e                	add	a2,a2,a5
ffffffffc0203ce2:	4505                	li	a0,1
ffffffffc0203ce4:	0141                	addi	sp,sp,16
ffffffffc0203ce6:	ef8fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203cea:	86aa                	mv	a3,a0
ffffffffc0203cec:	00002617          	auipc	a2,0x2
ffffffffc0203cf0:	2dc60613          	addi	a2,a2,732 # ffffffffc0205fc8 <default_pmm_manager+0x88>
ffffffffc0203cf4:	45d1                	li	a1,20
ffffffffc0203cf6:	00002517          	auipc	a0,0x2
ffffffffc0203cfa:	2ba50513          	addi	a0,a0,698 # ffffffffc0205fb0 <default_pmm_manager+0x70>
ffffffffc0203cfe:	c06fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203d02:	86b2                	mv	a3,a2
ffffffffc0203d04:	06a00593          	li	a1,106
ffffffffc0203d08:	00001617          	auipc	a2,0x1
ffffffffc0203d0c:	1b860613          	addi	a2,a2,440 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0203d10:	00001517          	auipc	a0,0x1
ffffffffc0203d14:	24850513          	addi	a0,a0,584 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0203d18:	becfc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203d1c <swapfs_write>:
ffffffffc0203d1c:	1141                	addi	sp,sp,-16
ffffffffc0203d1e:	e406                	sd	ra,8(sp)
ffffffffc0203d20:	00855793          	srli	a5,a0,0x8
ffffffffc0203d24:	c7b5                	beqz	a5,ffffffffc0203d90 <swapfs_write+0x74>
ffffffffc0203d26:	0000e717          	auipc	a4,0xe
ffffffffc0203d2a:	82270713          	addi	a4,a4,-2014 # ffffffffc0211548 <max_swap_offset>
ffffffffc0203d2e:	6318                	ld	a4,0(a4)
ffffffffc0203d30:	06e7f063          	bgeu	a5,a4,ffffffffc0203d90 <swapfs_write+0x74>
ffffffffc0203d34:	0000d717          	auipc	a4,0xd
ffffffffc0203d38:	77c70713          	addi	a4,a4,1916 # ffffffffc02114b0 <pages>
ffffffffc0203d3c:	6310                	ld	a2,0(a4)
ffffffffc0203d3e:	00001717          	auipc	a4,0x1
ffffffffc0203d42:	17a70713          	addi	a4,a4,378 # ffffffffc0204eb8 <commands+0xa30>
ffffffffc0203d46:	00002697          	auipc	a3,0x2
ffffffffc0203d4a:	4ea68693          	addi	a3,a3,1258 # ffffffffc0206230 <nbase>
ffffffffc0203d4e:	40c58633          	sub	a2,a1,a2
ffffffffc0203d52:	630c                	ld	a1,0(a4)
ffffffffc0203d54:	860d                	srai	a2,a2,0x3
ffffffffc0203d56:	0000d717          	auipc	a4,0xd
ffffffffc0203d5a:	70a70713          	addi	a4,a4,1802 # ffffffffc0211460 <npage>
ffffffffc0203d5e:	02b60633          	mul	a2,a2,a1
ffffffffc0203d62:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d66:	629c                	ld	a5,0(a3)
ffffffffc0203d68:	6318                	ld	a4,0(a4)
ffffffffc0203d6a:	963e                	add	a2,a2,a5
ffffffffc0203d6c:	57fd                	li	a5,-1
ffffffffc0203d6e:	83b1                	srli	a5,a5,0xc
ffffffffc0203d70:	8ff1                	and	a5,a5,a2
ffffffffc0203d72:	0632                	slli	a2,a2,0xc
ffffffffc0203d74:	02e7fa63          	bgeu	a5,a4,ffffffffc0203da8 <swapfs_write+0x8c>
ffffffffc0203d78:	0000d797          	auipc	a5,0xd
ffffffffc0203d7c:	72878793          	addi	a5,a5,1832 # ffffffffc02114a0 <va_pa_offset>
ffffffffc0203d80:	639c                	ld	a5,0(a5)
ffffffffc0203d82:	60a2                	ld	ra,8(sp)
ffffffffc0203d84:	46a1                	li	a3,8
ffffffffc0203d86:	963e                	add	a2,a2,a5
ffffffffc0203d88:	4505                	li	a0,1
ffffffffc0203d8a:	0141                	addi	sp,sp,16
ffffffffc0203d8c:	e76fc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203d90:	86aa                	mv	a3,a0
ffffffffc0203d92:	00002617          	auipc	a2,0x2
ffffffffc0203d96:	23660613          	addi	a2,a2,566 # ffffffffc0205fc8 <default_pmm_manager+0x88>
ffffffffc0203d9a:	45e5                	li	a1,25
ffffffffc0203d9c:	00002517          	auipc	a0,0x2
ffffffffc0203da0:	21450513          	addi	a0,a0,532 # ffffffffc0205fb0 <default_pmm_manager+0x70>
ffffffffc0203da4:	b60fc0ef          	jal	ra,ffffffffc0200104 <__panic>
ffffffffc0203da8:	86b2                	mv	a3,a2
ffffffffc0203daa:	06a00593          	li	a1,106
ffffffffc0203dae:	00001617          	auipc	a2,0x1
ffffffffc0203db2:	11260613          	addi	a2,a2,274 # ffffffffc0204ec0 <commands+0xa38>
ffffffffc0203db6:	00001517          	auipc	a0,0x1
ffffffffc0203dba:	1a250513          	addi	a0,a0,418 # ffffffffc0204f58 <commands+0xad0>
ffffffffc0203dbe:	b46fc0ef          	jal	ra,ffffffffc0200104 <__panic>

ffffffffc0203dc2 <strlen>:
ffffffffc0203dc2:	00054783          	lbu	a5,0(a0)
ffffffffc0203dc6:	cb91                	beqz	a5,ffffffffc0203dda <strlen+0x18>
ffffffffc0203dc8:	4781                	li	a5,0
ffffffffc0203dca:	0785                	addi	a5,a5,1
ffffffffc0203dcc:	00f50733          	add	a4,a0,a5
ffffffffc0203dd0:	00074703          	lbu	a4,0(a4)
ffffffffc0203dd4:	fb7d                	bnez	a4,ffffffffc0203dca <strlen+0x8>
ffffffffc0203dd6:	853e                	mv	a0,a5
ffffffffc0203dd8:	8082                	ret
ffffffffc0203dda:	4781                	li	a5,0
ffffffffc0203ddc:	853e                	mv	a0,a5
ffffffffc0203dde:	8082                	ret

ffffffffc0203de0 <strnlen>:
ffffffffc0203de0:	c185                	beqz	a1,ffffffffc0203e00 <strnlen+0x20>
ffffffffc0203de2:	00054783          	lbu	a5,0(a0)
ffffffffc0203de6:	cf89                	beqz	a5,ffffffffc0203e00 <strnlen+0x20>
ffffffffc0203de8:	4781                	li	a5,0
ffffffffc0203dea:	a021                	j	ffffffffc0203df2 <strnlen+0x12>
ffffffffc0203dec:	00074703          	lbu	a4,0(a4)
ffffffffc0203df0:	c711                	beqz	a4,ffffffffc0203dfc <strnlen+0x1c>
ffffffffc0203df2:	0785                	addi	a5,a5,1
ffffffffc0203df4:	00f50733          	add	a4,a0,a5
ffffffffc0203df8:	fef59ae3          	bne	a1,a5,ffffffffc0203dec <strnlen+0xc>
ffffffffc0203dfc:	853e                	mv	a0,a5
ffffffffc0203dfe:	8082                	ret
ffffffffc0203e00:	4781                	li	a5,0
ffffffffc0203e02:	853e                	mv	a0,a5
ffffffffc0203e04:	8082                	ret

ffffffffc0203e06 <strcpy>:
ffffffffc0203e06:	87aa                	mv	a5,a0
ffffffffc0203e08:	0585                	addi	a1,a1,1
ffffffffc0203e0a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e0e:	0785                	addi	a5,a5,1
ffffffffc0203e10:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e14:	fb75                	bnez	a4,ffffffffc0203e08 <strcpy+0x2>
ffffffffc0203e16:	8082                	ret

ffffffffc0203e18 <strcmp>:
ffffffffc0203e18:	00054783          	lbu	a5,0(a0)
ffffffffc0203e1c:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e20:	cb91                	beqz	a5,ffffffffc0203e34 <strcmp+0x1c>
ffffffffc0203e22:	00e79c63          	bne	a5,a4,ffffffffc0203e3a <strcmp+0x22>
ffffffffc0203e26:	0505                	addi	a0,a0,1
ffffffffc0203e28:	00054783          	lbu	a5,0(a0)
ffffffffc0203e2c:	0585                	addi	a1,a1,1
ffffffffc0203e2e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203e32:	fbe5                	bnez	a5,ffffffffc0203e22 <strcmp+0xa>
ffffffffc0203e34:	4501                	li	a0,0
ffffffffc0203e36:	9d19                	subw	a0,a0,a4
ffffffffc0203e38:	8082                	ret
ffffffffc0203e3a:	0007851b          	sext.w	a0,a5
ffffffffc0203e3e:	9d19                	subw	a0,a0,a4
ffffffffc0203e40:	8082                	ret

ffffffffc0203e42 <strchr>:
ffffffffc0203e42:	00054783          	lbu	a5,0(a0)
ffffffffc0203e46:	cb91                	beqz	a5,ffffffffc0203e5a <strchr+0x18>
ffffffffc0203e48:	00b79563          	bne	a5,a1,ffffffffc0203e52 <strchr+0x10>
ffffffffc0203e4c:	a809                	j	ffffffffc0203e5e <strchr+0x1c>
ffffffffc0203e4e:	00b78763          	beq	a5,a1,ffffffffc0203e5c <strchr+0x1a>
ffffffffc0203e52:	0505                	addi	a0,a0,1
ffffffffc0203e54:	00054783          	lbu	a5,0(a0)
ffffffffc0203e58:	fbfd                	bnez	a5,ffffffffc0203e4e <strchr+0xc>
ffffffffc0203e5a:	4501                	li	a0,0
ffffffffc0203e5c:	8082                	ret
ffffffffc0203e5e:	8082                	ret

ffffffffc0203e60 <memset>:
ffffffffc0203e60:	ca01                	beqz	a2,ffffffffc0203e70 <memset+0x10>
ffffffffc0203e62:	962a                	add	a2,a2,a0
ffffffffc0203e64:	87aa                	mv	a5,a0
ffffffffc0203e66:	0785                	addi	a5,a5,1
ffffffffc0203e68:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0203e6c:	fec79de3          	bne	a5,a2,ffffffffc0203e66 <memset+0x6>
ffffffffc0203e70:	8082                	ret

ffffffffc0203e72 <memcpy>:
ffffffffc0203e72:	ca19                	beqz	a2,ffffffffc0203e88 <memcpy+0x16>
ffffffffc0203e74:	962e                	add	a2,a2,a1
ffffffffc0203e76:	87aa                	mv	a5,a0
ffffffffc0203e78:	0585                	addi	a1,a1,1
ffffffffc0203e7a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203e7e:	0785                	addi	a5,a5,1
ffffffffc0203e80:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203e84:	fec59ae3          	bne	a1,a2,ffffffffc0203e78 <memcpy+0x6>
ffffffffc0203e88:	8082                	ret

ffffffffc0203e8a <printnum>:
ffffffffc0203e8a:	02069813          	slli	a6,a3,0x20
ffffffffc0203e8e:	7179                	addi	sp,sp,-48
ffffffffc0203e90:	02085813          	srli	a6,a6,0x20
ffffffffc0203e94:	e052                	sd	s4,0(sp)
ffffffffc0203e96:	03067a33          	remu	s4,a2,a6
ffffffffc0203e9a:	f022                	sd	s0,32(sp)
ffffffffc0203e9c:	ec26                	sd	s1,24(sp)
ffffffffc0203e9e:	e84a                	sd	s2,16(sp)
ffffffffc0203ea0:	f406                	sd	ra,40(sp)
ffffffffc0203ea2:	e44e                	sd	s3,8(sp)
ffffffffc0203ea4:	84aa                	mv	s1,a0
ffffffffc0203ea6:	892e                	mv	s2,a1
ffffffffc0203ea8:	fff7041b          	addiw	s0,a4,-1
ffffffffc0203eac:	2a01                	sext.w	s4,s4
ffffffffc0203eae:	03067e63          	bgeu	a2,a6,ffffffffc0203eea <printnum+0x60>
ffffffffc0203eb2:	89be                	mv	s3,a5
ffffffffc0203eb4:	00805763          	blez	s0,ffffffffc0203ec2 <printnum+0x38>
ffffffffc0203eb8:	347d                	addiw	s0,s0,-1
ffffffffc0203eba:	85ca                	mv	a1,s2
ffffffffc0203ebc:	854e                	mv	a0,s3
ffffffffc0203ebe:	9482                	jalr	s1
ffffffffc0203ec0:	fc65                	bnez	s0,ffffffffc0203eb8 <printnum+0x2e>
ffffffffc0203ec2:	1a02                	slli	s4,s4,0x20
ffffffffc0203ec4:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203ec8:	00002797          	auipc	a5,0x2
ffffffffc0203ecc:	2b078793          	addi	a5,a5,688 # ffffffffc0206178 <error_string+0x38>
ffffffffc0203ed0:	9a3e                	add	s4,s4,a5
ffffffffc0203ed2:	7402                	ld	s0,32(sp)
ffffffffc0203ed4:	000a4503          	lbu	a0,0(s4)
ffffffffc0203ed8:	70a2                	ld	ra,40(sp)
ffffffffc0203eda:	69a2                	ld	s3,8(sp)
ffffffffc0203edc:	6a02                	ld	s4,0(sp)
ffffffffc0203ede:	85ca                	mv	a1,s2
ffffffffc0203ee0:	8326                	mv	t1,s1
ffffffffc0203ee2:	6942                	ld	s2,16(sp)
ffffffffc0203ee4:	64e2                	ld	s1,24(sp)
ffffffffc0203ee6:	6145                	addi	sp,sp,48
ffffffffc0203ee8:	8302                	jr	t1
ffffffffc0203eea:	03065633          	divu	a2,a2,a6
ffffffffc0203eee:	8722                	mv	a4,s0
ffffffffc0203ef0:	f9bff0ef          	jal	ra,ffffffffc0203e8a <printnum>
ffffffffc0203ef4:	b7f9                	j	ffffffffc0203ec2 <printnum+0x38>

ffffffffc0203ef6 <vprintfmt>:
ffffffffc0203ef6:	7119                	addi	sp,sp,-128
ffffffffc0203ef8:	f4a6                	sd	s1,104(sp)
ffffffffc0203efa:	f0ca                	sd	s2,96(sp)
ffffffffc0203efc:	e8d2                	sd	s4,80(sp)
ffffffffc0203efe:	e4d6                	sd	s5,72(sp)
ffffffffc0203f00:	e0da                	sd	s6,64(sp)
ffffffffc0203f02:	fc5e                	sd	s7,56(sp)
ffffffffc0203f04:	f862                	sd	s8,48(sp)
ffffffffc0203f06:	f06a                	sd	s10,32(sp)
ffffffffc0203f08:	fc86                	sd	ra,120(sp)
ffffffffc0203f0a:	f8a2                	sd	s0,112(sp)
ffffffffc0203f0c:	ecce                	sd	s3,88(sp)
ffffffffc0203f0e:	f466                	sd	s9,40(sp)
ffffffffc0203f10:	ec6e                	sd	s11,24(sp)
ffffffffc0203f12:	892a                	mv	s2,a0
ffffffffc0203f14:	84ae                	mv	s1,a1
ffffffffc0203f16:	8d32                	mv	s10,a2
ffffffffc0203f18:	8ab6                	mv	s5,a3
ffffffffc0203f1a:	5b7d                	li	s6,-1
ffffffffc0203f1c:	00002a17          	auipc	s4,0x2
ffffffffc0203f20:	0cca0a13          	addi	s4,s4,204 # ffffffffc0205fe8 <default_pmm_manager+0xa8>
ffffffffc0203f24:	05e00b93          	li	s7,94
ffffffffc0203f28:	00002c17          	auipc	s8,0x2
ffffffffc0203f2c:	218c0c13          	addi	s8,s8,536 # ffffffffc0206140 <error_string>
ffffffffc0203f30:	000d4503          	lbu	a0,0(s10)
ffffffffc0203f34:	02500793          	li	a5,37
ffffffffc0203f38:	001d0413          	addi	s0,s10,1
ffffffffc0203f3c:	00f50e63          	beq	a0,a5,ffffffffc0203f58 <vprintfmt+0x62>
ffffffffc0203f40:	c521                	beqz	a0,ffffffffc0203f88 <vprintfmt+0x92>
ffffffffc0203f42:	02500993          	li	s3,37
ffffffffc0203f46:	a011                	j	ffffffffc0203f4a <vprintfmt+0x54>
ffffffffc0203f48:	c121                	beqz	a0,ffffffffc0203f88 <vprintfmt+0x92>
ffffffffc0203f4a:	85a6                	mv	a1,s1
ffffffffc0203f4c:	0405                	addi	s0,s0,1
ffffffffc0203f4e:	9902                	jalr	s2
ffffffffc0203f50:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203f54:	ff351ae3          	bne	a0,s3,ffffffffc0203f48 <vprintfmt+0x52>
ffffffffc0203f58:	00044603          	lbu	a2,0(s0)
ffffffffc0203f5c:	02000793          	li	a5,32
ffffffffc0203f60:	4981                	li	s3,0
ffffffffc0203f62:	4801                	li	a6,0
ffffffffc0203f64:	5cfd                	li	s9,-1
ffffffffc0203f66:	5dfd                	li	s11,-1
ffffffffc0203f68:	05500593          	li	a1,85
ffffffffc0203f6c:	4525                	li	a0,9
ffffffffc0203f6e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203f72:	0ff6f693          	andi	a3,a3,255
ffffffffc0203f76:	00140d13          	addi	s10,s0,1
ffffffffc0203f7a:	20d5e563          	bltu	a1,a3,ffffffffc0204184 <vprintfmt+0x28e>
ffffffffc0203f7e:	068a                	slli	a3,a3,0x2
ffffffffc0203f80:	96d2                	add	a3,a3,s4
ffffffffc0203f82:	4294                	lw	a3,0(a3)
ffffffffc0203f84:	96d2                	add	a3,a3,s4
ffffffffc0203f86:	8682                	jr	a3
ffffffffc0203f88:	70e6                	ld	ra,120(sp)
ffffffffc0203f8a:	7446                	ld	s0,112(sp)
ffffffffc0203f8c:	74a6                	ld	s1,104(sp)
ffffffffc0203f8e:	7906                	ld	s2,96(sp)
ffffffffc0203f90:	69e6                	ld	s3,88(sp)
ffffffffc0203f92:	6a46                	ld	s4,80(sp)
ffffffffc0203f94:	6aa6                	ld	s5,72(sp)
ffffffffc0203f96:	6b06                	ld	s6,64(sp)
ffffffffc0203f98:	7be2                	ld	s7,56(sp)
ffffffffc0203f9a:	7c42                	ld	s8,48(sp)
ffffffffc0203f9c:	7ca2                	ld	s9,40(sp)
ffffffffc0203f9e:	7d02                	ld	s10,32(sp)
ffffffffc0203fa0:	6de2                	ld	s11,24(sp)
ffffffffc0203fa2:	6109                	addi	sp,sp,128
ffffffffc0203fa4:	8082                	ret
ffffffffc0203fa6:	4705                	li	a4,1
ffffffffc0203fa8:	008a8593          	addi	a1,s5,8
ffffffffc0203fac:	01074463          	blt	a4,a6,ffffffffc0203fb4 <vprintfmt+0xbe>
ffffffffc0203fb0:	26080363          	beqz	a6,ffffffffc0204216 <vprintfmt+0x320>
ffffffffc0203fb4:	000ab603          	ld	a2,0(s5)
ffffffffc0203fb8:	46c1                	li	a3,16
ffffffffc0203fba:	8aae                	mv	s5,a1
ffffffffc0203fbc:	a06d                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc0203fbe:	00144603          	lbu	a2,1(s0)
ffffffffc0203fc2:	4985                	li	s3,1
ffffffffc0203fc4:	846a                	mv	s0,s10
ffffffffc0203fc6:	b765                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0203fc8:	000aa503          	lw	a0,0(s5)
ffffffffc0203fcc:	85a6                	mv	a1,s1
ffffffffc0203fce:	0aa1                	addi	s5,s5,8
ffffffffc0203fd0:	9902                	jalr	s2
ffffffffc0203fd2:	bfb9                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc0203fd4:	4705                	li	a4,1
ffffffffc0203fd6:	008a8993          	addi	s3,s5,8
ffffffffc0203fda:	01074463          	blt	a4,a6,ffffffffc0203fe2 <vprintfmt+0xec>
ffffffffc0203fde:	22080463          	beqz	a6,ffffffffc0204206 <vprintfmt+0x310>
ffffffffc0203fe2:	000ab403          	ld	s0,0(s5)
ffffffffc0203fe6:	24044463          	bltz	s0,ffffffffc020422e <vprintfmt+0x338>
ffffffffc0203fea:	8622                	mv	a2,s0
ffffffffc0203fec:	8ace                	mv	s5,s3
ffffffffc0203fee:	46a9                	li	a3,10
ffffffffc0203ff0:	a89d                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc0203ff2:	000aa783          	lw	a5,0(s5)
ffffffffc0203ff6:	4719                	li	a4,6
ffffffffc0203ff8:	0aa1                	addi	s5,s5,8
ffffffffc0203ffa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203ffe:	8fb5                	xor	a5,a5,a3
ffffffffc0204000:	40d786bb          	subw	a3,a5,a3
ffffffffc0204004:	1ad74363          	blt	a4,a3,ffffffffc02041aa <vprintfmt+0x2b4>
ffffffffc0204008:	00369793          	slli	a5,a3,0x3
ffffffffc020400c:	97e2                	add	a5,a5,s8
ffffffffc020400e:	639c                	ld	a5,0(a5)
ffffffffc0204010:	18078d63          	beqz	a5,ffffffffc02041aa <vprintfmt+0x2b4>
ffffffffc0204014:	86be                	mv	a3,a5
ffffffffc0204016:	00002617          	auipc	a2,0x2
ffffffffc020401a:	21260613          	addi	a2,a2,530 # ffffffffc0206228 <error_string+0xe8>
ffffffffc020401e:	85a6                	mv	a1,s1
ffffffffc0204020:	854a                	mv	a0,s2
ffffffffc0204022:	240000ef          	jal	ra,ffffffffc0204262 <printfmt>
ffffffffc0204026:	b729                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc0204028:	00144603          	lbu	a2,1(s0)
ffffffffc020402c:	2805                	addiw	a6,a6,1
ffffffffc020402e:	846a                	mv	s0,s10
ffffffffc0204030:	bf3d                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204032:	4705                	li	a4,1
ffffffffc0204034:	008a8593          	addi	a1,s5,8
ffffffffc0204038:	01074463          	blt	a4,a6,ffffffffc0204040 <vprintfmt+0x14a>
ffffffffc020403c:	1e080263          	beqz	a6,ffffffffc0204220 <vprintfmt+0x32a>
ffffffffc0204040:	000ab603          	ld	a2,0(s5)
ffffffffc0204044:	46a1                	li	a3,8
ffffffffc0204046:	8aae                	mv	s5,a1
ffffffffc0204048:	a839                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc020404a:	03000513          	li	a0,48
ffffffffc020404e:	85a6                	mv	a1,s1
ffffffffc0204050:	e03e                	sd	a5,0(sp)
ffffffffc0204052:	9902                	jalr	s2
ffffffffc0204054:	85a6                	mv	a1,s1
ffffffffc0204056:	07800513          	li	a0,120
ffffffffc020405a:	9902                	jalr	s2
ffffffffc020405c:	0aa1                	addi	s5,s5,8
ffffffffc020405e:	ff8ab603          	ld	a2,-8(s5)
ffffffffc0204062:	6782                	ld	a5,0(sp)
ffffffffc0204064:	46c1                	li	a3,16
ffffffffc0204066:	876e                	mv	a4,s11
ffffffffc0204068:	85a6                	mv	a1,s1
ffffffffc020406a:	854a                	mv	a0,s2
ffffffffc020406c:	e1fff0ef          	jal	ra,ffffffffc0203e8a <printnum>
ffffffffc0204070:	b5c1                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc0204072:	000ab603          	ld	a2,0(s5)
ffffffffc0204076:	0aa1                	addi	s5,s5,8
ffffffffc0204078:	1c060663          	beqz	a2,ffffffffc0204244 <vprintfmt+0x34e>
ffffffffc020407c:	00160413          	addi	s0,a2,1
ffffffffc0204080:	17b05c63          	blez	s11,ffffffffc02041f8 <vprintfmt+0x302>
ffffffffc0204084:	02d00593          	li	a1,45
ffffffffc0204088:	14b79263          	bne	a5,a1,ffffffffc02041cc <vprintfmt+0x2d6>
ffffffffc020408c:	00064783          	lbu	a5,0(a2)
ffffffffc0204090:	0007851b          	sext.w	a0,a5
ffffffffc0204094:	c905                	beqz	a0,ffffffffc02040c4 <vprintfmt+0x1ce>
ffffffffc0204096:	000cc563          	bltz	s9,ffffffffc02040a0 <vprintfmt+0x1aa>
ffffffffc020409a:	3cfd                	addiw	s9,s9,-1
ffffffffc020409c:	036c8263          	beq	s9,s6,ffffffffc02040c0 <vprintfmt+0x1ca>
ffffffffc02040a0:	85a6                	mv	a1,s1
ffffffffc02040a2:	18098463          	beqz	s3,ffffffffc020422a <vprintfmt+0x334>
ffffffffc02040a6:	3781                	addiw	a5,a5,-32
ffffffffc02040a8:	18fbf163          	bgeu	s7,a5,ffffffffc020422a <vprintfmt+0x334>
ffffffffc02040ac:	03f00513          	li	a0,63
ffffffffc02040b0:	9902                	jalr	s2
ffffffffc02040b2:	0405                	addi	s0,s0,1
ffffffffc02040b4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02040b8:	3dfd                	addiw	s11,s11,-1
ffffffffc02040ba:	0007851b          	sext.w	a0,a5
ffffffffc02040be:	fd61                	bnez	a0,ffffffffc0204096 <vprintfmt+0x1a0>
ffffffffc02040c0:	e7b058e3          	blez	s11,ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc02040c4:	3dfd                	addiw	s11,s11,-1
ffffffffc02040c6:	85a6                	mv	a1,s1
ffffffffc02040c8:	02000513          	li	a0,32
ffffffffc02040cc:	9902                	jalr	s2
ffffffffc02040ce:	e60d81e3          	beqz	s11,ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc02040d2:	3dfd                	addiw	s11,s11,-1
ffffffffc02040d4:	85a6                	mv	a1,s1
ffffffffc02040d6:	02000513          	li	a0,32
ffffffffc02040da:	9902                	jalr	s2
ffffffffc02040dc:	fe0d94e3          	bnez	s11,ffffffffc02040c4 <vprintfmt+0x1ce>
ffffffffc02040e0:	bd81                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc02040e2:	4705                	li	a4,1
ffffffffc02040e4:	008a8593          	addi	a1,s5,8
ffffffffc02040e8:	01074463          	blt	a4,a6,ffffffffc02040f0 <vprintfmt+0x1fa>
ffffffffc02040ec:	12080063          	beqz	a6,ffffffffc020420c <vprintfmt+0x316>
ffffffffc02040f0:	000ab603          	ld	a2,0(s5)
ffffffffc02040f4:	46a9                	li	a3,10
ffffffffc02040f6:	8aae                	mv	s5,a1
ffffffffc02040f8:	b7bd                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc02040fa:	00144603          	lbu	a2,1(s0)
ffffffffc02040fe:	02d00793          	li	a5,45
ffffffffc0204102:	846a                	mv	s0,s10
ffffffffc0204104:	b5ad                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204106:	85a6                	mv	a1,s1
ffffffffc0204108:	02500513          	li	a0,37
ffffffffc020410c:	9902                	jalr	s2
ffffffffc020410e:	b50d                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc0204110:	000aac83          	lw	s9,0(s5)
ffffffffc0204114:	00144603          	lbu	a2,1(s0)
ffffffffc0204118:	0aa1                	addi	s5,s5,8
ffffffffc020411a:	846a                	mv	s0,s10
ffffffffc020411c:	e40dd9e3          	bgez	s11,ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204120:	8de6                	mv	s11,s9
ffffffffc0204122:	5cfd                	li	s9,-1
ffffffffc0204124:	b5a9                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204126:	00144603          	lbu	a2,1(s0)
ffffffffc020412a:	03000793          	li	a5,48
ffffffffc020412e:	846a                	mv	s0,s10
ffffffffc0204130:	bd3d                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204132:	fd060c9b          	addiw	s9,a2,-48
ffffffffc0204136:	00144603          	lbu	a2,1(s0)
ffffffffc020413a:	846a                	mv	s0,s10
ffffffffc020413c:	fd06069b          	addiw	a3,a2,-48
ffffffffc0204140:	0006089b          	sext.w	a7,a2
ffffffffc0204144:	fcd56ce3          	bltu	a0,a3,ffffffffc020411c <vprintfmt+0x226>
ffffffffc0204148:	0405                	addi	s0,s0,1
ffffffffc020414a:	002c969b          	slliw	a3,s9,0x2
ffffffffc020414e:	00044603          	lbu	a2,0(s0)
ffffffffc0204152:	0196873b          	addw	a4,a3,s9
ffffffffc0204156:	0017171b          	slliw	a4,a4,0x1
ffffffffc020415a:	0117073b          	addw	a4,a4,a7
ffffffffc020415e:	fd06069b          	addiw	a3,a2,-48
ffffffffc0204162:	fd070c9b          	addiw	s9,a4,-48
ffffffffc0204166:	0006089b          	sext.w	a7,a2
ffffffffc020416a:	fcd57fe3          	bgeu	a0,a3,ffffffffc0204148 <vprintfmt+0x252>
ffffffffc020416e:	b77d                	j	ffffffffc020411c <vprintfmt+0x226>
ffffffffc0204170:	fffdc693          	not	a3,s11
ffffffffc0204174:	96fd                	srai	a3,a3,0x3f
ffffffffc0204176:	00ddfdb3          	and	s11,s11,a3
ffffffffc020417a:	00144603          	lbu	a2,1(s0)
ffffffffc020417e:	2d81                	sext.w	s11,s11
ffffffffc0204180:	846a                	mv	s0,s10
ffffffffc0204182:	b3f5                	j	ffffffffc0203f6e <vprintfmt+0x78>
ffffffffc0204184:	85a6                	mv	a1,s1
ffffffffc0204186:	02500513          	li	a0,37
ffffffffc020418a:	9902                	jalr	s2
ffffffffc020418c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204190:	02500793          	li	a5,37
ffffffffc0204194:	8d22                	mv	s10,s0
ffffffffc0204196:	d8f70de3          	beq	a4,a5,ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc020419a:	02500713          	li	a4,37
ffffffffc020419e:	1d7d                	addi	s10,s10,-1
ffffffffc02041a0:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02041a4:	fee79de3          	bne	a5,a4,ffffffffc020419e <vprintfmt+0x2a8>
ffffffffc02041a8:	b361                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc02041aa:	00002617          	auipc	a2,0x2
ffffffffc02041ae:	06e60613          	addi	a2,a2,110 # ffffffffc0206218 <error_string+0xd8>
ffffffffc02041b2:	85a6                	mv	a1,s1
ffffffffc02041b4:	854a                	mv	a0,s2
ffffffffc02041b6:	0ac000ef          	jal	ra,ffffffffc0204262 <printfmt>
ffffffffc02041ba:	bb9d                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc02041bc:	00002617          	auipc	a2,0x2
ffffffffc02041c0:	05460613          	addi	a2,a2,84 # ffffffffc0206210 <error_string+0xd0>
ffffffffc02041c4:	00002417          	auipc	s0,0x2
ffffffffc02041c8:	04d40413          	addi	s0,s0,77 # ffffffffc0206211 <error_string+0xd1>
ffffffffc02041cc:	8532                	mv	a0,a2
ffffffffc02041ce:	85e6                	mv	a1,s9
ffffffffc02041d0:	e032                	sd	a2,0(sp)
ffffffffc02041d2:	e43e                	sd	a5,8(sp)
ffffffffc02041d4:	c0dff0ef          	jal	ra,ffffffffc0203de0 <strnlen>
ffffffffc02041d8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02041dc:	6602                	ld	a2,0(sp)
ffffffffc02041de:	01b05d63          	blez	s11,ffffffffc02041f8 <vprintfmt+0x302>
ffffffffc02041e2:	67a2                	ld	a5,8(sp)
ffffffffc02041e4:	2781                	sext.w	a5,a5
ffffffffc02041e6:	e43e                	sd	a5,8(sp)
ffffffffc02041e8:	6522                	ld	a0,8(sp)
ffffffffc02041ea:	85a6                	mv	a1,s1
ffffffffc02041ec:	e032                	sd	a2,0(sp)
ffffffffc02041ee:	3dfd                	addiw	s11,s11,-1
ffffffffc02041f0:	9902                	jalr	s2
ffffffffc02041f2:	6602                	ld	a2,0(sp)
ffffffffc02041f4:	fe0d9ae3          	bnez	s11,ffffffffc02041e8 <vprintfmt+0x2f2>
ffffffffc02041f8:	00064783          	lbu	a5,0(a2)
ffffffffc02041fc:	0007851b          	sext.w	a0,a5
ffffffffc0204200:	e8051be3          	bnez	a0,ffffffffc0204096 <vprintfmt+0x1a0>
ffffffffc0204204:	b335                	j	ffffffffc0203f30 <vprintfmt+0x3a>
ffffffffc0204206:	000aa403          	lw	s0,0(s5)
ffffffffc020420a:	bbf1                	j	ffffffffc0203fe6 <vprintfmt+0xf0>
ffffffffc020420c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204210:	46a9                	li	a3,10
ffffffffc0204212:	8aae                	mv	s5,a1
ffffffffc0204214:	bd89                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc0204216:	000ae603          	lwu	a2,0(s5)
ffffffffc020421a:	46c1                	li	a3,16
ffffffffc020421c:	8aae                	mv	s5,a1
ffffffffc020421e:	b5a1                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc0204220:	000ae603          	lwu	a2,0(s5)
ffffffffc0204224:	46a1                	li	a3,8
ffffffffc0204226:	8aae                	mv	s5,a1
ffffffffc0204228:	bd3d                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc020422a:	9902                	jalr	s2
ffffffffc020422c:	b559                	j	ffffffffc02040b2 <vprintfmt+0x1bc>
ffffffffc020422e:	85a6                	mv	a1,s1
ffffffffc0204230:	02d00513          	li	a0,45
ffffffffc0204234:	e03e                	sd	a5,0(sp)
ffffffffc0204236:	9902                	jalr	s2
ffffffffc0204238:	8ace                	mv	s5,s3
ffffffffc020423a:	40800633          	neg	a2,s0
ffffffffc020423e:	46a9                	li	a3,10
ffffffffc0204240:	6782                	ld	a5,0(sp)
ffffffffc0204242:	b515                	j	ffffffffc0204066 <vprintfmt+0x170>
ffffffffc0204244:	01b05663          	blez	s11,ffffffffc0204250 <vprintfmt+0x35a>
ffffffffc0204248:	02d00693          	li	a3,45
ffffffffc020424c:	f6d798e3          	bne	a5,a3,ffffffffc02041bc <vprintfmt+0x2c6>
ffffffffc0204250:	00002417          	auipc	s0,0x2
ffffffffc0204254:	fc140413          	addi	s0,s0,-63 # ffffffffc0206211 <error_string+0xd1>
ffffffffc0204258:	02800513          	li	a0,40
ffffffffc020425c:	02800793          	li	a5,40
ffffffffc0204260:	bd1d                	j	ffffffffc0204096 <vprintfmt+0x1a0>

ffffffffc0204262 <printfmt>:
ffffffffc0204262:	715d                	addi	sp,sp,-80
ffffffffc0204264:	02810313          	addi	t1,sp,40
ffffffffc0204268:	f436                	sd	a3,40(sp)
ffffffffc020426a:	869a                	mv	a3,t1
ffffffffc020426c:	ec06                	sd	ra,24(sp)
ffffffffc020426e:	f83a                	sd	a4,48(sp)
ffffffffc0204270:	fc3e                	sd	a5,56(sp)
ffffffffc0204272:	e0c2                	sd	a6,64(sp)
ffffffffc0204274:	e4c6                	sd	a7,72(sp)
ffffffffc0204276:	e41a                	sd	t1,8(sp)
ffffffffc0204278:	c7fff0ef          	jal	ra,ffffffffc0203ef6 <vprintfmt>
ffffffffc020427c:	60e2                	ld	ra,24(sp)
ffffffffc020427e:	6161                	addi	sp,sp,80
ffffffffc0204280:	8082                	ret

ffffffffc0204282 <readline>:
ffffffffc0204282:	715d                	addi	sp,sp,-80
ffffffffc0204284:	e486                	sd	ra,72(sp)
ffffffffc0204286:	e0a2                	sd	s0,64(sp)
ffffffffc0204288:	fc26                	sd	s1,56(sp)
ffffffffc020428a:	f84a                	sd	s2,48(sp)
ffffffffc020428c:	f44e                	sd	s3,40(sp)
ffffffffc020428e:	f052                	sd	s4,32(sp)
ffffffffc0204290:	ec56                	sd	s5,24(sp)
ffffffffc0204292:	e85a                	sd	s6,16(sp)
ffffffffc0204294:	e45e                	sd	s7,8(sp)
ffffffffc0204296:	c901                	beqz	a0,ffffffffc02042a6 <readline+0x24>
ffffffffc0204298:	85aa                	mv	a1,a0
ffffffffc020429a:	00002517          	auipc	a0,0x2
ffffffffc020429e:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206228 <error_string+0xe8>
ffffffffc02042a2:	e1dfb0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02042a6:	4481                	li	s1,0
ffffffffc02042a8:	497d                	li	s2,31
ffffffffc02042aa:	49a1                	li	s3,8
ffffffffc02042ac:	4aa9                	li	s5,10
ffffffffc02042ae:	4b35                	li	s6,13
ffffffffc02042b0:	0000db97          	auipc	s7,0xd
ffffffffc02042b4:	d98b8b93          	addi	s7,s7,-616 # ffffffffc0211048 <buf>
ffffffffc02042b8:	3fe00a13          	li	s4,1022
ffffffffc02042bc:	e39fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc02042c0:	842a                	mv	s0,a0
ffffffffc02042c2:	00054b63          	bltz	a0,ffffffffc02042d8 <readline+0x56>
ffffffffc02042c6:	00a95b63          	bge	s2,a0,ffffffffc02042dc <readline+0x5a>
ffffffffc02042ca:	029a5463          	bge	s4,s1,ffffffffc02042f2 <readline+0x70>
ffffffffc02042ce:	e27fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc02042d2:	842a                	mv	s0,a0
ffffffffc02042d4:	fe0559e3          	bgez	a0,ffffffffc02042c6 <readline+0x44>
ffffffffc02042d8:	4501                	li	a0,0
ffffffffc02042da:	a099                	j	ffffffffc0204320 <readline+0x9e>
ffffffffc02042dc:	03341463          	bne	s0,s3,ffffffffc0204304 <readline+0x82>
ffffffffc02042e0:	e8b9                	bnez	s1,ffffffffc0204336 <readline+0xb4>
ffffffffc02042e2:	e13fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc02042e6:	842a                	mv	s0,a0
ffffffffc02042e8:	fe0548e3          	bltz	a0,ffffffffc02042d8 <readline+0x56>
ffffffffc02042ec:	fea958e3          	bge	s2,a0,ffffffffc02042dc <readline+0x5a>
ffffffffc02042f0:	4481                	li	s1,0
ffffffffc02042f2:	8522                	mv	a0,s0
ffffffffc02042f4:	dfffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
ffffffffc02042f8:	009b87b3          	add	a5,s7,s1
ffffffffc02042fc:	00878023          	sb	s0,0(a5)
ffffffffc0204300:	2485                	addiw	s1,s1,1
ffffffffc0204302:	bf6d                	j	ffffffffc02042bc <readline+0x3a>
ffffffffc0204304:	01540463          	beq	s0,s5,ffffffffc020430c <readline+0x8a>
ffffffffc0204308:	fb641ae3          	bne	s0,s6,ffffffffc02042bc <readline+0x3a>
ffffffffc020430c:	8522                	mv	a0,s0
ffffffffc020430e:	de5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
ffffffffc0204312:	0000d517          	auipc	a0,0xd
ffffffffc0204316:	d3650513          	addi	a0,a0,-714 # ffffffffc0211048 <buf>
ffffffffc020431a:	94aa                	add	s1,s1,a0
ffffffffc020431c:	00048023          	sb	zero,0(s1)
ffffffffc0204320:	60a6                	ld	ra,72(sp)
ffffffffc0204322:	6406                	ld	s0,64(sp)
ffffffffc0204324:	74e2                	ld	s1,56(sp)
ffffffffc0204326:	7942                	ld	s2,48(sp)
ffffffffc0204328:	79a2                	ld	s3,40(sp)
ffffffffc020432a:	7a02                	ld	s4,32(sp)
ffffffffc020432c:	6ae2                	ld	s5,24(sp)
ffffffffc020432e:	6b42                	ld	s6,16(sp)
ffffffffc0204330:	6ba2                	ld	s7,8(sp)
ffffffffc0204332:	6161                	addi	sp,sp,80
ffffffffc0204334:	8082                	ret
ffffffffc0204336:	4521                	li	a0,8
ffffffffc0204338:	dbbfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
ffffffffc020433c:	34fd                	addiw	s1,s1,-1
ffffffffc020433e:	bfbd                	j	ffffffffc02042bc <readline+0x3a>
