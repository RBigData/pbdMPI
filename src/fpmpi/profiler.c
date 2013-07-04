/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*
 *
 *  (C) 2001-2003 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 */
/* 
   Changes 6/26/2012:
      + WDG - Added missing MPI2 collectives - Exscan, Alltoallw, 
        Reduce_scatter_block.  Added collection of data about communication
	volume to each partner in MPI_COMM_WORLD (not just the partners).
	Added communicator creation time, including sync time.

   Changes 8/3/2010:
      + WDG - Ensure group freed from communicator cache when the communicator
        is freed.  Added option to output the number of group cache misses
	(this will be used to see if we need a more sophisticated communicator
	and group cache to be used in translating ranks).

   Changes 9/7/2005:
      + WDG - Removed obsolete features, including gtable, computation of
        standard deviation.  Added recording and output of wait time 
	in MPI_Waitxxx, Recv, and Probe calls.  Reorganized some routines
	into separate files.  Cleaned up data organization to simplify adding 
	new features in the futures

   Changes 11/17/2003:
      + buschelm - Added logging of calls to MPI_Comm_dup and MPI_Comm_split
        with additional logging when comm used is MPI_IDENT to 
        MPI_COMM_WORLD and MPI_COMM_SELF

   Changes 10/27/2003:
      + buschelm - Improved output for synchronizing routines.

   Changes 9/32/2003:
      + WDG - Introduced msgsize_t to allow the use of 64 bit integers
        for message lengths when available.

   Changes 9/22/2003:
      + WDG - Added MPI_Pcontrol hook.  Fixed some collective routines
        so that only data *sent* is recorded (more uniform, since 
        amount sent and amount received is different.  Sent defined
	as "provided", e.g., bcast sends the data once from the root.
	Added explanatory header, and added more controls over output
	format.  Added synctime control.

   Changes 9/17/2003:
      + WDG - Many changes.  Fixed broken table output.  Restored
        ability to output in multiple output formats (not just XML),
        though only text currently available
	Changed to structures for the data collection to reduce
	overhead and simplify code.
	Split a lot of long code into separate routines; moved global
	declarations to the group of routines that use them.  We may
	want to subdivide the file at some point.

   Changes 9/15/2003:
      + WDG - Many updates, including new configure and fpmpiconf.h file

   Changes 10/22/2001:
      + Added nearest-neighbor collection info. Each proc will
        record the number of times it communicates with others as
        well as keep a running sum of the size of messages it
        sends to others.

        This is rather kludgey at the moment.

   Changes 7/20/2001:
      + Added support for proposed XML schema

      "It is assumed that each performance record must contain the 
      following (consistent with the second approach for performance 
      events [1]):
       - Record type (identifies the record)
       - Measurement container (consists of one or more measurements)
       - Metadata (system and application attributes that provide the 
         context in which the performance data was collected)
       - Timestamp (identify when the record was created)

   Changes 6/15/2001:
      + Added gtable output

   Changes 5/3/2000:
      + Send sizes were converted to doubles due to overflows.

   Changes 4/13/2000:
      + Output format was changed to reflect needs of the Terascale
        initiative.

   Changes 3/13/2000:
      + We now print the min/max/avg min_loc/max_loc for the communication
        partners across all ranks, instead of printing the list of all 
	ranks which participated in a point-to-point communication.
        In a 5-pt stencil, for instance, the avg. should be close to 5
	with min/max values differing due to boundary effects.
	The heading for this section (in MPI_PROFILE_FILE) has changed
	to "Communication Partners".

   Changes 3/3/2000:
      + On Linux systems, the /proc/(pid)/stat file is read in order
        to get memory usage info. Lines are notated with a 
	#ifdef LINUX directive.
      + We now check for the T5_EVENT1 environment variable, since
        if this is set, it generates an error (conflicting hwc error)
	on SGI machines when using the hardware counters. If set, an error
	message is printed to STDERR and executions halts.
	If not set, we check for the presence of the MPI_PROFILE_EVENT1
	environment variable. If set to 21, floating point ops are polled 
	from the hardware counters, and if set to 26,  L2 cache misses 
	are polled. Other values are allowed since we don't check this
	value. If MPI_PROFILE_EVENT1 is not set, L2 cache misses are
	polled by default.
      + The destination/sources of each point-to-point communication
        call is tracked and printed out, under the heading
	of "Processor Communication Data". 
	We just keep track of the ranks, independent of the communicators.  
	We *should* use MPI_Group_translate_ranks to make all ranks 
	relative to MPI_COMM_WORLD; in another realease...

      o Still to do: The Fortran interfaces for the MPI_Waitxxx routines
	are incorrect and need to be fixed.

   Changes 2/24/2000:
      + Totals for point-to-point sends:
          total calls, size of messages, time. This includes
	  the usual min/max/avg min-loc/max-loc info as well.
	  Also, the communication rate (size/time) is calculated.
      + Total for collective sends: (same as above)
      + Total "barrier" time is shown for collective routines
        (this is the time spent waiting for nodes to initiate 
        collective sends/receives)

   Changes 2/22/2000:
      + added profiling for MPI_Waitxxx calls (C only)
      + stats printed for Waits & Barrier calls.
      + added more MPI routines (Sendrecv_replace, Pack/Unpack)
*/

#include "fpmpiconf.h"
#include "profiler.h"
#include "mpi.h"
#include "fpmpi.h"

#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif
#include <time.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

/* Global defs & variables */

#define ONE_MB 1048576
#define ONE_KB 1024
#define MAX_MSG 1073741824
#define MPI_PROF_FILE_NAME "fpmpi_profile"

/* Specifics about output of the volume of communication to each 
   destination. */
#define DESTVOL_SUMMARY 1
#define DESTVOL_DETAIL  2
typedef enum { DESTVOL_OUT_BYROW, DESTVOL_OUT_COO } destvolOut_t;
static destvolOut_t destvolOutputFormat = DESTVOL_OUT_BYROW;

/* timing control */
int fpmpi_ProfControl      = 1;
int fpmpi_ProfControlSync  = 1;
int fpmpi_ProfControlDests = 1;
int fpmpi_ProfControlDestVol = DESTVOL_SUMMARY;
/* In experiments, the wait sync time often greatly increases the time
   that it takes to communicate */
int fpmpi_ProfControlWait  = 0;
/* For the wait test, we may want to limit the tests to messages that are
   longer than a certain size (typically the rendezvous size).  This 
   parameter is configurable so experiments with other lengths can be used */
int fpmpi_ProfControlWaitSize = 0;
/* Some collective routines are not semantically synchronizing, but either 
   their use or their implementation may be synchronizing.  MPI_Bcast is an 
   example. This flag allows us to deal with such collectives as if they
   are synchronizing (Bcast,scatter*,gather*) */
int fpmpi_ProfControlSyncAlt = 0;

/* This flag is used to control internal debugging */
int fpmpi_ProfControlDebug = 0;

/* Turn this on if waittime ever requested */
static int testwaitSyncEnabled = 0;

/* This is used to collect the ranks of all partner processes for point-to-
   point communication.  This is computed during finalize (during the 
   runs, we keep this data associated with each routine) */
static int32_t allPartners[MAX_PROCBY32];

enum bin_sizes {sz_0, sz_1to4, sz_5to8, sz_9to16, sz_17to32, sz_33to64, 
		sz_65to128, sz_129to256, sz_257to512, sz_513to1024, 
		sz_1to4K, sz_5to8K, sz_9to16K, sz_17to32K, sz_33to64K, 
		sz_65to128K, sz_129to256K, sz_257to512K, sz_513to1024K,
		sz_1to4M, sz_5to8M, sz_9to16M, sz_17to32M, sz_33to64M,
		sz_65to128M, sz_129to256M, sz_257to512M, sz_513to1024M, 
		sz_large};
/* maxBinSize gives the maximum size for each bin, and should match both the
 names in bin_sizes and in the implementation of Get_Bin_ID */
unsigned long  maxBinSize[NBINS] = { 
    0, 4, 8, 16, 32, 64, 
    128, 256, 512, 1024,
    4*1024, 8*1024, 16*1024, 32*1024, 64*1024,
    128*1024, 256*1024, 512*1024, 1024*1024,
    4*1024*1024, 8*1024*1024, 16*1024*1024, 32*1024*1024, 64*1024*1024,
    128*1024*1024, 256*1024*1024, 512*1024*1024,
    1024*1024*1024, -1 };

/* Forward references */
static int CheckEnvBool( const char[], int * );

/* 
 * Definitions for the data that is collected.
 * 
 * The hierarchy of structures is:
 *
 * For each class of routine (e.g., point-to-point, collective) there
 * is an array of structures:
 *   array of { routine-name, pointer-to-raw-data, pointer-to-summary-data }
 * A null routine name designates end-of-list.
 *
 * Each pointer to raw data contains information on each routine, 
 * separated in the bins by message size.  Additional information on 
 * process partners and on synchronization (collective) or wait (blocking
 * point-to-point) operations may also be collected.
 *
 * These arrays are used to simplify the reporting of results; the
 * output routine loop over them (also by class) to compute things like
 * total point-to-point communication volume.   
 */
typedef struct {
    double    time;     /* sum of time */
    double    synctime; /* sum of synchronization or wait time, if relevant */
    msgsize_t size;     /* sum of exact size */
    int       calls;    /* Number of calls */
} CommBinData; 

/* This struct combines all of the data about the use of a routine - both
    the communication (CommBinData) and the partners (topology) */
typedef struct {
    CommBinData  b[NBINS];     /* One bin for each range of message size */
    int32_t      partners[MAX_PROCBY32];
                               /* partners is a bit vector to keep track of
		                  with which processes this one has been in
				  communication.  Pt2pt only */
    msgsize_t    *sizeToPartner;  /* Total message volume to partner.  
				     Allocated if feature enabled; pt2pt only.
				   */
} CommData;

/* This structure contains all of the information about the use of a routine,
   including the routine's name, communication data, and memory used to
   create the output */
typedef struct {
    const char *name;               /* Name of routine */
    int         hasSyncTime; 
    CommData    *data;              /* Raw data (for this process).
				       Pointer used to simplify definition;
				       access in routines is directly to the
				       data to which this points */
    CommData    sumData,            /* Aggregated data (valid on process 0 */
 	        maxData, minData;   /* only) */
    double      totalTime, totalSync,
                minTime, maxTime, maxSync;
    int         totalCalls, 
	        minCalls, maxCalls;
    msgsize_t   totalSize, maxSize; /* TotalSize is the aggregate size over all
				       processes.  maxSize is the maximum sent
				       or received by any one process */
    int         maxTimeLoc, maxCallsLoc, maxSizeLoc, maxSyncLoc; 
                                    /* Rank of process with the maxTime etc. */
    /* partner data */
    int         totalPartners, maxPartners, maxPartnersLoc,
	        minPartners, minPartnersLoc;
} CallData;

/* NoCommData and CallBasicData are defined in profiler.h */

static int getSummaryNoCommData( CallBasicData *, int );
static int getSummaryCommData( CallData *, int );
static int getSummaryPartnerData( CallData *, int );
static int PercentagesToString( const double [], int, char [] );
static int TimeBinsToString( CommBinData [], int, int, char [] );
static int SyncBinsToString( CommBinData [], int, int, char [] );
static int CallsBinsToString( CommBinData [], int, int, char [] );

static int AccumulateData( int, int );
static int PrintAverageData( FILE *, int );
static int PrintDetailedData( FILE *, int );
void  PrintDetailedPartners( FILE *pf, int llrank, int nprocs );

#define COUNTER_DECL(name) static CommData name##_data
#define COUNTER_DECL_COLL(name) COUNTER_DECL(name)

COUNTER_DECL_COLL(allgather);
COUNTER_DECL_COLL(allgatherv);
COUNTER_DECL_COLL(allreduce);
COUNTER_DECL_COLL(alltoall);
COUNTER_DECL_COLL(alltoallv);
COUNTER_DECL_COLL(alltoallw);

static CallData allCollectiveInfo[] = {
    { "Allgather",  1, &allgather_data },
    { "Allgatherv", 1, &allgatherv_data },
    { "Allreduce",  1, &allreduce_data },
    { "Alltoall",   1, &alltoall_data },
    { "Alltoallv",  1, &alltoallv_data },
    { "Alltoallw",  1, &alltoallw_data },
    { 0, 0, 0 } };

