#include "spmd.h"

/* ----- alltoall ----- */
SEXP spmd_alltoall_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_count, SEXP R_recv_count, SEXP R_comm){
	spmd_errhandler(MPI_Alltoall(INTEGER(R_send_data),
		INTEGER(R_send_count)[0],
		MPI_INT, INTEGER(R_recv_data), INTEGER(R_recv_count)[0],
		MPI_INT, global_spmd_comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_integer(). */

SEXP spmd_alltoall_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_count, SEXP R_recv_count, SEXP R_comm){
	spmd_errhandler(MPI_Alltoall(REAL(R_send_data),
		INTEGER(R_send_count)[0],
		MPI_DOUBLE, REAL(R_recv_data), INTEGER(R_recv_count)[0],
		MPI_DOUBLE, global_spmd_comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_double(). */

SEXP spmd_alltoall_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_count, SEXP R_recv_count, SEXP R_comm){
	spmd_errhandler(MPI_Alltoall(RAW(R_send_data),
		INTEGER(R_send_count)[0],
		MPI_BYTE, RAW(R_recv_data), INTEGER(R_recv_count)[0],
		MPI_BYTE, global_spmd_comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_raw(). */

