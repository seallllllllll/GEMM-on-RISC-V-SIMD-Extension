package simd

import chisel3._
import chisel3.util._

class ALU extends Module {
  val io = IO(new Bundle {
    val op = Input(UInt(4.W))
    val in1 = Input(SInt(32.W))
    val in2 = Input(SInt(32.W))
    val out = Output(SInt(32.W))
  })

  val add  = 0.U
  val sub  = 1.U
  val and  = 2.U
  val or   = 3.U
  val xor  = 4.U
  val vadd = 5.U
  val vmul = 6.U    // new
  
  // NEW: compute product and truncate to low 32 bits (wrap-around)
  val prod32 = ((io.in1 * io.in2).asUInt)(31, 0).asSInt

  // Perform the ALU operation
  io.out := MuxLookup(io.op, 0.S, Seq(
    add  -> (io.in1 + io.in2),
    sub  -> (io.in1 - io.in2),
    and  -> (io.in1 & io.in2),
    or   -> (io.in1 | io.in2),
    xor  -> (io.in1 ^ io.in2),
    vadd -> (io.in1 + io.in2), // Vector addition, same as add, but just for clarity
    vmul -> prod32  // NEW
  ))
}
