#include "spmd.h"

/* ----- COMM ----- */
SEXP spmd_barrier(SEXP R_comm){
	return(AsInt(spmd_errhandler(MPI_Barrier(comm[INTEGER(R_comm)[0]]))));
} /* End of spmd_barrier(). */

SEXP spmd_comm_is_null(SEXP R_comm){
	if(comm == NULL){
		return(AsInt(-1));
	}
	return(AsInt(comm[INTEGER(R_comm)[0]] == MPI_COMM_NULL));
} /* End of RmPI_comm_is_null(). */

SEXP spmd_comm_size(SEXP R_comm){
	int size;
	MPI_Comm_size(comm[INTEGER(R_comm)[0]], &size);
	return(AsInt(size));
} /* End of spmd_comm_size(). */

SEXP spmd_comm_rank(SEXP R_comm){
	int rank;
	MPI_Comm_rank(comm[INTEGER(R_comm)[0]], &rank);
	return(AsInt(rank));
} /* End of spmd_comm_rank(). */

SEXP spmd_comm_dup(SEXP R_comm, SEXP R_newcomm){
	int commn = INTEGER(R_comm)[0], newcommn = INTEGER(R_newcomm)[0];
	if(commn == 0){
		return(AsInt(
			spmd_errhandler(MPI_Comm_dup(MPI_COMM_WORLD,
				 &comm[newcommn]))));
	} else{
		return(AsInt(
			spmd_errhandler(MPI_Comm_dup(comm[commn],
				&comm[newcommn]))));
	}
} /* End of spmd_comm_dup(). */

SEXP spmd_comm_free(SEXP R_comm){
	return(AsInt(
		spmd_errhandler(MPI_Comm_free(&comm[INTEGER(R_comm)[0]]))));
} /* End of spmd_comm_free(). */


/* ----- Intercomm ----- */
SEXP spmd_comm_set_errhandler(SEXP R_comm){
	return(AsInt(
		MPI_Errhandler_set(comm[INTEGER(R_comm)[0]],
		MPI_ERRORS_RETURN)));
} /* End of spmd_comm_set_errhandler(). */


/* ----- spawn ----- */
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

SEXP spmd_comm_get_parent(SEXP R_comm){
        return(AsInt(
		spmd_errhandler(MPI_Comm_get_parent(
			&comm[INTEGER(R_comm)[0]]))));
} /* End of spmd_comm_get_parent(). */

SEXP spmd_is_master(){
	int check;
	MPI_Comm master;
	MPI_Comm_get_parent(&master);
	check = (master == MPI_COMM_NULL);
	if(! check){
		 MPI_Comm_free(&master);
	}
	return(AsInt(check));
} /* End of spmd_is_master(). */

SEXP spmd_comm_disconnect(SEXP R_comm){
	return(AsInt(
		spmd_errhandler(MPI_Comm_disconnect(
			&comm[INTEGER(R_comm)[0]]))));
} /* End of spmd_comm_disconnect(). */

#endif

SEXP spmd_intercomm_merge(SEXP R_intercomm, SEXP R_high, SEXP R_comm){
	return(AsInt(
		spmd_errhandler(MPI_Intercomm_merge(
			comm[INTEGER(R_intercomm)[0]], INTEGER(R_high)[0],
			&comm[INTEGER(R_comm)[0]]))));
} /* End of spmd_intercomm_merge(). */

/* Fortran supporting functions. */
SEXP spmd_comm_c2f(SEXP R_comm){
	return(AsInt((int) MPI_Comm_c2f(comm[INTEGER(R_comm)[0]])));
} /* End of spmd_comm_c2f(). */

