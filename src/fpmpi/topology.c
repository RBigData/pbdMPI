/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *  (C) 2003 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */
#include "fpmpiconf.h"
#include "profiler.h"

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#include "mpi.h"


/* 
 * This file will contain routines to estimate the topology needs of a
 * computation.  The possibilities are:
 *
 *   Print all of the partners used by each process, with a weight 
 *   for the number of messages and the number of bytes
 *    ASCI Format:
 *        src dest calls bytes
 *    XML: (to be decided)
 *   This can be fed into a tool like matlab to generate a graph
 *   based on a matrix with row,column == (src,dest), and the magnitude 
 *   of the entry based on the calls and/or bytes
 *
 *   Print the percent of messages going certain distances, based on
 *   specific topologies.  For example, impose a 2 or 3-d mesh (computed 
 *   with MPI_Dims_create), then compute the distance to each 
 *   partner.  Allow the user to specify a topology (e.g., a particular
 *   mesh, including a ragged mesh (ignore processes with effective rank 
 *   >= size of comm world.
 */
/*
 * The information is in the CommPartnerData structure:
 * double times, long sizes, int partners.  This is stored as
 * an array, indexed by the number of processes.
 * 
 * There is a lighter-weight array, <name>_target[], that has a bit
 * for each partner.
 */

/* Alltarget is a bit-wise or of the target variables */
void fpmpiOutputPartnerTopology( int32_t alltarget[], FILE *pf, int llrank ) 
{
    int   i, j, nprocs, rank, nnodes;
    int   dims[5], ndims=2;
    int   coords[5], mycoords[5];
    int   *distbuf;
    int   dist, maxdist;

    PMPI_Comm_size( MPI_COMM_WORLD, &nprocs );

    /* Compute the distances for each of these */
    dims[0] = 0;
    dims[1] = 0;
    /* FIXME: Allow some way, such as env variables or Pcontrol parms,
       to set the topology */
    PMPI_Dims_create( nprocs, ndims, dims );

    /* Check for out-of-range size */
    maxdist = dims[0];
    if (dims[1] > maxdist) maxdist = dims[1];
    if (maxdist*3 > MAX_LINE_WIDTH) {
	/* There are too many processes for the display format, so
	   just silently exit */
	return;
    }

    /* Convert our rank to cartesian coordinates, using the rule in 
       MPI_Cart_coords */
    nnodes = nprocs;
    rank   = llrank;
    for (i=0; i<ndims; i++) {
	nnodes      = nnodes / dims[i];
	mycoords[i] = rank / nnodes;
	rank        = rank % nnodes;
    }

    /* For each partner, compute the coordinates and the 1-norm
       distance */
    maxdist = 0;
    for (i=0; i<nprocs; i++) {
	int idx, bitpos;
	idx = i >> 5;
	bitpos = i & 0x1f;
	if (alltarget[idx] & (1 << bitpos)) {
	    rank = i;
	    nnodes = nprocs;
	    for (j=0; j<ndims; j++) {
		nnodes    = nnodes / dims[j];
		coords[j] = rank / nnodes;
		rank      = rank % nnodes;
	    }
	    dist = 0;
	    for (j=0; j<ndims; j++) {
		int d1 = coords[j] - mycoords[j];
		if (d1 < 0) d1 = -d1;
		dist += d1;
	    }
	    if (dist > maxdist) maxdist = dist;
	}
    }

    /* Gather from everyone their maximum distance */
    distbuf = (int *)malloc( nprocs * sizeof(int) );
    PMPI_Gather( &maxdist, 1, MPI_INT, 
		 distbuf, 1, MPI_INT, 0, MPI_COMM_WORLD );
    
    /* Have the root print out the maximum distance */
    /* For one or two dimensional topologies, we could output as is.
       For three dimensional topologies, we could output each "plane", 
       since there will typically be relatively few planes (e.g., 16 x 16 x 8)
    */

    /* 
       To provide a consise output, the output is ordered so that the longest
       dimension is across the page and the shortest is down the page.
     */
    if (llrank == 0) {
	fprintf( pf, "\nSummary of target processes for point-to-point communication:\n" );
	fprintf( pf, "1-norm distance of point-to-point with an assumed 2-d topology\n" );
	fprintf( pf, "(Maximum distance for point-to-point communication from each process)\n" );
	if (ndims <= 2) {
	    int idx = 0;
	    if (dims[1] < dims[0]) {
		for (i=0; i<dims[1]; i++) {
		    for (j=0; j<dims[0]; j++) {
			fprintf( pf, "%3d", distbuf[idx+j*dims[1]] );
		    }
		    idx++;
		    fprintf( pf, "\n" );
		}
	    }
	    else {
		for (i=0; i<dims[0]; i++) {
		    for (j=0; j<dims[1]; j++) {
			fprintf( pf, "%3d", distbuf[idx] );
			idx++;
		    }
		    fprintf( pf, "\n" );
		}
	    }
	}
    }
    free(distbuf);
}

/* 
 * FIXME:
 *
 * Output an adjacency matrix of the partners 
 * 
 * One simple format:
 * source-rank dest-rank message volume by bins
 *
 * We use a single process for output
 * 
 * FIXME: This should use the CommPartnerData structure, which has
 * an entry for each possible partner
 */

void fpmpiOutputDetailedPartners( int32_t alltarget[], 
				  FILE *pf, int llrank ) 
{
    int          i, rank, nprocs, npby32, flag;
    MPI_Status   status;
    int32_t      targets[MAX_PROCBY32], *tp;

    /* First, see if we want to do this */
    PMPI_Comm_size( MPI_COMM_WORLD, &nprocs );
    if (llrank == 0) {
	char *p = getenv("FPMPI_DETAILED_PARTNER");
	if (!p) flag = (nprocs <= 8);
	else {
	    int threshold=0;
	    /* Value is the threshold (use if fewer processes) */
	    threshold = atoi(p);
	    flag = (threshold > 0 && threshold >= nprocs);
	}
    }
    PMPI_Bcast( &flag, 1, MPI_INT, 0, MPI_COMM_WORLD );
    if (!flag) return;

    npby32 = (nprocs + 31)/32;
    if (llrank != 0) {
	/* Send the data to rank 0 */
	PMPI_Ssend( alltarget, npby32, MPI_INT, 0, llrank, MPI_COMM_WORLD );
    }
    else {
	fprintf( pf, "\nDetailed partner data: source: dest1 dest2 ...\n" );
	fprintf( pf, "Size of COMM_WORLD\t%d\n", nprocs );
	for (rank = 0; rank < nprocs; rank++) {
	    if (rank != 0) {
		/* Receive the data */
		PMPI_Recv( targets, npby32, MPI_INT, rank, 
			   rank, MPI_COMM_WORLD, &status );
		tp = targets;
	    }
	    else {
		tp = alltarget;
	    }
	    /* For each potential partner, output the partners*/
	    fprintf( pf, "%d:", rank );
	    for (i=0; i<nprocs; i++) {
		int idx, bitpos;
		idx = i >> 5;
		bitpos = i & 0x1f;
		if (tp[idx] & (1 << bitpos)) {
		    /* Print out the partner and the amount of data 
		       sent to that partner */
		    fprintf( pf, "%d ", i );
		}
		
	    }
	    fprintf( pf, "\n" );
	}
    }
}

