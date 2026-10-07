#include <stdint.h>
static volatile int32_t initialized = 9;
static volatile int32_t bss_value;
static volatile uint32_t signature[4] __attribute__((section(".signature")));
__attribute__((noinline)) static int32_t sum(const int32_t *a, int count)
{
    int32_t result = 0;
    for (int i = 0; i < count; ++i) result += a[i];
    return result + initialized;
}
int main(void)
{
    int32_t a[5] = {1, -2, 3, 4, 5};
    if (bss_value != 0 || sum(a, 5) != 20) return 1;
    bss_value = 7;
    signature[0] = 0x50415353u;
    signature[1] = 20;
    signature[2] = bss_value;
    signature[3] = 0;
    return 0;
}
