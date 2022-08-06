#include "spmd.h"

/* ----- probe ----- */
SEXP spmd_probe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status){
	return(AsInt(
		spmd_errhandler(MPI_Probe(INTEGER(R_source)[0],
				INTEGER(R_tag)[0], global_spmd_comm[INTEGER(R_comm)[0]],
				&global_spmd_status[INTEGER(R_status)[0]]))));
} /* End of spmd_probe(). */

SEXP spmd_iprobe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status){
	int flag;
	spmd_errhandler(MPI_Iprobe(INTEGER(R_source)[0], INTEGER(R_tag)[0],
			global_spmd_comm[INTEGER(R_comm)[0]], &flag,
			&global_spmd_status[INTEGER(R_status)[0]]));
	return(AsInt(flag));
} /* End of spmd_iprobe(). */


/* ----- source & tag ----- */
SEXP spmd_anysource(){
	return(AsInt(MPI_ANY_SOURCE));
} /* End of spmd_anysource(). */

SEXP spmd_anytag(){
	return(AsInt(MPI_ANY_TAG));
} /* End of spmd_anytag(). */

SEXP spmd_get_sourcetag(SEXP R_status){
	int status_number = INTEGER(R_status)[0];
	SEXP R_sourcetag;

	PROTECT(R_sourcetag = allocVector(INTSXP, 2));
	INTEGER(R_sourcetag)[0] = global_spmd_status[status_number].MPI_SOURCE;
	INTEGER(R_sourcetag)[1] = global_spmd_status[status_number].MPI_TAG;
	UNPROTECT(1);

	return(R_sourcetag);
} /* End of spmd_get_sourcetag(). */


/* ----- get count ----- */
SEXP spmd_get_count(SEXP R_data_type, SEXP R_status){
	SEXP R_count;

	PROTECT(R_count = allocVector(INTSXP, 1));
	spmd_errhandler(MPI_Get_count(&global_spmd_status[INTEGER(R_status)[0]],
			SPMD_DT[INTEGER(R_data_type)[0] - 1],
			INTEGER(R_count)));
	UNPROTECT(1);

	return(R_count);
} /* End of spmd_get_count(). */


/* ----- check MPI_COMM_NULL ----- */
SEXP spmd_is_comm_null(SEXP R_comm){
	int C_comm = INTEGER(R_comm)[0];
	SEXP R_check;

	PROTECT(R_check = allocVector(LGLSXP, 1));

	if(global_spmd_comm[C_comm] == MPI_COMM_NULL){
		LOGICAL(R_check)[0] = TRUE;
	} else{
		LOGICAL(R_check)[0] = FALSE;
	}

	UNPROTECT(1);
	return(R_check);
} /* End of spmd_is_mpi_comm_null(). */
