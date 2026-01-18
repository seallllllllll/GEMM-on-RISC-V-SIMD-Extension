package simd

import chisel3._
import chisel3.util._
import chisel3.util.log2Ceil


class IF_ID extends Bundle {
  val pc = SInt(32.W)
  val instruction = UInt(32.W)
}

class ID_EX extends Bundle {
  val rs1_data = Vec(8, SInt(32.W))
  val rs2_data = Vec(8, SInt(32.W))
  val immediate = Vec(8, SInt(32.W))
  // Needs 4 bits because we added VSPLAT (=8)
  val instructionType = UInt(4.W)
  val rd = UInt(5.W)
  val opcode = UInt(7.W)
  val memRead = Bool()
  val memWrite = Bool()
  val regWrite = Bool()
  val isVector = Bool()
  val aluOp = UInt(4.W)
  val isImmediate = Bool()
}


class EX_MEM extends Bundle {
  val alu_result = Vec(8, SInt(32.W))
  val rs2_data = Vec(8, SInt(32.W))
  val immediate = Vec(8, SInt(32.W))
  val rd = UInt(5.W)
  val memRead = Bool()
  val memWrite = Bool()
  val regWrite = Bool()
  val isVector = Bool()
  val dmem_addresses = Vec(8, UInt(32.W))
}

class MEM_WB extends Bundle {
  val alu_result = Vec(8, SInt(32.W))
  val rd = UInt(5.W)
  val regWrite = Bool()
  val memRead = Bool()
  val mem_data = Vec(8, SInt(32.W))
  val isVector = Bool()
}


class Processor extends Module {
  val io = IO(new Bundle {
    val instruction = Output(UInt(32.W))
    val pc = Output(SInt(32.W))
    val debug = (new DebugModule())
  })

  object InstructionType {
      // Use an explicit 4-bit encoding because we have >8 instruction types.
      val ADDI   = 0.U(4.W)
      val VADD   = 1.U(4.W)
      val VMUL   = 2.U(4.W)
      val VLOAD  = 3.U(4.W)
      val VSTORE = 4.U(4.W)
      val BEQ    = 5.U(4.W)
      val J      = 6.U(4.W)
      val NOP    = 7.U(4.W)
      val VSPLAT = 8.U(4.W)
      val ADD    = 9.U(4.W)
      val MUL    = 10.U(4.W)
      val LW     = 11.U(4.W)
      val SW     = 12.U(4.W)

  }
  
  val if_id = RegInit(0.U.asTypeOf(new IF_ID))
  val id_ex = RegInit(0.U.asTypeOf(new ID_EX))
  val ex_mem = RegInit(0.U.asTypeOf(new EX_MEM)) 
  val mem_wb = RegInit(0.U.asTypeOf(new MEM_WB))

  val dataMemory = Module(new DataMemory(4096)) 
  val instructionMemory = Module(new InstructionMemoryLoader(4096, "./src/main/resources/inst.hex"))

  val instructionType = WireDefault(InstructionType.NOP)
  

  val scalarRegfile = RegInit(VecInit(Seq.fill(32)(0.S(32.W))))
  val vectorRegfile = Mem(23, Vec(8, SInt(32.W))) // 23 vector registers (9-31)



  // Fetch stage
  val pc = RegInit(0.S(32.W))
  instructionMemory.io.addr := (pc >> 2).asUInt
  val instruction = instructionMemory.io.data

  // VADD VLOAD VSTORE ADDI BEQ J NOP
  
  // Decode stage
  val opcode = if_id.instruction(6, 0)
  val rd = if_id.instruction(11, 7)
  val funct3 = if_id.instruction(14, 12)
  val rs1 = if_id.instruction(19, 15)
  val rs2 = if_id.instruction(24, 20)
  val funct7 = if_id.instruction(31, 25)
  val _immediateScalar = if_id.instruction(31, 20)
  val immediateScalar = Cat(Fill(20, _immediateScalar(11)), _immediateScalar).asSInt()
  val isImmediate = WireDefault(false.B);

