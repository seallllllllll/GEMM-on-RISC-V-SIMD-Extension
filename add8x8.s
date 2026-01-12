addi x1, x0, 0
addi x2, x0, 256
addi x3, x0, 512

# row 0 (offset 0)
vload  v0, 0(x1)
vload  v1, 0(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 0(x3)

# row 1 (offset 32)
vload  v0, 32(x1)
vload  v1, 32(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 32(x3)

# row 2 (offset 64)
vload  v0, 64(x1)
vload  v1, 64(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 64(x3)

# row 3 (offset 96)
vload  v0, 96(x1)
vload  v1, 96(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 96(x3)

# row 4 (offset 128)
vload  v0, 128(x1)
vload  v1, 128(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 128(x3)

# row 5 (offset 160)
vload  v0, 160(x1)
vload  v1, 160(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 160(x3)

# row 6 (offset 192)
vload  v0, 192(x1)
vload  v1, 192(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 192(x3)

# row 7 (offset 224)
vload  v0, 224(x1)
vload  v1, 224(x2)
nop
nop
nop
vadd   v2, v0, v1
nop
nop
nop
vstore v2, 224(x3)
