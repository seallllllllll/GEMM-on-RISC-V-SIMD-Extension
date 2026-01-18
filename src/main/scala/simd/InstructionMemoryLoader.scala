package simd

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFile

class InstructionMemoryLoader(memSize: Int, hexFile: String) extends Module {
  val io = IO(new Bundle {
    val addr = Input(UInt(log2Ceil(memSize).W))
    val data = Output(UInt(32.W))
  })


  val mem = Mem(memSize, UInt(32.W))

  // Load instructions from hex file
  loadMemoryFromFile(mem, hexFile)

  io.data := mem(io.addr)
}
