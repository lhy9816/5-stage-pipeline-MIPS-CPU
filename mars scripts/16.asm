.text
ori $t4, $0, 0xff11
mtc0 $t4, $12
##########  P8 ����������  ##########
ori $t8, $t8, 8        ##����8��4λ��������

ori $t0, $t0, 0x7f2c   ##64λ���ػ���ַ
ori $t1, $t1, 0x7f40   ##�û���������ַ
ori $t2, $t2, 0x7f38   ##����ܻ���ַ
begin:
	#sw $s3, -4($t2)  ##�����LED��ʾ
	#lw $s0, 0($t0)   ##��ȡ64λ���ش����ĵ�һ��������
	#lw $s1, 4($t0)   ##��ȡ64λ���ش����ĵڶ���������
	ori $t9, $t9, 0
	and $s6, $s6, 28
	lw $s2, 0($t1)   ##��ȡ8���û�����������8�ֲ���֮һ
	beq $s2, 1, load
	nop 
	j begin
	nop
load: lw $s1, 4($t0)   ##��ȡ64λ���ش����ĵڶ���������
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
	#sw $0, 0x00007f18($0)     ##���ж�
	lw $t9, 0x00007f10($0)    ##���uart����
	nop
	sw $t9, 0x00007f10($0)    ##���uart����
	nop
	eret