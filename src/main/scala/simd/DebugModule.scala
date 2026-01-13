package simd

import chisel3._
import chisel3.util._

class DebugModule extends Bundle {
  // Pipeline stages
  val if_stage = new Bundle {
    val pc = Output(SInt(32.W))
    val instruction = Output(UInt(32.W))
  }
  val id_stage = new Bundle {
    val opcode = Output(UInt(7.W))
    val rd = Output(UInt(5.W))
    val rs1 = Output(UInt(5.W))
    val rs2 = Output(UInt(5.W))
    val immediate = Output(SInt(32.W))
    val instructionType = Output(UInt(3.W))
  }
  val ex_stage = new Bundle {
    val aluResults = Output(Vec(8, SInt(32.W)))
  }
  val mem_stage = new Bundle {
    val memAddresses = Output(Vec(8, UInt(32.W)))
    val memRead = Output(Bool())
    val memWrite = Output(Bool())
    val baseAddr0 = Output(UInt(32.W))  // MEM real base addr (lane0)

  }
  val wb_stage = new Bundle {
    val rd = Output(UInt(5.W))
    val regWrite = Output(Bool())
    val writeData = Output(Vec(8, SInt(32.W)))
  }

  val scalarRegs = Output(Vec(9, SInt(32.W)))
  val vectorRegs = Output(Vec(23, Vec(8, SInt(32.W))))
}
