/* WCC: These functions are to export and access pointers in R.
 *      Only arrange_MPI_APTS() is able to be called after MPI_Init().
 *      Other functions are not supposed to be called.
 *
 * Wei-Chen Chen, May 2012.
 */

#include "pkg_global.h"
#include <stdint.h>

rmpi_array_pointers MPI_APTS, *MPI_APTS_ptr = NULL;
int WHO_LOAD_FIRST;

SEXP arrange_MPI_APTS(void){
        SEXP R_apts;

	PROTECT(R_apts = findVar(install(MPI_APTS_R_NAME), R_GlobalEnv));
        if(R_apts == R_UnboundValue){
		WHO_LOAD_FIRST = __LOAD_LOCATION__;
		set_MPI_APTS_in_R();
        } else{
		get_MPI_APTS_from_R();
	}
	UNPROTECT(1);

	return(R_NilValue);
} /* End of arrange_MPI_APTS(). */

void set_MPI_APTS_in_R(void){
	/* Define R objects. */
	SEXP R_apts;

	/* Protect R objects. */
	PROTECT(R_apts = R_MakeExternalPtr(&MPI_APTS, R_NilValue, R_NilValue));

	/* Assign an R object in ".GlobalEnv". */
	defineVar(install(MPI_APTS_R_NAME), R_apts, R_GlobalEnv);

#if (MPI_APTS_DEBUG & 1) == 1
	int myrank;
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  ==> original in C.\n");
		REprintf("  ==> ptr: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm,
			global_spmd_status, global_spmd_datatype,
			global_spmd_info, global_spmd_request);
		REprintf("  %s (v0): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm[0],
			global_spmd_status[0], global_spmd_datatype[0],
			global_spmd_info[0], global_spmd_request[0]);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm,
			&global_spmd_status, &global_spmd_datatype,
			&global_spmd_info, &global_spmd_request);
		REprintf("  %s (a0): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm[0],
			&global_spmd_status[0], &global_spmd_datatype[0],
			&global_spmd_info[0], &global_spmd_request[0]);
		REprintf("     ==> maxsize: comm status request.\n");
		REprintf("     %s (v): %d %d %d.\n", __FILE__,
			global_spmd_COMM_MAXSIZE, global_spmd_STATUS_MAXSIZE,
			global_spmd_REQUEST_MAXSIZE);
		REprintf("     %s (a): %x %x %x.\n", __FILE__,
			&global_spmd_COMM_MAXSIZE, &global_spmd_STATUS_MAXSIZE,
			&global_spmd_REQUEST_MAXSIZE);
	}
#endif

	/* These are only saw by "Rmpi" not "pbdMPI". */
	MPI_APTS.comm = global_spmd_comm;
	MPI_APTS.status = global_spmd_status;
	MPI_APTS.datatype = global_spmd_datatype;
	MPI_APTS.info = global_spmd_info;
	MPI_APTS.request = global_spmd_request;

	MPI_APTS.COMM_MAXSIZE = &global_spmd_COMM_MAXSIZE;
	MPI_APTS.STATUS_MAXSIZE = &global_spmd_STATUS_MAXSIZE;
	MPI_APTS.REQUEST_MAXSIZE = &global_spmd_REQUEST_MAXSIZE;

#if (MPI_APTS_DEBUG & 1) == 1
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  ==> assign to R.\n");
		REprintf("  ==> struct: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__,
			MPI_APTS.comm,
			MPI_APTS.status,
			MPI_APTS.datatype,
			MPI_APTS.info,
			MPI_APTS.request);
		REprintf("  %s (v0): %x %x %x %x %x.\n", __FILE__,
			MPI_APTS.comm[0],
			MPI_APTS.status[0],
			MPI_APTS.datatype[0],
			MPI_APTS.info[0],
			MPI_APTS.request[0]);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&(MPI_APTS.comm),
			&(MPI_APTS.status),
			&(MPI_APTS.datatype),
			&(MPI_APTS.info),
			&(MPI_APTS.request));
		REprintf("  %s (a0): %x %x %x %x %x.\n", __FILE__,
			&(MPI_APTS.comm[0]),
			&(MPI_APTS.status[0]),
			&(MPI_APTS.datatype[0]),
			&(MPI_APTS.info[0]),
			&(MPI_APTS.request[0]));
		REprintf("     ==> maxsize: comm status request.\n");
		REprintf("     %s (v): %d %d %d.\n", __FILE__,
			*(MPI_APTS.COMM_MAXSIZE),
			*(MPI_APTS.STATUS_MAXSIZE),
			*(MPI_APTS.REQUEST_MAXSIZE));
		REprintf("     %s (a): %x %x %x.\n", __FILE__,
			&(MPI_APTS.COMM_MAXSIZE),
			&(MPI_APTS.STATUS_MAXSIZE),
			&(MPI_APTS.REQUEST_MAXSIZE));
	}
#endif

	/* Unprotect R objects. */
	UNPROTECT(1);
} /* End of set_MPI_APTS_in_R(). */