COUNTER_DECL(bcast);
COUNTER_DECL(gather);
COUNTER_DECL(gatherv);
COUNTER_DECL(reduce_scatter);
COUNTER_DECL(reduce_scatter_block);
COUNTER_DECL(reduce);
COUNTER_DECL(scan);
COUNTER_DECL(exscan);
COUNTER_DECL(scatter);
COUNTER_DECL(scatterv);

static CallData collectiveInfo[] = {
    { "Bcast", 0, &bcast_data },
    { "Gather", 0, &gather_data },
    { "Gatherv", 0, &gatherv_data },
    { "Reduce_scatter", 1, &reduce_scatter_data },
    { "Reduce_scatter_block", 1, &reduce_scatter_block_data },
    { "Reduce", 0, &reduce_data },
    { "Scan", 0, &scan_data },
    { "Exscan", 0, &exscan_data },
    { "Scatter", 0, &scatter_data },
    { "Scatterv", 0, &scatterv_data }, 
    { 0, 0 } };

COUNTER_DECL(recv);
COUNTER_DECL(send);
COUNTER_DECL(sendrecv);
COUNTER_DECL(sendrecv_replace);
COUNTER_DECL(bsend);
COUNTER_DECL(ibsend);
COUNTER_DECL(isend);
COUNTER_DECL(issend);
COUNTER_DECL(irsend);
COUNTER_DECL(rsend);
COUNTER_DECL(ssend);
COUNTER_DECL(irecv);

/* FIXME: Add synctime to other blocking send routines */

static CallData pt2ptInfo[] = {
    { "Recv", 1, &recv_data },
    { "Send", 1, &send_data },
    { "Sendrecv", 0, &sendrecv_data }, 
    { "Sendrecv_replace", 0, &sendrecv_replace_data },
    { "Bsend", 0, &bsend_data },
    { "Ibsend", 0, &ibsend_data }, 
    { "Isend", 0, &isend_data },
    { "Issend", 0, &issend_data },
    { "Irsend", 0, &irsend_data },
    { "Rsend", 0, &rsend_data },
    { "Ssend", 0, &ssend_data },
    { "Irecv", 0, &irecv_data }, 
    { 0, 0 } };

COUNTER_DECL(pack);
COUNTER_DECL(unpack);

static CallData packInfo[] = {
    { "Pack", 0, &pack_data }, 
    { "Unpack", 0, &unpack_data }, 
    { 0, 0 } };

static NoCommData iprobe_data;
static NoCommData probe_data;

static CallBasicData probeInfo[] = {
    { "Probe", 1, &probe_data },
    { "Iprobe", 0, &iprobe_data },
    { 0, 0 } };

static NoCommData barrier_data;
static CallBasicData barrierInfo = { "Barrier", 0, &barrier_data };

/* The declarations for these are in the testwait.c file and are
   initialized in MPI_Init */

/* If the order of these is changed, match the changes in testwait.c */   
static CallBasicData testwaitInfo[] = {
    { "Wait", 1, 0 },
    { "Waitall", 1, 0 },
    { "Waitsome", 1, 0 },
    { "Waitany", 1, 0 },
    { "Test", 0, 0 },
    { "Testall", 0, 0 },
    { "Testsome", 0, 0 },
    { "Testany", 0, 0 },
    { 0, 0, 0 } };

static NoCommData comm_create_data, comm_split_data, comm_dup_data;
static CallBasicData commInfo[] = {
    { "Comm_create", 1, &comm_create_data },
    { "Comm_split",  1, &comm_split_data },
    { "Comm_dup",    1, &comm_dup_data }, 
    { 0, 0 } };

/* At this point, we create a structure that contains pointers
   to each of these info structures; this will allow us to customize
   all of the output routines (This structure is not yet used) */
typedef struct fpmpiData { 
    CallData      *allcolls, *colls, *pt2pt, *pack;
    CallBasicData *probe, *barrier, *testwait, *comm; } fpmpiData;
fpmpiData fpmpiAllData = { allCollectiveInfo, collectiveInfo, pt2ptInfo, 
			   packInfo, probeInfo, &barrierInfo, testwaitInfo,
                           commInfo };

/* ------------------------------------------------------------------------ */
/* These provide a quick way to handle one comm other than comm_world
   in determining the target process of communication */
static MPI_Comm comm_cache = MPI_COMM_NULL;
static MPI_Group group_cache = MPI_GROUP_NULL;
static MPI_Group group_world = MPI_GROUP_NULL;
static int groupCacheMiss = 0;

/* Uses global buf_size for the amount of data moved */
/* Could also optimize for dups of COMM_WORLD (no need to translate ranks) */
/* FIXME: If communicator is not contained in COMM_WORLD, this can fail. */
#define UPDATE_COMM_DESTS(name,comm,source) if (fpmpi_ProfControlDests){ \
    int _s = source; \
    if (comm != MPI_COMM_WORLD) {\
        if (comm != comm_cache) {\
            if (group_cache != MPI_GROUP_NULL) PMPI_Group_free(&group_cache);\
            PMPI_Comm_group( comm, &group_cache );\
	    groupCacheMiss++; \
            comm_cache = comm;\
            }\
        PMPI_Group_translate_ranks( group_cache, 1, &source, group_world, &_s);\
     }\
     name##_data.partners[_s >> 5] |= ((unsigned)1 << (_s & 0x01F));\
     if (fpmpi_ProfControlDestVol){\
         name##_data.sizeToPartner[_s] += buf_size;\
     }\
} 

/* forward declarations */
static inline int Get_Bin_ID( int );
static inline int Get_Msg_size( int, MPI_Datatype );


/* Begin Profiling Routines */
/* FIXME: Provide a option to separate communication data by communicator.
   We could attach the data as an attribute to the communicator */
#ifdef GET_BY_COMM
#error 'not yet implemented'
#elif  defined(ALLOC_BY_COMM)
/* Provide a runtime option to store data by communicator or aggregate.  
   This provides a performance/detail tradeoff */
#error 'not yet implemented'
#else
#define GET_COUNTER(name) &(name##_data.b[bin_id]
#endif

/* This macro lets us change the way we remember the call */
#define UPDATE_COUNTER(name) if(fpmpi_ProfControl){ \
 CommBinData *const _b = &(name##_data.b[bin_id]);\
 _b->time += (endwtime - startwtime);  _b->calls ++; _b->size += buf_size; }

#define UPDATE_COUNTER_SYNC(name) \
    name##_data.b[bin_id].synctime += synctime;

/* Break out the time sync but leave the separate update macro
   in case we decide to change how we handle the data recording */
#define UPDATE_COUNTER_COLL(name) UPDATE_COUNTER(name)

/* Convert a (count/datatype) into a size in bytes 
 * Note:
 * Eventually we may want to have a short cut for this for
 * know implementation.  E.g., in MPICH2, the size may 
 * be extracted from basic datatypes without a routine call.
 */
static inline int Get_Msg_size( int count, MPI_Datatype datatype )
{
    int dsize;
    
    PMPI_Type_size( datatype, &dsize );
    return count * dsize;
}

/* ------------------------------------------------------------------------
 * Service routines for collecting data
 * ------------------------------------------------------------------------
 */
/* Determine message bin ID.
   To keep this fast, the bin id's are a power of two; we can compute the
   bin id with a quick tree code.  STILL TO DO!  FIXME

   We should really just look for 4 * 2^k (since most scientific data
   will be at least a multiple of the size of an int).

   size >>= 2;   // divide by four 
   Find the location of the largest bit.
   See http://graphics.stanford.edu/~seander/bithacks.html#IntegerLog
   for an example.  An easy code is

   int b = buf_size;
   while (b >>=1) bin_id ++;
   if (bin_id > 1) bin_id -= 1;  // combine 1 and 2,3 byte messages
   
   This gives:
   bin_id == 0  Messages of 0 bytes
   bin_id == 1  Messages of 1,2,3 bytes
   bin_id == 2  Messages of 4-7 bytes
   bin_id == k  Messages of 2^k - 2^k-1 bytes

   FIXME:
   We should have a default that quickly looks at the high
   bit; an option could allow the selection of user-defined sizes.
   E.g., use
    if (buf_size & 0xffff0000) { bin_id += 16; buf_size &= 0xffff0000; }
    if (buf_size & 0xff00ff00) { bin_id += 8;  buf_size &= 0xff00ff00; }
    if (buf_size & 0xf0f0f0f0) { bin_id += 4;  buf_size &= 0xf0f0f0f0; }
    if (buf_size & 0xcccccccc) { bin_id += 2;  buf_size &= 0xcccccccc; }
    if (buf_size & 0xaaaaaaaa) bin_id ++;
   which gives the number of the highest set bit in buf_size.

*/
static int Get_Bin_ID(int buf_size)
{
  int bin_id = 0; /* By default, assume a zero size message */

  /* We subdivide this a little to catch the short messages 
     early */
  if (buf_size > 4*ONE_KB) {
      if ( buf_size > MAX_MSG ) bin_id = NBINS - 1; /* The last bin is for
						       messages > 1024MB */
      else if ( buf_size > 512*ONE_MB ) bin_id = sz_513to1024M;
      else if ( buf_size > 256*ONE_MB ) bin_id = sz_257to512M;
      else if ( buf_size > 128*ONE_MB ) bin_id = sz_129to256M;
      else if ( buf_size >  64*ONE_MB ) bin_id = sz_65to128M;
      else if ( buf_size >  32*ONE_MB ) bin_id = sz_33to64M;
      else if ( buf_size >  16*ONE_MB ) bin_id = sz_17to32M;
      else if ( buf_size >   8*ONE_MB ) bin_id = sz_9to16M;
      else if ( buf_size >   4*ONE_MB ) bin_id = sz_5to8M;
      else if ( buf_size >     ONE_MB ) bin_id = sz_1to4M;
      else if ( buf_size > 512*ONE_KB ) bin_id = sz_513to1024K;
      else if ( buf_size > 256*ONE_KB ) bin_id = sz_257to512K;
      else if ( buf_size > 128*ONE_KB ) bin_id = sz_129to256K;
      else if ( buf_size >  64*ONE_KB ) bin_id = sz_65to128K;
      else if ( buf_size >  32*ONE_KB ) bin_id = sz_33to64K;
      else if ( buf_size >  16*ONE_KB ) bin_id = sz_17to32K;
      else if ( buf_size >   8*ONE_KB ) bin_id = sz_9to16K;
      else /*if ( buf_size >   4*ONE_KB )*/ bin_id = sz_5to8K;
  }
  else {
     if ( buf_size >  32 )  {
	 if      ( buf_size > ONE_KB ) bin_id = sz_1to4K;
	 else if ( buf_size > 512 )    bin_id = sz_513to1024;
	 else if ( buf_size > 256 )    bin_id = sz_257to512;
	 else if ( buf_size > 128 )    bin_id = sz_129to256;
	 else if ( buf_size >  64 )    bin_id = sz_65to128;
	 else 	                       bin_id = sz_33to64;
     }
     else {
	 if      ( buf_size >  16 )    bin_id = sz_17to32;
	 else if ( buf_size >   8 )    bin_id = sz_9to16;
	 else if ( buf_size >   4 )    bin_id = sz_5to8;
	 else if ( buf_size >   0  )   bin_id = sz_1to4;
	 else                          bin_id = sz_0;
     }
  }
  return bin_id;
}

/*
 * --------------------------------------------------------------------
 * Here begins the replacements for the MPI routines
 * --------------------------------------------------------------------
 */
