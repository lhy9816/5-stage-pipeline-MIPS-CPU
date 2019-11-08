.text
ori $t4, $0, 0xff11
mtc0 $t4, $12
ori $3, $0, 1
sw $3, 0x00007f18($0)
loop:
sw $3, 0x10000000($0)
addi $5, $5, 1
j loop
nop
.ktext 0x4180
#sw $0, 0x00007f18($0)
sw $3, 0x00007f10($0)
lw $4, 0x00007f10($0)