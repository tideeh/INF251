li $a0, 0
li $a1, 0
addi $v0, $gp, 64
addi $v1, $gp, 128
addi $t0, $gp, 0
LOOP:
lw $s0, 0($v0)
lw $s1, 0($v1)
beq $s0, $a0, FIM
beq $s1, $a0, FIM
sub $a1, $s0, $s1
sw $a1, 0($t0)
addi $v0, $v0, 4
addi $v1, $v1, 4
addi $t0, $t0, 4
j LOOP
FIM: