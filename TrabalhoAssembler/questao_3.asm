lw $a0, 0($gp)
lw $a1, 4($gp)
li $t0, 0
li $v0, 0
LOOP:
beq $a0, $v0, FIM
add $t0, $t0, $a1
subi $a0, $a0, 1
j LOOP
FIM:
sw $t0, 8($gp)