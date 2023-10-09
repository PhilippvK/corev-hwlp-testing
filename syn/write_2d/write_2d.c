#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline))  write_2d(size_t m, size_t n, uint32_t matrix[m][n])
{
    size_t counter;
    for (size_t i = 1; i < m; i++)
    {
        for (size_t j = 1; j < n; j++)
        {
            matrix[i][j] = i * j;
        }
    }
}

#define M 256
#define N 256

static uint32_t matrix[M][N] = {[0 ... 255][0 ... 255] = 3};


int main() {
    printf("before=%u %u %u\n", matrix[1][1],  matrix[2][2], matrix[3][3]);
    write_2d(M, N, matrix);
    printf("after=%u %u %u\n", matrix[1][1],  matrix[2][2], matrix[3][3]);
    return 0;
}
