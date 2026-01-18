
    .data
msg_mismatch:  .asciz "FAIL[re-encode] fl="
msg_mono:      .asciz "FAIL[monotonic] fl="
msg_val:       .asciz " val="
msg_prev:      .asciz " prev="
msg_fl2:       .asciz " fl2="
msg_ok:        .asciz "All tests passed.\n"
msg_fail:      .asciz "FAILED\n"
msg_cycles:    .asciz "Cycles: "
msg_instret:   .asciz "\nInstructions: "

    .text
    .globl  main
    .extern get_cycles
    .extern get_instret
    
main:

    .section .rodata
    .align 2
obdata:     .byte   0x3c, 0x3b, 0x3a

str1:       .asciz  "Move Disk "
str2:       .asciz  " from "
str3:       .asciz  " to "

    .align 2
pow10_tbl:
    .word 1000000000
    .word 100000000
    .word 10000000
    .word 1000000
    .word 100000
    .word 10000
    .word 1000
    .word 100
    .word 10
    .word 1


    .section .text


    # stack layout:
    # sp+0   : saved x8
    # sp+4   : saved x9
    # sp+8   : saved x18
    # sp+12  : saved x19
    # sp+16  : saved x20
    # sp+20  : disk[0]
    # sp+24  : disk[1]
    # sp+28  : disk[2]
    # sp+32  : start_cycles
    # sp+36  : start_instret

    addi    x2, x2, -40
    sw      x8, 0(x2)
    sw      x9, 4(x2)
    sw      x18, 8(x2)
    sw      x19, 12(x2)
    sw      x20, 16(x2)

    # Initialize the three disk positions to (0, 0, 0).
    sw      x0, 20(x2)
    sw      x0, 24(x2)
    sw      x0, 28(x2)

    addi    x8, x0, 1      # move counter = 1


    # Fix disk positions (BLANK 1-3: neutralize x5 effect)
    # BLANK 1: Fix position at x2+20
    sw      x0, 20(x2)

    # BLANK 2: Fix position at x2+24
    sw      x0, 24(x2)

    # BLANK 3: Fix position at x2+28
    sw      x0, 28(x2)

    addi    x8, x0, 1

    # ---- record start cycles / instret ----
    jal     ra, get_cycles
    sw      a0, 32(x2)         # start_cycles

    jal     ra, get_instret
    sw      a0, 36(x2)         # start_instret

game_loop:



    # BLANK 4: Check loop termination (2^3 moves)
    addi    x5, x0, 8
    beq     x8, x5, finish_game

    # Gray code formula: gray(n) = n XOR (n >> k)
    # BLANK 5: What is k for Gray code?
    srli    x5, x8, 1

    # BLANK 6: Complete Gray(n) calculation
    xor     x6, x8, x5

    # BLANK 7-8: Calculate previous value and its shift
    addi    x7, x8, -1
    srli    x28, x7, 1

    # BLANK 9: Generate Gray(n-1)
    xor     x7, x7, x28

    # BLANK 10: Which bits changed?
    xor     x5, x6, x7

    # Initialize disk number
    addi    x9, x0, 0

    # BLANK 11: Mask for testing LSB
    andi    x6, x5, 1

    # BLANK 12: Branch if disk 0 moves
    bne     x6, x0, disk_found

    # BLANK 13: Set disk 1
    addi    x9, x0, 1

    # BLANK 14: Test second bit with proper mask
    andi    x6, x5, 2
    bne     x6, x0, disk_found

    # BLANK 15: Last disk number
    addi    x9, x0, 2


disk_found:
    # BLANK 16: Check impossible pattern (multiple bits)


    andi    x30, x5, 5
    addi    x31, x0, 5
    beq     x30, x31, pattern_match
    jal     x0, continue_move
pattern_match:
continue_move:

    # BLANK 17: Word-align disk index (multiply by what?)
    slli    x5, x9, 2

    # BLANK 18: Base offset for disk array
    addi    x5, x5, 20
    add     x5, x2, x5
    lw      x18, 0(x5)

    bne     x9, x0, handle_large

    # BLANK 19: Small disk moves by how many positions?
    addi    x19, x18, 2

    # BLANK 20: Number of pegs
    addi    x6, x0, 3
    blt     x19, x6, display_move
    sub     x19, x19, x6
    jal     x0, display_move

handle_large:
    # BLANK 21: Load reference disk position

    lw      x6, 20(x2)

    # BLANK 22: Sum of all peg indices (0+1+2)
    addi    x19, x0, 3
    sub     x19, x19, x18
    sub     x19, x19, x6

