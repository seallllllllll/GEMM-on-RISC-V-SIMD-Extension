package simd

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import scala.io.Source

class ProcessorTester extends AnyFlatSpec with ChiselScalatestTester {
    
  "Processor" should "run" in {
    test(new Processor) { c =>
      c.reset.poke(true.B)
      c.clock.step(1)
      c.reset.poke(false.B)
      
      val rows = collection.mutable.ArrayBuffer[Seq[BigInt]]()

      
      for (i <- 0 until 100) {
        println("\n" + "="*25 + s" Cycle $i " + "="*25)
        
        // IF Stage
        println("\nIF Stage:")
        println(s"PC = 0x${c.io.debug.if_stage.pc.peek().litValue}")
        println(s"Instruction = 0x${c.io.debug.if_stage.instruction.peek().litValue}")
        
        // ID Stage
        println("\nID Stage:")
        println(s"opcode = ${c.io.debug.id_stage.opcode.peek().litValue}")
        println(s"rd = x${c.io.debug.id_stage.rd.peek().litValue}")
        println(s"rs1 = x${c.io.debug.id_stage.rs1.peek().litValue}")
        println(s"rs2 = x${c.io.debug.id_stage.rs2.peek().litValue}")
        println(s"imm = ${c.io.debug.id_stage.immediate.peek().litValue}")



        // EX Stage
        println("\nEX Stage:")
        println(s"ALU Results: [${(0 until 8).map(i => c.io.debug.ex_stage.aluResults(i).peek().litValue).mkString(", ")}]")
        
        // MEM Stage
        println("\nMEM Stage:")
        println(s"memRead = ${c.io.debug.mem_stage.memRead.peek().litValue}")
        println(s"memWrite = ${c.io.debug.mem_stage.memWrite.peek().litValue}")
        println(s"Memory Addresses: [${(0 until 8).map(i => c.io.debug.mem_stage.memAddresses(i).peek().litValue).mkString(", ")}]")
        println(s"MEM baseAddr0 = ${c.io.debug.mem_stage.baseAddr0.peek().litValue}")

                
        // WB Stage
        println("\nWB Stage:")
        println(s"rd = x${c.io.debug.wb_stage.rd.peek().litValue}")
        println(s"regWrite = ${c.io.debug.wb_stage.regWrite.peek().litValue}")
        println(s"Write Data: [${(0 until 8).map(i => c.io.debug.wb_stage.writeData(i).peek().litValue).mkString(", ")}]")
        
        def dumpVecMatrix(c: Processor): Unit = {
          println("\nVector-as-Matrix (8x8) view (x9..x16):")
          for (r <- 0 until 8) {
            val row = (0 until 8).map(j => c.io.debug.vectorRegs(r)(j).peek().litValue)
            println(row.mkString("[", ", ", "]"))
          }
        }
        
        dumpVecMatrix(c)

        c.clock.step(1)
        
        // Register State after this cycle
        println("\nRegister State:")
        println("Scalar Registers (x1-x8):")
        for (i <- 1 to 4) {
          println(s"x$i = ${c.io.debug.scalarRegs(i).peek().litValue}")
        }
        println("Vector Registers (x9-x31):")
        for (i <- 0 to 3) {
          println(s"x${i+9} = [${(0 until 8).map(j => c.io.debug.vectorRegs(i)(j).peek().litValue).mkString(", ")}]")
        }

        
      }
      // ===== Added: Golden C compare =====
        def readHexFile(path: String): Seq[BigInt] = {
          val src = Source.fromFile(path)
          try {
            src.getLines()
              .map(_.trim)
              .filter(l => l.nonEmpty && !l.startsWith("#"))
              .map(l => BigInt(l, 16))
              .toSeq
          } finally src.close()
        }

        val golden = readHexFile("golden_C.hex")
        require(golden.length == 64, s"golden_C.hex must have 64 lines, got ${golden.length}")

        val cBase = 128 // word index = 512 bytes / 4
        val actual = (0 until 64).map { i =>
          c.io.debug.dmemDbgAddr.poke((cBase + i).U)
          c.clock.step(1) // if dbg read not combinational
          c.io.debug.dmemDbgData.peek().litValue
        }

        for (i <- 0 until 64) {
          assert(
            actual(i) == golden(i),
            f"\n mismatch @word[${i}%d] (mem[${cBase + i}%d]): \nexpected=0x${golden(i)}%08X \nactual=0x${actual(i)}%08X"
          )
        }

        println("\nPASS: C matches golden_C.hex")
        // ===== End: Golden C compare =====
        
    }
  }
}
