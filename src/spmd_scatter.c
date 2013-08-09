#include "spmd.h"

/* ----- scatter ----- */
SEXP spmd_scatter_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm){
	int recv_length = XLENGTH(R_recv_data);
	spmd_errhandler(MPI_Scatter(INTEGER(R_send_data), recv_length,
		MPI_INT, INTEGER(R_recv_data), recv_length,
		MPI_INT, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatter_integer(). */

SEXP spmd_scatter_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm){
	int recv_length = XLENGTH(R_recv_data);
	spmd_errhandler(MPI_Scatter(REAL(R_send_data), recv_length,
		MPI_DOUBLE, REAL(R_recv_data), recv_length,
		MPI_DOUBLE, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatter_double(). */

SEXP spmd_scatter_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm){
	int recv_length = XLENGTH(R_recv_data);
	spmd_errhandler(MPI_Scatter(RAW(R_send_data), recv_length,
		MPI_BYTE, RAW(R_recv_data), recv_length,
		MPI_BYTE, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatter_raw(). */

