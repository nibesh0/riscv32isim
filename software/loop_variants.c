#include "matrix.h"
#include "multiply.h"

void matmul_selected(const int32_t a[MATRIX_N][MATRIX_N],
                     const int32_t b[MATRIX_N][MATRIX_N],
                     uint32_t c[MATRIX_N][MATRIX_N])
{
    for (int i = 0; i < MATRIX_N; ++i)
        for (int j = 0; j < MATRIX_N; ++j) c[i][j] = 0;
#if MATMUL_VARIANT == 0
    for (int i=0; i<MATRIX_N; ++i) for (int j=0; j<MATRIX_N; ++j) for (int k=0; k<MATRIX_N; ++k)
#elif MATMUL_VARIANT == 1
    for (int i=0; i<MATRIX_N; ++i) for (int k=0; k<MATRIX_N; ++k) for (int j=0; j<MATRIX_N; ++j)
#elif MATMUL_VARIANT == 2
    for (int j=0; j<MATRIX_N; ++j) for (int i=0; i<MATRIX_N; ++i) for (int k=0; k<MATRIX_N; ++k)
#elif MATMUL_VARIANT == 3
    for (int j=0; j<MATRIX_N; ++j) for (int k=0; k<MATRIX_N; ++k) for (int i=0; i<MATRIX_N; ++i)
#elif MATMUL_VARIANT == 4
    for (int k=0; k<MATRIX_N; ++k) for (int i=0; i<MATRIX_N; ++i) for (int j=0; j<MATRIX_N; ++j)
#else
    for (int k=0; k<MATRIX_N; ++k) for (int j=0; j<MATRIX_N; ++j) for (int i=0; i<MATRIX_N; ++i)
#endif
        c[i][j] += product_bits(a[i][k], b[k][j]);
}
