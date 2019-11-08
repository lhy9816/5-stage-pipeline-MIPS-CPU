.text
##########counter##########
begin:
	ori $s0, $0, 0xff11
	mtc0 $s0, $12
	ori $s0, $0, 9           ##给timer0_ctrl赋初值 
	ori $s1, $0, 0x017d7000  ##给count的初值
	sw $s1, 0x00007f04($0)   ##给PRESET赋初值
	sw $s0, 0x00007f00($0)   ##开始计时
detect:
	lw $t0, 0x00007f2c($0)   ##当前开关输入值
	bne $t0, $s0, decline
	nop
	j detect
	nop
decline:
	ori $s0, $t0, 0          ##s0改为当前开关输入值
	sw $s0, 0x00007f3c($0)
	j detect
	nop

.ktext 0x4180
	ori $t9, $0, 9
	ori $t8, $0, 1
	lw $s7, 0x00007f3c($0)
	subu $s7, $s7, $t8
	sw $s7, 0x00007f3c($0)
	sw $t9, 0x00007f00($0)
	eret
	