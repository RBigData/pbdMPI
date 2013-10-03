#include "spmd.h"

#ifdef MPI2
SEXP spmd_comm_spawn(SEXP R_worker, SEXP R_workerargv, SEXP R_n_workers,
		SEXP R_info, SEXP R_rank_source, SEXP R_intercomm){
	int i, n_workers = INTEGER(R_n_workers)[0], len = LENGTH(R_workerargv);
	int infon = INTEGER(R_info)[0], rank_source = INTEGER(R_rank_source)[0];
	int intercommn = INTEGER(R_intercomm)[0], *worker_errcodes, realns;

	worker_errcodes = (int *) Calloc(n_workers, int);
	if(len == 0){
		spmd_errhandler(MPI_Comm_spawn(CHARPT(R_worker, 0),
			MPI_ARGV_NULL, n_workers, info[infon], rank_source,
			MPI_COMM_SELF, &comm[intercommn], worker_errcodes)); 
        } else{
		char **argv = (char **) R_alloc(len + 1, sizeof(char *));
		for(i = 0; i < len; i++){
			argv[i] = CHARPT(R_workerargv, i);
		}
		argv[len] = NULL;
		spmd_errhandler(MPI_Comm_spawn(CHARPT(R_worker, 0),
			argv, n_workers, info[infon], rank_source, MPI_COMM_SELF,
			&comm[intercommn], worker_errcodes)); 
	}
	MPI_Comm_remote_size(comm[intercommn], &realns);
	if(realns < n_workers){
		for(i = 0; i < n_workers; i++){
			spmd_errhandler(worker_errcodes[i]);
		}
	}

        Free(worker_errcodes);

	Rprintf("\t%d workers are spawned successfully. %d failed.\n",
		realns, n_workers - realns);
	return AsInt(realns);
} /* End of spmd_comm_spawn(). */
#endif
