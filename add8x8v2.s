addi x1, x0, 0
addi x2, x0, 256
addi x3, x0, 512

# v8/v9 for load buffer，v0..v7 get result（with x9..x16）

# row 0 (offset 0)
vload  v8, 0(x1)
vload  v9, 0(x2)
nop
nop
nop
vadd   v0, v8, v9
nop
nop
nop
vstore v0, 0(x3)

# row 1 (offset 32)
vload  v8, 32(x1)
vload  v9, 32(x2)
nop
nop
nop
vadd   v1, v8, v9
nop
nop
nop
vstore v1, 32(x3)

# row 2 (offset 64)
vload  v8, 64(x1)
vload  v9, 64(x2)
nop
nop
nop
vadd   v2, v8, v9
nop
nop
nop
vstore v2, 64(x3)

# row 3 (offset 96)
vload  v8, 96(x1)
vload  v9, 96(x2)
nop
nop
nop
vadd   v3, v8, v9
nop
nop
nop
vstore v3, 96(x3)

# row 4 (offset 128)
vload  v8, 128(x1)
vload  v9, 128(x2)
nop
nop
nop
vadd   v4, v8, v9
nop
nop
nop
vstore v4, 128(x3)

# row 5 (offset 160)
vload  v8, 160(x1)
vload  v9, 160(x2)
nop
nop
nop
vadd   v5, v8, v9
nop
nop
nop
vstore v5, 160(x3)

# row 6 (offset 192)
vload  v8, 192(x1)
vload  v9, 192(x2)
nop
nop
nop
vadd   v6, v8, v9
nop
nop
nop
vstore v6, 192(x3)

# row 7 (offset 224)
vload  v8, 224(x1)
vload  v9, 224(x2)
nop
nop
nop
vadd   v7, v8, v9
nop
nop
nop
vstore v7, 224(x3)
