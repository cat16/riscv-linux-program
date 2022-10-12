.align 2
.section .text

# args:
# a0 - string
#
# returns:
# a0 - length
.global strlen
strlen:
    li      t0, 0
0:
    beq     t0, a1, 0f
    lb      t1, (a0)
    beqz    t1, 0f
    addi    a0, a0, 1
    addi    t0, t0, 1
    j       0b
0:
    move    a0, t0
    ret

# args:
# a0 - dest
# a1 - src
.global strcpy
strcpy:
0:
    lb      t0, (a1)
    sb      t0, (a0)
    beqz    t0, 0f
    addi    a0, a0, 1
    addi    a1, a1, 1
    j       0b
0:
    ret
