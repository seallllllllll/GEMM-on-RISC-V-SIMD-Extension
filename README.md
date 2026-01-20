# RISC-V Basic SIMD


## Overview

This project evaluates **GEMM (General Matrix Multiplication) acceleration** on a simple 32-bit RISC-V processor extended with a **custom fixed-width packed-SIMD architecture**. The processor is a 5-stage in-order pipeline, and the SIMD extension provides **8 lanes of 32-bit integer execution** through explicit software-managed vector operations.

Rather than designing a full-featured or scalable vector ISA (such as RVV), this project focuses on **understanding and exploiting data-level parallelism** using a small, non-scalable SIMD model. This design serves as a controlled experimental platform for studying how packed-SIMD techniques affect GEMM performance relative to a scalar baseline.

The project follows a structured workflow:

1. Establish a **scalar GEMM baseline** for correctness and cycle-count reference
2. Understand and validate the provided **custom SIMD execution model**
3. Implement a **naive SIMD GEMM** by vectorizing the inner loop across output columns
4. Apply **SIMD-specific optimizations**, including register blocking and instruction scheduling
5. Measure and analyze **cycle-level performance improvements** across all implementations

## Project Structure


```
RISC-V-Basic-SIMD/
├── README.md                # Project documentation
│
├── scalar_baseline.s        # Hand-written scalar GEMM baseline (assembly)
├── gemm_naive.s             # Naive SIMD GEMM (1×8 mapping)
├── gemm_optimized.s         # Optimized SIMD GEMM (register blocking, scheduling)
│
├── scalar_baseline.c        # C reference GEMM (functional golden model only)
│
├── custom_assembler.py      # Customized assembler with SIMD instruction support
├── gen_data_hex.py          # Data memory image generator
│
├── inst.hex                 # Instruction memory image generated from .s files
├── data.hex                 # Data memory initialization image (A, B, C)
├── golden_C.hex             # Golden reference output for correctness checking
│
├── src/                     # Chisel implementation of the processor
│   ├── main/
│   │   └── scala/
│   │       ├── Processor.scala
│   │       ├── ALU.scala
│   │       ├── DataMemory.scala
│   │       └── DebugModule.scala
│   └── test/
│       └── ProcessorTester.scala
│
├── project/                 # sbt project configuration
├── build.sbt                # sbt build file
├── test_run_dir/            # Simulation outputs
└── target/                  # sbt build artifacts

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
     python3 custom_assembler.py [filename].s -o inst.hex
     cp inst.hex ~/RISC-V-Basic-SIMD/src/main/resources/inst.hex
     python3 gen_data_hex.py /Users/suniachiu/RISC-V-Basic-SIMD/src/main/resources/inst.hex
     cp data.hex /Users/suniachiu/RISC-V-Basic-SIMD/src/main/resources/data.hex
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

### SIMD GEMM Correctness Verification

To demonstrate the functionality of the custom SIMD extension in a realistic
workload, the project evaluates an 8×8 integer GEMM kernel implemented in
hand-written RISC-V assembly.

For correctness verification, matrix A is initialized as the identity matrix,
and matrix B is initialized with a fixed 8×8 test pattern. Under this setup, the
expected result is:

C = A × B = B

After program execution, the computed result matrix C is read back from data
memory and compared element-wise against a golden reference (`golden_C.hex`)
using the provided testbench.

Successful execution confirms correct SIMD instruction execution, memory access,
and register aliasing behavior prior to performance evaluation.

