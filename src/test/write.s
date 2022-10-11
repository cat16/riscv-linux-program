.equ PATH_MAX,  255

.section .rodata

    .word 0f - start_msg
start_msg:
    .string "Writing file..."
0:

    .word 0f - file_name
file_name:
    .string "test.txt"
0:

    .word 0f - content
content:
    .string "Hello world!\n"
0:



.align 2
.section .text

.global write_test
write_test:
    addi    sp, sp, -8-PATH_MAX
    sd      ra, 0(sp)

    # print msg

    la      a0, start_msg
    lw      a1, -4(a0)
    jal     println

    # open file

    li      a0, -100
    la      a1, file_name
    li      a2, 01102       # TRUNC | CREAT | RDWR
    li      a3, 0b110100100 # -rw-r--r--
    jal     openat

    # write to file

    la      a1, content
    lw      a2, -4(a1)
    jal     write

    # return

    ld      ra, 0(sp)
    addi    sp, sp, +8+PATH_MAX

    ret