 // Control signals
  val regWrite = WireDefault(false.B)
  val memRead = WireDefault(false.B)
  val memWrite = WireDefault(false.B)
  val aluOp = WireDefault(0.U(4.W))
  val isVector = WireDefault(false.B)


  // Control unit
  switch(opcode) {
    is("b0010011".U) {  // addi
        instructionType := InstructionType.ADDI
        isImmediate := true.B
        aluOp := 0.U // ADD
        regWrite := true.B
        isVector := false.B
        memRead := false.B
        memWrite := false.B
    }
    /*
    is("b0110011".U) { // Custom opcode for vadd
        instructionType := InstructionType.VADD
        isImmediate := false.B
        aluOp := 5.U
        regWrite := true.B
        isVector := true.B
        memRead := false.B
        memWrite := false.B
   }*/
   /*
   is("b0110011".U) { // SIMD R-type (vadd / vmul)
      when(funct3 === "b111".U && funct7 === "b1111111".U) {
            instructionType := InstructionType.VADD
            isImmediate := false.B
            aluOp := 5.U            // vadd op
            regWrite := true.B
            isVector := true.B
            memRead := false.B
            memWrite := false.B
          }.elsewhen(funct3 === "b111".U && funct7 === "b1111110".U) {
            instructionType := InstructionType.VMUL
            isImmediate := false.B
            aluOp := 6.U            // vmul ALU op code
            regWrite := true.B
            isVector := true.B
            memRead := false.B
            memWrite := false.B
          }.otherwise {
            instructionType := InstructionType.NOP
            isImmediate := false.B
            regWrite := false.B
            memRead := false.B
            memWrite := false.B
            aluOp := 0.U
            isVector := false.B
          }
    }
    */
    is("b0110011".U) {
      when(funct3 === "b111".U && funct7 === "b1111111".U) {
          instructionType := InstructionType.VADD
          isImmediate := false.B
          aluOp := 5.U
          regWrite := true.B
          isVector := true.B
          memRead := false.B
          memWrite := false.B
        }.elsewhen(funct3 === "b111".U && funct7 === "b1111110".U) {
          instructionType := InstructionType.VMUL
          isImmediate := false.B
          aluOp := 6.U
          regWrite := true.B
          isVector := true.B
          memRead := false.B
          memWrite := false.B
        }.elsewhen(funct3 === "b000".U && funct7 === "b0000000".U) {
          instructionType := InstructionType.ADD
          isImmediate := false.B
          aluOp := 0.U
          regWrite := true.B
          isVector := false.B
          memRead := false.B
          memWrite := false.B
        }.elsewhen(funct3 === "b000".U && funct7 === "b0000001".U) {
          instructionType := InstructionType.MUL
          isImmediate := false.B
          aluOp := 6.U
          regWrite := true.B
          isVector := false.B
          memRead := false.B
          memWrite := false.B
        }.otherwise {
          instructionType := InstructionType.NOP
          isImmediate := false.B
          aluOp := 0.U
          regWrite := false.B
          isVector := false.B
          memRead := false.B
          memWrite := false.B
        }
    }



    is("b1000000".U) { // Custom opcode for vstore
      instructionType := InstructionType.VSTORE
      isImmediate := false.B
      regWrite := false.B
      memRead := false.B
      memWrite := true.B
      aluOp := 0.U
      isVector := true.B
    }
    is("b0101010".U) { // Custom opcode for nop
      instructionType := InstructionType.NOP
      isImmediate := false.B
      regWrite := false.B
      memRead := false.B
      memWrite := false.B
      aluOp := 0.U
      isVector := false.B
    }
    is("b1111111".U) {  // Custom opcode for vload
      instructionType := InstructionType.VLOAD
      isImmediate := true.B
      regWrite := true.B
      memRead := true.B
      memWrite := false.B
      aluOp := 0.U
      isVector := true.B
    }
    is("b1010101".U) {  // Custom opcode for vsplat
      instructionType := InstructionType.VSPLAT
      isImmediate := true.B      // lane index in immediate (0..7)
      regWrite := true.B         // write back to a vector register
      memRead := false.B
      memWrite := false.B
      aluOp := 0.U               // no ALU op needed
      isVector := true.B
    }
    is("b1100011".U){ // beq
      instructionType := InstructionType.BEQ
      isImmediate := true.B
      regWrite := false.B
      memRead := false.B
      memWrite := false.B
      aluOp := 1.U
      isVector := false.B
    }
    is("b1101111".U){ // j
      instructionType := InstructionType.J
      isImmediate := true.B
      regWrite := false.B
      memRead := false.B
      memWrite := false.B
      aluOp := 0.U
      isVector := false.B
    }
    is("b0000011".U) { // lw
      when(funct3 === "b010".U) {
        instructionType := InstructionType.LW
        isImmediate := true.B
        aluOp := 0.U // use add : address = rs1 + imm
        regWrite := true.B
        isVector := false.B
        memRead := true.B
        memWrite := false.B
      }.otherwise {
          instructionType := InstructionType.NOP
          isImmediate := false.B
          aluOp := 0.U
          regWrite := false.B
          isVector := false.B
          memRead := false.B
          memWrite := false.B
        }
    }
    is("b0100011".U) { // sw
      when(funct3 === "b010".U) {
        instructionType := InstructionType.SW
        isImmediate := false.B
        aluOp := 0.U // address = rs1 + immS
        regWrite := false.B
        isVector := false.B
        memRead := false.B
        memWrite := true.B
      }.otherwise {
          instructionType := InstructionType.NOP
          isImmediate := false.B
          aluOp := 0.U
          regWrite := false.B
          isVector := false.B
          memRead := false.B
          memWrite := false.B
        }
    }


  
  }
  

