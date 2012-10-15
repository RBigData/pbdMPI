#include "spmd.h"

/* ----- recv ----- */
SEXP spmd_recv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Recv(INTEGER(R_recv_data), LENGTH(R_recv_data),
		MPI_INT, INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_recv_integer(). */

SEXP spmd_recv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Recv(REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_recv_double(). */

SEXP spmd_recv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status){
	spmd_errhandler(MPI_Recv(RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &status[INTEGER(R_status)[0]]));
	return(R_recv_data);
} /* End of spmd_recv_raw(). */


/* ----- irecv ----- */
SEXP spmd_irecv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Irecv(INTEGER(R_recv_data),
		LENGTH(R_recv_data), MPI_INT,
		INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_recv_data);
} /* End of spmd_irecv_integer(). */

SEXP spmd_irecv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Irecv(REAL(R_recv_data), LENGTH(R_recv_data),
		MPI_DOUBLE, INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_recv_data);
} /* End of spmd_irecv_double(). */

SEXP spmd_irecv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request){
	spmd_errhandler(MPI_Irecv(RAW(R_recv_data), LENGTH(R_recv_data),
		MPI_BYTE, INTEGER(R_rank_source)[0], INTEGER(R_tag)[0],
		comm[INTEGER(R_comm)[0]], &request[INTEGER(R_request)[0]]));
	return(R_recv_data);
} /* End of spmd_irecv_raw(). */

