# gemm_block2x8_8x8.s
# 2x8 register-blocked GEMM for 8x8:
# - Vectorize across j (8 columns at once)
# - Block across i (2 rows at once)
# C = A * B
# A base = 0 bytes, B base = 256 bytes, C base = 512 bytes

addi x1, x0, 0        # A base
addi x2, x0, 256      # B base
addi x3, x0, 512      # C base

nop
nop
nop
nop

############################################################
# BLOCK 0: rows 0 and 1
# A offsets: 0, 32
# C offsets: 0, 32
############################################################
vload  v1,  0(x1)     # vA0 = A[0][0..7]
vload  v2, 32(x1)     # vA1 = A[1][0..7]
vload  v6,  0(x3)     # vC0 = C[0][0..7] (assume zero)
vload  v7, 32(x3)     # vC1 = C[1][0..7] (assume zero)
nop
nop
nop

# k = 0
vload  v4,   0(x2)    # vB = B[0][0..7]
nop
nop
nop
vsplat v8, v1, 0      # vS0 = A[0][0] broadcast
vsplat v9, v2, 0      # vS1 = A[1][0] broadcast
nop
nop
nop
vmul   v10, v8, v4    # vP0 = vS0 * vB
vmul   v11, v9, v4    # vP1 = vS1 * vB
nop
nop
nop
vadd   v6, v6, v10    # vC0 += vP0
vadd   v7, v7, v11    # vC1 += vP1
nop
nop
nop

# k = 1
vload  v4,  32(x2)    # B[1][0..7]
nop
nop
nop
vsplat v8, v1, 1
vsplat v9, v2, 1
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 2
vload  v4,  64(x2)    # B[2][0..7]
nop
nop
nop
vsplat v8, v1, 2
vsplat v9, v2, 2
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 3
vload  v4,  96(x2)    # B[3][0..7]
nop
nop
nop
vsplat v8, v1, 3
vsplat v9, v2, 3
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 4
vload  v4, 128(x2)    # B[4][0..7]
nop
nop
nop
vsplat v8, v1, 4
vsplat v9, v2, 4
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 5
vload  v4, 160(x2)    # B[5][0..7]
nop
nop
nop
vsplat v8, v1, 5
vsplat v9, v2, 5
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 6
vload  v4, 192(x2)    # B[6][0..7]
nop
nop
nop
vsplat v8, v1, 6
vsplat v9, v2, 6
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 7
vload  v4, 224(x2)    # B[7][0..7]
nop
nop
nop
vsplat v8, v1, 7
vsplat v9, v2, 7
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

vstore v6,  0(x3)     # store C row 0
vstore v7, 32(x3)     # store C row 1
nop
nop
nop

############################################################
# BLOCK 1: rows 2 and 3 (offsets +64, +96)
############################################################
vload  v1,  64(x1)
vload  v2,  96(x1)
vload  v6,  64(x3)
vload  v7,  96(x3)
nop
nop
nop
# k = 0
vload  v4,   0(x2)    # vB = B[0][0..7]
nop
nop
nop
vsplat v8, v1, 0      # vS0 = A[0][0] broadcast
vsplat v9, v2, 0      # vS1 = A[1][0] broadcast
nop
nop
nop
vmul   v10, v8, v4    # vP0 = vS0 * vB
vmul   v11, v9, v4    # vP1 = vS1 * vB
nop
nop
nop
vadd   v6, v6, v10    # vC0 += vP0
vadd   v7, v7, v11    # vC1 += vP1
nop
nop
nop

# k = 1
vload  v4,  32(x2)    # B[1][0..7]
nop
nop
nop
vsplat v8, v1, 1
vsplat v9, v2, 1
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 2
vload  v4,  64(x2)    # B[2][0..7]
nop
nop
nop
vsplat v8, v1, 2
vsplat v9, v2, 2
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 3
vload  v4,  96(x2)    # B[3][0..7]
nop
nop
nop
vsplat v8, v1, 3
vsplat v9, v2, 3
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 4
vload  v4, 128(x2)    # B[4][0..7]
nop
nop
nop
vsplat v8, v1, 4
vsplat v9, v2, 4
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 5
vload  v4, 160(x2)    # B[5][0..7]
nop
nop
nop
vsplat v8, v1, 5
vsplat v9, v2, 5
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 6
vload  v4, 192(x2)    # B[6][0..7]
nop
nop
nop
vsplat v8, v1, 6
vsplat v9, v2, 6
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 7
vload  v4, 224(x2)    # B[7][0..7]
nop
nop
nop
vsplat v8, v1, 7
vsplat v9, v2, 7
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

