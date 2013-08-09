#include "spmd.h"

/* ----- send ----- */
SEXP spmd_send_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
	spmd_errhandler(MPI_Send(INTEGER(R_send_data), XLENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_NilValue);
} /* End of spmd_send_integer(). */

SEXP spmd_send_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
	spmd_errhandler(MPI_Send(REAL(R_send_data), XLENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_NilValue);
} /* End of spmd_send_double(). */

SEXP spmd_send_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
	spmd_errhandler(MPI_Send(RAW(R_send_data), XLENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_NilValue);
} /* End of spmd_send_raw(). */


/* ----- isend ----- */
SEXP spmd_isend_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Isend(INTEGER(R_send_data), XLENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_NilValue);
} /* End of spmd_isend_integer(). */

SEXP spmd_isend_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Isend(REAL(R_send_data), XLENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_NilValue);
} /* End of spmd_isend_double(). */

SEXP spmd_isend_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Isend(RAW(R_send_data), XLENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_NilValue);
} /* End of spmd_isend_raw(). */