  // Read logic for source registers
  val rs1_data = Wire(Vec(8, SInt(32.W)))
  val rs2_data = Wire(Vec(8, SInt(32.W)))

  val immediate = Wire(Vec(8, SInt(32.W)))
  rs1_data := VecInit(Seq.fill(8)(0.S)) // Default rs1_data to 0
  rs2_data := VecInit(Seq.fill(8)(0.S)) // Default rs2_data to 0
  immediate := VecInit(Seq.fill(8)(immediateScalar))

  when(instructionType === InstructionType.BEQ) {
      val imm12 = if_id.instruction(31)       // imm[12] - MSB
      val imm10_5 = if_id.instruction(30, 25)  // imm[10:5]
      val imm4_1 = if_id.instruction(11, 8)    // imm[4:1]
      val imm11 = if_id.instruction(7)         // imm[11]
      val _imm = Cat(imm12, imm11, imm10_5, imm4_1, 0.U(1.W)).asSInt()
      val imm = Cat(Fill(19, _imm(12)), _imm).asSInt()
      printf(p"Immediate value: ${imm}\n")
      immediate := VecInit(Seq.fill(8)(imm))

  }.elsewhen(instructionType === InstructionType.J) {
      val imm20 = if_id.instruction(31)       // imm[20] - MSB
      val imm10_1 = if_id.instruction(30, 21)  // imm[10:1]
      val imm11 = if_id.instruction(20)        // imm[11]
      val imm19_12 = if_id.instruction(19, 12) // imm[19:12]
      val _imm = Cat(imm20, imm19_12, imm11, imm10_1, 0.U(1.W)).asSInt()
      // J-type immediate is 21-bit signed; sign bit is imm[20] (instruction bit 31)
      val imm = Cat(Fill(11, _imm(20)), _imm).asSInt()
      immediate := VecInit(Seq.fill(8)(imm))

      
  
  }.elsewhen(instructionType === InstructionType.VSTORE || instructionType === InstructionType.SW) {
      // S-type immediate: imm[11:5]=inst[31:25], imm[4:0]=inst[11:7]
      val imm11_5 = if_id.instruction(31, 25)
      val imm4_0  = if_id.instruction(11, 7)
      val immS12  = Cat(imm11_5, imm4_0)                 // 12 bits
      val immS    = Cat(Fill(20, immS12(11)), immS12).asSInt // sign-extend to 32
      immediate := VecInit(Seq.fill(8)(immS))
    }
    
