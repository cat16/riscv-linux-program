.align 2
.section .text



# args:
# a0 - number
#
# returns:
# a0,a1 - hex string
.global format_hex
format_hex:
    addi    sp, sp, -(3*8)
    sd      ra, 0(sp)
    sd      s0, 8(sp)
    sd      s1, 16(sp)

    move    s0, a0
    jal     format_hex_lower
    move    s1, a0

    srli    a0, s0, 32
    jal     format_hex_lower

    move    a1, s1

    ld      ra, 0(sp)
    ld      s0, 8(sp)
    ld      s1, 16(sp)
    addi    sp, sp, +(3*8)
    ret

# args:
# a0 - number
#
# returns:
# a0 - lower hex string
.global format_hex_lower
format_hex_lower:
    move    t0, a0
    li      t1, 0xffffffff
    and     t0, t0, t1
    li      a0, 0
    li      t1, 8*7
    li      t4, 16*4
0:
    bltz    t1, 0f

    andi    t2, t0, 0xf
    addi    t2, t2, 0x30
    li      t3, 0x30+9
    ble     t2, t3, 1f
    addi    t2, t2, 0x61-0x30-10
1:
    sll     t2, t2, t1
    addi    t1, t1, -8
    srli    t0, t0, 4
    or      a0, a0, t2
    j       0b
0:
    ret

