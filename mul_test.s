addi x1, x0, 0
addi x2, x0, 32
addi x3, x0, 64


nop
vload v1, 0(x1)
vload v2, 0(x2)

nop
nop
nop

vmul v3, v1, v2

nop
nop
nop

vstore v3, 0(x3)

j 0
