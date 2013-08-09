#include "spmd.h"

/* ----- allreduce ----- */
SEXP spmd_allreduce_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_comm){
	spmd_errhandler(MPI_Allreduce(INTEGER(R_send_data),
		INTEGER(R_recv_data), XLENGTH(R_send_data), MPI_INT,
		SPMD_OP[INTEGER(R_op)[0]], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allreduce_integer(). */

SEXP spmd_allreduce_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_comm){
	spmd_errhandler(MPI_Allreduce(REAL(R_send_data), REAL(R_recv_data),
		XLENGTH(R_send_data), MPI_DOUBLE, SPMD_OP[INTEGER(R_op)[0]],
		comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allreduce_double(). */
