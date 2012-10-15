#include "spmd.h"

/* ----- reduce ----- */
SEXP spmd_reduce_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm){
	spmd_errhandler(MPI_Reduce(INTEGER(R_send_data), INTEGER(R_recv_data),
		LENGTH(R_send_data), MPI_INT, SPMD_OP[INTEGER(R_op)[0]],
		INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_reduce_integer(). */

SEXP spmd_reduce_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm){
	spmd_errhandler(MPI_Reduce(REAL(R_send_data), REAL(R_recv_data),
		LENGTH(R_send_data), MPI_DOUBLE, SPMD_OP[INTEGER(R_op)[0]],
		INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_reduce_double(). */

