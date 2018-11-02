li $a0, 0
li $t0, 0
addi $s0, $gp, 0
addi $v0, $gp, 4
LOOP:
lw $t1, 0($v0)
BEQ $t1, $a0, FIM
add $t0, $t0, $t1
addi $v0, $v0, 4
j LOOP
FIM:
sw $t0, 0($s0)