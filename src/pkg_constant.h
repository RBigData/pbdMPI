/* WCC: define pkg constants.
 *
 * Wei-Chen Chen, May 2012.
 */

#ifndef __PKG_CONSTANT__
#define __PKG_CONSTANT__

#ifdef __GNUC__
#define VARIABLE_IS_NOT_USED __attribute__ ((unused))
#else
#define VARIABLE_IS_NOT_USED
#endif


/* For loading. */
#define N_LOAD_LOCATION		5
enum {UNSET, RMPI, PBDMPI, VISIT, PNCDF4};
static char VARIABLE_IS_NOT_USED *LOAD_LOCATION[N_LOAD_LOCATION] =
	{"UNSET", "Rmpi", "pbdMPI", "VisIt", "pncdf4"};

#define __LOAD_LOCATION__	PBDMPI
extern int WHO_LOAD_FIRST;
// Whom need to take care free memory.

#define MPI_APTS_R_NAME		".__MPI_APTS__"
#define MPI_LIB_R_NAME		".__MPI_LIB__"


/* For debugging. */
#define MPI_LONG_DEBUG		0
#define MPI_APTS_DEBUG		0


/* For "Rmpi.c", "pbdMPI.c", or similar main c functions. */
#define __COMM_MAXSIZE__	10
#define __STATUS_MAXSIZE__	5000
#define __REQUEST_MAXSIZE__	10000

#endif
