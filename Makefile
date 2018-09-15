build-cuda:
	nvcc vector-add-cuda.cu -o vector-add-cuda
build-c:
	gcc vector-add.c -o vector-add