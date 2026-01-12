# gen_data_hex.py
# generate data.hex：each column 32-bit word（8 hex digits）
# A(64) + B(64) + C(64)

def to_u32(x: int) -> int:
    # transfer to 32-bit two's complement
    return x & 0xFFFFFFFF

def write_hex_words(words, path="data.hex"):
    with open(path, "w", encoding="utf-8") as f:
        for w in words:
            f.write(f"{to_u32(w):08X}\n")

def main():
    M = N = 8

    
    # A: 1..64
    A = [i for i in range(1, M*N + 1)]
    # B: all 1
    B = [1 for _ in range(M*N)]
    # C: all 0
    C = [0 for _ in range(M*N)]

    words = A + B + C
    write_hex_words(words, "data.hex")
    print("Generated data.hex with", len(words), "words")

if __name__ == "__main__":
    main()
