#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
	// Initialize the MPI environment
	MPI_Init(&argc, &argv);

	// Finalize the MPI environment.
	MPI_Finalize();
}
