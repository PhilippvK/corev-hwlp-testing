#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline)) add32(size_t n, uint32_t d[n], uint32_t a[n], uint32_t b[n])
{
    for (size_t i = 0; i < n; i++)
    {
        d[i] = a[i] + b[i];
    }}

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
