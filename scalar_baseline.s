# scalar_gemm.s (no labels; immediate-only branches/jumps)
# C[i][j] = sum_{k=0..7} A[i][k] * B[k][j]
# A @ 0x000, B @ 0x100 (256), C @ 0x200 (512)
# int32, row-major, N=8

addi x1, x0, 0        # A_base
addi x2, x0, 256      # B_base
addi x3, x0, 512      # C_base
addi x14, x0, 8       # N=8

nop
nop
nop
nop

add  x15, x1, x0      # A_row_ptr
add  x16, x3, x0      # C_row_ptr
addi x4, x0, 0        # i=0

nop
nop
nop
nop

# i_loop @ PC=0x2c
beq  x4, x14, 260     # to done @ PC=0x110

add  x17, x2, x0      # B_col_ptr = B_base + j*4 (j starts 0)
add  x18, x16, x0     # C_ptr     = C_row_ptr + j*4
addi x5, x0, 0        # j=0

nop
nop
nop
nop

# j_loop @ PC=0x4c
beq  x5, x14, 196     # to next_i @ PC=0x0f0

addi x7, x0, 0        # acc=0
nop
nop
nop
nop

add  x19, x15, x0     # A_ptr = &A[i][0]
add  x20, x17, x0     # B_ptr = &B[0][j]
addi x6, x0, 0        # k=0

nop
nop
nop
nop

# k_loop @ PC=0x70
beq  x6, x14, 100       # to k_done @ PC=0x0c4

lw   x8, 0(x19)       # a = A[i][k]
nop
nop
nop

lw   x9, 0(x20)       # b = B[k][j]
nop
nop
nop

mul  x10, x8, x9      # prod
nop
nop
nop

add  x7, x7, x10      # acc += prod
nop
nop
nop

addi x19, x19, 4      # A_ptr += 4
addi x20, x20, 32     # B_ptr += 32  (next row: 8*4 bytes)
addi x6, x6, 1        # k++

nop
nop
nop
nop

j    -96              # back to k_loop @ PC=0x70
nop

# k_done @ PC=0x0c4
sw   x7, 0(x18)       # C[i][j] = acc
nop
nop

addi x5,  x5,  1      # j++
addi x17, x17, 4      # B_col_ptr += 4
addi x18, x18, 4      # C_ptr     += 4
nop
nop
nop
nop

j    -192             # back to j_loop @ PC=0x4c
nop

# next_i @ PC=0x0f0
addi x4,  x4,  1      # i++
addi x15, x15, 32     # A_row_ptr += 32
addi x16, x16, 32     # C_row_ptr += 32
nop
nop
nop
nop

j    -256             # back to i_loop @ PC=0x2c
nop
# done @ PC=0x110
j 0                   # terminal loop
