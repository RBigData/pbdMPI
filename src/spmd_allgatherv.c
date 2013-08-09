#include "spmd.h"

/* ----- allgatherv ----- */
SEXP spmd_allgatherv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm){
	spmd_errhandler(
		MPI_Allgatherv(INTEGER(R_send_data), XLENGTH(R_send_data),
		MPI_INT, INTEGER(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_displs), MPI_INT, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgatherv_integer(). */

SEXP spmd_allgatherv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm){
	spmd_errhandler(
		MPI_Allgatherv(REAL(R_send_data), XLENGTH(R_send_data),
		MPI_DOUBLE, REAL(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_displs), MPI_DOUBLE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgatherv_double(). */

SEXP spmd_allgatherv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm){
	spmd_errhandler(MPI_Allgatherv(RAW(R_send_data), XLENGTH(R_send_data),
		MPI_BYTE, RAW(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_displs), MPI_BYTE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgatherv_raw(). */

