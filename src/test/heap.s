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



# TODO: The print is really nice,
# but this is kinda garbage because
# it only tests what's hardcoded here.
# Need to turn into program where you
# can enter commands to test exactly
# what you want.

.align 2
.section .text

.global heap_test
heap_test:
    addi    sp, sp, -(9*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 2*8(sp)
    sd      s2, 3*8(sp)
    sd      s3, 4*8(sp)
    sd      s4, 5*8(sp)
    sd      s5, 6*8(sp)
    sd      s6, 7*8(sp)
    sd      s7, 8*8(sp)

    # empty heap

    jal     print_heap
    jal     printnl

    # put stuff on heap

    li      a0, 8*1
    jal     heap_alloc
    move    s2, a0

    jal     print_heap
    jal     printnl

    li      a0, 8*4
    jal     heap_alloc
    li      t0, 0x1111111111111111
    sd      t0, (a0)
    sd      t0, 8(a0)
    sd      t0, 24(a0)
    move    s3, a0

    # put array of stuff on heap

    li      s0, 0x04
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

    # put more stuff

    li      a0, 1
    jal     heap_alloc
    move    s6, a0

    li      a0, 8*1
    jal     heap_alloc
    move    s7, a0

    li      a0, 8*7
    jal     heap_alloc
    li      t0, 0xffff
    sd      t0, 6*8(a0)
    move    s5, a0

    li      a0, 8*3
    jal     heap_alloc
    move    s4, a0

    jal     print_heap
    jal     printnl

    # free stuff

    move    a0, s2      # no merge
    jal     heap_free
    move    a0, s3      # merge backwards
    jal     heap_free
    move    a0, s4      # no merge
    jal     heap_free
    move    a0, s5      # merge forwards
    jal     heap_free
    move    a0, s6      # no merge
    jal     heap_free
    move    a0, s7      # merge both f & b
    jal     heap_free

    jal     print_heap
    jal     printnl

    # allocate more stuff

    li      a0, 8       # initial test
    jal     heap_alloc

    li      a0, 15*8    # fill in end
    jal     heap_alloc

    li      a0, 9*8    # too much for front
    jal     heap_alloc

    li      a0, 1*8    # enough for front
    jal     heap_alloc

    jal     print_heap

    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1, 2*8(sp)
    ld      s2, 3*8(sp)
    ld      s3, 4*8(sp)
    ld      s4, 5*8(sp)
    ld      s5, 6*8(sp)
    ld      s6, 7*8(sp)
    ld      s7, 8*8(sp)
    addi    sp, sp, +(9*8)
    ret

print_heap:
    addi    sp, sp, -8
    sd      ra, 0(sp)

    jal     print_heap_info
    jal     print_heap_blocks

    ld      ra, 0(sp)
    addi    sp, sp, +8
    ret

print_heap_blocks:
    addi    sp, sp, -(3*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 16(sp)

    # blocks

    la      a0, block_msg
    lw      a1, -4(a0)
    jal     println

    la      t0, heap_info
    ld      s0, 24(t0)
    ld      s1, 32(t0)
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

    jal     printnl
    jal     print_space
    jal     print_space
    jal     print_space
    jal     print_space

    ld      a0, 8(s0)
    jal     print_hex
    jal     print_space

    ld      a0, 16(s0)
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
    addi    sp, sp, +(3*8)
    ret

print_heap_info:
    addi    sp, sp, -(4*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 16(sp)
    sd      s2, 24(sp)

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
    li      s2, 5
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

    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    ld      s2, 24(sp)
    addi    sp, sp, +(4*8)
    ret
