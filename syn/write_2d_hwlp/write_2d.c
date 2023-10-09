#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline))  write_2d(size_t m, size_t n, uint32_t matrix[m][n])
{
    register size_t i;
    register size_t j;
    
    register uint32_t tmp0;
    register uint32_t tmp1;

    asm volatile (    
        "add   %[i], x0, 1;"
        "add   %[j], x0, 1;"
        "cv.count  1, %[m];"
        ".balign 4;"
        "cv.endi   1, endO;"
        "cv.starti 1, startO;"
        ".balign 4;"
        ".option norvc;"
        "startO: cv.count  0, %[n];"
        "        .balign 4;"
        "        cv.endi   0, endZ;"
        "        cv.starti 0, startZ;"
        "        startZ:"
        "           mul  %[tmp0], %[i], %[j];"
        "           slli %[tmp1], %[i], 2;" 
        "           add  %[tmp1], %[tmp1], %[j];" 
        "           slli %[tmp1], %[tmp1], 2;" 
        "           add  %[matrix], %[matrix], %[tmp1];"  
        "           sw   %[tmp0], 0(%[matrix]);"  
        "           addi %[j], %[j], 1;"
        "        endZ:;"
        "        addi    %[i], %[i], 1;"
        "        addi    x0, x0, 0;"
        "        addi    x0, x0, 0;"
        "endO:;"

        : [matrix] "+r" (matrix), [tmp0] "+r" (tmp0),[tmp1] "+r" (tmp1), [i] "=r" (i), [j] "=r" (j)
        : [m] "r" (m), [n] "r" (n)
        
    );

}

#define M 256
#define N 256

static uint32_t matrix[M][N] = {[0 ... 255][0 ... 255] = 3};


int main() {
    printf("before=%u %u %u\n", matrix[0][0],  matrix[0][1], matrix[0][2]);
    write_2d(M, N, matrix);
    printf("after=%u %u %u\n", matrix[1][1],  matrix[2][2], matrix[3][3]);
    return 0;
}

