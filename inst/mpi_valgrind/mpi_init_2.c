#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
	// Initialize the MPI environment
	MPI_Init((void *) 0, (void *) 0);

	// Finalize the MPI environment.
	MPI_Finalize();
}
