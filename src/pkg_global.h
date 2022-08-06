/* WCC: point structure to array pointers.
 *
 * Wei-Chen Chen, May 2012.
 */

#ifndef __SPMD_GLOBAL__
#define __SPMD_GLOBAL__

#include <R.h>
#include <Rinternals.h>

#ifdef _WIN64
#include <stdint.h>
#endif

#include <mpi.h>
#include "pkg_constant.h"

/* Declared in "Rmpi.c", "spmd.c", or similar main c functions. */
extern MPI_Comm *global_spmd_comm;
extern MPI_Comm global_spmd_localcomm;
extern MPI_Status *global_spmd_status;
extern MPI_Datatype *global_spmd_datatype;
extern MPI_Info *global_spmd_info;
extern MPI_Request *global_spmd_request;
extern int global_spmd_COMM_MAXSIZE;
extern int global_spmd_STATUS_MAXSIZE;
extern int global_spmd_REQUEST_MAXSIZE;

/* Collections. */
typedef struct _rmpi_array_pointers	rmpi_array_pointers;
struct _rmpi_array_pointers{
	MPI_Comm *comm;
	MPI_Status *status;
	MPI_Datatype *datatype;
	MPI_Info *info;
	MPI_Request *request;
	int *COMM_MAXSIZE;
	int *STATUS_MAXSIZE;
	int *REQUEST_MAXSIZE;
};
extern rmpi_array_pointers MPI_APTS, *MPI_APTS_ptr;

/* In "pkg_tools.c". */
SEXP arrange_MPI_APTS();
void set_MPI_APTS_in_R();
void get_MPI_APTS_from_R();
SEXP get_MPI_COMM_PTR();
SEXP addr_MPI_COMM_PTR();

/* In "pkg_dl.c". */
extern void *DL_APT_ptr;
SEXP pkg_initialize(SEXP R_i_lib);
SEXP pkg_dlopen();
SEXP pkg_dlclose();

/* Obtain character pointers. */
#define CHARPT(x,i)	((char*)CHAR(STRING_ELT(x,i)))

#endif