void get_MPI_APTS_from_R(void){
        /* Define an R object. */
        SEXP R_apts;

        /* Get an R object from ".GlobalEnv". */
        R_apts = findVar(install(MPI_APTS_R_NAME), R_GlobalEnv);
        if(R_apts == R_NilValue){
                error(".__MPI_APTS__ is not found in .GlobalEnv");
        }

        /* Get pointers. */
        MPI_APTS_ptr = R_ExternalPtrAddr(R_apts);

#if (MPI_APTS_DEBUG & 1) == 1
	int myrank;
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  ==> get from R.\n");
		REprintf("  ==> mpi_apts: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n",__FILE__,
			MPI_APTS_ptr->comm,
			MPI_APTS_ptr->status,
			MPI_APTS_ptr->datatype,
			MPI_APTS_ptr->info,
			MPI_APTS_ptr->request);
		REprintf("  %s (v0): %x %x %x %x %x.\n", __FILE__,
			MPI_APTS_ptr->comm[0],
			MPI_APTS_ptr->status[0],
			MPI_APTS_ptr->datatype[0],
			MPI_APTS_ptr->info[0],
			MPI_APTS_ptr->request[0]);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&(MPI_APTS_ptr->comm),
			&(MPI_APTS_ptr->status),
			&(MPI_APTS_ptr->datatype),
			&(MPI_APTS_ptr->info),
			&(MPI_APTS_ptr->request));
		REprintf("  %s (a0): %x %x %x %x %x.\n", __FILE__,
			&(MPI_APTS_ptr->comm[0]),
			&(MPI_APTS_ptr->status[0]),
			&(MPI_APTS_ptr->datatype[0]),
			&(MPI_APTS_ptr->info[0]),
			&(MPI_APTS_ptr->request[0]));
		REprintf("     ==> maxsize: comm status request.\n");
		REprintf("     %s (v): %d %d %d.\n", __FILE__,
			*MPI_APTS_ptr->COMM_MAXSIZE,
			*MPI_APTS_ptr->STATUS_MAXSIZE,
			*MPI_APTS_ptr->REQUEST_MAXSIZE);
		REprintf("     %s (a): %x %x %x.\n", __FILE__,
			MPI_APTS_ptr->COMM_MAXSIZE,
			MPI_APTS_ptr->STATUS_MAXSIZE,
			MPI_APTS_ptr->REQUEST_MAXSIZE);
	}
#endif

        /* These are only saw by "pbdMPI" not "Rmpi". */
        global_spmd_comm = (MPI_Comm*) MPI_APTS_ptr->comm;
        global_spmd_status = (MPI_Status *) MPI_APTS_ptr->status;
        global_spmd_datatype = (MPI_Datatype *) MPI_APTS_ptr->datatype;
        global_spmd_info = (MPI_Info *) MPI_APTS_ptr->info;
        global_spmd_request = (MPI_Request *) MPI_APTS_ptr->request;

        global_spmd_COMM_MAXSIZE = *MPI_APTS_ptr->COMM_MAXSIZE;
        global_spmd_STATUS_MAXSIZE = *MPI_APTS_ptr->STATUS_MAXSIZE;
        global_spmd_REQUEST_MAXSIZE = *MPI_APTS_ptr->REQUEST_MAXSIZE;

#if (MPI_APTS_DEBUG & 1) == 1
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  ==> assign to C.\n");
		REprintf("  ==> ptr: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm,
			global_spmd_status, global_spmd_datatype,
			global_spmd_info, global_spmd_request);
		REprintf("  %s (v0): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm[0],
			global_spmd_status[0], global_spmd_datatype[0],
			global_spmd_info[0], global_spmd_request[0]);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm,
			&global_spmd_status, &global_spmd_datatype,
			&global_spmd_info, &global_spmd_request);
		REprintf("  %s (a0): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm[0],
			&global_spmd_status[0], &global_spmd_datatype[0],
			&global_spmd_info[0], &global_spmd_request[0]);
		REprintf("     ==> maxsize: comm status request.\n");
		REprintf("     %s (v): %d %d %d.\n", __FILE__,
			global_spmd_COMM_MAXSIZE,
			global_spmd_STATUS_MAXSIZE,
			global_spmd_REQUEST_MAXSIZE);
		REprintf("     %s (a): %x %x %x.\n", __FILE__,
			&global_spmd_COMM_MAXSIZE,
			&global_spmd_STATUS_MAXSIZE,
			&global_spmd_REQUEST_MAXSIZE);
	}
#endif
} /* End of get_MPI_APTS_from_R(). */


/* Utilities. */
SEXP get_MPI_COMM_PTR(SEXP R_comm, SEXP R_show_msg){
	int C_comm;
	void *p;
        SEXP R_ptr;
	int myrank;

	C_comm = INTEGER(R_comm)[0];
	p = (void *) (&global_spmd_comm[C_comm]);
	PROTECT(R_ptr = R_MakeExternalPtr(p, R_NilValue, R_NilValue));

	if(INTEGER(R_show_msg)[0] == 1){
		MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
#if (MPI_APTS_DEBUG & 1) == 1
		Rprintf("rank: %d, comm: %x, MPI_COMM_WORLD: %x.\n",
			myrank, global_spmd_comm[C_comm], MPI_COMM_WORLD);
#else
		Rprintf("rank: %d, comm: %p, MPI_COMM_WORLD: %p.\n",
			myrank, global_spmd_comm[C_comm], MPI_COMM_WORLD);
#endif
	}

	UNPROTECT(1);
	return(R_ptr);
} /* End of get_MPI_COMM_PTR(). */

SEXP addr_MPI_COMM_PTR(SEXP R_ptr){
	int myrank, myrank_new;
	MPI_Comm *comm_foreign;

        /* Get pointers. */
        comm_foreign = (MPI_Comm*) R_ExternalPtrAddr(R_ptr);

	/* Print results. */
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	MPI_Comm_rank(*comm_foreign, &myrank_new);
#if (MPI_APTS_DEBUG & 1) == 1
	Rprintf("rank: %d, comm: %x, MPI_COMM_WORLD: %x, rank_new: %d.\n",
		myrank, *comm_foreign, MPI_COMM_WORLD, myrank_new);
#else
	Rprintf("rank: %d, comm: %p, MPI_COMM_WORLD: %p, rank_new: %d.\n",
		myrank, *comm_foreign, MPI_COMM_WORLD, myrank_new);
#endif

	return(R_NilValue);
} /* End of addr_MPI_COMM_PTR(). */

