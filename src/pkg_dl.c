/* WCC: These functions are to export and access the shared library in R.
 *
 * Wei-Chen Chen, Aug 2012.
 */

#include "pkg_global.h"
void *DL_APT_ptr = NULL;

#ifndef WIN
#include <dlfcn.h>
#endif

SEXP pkg_dlopen(){
#ifndef WIN
#ifdef OPENMPI
        SEXP R_apts;

	PROTECT(R_apts = findVar(install(MPI_LIB_R_NAME), R_GlobalEnv));
	if(R_apts != R_UnboundValue){
		if(DL_APT_ptr == NULL){
			DL_APT_ptr = dlopen(CHARPT(R_apts, 0),
					RTLD_GLOBAL | RTLD_LAZY);
			if(DL_APT_ptr == NULL){
				error(".__MPI_LIB__ loading fails.");
			}
		}
	}
	UNPROTECT(1);
#endif
#endif
	return(R_NilValue);
} /* End of pkg_dlopen(). */

SEXP pkg_dlclose(){
#ifndef WIN
	if(DL_APT_ptr != NULL){
		dlclose(DL_APT_ptr);
	}
#endif
	return(R_NilValue);
} /* End of pkg_dlclose(). */