/*
    MPI_Allgather - prototyping replacement for MPI_Allgather
    Trace the beginning and ending of MPI_Allgather.
*/
int MPI_Allgather( void *sendbuf, int sendcount, MPI_Datatype sendtype, 
		   void *recvbuf, int recvcount, MPI_Datatype recvtype, 
		   MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size;

#ifdef HAVE_MPI_IN_PLACE
  if (sendbuf == MPI_IN_PLACE) {
      buf_size = Get_Msg_size( recvcount, recvtype );
  }
  else 
#endif
  buf_size = Get_Msg_size( sendcount, sendtype );
  bin_id = Get_Bin_ID( buf_size );

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(allgather);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Allgather( sendbuf, sendcount, sendtype, recvbuf, 
			      recvcount, recvtype, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(allgather);

  return returnVal;
}

/*
    MPI_Allgatherv - prototyping replacement for MPI_Allgatherv
    Trace the beginning and ending of MPI_Allgatherv.
*/
int MPI_Allgatherv( void *sendbuf, int sendcount, MPI_Datatype sendtype, 
		    void *recvbuf, int *recvcounts, int *displs, 
		    MPI_Datatype recvtype, MPI_Comm comm ) 
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size;

#ifdef HAVE_MPI_IN_PLACE
  if (sendbuf == MPI_IN_PLACE) {
      int myrank;
      PMPI_Comm_rank( comm, &myrank );
      buf_size = Get_Msg_size( recvcounts[myrank], recvtype );
  }
  else 
#endif
  buf_size = Get_Msg_size( sendcount, sendtype );
  bin_id = Get_Bin_ID( buf_size);

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(allgatherv);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Allgatherv( sendbuf, sendcount, sendtype, recvbuf, 
			       recvcounts, displs, recvtype, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(allgatherv);
  
  return returnVal;
}

/*
    MPI_Allreduce - prototyping replacement for MPI_Allreduce
    Trace the beginning and ending of MPI_Allreduce.
*/
int MPI_Allreduce( void *sendbuf, void *recvbuf, int count, 
		   MPI_Datatype datatype, MPI_Op op, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID( buf_size );

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(allreduce);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Allreduce( sendbuf, recvbuf, count, datatype, op, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(allreduce);

  return returnVal;
}

/*
    MPI_Alltoall - prototyping replacement for MPI_Alltoall
    Trace the beginning and ending of MPI_Alltoall.
*/
int MPI_Alltoall( void *sendbuf, int sendcount, MPI_Datatype sendtype, 
		  void *recvbuf, int recvcnt, MPI_Datatype recvtype, 
		  MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size, nprocs;

  PMPI_Comm_size( comm, &nprocs );
  buf_size = nprocs * Get_Msg_size( sendcount, sendtype );
  bin_id = Get_Bin_ID( buf_size );

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(alltoall);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Alltoall( sendbuf, sendcount, sendtype, recvbuf,
			     recvcnt, recvtype, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(alltoall);
  
  return returnVal;
}

/*
    MPI_Alltoallv - prototyping replacement for MPI_Alltoallv
    Trace the beginning and ending of MPI_Alltoallv.
*/
int MPI_Alltoallv( void *sendbuf, int *sendcnts, int *sdispls, 
		   MPI_Datatype sendtype, void *recvbuf, int *recvcnts, 
		   int *rdispls, MPI_Datatype recvtype, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size, i, nprocs;

  buf_size = 0;
  PMPI_Comm_size( comm, &nprocs );
  for (i=0; i<nprocs; i++) {
      buf_size += Get_Msg_size( sendcnts[i], sendtype );
  }
  bin_id = Get_Bin_ID(buf_size);  /* Determine message bin ID */

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(alltoallv);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Alltoallv( sendbuf, sendcnts, sdispls, sendtype, recvbuf,
			      recvcnts, rdispls, recvtype, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(alltoallv);
  
  return returnVal;
}

#if defined(MPI_VERSION) && MPI_VERSION >= 2
/*
    MPI_Alltoallw - prototyping replacement for MPI_Alltoallw
    Trace the beginning and ending of MPI_Alltoallw.
*/
int MPI_Alltoallw(void *sendbuf, int *sendcnts, int *sdispls, 
                  MPI_Datatype *sendtypes, void *recvbuf, int *recvcnts, 
                  int *rdispls, MPI_Datatype *recvtypes, MPI_Comm comm)
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    buf_size, i, nprocs;

  buf_size = 0;
  PMPI_Comm_size( comm, &nprocs );
  for (i=0; i<nprocs; i++) {
      buf_size += Get_Msg_size( sendcnts[i], sendtypes[i] );
  }
  bin_id = Get_Bin_ID(buf_size);  /* Determine message bin ID */

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(alltoallw);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Alltoallw( sendbuf, sendcnts, sdispls, sendtypes, recvbuf,
			      recvcnts, rdispls, recvtypes, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER_COLL(alltoallw);
  
  return returnVal;
}
#endif

/*
    MPI_Barrier - prototyping replacement for MPI_Barrier
    Trace the beginning and ending of MPI_Barrier.
*/
int MPI_Barrier( MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Barrier( comm );
  endwtime = MPI_Wtime();
  barrier_data.time  += endwtime - startwtime;
  barrier_data.calls += 1;

  return returnVal;
}

/*
     MPI_Iprobe - prototyping replacement for MPI_Iprobe
     Count calls, and accumulate total time.
*/
int MPI_Iprobe(int source, int tag, MPI_Comm comm, int *flag, MPI_Status *status)
{
  int     returnVal;
  double startwtime, endwtime;
 
  startwtime    = MPI_Wtime();
  returnVal     = PMPI_Iprobe(source,tag,comm,flag,status);
  endwtime      = MPI_Wtime();

  iprobe_data.time += endwtime - startwtime;
  iprobe_data.calls += 1;

  return returnVal;
}

/*
     MPI_Probe - prototyping replacement for MPI_Probe
     Count calls, and accumulate total time.
*/
int MPI_Probe(int source, int tag, MPI_Comm comm, MPI_Status *status)
{
  int    returnVal;
  double endttime = 0;
  double startwtime, endwtime;

  if (fpmpi_ProfControlWait) {
      int flag;
      startwtime = endttime = MPI_Wtime();
      do {
	  returnVal = PMPI_Iprobe( source, tag, comm, &flag, status );
	  if (!flag) endttime = MPI_Wtime();
      } while (!flag && !returnVal);
      endwtime = MPI_Wtime();
      probe_data.synctime += endttime - startwtime;
  }
  else {
      startwtime    = MPI_Wtime();
      returnVal     = PMPI_Probe(source,tag,comm,status);
      endwtime      = MPI_Wtime();
  }

  probe_data.time  += endwtime - startwtime;
  probe_data.calls += 1;

  return returnVal;
}

/*
    MPI_Bcast - prototyping replacement for MPI_Bcast
    Trace the beginning and ending of MPI_Bcast.
*/
int MPI_Bcast( void *buffer, int count, MPI_Datatype datatype, 
	       int root, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size, rank;

  PMPI_Comm_rank( comm, &rank );
  buf_size = Get_Msg_size( count, datatype );/* Size is in bytes */
  bin_id = Get_Bin_ID(buf_size);  /* Determine message bin ID */

  if (rank != root) {
      /* This sets the bin_id to the size of message being received
	 but counts as no data *sent.* */
      buf_size = 0;
  }

  /* Permit the collection of synchronization time even for those collectives
     that are not semantically synchronizing, because their use in the 
     code or the algorithm used for their implementation is synchronizing. */
  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(bcast);
  }

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Bcast( buffer, count, datatype, root, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(bcast);

  return returnVal;
}

/*
    MPI_Gather - prototyping replacement for MPI_Gather
    Trace the beginning and ending of MPI_Gather.
*/
int MPI_Gather( void *sendbuf, int sendcnt, MPI_Datatype sendtype, 
		void *recvbuf, int recvcount, MPI_Datatype recvtype, 
		int root, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size;

#ifdef HAVE_MPI_IN_PLACE
  if (sendbuf == MPI_IN_PLACE) {
      buf_size = Get_Msg_size( recvcount, recvtype );
  }
  else 
#endif
  buf_size = Get_Msg_size( sendcnt, sendtype );
  bin_id = Get_Bin_ID(buf_size);
  
  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(gather);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Gather( sendbuf, sendcnt, sendtype, recvbuf, 
			   recvcount, recvtype, root, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(gather);

  return returnVal;
}

/*
    MPI_Gatherv - prototyping replacement for MPI_Gatherv
    Trace the beginning and ending of MPI_Gatherv.
*/
int MPI_Gatherv( void *sendbuf, int sendcnt, MPI_Datatype sendtype, 
		 void *recvbuf, int *recvcnts, int *displs, 
		 MPI_Datatype recvtype, int root, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( sendcnt, sendtype );
  bin_id = Get_Bin_ID(buf_size);
  
  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(gatherv);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Gatherv( sendbuf, sendcnt, sendtype, recvbuf, recvcnts,
			    displs, recvtype, root, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(gatherv);
  
  return returnVal;
}

/*
    MPI_Pack - prototyping replacement for MPI_Pack
    Log the beginning and ending of the time spent in MPI_Pack calls.
*/
int MPI_Pack( void *inbuf, int incount, MPI_Datatype datatype, void *outbuf, 
	      int outcount, int *position, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( incount, datatype );
  bin_id = Get_Bin_ID( buf_size );
  
  startwtime = MPI_Wtime();
  returnVal  = PMPI_Pack(inbuf, incount, datatype, outbuf, outcount, 
			position, comm );
  endwtime   = MPI_Wtime();
  UPDATE_COUNTER(pack);

  return returnVal;
}

/*
    MPI_Unpack - prototyping replacement for MPI_Unpack
    Log the beginning and ending of the time spent in MPI_Unpack calls.
*/
int MPI_Unpack( void *inbuf, int insize, int *position, void *outbuf, 
		int outcount, MPI_Datatype datatype, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( outcount, datatype );
  bin_id = Get_Bin_ID( buf_size );
  
  startwtime = MPI_Wtime();
  returnVal = PMPI_Unpack( inbuf, insize, position, outbuf, outcount, 
			   datatype, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(unpack);

  return returnVal;
}

/*
    MPI_Reduce_scatter - prototyping replacement for MPI_Reduce_scatter
    Trace the beginning and ending of MPI_Reduce_scatter.
*/
int MPI_Reduce_scatter( void *sendbuf, void *recvbuf, int *recvcnts, 
			MPI_Datatype datatype, MPI_Op op, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    ierr, buf_size;
  
  buf_size = Get_Msg_size( recvcnts[0], datatype ); /* FIXME */
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();	  
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(reduce_scatter);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Reduce_scatter( sendbuf, recvbuf, recvcnts, datatype,
				   op, comm );
  endwtime = MPI_Wtime();	
  UPDATE_COUNTER(reduce_scatter);  
  
  return returnVal;
}

#if defined(MPI_VERSION) && ((MPI_VERSION == 2 && MPI_SUBVERSION >= 2)	|| \
			     MPI_VERSION > 2)
/*
    MPI_Reduce_scatter_block - prototyping replacement for 
    MPI_Reduce_scatter_block
    Trace the beginning and ending of MPI_Reduce_scatter_block
*/
int MPI_Reduce_scatter_block(void *sendbuf, void *recvbuf, int recvcount, 
		       MPI_Datatype datatype, MPI_Op op, MPI_Comm comm)
{
  int    returnVal;
  double startwtime, endwtime;
  double synctime;
  int    bin_id;
  int    ierr, buf_size;
  
  buf_size = Get_Msg_size( recvcount, datatype );
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSync) {
      startwtime = MPI_Wtime();	  
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(reduce_scatter_block);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Reduce_scatter_block( sendbuf, recvbuf, recvcount, datatype,
					 op, comm );
  endwtime = MPI_Wtime();	
  UPDATE_COUNTER(reduce_scatter_block);  
  
  return returnVal;
}
#endif

/*
    MPI_Reduce - prototyping replacement for MPI_Reduce
    Trace the beginning and ending of MPI_Reduce.
*/
int MPI_Reduce( void *sendbuf, void *recvbuf, int count, 
		  MPI_Datatype datatype, MPI_Op op, int root, 
		  MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size;
  
  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(reduce);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Reduce( sendbuf, recvbuf, count, datatype, op, root, comm );
  endwtime = MPI_Wtime();	
  UPDATE_COUNTER(reduce);  

  return returnVal;
}

/*
    MPI_Scan - prototyping replacement for MPI_Scan
    Trace the beginning and ending of MPI_Scan.
*/
int MPI_Scan( void *sendbuf, void *recvbuf, int count, 
		MPI_Datatype datatype, MPI_Op op, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size;
  
  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(scan);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Scan( sendbuf, recvbuf, count, datatype, op, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(scan);	  

  return returnVal;
}

#if defined(MPI_VERSION) && MPI_VERSION >= 2
/*
    MPI_Exscan - prototyping replacement for MPI_Exscan
    Trace the beginning and ending of MPI_Exscan.
*/
int MPI_Exscan( void *sendbuf, void *recvbuf, int count, 
		MPI_Datatype datatype, MPI_Op op, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size;
  
  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(exscan);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Exscan( sendbuf, recvbuf, count, datatype, op, comm );
  endwtime = MPI_Wtime();
  UPDATE_COUNTER(exscan);	  

  return returnVal;
}
#endif

/*
    MPI_Scatter - prototyping replacement for MPI_Scatter
    Trace the beginning and ending of MPI_Scatter.
*/
int MPI_Scatter( void *sendbuf, int sendcnt, MPI_Datatype sendtype, 
		 void *recvbuf, int recvcnt, MPI_Datatype recvtype, 
		 int root, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size, rank;

  /* If the rank is not the root, then the send arguments are ignored */
  PMPI_Comm_rank( comm, &rank );
  if (rank != root) {
      buf_size = 0;  
  }
  else {
      buf_size = Get_Msg_size( sendcnt, sendtype );
  }
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(scatter);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Scatter( sendbuf, sendcnt, sendtype, recvbuf, recvcnt, 
			    recvtype, root, comm );
  endwtime = MPI_Wtime();	  
  UPDATE_COUNTER(scatter);

  return returnVal;
}

/*
    MPI_Scatterv - prototyping replacement for MPI_Scatterv
    Trace the beginning and ending of MPI_Scatterv.
*/
int MPI_Scatterv( void *sendbuf, int *sendcnts, int *displs, 
		  MPI_Datatype sendtype, void *recvbuf, int recvcnt, 
		  MPI_Datatype recvtype, int root, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime;
  int    bin_id;
  int    buf_size, i, nprocs, rank;
  int    isIntercomm;

  PMPI_Comm_rank( comm, &rank );
  PMPI_Comm_size( comm, &nprocs );
  PMPI_Comm_test_inter( comm, &isIntercomm );
  if ( (rank == root && !isIntercomm) 
#ifdef HAVE_MPI_ROOT
       || (rank == MPI_ROOT && isIntercomm) 
#endif
      ) {
      buf_size = 0;
      for (i=0; i<nprocs; i++) {
	  buf_size += Get_Msg_size( sendcnts[i], sendtype );
      }
  }
  else {
      buf_size = 0;
  }
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlSyncAlt) {
      startwtime = MPI_Wtime();
      PMPI_Barrier( comm );
      synctime = MPI_Wtime() - startwtime;
      UPDATE_COUNTER_SYNC(scatterv);
  }

  startwtime = MPI_Wtime();
  returnVal = PMPI_Scatterv( sendbuf, sendcnts, displs, sendtype, recvbuf, 
			     recvcnt, recvtype, root, comm );
  endwtime = MPI_Wtime();	
  UPDATE_COUNTER(scatterv);  

  return returnVal;
}

/*
    MPI_Recv - prototyping replacement for MPI_Recv
    Trace the beginning and ending of MPI_Recv.
*/
int MPI_Recv( void *buf, int count, MPI_Datatype datatype, int source, 
	       int tag, MPI_Comm comm, MPI_Status *status )
{
  int    returnVal;
  double startwtime, endwtime;
  double endttime = 0;
  double synctime = 0;
  int    bin_id;
  int    buf_size;
  MPI_Status tmpstatus;
  MPI_Status *sp = status;

  if (status == MPI_STATUS_IGNORE) sp = &tmpstatus;

  if (fpmpi_ProfControlWait && source != MPI_PROC_NULL) {
      /* Endttime is the last time *before* the iprobe would succeed. */
      int flag;
      startwtime = MPI_Wtime();
      do {
	  endttime = MPI_Wtime();
	  returnVal = PMPI_Iprobe( source, tag, comm, &flag, sp );
      } while (!flag && !returnVal);
      synctime += endttime - startwtime;
  }
  else {
      startwtime = MPI_Wtime();
  }

  returnVal = PMPI_Recv( buf, count, datatype, source, tag, comm, sp );
  endwtime = MPI_Wtime();

  if (source != MPI_PROC_NULL) {
      PMPI_Get_count( sp, datatype, &count );
      buf_size = Get_Msg_size( count, datatype );
      bin_id = Get_Bin_ID(buf_size);  /* Determine message bin ID */
  
      UPDATE_COUNTER(recv);
      if (fpmpi_ProfControlWait) {
	  UPDATE_COUNTER_SYNC(recv);
      }
      /* actsrc = sp->MPI_SOURCE; */
      /* UPDATE_COMM_DESTS(recv, comm, actsrc); */
  }

  return returnVal;
}


/*
    MPI_Send - prototyping replacement for MPI_Send
    Trace the beginning and ending of MPI_Send.
*/
int MPI_Send( void *buf, int count, MPI_Datatype datatype, int dest, 
	       int tag, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime, synctime=0;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  if (fpmpi_ProfControlWait && dest != MPI_PROC_NULL && 
      fpmpi_ProfControlWaitSize <= buf_size) {
      MPI_Request req;
      double      endttime;
      int         flag;

      startwtime = MPI_Wtime();
      returnVal = PMPI_Issend( buf, count, datatype, dest, tag, comm, &req );
      do {
	  endttime = MPI_Wtime();
	  returnVal = PMPI_Test( &req, &flag, MPI_STATUS_IGNORE );
      } while (!flag && !returnVal);
      synctime = endttime - startwtime;
      PMPI_Wait( &req, MPI_STATUS_IGNORE );
      endwtime = MPI_Wtime();
      UPDATE_COUNTER_SYNC(send);
  }
  else {
      startwtime = MPI_Wtime();	  
      returnVal  = PMPI_Send( buf, count, datatype, dest, tag, comm );
      endwtime   = MPI_Wtime();
  }
  UPDATE_COUNTER(send);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(send, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Sendrecv - prototyping replacement for MPI_Sendrecv
    Trace the beginning and ending of MPI_Sendrecv.
*/
int MPI_Sendrecv( void * sendbuf, int sendcount, MPI_Datatype sendtype, 
		   int dest, int sendtag, void * recvbuf, int recvcount, 
		   MPI_Datatype recvtype, int source, int recvtag, 
		   MPI_Comm comm, MPI_Status * status)
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;
  MPI_Status tmpstatus;
  MPI_Status *sp = status;

  if (status == MPI_STATUS_IGNORE) sp = &tmpstatus;

  buf_size = Get_Msg_size( sendcount, sendtype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Sendrecv( sendbuf, sendcount, sendtype, dest, sendtag, 
			     recvbuf, recvcount, recvtype, source, recvtag,
			     comm, sp );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(sendrecv);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(sendrecv, comm, dest); /* Only has send dest */
  }

  return returnVal;
}

/*
    MPI_Sendrecv_replace - prototyping replacement for MPI_Sendrecv_replace
    Log the beginning and ending of the time spent in MPI_Sendrecv_replace calls.
*/
int MPI_Sendrecv_replace( void *buf, int count, MPI_Datatype datatype, 
			  int dest, int sendtag, int source, int recvtag, 
			  MPI_Comm comm, MPI_Status *status )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;
  MPI_Status tmpstatus;
  MPI_Status *sp = status;

  if (status == MPI_STATUS_IGNORE) sp = &tmpstatus;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal  = PMPI_Sendrecv_replace( buf, count, datatype, dest, 
			 sendtag, source, recvtag, comm, sp );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(sendrecv_replace);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(sendrecv_replace, comm, dest);
  }
  
  return returnVal;
}

/*
    MPI_Bsend - prototyping replacement for MPI_Bsend
    Trace the beginning and ending of MPI_Bsend.
*/
int MPI_Bsend( void *buf, int count, MPI_Datatype datatype, int dest, 
	       int tag, MPI_Comm comm )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Bsend( buf, count, datatype, dest, tag, comm );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(bsend);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(bsend, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Ibsend - prototyping replacement for MPI_Ibsend
    Trace the beginning and ending of MPI_Ibsend.
*/
int MPI_Ibsend( void *buf, int count, MPI_Datatype datatype, int dest, 
		int tag, MPI_Comm comm, MPI_Request *request )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Ibsend( buf, count, datatype, dest, tag, comm, request );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(ibsend);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(ibsend, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Irecv - prototyping replacement for MPI_Irecv
    Trace the beginning and ending of MPI_Irecv.
*/
int MPI_Irecv( void * buf, int count, MPI_Datatype datatype, int source,
		int tag, MPI_Comm comm, MPI_Request * request)
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Irecv( buf, count, datatype, source, tag, comm, request );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(irecv);

  return returnVal;
}

/*
    MPI_Irsend - prototyping replacement for MPI_Irsend
    Trace the beginning and ending of MPI_Irsend.
*/
int MPI_Irsend( void *buf, int count, MPI_Datatype datatype, int dest, 
		int tag, MPI_Comm comm, MPI_Request *request )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Irsend( buf, count, datatype, dest, tag, comm, request );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(irsend);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(irsend, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Rsend - prototyping replacement for MPI_Rsend
    Trace the beginning and ending of MPI_Rsend.
*/
int MPI_Rsend( void * buf, int count, MPI_Datatype datatype, int dest,
	       int tag, MPI_Comm comm)
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Rsend( buf, count, datatype, dest, tag, comm );
  endwtime   = MPI_Wtime();	
  UPDATE_COUNTER(rsend);  
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(rsend, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Ssend - prototyping replacement for MPI_Ssend
    Trace the beginning and ending of MPI_Ssend.
*/
int MPI_Ssend( void * buf, int count, MPI_Datatype datatype, int dest,
		int tag, MPI_Comm comm)
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Ssend( buf, count, datatype, dest, tag, comm );
  endwtime   = MPI_Wtime();	
  UPDATE_COUNTER(ssend);  
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(ssend, comm, dest);
  }

  return returnVal;
}
/*
    MPI_Isend - prototyping replacement for MPI_Isend
    Trace the beginning and ending of MPI_Isend.
*/
int MPI_Isend( void *buf, int count, MPI_Datatype datatype, int dest, 
		int tag, MPI_Comm comm, MPI_Request *request )
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Isend( buf, count, datatype, dest, tag, comm, request );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(isend);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(isend, comm, dest);
  }

  return returnVal;
}

/*
    MPI_Issend - prototyping replacement for MPI_Issend
    Trace the beginning and ending of MPI_Issend.
*/
int MPI_Issend( void * buf, int count, MPI_Datatype datatype, 
		 int dest, int tag, MPI_Comm comm, MPI_Request * request)
{
  int    returnVal;
  double startwtime, endwtime;
  int    bin_id;
  int    buf_size;

  buf_size = Get_Msg_size( count, datatype );
  bin_id = Get_Bin_ID(buf_size);

  startwtime = MPI_Wtime();	  
  returnVal = PMPI_Issend( buf, count, datatype, dest, tag, comm, request );
  endwtime   = MPI_Wtime();	  
  UPDATE_COUNTER(issend);
  if (dest != MPI_PROC_NULL) {
      UPDATE_COMM_DESTS(issend, comm, dest);
  }

  return returnVal;
}

/*
 * --------------------------------------------------------------------
 * Here begins the definition of routines that are intercepted to 
 * support other operations (such as the translations to ranks in comm world)
 * --------------------------------------------------------------------
 */
int MPI_Comm_free( MPI_Comm *comm )
{
    if (*comm == comm_cache && comm_cache != MPI_COMM_NULL) {
	/* flush the cache of known communicators */
	if (*comm != MPI_COMM_WORLD && group_cache != MPI_GROUP_NULL) {
	    PMPI_Group_free(&group_cache);
	    group_cache = MPI_GROUP_NULL;
	}
	comm_cache = MPI_COMM_NULL;
    }
    return PMPI_Comm_free( comm );
}
int MPI_Comm_create(MPI_Comm comm, MPI_Group group, MPI_Comm *newcomm)
{
    int    returnVal;
    double startwtime, endwtime;
    double synctime;

    if (fpmpi_ProfControlSync) {
	startwtime = MPI_Wtime();
	PMPI_Barrier( comm );
	synctime = MPI_Wtime() - startwtime;
	comm_create_data.synctime += synctime;
    }
    startwtime = MPI_Wtime();	  
    returnVal = PMPI_Comm_create(comm, group, newcomm);
    endwtime = MPI_Wtime();
    comm_create_data.time += endwtime - startwtime;
    comm_create_data.calls ++;

    return returnVal;
}
int MPI_Comm_dup(MPI_Comm comm, MPI_Comm *newcomm)
{
    int    returnVal;
    double startwtime, endwtime;
    double synctime;

    if (fpmpi_ProfControlSync) {
	startwtime = MPI_Wtime();
	PMPI_Barrier( comm );
	synctime = MPI_Wtime() - startwtime;
	comm_dup_data.synctime += synctime;
    }
    startwtime = MPI_Wtime();	  
    returnVal = PMPI_Comm_dup( comm, newcomm);
    endwtime = MPI_Wtime();
    comm_dup_data.time += endwtime - startwtime;
    comm_dup_data.calls ++;

    return returnVal;
}
int MPI_Comm_split(MPI_Comm comm, int color, int key, MPI_Comm *newcomm)
{
    int    returnVal;
    double startwtime, endwtime;
    double synctime;

    if (fpmpi_ProfControlSync) {
	startwtime = MPI_Wtime();
	PMPI_Barrier( comm );
	synctime = MPI_Wtime() - startwtime;
	comm_split_data.synctime += synctime;
    }
    startwtime = MPI_Wtime();	  
    returnVal = PMPI_Comm_split( comm, color, key, newcomm);
    endwtime = MPI_Wtime();
    comm_split_data.time += endwtime - startwtime;
    comm_split_data.calls ++;

    return returnVal;
}



/* ------------------------------------------------------------------------
 * Here is the definition of MPI_Pcontrol
 *
 * MPI_Pcontrol( flag ) has the following definition
 *  flag has three bits.  The lower (0x1) bit controls the collection
 *  of data. The second (0x2) bit controls the collection of 
 *  time synchronization data for the collective routines
 *  The third (0x4) bit controls the collection of data about destinations.
 * ------------------------------------------------------------------------
 */
int MPI_Pcontrol( const int flag, ... )
{
    va_list ap;
    
    fpmpi_ProfControl      = (flag & FPMPI_PROF_ON);
    fpmpi_ProfControlSync  = (flag & FPMPI_PROF_COLLSYNC) == FPMPI_PROF_COLLSYNC;
    fpmpi_ProfControlDests = (flag & FPMPI_PROF_DESTS) == FPMPI_PROF_DESTS;
    fpmpi_ProfControlWait  = (flag & FPMPI_PROF_WAITTIME) == FPMPI_PROF_WAITTIME;
    /* Use the second argument to set the value of the waittime size */
    if (flag & FPMPI_PROF_WAITTIME_SIZE) {
	va_start( ap, flag );
	fpmpi_ProfControlWaitSize = va_arg( ap, int );
	va_end( ap );
    }
    if (fpmpi_ProfControlWait) testwaitSyncEnabled = 1;
    fpmpi_ProfControlSyncAlt = (flag & FPMPI_PROF_COLLSYNC_ALT) == 
	FPMPI_PROF_COLLSYNC_ALT;
    if ((flag & FPMPI_PROF_DESTVOL) == FPMPI_PROF_DESTVOL)
	fpmpi_ProfControlDestVol = DESTVOL_SUMMARY;
    if ((flag & FPMPI_PROF_DESTVOL_DETAIL) == FPMPI_PROF_DESTVOL_DETAIL)
	fpmpi_ProfControlDestVol = DESTVOL_DETAIL;

    return MPI_SUCCESS;
}

/*
 * --------------------------------------------------------------------
 * Here begins the defintiion of INIT
 * --------------------------------------------------------------------
 */
void fpmpiInitPerformanceCounters(void);
/* Program name */
static char *cmdname = 0;

/* Control the output comments */
static int Verbose = 0;

/* What sort of output will we generate */
typedef enum { OUT_TEXT, OUT_XML, OUT_LATEX } OutputForm;

/* timing.  Do not use clock; the times are not reliable (the definition is
   "processor time used by the process, which is open to interpretation) */
static struct timeval startTime_tv, endTime_tv;

static int fpmpi_Init( int *argc, char ***argv );

/*
    MPI_Init - prototyping replacement for MPI_Init
    Trace the beginning and ending of MPI_Init.

    Environment variables:
    
    FPMPI_PROF_ON
    FPMPI_PROF_COLLSYNC
    FPMPI_PROF_WAITTIME
    FPMPI_PROF_WAITTIME_SYNC
    FPMPI_PROF_DESTS
    FPMPI_PROF_DESTVOL
    FPMPI_PROF_DESTVOL_DETAIL
    FPMPI_PROF_DEBUG

    Values should be either YES or NO (case is important).

    FPMPI_PROF_WAITTIME_SIZE (integer, only collect waittime for message
                              longer than this)
    FPMPI_PROF_DESTVOL_OUTPUT (BYROW, or COO)

*/
static int fpmpi_Init( int *argc, char ***argv ) 
{
    int llrank, size;
    const char *s;
    int profFlags[8];

    if (argv && *argv) cmdname = (*argv)[0];

    PMPI_Comm_rank( MPI_COMM_WORLD, &llrank );
    PMPI_Comm_size( MPI_COMM_WORLD, &size );

    /* Get the group of comm world so that we can translate ranks in other
       communicators */
    PMPI_Comm_group( MPI_COMM_WORLD, &group_world );
    
    if (llrank == 0) {
	int foundVal;
	CheckEnvBool( "FPMPI_PROF", &fpmpi_ProfControl );
	CheckEnvBool( "FPMPI_PROF_COLLSYNC", &fpmpi_ProfControlSync );
	CheckEnvBool( "FPMPI_PROF_DESTS", &fpmpi_ProfControlDests );
	CheckEnvBool( "FPMPI_PROF_DESTVOL", &fpmpi_ProfControlDestVol );
	/* Special case: the destination volume (DESTVOL) has two options:
	   a simple, aggregated value, and a detailed (per routine) 
	   choice. */
	foundVal = 0;
	if (foundVal) 
	    fpmpi_ProfControlDestVol = DESTVOL_DETAIL;

	CheckEnvBool( "FPMPI_PROF_WAITTIME", &fpmpi_ProfControlWait );
	s = getenv( "FPMPI_PROF_WAITTIME_SIZE" );
	if (s) {
	    fpmpi_ProfControlWaitSize = strtol( s, NULL, 10 );
	    /* If the value is 0, we'll ignore it anyway */
	}
	CheckEnvBool( "FPMPI_PROF_COLLSYNC_ALT", &fpmpi_ProfControlSyncAlt );
	CheckEnvBool( "FPMPI_PROF_DEBUG", &fpmpi_ProfControlDebug );

	s = getenv( "FPMPI_PROF_DESTVOL_OUTPUT" );
	if (s) {
	    /* Note this value is only used on rank 0, so we do not need
	       to communicate it to other processes */
	    if (strcmp( s, "COO" ) == 0 || strcmp( s, "coo" ) == 0) {
		destvolOutputFormat = DESTVOL_OUT_COO;
	    }
	    else if (strcmp( s, "BYROW" ) == 0 ||
		    strcmp( s, "byrow" ) == 0) {
		destvolOutputFormat = DESTVOL_OUT_BYROW;
	    }
	    else {
		fprintf( stderr, 
"Unrecognized value for FPMPI_PROF_DESTVOL_OUTPUT of %s, expected BYROW or COO\n", s );
	    }
	}

	/* Get the settings for the logging controls from the environment on 
	   process zero. */
	profFlags[0] = fpmpi_ProfControl;
	profFlags[1] = fpmpi_ProfControlSync;
	profFlags[2] = fpmpi_ProfControlDests;
	profFlags[3] = fpmpi_ProfControlWait;
	profFlags[4] = fpmpi_ProfControlWaitSize;
	profFlags[5] = fpmpi_ProfControlSyncAlt;
	profFlags[6] = fpmpi_ProfControlDebug;
	profFlags[7] = fpmpi_ProfControlDestVol;
    }

    PMPI_Bcast( profFlags, 8, MPI_INT, 0, MPI_COMM_WORLD );
    if (llrank != 0) {
	fpmpi_ProfControl         = profFlags[0];
	fpmpi_ProfControlSync     = profFlags[1];
	fpmpi_ProfControlDests    = profFlags[2];
	fpmpi_ProfControlWait     = profFlags[3];
	fpmpi_ProfControlWaitSize = profFlags[4];
	fpmpi_ProfControlSyncAlt  = profFlags[5];
	fpmpi_ProfControlDebug    = profFlags[6];
	fpmpi_ProfControlDestVol  = profFlags[7];
    }

    fpmpiInitPerformanceCounters();
    
    fpmpi_TestWaitInit( testwaitInfo );
    if (fpmpi_ProfControlWait) testwaitSyncEnabled = 1;

    /* Turn on the collecting-sync-flag for the alternate collectives */
    if (fpmpi_ProfControlSyncAlt) {
	int i;
	for (i=0; collectiveInfo[i].name; i++) 
	    collectiveInfo[i].hasSyncTime = 1;
    }
    if (fpmpi_ProfControlDestVol == DESTVOL_DETAIL) {
	int       i;
	msgsize_t *dp;
	/* We can use a single array for all routines as an option to
	   reduce memory use (could do that for the bitvec as well) */
	for (i=0; pt2ptInfo[i].name; i++) {
	    dp = (msgsize_t *)calloc( size, sizeof(msgsize_t) );
	    if (!dp) {
		fprintf( stderr, 
		"Unable to allocate %ld bytes for message volume information\n", 
			 (long)size*sizeof(msgsize_t) );
		PMPI_Abort( MPI_COMM_WORLD, 1 );
	    }
	    pt2ptInfo[i].data->sizeToPartner = dp;
	}
    }
    else if (fpmpi_ProfControlDestVol == DESTVOL_SUMMARY) {
	int       i;
	msgsize_t *dp;
	dp = (msgsize_t *)calloc( size, sizeof(msgsize_t) );
	if (!dp) {
	    fprintf( stderr, 
	      "Unable to allocate %ld bytes for message volume information\n", 
			 (long)size*sizeof(msgsize_t) );
	    PMPI_Abort( MPI_COMM_WORLD, 1 );
	}
	/* Use a single array for all routines */
	for (i=0; pt2ptInfo[i].name; i++) {
	    pt2ptInfo[i].data->sizeToPartner = dp;
	}
    }

    /* Consistency check */
    if (size > MAX_PROCS) {
	/* Disable all partner data collection. Warn if collection was
	   requested */
	if (fpmpi_ProfControlDests || fpmpi_ProfControlDestVol) {
	    if (llrank == 0) 
		fprintf( stderr, 
"Size of MPI_COMM_WORLD = %d is largner than MAX_PROCS (=%d) in fpmpi2\n\
Collection of destination infomration is disabled; reconfigure and rebuild\n\
fpmpi2 with a larger --with-max_procs value if desired\n", size, MAX_PROCS );
	    fpmpi_ProfControlDests   = 0;
	    fpmpi_ProfControlDestVol = 0;
	}
    }

    return 0;
}

int MPI_Init( int *argc, char ***argv )
{
  int returnVal;

  gettimeofday( &startTime_tv, NULL );
  
  returnVal = PMPI_Init( argc, argv );

  fpmpi_Init( argc, argv );

  return returnVal;
}
#ifdef HAVE_MPI_INIT_THREAD
int MPI_Init_thread( int *argc, char ***argv, int requested, int *provided )
{
    int returnVal;

    returnVal = PMPI_Init_thread( argc, argv, requested, provided );

    fpmpi_Init( argc, argv );

    return returnVal;
}
#endif

/*
 * --------------------------------------------------------------------
 * Here begins the defintiion of FINALIZE
 * --------------------------------------------------------------------
 */
/*
    MPI_Finalize - prototyping replacement for MPI_Finalize
    Trace the beginning and ending of MPI_Finalize.

    FIXME: This should call a separate routine which would do the actual
    output.  That routine could then be called by the user to flush the
    state, and it should be collective over MPI_COMM_WORLD.
*/
int MPI_Finalize( void )
{
  int returnVal;
  int llrank, nprocs;
  FILE *pf;

  gettimeofday( &endTime_tv, NULL );

  PMPI_Comm_rank( MPI_COMM_WORLD, &llrank );
  PMPI_Comm_size( MPI_COMM_WORLD, &nprocs );

  /* Gather all of the data to process 0 and perform the various 
     data accumulations */
  AccumulateData( llrank, nprocs );

  pf = OutputOpenFile( llrank );

  OutputHeader( pf, llrank );
  OutputProgramDescription( pf, llrank, nprocs );
  OutputResourceUsage( pf, llrank, nprocs );

  (void)PMPI_Barrier( MPI_COMM_WORLD );

  if (llrank == 0) {
      PrintAverageData( pf, nprocs );
      PrintDetailedData( pf, nprocs );
  }
  fpmpi_Output_DupSplit( pf, llrank );

  (void)PMPI_Barrier( MPI_COMM_WORLD );
  PrintDetailedPartners( pf, llrank, nprocs );

  /* Performance counter data, if any (no output if no performance
     counters available) */
  fpmpiOutputPerformanceCounters( pf, llrank, nprocs );

  /* Output fpmpi statistics if requested */
  if (fpmpi_ProfControlDebug) {
      printf( "FPMPI2 Internal Counters\n" );
      printf( "Group cache misses = %d\n", groupCacheMiss );
  }

  OutputTail( pf, llrank );

  /* Free allocated memory */
  if (fpmpi_ProfControlDestVol == DESTVOL_DETAIL) {
      int       i;
      /* We can use a single array for all routines as an option to
	 reduce memory use (could do that for the bitvec as well) */
      for (i=0; pt2ptInfo[i].name; i++) {
	  free( pt2ptInfo[i].data->sizeToPartner );
      }
  }
  else if (fpmpi_ProfControlDestVol == DESTVOL_SUMMARY) {
      /* A single array is shared by all routines, so just free the first one */
      free( pt2ptInfo[0].data->sizeToPartner );
  }

  returnVal = PMPI_Finalize();
  return returnVal;
}

/*
 * --------------------------------------------------------------------
 * Here begins the output routines
 * --------------------------------------------------------------------
 */
/* Printout the data for one communication item, based on the 
   data in cd and timesync 
   
   Given the data, compute the max, min, and average over all processes.

*/
void CBCombineMax( void *, void *, int *, MPI_Datatype * );
void CBCombineMin( void *, void *, int *, MPI_Datatype * );
void CBCombineSum( void *, void *, int *, MPI_Datatype * );

void CBCombineMax( void *cptrin, void *cptrout, 
		   int *count, MPI_Datatype *dtype )
{
  int i, n = *count;
  CommBinData *cin = (CommBinData *)cptrin;
  CommBinData *cout = (CommBinData *)cptrout;
  for (i=0; i<n; i++) {
    if (cout[i].size < cin[i].size)
      cout[i].size = cin[i].size;
    if (cout[i].time < cin[i].time)
      cout[i].time = cin[i].time;
    if (cout[i].synctime < cin[i].synctime)
      cout[i].synctime = cin[i].synctime;
    if (cout[i].calls < cin[i].calls)
      cout[i].calls = cin[i].calls;
  }
}
/* For the min, we may want to ignore min values that have no
   associated calls */
/* Question: do we want to know if ANYONE had zero calls? */
void CBCombineMin( void *cptrin, void *cptrout,
		   int *count, MPI_Datatype *dtype )
{
    int i, n = *count;
    CommBinData *cin = (CommBinData *)cptrin;
    CommBinData *cout = (CommBinData *)cptrout;
    for (i=0; i<n; i++) {
	if (cout[i].calls == 0) {
	    /* just copy input*/
	    cout[i].calls = cin[i].calls;
	    cout[i].size  = cin[i].size;
	    cout[i].time  = cin[i].time;
	    cout[i].synctime  = cin[i].synctime;
	}
	else {
	    /* Only update if cin had some calls */
	    if (cin[i].calls > 0) {
		if (cout[i].size > cin[i].size)
		    cout[i].size = cin[i].size;
		if (cout[i].time > cin[i].time)
		    cout[i].time = cin[i].time;
		if (cout[i].synctime > cin[i].synctime)
		    cout[i].synctime = cin[i].synctime;
		if (cout[i].calls > cin[i].calls)
		    cout[i].calls = cin[i].calls;
	    }
	}
    }
}

void CBCombineSum( void *cptrin, void *cptrout, 
		   int *count, MPI_Datatype *dtype )
{
  int i, n = *count;
  CommBinData *cin = (CommBinData *)cptrin;
  CommBinData *cout = (CommBinData *)cptrout;
  for (i=0; i<n; i++) {
    cout[i].size += cin[i].size;
    cout[i].time += cin[i].time;
    cout[i].synctime += cin[i].synctime;
    cout[i].calls += cin[i].calls;
  }
}

static MPI_Datatype getSummaryDatatype( void );

/*
 * ----------------------------------------------------------------------
 * The following code provides access to hardware counters
 * ----------------------------------------------------------------------
 */
/* ----------------------------------------------------------------------
 * Output Usage Information
 * ------------------------------------------------------------------------ */
void OutputResourceUsage( FILE *pf, int llrank, int nprocs )
{
    int rc, rcout;
    int max_wall_clock_rank, min_wall_clock_rank;
    double wall_clock_t;
    double max_wall_clock_t, min_wall_clock_t;
    double t_tmp;
    ProgramResourceUsage usage;

    rc = fpmpi_GetResourceUsage( &usage, llrank );
    if (rc != 0) rc = 1;
    PMPI_Allreduce( &rc, &rcout, 1, MPI_INT, MPI_MAX, MPI_COMM_WORLD );

    wall_clock_t = endTime_tv.tv_sec - startTime_tv.tv_sec;
    wall_clock_t += 1.0e-6 * (endTime_tv.tv_usec - startTime_tv.tv_usec);
    t_tmp = wall_clock_t;

    fpmpi_getrange_double_single( t_tmp,
				  &max_wall_clock_t, &max_wall_clock_rank, 
				  &min_wall_clock_t, &min_wall_clock_rank,
				  &wall_clock_t );
    wall_clock_t /= nprocs;
    
    if (llrank == 0) {
	fprintf( pf, "Execute time:\t%.4g\n", wall_clock_t );
	fprintf(pf, "Timing Stats: [seconds]\t[min/max]    \t[min rank/max rank]\n");
	fprintf(pf, "  wall-clock: %.4g sec\t%f / %f\t%d / %d\n",
		wall_clock_t, min_wall_clock_t, max_wall_clock_t,
		min_wall_clock_rank, max_wall_clock_rank);
    }

    /* Only perform these additional checks if all processes succeeded in
       acquiring the resource data */
    if (rcout == 0) {
	if ( (usage.validFields & (FPMPI_PRU_USER_TIME | FPMPI_PRU_SYS_TIME)) == 
	     (FPMPI_PRU_USER_TIME | FPMPI_PRU_SYS_TIME) ) {
	    double sys_t=0.0;
	    double max_sys_t, min_sys_t;
	    int max_sys_rank, min_sys_rank;
	    double user_t=0.0;
	    double max_user_t, min_user_t;
	    int max_user_rank, min_user_rank;
	    
	    t_tmp = usage.userTime;
	    fpmpi_getrange_double_single( t_tmp, 
					  &max_user_t, &max_user_rank,
					  &min_user_t, &min_user_rank,
					  &user_t );
	    user_t       /= nprocs;
	    t_tmp = usage.systemTime;
	    fpmpi_getrange_double_single( t_tmp,
					  &max_sys_t, &max_sys_rank,
					  &min_sys_t, &min_sys_rank,
					  &sys_t );
	    sys_t	       /= nprocs;
	    
	    if (llrank == 0) {
		fprintf(pf, "        user: %.4g sec\t%f / %f\t%d / %d\n",
			user_t, min_user_t, max_user_t, min_user_rank, max_user_rank);
		fprintf(pf, "         sys: %.4g sec\t%f / %f\t%d / %d\n",
			sys_t, min_sys_t, max_sys_t, min_sys_rank, max_sys_rank);
	    }
	}
	
	if (usage.validFields & FPMPI_PRU_RSS) {
	    long maxrss, maxrss_all, minrss_all;
	    
	    maxrss = usage.residentSetSize;
	    PMPI_Reduce( &maxrss, &maxrss_all, 1, MPI_LONG, MPI_MAX, 0, MPI_COMM_WORLD);
	    PMPI_Reduce( &maxrss, &minrss_all, 1, MPI_LONG, MPI_MIN, 0, MPI_COMM_WORLD);
	    if (llrank == 0) {
		fprintf(pf, "\n");
		fprintf(pf, "Memory Usage Stats (RSS) [min/max KB]:\t%ld/%ld\n",
			minrss_all, maxrss_all);
	    }  
	}
    }
    
    if (llrank == 0) {
	fprintf( pf, "\n" );
    }

}

/*
 * Output the description of the FPMPI output format
 */
void OutputHeader( FILE *pf, int llrank )
{
  if ( llrank == 0 ) {
      fprintf(pf, "MPI Routine Statistics (FPMPI2 Version %s)\n", FPMPI2_VERSION );
      fprintf(pf, "Options: " );
      if (fpmpi_ProfControl)         fprintf( pf, "FPMPI enabled, " );
      if (fpmpi_ProfControlSync)     fprintf( pf, "Collective sync, " );
      if (fpmpi_ProfControlDests)    fprintf( pf, "Collect destinations, " );
      if (fpmpi_ProfControlWait)     
	  fprintf( pf, "pt-to-pt sync for size>%d", fpmpi_ProfControlWaitSize );
      fprintf( pf, "\n" );

      /* Set the environment variable FPMPI_NO_HEADER to suppress this
	 header message */
      if (!getenv("FPMPI_NO_HEADER")) {
	fprintf( pf, "Explanation of data:\n\
Times are the time to perform the operation, e.g., the time for MPI_Send\n\
Average times are the average over all processes, e.g., sum (time on each\n\
process) / number of processes\n\
Min and max values are over all processes\n\
(Data is always average/min/max)\n\
Amount of data is computed in bytes.  For point-to-point operations,\n\
it is the data sent or received.  For collective operations, it is the\n\
data contibuted to the operation.  E.g., for an MPI_Bcast, the amount of\n\
data is the number of bytes provided by the root, counted only at the root.\n\
For synchronizing collective operations, the average, min, and max time\n\
spent synchronizing is shown next.\n\
Calls by message size shows the fraction of calls that sent messages of a \n\
particular size.  The bins are\n\
0 bytes, 1-4 bytes, 5-8 bytes, 9-16, 17-32, 33-64, -128, -256, -512, -1024\n\
 -4K, -8K, -16K, -32K, -64K, -128K, -256K, -512K, -1M, -4M, -8M, -16M, \n\
 -32M, -64M, -128M, -256M, -512M, -1GB, >1GB.\n\
Each bin is represented by a single digit, representing the 10's of percent\n\
of messages within this bin.  A 0 represents precisely 0, a . (period) \n\
represents more than 0 but less than 10%%.  A * represents 100%%.\n\
Messages by message size shows similar information, but for the total\n\
message size.\n\
\n\
The experimental topology information shows the 1-norm distance that the\n\
longest point-to-point message travelled, by process.\n\
\n\
MPI_Pcontrol may be used to control the collection of data.  Use the values\n\
defined in fpmpi.h, such as FPMPI_PROF_COLLSYNC, to control what data is \n\
collected or reported by FPMPI2.\n" );
      }
  }
}

void  OutputTail( FILE *pf, int llrank )
{
  if ( llrank == 0 ) {
    fclose(pf);
  }
}

void  OutputProgramDescription( FILE *pf, 
				int llrank, int nprocs )
{
    if ( llrank == 0 ) {
	if (cmdname) {
	    fprintf( pf, "Command: %s\n", cmdname );
	}
	
	{
	    time_t t;
	    char *c;
	    int  clen;
	    t = time(NULL);
	    c = asctime(localtime(&t));
	    /* Remove any trailing newline on c */
	    clen = strlen( c );
	    if (c[clen-1] == '\n') c[clen-1] = 0;
	    fprintf(pf,"\n");
	    fprintf(pf,"Date:     \t%s\n", c );
	    fprintf(pf,"Processes:\t%d\n", nprocs);
	}
	
    }
    
}

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif
/* 
 * The output filename can be controlled with environment variables:
 *
 */
FILE *OutputOpenFile( int llrank )
{
    FILE *pf = 0;
    char profname[MAXPATHLEN];
    char *ext="txt";
    const char *pname;

    if ( llrank == 0 ) {
	/* keep trying to find a filename until we succeed */
	pname = getenv("FPMPI_FILENAME");
	/* Backwards compatibility */
	if (!pname) 
	    pname = getenv("MPI_PROFILE_FILE_NAME");
	if (!pname) {
	    /* Create the filename from a pattern, using %E (other
	       escapes may be added later, such as %T for Unix Time (seconds
	       since Unix Epoch began) */
	    const char *pattern = getenv("FPMPI_FILENAME_PATTERN");
	    if (pattern) {
		char *pOut = profname;
		const char *pIn = pattern;
		while (*pIn && (pOut - profname) < MAXPATHLEN) {
		    if (*pIn == '%') {
			/* Replace %E with the name of the executable */
			if (pIn[1] == 'E') {
			    char *cmd = cmdname;
			    if (!cmd) {
				cmd = "Unknown";
			    }
			    while (*cmd && (pOut - profname) < MAXPATHLEN) {
				*pOut++ = *cmd++;
			    }
			}
			else {
			    /* Escape and use the last character */
			    *pOut++ = pIn[1];
			}
			pIn += 2;
		    }
		    else {
			*pOut++ = *pIn++;
		    }
		}
		pname = profname;
	    }
	}
	if (!pname) {
	    ext = "txt";
	    sprintf(profname,"%s.%s", MPI_PROF_FILE_NAME,ext);
	    if (getenv("MPI_PROFILE_DIR") != NULL)
		sprintf(profname, "%s/fpmpi_output.%s", 
			getenv("MPI_PROFILE_DIR"),ext);
	    pname = (const char *)profname;
	}
	
	if (Verbose) 
	    printf("Profile will be saved in %s.\n", pname);
	pf = fopen( pname, "w" );
	if (!pf) {
	    fprintf( stderr, "Could not open %s\n", pname );
	    perror( "Reason: " );
	}
    }
    return pf;
}

void  PrintDetailedPartners( FILE *pf, int llrank, int nprocs )
{
    fpmpiOutputPartnerTopology( allPartners, pf, llrank );
    fpmpiOutputDetailedPartners( allPartners, pf, llrank );
    fpmpiOutputDetailedDataVol( pf, llrank );
}

/*
 * --------------------------------------------------------------------
 * For each of the arrays of data, get the min, max, and sums
 * --------------------------------------------------------------------
 */
static int AccumulateData( int llrank, int nprocs )
{
    int i;

    for (i=0; allCollectiveInfo[i].name; i++) {
	getSummaryCommData( &allCollectiveInfo[i], llrank );
    }

    for (i=0; collectiveInfo[i].name; i++) {
	getSummaryCommData( &collectiveInfo[i], llrank );
    }

    for (i=0; pt2ptInfo[i].name; i++) {
	int j;
	getSummaryCommData( &pt2ptInfo[i], llrank );
	getSummaryPartnerData( &pt2ptInfo[i], nprocs );
	for (j=0; j<MAX_PROCBY32; j++) 
	    allPartners[j] |= pt2ptInfo[i].data->partners[j];
    }
    

    for (i=0; packInfo[i].name; i++) {
	getSummaryCommData( &packInfo[i], llrank );
    }
    
    for (i=0; probeInfo[i].name; i++) {
	getSummaryNoCommData( &probeInfo[i], llrank );
    }
    for (i=0; testwaitInfo[i].name; i++) {
	getSummaryNoCommData( &testwaitInfo[i], llrank );
    }
    getSummaryNoCommData( &barrierInfo, llrank );

    for (i=0; commInfo[i].name; i++) {
	getSummaryNoCommData( &commInfo[i], llrank );
    }
    
    return 0;
}

/* Print the most useful data */
static int PrintAverageData( FILE *fp, int nprocs )
{
    int i;
    char binString[NBINS+1];

    fprintf( fp, "\
                  Average of sums over all processes\n\
Routine                 Calls       Time Msg Length    %%Time by message length\n\
                                                    0.........1........1........\n\
                                                              K        M\n"
	);

    for (i=0; allCollectiveInfo[i].name; i++) {
	if (allCollectiveInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g %10.3g", 
		     allCollectiveInfo[i].name,
		     allCollectiveInfo[i].totalCalls / nprocs,
		     allCollectiveInfo[i].totalTime / nprocs, 
		     (double)(allCollectiveInfo[i].totalSize)  / nprocs );
	    TimeBinsToString( allCollectiveInfo[i].sumData.b, NBINS, 28,
			      binString );
	    fprintf( fp, " %s\n", binString );
	}
    }

    for (i=0; collectiveInfo[i].name; i++) {
	if (collectiveInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g %10.3g", 
		     collectiveInfo[i].name,
		     collectiveInfo[i].totalCalls / nprocs,
		     collectiveInfo[i].totalTime / nprocs, 
		     ((double)collectiveInfo[i].totalSize) / nprocs );
	    TimeBinsToString( collectiveInfo[i].sumData.b, NBINS, 28,
			      binString );
	    fprintf( fp, " %s\n", binString );
	}
    }

    for (i=0; pt2ptInfo[i].name; i++) {
	if (pt2ptInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g %10.3g", 
		     pt2ptInfo[i].name,
		     pt2ptInfo[i].totalCalls / nprocs,
		     pt2ptInfo[i].totalTime / nprocs, 
		     ((double)pt2ptInfo[i].totalSize) / nprocs );
	    TimeBinsToString( pt2ptInfo[i].sumData.b, NBINS, 28,
			      binString );
	    fprintf( fp, " %s\n", binString );
	}
    }

    for (i=0; packInfo[i].name; i++) {
	if (packInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g %10.3g", 
		     packInfo[i].name,
		     packInfo[i].totalCalls / nprocs,
		     packInfo[i].totalTime / nprocs, 
		     ((double)packInfo[i].totalSize) / nprocs );
	    TimeBinsToString( packInfo[i].sumData.b, NBINS, 28,
			      binString );
	    fprintf( fp, " %s\n", binString );
	}
    }
    
    for (i=0; probeInfo[i].name; i++) {
	if (probeInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g\n", 
		     probeInfo[i].name,
		     probeInfo[i].totalCalls / nprocs,
		     probeInfo[i].totalTime / nprocs );
	}
    }
    /* Fixme; like the allcollective data, include the 
       sync time.  For that, we need to perform more processing 
       on the data before we enter this routine */
    for (i=0; testwaitInfo[i].name; i++) {
	if (testwaitInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g\n", 
		     testwaitInfo[i].name,
		     testwaitInfo[i].totalCalls / nprocs,
		     testwaitInfo[i].totalTime / nprocs );
	}
    }

    if (barrierInfo.totalCalls > 0) {
	fprintf( fp, "MPI_%-16.16s:%8d %10.3g\n", 
		 barrierInfo.name,
		 barrierInfo.totalCalls / nprocs,
		 barrierInfo.totalTime / nprocs );
    }

    for (i=0; commInfo[i].name; i++) {
	if (commInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%-16.16s:%8d %10.3g\n", 
		     commInfo[i].name,
		     commInfo[i].totalCalls / nprocs,
		     commInfo[i].totalTime / nprocs );
	}
    }
    
    return 0;
}

