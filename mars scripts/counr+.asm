.text
##########counter##########
begin:
	ori $t7, $0, 0
	ori $t6, $0, 10
	ori $s0, $0, 0xff11
	mtc0 $s0, $12
	ori $s0, $0, 9           ##��timer0_ctrl����ֵ 
	ori $s1, $0, 0x02625fff#017d7000  ##��count�ĳ�ֵ
	sw $s1, 0x00007f04($0)   ##��PRESET����ֵ
	sw $s0, 0x00007f00($0)   ##��ʼ��ʱ
detect:
	lw $t0, 0x00007f2c($0)   ##��ǰ��������ֵ
	bne $t0, $s0, decline
	nop
	j detect
	nop
decline:
	ori $s0, $t0, 0          ##s0��Ϊ��ǰ��������ֵ
	sw $s0, 0x00007f3c($0)
	j detect
	nop

.ktext 0x4180
	ori $t9, $0, 9
	ori $t8, $0, 1
	lw $s7, 0x00007f3c($0)
	subu $s7, $s7, $t8
	beq $t7, $t6, init
	nop
	sw $t7, 0x00007f10($0)   ##����ô��ڱ�ʾ
	addi $t7, $t7, 1
	j next
	nop
init:
	ori $t7, $0, 0
	sw $t7, 0x00007f10($0)   ##����ô��ڱ�ʾ
	addi $t7, $t7, 1
next:
	sw $s7, 0x00007f3c($0)
	sw $t9, 0x00007f00($0)
	eret
	