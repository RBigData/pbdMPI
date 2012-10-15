#include "spmd.h"

/* ----- sendrecv_replace ----- */
SEXP spmd_sendrecv_replace_integer(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv_replace(INTEGER(R_data), LENGTH(R_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_integer(). */

SEXP spmd_sendrecv_replace_double(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv_replace(REAL(R_data), LENGTH(R_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_double(). */

SEXP spmd_sendrecv_replace_raw(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv_replace(RAW(R_data), LENGTH(R_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_raw(). */