static int PrintDetailedDataForComm( FILE *, CallData *, int );

static int PrintDetailedDataForComm( FILE *fp, CallData *cd, int nprocs )
{
    char binString[NBINS+1];

    fprintf( fp, "MPI_%s:\n", cd->name );
    fprintf( fp, "\tCalls     : %10d   %10d [%4d]", 
	     cd->totalCalls / nprocs, cd->maxCalls, cd->maxCallsLoc );
    CallsBinsToString( cd->sumData.b, NBINS, 28, binString );
    fprintf( fp, " %s\n", binString );
    
    fprintf( fp, "\tTime      : %10.3g   %10.3g [%4d]", 
	     cd->totalTime / nprocs, cd->maxTime, cd->maxTimeLoc );
    TimeBinsToString( cd->sumData.b, NBINS, 28, binString );
    fprintf( fp, " %s\n", binString );

    fprintf( fp, "\tData Sent : %10.3g %12ld [%4d]\n", 
	     ((double)cd->totalSize) / nprocs, (long)cd->maxSize,
	     cd->maxSizeLoc );
    
    /* If no routine ever waited, then skip the wait/sync time */
    if (cd->hasSyncTime) {
	if (cd->totalSync > 0) {
	    fprintf( fp, "\tSyncTime  : %10.3g   %10.3g [%4d]", 
		     cd->totalSync / nprocs, cd->maxSync, cd->maxSyncLoc );
	    SyncBinsToString( cd->sumData.b, NBINS, 28, binString );
	    fprintf( fp, " %s\n", binString );
	}
	else { 
	    fprintf( fp, "\tSyncTime  : 0\n" );
	}
    }
    
    if (1 && cd->totalCalls > 0) {
	int i;
	char *header = "By bin    ";
	/* For each bin with data, print the [min,max] of calls, time,
	   and synctime */
	for (i=0; i<NBINS; i++) {
	    if (cd->maxData.b[i].calls > 0) {
		int minbin = (i>0) ? maxBinSize[i-1]+1:0;
		int maxbin = maxBinSize[i];
		
		fprintf( fp, "\t%s: %d-%d\t[%d,%d]\t[%10.3g,%10.3g]", 
			 header, minbin, maxbin,
			 cd->minData.b[i].calls, cd->maxData.b[i].calls,
			 cd->minData.b[i].time, cd->maxData.b[i].time );
		if (cd->hasSyncTime && cd->totalSync > 0) {
		    fprintf( fp, "\t[%10.3g,%10.3g]",
			     cd->minData.b[i].synctime, 
			     cd->maxData.b[i].synctime );
		}
		fprintf( fp, "\n" );
		header = "          ";
	    }
	}
    }

    return 0;
}
static int PrintDetailedPartnerInfo( FILE *, CallData *, int );
static int PrintDetailedPartnerInfo( FILE *fp, CallData *cd, int nprocs )
{
    if (cd->totalPartners > 0) {
	fprintf( fp, "\tPartners  : %10.3g max %d(at %d) min %d(at %d)\n",
		 (double)cd->totalPartners / nprocs, 
		 cd->maxPartners, cd->maxPartnersLoc, cd->minPartners, 
		 cd->minPartnersLoc );
    }

    return 0;
}
static int PrintDetailedData( FILE *fp, int nprocs )
{
    int i;

    fprintf( fp, "\nDetails for each MPI routine\n\
                  Average of sums over all processes\n\
                                                   %% by message length\n\
                                (max over          0.........1........1........\n\
                                 processes [rank])           K        M\n"
	);

    for (i=0; allCollectiveInfo[i].name; i++) {
	if (allCollectiveInfo[i].totalCalls > 0) {
	    PrintDetailedDataForComm( fp, &allCollectiveInfo[i], nprocs );
	}
    }

    for (i=0; collectiveInfo[i].name; i++) {
	if (collectiveInfo[i].totalCalls > 0) {
	    PrintDetailedDataForComm( fp, &collectiveInfo[i], nprocs );
	}
    }

    for (i=0; pt2ptInfo[i].name; i++) {
	if (pt2ptInfo[i].totalCalls > 0) {
	    PrintDetailedDataForComm( fp, &pt2ptInfo[i], nprocs );
	    PrintDetailedPartnerInfo( fp, &pt2ptInfo[i], nprocs );
	}
    }

    for (i=0; packInfo[i].name; i++) {
	if (packInfo[i].totalCalls > 0) {
	    PrintDetailedDataForComm( fp, &packInfo[i], nprocs );
	}
    }
    
    for (i=0; probeInfo[i].name; i++) {
	if (probeInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%s:\n\tCalls     : %10d\n\tTime      : %10.3g\n",
		     probeInfo[i].name,
		     probeInfo[i].totalCalls / nprocs,
		     probeInfo[i].totalTime / nprocs );	
	    if (probeInfo[i].hasSyncTime) {
		fprintf( fp, "\tSyncTime  : %10.3g\n", 
			 probeInfo[i].totalSync / nprocs );
	    }
	}
    }

    for (i=0; testwaitInfo[i].name; i++) {
	if (testwaitInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%s:\n\tCalls     : %10d\n\tTime      : %10.3g\n",
		     testwaitInfo[i].name,
		     testwaitInfo[i].totalCalls / nprocs,
		     testwaitInfo[i].totalTime / nprocs );	
	    if (testwaitSyncEnabled && testwaitInfo[i].hasSyncTime) {
		fprintf( fp, "\tSyncTime  : %10.3g\n", 
			 testwaitInfo[i].totalSync / nprocs );
	    }
	}
    }
    
    if (barrierInfo.totalCalls > 0) {
	fprintf( fp, "MPI_%s:\n\tCalls     : %10d\n\tTime      : %10.3g\n",
		 barrierInfo.name,
		 barrierInfo.totalCalls / nprocs,
		 barrierInfo.totalTime / nprocs );	
    }

    for (i=0; commInfo[i].name; i++) {
	if (commInfo[i].totalCalls > 0) {
	    fprintf( fp, "MPI_%s:\n\tCalls     : %10d\n\tTime      : %10.3g\n",
		     commInfo[i].name,
		     commInfo[i].totalCalls / nprocs,
		     commInfo[i].totalTime / nprocs );	
	    if (commInfo[i].hasSyncTime) {
		fprintf( fp, "\tSyncTime  : %10.3g\n", 
			 commInfo[i].totalSync / nprocs );
	    }
	}
    }
    
    /*    PrintAverageWaitTestData( llrank ); */
    return 0;
}

