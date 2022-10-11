.align 2
.section .text

# args:
# a0 - message
# a1 - length
.global panic
panic:
    jal     print
    li      a0, 1
    j       exit
