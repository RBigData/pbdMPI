#include "spmd.h"

/* ----- gather ----- */
SEXP spmd_gather_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	SEXP R_buff_data;
	int *C_send_data = INTEGER(R_send_data),
	    *C_recv_data = INTEGER(R_recv_data),
	    *C_recv_data_fix = INTEGER(R_recv_data),
	    *C_buff_data,
	    *C_buff_data_fix;
	R_xlen_t C_length_send_data = XLENGTH(R_send_data),
	         C_length_send_data_fix = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_comm = INTEGER(R_comm)[0], comm_size, comm_rank, i;

	if(C_length_send_data > SPMD_SHORT_LEN_MAX){
		/* R_send_data is a long vector, so is R_recv_data. */

		/* Since C_recv_data is not contiguious, use extra buffer to
		   store chunk data for MPI calls. */
		MPI_Comm_size(comm[C_comm], &comm_size);
		MPI_Comm_rank(comm[C_comm], &comm_rank);
		if(comm_rank == C_rank_dest){
			PROTECT(R_buff_data = allocVector(INTSXP,
				(R_xlen_t) comm_size *
				(R_xlen_t) SPMD_SHORT_LEN_MAX));
		} else{
			PROTECT(R_buff_data = allocVector(INTSXP, 1));
		}
		C_buff_data = INTEGER(R_buff_data);
		C_buff_data_fix = INTEGER(R_buff_data);

		/* Loop through all. */
		while(C_length_send_data > SPMD_SHORT_LEN_MAX){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				SPMD_SHORT_LEN_MAX,
				MPI_INT, C_buff_data, SPMD_SHORT_LEN_MAX,
				MPI_INT, C_rank_dest, comm[C_comm]));
			C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						SPMD_SHORT_LEN_MAX *
						sizeof(int));
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						SPMD_SHORT_LEN_MAX;
				}
				C_recv_data_fix = C_recv_data_fix +
					SPMD_SHORT_LEN_MAX;
				C_recv_data = C_recv_data_fix;
			}
			C_buff_data = C_buff_data_fix;
			C_length_send_data = C_length_send_data -
				SPMD_SHORT_LEN_MAX;
		}

		/* Remainder. */
		if(C_length_send_data > 0){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				(int) C_length_send_data,
				MPI_INT, C_buff_data, (int) C_length_send_data,
				MPI_INT, C_rank_dest, comm[C_comm]));

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						(int) C_length_send_data *
						sizeof(int));
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						C_length_send_data;
				}
			}
		}

		UNPROTECT(1);
	} else{
		/* It doesn't matter if R_recv_data is a long vector or not,
		   since pointer address is already long int.*/
		spmd_errhandler(MPI_Gather(C_send_data,
			(int) C_length_send_data,
			MPI_INT, C_recv_data, (int) C_length_send_data,
			MPI_INT, C_rank_dest, comm[C_comm]));
	}
#else
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(INTEGER(R_send_data), C_length_send_data,
		MPI_INT, INTEGER(R_recv_data), C_length_send_data,
		MPI_INT, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_gather_integer(). */

SEXP spmd_gather_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	SEXP R_buff_data;
	double *C_send_data = REAL(R_send_data),
	       *C_recv_data = REAL(R_recv_data),
	       *C_recv_data_fix = REAL(R_recv_data),
	       *C_buff_data,
	       *C_buff_data_fix;
	R_xlen_t C_length_send_data = XLENGTH(R_send_data),
	         C_length_send_data_fix = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_comm = INTEGER(R_comm)[0], comm_size, comm_rank, i;

	if(C_length_send_data > SPMD_SHORT_LEN_MAX){
		/* R_send_data is a long vector, so is R_recv_data. */

		/* Since C_recv_data is not contiguious, use extra buffer to
		   store chunk data for MPI calls. */
		MPI_Comm_size(comm[C_comm], &comm_size);
		MPI_Comm_rank(comm[C_comm], &comm_rank);
		if(comm_rank == C_rank_dest){
			PROTECT(R_buff_data = allocVector(REALSXP,
				(R_xlen_t) comm_size *
				(R_xlen_t) SPMD_SHORT_LEN_MAX));
		} else{
			PROTECT(R_buff_data = allocVector(REALSXP, 1));
		}
		C_buff_data = REAL(R_buff_data);
		C_buff_data_fix = REAL(R_buff_data);

		/* Loop through all. */
		while(C_length_send_data > SPMD_SHORT_LEN_MAX){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				SPMD_SHORT_LEN_MAX,
				MPI_DOUBLE, C_buff_data, SPMD_SHORT_LEN_MAX,
				MPI_DOUBLE, C_rank_dest, comm[C_comm]));
			C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						SPMD_SHORT_LEN_MAX *
						sizeof(double));
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						SPMD_SHORT_LEN_MAX;
				}
				C_recv_data_fix = C_recv_data_fix +
					SPMD_SHORT_LEN_MAX;
				C_recv_data = C_recv_data_fix;
			}
			C_buff_data = C_buff_data_fix;
			C_length_send_data = C_length_send_data -
				SPMD_SHORT_LEN_MAX;
		}

		/* Remainder. */
		if(C_length_send_data > 0){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				(int) C_length_send_data,
				MPI_DOUBLE, C_buff_data,
				(int) C_length_send_data,
				MPI_DOUBLE, C_rank_dest, comm[C_comm]));

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						(int) C_length_send_data *
						sizeof(double));
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						C_length_send_data;
				}
			}
		}

		UNPROTECT(1);
	} else{
		/* It doesn't matter if R_recv_data is a long vector or not,
		   since pointer address is already long int.*/
		spmd_errhandler(MPI_Gather(C_send_data,
			(int) C_length_send_data,
			MPI_DOUBLE, C_recv_data, (int) C_length_send_data,
			MPI_DOUBLE, C_rank_dest, comm[C_comm]));
	}
