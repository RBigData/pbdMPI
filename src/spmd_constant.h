/* WCC: Define spmd constant stuff. */

#ifndef __SPMD_CONSTANT__
#define __SPMD_CONSTANT__

/* MPI stuff. */
#include <mpi.h>

#ifdef __GNUC__
#define VARIABLE_IS_NOT_USED __attribute__ ((unused))
#else
#define VARIABLE_IS_NOT_USED
#endif

#define N_SPMD_OP 5
static const MPI_Op SPMD_OP[N_SPMD_OP] =
	{MPI_SUM, MPI_SUM, MPI_PROD, MPI_MAX, MPI_MIN};

#define N_SPMD_DT 4
static const MPI_Datatype SPMD_DT[N_SPMD_DT] =
	{MPI_INT, MPI_DOUBLE, MPI_CHAR, MPI_BYTE};

#endif