    // RS1 read logic: only treat x9..x31 as vector regs when isVector == true
    when(rs1 >= 9.U && rs1 < 32.U && isVector) {
      rs1_data := vectorRegfile(rs1 - 9.U)
    }.elsewhen(rs1 > 0.U && rs1 < 32.U) {
      rs1_data := VecInit(Seq.fill(8)(scalarRegfile(rs1)))
    }.otherwise {
      rs1_data := VecInit(Seq.fill(8)(0.S)) // x0
    }

    // RS2 read logic (only needed when instruction actually uses rs2)
    when(!isImmediate || instructionType === InstructionType.BEQ || instructionType === InstructionType.SW || instructionType === InstructionType.VSTORE) {
      when(rs2 >= 9.U && rs2 < 32.U && isVector) {
        rs2_data := vectorRegfile(rs2 - 9.U)
      }.elsewhen(rs2 > 0.U && rs2 < 32.U) {
        rs2_data := VecInit(Seq.fill(8)(scalarRegfile(rs2)))
      }.otherwise {
        rs2_data := VecInit(Seq.fill(8)(0.S)) // x0
      }
    }
  
  // J does not require rs1_data; jump uses id_ex.immediate(0) in EX
  // .elsewhen(instructionType === InstructionType.BEQ) {
  //   rs1_data := VecInit(Seq.fill(8)(0.S))
  // }

  //Execute stage
  val vectorALUs = VecInit(Seq.fill(8)(Module(new ALU).io))
  val vector_alu_result = Wire(Vec(8, SInt(32.W)))

  for (i <- 0 until 8) {
    vectorALUs(i).op := id_ex.aluOp
    vectorALUs(i).in1 := id_ex.rs1_data(i)
    when(id_ex.instructionType === InstructionType.BEQ){
      vectorALUs(i).in2 :=  id_ex.rs2_data(i)
    }.elsewhen(id_ex.instructionType === InstructionType.VSTORE || id_ex.instructionType === InstructionType.SW) {
      vectorALUs(i).in2 := id_ex.immediate(i)
    }.elsewhen (id_ex.isImmediate) {
      vectorALUs(i).in2 := id_ex.immediate(i)
    } .otherwise {
      vectorALUs(i).in2 := id_ex.rs2_data(i)
    }
    vector_alu_result(i) := vectorALUs(i).out
  }
  
  // VSPLAT: broadcast rs1 lane[imm[2:0]] to all 8 lanes
  when(id_ex.instructionType === InstructionType.VSPLAT) {
    val laneSel = id_ex.immediate(0).asUInt()(2, 0)  // imm[2:0] = 0..7
    val src = id_ex.rs1_data(laneSel)
    for (i <- 0 until 8) {
      vector_alu_result(i) := src
    }
  }



  /*
  val base_addr = vector_alu_result(0).asUInt()
  val dmem_addresses = Wire(Vec(8, UInt(32.W)))
  val memSize = 4096
  val addrWidth = log2Ceil(memSize)
  val base_word_index = id_ex.rs1_data(0).asUInt
  val imm_word_offset = id_ex.immediate(0).asUInt


  when(id_ex.isVector) {
    for (i <- 0 until 8) {
      // dmem_addresses(i) := (base_addr >> 2) + i.U
      dmem_addresses(i) := ((base_addr >> 2) + i.U)(addrWidth-1, 0)
      // dmem_addresses(i) := (base_word_index + imm_word_offset + i.U)(addrWidth-1, 0)

    }
    ex_mem.dmem_addresses := dmem_addresses
  }
  .otherwise {
    dmem_addresses := VecInit(Seq.fill(8)(0.U))
  }
  */
  
  val memSize = 4096
  val addrWidth = log2Ceil(memSize)
  
  val dmem_addresses = Wire(Vec(8, UInt(32.W)))
    dmem_addresses := VecInit(Seq.fill(8)(0.U))

