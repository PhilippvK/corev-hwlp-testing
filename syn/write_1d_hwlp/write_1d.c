#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline)) write_1d(size_t n, uint32_t array[n])
{
    register uint32_t tmp0;

    register uint32_t* a_ptr = array;

    asm volatile (
        ".option norvc;"
        "cv.count  0, %[n];"
        "cv.starti 0, startZ;"
        "cv.endi   0, endZ;"
            "startZ:  lw  %[tmp0], 0(%[a_ptr]);"
            "         add %[tmp0], %[tmp0], %[tmp0];" 
            "         sw  %[tmp0], 0(%[a_ptr]);"
            "endZ:    addi %[a_ptr], %[a_ptr], 4;"
        : [tmp0] "=r" (tmp0), [a_ptr] "+r" (a_ptr)
        : [n] "r" (n), [a] "r" (array)
    ); 

}

#define N 1024

static uint32_t array[N] = {[0 ... 1023] = 3};


int main() {
    printf("before=%u %u %u\n", array[0], array[1], array[2]);
    write_1d(N, (uint32_t*)array);
    printf("after=%u %u %u\n", array[0], array[1], array[2]);
    return 0;
}
