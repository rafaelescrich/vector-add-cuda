#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define N 100000000

__global__ void add(int *a, int *b, int *c) {
	c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

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
	int nDevices;
	cudaGetDeviceCount(&nDevices);
	for (int i = 0; i < nDevices; i++) {
		cudaDeviceProp prop;
		cudaGetDeviceProperties(&prop, i);
		printf("Device Number: %d\n", i);
		printf("  Device name: %s\n", prop.name);
		printf("  Memory Clock Rate (KHz): %d\n",
			prop.memoryClockRate);
		printf("  Memory Bus Width (bits): %d\n",
			prop.memoryBusWidth);
		printf("  Peak Memory Bandwidth (GB/s): %f\n\n",
			2.0*prop.memoryClockRate*(prop.memoryBusWidth/8)/1.0e6);
	}

	int *a, *b, *c; // host copies of a, b, c
	int *d_a, *d_b, *d_c; // device copies of a, b, c
	int size = N * sizeof(int);
	
	// Alloc space for device copies of a, b, c
	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);
	// setup input values
	a = (int *)malloc(size); random_ints(a, N);
	b = (int *)malloc(size); random_ints(b, N);
	c = (int *)malloc(size);

	// Copy inputs to device
	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
	
	// start timer
	gettimeofday(&t1, NULL); 
	// Launch add() kernel on GPU with N blocks
	// Alloc space for host copies of a, b, c and 
	add<<<N,1>>>(d_a, d_b, d_c);
	// stop timer
	gettimeofday(&t2, NULL);
	

	// Copy result back to host
	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
	
	// Cleanup
	free(a); free(b); free(c);
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

	elapsed = (t2.tv_sec * 1000000 + t2.tv_usec)-(t1.tv_sec * 1000000 + t1.tv_usec);
	printf("The sum of two arrays took: %ld milliseconds\n", elapsed);

	return 0;
}