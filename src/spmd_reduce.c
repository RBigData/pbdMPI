#include "spmd.h"

/* ----- reduce ----- */
SEXP spmd_reduce_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	int *C_send_data = INTEGER(R_send_data),
	    *C_recv_data = INTEGER(R_recv_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_op = INTEGER(R_op)[0],
	    C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_comm = INTEGER(R_comm)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Reduce(C_send_data, C_recv_data,
			SPMD_SHORT_LEN_MAX, MPI_INT, SPMD_OP[C_op],
			C_rank_dest, comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		spmd_errhandler(MPI_Reduce(C_send_data, C_recv_data,
			(int) C_length_send_data, MPI_INT, SPMD_OP[C_op],
			C_rank_dest, comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Reduce(INTEGER(R_send_data), INTEGER(R_recv_data),
		LENGTH(R_send_data), MPI_INT, SPMD_OP[INTEGER(R_op)[0]],
		INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_reduce_integer(). */

SEXP spmd_reduce_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	double *C_send_data = REAL(R_send_data),
	       *C_recv_data = REAL(R_recv_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_op = INTEGER(R_op)[0],
	    C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_comm = INTEGER(R_comm)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Reduce(C_send_data, C_recv_data,
			SPMD_SHORT_LEN_MAX, MPI_DOUBLE, SPMD_OP[C_op],
			C_rank_dest, comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		spmd_errhandler(MPI_Reduce(C_send_data, C_recv_data,
			(int) C_length_send_data, MPI_DOUBLE, SPMD_OP[C_op],
			C_rank_dest, comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Reduce(REAL(R_send_data), REAL(R_recv_data),
		LENGTH(R_send_data), MPI_DOUBLE, SPMD_OP[INTEGER(R_op)[0]],
		INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_reduce_double(). */

