.align 2
.section .text

.global _start
_start:
    jal     heap_init
    jal     main
    j       exit

