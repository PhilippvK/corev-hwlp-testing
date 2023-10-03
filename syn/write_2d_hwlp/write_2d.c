#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline))  write_2d(size_t m, size_t n, uint32_t matrix[m][n])
{
    register size_t counter;
    register size_t i = 0;
    register size_t j = 0;
    
    register uint32_t tmp0;
    register uint32_t tmp1;
    register uint32_t tmp2;
    register uint32_t tmp3;
    register uint32_t tmp4;


    asm volatile (    
        "cv.count  1, %[m];"
        ".balign 4;"
        "cv.endi   1, endO;"
        "cv.starti 1, startO;"
        ".balign 4;"
        "cv.endi   0, endZ;"
        "cv.starti 0, startZ;"
        ".balign 4;"
        ".option norvc;"
        "startO:;"
        "        startZ:"
        "           mv   %[tmp3], %[i];"
        "           mv   %[tmp4], %[j];"
        "           addi %[tmp3], %[tmp3], 1;"
        "           addi %[tmp4], %[tmp4], 1;"
        "           mul  %[tmp0], %[tmp3], %[tmp4];"
        "           slli %[tmp1], %[i], 2;" 
        "           add  %[tmp1], %[tmp1], %[j];" 
        "           slli %[tmp1], %[tmp1], 2;" 
        "           add  %[tmp2], %[matrix], %[tmp1];"  
        "           sw   %[tmp0], 0(%[tmp2]);"  
        "        endZ:   addi %[j], %[j], 1;"
        "        cv.count  0, %[n];"
        "        mv   %[counter], %[i];"
        "endO:   addi %[i], %[i], 1;"

        : [tmp0] "+r" (tmp0),[tmp1] "+r" (tmp1), [tmp3] "+r" (tmp3), [tmp4] "+r" (tmp4), [tmp2] "+r" (tmp2), [matrix] "+r" (matrix)
        : [m] "r" (m), [n] "r" (n), [counter] "r" (counter)   , [i] "r" (i), [j] "r" (j)
        
    );

}

#define M 256
#define N 256

static uint32_t matrix[M][N] = {[0 ... 255][0 ... 255] = 3};


int main() {
    printf("before=%u %u %u\n", matrix[0][0],  matrix[0][1], matrix[0][2]);
    write_2d(M, N, matrix);
    printf("after=%u %u %u\n", matrix[0][0],  matrix[0][1], matrix[0][2]);
    return 0;
}

