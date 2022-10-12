.section .rodata

.word 0f - hinfo_msg
hinfo_msg:
    .string "Current heap info:"
0:

.word 0f - block_msg
block_msg:
    .string "Current heap blocks:"
0:

.word 0f - dots
dots:
    .string "..."
0:

.word 0f - hexstr
hexstr:
    .string "0x"
0:



.align 2
.section .text

.global heap_test
heap_test:
    addi    sp, sp, -(3*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 16(sp)

    # empty heap

    jal     print_heap
    jal     printnl

    # put stuff on heap

    li      a0, 8*4
    jal     heap_alloc
    li      t0, 0x1111111111111111
    sd      t0, (a0)
    sd      t0, 8(a0)
    sd      t0, 24(a0)

    li      s0, 0x0f
0:
    bltz    s0, 0f

    li      a0, 8*3
    jal     heap_alloc
    sd      s0, (a0)
    li      t0, 0xf000000000000000
    add     t0, s0, t0
    sd      t0, 16(a0)

    addi    s0, s0, -1
    j       0b
0:

    li      a0, 8*7
    jal     heap_alloc
    li      t0, 0xffff
    sd      t0, 6*8(a0)

    li      a0, 8*3
    jal     heap_alloc

    jal     print_heap

    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    addi    sp, sp, +(3*8)
    ret

print_heap:
    addi    sp, sp, -(4*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 16(sp)
    sd      s2, 24(sp)

    # info

    la      a0, hinfo_msg
    lw      a1, -4(a0)
    jal     print
    jal     print_space

    la      a0, hexstr
    lw      a1, -4(a0)
    jal     print

    la      s0, heap_info
    move    a0, s0
    jal     print_hex
    jal     printnl

    li      s1, 0
    li      s2, 4
0:
    beq     s1, s2, 0f
    jal     print_space
    jal     print_space
    li      t1, 8
    mul     t0, s1, t1
    add     t0, s0, t0
    ld      a0, 0(t0)
    jal     print_hex
    jal     printnl
    addi    s1, s1, 1
    j       0b
0:

    # blocks

    la      a0, block_msg
    lw      a1, -4(a0)
    jal     println

    la      t0, heap_info
    ld      s0, 16(t0)
    ld      s1, 24(t0)
0:
    jal     print_space
    jal     print_space

    la      a0, hexstr
    lw      a1, -4(a0)
    jal     print
    move    a0, s0
    jal     print_hex
    jal     print_space

    ld      a0, 0(s0)
    jal     print_hex
    jal     print_space

    ld      a0, 8(s0)
    jal     print_hex
    jal     print_space

    la      a0, dots
    lw      a1, -4(a0)
    jal     print
    jal     print_space

    ld      t0, 0(s0)
    andi    t0, t0, ~0b11
    add     t0, s0, t0
    ld      a0, -8(t0)
    move    s0, t0
    jal     print_hex
    jal     printnl

    beq     s0, s1, 0f
    j 0b
0:

    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    ld      s2, 24(sp)
    addi    sp, sp, +(4*8)
    ret
