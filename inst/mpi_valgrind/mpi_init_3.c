#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
	static int fake_argc = 1;
	char *fake_argv[1];
	char *fake_argv0 = "R";

	// Initialize the MPI environment
	fake_argv[0] = (char *) &fake_argv0;
	MPI_Init(&fake_argc, (char ***) (void*) &fake_argv);

	// Finalize the MPI environment.
	MPI_Finalize();
}
