#include <stdio.h>
#include <mpi.h>

MPI_Comm localcomm = MPI_COMM_NULL;
MPI_Comm comm;

void main(){
	/* To be consistent with "spmd.c" to be called by
           "zzz.r" or "spmd_communicator.r". */
	int flag;
	MPI_Initialized(&flag);

#ifndef MPI2
	static int fake_argc = 1;
	char *fake_argv[1];
	char *fake_argv0 = "R";
#endif

	if(!flag){
#ifndef MPI2
		fake_argv[0] = (char *) &fake_argv0;
		MPI_Init(&fake_argc, (char ***) (void*) &fake_argv);
#else
		MPI_Init((void *) 0, (void *) 0);
#endif
	}

	MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
	MPI_Comm_set_errhandler(MPI_COMM_SELF, MPI_ERRORS_RETURN);
	comm = MPI_COMM_WORLD;
#if MPI_VERSION >= 3
	if(localcomm == MPI_COMM_NULL){
		MPI_Comm_split_type(comm, MPI_COMM_TYPE_SHARED, 0, MPI_INFO_NULL, &localcomm);
	}
#endif

	/* To be consistent with "a.r". */
	int size, rank;
	MPI_Comm_size(comm, &size);
	MPI_Comm_rank(comm, &rank);
	printf("[C] size: %d, rank: %d\n", size, rank);

	/* To be consistent with "spmd.c" called by "spmd_communicator.r". */
	MPI_Finalized(&flag);
	if(! flag){
		MPI_Finalize();
	}
}

