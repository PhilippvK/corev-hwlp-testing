#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

uint32_t __attribute__ ((noinline)) dot32(size_t n, uint32_t a[n], uint32_t b[n])
{
    uint32_t sum;

    register uint32_t tmp0;
    register uint32_t tmp1;

    register uint32_t* a_ptr = a;
    register uint32_t* b_ptr = b;

    asm volatile (
        ".option norvc;"
        "cv.count  0, %[n];"
        "cv.starti 0, startZ;"
        "cv.endi   0, endZ;"
        "li        %[sum], 0;"
             "startZ:  lw  %[tmp0], 0(%[a_ptr]);"
             "         lw  %[tmp1], 0(%[b_ptr]);"
             "         mul %[tmp0], %[tmp0], %[tmp1];         "
             "         add %[sum], %[sum], %[tmp0]; "
             "         addi %[a_ptr], %[a_ptr], 4;"
             "endZ:    addi %[b_ptr], %[b_ptr], 4;"
        : [sum] "=r" (sum), [tmp0] "=r" (tmp0), [tmp1] "=r" (tmp1), [a_ptr] "+r" (a_ptr), [b_ptr] "+r" (b_ptr)
        : [n] "r" (n)
    );
    return sum;
}

#define N 1024

static uint32_t array1[N] = {[0 ... 1023] = 2};
static uint32_t array2[N] = {[0 ... 1023] = 3};

int main() {
    uint32_t ret = dot32(N, (uint32_t*)array1, (uint32_t*)array2);
    printf("ret=%u\n", ret);
    printf("arr1=%u %u %u\n", array1[0], array1[1], array1[2]);
    printf("arr2=%u %u %u\n", array2[0], array2[1], array2[2]);
    return 0;
}
