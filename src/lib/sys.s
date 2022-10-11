# This contains all syscalls used,
# as functions for convenience.
# These are guaranteed to not modify
# any registers other than the
# arguments needed for the syscalls

.align 2
.section .text

# args:
# a0 - code
.global exit
exit:
    li      a7, 93
    ecall
0: j 0b # loop if failed for safety

# args:
# a0 - relative dir fd;
#      0 for none, -100 for cwd
# a1 - path / name
# a2 - flags
# a3 - mode
#
# returns:
# a0 - fd
.global openat
openat:
    li      a7, 56
    ecall
    ret

# args:
# a0 - fd
# a1 - content buf
# a2 - size
.global write
write:
    li      a7, 64
    ecall
    ret

# args:
# a0 - address to end at
#      returns current addr if 0
.global brk
brk:
    li      a7, 214
    ecall
    ret
