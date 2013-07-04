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
 * Process the wait and test calls
 * --------------------------------------------------------------------
 */

/* Local variables for wait and test */
static NoCommData wait_data, waitall_data, waitany_data, waitsome_data;
static NoCommData test_data, testall_data, testany_data, testsome_data;
/*
    MPI_Wait - prototyping replacement for MPI_Wait
    Log the beginning and ending of the time spent in MPI_Wait calls.
*/
int MPI_Wait( MPI_Request *request, MPI_Status *status )
{
  int returnVal = 0 ;
  double endttime = 0;
  double startwtime, endwtime;

  if (fpmpi_ProfControlWait) {
      int flag;
      startwtime = endttime = MPI_Wtime();
      do {
	  returnVal = PMPI_Test( request, &flag, status );
	  if (!flag) endttime = MPI_Wtime();
      } while (!flag && !returnVal);
      endwtime = MPI_Wtime();
      wait_data.synctime += endttime - startwtime;
  }
  else {
      startwtime = MPI_Wtime();	  
      returnVal = PMPI_Wait( request, status );
      endwtime = MPI_Wtime();
  }
  wait_data.time  += endwtime - startwtime;
  wait_data.calls += 1;

  return returnVal;
}

/*
    MPI_Waitall - prototyping replacement for MPI_Waitall
    Log the beginning and ending of the time spent in MPI_Waitall calls.
*/
int MPI_Waitall( int count, MPI_Request *array_of_requests, 
		 MPI_Status *array_of_statuses )
{
  int returnVal = 0;
  double endttime = 0;
  double startwtime, endwtime;
  
  if (fpmpi_ProfControlWait) {
      int idx, flag, testReturnVal;
      MPI_Status status;
      startwtime = endttime = MPI_Wtime();
      /* Wait for anyone to arrive, then wait on the rest */
      do {
	  testReturnVal = PMPI_Testany( count, array_of_requests, 
				    &idx, &flag, &status );
	  if (!flag) endttime = MPI_Wtime();
      } while (!flag && !testReturnVal);
      if (testReturnVal) {
	  /* Waitall is allowed to return if there is an error */
	  if (array_of_statuses != MPI_STATUSES_IGNORE) {
	      int i;
	      for (i=0; i<count; i++) {
		  array_of_statuses[i].MPI_ERROR = MPI_ERR_PENDING;
	      }
	      if (idx >= 0 && idx < count) {
		  status.MPI_ERROR = testReturnVal;
		  array_of_statuses[idx] = status;
	      }
	  }
      }
      else if (count > 1) {
	  returnVal = PMPI_Waitall( count, 
				    array_of_requests, array_of_statuses );
	  /* Replace the element that is now null */
	  if (idx >= 0 && idx < count && 
	      array_of_statuses != MPI_STATUSES_IGNORE) {
	      if (returnVal) 
		  status.MPI_ERROR = MPI_SUCCESS;
	      array_of_statuses[idx] = status;
	  }
      }
      endwtime = MPI_Wtime();
      waitall_data.synctime += endttime - startwtime;
  }
  else {
      startwtime = MPI_Wtime();	  
      returnVal = PMPI_Waitall( count, array_of_requests, array_of_statuses );
      endwtime = MPI_Wtime();
  }
  waitall_data.time  += endwtime - startwtime;
  waitall_data.calls += 1;

  return returnVal;
}

