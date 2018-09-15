#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdio.h>

#define N 100000000

void random_ints(int* x, int size)
{
	int i;
	for (i=0;i<size;i++) {
		x[i]=rand()%100000000;
	}
}

int main(void)
{
    struct timeval t1, t2;
    long elapsed;

    int *a, *b, *c; // host copies of a, b, c
    int size = N * sizeof(int);

     // setup input values
	a = (int *)malloc(size); random_ints(a, N);
	b = (int *)malloc(size); random_ints(b, N);
	c = (int *)malloc(size);

    // start timer
    gettimeofday(&t1, NULL);
    // sum a,b vectors
    for (int i = 0; i < N; i++)
        c[i] = a[i] + b[i];
    // stop timer
    gettimeofday(&t2, NULL);

    // Cleanup
    free(a); free(b); free(c);

    elapsed = (t2.tv_sec * 1000000 + t2.tv_usec)-(t1.tv_sec * 1000000 + t1.tv_usec);
    printf("The sum of two arrays took: %ld milliseconds\n", elapsed);

    return 0;
}