/* 
 * Get the overall summary data
 */
static int getSummaryNoCommData( CallBasicData *cd, int llrank )
{
    PMPI_Reduce( &cd->data->time, &cd->totalTime, 2, MPI_DOUBLE, MPI_SUM, 0,
		 MPI_COMM_WORLD );
    PMPI_Reduce( &cd->data->calls, &cd->totalCalls, 1, MPI_INT, MPI_SUM, 0,
		 MPI_COMM_WORLD );

    return 0;
}

static int getSummaryCommData( CallData *cd, int llrank )
{
    int i;
    static MPI_Datatype cbtype = MPI_DATATYPE_NULL;
    static MPI_Op cb_max, cb_min, cb_sum;
    struct { double var; int loc; } stime, smaxtime, 
					sdata, smaxdata, ssync, smaxsync;
    struct { int var; int loc; } scalls, smaxcalls;
    
    if (cbtype == MPI_DATATYPE_NULL) {
	cbtype = getSummaryDatatype();
	
	PMPI_Op_create( CBCombineMax, 1, &cb_max );
	PMPI_Op_create( CBCombineMin, 1, &cb_min );
	PMPI_Op_create( CBCombineSum, 1, &cb_sum );
    }

    PMPI_Reduce( cd->data->b, cd->sumData.b, NBINS, cbtype, cb_sum, 0, 
		 MPI_COMM_WORLD );
    PMPI_Reduce( cd->data->b, cd->maxData.b, NBINS, cbtype, cb_max, 0, 
		 MPI_COMM_WORLD );
    PMPI_Reduce( cd->data->b, cd->minData.b, NBINS, cbtype, cb_min, 0, 
		 MPI_COMM_WORLD );
    
    if (llrank == 0) {
	for (i=0; i<NBINS; i++) {
	    cd->totalTime  += cd->sumData.b[i].time;
	    cd->totalCalls += cd->sumData.b[i].calls;
	    cd->totalSync  += cd->sumData.b[i].synctime;
	    cd->totalSize  += cd->sumData.b[i].size;
	}
    }

    /* Get overall data (by combining the per-bin data).  We do this to 
       get the MAX over processes */
    stime.var = 0;
    stime.loc = llrank;
    scalls.var = 0;
    scalls.loc = llrank;
    sdata.var = 0;
    sdata.loc = llrank;
    ssync.var = 0;
    ssync.loc = llrank;
    for (i=0; i<NBINS; i++) {
	stime.var  += cd->data->b[i].time;
	scalls.var += cd->data->b[i].calls;
	sdata.var  += cd->data->b[i].size;
	ssync.var  += cd->data->b[i].synctime;
    }
    PMPI_Reduce( &stime, &smaxtime, 1, MPI_DOUBLE_INT,
		 MPI_MAXLOC, 0, MPI_COMM_WORLD );
    PMPI_Reduce( &scalls, &smaxcalls, 1, MPI_2INT, 
		 MPI_MAXLOC, 0, MPI_COMM_WORLD );
    PMPI_Reduce( &sdata, &smaxdata, 1, MPI_DOUBLE_INT,
		 MPI_MAXLOC, 0, MPI_COMM_WORLD );
    PMPI_Reduce( &ssync, &smaxsync, 1, MPI_DOUBLE_INT,
		 MPI_MAXLOC, 0, MPI_COMM_WORLD );

    if (llrank == 0) {
	cd->maxTime     = smaxtime.var;
	cd->maxCalls    = smaxcalls.var;
	cd->maxSize     = smaxdata.var;
	cd->maxSync     = smaxsync.var;
	cd->maxTimeLoc  = smaxtime.loc;
	cd->maxCallsLoc = smaxcalls.loc;
	cd->maxSizeLoc  = smaxdata.loc;
	cd->maxSyncLoc  = smaxsync.loc;
    }
    return 0;
}