#else
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(REAL(R_send_data), C_length_send_data,
		MPI_DOUBLE, REAL(R_recv_data), C_length_send_data,
		MPI_DOUBLE, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_gather_double(). */

SEXP spmd_gather_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_comm){
#ifdef LONG_VECTOR_SUPPORT
	SEXP R_buff_data;
	Rbyte *C_send_data = RAW(R_send_data),
	      *C_recv_data = RAW(R_recv_data),
	      *C_recv_data_fix = RAW(R_recv_data),
	      *C_buff_data,
	      *C_buff_data_fix;
	R_xlen_t C_length_send_data = XLENGTH(R_send_data),
	         C_length_send_data_fix = XLENGTH(R_send_data);
	int C_rank_dest = INTEGER(R_rank_dest)[0],
	    C_comm = INTEGER(R_comm)[0], comm_size, comm_rank, i;

	if(C_length_send_data > SPMD_SHORT_LEN_MAX){
		/* R_send_data is a long vector, so is R_recv_data. */

		/* Since C_recv_data is not contiguious, use extra buffer to
		   store chunk data for MPI calls. */
		MPI_Comm_size(comm[C_comm], &comm_size);
		MPI_Comm_rank(comm[C_comm], &comm_rank);
		if(comm_rank == C_rank_dest){
			PROTECT(R_buff_data = allocVector(RAWSXP,
				(R_xlen_t) comm_size *
				(R_xlen_t) SPMD_SHORT_LEN_MAX));
		} else{
			PROTECT(R_buff_data = allocVector(RAWSXP, 1));
		}
		C_buff_data = RAW(R_buff_data);
		C_buff_data_fix = RAW(R_buff_data);

		/* Loop through all. */
		while(C_length_send_data > SPMD_SHORT_LEN_MAX){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				SPMD_SHORT_LEN_MAX,
				MPI_BYTE, C_buff_data, SPMD_SHORT_LEN_MAX,
				MPI_BYTE, C_rank_dest, comm[C_comm]));
			C_send_data = C_send_data + SPMD_SHORT_LEN_MAX;

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						SPMD_SHORT_LEN_MAX);
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						SPMD_SHORT_LEN_MAX;
				}
				C_recv_data_fix = C_recv_data_fix +
					SPMD_SHORT_LEN_MAX;
				C_recv_data = C_recv_data_fix;
			}
			C_buff_data = C_buff_data_fix;
			C_length_send_data = C_length_send_data -
				SPMD_SHORT_LEN_MAX;
		}

		/* Remainder. */
		if(C_length_send_data > 0){
			/* Send C_send_data out to C_buff_data. */
			spmd_errhandler(MPI_Gather(C_send_data,
				(int) C_length_send_data,
				MPI_BYTE, C_buff_data,
				(int) C_length_send_data,
				MPI_BYTE, C_rank_dest, comm[C_comm]));

			/* Memory copy from C_buff_data to C_recv_data. */
			if(comm_rank == C_rank_dest){
				C_recv_data = C_recv_data_fix;
				for(i = 0; i < comm_size; i++){
					memcpy(C_recv_data, C_buff_data,
						(int) C_length_send_data);
					C_recv_data = C_recv_data +
						C_length_send_data_fix;
					C_buff_data = C_buff_data +
						C_length_send_data;
				}
			}
		}

		UNPROTECT(1);
	} else{
		/* It doesn't matter if R_recv_data is a long vector or not,
		   since pointer address is already long int.*/
		spmd_errhandler(MPI_Gather(C_send_data,
			(int) C_length_send_data,
			MPI_BYTE, C_recv_data, (int) C_length_send_data,
			MPI_BYTE, C_rank_dest, comm[C_comm]));
	}
#else
	int C_length_send_data = LENGTH(R_send_data);
	spmd_errhandler(MPI_Gather(RAW(R_send_data), C_length_send_data,
		MPI_BYTE, RAW(R_recv_data), C_length_send_data,
		MPI_BYTE, INTEGER(R_rank_dest)[0], comm[INTEGER(R_comm)[0]]));
#endif
	return(R_recv_data);
} /* End of spmd_gather_raw(). */

