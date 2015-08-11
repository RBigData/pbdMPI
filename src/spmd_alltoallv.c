#include "spmd.h"

/* ----- alltoallv ----- */
SEXP spmd_alltoallv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_recv_counts,
		SEXP R_sdispls, SEXP R_rdispls, SEXP R_comm){
	spmd_errhandler(
		MPI_Alltoallv(INTEGER(R_send_data), INTEGER(R_send_counts),
		INTEGER(R_sdispls), MPI_INT,
		INTEGER(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_rdispls), MPI_INT, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoallv_integer(). */

SEXP spmd_alltoallv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_recv_counts,
		SEXP R_sdispls, SEXP R_rdispls,
		SEXP R_comm){
	spmd_errhandler(
		MPI_Alltoallv(REAL(R_send_data), INTEGER(R_send_counts),
		INTEGER(R_sdispls), MPI_DOUBLE,
		REAL(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_rdispls), MPI_DOUBLE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoallv_double(). */

SEXP spmd_alltoallv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_recv_counts,
		SEXP R_sdispls, SEXP R_rdispls,
		SEXP R_comm){
	spmd_errhandler(MPI_Alltoallv(RAW(R_send_data), INTEGER(R_send_counts),
		INTEGER(R_rdispls), MPI_BYTE,
		RAW(R_recv_data), INTEGER(R_recv_counts),
		INTEGER(R_rdispls), MPI_BYTE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoallv_raw(). */

