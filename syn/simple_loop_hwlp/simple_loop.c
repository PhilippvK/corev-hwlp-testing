#include <stdio.h>
#include <stdint.h>
#include <stddef.h>


uint32_t __attribute__ ((noinline)) simple_loop(size_t n)
{
    register uint32_t sum = 0;
    register uint32_t j = 0;
    register uint32_t a = 0;
    register uint32_t b = 0;
    register uint32_t c = 0;

    asm volatile (
        "cv.count  0, %[n];"
        ".balign 4;"
        "cv.endi   0, endZ;"
        "cv.starti 0, startZ;"
        ".option norvc;"
            "startZ:;"
            "        slli  %[a], %[j], 1;"
            "        addi %[b], %[a], 3;"
            "        slli  %[c], %[b], 2;"
            "        add  %[sum], %[sum], %[c];"
            "        addi %[j], %[j], 1;"
            "endZ:   addi x0, x0, 0;"
        : [sum] "+r" (sum), [j] "+r" (j), [a] "+r" (a), [b] "+r" (b), [c] "+r" (c)
        : [n] "r" (n)
    );
    return sum;
}

#define N 2048

int main() {
    uint32_t ret = simple_loop(N);
    printf("ret=%u\n", ret); 
    return 0;
}
