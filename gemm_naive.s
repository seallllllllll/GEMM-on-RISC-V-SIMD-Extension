# mul8x8_gemm.s
# C = A * B   (8x8 GEMM)
# A base = 0 bytes, B base = 256 bytes, C base = 512 bytes
#
# Vectorization on j (columns): compute 8 columns at once as one vector.
# For each row i:
#   Cvec = C[i][0..7]   (should be zero-initialized in data.hex)
#   for k=0..7:
#       Avec = vsplat(Arow, k)      # broadcast A[i][k]
#       Bvec = B[k][0..7]           # contiguous row of B
#       Cvec += Avec * Bvec
#   store Cvec back

addi x1, x0, 0       # A base
addi x2, x0, 256     # B base
addi x3, x0, 512     # C base

# a few nops for pipeline warm-up (keep your style)
nop
nop
nop
nop

############################################################
# ---- row 0 (offset 0) ----
############################################################
vload  v1, 0(x1)     # v1 = A[0][0..7]
vload  v3, 0(x3)     # v3 = C[0][0..7] (assume zeros)
nop
nop
nop

# k = 0
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)     # B[0][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 1
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)    # B[1][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 2
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)    # B[2][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 3
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)    # B[3][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 4
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)   # B[4][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 5
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)   # B[5][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 6
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)   # B[6][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

# k = 7
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)   # B[7][0..7]
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop

vstore v3, 0(x3)

############################################################
# ---- row 1..7 ----
# row1: 32, row2: 64, row3: 96, row4: 128, row5: 160, row6: 192, row7: 224
############################################################

# ---- row 1 (offset 32) ----
vload  v1, 32(x1)
vload  v3, 32(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 32(x3)

# ---- row 2 (offset 64) ----
vload  v1, 64(x1)
vload  v3, 64(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 64(x3)

# ---- row 3 (offset 96) ----
vload  v1, 96(x1)
vload  v3, 96(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 96(x3)

# ---- row 4 (offset 128) ----
vload  v1, 128(x1)
vload  v3, 128(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 128(x3)

# ---- row 5 (offset 160) ----
vload  v1, 160(x1)
vload  v3, 160(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 160(x3)

# ---- row 6 (offset 192) ----
vload  v1, 192(x1)
vload  v3, 192(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 192(x3)

# ---- row 7 (offset 224) ----
vload  v1, 224(x1)
vload  v3, 224(x3)
nop
nop
nop
vsplat v4, v1, 0
nop
nop
nop
vload  v2, 0(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 1
nop
nop
nop
vload  v2, 32(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 2
nop
nop
nop
vload  v2, 64(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 3
nop
nop
nop
vload  v2, 96(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 4
nop
nop
nop
vload  v2, 128(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 5
nop
nop
nop
vload  v2, 160(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 6
nop
nop
nop
vload  v2, 192(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vsplat v4, v1, 7
nop
nop
nop
vload  v2, 224(x2)
nop
nop
nop
vmul   v5, v4, v2
nop
nop
nop
vadd   v3, v3, v5
nop
nop
nop
vstore v3, 224(x3)

j 0