static int getSummaryPartnerData( CallData *cd, int nprocs )
{
    int32_t *partners = cd->data->partners;
    int     i, j, totpartners;
    unsigned int mask;

    totpartners = 0;
    /* Find the number of set bits */
    for (i=0; i<MAX_PROCBY32; i++) {
	mask = 1;
	for (j=0; j<32; j++) {
	    if (partners[i] & mask) totpartners++;
	    mask <<= 1;
	}
    }
    fpmpi_getrange_int_single( totpartners, 
			       &cd->maxPartners, &cd->maxPartnersLoc,
			       &cd->minPartners, &cd->minPartnersLoc, 
			       &cd->totalPartners );
    return 0;
}

static MPI_Datatype getSummaryDatatype( void )
{
    MPI_Datatype din[4], cb_dtype;
    MPI_Aint displs[4];
    int blk[4], i;
    CommBinData cbMax[2];    /* Used to create the datatype */

    /* If the size of long-long is at least 8, we use it for the sizes; else,
       we use a double.  The values that we use are totalTime, totalSync, size,
       calls.  We use an MPI_UB instead of MPI_Type_create_resized for portability
       with MPI-1 implementations.  And we use an array of these in the
       reductions because there is one of these for each bin */
#if SIZEOF_LONG_LONG >= 8
    PMPI_Address( &cbMax[0].time, &displs[0] );
    PMPI_Address( &cbMax[0].size, &displs[1] );
    PMPI_Address( &cbMax[0].calls, &displs[2] );
    PMPI_Address( &cbMax[1].time, &displs[3] );
    for (i=3; i>=0; i--) 
      displs[i] -= displs[0];
    blk[0] = 2; din[0] = MPI_DOUBLE;
    blk[1] = 1; din[1] = MPI_LONG_LONG;
    blk[2] = 1; din[2] = MPI_INT;
    blk[3] = 1; din[3] = MPI_UB;
    PMPI_Type_struct( 4, blk, displs, din, &cb_dtype );
#else    
    PMPI_Address( &cbMax[0].time, &displs[0] );
    PMPI_Address( &cbMax[0].calls, &displs[1] );
    PMPI_Address( &cbMax[1].time, &displs[2] );
    for (i=2; i>=0; i--) 
      displs[i] -= displs[0];
    blk[0] = 3; din[0] = MPI_DOUBLE;
    blk[1] = 1; din[1] = MPI_INT;
    blk[2] = 1; din[2] = MPI_UB;
    PMPI_Type_struct( 3, blk, displs, din, &cb_dtype );
#endif
    PMPI_Type_commit( &cb_dtype );
    
    return cb_dtype;
}

