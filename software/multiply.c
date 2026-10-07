#include "matrix.h"
#include "multiply.h"

int32_t software_multiply(int32_t a, int32_t b)
{
    union { uint32_t bits; int32_t signed_value; } result;
    result.bits = product_bits(a, b);
    return result.signed_value;
}
