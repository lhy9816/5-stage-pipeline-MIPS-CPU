.text
ori $t4, $0, 0xff11
mtc0 $t4, $12
##########  P8 计算器程序  ##########
ori $t0, $t0, 0x7f2c   ##64位开关基地址
ori $t1, $t1, 0x7f40   ##用户按键基地址
ori $t2, $t2, 0x7f38   ##数码管基地址
begin:
	sw $s3, -4($t2)  ##结果用LED表示
	lw $s0, 0($t0)   ##读取64位开关传来的第一个操作数
	lw $s1, 4($t0)   ##读取64位开关传来的第二个操作数
	lw $s2, 0($t1)   ##读取8个用户按键传来的8种操作之一
	beq $s2, 1, add_
	nop
	beq $s2, 2, sub_
	nop
	beq $s2, 4, and_
	nop
	beq $s2, 8, or_
	nop
	beq $s2, 16, xor_
	nop
	beq $s2, 32, nor_
	nop
	beq $s2, 64, leftshamt
	nop
	beq $s2, 128, rightshamt
	nop
	j begin             ##复位后
     nop
	
add_:addu $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入加法结果
     j begin
     nop
sub_:subu $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入减法结果
     j begin
     nop

and_:and $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入与操作结果
     j begin
     nop

or_: or $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入或操作结果
     j begin
     nop
     
xor_:xor $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入异或结果
     j begin
     nop

nor_:nor $s3, $s0, $s1	  ##进行操作
     nop
     sw $s3, 4($t2)       ##存入或非结果
     j begin
     nop

leftshamt:sllv $s3, $s0, $s1	  ##进行操作
    	    nop
          sw $s3, 4($t2)       ##存入左移结果
          j begin
          nop

rightshamt:srlv $s3, $s0, $s1	  ##进行操作
    	     nop
           sw $s3, 4($t2)       ##存入右移结果
           j begin
           nop

.ktext 0x4180
	#sw $0, 0x00007f18($0)     ##关中断
	lw $t9, 0x00007f10($0)    ##获得uart数据
	nop
	sw $t9, 0x00007f10($0)    ##输出uart数据
	no
	eret