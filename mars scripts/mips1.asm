.text
ori $t4, $0, 0xff11
mtc0 $t4, $12
##########  P8 ����������  ##########
ori $t0, $t0, 0x7f2c   ##64λ���ػ���ַ
ori $t1, $t1, 0x7f40   ##�û���������ַ
ori $t2, $t2, 0x7f38   ##����ܻ���ַ
begin:
	sw $s3, -4($t2)  ##�����LED��ʾ
	lw $s0, 0($t0)   ##��ȡ64λ���ش����ĵ�һ��������
	lw $s1, 4($t0)   ##��ȡ64λ���ش����ĵڶ���������
	lw $s2, 0($t1)   ##��ȡ8���û�����������8�ֲ���֮һ
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
	j begin             ##��λ��
     nop
	
add_:addu $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##����ӷ����
     j begin
     nop
sub_:subu $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##����������
     j begin
     nop

and_:and $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##������������
     j begin
     nop

or_: or $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##�����������
     j begin
     nop
     
xor_:xor $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##���������
     j begin
     nop

nor_:nor $s3, $s0, $s1	  ##���в���
     nop
     sw $s3, 4($t2)       ##�����ǽ��
     j begin
     nop

leftshamt:sllv $s3, $s0, $s1	  ##���в���
    	    nop
          sw $s3, 4($t2)       ##�������ƽ��
          j begin
          nop

rightshamt:srlv $s3, $s0, $s1	  ##���в���
    	     nop
           sw $s3, 4($t2)       ##�������ƽ��
           j begin
           nop

.ktext 0x4180
	#sw $0, 0x00007f18($0)     ##���ж�
	lw $t9, 0x00007f10($0)    ##���uart����
	nop
	sw $t9, 0x00007f10($0)    ##���uart����
	no
	eret