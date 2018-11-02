li $a0, 0
li $a1, 0
li $a3, 0
addi $v0, $gp, 64
addi $v1, $gp, 128
addi $t0, $gp, 0
LOOP:
lw $s0, 0($v0)
lw $s1, 0($v1)
beq $s0, $a0, FIM
beq $s1, $a0, FIM
addi $a3, $a3, 1
sub $a1, $s0, $s1
sw $a1, 0($t0)
addi $v0, $v0, 4
addi $v1, $v1, 4
addi $t0, $t0, 4
j LOOP
FIM:
addi $t0, $gp, 0
li $t1, 0
LOOP2:
beq $a3, $a0, FIM2
subi $a3, $a3, 1
lw $a1, 0($t0)
slt $t2, $a1, $a0
add $t1, $t1, $t2
addi $t0, $t0, 4
j LOOP2
FIM2:
sw $t1, 192($gp)