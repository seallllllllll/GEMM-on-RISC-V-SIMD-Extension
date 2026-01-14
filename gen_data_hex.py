# gen_data_hex.py
# generate data.hex：each line is one 32-bit word (8 hex digits)
# Layout: A(64) + B(64) + C_init(64)
# Also generates golden_C.hex for reference checking.

def to_u32(x: int) -> int:
    return x & 0xFFFFFFFF

def write_hex_words(words, path):
    with open(path, "w", encoding="utf-8") as f:
        for w in words:
            f.write(f"{to_u32(w):08X}\n")

def matmul_ref(A, B, N=8):
    C = [[0]*N for _ in range(N)]
    for i in range(N):
        for j in range(N):
            s = 0
            for k in range(N):
                s += A[i][k] * B[k][j]
            C[i][j] = s
    return C

def flatten_row_major(M, N=8):
    return [M[i][j] for i in range(N) for j in range(N)]

def main():
    N = 8

    # A = Identity
    A = [[1 if i == j else 0 for j in range(N)] for i in range(N)]

    # B = 1..64 row-major (matches your main.c)
    B = [[i*N + j + 1 for j in range(N)] for i in range(N)]

    # C init = 0
    C0 = [[0 for _ in range(N)] for _ in range(N)]

    # Reference C
    C_ref = matmul_ref(A, B, N)

    # data.hex = A + B + C_init
    words = flatten_row_major(A, N) + flatten_row_major(B, N) + flatten_row_major(C0, N)
    write_hex_words(words, "data.hex")

    # golden_C.hex = reference C only (64 words)
    write_hex_words(flatten_row_major(C_ref, N), "golden_C.hex")

    print("Generated data.hex with", len(words), "words")
    print("Generated golden_C.hex with", N*N, "words")

if __name__ == "__main__":
    main()
