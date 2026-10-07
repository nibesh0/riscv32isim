#include "matrix.h"
#include "multiply.h"

void matmul_selected(const int32_t a[MATRIX_N][MATRIX_N],
                     const int32_t b[MATRIX_N][MATRIX_N],
                     uint32_t c[MATRIX_N][MATRIX_N])
{
    for (int i = 0; i < MATRIX_N; ++i) {
        uint32_t *row = c[i];
        for (int j = 0; j < MATRIX_N; ++j) row[j] = 0;
        for (int k = 0; k < MATRIX_N; ++k) {
            int32_t aik = a[i][k];
            const int32_t *brow = b[k];
            for (int j = 0; j < MATRIX_N; ++j)
                row[j] += product_bits(aik, brow[j]);
        }
    }
}
