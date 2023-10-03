#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline))  write_2d(size_t m, size_t n, uint32_t matrix[m][n])
{
    size_t counter;
    for (size_t i = 0; i < m; i++)
    {
        for (size_t j = 0; j < n; j++)
        {
            matrix[i][j] = (i+1) * (j+1);
        }
        counter = i;
    }
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
