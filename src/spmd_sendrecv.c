#include "spmd.h"

/* ----- sendrecv ----- */
SEXP spmd_sendrecv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv(INTEGER(R_send_data), LENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		INTEGER(R_recv_data), LENGTH(R_recv_data),
		MPI_INT, INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_sendrecv_integer(). */

SEXP spmd_sendrecv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv(REAL(R_send_data), LENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_sendrecv_double(). */

SEXP spmd_sendrecv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Sendrecv(RAW(R_send_data), LENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_send_tag)[0],
		RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, INTEGER(R_rank_source)[0], INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_sendrecv_raw(). */

