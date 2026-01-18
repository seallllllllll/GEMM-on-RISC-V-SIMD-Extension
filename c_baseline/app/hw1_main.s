

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
    .globl main
    .extern get_cycles
    .extern get_instret
    
main:

    # sp+0  : start_cycles
    # sp+4  : start_instret
    # sp+8  : test_result
    addi sp, sp, -12

    jal  ra, get_cycles
    sw   a0, 0(sp)        # start_cycles = a0

    jal  ra, get_instret
    sw   a0, 4(sp)        # start_instret = a0

    # int main(void)
    
    jal ra, test
    sw  a0, 8(sp)
    
    # cycles
    jal  ra, get_cycles
    lw   t0, 0(sp)        # t0 = start_cycles
    sub  t0, a0, t0       # t0 = end_cycles - start_cycles

    # print "cycles="
    la   a0, msg_cycles   # a0 = &"cycles="
    jal  ra, print_str


    # print num
    mv   a0, t0
    jal  ra, print_int

    # instret
    jal  ra, get_instret
    lw   t0, 4(sp)        # t0 = start_instret
    sub  t0, a0, t0       # t0 = end_instret - start_instret
    la   a0, msg_instret
    jal  ra, print_str
    mv   a0, t0
    jal  ra, print_int

    jal ra, print_nl



    lw   a0, 8(sp)        # a0 = test_result
    addi sp, sp, 12       # Free the stack we just malloc’ed.

    
    # if (test() != 0) return 0;
    beq a0, zero, .FAIL
    
    # pass：print OK + return 0
    la   a0, msg_ok
    jal  ra, print_str
    addi a0, zero, 0
    addi a7, zero, 93
    ecall

    
.FAIL:
    # return 1;
    la   a0, msg_fail
    jal  ra, print_str
    
    addi a0, zero, 1
    addi a7, zero, 93
    ecall


# ---- tiny print helpers for rv32emu system emulation (Linux syscalls) ----
# write(fd=a0, buf=a1, len=a2)
write_syscall:
    li   a7, 64           # SYS_write
    ecall
    ret

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
    tail write_syscall

# print '\n'
print_nl:
    addi sp, sp, -16
    li   t0, 10
    sb   t0, 0(sp)
    li   a0, 1            # fd=stdout
    addi a1, sp, 0
    li   a2, 1
    li a7, 64
    ecall
    
    addi sp, sp, 16
    ret

    .section .rodata
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

# a0 = unsigned integer to print (decimal), no div/mul（by RV32I）
print_int:
    addi sp, sp, -32
    sw   ra, 28(sp)

    addi t6, sp, 0        # buf
    mv   t0, t6           # t0 = write cursor
    li   t5, 0            # started = 0

    beqz a0, .L_zero

    la   t1, pow10_tbl    # t1 -> 10^n 表
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

    beqz t5, .L_zero      # all 0

    # write buffer (len = t0 - t6)
    sub  a2, t0, t6
    mv   a1, t6
    li   a0, 1
    call write_syscall
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

.L_zero:
    li   a0, 1
    addi a1, sp, 0
    li   t3, '0'
    sb   t3, 0(sp)
    li   a2, 1
    call write_syscall
    lw   ra, 28(sp)
    addi sp, sp, 32
    ret

test:
    
    # AI
    # Create a 32-byte stack frame and save `ra` and `s0`–`s4`.
    addi  sp, sp, -32
    sw    ra, 28(sp)
    sw    s0,  0(sp)
    sw    s1,  4(sp)
    sw    s2,  8(sp)
    sw    s3, 12(sp)
    sw    s4, 16(sp)
    # test: Prologue
    sw    s5, 20(sp)      # save s5
    li    s5, 0           # printed_once = 0

 
    # int32_t previous_value = -1;
    addi s3, zero, -1        # s3 = previous_value
    # bool passed = true;
    addi s4, zero, 1        # s4 = passed
    
    
    
    
    addi s2, zero, 0        # s2 = i
    # for (int i = 0; i < 256; i++)


test_for_loop:
    addi t3, zero, 256
    bge s2, t3, test_return
    
    # uint8_t fl = i;
    addi t4, s2, 0        # t4 = fl
    # int32_t value = uf8_decode(fl);
    addi a0, t4, 0        
    jal ra, uf8_decode        
    addi t5, a0, 0        # t5 = value
    
    # Generate by AI, to avoid value lost
    add  s0, t4, x0         # save fl
    add  s1, t5, x0         # save value

    
    # uint8_t fl2 = uf8_encode(value);
    add  a0, t5, x0
    jal  ra, uf8_encode
    addi t6, a0, 0          # t6 = fl2

    # Generate by AI
    # Retrieve fl/value before call
    add  t4, s0, x0
    add  t5, s1, x0
    
    # if (fl != fl2)
    beq t4, t6, test_if1_ok
    # printf("%02x: produces value %d but encodes back to %02x\n", fl, value, fl2);
 
    # --- print the first error ---
    bne  s5, x0, 1f
    li   s5, 1

    la   a0, msg_mismatch
    jal  ra, print_str
    add  a0, t4, x0
    jal  ra, print_int

    la   a0, msg_val
    jal  ra, print_str
    add  a0, t5, x0
    jal  ra, print_int

    la   a0, msg_prev
    jal  ra, print_str
    add  a0, s3, x0
    jal  ra, print_int

    la   a0, msg_fl2
    jal  ra, print_str
    add  a0, t6, x0
    jal  ra, print_int

    jal  ra, print_nl
    
   
