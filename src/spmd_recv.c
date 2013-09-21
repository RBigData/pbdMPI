#include "spmd.h"

/* ----- recv ----- */
SEXP spmd_recv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	int *C_recv_data = INTEGER(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_status = INTEGER(R_status)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Recv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_INT, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Recv(C_recv_data, (int) C_length_recv_data,
			MPI_INT, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
	}
#else
	spmd_errhandler(MPI_Recv(INTEGER(R_recv_data), LENGTH(R_recv_data),
		MPI_INT, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_recv_integer(). */

SEXP spmd_recv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	double *C_recv_data = REAL(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_status = INTEGER(R_status)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Recv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_DOUBLE, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Recv(C_recv_data, (int) C_length_recv_data,
			MPI_DOUBLE, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
	}
#else
	spmd_errhandler(MPI_Recv(REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_recv_double(). */

SEXP spmd_recv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	Rbyte *C_recv_data = RAW(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_status = INTEGER(R_status)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Recv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_BYTE, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Recv(C_recv_data, (int) C_length_recv_data,
			MPI_BYTE, C_rank_source, C_tag, comm[C_comm],
			&status[C_status]));
	}
#else
	spmd_errhandler(MPI_Recv(RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_recv_raw(). */


/* ----- irecv ----- */
SEXP spmd_irecv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	int *C_recv_data = INTEGER(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Irecv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_INT, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Irecv(C_recv_data, (int) C_length_recv_data,
			MPI_INT, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
	}
#else
	spmd_errhandler(MPI_Irecv(INTEGER(R_recv_data), LENGTH(R_recv_data),
		MPI_INT, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_irecv_integer(). */

SEXP spmd_irecv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	double *C_recv_data = REAL(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Irecv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_DOUBLE, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Irecv(C_recv_data, (int) C_length_recv_data,
			MPI_DOUBLE, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
	}
#else
	spmd_errhandler(MPI_Irecv(REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_irecv_double(). */

SEXP spmd_irecv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	int C_rank_source, C_tag;

	C_rank_source = (LENGTH(R_rank_source) == 0) ?
			MPI_ANY_SOURCE : INTEGER(R_rank_source)[0];
	C_tag = (LENGTH(R_tag) == 0) ? MPI_ANY_TAG : INTEGER(R_tag)[0];

#ifdef LONG_VECTOR_SUPPORT
	Rbyte *C_recv_data = RAW(R_recv_data);
	R_xlen_t C_length_recv_data = XLENGTH(R_recv_data);
	int C_comm = INTEGER(R_comm)[0],
	    C_request = INTEGER(R_request)[0];

	/* Loop through all. */
	while(C_length_recv_data > SPMD_SHORT_LEN_MAX){
		spmd_errhandler(MPI_Irecv(C_recv_data, SPMD_SHORT_LEN_MAX,
			MPI_BYTE, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
		C_recv_data = C_recv_data + SPMD_SHORT_LEN_MAX;
		C_length_recv_data = C_length_recv_data - SPMD_SHORT_LEN_MAX;
	}

	/* Remainder. */
	if(C_length_recv_data > 0){
		spmd_errhandler(MPI_Irecv(C_recv_data, (int) C_length_recv_data,
			MPI_BYTE, C_rank_source, C_tag, comm[C_comm],
			&request[C_request]));
	}
#else
	spmd_errhandler(MPI_Irecv(RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, C_rank_source, C_tag,
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_irecv_raw(). */

