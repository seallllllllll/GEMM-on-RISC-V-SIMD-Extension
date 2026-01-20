// baseline.c — scalar 8x8 GEMM baseline (plain triple-loop)
// Memory map aligned with your SIMD asm kernels:
//   A base = 0 bytes
//   B base = 256 bytes
//   C base = 512 bytes
// Data type: int32_t, row-major 8x8.
//
// - Each row is 8 * 4 = 32 bytes
// - C is zero-initialized by data.hex

#include <stdint.h>

#define N 8
#define A_BASE 0x00000000u
#define B_BASE 0x00000100u  // 256
#define C_BASE 0x00000200u  // 512

static inline volatile int32_t *ptr_i32(uint32_t byte_addr) {
  return (volatile int32_t *)(uintptr_t)byte_addr;
}

int main(void) {
  // Point to the same DMEM layout used by your asm versions
  volatile int32_t *A = ptr_i32(A_BASE);
  volatile int32_t *B = ptr_i32(B_BASE);
  volatile int32_t *C = ptr_i32(C_BASE);

  // Plain triple-loop GEMM: C = A * B
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      int32_t sum = 0;
      for (int k = 0; k < N; k++) {
        // row-major indexing
        int32_t a = A[i * N + k];
        int32_t b = B[k * N + j];
        sum += a * b;
      }
      C[i * N + j] = sum;
    }
  }

  // Stop here so the testbench can terminate on "PC stable" / infinite loop.
  while (1) { }
}
