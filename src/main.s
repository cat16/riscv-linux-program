.align 2
.section .text

.global main
main:
    addi    sp, sp, -8
    sd      ra, 0(sp)

    # do stuff

    #jal     write_test
    jal     heap_test

    # exit with code 0

    ld      ra, 0(sp)
    addi    sp, sp, +8

    li      a0, 0
    ret
