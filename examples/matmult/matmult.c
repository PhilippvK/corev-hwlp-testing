#include <stdint.h>

#define N 100
#define K 100
#define M 100

// void mat_mult(const int8_t *mat_l, const int8_t *mat_r, int *result, const unsigned int N, const unsigned int K, const unsigned int M)
int mat_mult(const int8_t *mat_l, const int8_t *mat_r, int *result)
{
    unsigned int n, k, m;
    unsigned int row, col;
    int accumulator;

    for (m = 0; m < M; m++)
    {
        for (n = 0; n < N; n++)
        {
            row = n*K;
            accumulator = 0;
            for (k = 0; k < K; k++)
            {
                col = k*M;
                accumulator += mat_l[row + k] * mat_r[col + m];
            }
            // result[n*M + m] = accumulator / div[n*M + m];
            result[n*M + m] = accumulator;
        }
    }
    accumulator = 0;
    for (m = 0; m < M; m++)
    {
        for (n = 0; n < N; n++)
        {
            int tmp = result[n*M + m];
            accumulator += tmp;
        }
    }
    return accumulator;
}

int main() {
    const int8_t A[N*K];
    const int8_t B[K*M];
    int C[N*M];
    return mat_mult(&A[0], &B[0], &C[0]);
}
