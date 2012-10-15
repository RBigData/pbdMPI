#include "spmd.h"

/* ----- bcast ----- */
SEXP spmd_bcast_integer(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
	spmd_errhandler(MPI_Bcast(INTEGER(R_send_data), LENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_send_data);
} /* End of spmd_bcast_integer(). */

SEXP spmd_bcast_double(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
	spmd_errhandler(MPI_Bcast(REAL(R_send_data), LENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_send_data);
} /* End of spmd_bcast_double(). */

SEXP spmd_bcast_raw(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
	spmd_errhandler(MPI_Bcast(RAW(R_send_data), LENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_send_data);
} /* End of spmd_bcast_raw(). */

