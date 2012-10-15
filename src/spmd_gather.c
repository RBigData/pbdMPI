#include "spmd.h"

/* ----- gather ----- */
SEXP spmd_gather_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
	int send_length = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(INTEGER(R_send_data), send_length,
		MPI_INT, INTEGER(R_recv_data), send_length,
		MPI_INT, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_gather_integer(). */

SEXP spmd_gather_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
	int send_length = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(REAL(R_send_data), send_length,
		MPI_DOUBLE, REAL(R_recv_data), send_length,
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_gather_double(). */

SEXP spmd_gather_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
	int send_length = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(RAW(R_send_data), send_length,
		MPI_BYTE, RAW(R_recv_data), send_length,
		MPI_BYTE, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_gather_raw(). */

