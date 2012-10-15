#include "spmd.h"

/* ----- scatterv ----- */
SEXP spmd_scatterv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm){
	spmd_errhandler(MPI_Scatterv(INTEGER(R_send_data),
		INTEGER(R_send_counts), INTEGER(R_displs),
		MPI_INT, INTEGER(R_recv_data), LENGTH(R_recv_data),
		MPI_INT, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatterv_integer(). */

SEXP spmd_scatterv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm){
	spmd_errhandler(MPI_Scatterv(REAL(R_send_data),
		INTEGER(R_send_counts), INTEGER(R_displs),
		MPI_DOUBLE, REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatterv_double(). */

SEXP spmd_scatterv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm){
	spmd_errhandler(MPI_Scatterv(RAW(R_send_data),
		INTEGER(R_send_counts), INTEGER(R_displs),
		MPI_BYTE, RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, INTEGER(R_rank_source)[0], comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_scatterv_raw(). */