/* Convert the data in the bins to a string.
 * This is done in two steps.
 * First, the values are converted into percentages.  This is
 * easily done once the totals are known.  The array of percentages is
 * then converted into a string 
 */

/* 
 * Special case: negative percent is no data 
 */
static int PercentagesToString( const double vals[], int nbins, 
				char binString[] )
{
    int i;
    
    for (i=0; i<nbins; i++) {
	int npercent = 10 * vals[i] + 0.5;
	if (npercent < 10 && npercent > 0)
	    binString[i] = '0' + npercent;
	else if (npercent == 0) 
	    binString[i] = '.';
	else if (npercent < 0)
	    binString[i] = '0';
	else {
	    binString[i] = '*'; 
	}
    }
    binString[i] = 0;
    return 0;
}


static int TimeBinsToString( CommBinData cb[], int nbins, int maxbins,
			     char binString[] )
{
    double percent[NBINS], totalTime = 0;
    int i;

    for (i=0; i<nbins; i++) {
	totalTime += cb[i].time;
	percent[i] = -1;
    }
    
    if (totalTime > 0) {
	for (i=0; i<maxbins; i++) {
	    if (cb[i].calls > 0) 
		percent[i] = cb[i].time / totalTime;
	    else 
		percent[i] = -1;
	}
    }
    return PercentagesToString( percent, maxbins, binString );
}

