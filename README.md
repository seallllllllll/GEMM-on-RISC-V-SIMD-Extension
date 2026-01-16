# RISC-V Basic SIMD

## Overview

This project implements a custom fixed-width SIMD extension on top of a 32-bit
RISC-V 5-stage pipelined processor and uses it as an experimental platform to
study **GEMM (General Matrix Multiply) acceleration using packed-SIMD
techniques**.

The primary objective is **not** to build a full-featured vector ISA (e.g. RVV),
but to evaluate how a small, non-scalable SIMD design (8 lanes × 32-bit) can
improve the performance of GEMM compared to a scalar baseline.

The project follows a structured workflow:

1. Establish a **scalar GEMM baseline** for correctness and cycle count reference
2. Understand and validate the provided **custom SIMD ISA**
3. Implement a **naive SIMD GEMM** by vectorizing the inner loop
4. Apply **SIMD-specific optimizations** (register blocking, unrolling, scheduling)
5. Measure and analyze **cycle-level performance gains**


## Project Structure


```
RISC-V-Basic-SIMD/
├── build.sbt                     # SBT build configuration
├── README.md                     # Project documentation
├── custom_assembler.py           # Python-based custom assembler for SIMD instructions
├── gen_data_hex.py               # Generate data.hex for memory initialization
├── inst.hex                      # Instruction memory image
├── data.hex                      # Data memory image
├── golden_C.hex                  # Golden reference output for GEMM verification
│
├── src/
│   ├── main/
│   │   ├── resources/
│   │   │   ├── inst.hex           # Instruction Memory (used by simulator)
│   │   │   └── data.hex           # Data Memory (used by simulator)
│   │   └── scala/
│   │       ├── ALU.scala
│   │       ├── DataMemory.scala
│   │       ├── DebugModule.scala
│   │       ├── InstructionMemoryLoader.scala
│   │       └── Processor.scala
│   └── test/
│       └── ProcessorTester.scala  # Scala testbench
│
├── project/                      # SBT project metadata
├── target/                       # SBT build outputs
├── test_run_dir/                 # Simulation / test outputs
│
├── add8x8.s                      # SIMD vector add example
├── add8x8v2.s                    # Alternative SIMD add version
├── mul8x8.s                      # SIMD vector multiply example
├── mul8x8v2.s                    # Optimized SIMD multiply
├── mul_test.s                    # Scalar / SIMD multiply test
├── inst.s                        # Instruction test program
├── inst3vecadd.s                 # Vector add test
├── branchadd.s                   # Branch + add test
├── jumpadd.s                     # Jump test
├── simpleadd.s                   # Simple scalar add
├── simplebranchjump.s            # Simple branch/jump test
├── scalarquivalent.s             # Scalar-equivalent reference code
└── out.hex                       # Output dump (debug / test)
```

- **src/main**: Chisel implementation of the scalar + SIMD processor, memory
  system, and debug interfaces.
- **src/test**: Scala-based testbench used for correctness checking and golden
  reference comparison.
- **custom_assembler.py**: Assembles scalar and SIMD instructions into machine
  code for the custom ISA.
- **resources (inst.hex / data.hex)**: Instruction and data memory images used
  for GEMM experiments.


## Installation

### Prerequisites

- **Java Development Kit (JDK 11)**  
  Required by the provided SBT/Chisel toolchain (newer versions such as Java 21
  may cause build failures).
- **Scala**
- **SBT**
- **Chisel**
- **Python 3** (for the custom assembler and data generation scripts)


### Setup Instructions

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/astrophy-geek/RISC-V-Basic-SIMD.git
   cd RISC-V-Basic-SIMD
   ```

2. **Import into IntelliJ (Or use any editor)**:
   - Open IntelliJ IDEA.
   - Import the project as an Scala project.
   - Make sure the project is correctly configured for Scala and Chisel.

3. **Build the Project**:
   - Use the following command to compile the project:

     ```bash
     sbt compile
     ```

4. **Run Tests**:
   - To run tests (e.g., `ProcessorTestor`), use:

     ```bash
     sbt test
     ```

5. **Custom Assembler**:
   - Generate custom assemblies using the script custom_assembler.py

     ```bash
     python assembler.py <assembly_file> [-o <output_file>]
     // use python3 for macOS
     ```

## Usage

The processor is primarily used to execute **scalar and SIMD GEMM kernels**
for correctness verification and performance evaluation.

Typical workflow:

1. Write or modify an assembly program implementing scalar or SIMD GEMM.
2. Assemble the program using `custom_assembler.py` to generate `inst.hex`.
3. Generate `data.hex` containing matrices A, B, and C.
4. Run the simulator and collect:
   - Final C matrix (for golden comparison)
   - Cycle counts (for performance evaluation)


## Example Demonstration

Simple Vector Addition

### Input Vectors:
```
Vector A = [1, 2, 3, 4, 5, 6, 7, 8]
Vector B = [8, 7, 6, 5, 4, 3, 2, 1]
```

### SIMD Operation:
- Perform the `vadd` operation on the corresponding elements of the vectors.

### Expected Output:
```
Result = [9, 9, 9, 9, 9, 9, 9, 9]
```

## Contributing

Do whatever you like! Maybe tag/mention me!

