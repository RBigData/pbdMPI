#include "spmd.h"

/* ----- INFO ----- */

SEXP spmd_info_create(SEXP R_info){
	return(AsInt(
		spmd_errhandler(MPI_Info_create(&global_spmd_info[INTEGER(R_info)[0]]))));
} /* End of spmd_info_create(). */

SEXP spmd_info_set(SEXP R_info, SEXP R_key, SEXP R_value){
	return(AsInt(
		spmd_errhandler(MPI_Info_set(global_spmd_info[INTEGER(R_info)[0]],
		(char *) STRING_ELT(R_key,0),
		(char *) STRING_ELT(R_value,0)))));
} /* End of spmd_info_set(). */

SEXP spmd_info_free(SEXP R_info){
	return(AsInt(
		spmd_errhandler(MPI_Info_free(&global_spmd_info[INTEGER(R_info)[0]]))));
} /* End of spmd_info_free(). */


/* Fortran supporting functions. */
SEXP spmd_info_c2f(SEXP R_info){
	return(AsInt((int) MPI_Info_c2f(global_spmd_info[INTEGER(R_info)[0]])));
} /* End of spmd_info_c2f(). */

