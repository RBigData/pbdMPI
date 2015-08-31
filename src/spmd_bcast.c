#include "spmd.h"

/* ----- bcast ----- */
SEXP spmd_bcast_integer(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	int *C_send_data = INTEGER(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_source = INTEGER(R_rank_source)[0],
	    C_comm = INTEGER(R_comm)[0];
	#if (MPI_LONG_DEBUG & 1) == 1
		int C_comm_rank;
		MPI_Comm_rank(comm[C_comm], &C_comm_rank);
	#endif

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_INT, C_rank_source, comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, (int) C_length_send_data,
			MPI_INT, C_rank_source, comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Bcast(INTEGER(R_send_data), LENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
#endif
	return(R_send_data);
} /* End of spmd_bcast_integer(). */

SEXP spmd_bcast_double(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	double *C_send_data = REAL(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_source = INTEGER(R_rank_source)[0],
	    C_comm = INTEGER(R_comm)[0];
	#if (MPI_LONG_DEBUG & 1) == 1
		int C_comm_rank;
		MPI_Comm_rank(comm[C_comm], &C_comm_rank);
	#endif

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_DOUBLE, C_rank_source, comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, (int) C_length_send_data,
			MPI_DOUBLE, C_rank_source, comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Bcast(REAL(R_send_data), LENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
#endif
	return(R_send_data);
} /* End of spmd_bcast_double(). */

SEXP spmd_bcast_raw(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	Rbyte *C_send_data = RAW(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_source = INTEGER(R_rank_source)[0],
	    C_comm = INTEGER(R_comm)[0];
	#if (MPI_LONG_DEBUG & 1) == 1
		int C_comm_rank;
		MPI_Comm_rank(comm[C_comm], &C_comm_rank);
	#endif

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_BYTE, C_rank_source, comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			if(C_comm_rank == 0){
				Rprintf("C_length_send_data: %ld\n",
					C_length_send_data);
			}
		#endif

		spmd_errhandler(MPI_Bcast(C_send_data, (int) C_length_send_data,
			MPI_BYTE, C_rank_source, comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Bcast(RAW(R_send_data), LENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
#endif
	return(R_send_data);
} /* End of spmd_bcast_raw(). */

SEXP spmd_bcast_string(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm){
	char *C_send_data = CHARPT(R_send_data, 0);
	spmd_errhandler(MPI_Bcast(C_send_data, strlen(C_send_data),
		MPI_CHAR, INTEGER(R_rank_source)[0],
		comm[INTEGER(R_comm)[0]]));
	return(R_send_data);
} /* End of spmd_bcast_string(). */

