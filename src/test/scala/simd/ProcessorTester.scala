/*
Test spec:
- A matrix: mem[0..63]
- B matrix: mem[64..127]
- C matrix: mem[128..191]
- Correctness is defined ONLY by C memory content
- Vector registers are scratch, not architectural state
*/


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
      
      def peekMem(wordAddr: Int): BigInt = {
          c.io.debug.dmemDbgAddr.poke(wordAddr.U)
          c.clock.step(1) // keep if dbg read is registered
          c.io.debug.dmemDbgData.peek().litValue
        }

      
      val rows = collection.mutable.ArrayBuffer[Seq[BigInt]]()


        val maxCycles = 5000
        val stablePcThreshold = 8      // PC being same 8 times, then j 0 terminal loop

        var cycle = 0
        var lastPc = BigInt(-1)
        var stablePcCount = 0
        var reachedEnd = false
        
        c.clock.setTimeout(0)   // 0 = disable timeout
        
        def countNonEmptyLines(path: String): Int = {
          val src = Source.fromFile(path)
          try src.getLines().map(_.trim).count(l => l.nonEmpty && !l.startsWith("#"))
          finally src.close()
        }

        val instLenWords = countNonEmptyLines("./src/main/resources/inst.hex")
        require(instLenWords > 0, s"inst.hex is empty?")



        while (cycle < maxCycles) {
          val pcVal   = c.io.debug.if_stage.pc.peek().litValue
          val instVal = c.io.debug.if_stage.instruction.peek().litValue
          val pcWord  = (pcVal / 4).toInt

          if (pcWord >= instLenWords) {
              println(s"Reached end of inst.hex at cycle=$cycle pcWord=$pcWord instLenWords=$instLenWords")
              reachedEnd = true
              cycle = maxCycles
          } else {
              println("\n" + "="*25 + s" Cycle $cycle " + "="*25)

              // IF Stage
              println("\nIF Stage:")
              val pc = c.io.debug.if_stage.pc.peek().litValue
              val inst = c.io.debug.if_stage.instruction.peek().litValue
              println(s"PC = 0x${pc.toString(16)}")
              println(s"Instruction = 0x${inst.toString(16)}")
              // println(s"PC = 0x$pc")
              // println(s"Instruction = 0x$inst")

              // whether pc is stop
              if (pc == lastPc) stablePcCount += 1 else stablePcCount = 0
              lastPc = pc

              // ID Stage
              println("\nID Stage:")
              println(s"opcode = ${c.io.debug.id_stage.opcode.peek().litValue}")
              println(s"rd = x${c.io.debug.id_stage.rd.peek().litValue}")
              println(s"rs1 = x${c.io.debug.id_stage.rs1.peek().litValue}")
              println(s"rs2 = x${c.io.debug.id_stage.rs2.peek().litValue}")
              println(s"imm = ${c.io.debug.id_stage.immediate.peek().litValue}")
              println(s"funct3 = ${c.io.debug.id_stage.funct3.peek().litValue}")
              println(s"funct7 = ${c.io.debug.id_stage.funct7.peek().litValue}")
              println(s"aluOp  = ${c.io.debug.id_stage.aluOp.peek().litValue}")

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
              cycle += 1
          }
        }

        println(s"\nStopped after $cycle cycles; stablePcCount=$stablePcCount")
        require(reachedEnd || stablePcCount >= stablePcThreshold,
        s"Program did not reach terminal loop OR end-of-program. Ran $cycle cycles. stablePcCount=$stablePcCount reachedEnd=$reachedEnd")



      /*
      for (i <- 0 until 300) {
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
        println(s"funct3 = ${c.io.debug.id_stage.funct3.peek().litValue}")
        println(s"funct7 = ${c.io.debug.id_stage.funct7.peek().litValue}")
        println(s"aluOp  = ${c.io.debug.id_stage.aluOp.peek().litValue}")



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
      */

              
      
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
        
        // val A = (0 until 64).map(i => peekMem(i))
        // val B = (0 until 64).map(i => peekMem(64 + i))

        val golden = readHexFile("golden_C.hex")
        require(golden.length == 64, s"golden_C.hex must have 64 lines, got ${golden.length}")

        val cBase = 128 // word index = 512 bytes / 4
        val actualC = (0 until 64).map(i => peekMem(cBase + i))

        dumpCMemoryMatrix(128)   // print first

        golden.zip(actualC).zipWithIndex.foreach { case ((e, a), idx) =>
          assert(a == e, s"mismatch @C[$idx] (mem[${cBase + idx}]): expected=$e actual=$a")
        }

        println("\nPASS: C[0..63] matches golden_C.hex")


        /*
        // ===== VMUL OUT compare (C = A .* B) =====
        def peekMem(wordAddr: Int): BigInt = {
          c.io.debug.dmemDbgAddr.poke(wordAddr.U)
          c.clock.step(1) // keep if dbg read is registered
          c.io.debug.dmemDbgData.peek().litValue
        }

        // get A / B
        // val A = (0 until 64).map(i => peekMem(i))
        // val B = (0 until 64).map(i => peekMem(64 + i))

        val cBase     = 128 // C base = 512 bytes => word index 128
        val actualC   = (0 until 64).map(i => peekMem(cBase + i))
        val expectedC = (0 until 64).map(i => A(i) * B(i))

        expectedC.zip(actualC).zipWithIndex.foreach { case ((e, a), idx) =>
          assert(a == e, s"mismatch @C[$idx] (mem[${cBase + idx}]): expected=$e actual=$a")
        }

        println("\nPASS: C[0..63] matches element-wise A*B")
        // ===== End compare =====
        */
        
        def dumpCMemoryMatrix(cBase: Int): Unit = {
          println("\nC memory as Matrix (8x8):")
          for (r <- 0 until 8) {
            val row = (0 until 8).map { c =>
              peekMem(cBase + r*8 + c)
            }
            println(row.mkString("[", ", ", "]"))
          }
        }

    }


    
  }
}
