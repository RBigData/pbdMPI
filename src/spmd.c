#include "spmd.h"

MPI_Comm *comm = NULL;
MPI_Status *status = NULL;
MPI_Datatype *datatype = NULL;
MPI_Info *info = NULL;
MPI_Request *request = NULL;
int COMM_MAXSIZE = __COMM_MAXSIZE__;
int STATUS_MAXSIZE = __STATUS_MAXSIZE__;
int REQUEST_MAXSIZE = __REQUEST_MAXSIZE__;

SEXP spmd_initialize(){
	int i, flag;
	MPI_Initialized(&flag);

#ifndef MPI2
	static int fake_argc = 1;
	char *fake_argv[1];
	char *fake_argv0 = "R";
#endif

	if(!flag){
#ifndef WIN
		pkg_dlopen();
#endif

#ifndef MPI2
		fake_argv[0] = (char *) &fake_argv0;
		MPI_Init(&fake_argc, (char ***) (void*) &fake_argv);
#else
		MPI_Init((void *) 0, (void *) 0);
#endif
	}

	MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
	MPI_Comm_set_errhandler(MPI_COMM_SELF, MPI_ERRORS_RETURN);
	if(comm == NULL){
		comm = (MPI_Comm *) Calloc(COMM_MAXSIZE, MPI_Comm); 
		comm[0] = MPI_COMM_WORLD;
		for(i = 1; i < COMM_MAXSIZE; i++){
			comm[i] = MPI_COMM_NULL;
		}
	}
	if(status == NULL){
		status = (MPI_Status *) Calloc(STATUS_MAXSIZE, MPI_Status); 
	}
	if(datatype == NULL){
		datatype = (MPI_Datatype *) Calloc(1, MPI_Datatype); 
	}
	if(info == NULL){
		info = (MPI_Info *) Calloc(1, MPI_Info);
		info[0] = MPI_INFO_NULL;
	}
	if(request == NULL){
		request = (MPI_Request *) Calloc(REQUEST_MAXSIZE, MPI_Request);
		for(i = 0; i < REQUEST_MAXSIZE; i++){
			request[i] = MPI_REQUEST_NULL;	
		}
	}

	arrange_MPI_APTS();
	return(AsInt(1));
} /* End of spmd_initialize(). */

SEXP spmd_finalize(SEXP R_mpi_finalize){
	int flag, C_mpi_finalize;

	MPI_Finalized(&flag);
	C_mpi_finalize = INTEGER(R_mpi_finalize)[0];

	if(C_mpi_finalize == 1){
		if(! flag){
			if(WHO_LOAD_FIRST == PBDMPI){
				Free(comm);
				Free(status);
				Free(request);
				Free(datatype);
				Free(info);
			}
#ifndef WIN
			pkg_dlclose();
#endif
			MPI_Finalize();
		}
	}

	return(AsInt(1));
} /* End of spmd_finalize(). */

SEXP spmd_is_finalized(){
	int flag;

	MPI_Finalized(&flag);

	return(AsInt(flag));
} /* End of spmd_is_finalized(). */

SEXP spmd_get_processor_name(){
	int result_length;
	char *processor_name;
	SEXP R_processor_name;

	PROTECT(R_processor_name  = allocVector(STRSXP, 1));
	processor_name = (char *) Calloc(MPI_MAX_PROCESSOR_NAME, char);
	MPI_Get_processor_name(processor_name, &result_length);
	SET_STRING_ELT(R_processor_name, 0, mkChar(processor_name));
	UNPROTECT(1);
	Free(processor_name);

	return(R_processor_name);
} /* End of spmd_get_processor_name(). */


#ifdef MPI2
SEXP spmd_universe_size(){
	int *MPI_Universe_Size;
	int univ_flag;

	MPI_Comm_get_attr(comm[0], MPI_UNIVERSE_SIZE, &MPI_Universe_Size,
				&univ_flag);
	if(univ_flag){
		return(AsInt(*MPI_Universe_Size));
	} else{
		return(AsInt(0));
	}
} /* End of spmd_universe_size(). */
#endif

