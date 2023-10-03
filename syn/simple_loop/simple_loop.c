#include <stdio.h>
#include <stdint.h>
#include <stddef.h>


 uint32_t __attribute__ ((noinline)) simple_loop(size_t n)
{
    uint32_t sum = 0;
    uint32_t j = 0;
    for (size_t i = 0; i < n; i++)
    {
        sum += j;
        j += 1;

    }
    return sum;
}


#define N 2048

int main() {
    uint32_t ret = simple_loop(N);
    printf("ret=%u\n", ret); 
    return 0;
}