    when(id_ex.memRead || id_ex.memWrite) {
      when(id_ex.isVector) {
        val base = vector_alu_result(0).asUInt()
        for (i <- 0 until 8) {
          dmem_addresses(i) := ((base >> 2) + i.U)(addrWidth-1, 0)
        }
      }.otherwise {
        // scalar: address = (rs1 + imm) >> 2，所有 lane 用同一個 addr（DataMemory 不用改）
        val base = vector_alu_result(0).asUInt()
        val a = (base >> 2)(addrWidth-1, 0)
        dmem_addresses := VecInit(Seq.fill(8)(a))
      }
    }
    ex_mem.dmem_addresses := dmem_addresses





  // Memory stage


  dataMemory.io.wen := false.B // Default value
  dataMemory.io.ren := false.B // Default value
  dataMemory.io.dataIn := VecInit(Seq.fill(8)(0.S))
  dataMemory.io.addr := VecInit(Seq.fill(8)(0.U))
  val mem_data = Wire(Vec(8, SInt(32.W)))
  
  dataMemory.io.dbgAddr := io.debug.dmemDbgAddr
  io.debug.dmemDbgData := dataMemory.io.dbgData



when(ex_mem.memWrite) {
  dataMemory.io.wen := true.B
  dataMemory.io.dataIn := ex_mem.rs2_data
  dataMemory.io.addr := ex_mem.dmem_addresses
  mem_data := ex_mem.rs2_data  // Store written data
}.elsewhen(ex_mem.memRead) {
  dataMemory.io.ren := true.B
  dataMemory.io.addr := ex_mem.dmem_addresses
  mem_data := dataMemory.io.dataOut  // Read data from memory
}.otherwise {
  mem_data := VecInit(Seq.fill(8)(0.S))
}



  // Writeback stage
  when(mem_wb.regWrite) {
    when(mem_wb.memRead) {
      // Write data from memory
      when(mem_wb.isVector) {
        vectorRegfile(mem_wb.rd - 9.U) := mem_wb.mem_data
      } .otherwise {
        scalarRegfile(mem_wb.rd) := mem_wb.mem_data(0)
      }
    }.otherwise {
      // Write data from ALU
      when(mem_wb.isVector) {
        vectorRegfile(mem_wb.rd - 9.U) := mem_wb.alu_result
      } .otherwise {
        scalarRegfile(mem_wb.rd) := mem_wb.alu_result(0)
      }
    }
  }


  
  // Pipeline stages with registers
  // 
  // IF  -[IF/ID]->  ID  -[ID/EX]->  EX  -[EX/MEM]->  MEM  -[MEM/WB]->  WB
  // 
  // IF/ID:  if_id
  // ID/EX:  id_ex
  // EX/MEM: ex_mem
  // MEM/WB: mem_wb
  //
  //     IF    ID    EX    MEM    WB
  //           IF    ID    EX     MEM    WB
  //                 IF    ID     EX     MEM    WB
  //                       IF     ID     EX     MEM    WB
  //                              IF     ID     EX     MEM    WB


  // val stall = Wire(Bool())
  // stall := false.B
  // // 1. RAW hazards - check both EX and MEM stages
  // when((rs1 =/= 0.U && (rs1 === id_ex.rd)) || 
  //     (rs2 =/= 0.U && (rs2 === id_ex.rd))) {
  //   stall := true.B
  // }
  // printf(p"rs1: ${rs1}\n")
  // printf(p"ID/EX rd: ${id_ex.rd}\n")
  // printf(p"ID/EX rs1_data: ${id_ex.rs1_data}\n")
  // printf(p"Vector alu result: ${vector_alu_result}\n")
  // printf(p"EX/MEM rd: ${ex_mem.rd}\n")
  // printf(p"MEM/WB rd: ${mem_wb.rd}\n")

  // Simple forwarding logic
  // when (rs1 === id_ex.rd) {
  //   rs1_data := vector_alu_result
  // }.elsewhen(rs1 === ex_mem.rd) {
  //   rs1_data := ex_mem.alu_result
  // }.elsewhen(rs1 === mem_wb.rd) {
  //   rs1_data := mem_wb.alu_result
  // }


