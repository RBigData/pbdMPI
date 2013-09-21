#include "spmd.h"

/* ----- sendrecv_replace ----- */
SEXP spmd_sendrecv_replace_integer(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source = MPI_PROC_NULL, C_rank_dest = MPI_PROC_NULL;
#ifdef LONG_VECTOR_SUPPORT
	if(XLENGTH(R_data) > SPMD_SHORT_LEN_MAX){
		error("long vectors not supported yet: %s:%d\n",
			__FILE__, __LINE__);
	}
#endif
	if(LENGTH(R_rank_source) > 0){
		C_rank_source = INTEGER(R_rank_source)[0];
	}
	if(LENGTH(R_rank_dest) > 0){
		C_rank_dest = INTEGER(R_rank_dest)[0];
	}
	spmd_errhandler(MPI_Sendrecv_replace(INTEGER(R_data), LENGTH(R_data),
		MPI_INT, C_rank_dest, INTEGER(R_send_tag)[0],
		C_rank_source, INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_integer(). */

SEXP spmd_sendrecv_replace_double(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source = MPI_PROC_NULL, C_rank_dest = MPI_PROC_NULL;
#ifdef LONG_VECTOR_SUPPORT
	if(XLENGTH(R_data) > SPMD_SHORT_LEN_MAX){
		error("long vectors not supported yet: %s:%d\n",
			__FILE__, __LINE__);
	}
#endif
	if(LENGTH(R_rank_source) > 0){
		C_rank_source = INTEGER(R_rank_source)[0];
	}
	if(LENGTH(R_rank_dest) > 0){
		C_rank_dest = INTEGER(R_rank_dest)[0];
	}
	spmd_errhandler(MPI_Sendrecv_replace(REAL(R_data), LENGTH(R_data),
		MPI_DOUBLE, C_rank_dest, INTEGER(R_send_tag)[0],
		C_rank_source, INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_double(). */

SEXP spmd_sendrecv_replace_raw(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status){
	int C_rank_source = MPI_PROC_NULL, C_rank_dest = MPI_PROC_NULL;
#ifdef LONG_VECTOR_SUPPORT
	if(XLENGTH(R_data) > SPMD_SHORT_LEN_MAX){
		error("long vectors not supported yet: %s:%d\n",
			__FILE__, __LINE__);
	}
#endif
	if(LENGTH(R_rank_source) > 0){
		C_rank_source = INTEGER(R_rank_source)[0];
	}
	if(LENGTH(R_rank_dest) > 0){
		C_rank_dest = INTEGER(R_rank_dest)[0];
	}
	spmd_errhandler(MPI_Sendrecv_replace(RAW(R_data), LENGTH(R_data),
		MPI_BYTE, C_rank_dest, INTEGER(R_send_tag)[0],
		C_rank_source, INTEGER(R_recv_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_data);
} /* End of spmd_sendrecv_replace_raw(). */

