#ifndef MATRIX_H
#define MATRIX_H
#include <stdint.h>
#ifndef MATRIX_N
#define MATRIX_N 4
#endif
int32_t software_multiply(int32_t a, int32_t b);
void matmul_selected(const int32_t a[MATRIX_N][MATRIX_N],
                     const int32_t b[MATRIX_N][MATRIX_N],
                     uint32_t c[MATRIX_N][MATRIX_N]);
#endif
