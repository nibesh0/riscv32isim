#include "matrix.h"
#include "fixture.h"

static uint32_t C[MATRIX_N][MATRIX_N] __attribute__((section(".matrix_results")));
static volatile uint32_t signature[4] __attribute__((section(".signature")));
static volatile uint32_t *const timer = (volatile uint32_t *)0xfffffff0u;

static volatile uint32_t initialized = 17;
static volatile uint32_t zero_initialized;
static const int32_t operands[][2] = {
    {0, -8}, {-7, 6}, {-7, -6}, {9, -3}, {2147483647, 1},
    {(-2147483647 - 1), 1}, {(-2147483647 - 1), -1},
    {(-2147483647 - 1), 0}, {(-2147483647 - 1), 2}
};
static const uint32_t products[] = {
    0, 0xffffffd6u, 42, 0xffffffe5u, 0x7fffffffu,
    0x80000000u, 0x80000000u, 0, 0
};

int main(void)
{
    signature[0] = 0;
    if (initialized != 17 || zero_initialized != 0) return 1;
    for (unsigned i = 0; i < sizeof(products)/sizeof(products[0]); ++i)
        if ((uint32_t)software_multiply(operands[i][0], operands[i][1]) != products[i]) return 2;
    *timer = 1;
    matmul_selected(A, B, C);
    *timer = 2;
    uint32_t checksum = 0;
    for (int i = 0; i < MATRIX_N; ++i)
        for (int j = 0; j < MATRIX_N; ++j) checksum += C[i][j];
    signature[1] = MATRIX_N;
    signature[2] = checksum;
    signature[3] = C[MATRIX_N-1][MATRIX_N-1];
    signature[0] = 0x50415353u;
    return 0;
}
