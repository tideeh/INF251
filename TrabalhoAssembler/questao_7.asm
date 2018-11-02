li $a0, 0
li $s2, 0
lw $s0, 0($gp)
addi $v0, $gp, 4
LOOP:
lw $t1, 0($v0)
BEQ $t1, $a0, FIM
seq $s1, $t1, $s0
add $s2, $s2, $s1
addi $v0, $v0, 4
j LOOP
FIM: