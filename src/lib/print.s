.section .rodata

newline:
    .half '\n'
space:
    .half ' '



.align 2
.section .text

# only uses a regs for convenience
#
# args:
# a0 - string
# a1 - length
.global print
print:
    addi    sp, sp, -8
    sd      ra, (sp)

    move    a2, a1
    move    a1, a0
    li      a0, 1 # stdout
    jal write

    ld      ra, (sp)
    addi    sp, sp, +8
    ret

# only uses a regs for convenience
.global printnl
printnl:
    addi    sp, sp, -8
    sd      ra, (sp)

    la      a0, newline
    li      a1, 1
    jal     print

    ld      ra, (sp)
    addi    sp, sp, +8
    ret

# only uses a regs for convenience
#
# args:
# a0 - string
# a1 - length
.global println
println:
    addi    sp, sp, -8
    sd      ra, (sp)

    jal     print
    jal     printnl

    ld      ra, (sp)
    addi    sp, sp, +8
    ret

.global print_space
print_space:
    addi    sp, sp, -8
    sd      ra, (sp)

    la      a0, space
    li      a1, 1
    jal     print

    ld      ra, (sp)
    addi    sp, sp, +8
    ret

# args:
# a0 - the hex value to print
.global print_hex
print_hex:
    addi    sp, sp, -(8+16)
    sd      ra, (sp)

    jal     format_hex
    addi    t0, sp, 8
    sd      a0, 0(t0)
    sd      a1, 8(t0)

    move    a0, t0
    li      a1, 16
    jal     print

    ld      ra, (sp)
    addi    sp, sp, +(8+16)
    ret

