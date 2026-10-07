#include "matrix.h"
#include "multiply.h"

void matmul_selected(const int32_t a[MATRIX_N][MATRIX_N],
                     const int32_t b[MATRIX_N][MATRIX_N],
                     uint32_t c[MATRIX_N][MATRIX_N])
{
    for (int i = 0; i < MATRIX_N; ++i)
        for (int j = 0; j < MATRIX_N; ++j) {
            uint32_t sum = 0;
            for (int k = 0; k < MATRIX_N; ++k)
                sum += product_bits(a[i][k], b[k][j]);
            c[i][j] = sum;
        }
}