display_move:

    # print "Move Disk " + num + " from "
    la   x10, str1
    jal  ra, print_str

    addi t0, x9, 1
    addi t0, t0, 48
    mv   a0, t0
    jal  ra, print_char

    la   x10, str2
    jal  ra, print_str

    # -- Only decode the source/destination letters at this point --

    la   x20, obdata

    # source
    add  x5, x20, x18
    lbu  t0, 0(x5)
    li   t1, 0x6F
    xor  t0, t0, t1
    addi t0, t0, -0x12
    mv   a0, t0
    jal  ra, print_char

    # " to "
    la   x10, str3
    jal  ra, print_str

    add  x7, x20, x19
    lbu  t0, 0(x7)
    li   t1, 0x6F
    xor  t0, t0, t1
    addi t0, t0, -0x12
    mv   a0, t0
    jal  ra, print_char

    jal  ra, print_nl


    # BLANK 26: Calculate storage offset
    slli    x5, x9, 2
    addi    x5, x5, 20
    add     x5, x2, x5

    # BLANK 27: Update disk position
    sw      x19, 0(x5)

    # BLANK 28-29: Increment counter and loop
    addi    x8, x8, 1
    jal     x0, game_loop

# a0 = address of NUL-terminated string
print_str:
    mv   t0, a0           # t0 = s
    mv   t1, a0           # t1 = p
1:  lbu  t2, 0(t1)
    beq  t2, x0, 2f
    addi t1, t1, 1
    j    1b
2:  sub  a2, t1, t0       # len = p - s
    mv   a1, t0           # buf = s
    li   a0, 1            # fd = stdout
    li   a7, 64           # SYS_write
    ecall
    ret

# a0 = char value
print_char:
    addi sp, sp, -16
    sb   a0, 0(sp)

    li   a0, 1
    addi a1, sp, 0        # buf = sp
    li   a2, 1
    li   a7, 64           # write
    ecall                 # <<  ecall，no more calling

    addi sp, sp, 16
    ret

# print '\n'
print_nl:
    addi sp, sp, -16
    li   t0, 10
    sb   t0, 0(sp)
    li   a0, 1            # fd=stdout
    addi a1, sp, 0
    li   a2, 1
    li   a7, 64           # SYS_write
    ecall
    addi sp, sp, 16
    ret

# a0 = unsigned integer to print (decimal), no div/mul（RV32I）
print_int:
    addi sp, sp, -32
    sw   ra, 28(sp)

    addi t6, sp, 0        # buf
    mv   t0, t6           # t0 = write cursor
    li   t5, 0            # started = 0

    beqz a0, .L_zero

    la   t1, pow10_tbl    # t1 -> 10^n
    li   t2, 10           # 10 entries

.L_loop_digit:
    lw   t3, 0(t1)        # C = *t1
    li   t4, 0            # digit = 0
.L_sub:
    bltu a0, t3, .L_emit  # if a0 < C -> emit
    sub  a0, a0, t3
    addi t4, t4, 1
    j    .L_sub
.L_emit:
    bnez t5, .L_store
    beqz t4, .L_next      # skip leading zeros
    li   t5, 1            # started = 1
.L_store:
    addi t4, t4, 48       # '0' + digit
    sb   t4, 0(t0)
    addi t0, t0, 1

.L_next:
    addi t1, t1, 4
    addi t2, t2, -1
    bnez t2, .L_loop_digit

    beqz t5, .L_zero      # for all 0 situation

    # write buffer (len = t0 - t6)
    sub  a2, t0, t6
    mv   a1, t6
    li   a0, 1
    li   a7, 64           # SYS_write
    ecall
    ret
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

.L_zero:
    li   a0, 1
    addi a1, sp, 0
    li   t3, '0'
    sb   t3, 0(sp)
    li   a2, 1
    li   a7, 64           # SYS_write
    ecall
    ret
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

finish_game:
    # ---- cycles: end - start ----
    jal     ra, get_cycles
    lw      t0, 32(x2)         # t0 = start_cycles
    sub     t0, a0, t0         # t0 = end_cycles - start_cycles

    la      a0, msg_cycles     # "Cycles: "
    jal     ra, print_str
    mv      a0, t0
    jal     ra, print_int

    # ---- instret: end - start ----
    jal     ra, get_instret
    lw      t0, 36(x2)         # t0 = start_instret
    sub     t0, a0, t0         # t0 = end_instret - start_instret

    la      a0, msg_instret    # "\nInstructions: "
    jal     ra, print_str
    mv      a0, t0
    jal     ra, print_int

    jal     ra, print_nl

    # ---- restore callee-saved regs & stack ----
    lw      x8, 0(x2)
    lw      x9, 4(x2)
    lw      x18, 8(x2)
    lw      x19, 12(x2)
    lw      x20, 16(x2)
    addi    x2, x2, 40

    # exit(0)
    li      a0, 0
    li      a7, 93
    ecall