  if_id.pc := pc
  if_id.instruction := instruction



  id_ex.rd := rd
  id_ex.rs1_data := rs1_data
  id_ex.rs2_data := rs2_data
  id_ex.immediate := immediate
  id_ex.instructionType := instructionType
  id_ex.rd := rd
  id_ex.opcode := opcode
  id_ex.memRead := memRead
  id_ex.memWrite := memWrite
  id_ex.regWrite := regWrite
  id_ex.isVector := isVector
  id_ex.aluOp := aluOp
  id_ex.isImmediate := isImmediate

  ex_mem.rd := id_ex.rd
  ex_mem.alu_result := vector_alu_result
  ex_mem.rs2_data := id_ex.rs2_data
  ex_mem.immediate := id_ex.immediate
  ex_mem.rd := id_ex.rd
  ex_mem.memRead := id_ex.memRead
  ex_mem.memWrite := id_ex.memWrite
  ex_mem.regWrite := id_ex.regWrite
  ex_mem.isVector := id_ex.isVector
  ex_mem.dmem_addresses := dmem_addresses

  mem_wb.rd := ex_mem.rd
  mem_wb.alu_result := ex_mem.alu_result
  mem_wb.rd := ex_mem.rd
  mem_wb.regWrite := ex_mem.regWrite
  mem_wb.memRead := ex_mem.memRead
  mem_wb.mem_data := mem_data
  mem_wb.isVector := ex_mem.isVector

  


  io.pc := pc
  io.instruction := instruction

  // Debug connections
  io.debug.if_stage.pc := io.pc
  io.debug.if_stage.instruction := io.instruction

  io.debug.id_stage.opcode := if_id.instruction(6,0)
  io.debug.id_stage.rd := if_id.instruction(11,7)
  io.debug.id_stage.rs1 := if_id.instruction(19,15)
  io.debug.id_stage.rs2 := if_id.instruction(24,20)
  io.debug.id_stage.funct3 := funct3
  io.debug.id_stage.funct7 := funct7
  io.debug.id_stage.aluOp  := aluOp
  io.debug.id_stage.immediate := id_ex.immediate(0)
  io.debug.id_stage.instructionType := instructionType
  

  io.debug.ex_stage.aluResults := vector_alu_result

  io.debug.mem_stage.memAddresses := ex_mem.dmem_addresses
  io.debug.mem_stage.memRead := ex_mem.memRead
  io.debug.mem_stage.memWrite := ex_mem.memWrite
  io.debug.mem_stage.baseAddr0 := ex_mem.dmem_addresses(0)


  io.debug.wb_stage.rd := mem_wb.rd
  io.debug.wb_stage.regWrite := mem_wb.regWrite
  io.debug.wb_stage.writeData := Mux(mem_wb.memRead, mem_wb.mem_data, mem_wb.alu_result)

  io.debug.scalarRegs := scalarRegfile
  val vectorRegsDebug = Wire(Vec(23, Vec(8, SInt(32.W))))
  for (i <- 0 until 23) {
    vectorRegsDebug(i) := vectorRegfile(i)
  }
  io.debug.vectorRegs := vectorRegsDebug


val branch_taken = Wire(Bool())
branch_taken := false.B

val nextPc = WireDefault(pc + 4.S)

when(instructionType === InstructionType.J) {
  nextPc := if_id.pc + immediate(0)
}.elsewhen(instructionType === InstructionType.BEQ && rs1_data(0) === rs2_data(0)) {
  nextPc := if_id.pc + immediate(0)
}

pc := nextPc


/*
when(id_ex.instructionType === InstructionType.J) {
  branch_taken := true.B
  printf(p"Branch taken\n")
  pc := pc + id_ex.immediate(0)
}.elsewhen(id_ex.instructionType === InstructionType.BEQ && id_ex.rs1_data(0) === id_ex.rs2_data(0)) {
  branch_taken := true.B 
  printf(p"Branch taken\n")
  pc := pc + id_ex.immediate(0)
}.otherwise {
  pc := pc + 4.S
}
*/
  

}
