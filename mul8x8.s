# mul8x8.s
# C[r][c] = A[r][c] * B[r][c], r=0..7, c=0..7
# A base = 0 bytes, B base = 256 bytes, C base = 512 bytes

addi x1, x0, 0       # A base
addi x2, x0, 256     # B base
addi x3, x0, 512     # C base
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0

# ---- row 0 (offset 0) ----
vload  v1, 0(x1)
vload  v2, 0(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 0(x3)

# ---- row 1 (offset 32) ----
vload  v1, 32(x1)
vload  v2, 32(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 32(x3)

# ---- row 2 (offset 64) ----
vload  v1, 64(x1)
vload  v2, 64(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 64(x3)

# ---- row 3 (offset 96) ----
vload  v1, 96(x1)
vload  v2, 96(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 96(x3)

# ---- row 4 (offset 128) ----
vload  v1, 128(x1)
vload  v2, 128(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 128(x3)

# ---- row 5 (offset 160) ----
vload  v1, 160(x1)
vload  v2, 160(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 160(x3)

# ---- row 6 (offset 192) ----
vload  v1, 192(x1)
vload  v2, 192(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 192(x3)

# ---- row 7 (offset 224) ----
vload  v1, 224(x1)
vload  v2, 224(x2)
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vmul   v3, v1, v2
addi x0,x0,0
addi x0,x0,0
addi x0,x0,0
vstore v3, 224(x3)

# stop here
j 0
