# This is a heap implemented with brk.
# It's slow / unoptimized, and only for
# learning how to set up a basic heap

# mask and imask are used to floor & ceil
# to get correct bounds
.equ align_imask,   0b111
.equ align_mask,    ~align_imask

.equ prev_used,     0b001
.equ size_mask,     align_mask

# block node

.equ bsize, 0
.equ fb_next, 8     # free only
# free also contains its address at the end

# sizes of metadata

.equ sizeof_fb, (8*3 + align_imask) & align_mask
.equ sizeof_ub, (8*1 + align_imask) & align_mask

.equ PAGE_SIZE, 4096



.align 2
.section .rodata

.word 0f - heap_oom
heap_oom:
    .string "Heap ran out of memory!\n"
0:

.section .data

.align 4
.global heap_info           # global for testing only
.equ heap_last_used,    0   # last free block will set this
.equ heap_first_free,   8   # matches fb_next
.equ heap_start,        16
.equ heap_end,          24
heap_info:
    .dword 0
    .dword 0
    .dword __global_pointer$
    .dword 0



.align 2
.section .text

.global heap_init
heap_init:
    addi    sp, sp, -8
    sd      ra, 0(sp)

    # get heap info (t0)

    la      t0, heap_info

    # set heap start (t1)

    ld      t1, heap_start(t0)
    addi    t1, t1, align_imask
    andi    t1, t1, align_mask
    sd      t1, heap_start(t0)

    # set heap end (a0)
    # also calculate heap size (t2)

    li      a0, 0
    jal     brk
    andi    a0, a0, align_mask
    sub     t2, a0, t1          # size = end - start (t2)
    li      t3, sizeof_fb
    bgeu    t2, t3, 0f          # check if enough mem to start

    move    a1, a0
    add     a0, t1, t3
    jal     brk_or_panic        # if not, get more
    sub     t2, a0, t1          # recalc size (t2)
0:
    sd      a0, heap_end(t0)

    # create initial free block

    ori     t2, t2, prev_used   # add prev used
    sd      t2, bsize(t1)       # store size
    sd      t0, fb_next(t1)     # store next
    sd      t1, -8(a0)          # store addr at end

    sd      t1, heap_first_free(t0)

    ld      ra, 0(sp)
    addi    sp, sp, +8
    ret

# args:
# a0 - size
#
# returns:
# a0 - address
.global heap_alloc
heap_alloc:
    addi    sp, sp, -8
    sd      ra, 0(sp)

    # align size properly (t0)

    move    t0, a0
    addi    t0, t0, sizeof_ub
    addi    t0, t0, align_imask
    andi    t0, t0, align_mask

    # get a free block that will fit (t1)
    # and its free space

    la      t3, heap_info
    ld      t4, heap_first_free(t3)
    ld      a1, heap_end(t3)

    move    t6, t3              # prev block (t6)

    bne     t4, t3, 0f          # if no free blocks
    move    t4, a1              # pretend end is start
    j       3f
0:

    move    t1, t4              # current block (t1)

0:
    ld      t2, bsize(t1)       # size of current block (t2)
    andi    t2, t2, size_mask
    bgeu    t2, t0, 0f          # is it big enough
    ld      t5, fb_next(t1)     # if not, get the next
    beq     t5, t3, 1f
    move    t6, t1
    move    t1, t5
    j       0b
1:  # if no blocks are big enough
    add     t5, t1, t2          # get end of last free block
    beq     t5, a1, 2f          # if no free block at end of heap:
    move    t6, t1
3:
    move    t1, a1              # immitate new free block at end
2:
    add     a0, t1, t0          # get needed heap end (a0)
    jal     brk_or_panic        # set heap end (a0)
    sd      a0, heap_end(t3)    # update end in info
    sub     t2, a0, t1          # new free space (t2)
    andi    t5, t2, prev_used   # prev used bit
    sd      t5, bsize(t1)       # update size
    sd      t3, fb_next(t1)     # update next (for case 3)
0:

    # deal with extra free space

    sub     t5, t2, t0          # unneeded free space (t5)
    li      t4, sizeof_fb
    bltu    t5, t4, 0f          # check if enough for a free block

    add     t3, t1, t0          # if so, get addr (t3)
    sd      t3, fb_next(t6)     # set prev block next to new
    add     t6, t3, t5          # store addr at end
    sd      t3, -8(t6)
    ori     t6, t5, prev_used   # store size with prev in use
    sd      t6, bsize(t3)
    ld      t6, fb_next(t1)     # copy next
    sd      t6, fb_next(t3)
    j       1f
0:
    move    t0, t2              # if no space, fill in with used
    ld      t4, fb_next(t1)
    sd      t4, fb_next(t6)     # set prev next to cur next
    ld      t4, heap_end(t3)
    add     t3, t1, t0
    beq     t3, t4, 1f          # if this is not at the end
    ld      t4, bsize(t3)       # set next's prev used to 1
    ori     t4, t4, prev_used
    sd      t4, bsize(t3)
1:

    # create used block

    add     t2, t0, t1          # end of block
    ori     t0, t0, prev_used   # prev used bit
    sd      t0, bsize(t1)       # store size
    sd      zero, fb_next(t1)   # remove free block stuff
    sd      zero, -8(t2)

    move    a0, t1
    addi    a0, a0, sizeof_ub

    ld      ra, 0(sp)
    addi    sp, sp, +8
    ret

# args:
# a0 - address
.global heap_free
heap_free:
    ret

# args:
# a0 - min address needed
# a1 - old address
#
# returns:
# a0 - new address, aligned
brk_or_panic:
    addi    sp, sp, -8
    sd      ra, 0(sp)

    jal     brk
    andi    a0, a0, align_mask
    bgtu    a0, a1, 0f      # make sure brk worked
    la      a0, heap_oom    # if not, panic
    lw      a1, -4(a0)
    j       panic
0:
    ld      ra, 0(sp)
    addi    sp, sp, +8
    ret