1:
    li   s4, 0           # passed = false
    
test_if1_ok:
    # if (value <= previous_value)
    # equals to value < (previous_value + 1)
    addi t3, s3, 1
    bge t5, t3, test_if2_ok
    # printf("%02x: value %d <= previous_value %d\n", fl, value, previous_value);
    # --- print the first error ---
    bne  s5, x0, 2f
    li   s5, 1

    la   a0, msg_mono
    jal  ra, print_str
    add  a0, t4, x0
    jal  ra, print_int

    la   a0, msg_val
    jal  ra, print_str
    add  a0, t5, x0
    jal  ra, print_int

    la   a0, msg_prev
    jal  ra, print_str
    add  a0, s3, x0
    jal  ra, print_int

    la   a0, msg_fl2
    jal  ra, print_str
    add  a0, t6, x0
    jal  ra, print_int

    jal  ra, print_nl



2:
    li   s4, 0                # passed = false
    

    
test_if2_ok:
    # previous_value = value;
    addi s3, t5, 0    

    addi s2, s2, 1
    j test_for_loop
    
test_return:
    addi a0, s4, 0
    
    # AI
    # back the callee-saved & ra
    lw    s0,  0(sp)
    lw    s1,  4(sp)
    lw    s2,  8(sp)
    lw    s3, 12(sp)
    lw    s4, 16(sp)
    # test_return: Epilogue
    lw    s5, 20(sp)      # NEW: restore s5
    
    lw    ra, 28(sp)
    addi  sp, sp, 32
    ret

    


# Decode uf8 to uint32_t 
uf8_decode:
    andi t0, a0, 0x0f    # mantissa = fl & 0x0f
    srli t1, a0, 4        # exponent = fl >> 4
    
    # offset = (0x7FFF >> (15 - exponent)) << 4 = 16*(2^E - 1)
    addi t2, zero, 1        # t2 = 1
    sll t2, t2, t1        # 2^E
    addi t2, t2, -1        # 2^E - 1
    slli t2, t2, 4        # offset = t2 = 16*(2^E - 1)
    
    # return (mantissa << exponent) + offset;
    sll t0, t0, t1        # mantissa << exponent
    add a0, t0, t2        # return a0 = (mantissa << exponent) + offset
    ret
    
 
clz:
    addi t0, zero, 32                # int n = t0 = 32, c = t1 = 16;
    addi t1, zero, 16
    add t2, zero, a0                # t2 = x        
    
    
clz_loop:  
    srl t3, t2, t1                    # uint32_t t3 = y = x >> c;
    beq t3, zero, clz_skip_if        # if (y) {}
    sub t0, t0, t1                    # n -= c;
    add t2, t3, zero                   # x = y;

               
clz_skip_if:
    srli t1, t1, 1                # c >>= 1;
    bne t1, zero, clz_loop        # while (c);
    
    
# by AI, to avoid missing the route or having to rerun       
clz_exit:
    sub a0, t0, t2                # return n - x;
    ret



# Encode uint32_t to uf8  
# a0 = value
uf8_encode:
    
    addi sp, sp, -16        # 16-byte
    sw   ra, 12(sp)         # Save the return address ra for returning to test.

    
    li   t0, 16
    blt  a0, t0, .L_ret

    mv   t6, a0                  # save value
    add  a0, a0, t0              # a0 = u = value + 16
    jal  ra, clz                 # a0 = clz(u)
    li   t1, 31
    sub  t2, t1, a0              # msb = 31 - clz(u)
    addi t3, t2, -4              # E = msb - 4

    # E to [0,15]
    slti t4, t3, 0
    beqz t4, 1f
    mv   t3, x0
1:  li   t5, 15
    ble  t3, t5, 2f
    mv   t3, t5
2:
    li   t1, 1
    sll  t1, t1, t3              # 1<<E
    addi t1, t1, -1              # (1<<E)-1
    slli t1, t1, 4               # overflow = ((1<<E)-1)<<4

    # Compute the mantissa using the actual value = t6.
    sub  t0, t6, t1              # value - overflow
    srl  t0, t0, t3              # >> E
    andi t0, t0, 0x0F            # mant

    slli t3, t3, 4               # E<<4
    or   a0, t3, t0              # (E<<4)|mant
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
.L_ret:
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
