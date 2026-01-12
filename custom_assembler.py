import re
import sys

INSTRUCTION_SET = {
    "addi": {"type": "I", "opcode": "0010011", "funct3": "000"},
    "vload": {"type": "I", "opcode": "1111111", "funct3": "000"}, 
    "vstore": {"type": "S", "opcode": "1000000", "funct3": "000"},
    "vadd": {"type": "R", "opcode": "0110011", "funct3": "111", "funct7": "1111111"},
    "beq": {"type": "B", "opcode": "1100011", "funct3": "000"},
    "j": {"type": "J", "opcode": "1101111"},

}

def to_signed_binary(num, bit_length):
    if num < 0:
        num = (1 << bit_length) + num
    
    return format(num, f'0{bit_length}b')


def encode_register(register):
    """
    Map register names to custom binary encoding.
    - `x0` is `00000`
    - `x1` to `x8` (scalar) are mapped normally.
    - `x9` to `x31` (vector) are mapped as vector registers.
    """
    if register == "x0":
        return "00000"
    elif register[0]=="x":
        return f"{int(register[1:]):05b}"
    elif register[0]=="v":
        return f"{int(register[1:])+8:05b}"
    elif isinstance(register, int):
        return int(register)
    else:
        raise ValueError(f"Invalid register: {register}")

def parse_assembly_line(line):
    """Parse a single line of assembly code."""
    #ex: addi x1, x2, -5
    #tokens = ["addi", "x1", "x2", "-5"]
    #instruction = "addi"
    #operands = ["x1", "x2", "-5"]
    
    tokens = re.split(r"[,\s]+", line.strip())
    instruction = tokens[0]
    operands = tokens[1:]
    return instruction, operands

# Convert an instruction into 32-bit binary
def encode_instruction(instruction, operands):
    """Encode an instruction to machine code."""
    if instruction not in INSTRUCTION_SET:
        raise ValueError(f"Unknown instruction: {instruction}")
    
    instr_data = INSTRUCTION_SET[instruction]
    instr_type = instr_data["type"]
    opcode = instr_data["opcode"]
    funct3 = instr_data.get("funct3", "")
    funct7 = instr_data.get("funct7", "")

    # funct7 rs2 rs1 funct3 rd opcode R-type
    if instr_type == "R":
        rd = encode_register(operands[0])
        rs1 = encode_register(operands[1])
        rs2 = encode_register(operands[2])
        binary = f"{funct7}{rs2}{rs1}{funct3}{rd}{opcode}"

    # Special case: vload uses the memory address format
    # ex: vload v0, 16(x1)
    # operands[0] = v0 → rd
    # operands[1] = 16(x1) → offset = 16, base = x1
    # imm = 16 → 12-bit
    elif instr_type == "I" and instruction in ["vload"]:
        offset, base = re.match(r"(\d+)\((x\d+)\)", operands[1]).groups()
        rd = encode_register(operands[0])
        rs1 = encode_register(base)
        imm = int(offset)
        imm_bin = f"{imm:012b}"
        binary = f"{imm_bin}{rs1}{funct3}{rd}{opcode}"

    # imm[11:0] rs1 funct3 rd opcode I-type
    # ex: addi x1, x2, -5
    elif instr_type == "I":
        rd = encode_register(operands[0])
        rs1 = encode_register(operands[1])
        imm = int(operands[2])
        imm_bin = to_signed_binary(imm, 12)
        # imm_bin = f"{imm:012b}"
        binary = f"{imm_bin}{rs1}{funct3}{rd}{opcode}"

    # imm[11:5] rs2 rs1 funct3 imm[4:0] opcode S-type
    # ex: vstore
    elif instr_type == "S":
        offset, base = re.match(r"(\d+)\((x\d+)\)", operands[1]).groups()
        rs1 = encode_register(base)
        rs2 = encode_register(operands[0])
        imm = int(offset)
        # imm_bin = f"{imm:012b}"
        imm_bin = to_signed_binary(imm, 12)
        imm_high = imm_bin[:7]
        imm_low = imm_bin[7:]
        binary = f"{imm_high}{rs2}{rs1}{funct3}{imm_low}{opcode}"

    # imm[12|10:5] rs2 rs1 funct3 imm[4:1|11] opcode B-type
    # ex: beq x1, x2, 16
    elif instr_type == "B":
        rs1 = encode_register(operands[0])
        rs2 = encode_register(operands[1])
        imm = int(operands[2])
        # imm_bin = f"{imm:012b}"
        imm_bin = to_signed_binary(imm, 13)
        imm_high = imm_bin[:1]
        imm_mid = imm_bin[2:8]
        imm_low = imm_bin[8:12]
        imm_low2 = imm_bin[1]
        binary = f"{imm_high}{imm_mid}{rs2}{rs1}{funct3}{imm_low}{imm_low2}{opcode}"
    
    # imm[20|10:1|11|19:12] rd opcode J-type
    # ex: j 128
    elif instr_type == "J":
        rd = "00000"
        imm = int(operands[0])
        # imm_bin = f"{imm:020b}"
        imm_bin = to_signed_binary(imm, 21)
        imm_high = imm_bin[:1]
        imm_mid = imm_bin[10:20]
        imm_low = imm_bin[9]
        imm_low2 = imm_bin[1:9]
        binary = f"{imm_high}{imm_mid}{imm_low}{imm_low2}{rd}{opcode}"


    else:
        raise ValueError(f"Unsupported instruction type: {instr_type}")

    return binary
    
# Process the entire assembly string line by line
def assemble(assembly_code):
    """Convert assembly code to machine code."""
    machine_code = []
    for line in assembly_code.strip().lower().split("\n"):
        if not line.strip() or line.strip().startswith("#"):
            continue  # Skip empty lines and comments
        if line.strip()=="nop":
            machine_code.append("00000000000000000000000000101010")
        else:
            instruction, operands = parse_assembly_line(line)
            machine_code.append(encode_instruction(instruction, operands))
    return machine_code

# input.asm: an assembly language program
# output.hex: the output filename (default = out.hex)
if __name__ == "__main__":
    if len(sys.argv) not in [2, 4]:
        print("Usage: python assembler.py <assembly_file> [-o <output_file>]")
        sys.exit(1)

    assembly_file = sys.argv[1]
    output_file = "out.hex"

    if len(sys.argv) == 4:
        if sys.argv[2] == "-o":
            output_file = sys.argv[3]
        else:
            print("Usage: python assembler.py <assembly_file> [-o <output_file>]")
            sys.exit(1)

    try:
        with open(assembly_file, "r") as f:
            assembly_code = f.read()
        
        machine_code = assemble(assembly_code)
        output_lines = [f"{int(code, 2):08x}".upper() for code in machine_code]

        if output_file:
            with open(output_file, "w") as f:
                f.write("\n".join(output_lines))
        else:
            for line in output_lines:
                print(line)
    except Exception as e:
        print(f"Error: {e}")
