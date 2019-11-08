.text
ori $t4, $0, 0xff11
mtc0 $t4, $12
##########  P8 计算器程序  ##########
ori $t8, $t8, 8        ##产生8个4位二进制数

ori $t0, $t0, 0x7f2c   ##64位开关基地址
ori $t1, $t1, 0x7f40   ##用户按键基地址
ori $t2, $t2, 0x7f38   ##数码管基地址
begin:
	#sw $s3, -4($t2)  ##结果用LED表示
	#lw $s0, 0($t0)   ##读取64位开关传来的第一个操作数
	#lw $s1, 4($t0)   ##读取64位开关传来的第二个操作数
	ori $t9, $t9, 0
	and $s6, $s6, 28
	lw $s2, 0($t1)   ##读取8个用户按键传来的8种操作之一
	beq $s2, 1, load
	nop 
	j begin
	nop
load: lw $s1, 4($t0)   ##读取64位开关传来的第二个操作数
	ori $s3, $s1, 0
	
first:beq $t9, $t8, exit
	nop
	srlv $s5, $s1, $s6
	sw $s5, 0x00007f10($0)
	addi $s6, $s6, -4
	addi $t9, $t9, 1
	j first
	nop
exit: sw $s3, 4($t2)
	j begin
	nop
	

.ktext 0x4180
	#sw $0, 0x00007f18($0)     ##关中断
	lw $t9, 0x00007f10($0)    ##获得uart数据
	nop
	sw $t9, 0x00007f10($0)    ##输出uart数据
	nop
	eret