package simd

import chisel3._
import chisel3.util._
import chisel3.util.experimental.loadMemoryFromFile

class DataMemory(memSize: Int) extends Module {
    val addrWidth = log2Ceil(memSize)
  val io = IO(new Bundle {
    val addr = Input(Vec(8, UInt(addrWidth.W)))     // Addresses for 8 lanes
    val dataIn = Input(Vec(8, SInt(32.W)))  // Data to write for 8 lanes
    val wen = Input(Bool())                  // Write enable
    val ren = Input(Bool())                  // Read enable
    val dataOut = Output(Vec(8, SInt(32.W)))// Data read from 8 lanes
    
    val dbgAddr = Input(UInt(addrWidth.W))         // word index
    val dbgData = Output(SInt(32.W))

  })

  val mem = Mem(memSize, SInt(32.W))

  loadMemoryFromFile(mem, "./src/main/resources/data.hex")
  
  // debug read (asynchronous for Mem)
  io.dbgData := mem.read(io.dbgAddr)

  // printf("Memory contents after loading:\n")
  // for (i <- 0 until 26) {
  //   printf("%d: %x\n", i.U, mem.read(i.U, true.B))
  // }


  val dataOutVec = Wire(Vec(8, SInt(32.W)))
  dataOutVec := VecInit(Seq.fill(8)(0.S))
  
  when(io.wen) {
    for (i <- 0 until 8) {
      mem.write(io.addr(i), io.dataIn(i))
    }
  }.elsewhen(io.ren) {
    for (i <- 0 until 8) {
      dataOutVec(i) := mem.read(io.addr(i))
    }
  }

  io.dataOut := dataOutVec
}
