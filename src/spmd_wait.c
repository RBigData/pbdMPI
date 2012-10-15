#include "spmd.h"

/* ----- WAIT ----- */

SEXP spmd_wait(SEXP R_request, SEXP R_status){
	spmd_errhandler(
		MPI_Wait(&request[INTEGER(R_request)[0]],
			&status[INTEGER(R_status)[0]]));
	return(R_NilValue);
} /* End of spmd_wait(). */

SEXP spmd_waitany(SEXP R_count, SEXP R_status){
	int index;
	spmd_errhandler(
		MPI_Waitany(INTEGER(R_count)[0], request, &index,
			&status[INTEGER(R_status)[0]]));
	return(AsInt(index));
} /* End of spmd_waitany(). */

SEXP spmd_waitsome(SEXP R_count){
	int countn = INTEGER(R_count)[0];
	SEXP R_indices;
	PROTECT(R_indices = allocVector(INTSXP, countn + 1));
	spmd_errhandler(
		MPI_Waitsome(countn, request, &INTEGER(R_indices)[0],
			&INTEGER(R_indices)[1], status));
	UNPROTECT(1);
	return(R_indices);
} /* End of spmd_waitsome(). */

SEXP spmd_waitall(SEXP R_count){
	spmd_errhandler(MPI_Waitall(INTEGER(R_count)[0], request, status));
	return(R_NilValue);
} /* End of spmd_waitall(). */

