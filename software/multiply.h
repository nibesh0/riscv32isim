#ifndef MULTIPLY_H
#define MULTIPLY_H
#include <stdint.h>

static inline uint32_t shift_add_bits(int32_t a, int32_t b)
{
    uint32_t ua = (uint32_t)a;
    uint32_t ub = (uint32_t)b;
    int negative = (a < 0) != (b < 0);
    if (a < 0) ua = 0u - ua;
    if (b < 0) ub = 0u - ub;
    uint32_t result = 0;
    while (ub) {
        if (ub & 1u) result += ua;
        ua <<= 1;
        ub >>= 1;
    }
    return negative ? 0u - result : result;
}

static inline uint32_t product_bits(int32_t a, int32_t b)
{
#if SOFTWARE_MUL
    return shift_add_bits(a, b);
#else
    return (uint32_t)a * (uint32_t)b;
#endif
}
#endif