/*
    MPI_Waitany - prototyping replacement for MPI_Waitany
    Log the beginning and ending of the time spent in MPI_Waitany calls.
*/
int MPI_Waitany( int count, MPI_Request *array_of_requests, 
		 int *index, MPI_Status *status )
{
  int returnVal = 0;
  double endttime = 0;
  double startwtime, endwtime;

  if (fpmpi_ProfControlWait) {
      int flag;
      startwtime = endttime = MPI_Wtime();
      /* Wait for anyone to arrive, then wait on the rest */
      do {
	  returnVal = PMPI_Testany( count, array_of_requests, index, &flag, 
				    status );
	  if (!flag) endttime = MPI_Wtime();
      } while (!flag && !returnVal);
      endwtime = MPI_Wtime();
      waitany_data.synctime += endttime - startwtime;
  }
  else {
      startwtime = MPI_Wtime();	  
      returnVal = PMPI_Waitany( count, array_of_requests, index, status );
      endwtime = MPI_Wtime();
  }
  waitany_data.time  += endwtime - startwtime;
  waitany_data.calls += 1;

  return returnVal;
}

/*
    MPI_Waitsome - prototyping replacement for MPI_Waitsome
    Log the beginning and ending of the time spent in MPI_Waitsome calls.
*/
int MPI_Waitsome( int incount, MPI_Request *array_of_requests, 
		  int *outcount, int *array_of_indices, 
		  MPI_Status *array_of_statuses )
{
  int returnVal = 0;
  double endttime = 0;
  double startwtime, endwtime;

  if (fpmpi_ProfControlWait) {
      startwtime = endttime = MPI_Wtime();
      /* Wait for anyone to arrive, then wait on the rest */
      do {
	  returnVal = PMPI_Testsome( incount, array_of_requests, outcount, 
				     array_of_indices, array_of_statuses );
	  if (*outcount > 0) endttime = MPI_Wtime();
      } while (*outcount == 0 && !returnVal);
      endwtime = MPI_Wtime();
      waitsome_data.synctime += endttime - startwtime;
  }
  else {
      startwtime = MPI_Wtime();	  
      returnVal = PMPI_Waitsome( incount, array_of_requests, outcount, 
			     array_of_indices, array_of_statuses );
      endwtime = MPI_Wtime();
  }
  waitsome_data.time  += endwtime - startwtime;
  waitsome_data.calls += 1;

  return returnVal;
}

int MPI_Test( MPI_Request *request, int *flag, MPI_Status *status )
{
  int   returnVal;
  double startwtime, endwtime;

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Test( request, flag, status );
  endwtime = MPI_Wtime();
  test_data.time  += endwtime - startwtime;
  test_data.calls += 1;

  return returnVal;
}

int MPI_Testall( int count, MPI_Request *array_of_requests, int *flag, 
		  MPI_Status *array_of_statuses )
{
  int  returnVal;
  double startwtime, endwtime;

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Testall( count, array_of_requests, flag, array_of_statuses );
  endwtime = MPI_Wtime();
  testall_data.time  += endwtime - startwtime;
  testall_data.calls += 1;

  return returnVal;
}

int MPI_Testany( int count, MPI_Request *array_of_requests, int *index, 
		  int *flag, MPI_Status *status )
{
  int  returnVal;
  double startwtime, endwtime;

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Testany( count, array_of_requests, index, flag, status );
  endwtime = MPI_Wtime();
  testany_data.time  += endwtime - startwtime;
  testany_data.calls += 1;

  return returnVal;
}

int  MPI_Testsome( int incount, MPI_Request *array_of_requests, 
		   int *outcount, int *array_of_indices, 
		   MPI_Status *array_of_statuses )
{
  int  returnVal;
  double startwtime, endwtime;

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Testsome( incount, array_of_requests, outcount, 
			     array_of_indices, array_of_statuses );
  endwtime = MPI_Wtime();
  testsome_data.time  += endwtime - startwtime;
  testsome_data.calls += 1;

  return returnVal;
}

void fpmpi_TestWaitInit( CallBasicData cd[] )
{
    cd[0].data = &wait_data;
    cd[1].data = &waitall_data;
    cd[2].data = &waitsome_data;
    cd[3].data = &waitany_data;
    
    cd[4].data = &test_data;
    cd[5].data = &testall_data;
    cd[6].data = &testsome_data;
    cd[7].data = &testany_data;
}
