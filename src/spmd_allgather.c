#include "spmd.h"

/* ----- allgather ----- */
SEXP spmd_allgather_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_comm){
	int send_length = XLENGTH(R_send_data);
	spmd_errhandler(MPI_Allgather(INTEGER(R_send_data), send_length,
		MPI_INT, INTEGER(R_recv_data), send_length,
		MPI_INT, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgather_integer(). */

SEXP spmd_allgather_double(SEXP R_send_data, SEXP R_recv_data, SEXP R_comm){
	int send_length = XLENGTH(R_send_data);
	spmd_errhandler(MPI_Allgather(REAL(R_send_data), send_length,
		MPI_DOUBLE, REAL(R_recv_data), send_length,
		MPI_DOUBLE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgather_double(). */

SEXP spmd_allgather_raw(SEXP R_send_data, SEXP R_recv_data, SEXP R_comm){
	int send_length = XLENGTH(R_send_data);
	spmd_errhandler(MPI_Allgather(RAW(R_send_data), send_length,
		MPI_BYTE, RAW(R_recv_data), send_length,
		MPI_BYTE, comm[INTEGER(R_comm)[0]]));
	return(R_recv_data);
} /* End of spmd_allgather_raw(). */

