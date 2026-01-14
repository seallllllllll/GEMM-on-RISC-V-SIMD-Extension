addi x3, x0, 512
nop; nop; nop; nop


vload v8, 0(x2)        # 讀 B 第 0 列: 1..8 (或你想要的)
nop; nop; nop
vstore v8, 0(x3)       # 只做這一次 store
end: j end