static int SyncBinsToString( CommBinData cb[], int nbins, int maxbins, 
			     char binString[] )
{
    double percent[NBINS], totalTime = 0;
    int i;

    for (i=0; i<nbins; i++) 
	totalTime += cb[i].synctime;
    
    for (i=0; i<maxbins; i++) {
	if (cb[i].calls > 0) 
	    percent[i] = cb[i].synctime / totalTime;
	else 
	    percent[i] = -1;
    }
    return PercentagesToString( percent, maxbins, binString );
}

static int CallsBinsToString( CommBinData cb[], int nbins, int maxbins, 
			      char binString[] )
{
    double percent[NBINS], totalCalls = 0;
    int i;

    for (i=0; i<nbins; i++) 
	totalCalls += cb[i].calls;
    
    for (i=0; i<maxbins; i++) {
	if (cb[i].calls > 0) 
	    percent[i] = cb[i].calls / totalCalls;
	else 
	    percent[i] = -1;
    }
    return PercentagesToString( percent, maxbins, binString );
}

/* */
static int CheckEnvBool( const char envname[], int *val )
{
    char *s = getenv( envname );
    /* If not defined or null, no change */
    if (!s || *s == 0) return 0;
    if (strcmp(s,"YES") == 0 || strcmp(s,"yes") == 0) { *val = 1; return 0; }
    if (strcmp(s,"NO") == 0 || strcmp(s,"no") == 0) { *val = 0; return 0; }
    /* Unrecognized value */
    fprintf( stderr, "Unrecognized value for environment variable %s is %s\n",
	     envname, s );
    return 1;
}

/* Output the amount of data to each destination */
void PrintPartnerVol( FILE *pf, int src, msgsize_t vol[], int size )
{
    int i;
    if (destvolOutputFormat == DESTVOL_OUT_BYROW) {
	fprintf( pf, "%d", src );
	for (i=0; i<size; i++) {
	    if (vol[i]) {
		fprintf( pf, "\t%d\t%ld,", i, (long)vol[i] );
	    }
	}
	fprintf( pf, "\n" );
    }
    else if (destvolOutputFormat == DESTVOL_OUT_COO) {
	for (i=0; i<size; i++) {
	    if (vol[i]) {
		fprintf( pf, "%d\t%d\t%ld\n", src, i, (long)vol[i] );
	    }
	}
    }
}

void fpmpiOutputDetailedDataVol( FILE *pf, int llrank )
{
    int i, k, size;
    msgsize_t *p = 0;

    if (fpmpi_ProfControlDestVol == 0)  return;
    PMPI_Comm_size( MPI_COMM_WORLD, &size );

    if (llrank == 0) {
	p = (msgsize_t *)malloc( size * sizeof(msgsize_t) );
	if (!p) {
	    fprintf( stderr, "Unable to allocated %ld bytes\n", 
		     (long)size * sizeof(msgsize_t) );
	    PMPI_Abort( MPI_COMM_WORLD, 1 );
	}
	fprintf( pf, "Data volume for each rank" );
	if (destvolOutputFormat == DESTVOL_OUT_BYROW) {
	    fprintf( pf, ": source<tab>dest<tab>bytes,...\n" );
	}
	else if (destvolOutputFormat == DESTVOL_OUT_COO) {
	    fprintf( pf, " in COO format: source<tab>dest<tab>bytes\n" );
	}
    }
    if (fpmpi_ProfControlDestVol == DESTVOL_SUMMARY) {
	if (llrank == 0) {
	    PrintPartnerVol( pf, 0, pt2ptInfo[0].data->sizeToPartner, size );
	    for (i=1; i<size; i++) {
		PMPI_Recv( p, size, MSGSIZE_T, i, 0, MPI_COMM_WORLD, 
			   MPI_STATUS_IGNORE );
		PrintPartnerVol( pf, i, p, size );
	    }
	}
	else {
	    PMPI_Ssend( pt2ptInfo[0].data->sizeToPartner, size, MSGSIZE_T, 
			0, 0, MPI_COMM_WORLD );
	}
    }
    else {
	/* DESTVOL_DETAIL */
	for (k=0; pt2ptInfo[k].name; k++) {
	    if (llrank == 0) {
		PrintPartnerVol( pf, 0, 
				 pt2ptInfo[k].data->sizeToPartner, size );
		for (i=1; i<size; i++) {
		    PMPI_Recv( p, size, MSGSIZE_T, i, 0, MPI_COMM_WORLD, 
			       MPI_STATUS_IGNORE );
		    PrintPartnerVol( pf, i, p, size );
		}
	    }
	    else {
		PMPI_Ssend( pt2ptInfo[k].data->sizeToPartner, size, MSGSIZE_T, 
			    0, 0, MPI_COMM_WORLD );
	    }
	}
    }
    if (llrank == 0) free( p );
}
