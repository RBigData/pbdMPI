#include "spmd.h"

/* ----- send ----- */
SEXP spmd_send_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	int *C_send_data = INTEGER(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_INT, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, (int) C_length_send_data,
			MPI_INT, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Send(INTEGER(R_send_data), LENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_send_integer(). */

SEXP spmd_send_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	double *C_send_data = REAL(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_DOUBLE, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, (int) C_length_send_data,
			MPI_DOUBLE, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Send(REAL(R_send_data), LENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_send_double(). */

SEXP spmd_send_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	Rbyte *C_send_data = RAW(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_BYTE, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Send(C_send_data, (int) C_length_send_data,
			MPI_BYTE, C_rank_dest, C_tag, global_spmd_comm[C_comm]));
	}
#else
	spmd_errhandler(MPI_Send(RAW(R_send_data), LENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_send_raw(). */


/* ----- isend ----- */
SEXP spmd_isend_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
#ifdef LONG_VECTOR_SUPPORT
	int *C_send_data = INTEGER(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_INT, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, (int) C_length_send_data,
			MPI_INT, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
	}
#else
	spmd_errhandler(MPI_Isend(INTEGER(R_send_data), LENGTH(R_send_data),
		MPI_INT, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]], &global_spmd_request[INTEGER(R_request)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_isend_integer(). */

SEXP spmd_isend_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
#ifdef LONG_VECTOR_SUPPORT
	double *C_send_data = REAL(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_DOUBLE, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, (int) C_length_send_data,
			MPI_DOUBLE, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
	}
#else
	spmd_errhandler(MPI_Isend(REAL(R_send_data), LENGTH(R_send_data),
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]], &global_spmd_request[INTEGER(R_request)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_isend_double(). */

SEXP spmd_isend_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
#ifdef LONG_VECTOR_SUPPORT
	Rbyte *C_send_data = RAW(R_send_data);
	R_xlen_t C_length_send_data = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_tag = INTEGER(R_tag)[0],
	    C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_send_data > SPMD_SHORT_LEN_MAX){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, SPMD_SHORT_LEN_MAX,
			MPI_BYTE, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
		C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;
		C_length_send_data = C_length_send_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_send_data > 0){
		#if (MPI_LONG_DEBUG & 1) == 1
			Rprintf("C_length_send_data: %ld\n",
				C_length_send_data);
		#endif

		spmd_errhandler(MPI_Isend(C_send_data, (int) C_length_send_data,
			MPI_BYTE, C_rank_dest, C_tag, global_spmd_comm[C_comm],
			&global_spmd_request[C_request]));
	}
#else
	spmd_errhandler(MPI_Isend(RAW(R_send_data), LENGTH(R_send_data),
		MPI_BYTE, INTEGER(R_rank_dest)[0], INTEGER(R_tag)[0],
		global_spmd_comm[INTEGER(R_comm)[0]], &global_spmd_request[INTEGER(R_request)[0]]));
#endif
	return(R_NilValue);
} /* End of spmd_isend_raw(). */

