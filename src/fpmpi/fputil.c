/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *
 *  (C) 2001-2005 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */

#include "fpmpiconf.h"
#include "profiler.h"
#include "fpmpi.h"
#include "mpi.h"

#include <stdlib.h>

/*
 * This file contains utility routines used by the fpmpi library.
 * 
 */

/* 
   The following collective routines compute the 
   min/max/rank of min/rank of max 
   of an array of values, returning the values in supplied arrays.

   These are three essentially identical routines, except for the choice of 
   input datatype (int, long, or double) and the related structures and
   MPI datatypes. 
*/

/* Determine the min/max/sum of single integer values across procs */
void fpmpi_getrange_int_single(int val, int *maxout, int *maxloc, 
			       int *minout, int *minloc, int *sumout)
{
  typedef struct { int val; int loc; } twoint;
  twoint *lvals, *gvals;
  int rank;

  lvals = (twoint *) malloc( 2 * sizeof(twoint) );
  gvals = lvals + 1;
  
  PMPI_Comm_rank( MPI_COMM_WORLD, &rank );

  lvals->val = val;
  lvals->loc = rank;

  PMPI_Reduce( lvals, gvals, 1, MPI_2INT, MPI_MAXLOC, 
	       0, MPI_COMM_WORLD );
  *maxout = gvals->val;
  *maxloc = gvals->loc;

  PMPI_Reduce( lvals, gvals, 1, MPI_2INT, MPI_MINLOC, 
	       0, MPI_COMM_WORLD );
  *minout = gvals->val;
  *minloc = gvals->loc;

  PMPI_Reduce( &val, sumout, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD );
  free( lvals );
}

void fpmpi_getrange_double_single(double val, double *maxout, int *maxloc, 
				  double *minout, int *minloc, double *sumout)
{
  typedef struct { double val; int loc; } doubleint;
  doubleint lvals, gvals;
  int rank;

  PMPI_Comm_rank( MPI_COMM_WORLD, &rank );

  lvals.val = val;
  lvals.loc = rank;

  PMPI_Reduce( &lvals, &gvals, 1, MPI_DOUBLE_INT, MPI_MAXLOC, 
	       0, MPI_COMM_WORLD );
  *maxout = gvals.val;
  *maxloc = gvals.loc;

  PMPI_Reduce( &lvals, &gvals, 1, MPI_DOUBLE_INT, MPI_MINLOC, 
	       0, MPI_COMM_WORLD );
  *minout = gvals.val;
  *minloc = gvals.loc;

  PMPI_Reduce( &val, sumout, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD );
}

#if SIZEOF_LONG_LONG >= 8
void fpmpi_getrange_msgsize_single(msgsize_t val, msgsize_t *maxout, 
				   int *maxloc, msgsize_t *minout, 
				   int *minloc, msgsize_t *sumout)
{
  typedef struct { double val; int loc; } doubleint;
  doubleint lvals, gvals;
  int rank;
  static MPI_Datatype longlongintDtype = MPI_DATATYPE_NULL;

  if (longlongintDtype == MPI_DATATYPE_NULL) {
      /* eventually, create a longlongint type and a corresponding
	 max/min/int operation.
       */
      ;
  }

  PMPI_Comm_rank( MPI_COMM_WORLD, &rank );

  lvals.val = val;
  lvals.loc = rank;

  PMPI_Reduce( &lvals, &gvals, 1, MPI_DOUBLE_INT, MPI_MAXLOC, 
	       0, MPI_COMM_WORLD );
  *maxout = gvals.val;
  *maxloc = gvals.loc;

  PMPI_Reduce( &lvals, &gvals, 1, MPI_DOUBLE_INT, MPI_MINLOC, 
	       0, MPI_COMM_WORLD );
  *minout = gvals.val;
  *minloc = gvals.loc;

  PMPI_Reduce( &val, sumout, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD );
}
#endif
