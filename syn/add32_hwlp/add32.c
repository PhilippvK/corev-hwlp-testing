#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline)) add32(size_t n, uint32_t d[n], uint32_t a[n], uint32_t b[n])
{
    register uint32_t tmp0;
    register uint32_t tmp1;
    register uint32_t tmp2;

    register uint32_t* a_ptr = a;
    register uint32_t* b_ptr = b;
    register uint32_t* d_ptr = d;

    asm volatile (
        ".option norvc;"
        "cv.count  0, %[n];"
        "cv.starti 0, startZ;"
        "cv.endi   0, endZ;"
            "startZ:  lw  %[tmp0], 0(%[a_ptr]);"
            "         lw  %[tmp1], 0(%[b_ptr]);"
            "         lw  %[tmp2], 0(%[d_ptr]);"
            "         add %[tmp2], %[tmp0], %[tmp1];" 
            "         sw  %[tmp2], 0(%[d_ptr]);"
            "         addi %[a_ptr], %[a_ptr], 4;"
            "         addi %[b_ptr], %[b_ptr], 4;"
            "endZ:    addi %[d_ptr], %[d_ptr], 4;"
        : [tmp0] "=r" (tmp0), [tmp1] "=r" (tmp1), [tmp2] "=r" (tmp2), [a_ptr] "+r" (a_ptr), [b_ptr] "+r" (b_ptr), [d_ptr] "+r" (d_ptr)
        : [n] "r" (n), [a] "r" (a), [b] "r" (b), [d] "r" (d)
    ); 
}


#define N 1024

static uint32_t array1[N] = {[0 ... 1023] = 2};
static uint32_t array2[N] = {[0 ... 1023] = 3};
static uint32_t array3[N] = {[0 ... 1023] = 0};


int main() {
    add32(N, (uint32_t*)array3,(uint32_t*)array1, (uint32_t*)array2);
    for (size_t i = 0; i < 3; i++)
    {
        printf("%u ", array3[i]);
        printf(" ");
    }
    printf("\n");
    printf("arr1=%u %u %u\n", array1[0], array1[1], array1[2]);
    printf("arr2=%u %u %u\n", array2[0], array2[1], array2[2]);
    return 0;
}
