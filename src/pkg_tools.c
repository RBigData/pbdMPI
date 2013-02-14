/* WCC: These functions are to export and access pointers in R.
 *      Only arrange_MPI_APTS() is able to be called after MPI_Init().
 *      Other functions are not supposed to be called.
 *
 * Wei-Chen Chen, May 2012.
 */

#include "pkg_global.h"

SEXP arrange_MPI_APTS(){
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

void set_MPI_APTS_in_R(){
	/* Define R objects. */
	SEXP R_apts;

	/* Protect R objects. */
	PROTECT(R_apts = R_MakeExternalPtr(&MPI_APTS, R_NilValue, R_NilValue));

	/* Assign an R object in ".GlobalEnv". */
	defineVar(install(MPI_APTS_R_NAME), R_apts, R_GlobalEnv);

	/* These are only saw by "Rmpi" not "pbdMPI". */
	MPI_APTS.comm = comm;
	MPI_APTS.status = status;
	MPI_APTS.datatype = datatype;
	MPI_APTS.info = info;
	MPI_APTS.request = request;

	MPI_APTS.COMM_MAXSIZE = &COMM_MAXSIZE;
	MPI_APTS.STATUS_MAXSIZE = &STATUS_MAXSIZE;
	MPI_APTS.REQUEST_MAXSIZE = &REQUEST_MAXSIZE;

	#if (MPI_APTS_DEBUG & 1) == 1
	int myrank;
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__, comm,
			status, datatype, info, request);
		REprintf("  %s (v): %d %d %d.\n", __FILE__, COMM_MAXSIZE,
			STATUS_MAXSIZE, REQUEST_MAXSIZE);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__, &comm,
			&status, &datatype, &info, &request);
		REprintf("  %s (a): %x %x %x.\n", __FILE__, &COMM_MAXSIZE,
			&STATUS_MAXSIZE, &REQUEST_MAXSIZE);
	}
	#endif

	/* Unprotect R objects. */
	UNPROTECT(1);
} /* End of set_MPI_APTS_in_R(). */

void get_MPI_APTS_from_R(){
        /* Define an R object. */
        SEXP R_apts;

        /* Get an R object from ".GlobalEnv". */
        R_apts = findVar(install(MPI_APTS_R_NAME), R_GlobalEnv);
        if(R_apts == R_NilValue){
                error(".__MPI_APTS__ is not found in .GlobalEnv");
        }

        /* Get pointers. */
        MPI_APTS_ptr = R_ExternalPtrAddr(R_apts);

        /* These are only saw by "pbdMPI" not "Rmpi". */
        comm = (MPI_Comm*) MPI_APTS_ptr->comm;
        status = (MPI_Status *) MPI_APTS_ptr->status;
        datatype = (MPI_Datatype *) MPI_APTS_ptr->datatype;
        info = (MPI_Info *) MPI_APTS_ptr->info;
        request = (MPI_Request *) MPI_APTS_ptr->request;

        COMM_MAXSIZE = *MPI_APTS_ptr->COMM_MAXSIZE;
        STATUS_MAXSIZE = *MPI_APTS_ptr->STATUS_MAXSIZE;
        REQUEST_MAXSIZE = *MPI_APTS_ptr->REQUEST_MAXSIZE;

	#if (MPI_APTS_DEBUG & 1) == 1
	int myrank;
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__, comm,
			status, datatype, info, request);
		REprintf("  %s (v): %d %d %d.\n", __FILE__, COMM_MAXSIZE,
			STATUS_MAXSIZE, REQUEST_MAXSIZE);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__, &comm,
			&status, &datatype, &info, &request);
		REprintf("  %s (a): %x %x %x.\n", __FILE__, &COMM_MAXSIZE,
			&STATUS_MAXSIZE, &REQUEST_MAXSIZE);
	}
	#endif
} /* End of get_MPI_APTS_from_R(). */

