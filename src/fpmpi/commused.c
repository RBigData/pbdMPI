/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2001-2005 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */

#include "fpmpiconf.h"
#include "profiler.h"
#include "fpmpi.h"
#include "mpi.h"

/*
 * --------------------------------------------------------------------
 * Process routines that modify communicators
 * FIXME:
 * Merge with the code to measure sync time for these collectives
 * --------------------------------------------------------------------
 */
static int    comm_dup_calls        = 0;
static int    comm_world_dups       = 0;
static int    comm_self_dups        = 0;
static int    comm_dup_world_keyval = MPI_KEYVAL_INVALID;
static int    comm_dup_self_keyval  = MPI_KEYVAL_INVALID;
static int    comm_dup_other_keyval = MPI_KEYVAL_INVALID;

static int    comm_split_calls  = 0;
static int    comm_world_splits = 0;

/*
    MPI_Comm_dup - duplicates of MPI_COMM_WORLD and MPI_COMM_SELF are counted
*/
int MPI_Comm_dup_orig( MPI_Comm oldcomm, MPI_Comm *newcomm )
{
  int returnVal;
  int *dummyattrval, flag;

  if (comm_dup_world_keyval == MPI_KEYVAL_INVALID) {
      PMPI_Keyval_create(MPI_DUP_FN,MPI_NULL_DELETE_FN,&comm_dup_world_keyval,(void *)0);
  }
  if (comm_dup_self_keyval  == MPI_KEYVAL_INVALID) {
      PMPI_Keyval_create(MPI_DUP_FN,MPI_NULL_DELETE_FN,&comm_dup_self_keyval,(void *)0);
  }
  if (comm_dup_other_keyval == MPI_KEYVAL_INVALID) {
      PMPI_Keyval_create(MPI_DUP_FN,MPI_NULL_DELETE_FN,&comm_dup_other_keyval,(void *)0);
  }

  PMPI_Attr_get(oldcomm,comm_dup_other_keyval,&dummyattrval,&flag);
  if (!flag) {
      PMPI_Attr_get(oldcomm,comm_dup_world_keyval,&dummyattrval,&flag);
      if (flag) {
          comm_world_dups += 1;
      } else {
          PMPI_Attr_get(oldcomm,comm_dup_self_keyval,&dummyattrval,&flag);
          if (flag) {
              comm_self_dups += 1;
          } else {
              PMPI_Comm_size(oldcomm,&flag);
              if (flag == 1) {
                  PMPI_Attr_put(oldcomm,comm_dup_self_keyval,(void *)&comm_dup_self_keyval);
                  comm_self_dups += 1;
              } else {
                  PMPI_Comm_compare(oldcomm,MPI_COMM_WORLD,&flag);
                  if (flag == MPI_IDENT) {
                      PMPI_Attr_put(oldcomm,comm_dup_world_keyval,(void *)&comm_dup_world_keyval);
                      comm_world_dups += 1;
                  } else {
                      PMPI_Attr_put(oldcomm,comm_dup_other_keyval,(void *)&comm_dup_other_keyval);
                  }
              }
          } 
      }
  }

  returnVal = PMPI_Comm_dup(oldcomm,newcomm);

  comm_dup_calls += 1;
  return returnVal;
}

/*
    MPI_Comm_split - splits of MPI_COMM_WORLD and MPI_COMM_SELF are counted
*/
int MPI_Comm_split_orig( MPI_Comm oldcomm, int color, int key, MPI_Comm *newcomm )
{
  int returnVal;
  int *dummyattrval, flag;

  if (comm_dup_world_keyval == MPI_KEYVAL_INVALID) {
      PMPI_Keyval_create(MPI_DUP_FN,MPI_NULL_DELETE_FN,&comm_dup_world_keyval,(void *)0);
  }
  if (comm_dup_other_keyval == MPI_KEYVAL_INVALID) {
      PMPI_Keyval_create(MPI_DUP_FN,MPI_NULL_DELETE_FN,&comm_dup_other_keyval,(void *)0);
  }

  PMPI_Attr_get(oldcomm,comm_dup_other_keyval,&dummyattrval,&flag);
  if (!flag) {
      PMPI_Attr_get(oldcomm,comm_dup_world_keyval,&dummyattrval,&flag);
      if (flag) {
          comm_world_splits += 1;
      } else {
          PMPI_Comm_compare(oldcomm,MPI_COMM_WORLD,&flag);
          if (flag == MPI_IDENT) {
              PMPI_Attr_put(oldcomm,comm_dup_world_keyval,(void *)&comm_dup_world_keyval);
              comm_world_splits += 1;
          } else {
              PMPI_Attr_put(oldcomm,comm_dup_other_keyval,(void *)&comm_dup_other_keyval);
          }
      }
  }
  returnVal = PMPI_Comm_split(oldcomm,color,key,newcomm);
  comm_split_calls += 1;
  return returnVal;
}

/* ------------------------------------------------------------------------
 * These routines are invoked during MPI_Finalize to report on the
 * data measured by routines in this file.
 * ------------------------------------------------------------------------ */

static void printout_dupsplit( FILE *pf, int llrank, int calls, 
			       const char *name)
{
    int maxcalls, mincalls, total_calls, maxloc, minloc;
    int nprocs;

    PMPI_Comm_size( MPI_COMM_WORLD, &nprocs );
    fpmpi_getrange_int_single(calls, &maxcalls, &maxloc, &mincalls, &minloc, 
			      &total_calls);
    if (llrank == 0) {
        if (total_calls > 0) {
            fprintf( pf, 
		     "%s:\n\tCalls     : %10d max %d(at %d) min %d(at %d)\n",
		     name, total_calls / nprocs, maxcalls, maxloc, mincalls, minloc );
        }
    }
}
void fpmpi_Output_DupSplit( FILE *pf, int llrank)
{
    printout_dupsplit(pf, llrank, comm_dup_calls,    "MPI_Comm_dup(all communicators)");
    printout_dupsplit(pf, llrank, comm_world_dups,   "MPI_Comm_dup(MPI_COMM_WORLD)");
    printout_dupsplit(pf, llrank, comm_self_dups,    "MPI_Comm_dup(MPI_COMM_SELF)");
    printout_dupsplit(pf, llrank, comm_split_calls,  "MPI_Comm_split(all communicators)");
    printout_dupsplit(pf, llrank, comm_world_splits, "MPI_Comm_split(MPI_COMM_WORLD)");
}

