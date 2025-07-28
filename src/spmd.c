#include "spmd.h"

MPI_Comm *global_spmd_comm = NULL;
MPI_Comm global_spmd_localcomm = MPI_COMM_NULL;
MPI_Status *global_spmd_status = NULL;
MPI_Datatype *global_spmd_datatype = NULL;
MPI_Info *global_spmd_info = NULL;
MPI_Request *global_spmd_request = NULL;
int global_spmd_COMM_MAXSIZE = __COMM_MAXSIZE__;
int global_spmd_STATUS_MAXSIZE = __STATUS_MAXSIZE__;
int global_spmd_REQUEST_MAXSIZE = __REQUEST_MAXSIZE__;

SEXP spmd_initialize(void){
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
	if(global_spmd_comm == NULL){
		global_spmd_comm = (MPI_Comm *) R_Calloc(global_spmd_COMM_MAXSIZE, MPI_Comm); 
		global_spmd_comm[0] = MPI_COMM_WORLD;
		for(i = 1; i < global_spmd_COMM_MAXSIZE; i++){
			global_spmd_comm[i] = MPI_COMM_NULL;
		}
	}
#if MPI_VERSION >= 3
	if(global_spmd_localcomm == MPI_COMM_NULL){
		MPI_Comm_split_type(global_spmd_comm[0], MPI_COMM_TYPE_SHARED,0, MPI_INFO_NULL, &global_spmd_localcomm);
	}
#endif
	if(global_spmd_status == NULL){
		global_spmd_status = (MPI_Status *) R_Calloc(global_spmd_STATUS_MAXSIZE, MPI_Status); 
	}
	if(global_spmd_datatype == NULL){
		global_spmd_datatype = (MPI_Datatype *) R_Calloc(1, MPI_Datatype); 
	}
	if(global_spmd_info == NULL){
		global_spmd_info = (MPI_Info *) R_Calloc(1, MPI_Info);
		global_spmd_info[0] = MPI_INFO_NULL;
	}
	if(global_spmd_request == NULL){
		global_spmd_request = (MPI_Request *) R_Calloc(global_spmd_REQUEST_MAXSIZE, MPI_Request);
		for(i = 0; i < global_spmd_REQUEST_MAXSIZE; i++){
			global_spmd_request[i] = MPI_REQUEST_NULL;	
		}
	}

	arrange_MPI_APTS();
	return(AsInt(1));
} /* End of spmd_initialize(). */

SEXP spmd_finalize(SEXP R_mpi_finalize){
	int flag, C_mpi_finalize;

	MPI_Finalized(&flag);
	C_mpi_finalize = INTEGER(R_mpi_finalize)[0];
	REprintf("spmd_finalize: C_mpi_finalize: %d, flag: %d.\n", C_mpi_finalize, flag);
	REprintf("spmd_finalize: WHO_LOAD_FIRST: %d PBDMPI: %d.\n",
		WHO_LOAD_FIRST, PBDMPI);

	if(C_mpi_finalize == 1){
		if(! flag){
			if(WHO_LOAD_FIRST == PBDMPI){

#if (MPI_APTS_DEBUG & 1) == 1
	int myrank;
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  before free\n");
		REprintf("  ==> ptr: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm,
			global_spmd_status, global_spmd_datatype,
			global_spmd_info, global_spmd_request);
		REprintf("  %s (v0): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm[0],
			global_spmd_status[0], global_spmd_datatype[0],
			global_spmd_info[0], global_spmd_request[0]);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm,
			&global_spmd_status, &global_spmd_datatype,
			&global_spmd_info, &global_spmd_request);
		REprintf("  %s (a0): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm[0],
			&global_spmd_status[0], &global_spmd_datatype[0],
			&global_spmd_info[0], &global_spmd_request[0]);
	}
#endif
				REprintf("spmd_finalize: before free.\n");

// In spmd_finalize(), add this before the R_Free() calls:
#if MPI_VERSION >= 3
			if(global_spmd_localcomm != MPI_COMM_NULL){
    			MPI_Comm_free(&global_spmd_localcomm);
    			global_spmd_localcomm = MPI_COMM_NULL;
				REprintf("spmd_initialize: global_spmd_localcomm freed by MPI v3+\n");

			}
#endif

			if(global_spmd_comm != NULL){
                R_Free(global_spmd_comm);
                global_spmd_comm = NULL;
            }
            if(global_spmd_status != NULL){
                R_Free(global_spmd_status);
                global_spmd_status = NULL;
            }
            if(global_spmd_datatype != NULL){
                R_Free(global_spmd_datatype);
                global_spmd_datatype = NULL;
            }
            if(global_spmd_info != NULL){
                R_Free(global_spmd_info);
                global_spmd_info = NULL;
            }
            if(global_spmd_request != NULL){
                R_Free(global_spmd_request);
                global_spmd_request = NULL;
            }

#if (MPI_APTS_DEBUG & 1) == 1
	if(myrank == 0){
		REprintf("rank: %d, load: %s, func: %s.\n", myrank,
			LOAD_LOCATION[__LOAD_LOCATION__], __FUNCTION__);
		REprintf("  after free\n");
		REprintf("  ==> ptr: comm status datatype info request.\n");
		REprintf("  %s (v): %x %x %x %x %x.\n", __FILE__,
			global_spmd_comm,
			global_spmd_status, global_spmd_datatype,
			global_spmd_info, global_spmd_request);
		REprintf("  %s (a): %x %x %x %x %x.\n", __FILE__,
			&global_spmd_comm,
			&global_spmd_status, &global_spmd_datatype,
			&global_spmd_info, &global_spmd_request);
	}
#endif

			}
#ifndef WIN
			pkg_dlclose();
#endif
			MPI_Finalize();
		}
	}

	return(AsInt(1));
} /* End of spmd_finalize(). */

SEXP spmd_is_finalized(void){
	int flag;

	MPI_Finalized(&flag);

	return(AsInt(flag));
} /* End of spmd_is_finalized(). */

SEXP spmd_get_processor_name(void){
	int result_length;
	char *processor_name;
	SEXP R_processor_name;

	PROTECT(R_processor_name  = allocVector(STRSXP, 1));
	processor_name = (char *) R_Calloc(MPI_MAX_PROCESSOR_NAME, char);
	MPI_Get_processor_name(processor_name, &result_length);
	SET_STRING_ELT(R_processor_name, 0, mkChar(processor_name));
	UNPROTECT(1);
	R_Free(processor_name);

	return(R_processor_name);
} /* End of spmd_get_processor_name(). */


#ifdef MPI2
SEXP spmd_universe_size(void){
	int *MPI_Universe_Size;
	int univ_flag;

	MPI_Comm_get_attr(global_spmd_comm[0], MPI_UNIVERSE_SIZE, &MPI_Universe_Size,
				&univ_flag);
	if(univ_flag){
		return(AsInt(*MPI_Universe_Size));
	} else{
		return(AsInt(0));
	}
} /* End of spmd_universe_size(). */
#endif