vstore v6,  64(x3)
vstore v7,  96(x3)
nop
nop
nop

############################################################
# BLOCK 2: rows 4 and 5 (offsets +128, +160)
############################################################
vload  v1, 128(x1)
vload  v2, 160(x1)
vload  v6, 128(x3)
vload  v7, 160(x3)
nop
nop
nop
# k = 0
vload  v4,   0(x2)    # vB = B[0][0..7]
nop
nop
nop
vsplat v8, v1, 0      # vS0 = A[0][0] broadcast
vsplat v9, v2, 0      # vS1 = A[1][0] broadcast
nop
nop
nop
vmul   v10, v8, v4    # vP0 = vS0 * vB
vmul   v11, v9, v4    # vP1 = vS1 * vB
nop
nop
nop
vadd   v6, v6, v10    # vC0 += vP0
vadd   v7, v7, v11    # vC1 += vP1
nop
nop
nop

# k = 1
vload  v4,  32(x2)    # B[1][0..7]
nop
nop
nop
vsplat v8, v1, 1
vsplat v9, v2, 1
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 2
vload  v4,  64(x2)    # B[2][0..7]
nop
nop
nop
vsplat v8, v1, 2
vsplat v9, v2, 2
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 3
vload  v4,  96(x2)    # B[3][0..7]
nop
nop
nop
vsplat v8, v1, 3
vsplat v9, v2, 3
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 4
vload  v4, 128(x2)    # B[4][0..7]
nop
nop
nop
vsplat v8, v1, 4
vsplat v9, v2, 4
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 5
vload  v4, 160(x2)    # B[5][0..7]
nop
nop
nop
vsplat v8, v1, 5
vsplat v9, v2, 5
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 6
vload  v4, 192(x2)    # B[6][0..7]
nop
nop
nop
vsplat v8, v1, 6
vsplat v9, v2, 6
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 7
vload  v4, 224(x2)    # B[7][0..7]
nop
nop
nop
vsplat v8, v1, 7
vsplat v9, v2, 7
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

vstore v6, 128(x3)
vstore v7, 160(x3)
nop
nop
nop

############################################################
# BLOCK 3: rows 6 and 7 (offsets +192, +224)
############################################################
vload  v1, 192(x1)
vload  v2, 224(x1)
vload  v6, 192(x3)
vload  v7, 224(x3)
nop
nop
nop
# k = 0
vload  v4,   0(x2)    # vB = B[0][0..7]
nop
nop
nop
vsplat v8, v1, 0      # vS0 = A[0][0] broadcast
vsplat v9, v2, 0      # vS1 = A[1][0] broadcast
nop
nop
nop
vmul   v10, v8, v4    # vP0 = vS0 * vB
vmul   v11, v9, v4    # vP1 = vS1 * vB
nop
nop
nop
vadd   v6, v6, v10    # vC0 += vP0
vadd   v7, v7, v11    # vC1 += vP1
nop
nop
nop

# k = 1
vload  v4,  32(x2)    # B[1][0..7]
nop
nop
nop
vsplat v8, v1, 1
vsplat v9, v2, 1
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 2
vload  v4,  64(x2)    # B[2][0..7]
nop
nop
nop
vsplat v8, v1, 2
vsplat v9, v2, 2
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 3
vload  v4,  96(x2)    # B[3][0..7]
nop
nop
nop
vsplat v8, v1, 3
vsplat v9, v2, 3
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 4
vload  v4, 128(x2)    # B[4][0..7]
nop
nop
nop
vsplat v8, v1, 4
vsplat v9, v2, 4
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 5
vload  v4, 160(x2)    # B[5][0..7]
nop
nop
nop
vsplat v8, v1, 5
vsplat v9, v2, 5
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 6
vload  v4, 192(x2)    # B[6][0..7]
nop
nop
nop
vsplat v8, v1, 6
vsplat v9, v2, 6
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

# k = 7
vload  v4, 224(x2)    # B[7][0..7]
nop
nop
nop
vsplat v8, v1, 7
vsplat v9, v2, 7
nop
nop
nop
vmul   v10, v8, v4
vmul   v11, v9, v4
nop
nop
nop
vadd   v6, v6, v10
vadd   v7, v7, v11
nop
nop
nop

vstore v6, 192(x3)
vstore v7, 224(x3)

j 0
