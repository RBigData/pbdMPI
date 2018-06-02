#include "spmd.h"

/* ----- Internal ----- */
SEXP AsInt(int x){
    SEXP R_x;

    PROTECT(R_x = allocVector(INTSXP, 1));
    INTEGER(R_x)[0] = x;
    UNPROTECT(1);

    return(R_x);
} /* End of AsInt(). */

int spmd_errhandler(int error_code){
	int error_message_length;
	char error_message[MPI_MAX_ERROR_STRING];

	if(error_code != MPI_SUCCESS){
		MPI_Error_string(error_code, error_message,
			&error_message_length);
		error(error_message);
	}
	
	return(error_code);
} /* End of spmd_errhandler(). */

int spmd_comm_slot(void) {
    int newcommn;
    for (newcommn = 1; newcommn < COMM_MAXSIZE && comm[newcommn] != MPI_COMM_NULL; newcommn++);
    if (newcommn == COMM_MAXSIZE)
        error("Out of communicators. Increase COMM_MAXSIZE.");
    else
        return newcommn;
}
