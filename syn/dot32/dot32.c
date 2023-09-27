#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

uint32_t __attribute__ ((noinline)) dot32(size_t n, uint32_t a[n], uint32_t b[n])
{
    uint32_t sum = 0;
    for (size_t i = 0; i < n; i++)
    {
        sum += a[i] * b[i];
    }
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
