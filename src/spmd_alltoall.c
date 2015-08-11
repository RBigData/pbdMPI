#include "spmd.h"

/* ----- alltoall ----- */
SEXP spmd_alltoall_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_comm){
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Alltoall(INTEGER(R_send_data), C_length_send_data,
		MPI_INT, INTEGER(R_recv_data), C_length_send_data,
		MPI_INT, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_integer(). */

SEXP spmd_alltoall_double(SEXP R_send_data, SEXP R_recv_data, SEXP R_comm){
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Alltoall(REAL(R_send_data), C_length_send_data,
		MPI_DOUBLE, REAL(R_recv_data), C_length_send_data,
		MPI_DOUBLE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_double(). */

SEXP spmd_alltoall_raw(SEXP R_send_data, SEXP R_recv_data, SEXP R_comm){
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Alltoall(RAW(R_send_data), C_length_send_data,
		MPI_BYTE, RAW(R_recv_data), C_length_send_data,
		MPI_BYTE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_alltoall_raw(). */

