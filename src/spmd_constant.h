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

#define N_SPMD_OP 11 
static const MPI_Op SPMD_OP[N_SPMD_OP] =
	{MPI_SUM, MPI_SUM, MPI_PROD, MPI_MAX, MPI_MIN,
	 MPI_LAND, MPI_BAND, MPI_LOR, MPI_BOR, MPI_LXOR, MPI_BXOR};

#define N_SPMD_DT 5
static const MPI_Datatype SPMD_DT[N_SPMD_DT] =
	{MPI_INT, MPI_DOUBLE, MPI_BYTE, MPI_BYTE, MPI_CHAR};
        /* The first MPI_BYTE is for raw and the second MPI_BYTE is
           for R objects. */

#endif

