#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

void __attribute__ ((noinline)) write_1d(size_t n, uint32_t array[n])
{
    for (size_t i = 0; i < n; i++)
    {
        array[i] = array[i] * 2;
    }
}


#define N 1024

static uint32_t array[N] = {[0 ... 1023] = 3};


int main() {
    printf("before=%u %u %u\n", array[0], array[1], array[2]);
    write_1d(N, (uint32_t*)array);
    printf("after=%u %u %u\n", array[0], array[1], array[2]);
    return 0;
}
