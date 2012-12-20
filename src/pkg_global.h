/* WCC: point structure to array pointers.
 *
 * Wei-Chen Chen, May 2012.
 */

#ifndef __SPMD_GLOBAL__
#define __SPMD_GLOBAL__

#include <R.h>
#include <Rinternals.h>
#include <mpi.h>
#include "pkg_constant.h"

/* Declared in "Rmpi.c", "spmd.c", or similar main c functions. */
extern MPI_Comm *comm;
extern MPI_Status *status;
extern MPI_Datatype *datatype;
extern MPI_Info *info;
extern MPI_Request *request;
extern int COMM_MAXSIZE;
extern int STATUS_MAXSIZE;
extern int REQUEST_MAXSIZE;

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
rmpi_array_pointers MPI_APTS, *MPI_APTS_ptr;

/* In "pkg_tools.c". */
SEXP arrange_MPI_APTS();
void set_MPI_APTS_in_R();
void get_MPI_APTS_from_R();

/* In "pkg_dl.c". */
extern void *DL_APT_ptr;
SEXP pkg_initialize(SEXP R_i_lib);
SEXP pkg_dlopen();
SEXP pkg_dlclose();

/* Obtain character pointers. */
#define CHARPT(x,i)	((char*)CHAR(STRING_ELT(x,i)))

#endif

