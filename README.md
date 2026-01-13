# RISC-V Basic SIMD

## Overview

This project implements a basic SIMD vector processor based on the RISC-V 5-stage pipeline architecture built in Scala and Chisel. Built it as a project in Computer Organisation course. It demonstrates the concept of vector processing with a fixed-length vector array (8 lanes). 
I implemented custom instructions `vload`, `vstore`, and `vadd` for simplicity. 

### Key Features:
- **SIMD (Single Instruction, Multiple Data) processing**: Supports vectorized operations on 8-lane vectors (More of hard coded but serves the purpose.)
- **RISC-V Pipeline**: The processor follows the classic 5-stage pipeline architecture.
- **Custom Instructions**: Implements custom SIMD instructions (`vload`, `vstore`, `vadd`).
- **Written in Chisel**: The hardware description is written in Chisel and tested with Scala-based testbenches.

## Project Structure


```
RISC-V Basic SIMD/
├── build.sbt                     # SBT build configuration
├── src/                          # Source files
│   ├── main/
|   |──────── resources/
|   |           ├── data.hex                        # Data Memory
|   |           ├── inst.hex                        # Instruction Memory
│   │──────── scala
|   |           ├── ALU.scala                       # Arithmetic Logic Unit
|   |           ├── DataMemory.scala                # Data memory model
|   |           ├── DebugModule.scala               # Debugging utilities
|   |           ├── InstructionMemoryLoader.scala   # Instruction memory loader
|   |           ├── Processor.scala                 # Main Processor implementation
│   └── test/
│       ├── ProcessorTestor.scala   # Testbench for processor
├── custom_assembler.py             # Python-based custom assembler for SIMD instructions
|── # some sample assemblies to test
└── README.md
```

- **src/main**: Contains the Chisel hardware description files, including the main processor, ALU, memory modules, and loader.
- **src/test**: Contains Scala-based testbenches for verifying the design.
- **custom_assembler.py**: A Python script that assembles custom instructions like `vload`, `vstore`, and `vadd` into machine code.
- **samples**: Some basic sample assembly code I wrote to test the processor.

## Installation

### Prerequisites


- **Java Development Kit (JDK)**: I don't remember the exact version 
- **Scala**: Ensure Scala is installed.
- **SBT**: Build tool for Scala projects.
- **Chisel**: Hardware construction language
- **Python**: Required for running the custom assembler.

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

The processor supports a basic vector array of 8 lanes and demonstrates SIMD operations using custom instructions. Here's an example workflow to run the demonstration:

1. **Write Assembly Code**: Create a `.s` file (e.g., `test.s`). Example:

   ```asm
    addi x1, x0, 0
    addi x2, x0, 32
    addi x3, x0, 64
    nop
    vload v1, 0(x1)
    vload v2, 0(x2)
    nop
    nop
    nop
    vadd v3, v1, v2
    nop
    nop
    nop
    vstore v3, 0(x3)
   ```
   I would surely like to implement forwarding to eliminate nops lol.

2. **Assemble the Code**: Use the custom Python assembler to generate the binary file:

     ```bash
     python assembler.py <assembly_file> [-o <output_file>]
     // use python3 for macOS
     // python3 custom_assembler.py add8x8.s -o inst.hex
     // cp inst.hex ~/RISC-V-Basic-SIMD/src/main/resources/inst.hex
     // python3 gen_data_hex.py /Users/suniachiu/RISC-V-Basic-SIMD/src/main/resources/inst.hex
     // cp data.hex /Users/suniachiu/RISC-V-Basic-SIMD/src/main/resources/data.hex
     ```


3. **Run the Processor**: The processor will execute the instructions and perform the SIMD operations.

4. **View Results**: Check the test output in the terminal.

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

