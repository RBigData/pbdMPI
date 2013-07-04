#include "fpmpiconf.h"
#include "mpi.h"
#include "profiler.h"

#include <stdio.h>
#include <stdlib.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif
/*
 * This file contains the code to read various resource usage information.
 * This includes
 *    Basic information from getrusage
 *    Information from /proc for LINUX
 *    Various performance counter tools, such as perfex and PAPI
 */

/* Decide which package to use, since multiple methods for
   accessing resource information may be available */
#if !defined(USE_LIBPERFEX) && !defined(USE_PCL) && !defined(USE_PAPI) && \
    !defined(USE_PROCSTAT)
#if defined(HAVE_PAPI)
#define USE_PAPI
#elif defined(HAVE_LIBPERFEX)
#define USE_LIBPERFEX
#elif defined(HAVE_PCL)
#define USE_PCL
#elif defined(HAVE_PROCSTAT)
#define USE_PROCSTAT
#endif /* case on HAVE_xxx */
#endif /* test on USE_xxx */

#ifdef USE_LIBPERFEX
static void initLibPerfex(void);
#endif /* USE_LIBPERFEX */

#ifdef USE_PCL
static void initPCL(void);
static void printout_pclstats( int, int, double, void *, int, int);
#endif /* USE_PCL */

#ifdef USE_PAPI
static void initPAPI(void);
static void OutputPAPI( FILE *, int, int );
#endif /* USE_PAPI */

#ifdef USE_PROCSTAT
#endif /* USE_PROCSTAT */

void fpmpiInitPerformanceCounters(void)
{
#ifdef USE_LIBPERFEX
    initLibPerfex();
#elif defined(USE_PCL)
    initPCL();
#elif defined(USE_PAPI)
    initPAPI();
#endif
}

void fpmpiOutputPerformanceCounters( FILE *pf, int llrank, int nprocs )
{
#ifdef USE_LIBPERFEX
  OutputPerfex( pf, llrank );
#elif defined(USE_PCL)
  OutputPcl( pf, llrank );
#elif defined(USE_PAPI)
  OutputPAPI( pf, llrank, nprocs );
#endif
}


#ifdef USE_PCL
static void printout_pclstats( int n_cycles, int n_fp_ops, 
		       double flops, void *handle, int rank, int nprocs)
{
  FILE *pf = (FILE *pf) handle;
  int i;
  int sum_cycles, max_cycles, min_cycles, max_cycles_loc, min_cycles_loc;
  int sum_fp_ops, max_fp_ops, min_fp_ops, max_fp_ops_loc, min_fp_ops_loc;
  double sum_flops, max_flops, min_flops;
  int max_flops_loc, min_flops_loc;

  getrange_int_single(n_cycles, &max_cycles, &max_cycles_loc, 
		   &min_cycles, &min_cycles_loc, &sum_cycles);
  getrange_int_single(n_fp_ops, &max_fp_ops, &max_fp_ops_loc, 
		   &min_fp_ops, &min_fp_ops_loc, &sum_fp_ops);
  getrange_double_single(flops, &max_flops, &max_flops_loc, 
		   &min_flops, &min_flops_loc, &sum_flops);

  if ( rank == 0 ) {
    GtableNewRow( gtable );
    GtableAddEntry(gtable, -1, -1, "Performance Counter Stats");
    GtableNewRow( gtable );
    GtableAddEntryFmt(gtable, -1, -1, "Cycles: %d", min_cycles);
    GtableAddEntryFmt(gtable, -1, -1, "%d", max_cycles);
    GtableAddEntryFmt(gtable, -1, -1, "%d", sum_cycles/nprocs);
    GtableAddEntryFmt(gtable, -1, -1, "%d", min_cycles_loc);
    GtableAddEntryFmt(gtable, -1, -1, "%d", max_cycles_loc);
    GtableNewRow( gtable );
    GtableAddEntryFmt(gtable, -1, -1, "Fp Ops: %d", min_fp_ops);
    GtableAddEntryFmt(gtable, -1, -1, "%d", max_fp_ops);
    GtableAddEntryFmt(gtable, -1, -1, "%d", sum_fp_ops/nprocs);
    GtableAddEntryFmt(gtable, -1, -1, "%d", min_fp_ops_loc);
    GtableAddEntryFmt(gtable, -1, -1, "%d", max_fp_ops_loc);
    GtableNewRow( gtable );
    GtableAddEntryFmt(gtable, -1, -1, "FLOPS: %f", min_flops);
    GtableAddEntryFmt(gtable, -1, -1, "%f", max_flops);
    GtableAddEntryFmt(gtable, -1, -1, "%f", sum_flops/nprocs);
    GtableAddEntryFmt(gtable, -1, -1, "%d", min_flops_loc);
    GtableAddEntryFmt(gtable, -1, -1, "%d", max_flops_loc);
  }
}

#ifdef USE_LIBPCL
#include <pcl.h>

/* PCL Variables */
#define PCL_NEVENTS 2
int counter_list[PCL_NEVENTS];     /* A list of events to track */
int ncounter, PCL_NO_EVENTS = 0;
unsigned int mode;
PCL_CNT_TYPE i_result_list[PCL_NEVENTS];
PCL_FP_CNT_TYPE fp_result_list[PCL_NEVENTS];

static void initPCL( void ) 
{
  /* Define PCL measurements */
  ncounter = PCL_NEVENTS;
  counter_list[0] = PCL_CYCLES;
  counter_list[1] = PCL_FP_INSTR;
  /* Define PCL count mode */
  mode = PCL_MODE_USER;

  /* Check if PCL works on this machine */
  ierr = PCLquery(counter_list, ncounter, mode);
  if ( ierr != PCL_SUCCESS) {
    fprintf(stderr,"[%d] Failed with error %d\n", llrank, ierr);
    if (ierr == PCL_NOT_SUPPORTED)
      fprintf(stderr, "[%d] Requested PCL event(s) not available.\n", llrank);
    else if (ierr == PCL_TOO_MANY_EVENTS)
      fprintf(stderr, "[%d] Too many requested events.\n", llrank);
    else if (ierr == PCL_ILL_EVENT)
      fprintf(stderr, "[%d] Illegal event identifier.\n", llrank);
    else if (ierr == PCL_MODE_NOT_SUPPORTED)
      fprintf(stderr, "[%d] Unsupported PCL MODE.\n", llrank);
    else if (ierr == PCL_FAILURE)
      fprintf(stderr, "[%d] Unknown PCL Failure.\n", llrank);
    return ierr;
  }

  /* Start performance counting */
  ierr = PCLstart(counter_list, ncounter, mode);
  if (ierr != PCL_SUCCESS) {
    fprintf( stderr, "[%d] PCLstart failed!\n", llrank);
  }
}
void  OutputPcl( pf, llrank ) 
{
   /* Stop PCL measurements */
  if (PCLstop(i_result_list, fp_result_list, ncounter) != PCL_SUCCESS)
    fprintf(stderr, "[%d] PCLstop error!\n", llrank);

  n_fp_ops = i_result_list[1];
  n_cycles = i_result_list[0];
  flops    = fp_result_list[2];
  printout_pclstats(n_cycles, n_fp_ops, flops, pf, llrank, nprocs);
}
#endif /* USE_LIBPCL */


#endif /* USE_PCL */

#ifdef USE_LIBPERFEX
#define MPI_PROF_L2 26
#define MPI_PROF_FLOPS 21
/* R10K hardware performance counters, these can be overridden using
   the environment variables T5_EVENT0 and T5_EVENT1
   Note: If T5_EVENT1 is set, a 'conflicting events' message is generated,
         regardless if it matches the defs below.
 */
static int hwpc_e0 = 0;              /* cycles */
static int  hwpc_e1 = MPI_PROF_L2;   /* L2 cache misses (default) */
static long long hwpc_c0, hwpc_c1;
static int hwpc_ok = 1;

static void initLibPerfex( void ) 
{
  /* If a user has the env variable T5_EVENT1 set, this code will generate
     a conflicting events error when trying to set the hardware counters
     We use a flag to see if the variable has been set. */
  if (getenv("T5_EVENT1") != NULL) {
    fprintf(stderr, "T5_EVENT1 detected, aborting run.\n");
    returnVal = PMPI_Finalize();
    return returnVal;
  }
  else if (getenv("MPI_PROFILE_EVENT1") != NULL)
    hwpc_e1 = atoi( getenv("MPI_PROFILE_EVENT1") );

  if ( start_counters( hwpc_e0, hwpc_e1 ) < 0 ) 
    hwpc_ok = 0;
}
void  OutputPerfex( pf, llrank )
{
   /* We can't use the print_costs routine because the output is not reliably
      written to the output (a known bug in the SGI MPI implementation) */
   if ( hwpc_ok ) {
     if ( llrank == 0 ) {
       if ( read_counters( hwpc_e0, &hwpc_c0, hwpc_e1, &hwpc_c1 ) < 0 ) {
	 fprintf(pf, "** Error reading hardware performance counters **\n");
       }
       else {
	 fprintf(pf,"\n------   Hardware Performance Stats\n");
	 /*print_counters(hwpc_e0, hwpc_c0, hwpc_e1, hwpc_c1);*/
	 /* print_costs(hwpc_e0, hwpc_c0, hwpc_e1, hwpc_c1); */
	 fprintf( pf, "Event %d \t%lld\n", hwpc_e0, hwpc_c0 );
	 fprintf( pf, "Event %d \t%lld\n", hwpc_e1, hwpc_c1 );
       }
     }
   }
   else {
     fprintf(pf, "** Error initializing hardware performance counters **\n");
   }
}
#endif /* USE_LIBPERFEX */

#ifdef USE_PAPI

#include "papi.h"

/* Define some useful events in decreasing order of interest.  
   This allows us to provide more than 2 events if the hardware supports
   more events, without enumerating different sets for different 
   numbers of available events. */
#define MAX_PAPI_EVENTS 6
static int Events[MAX_PAPI_EVENTS] = { PAPI_FMA_INS, PAPI_TOT_CYC, PAPI_L3_TCM,        PAPI_L2_DCA, PAPI_L2_DCH, PAPI_L3_STM }; 
/* PAPI_FP_INS not available at BGL */
static int validEvents[MAX_PAPI_EVENTS];
static int numValidEvents = 0;

static void initPAPI(void)
{
    int        n, rc, i;

    /* Check on the number of available counters */
    n = PAPI_num_counters();

    /* Validate the counters choices */
    for (i=0; i<MAX_PAPI_EVENTS; i++) {
        if (Events[i] == -1) break;
        rc = PAPI_query_event( Events[i] );
	if (rc == PAPI_OK) {
            validEvents[numValidEvents++] = Events[i];
        }
        if (numValidEvents >= n) break;
    }

    if (numValidEvents == 0) {
        /* We may want to warn about missing PAPI data */
        return;
    }

    /* Start the counters */
    rc = PAPI_start_counters( validEvents, numValidEvents );
    if (rc != PAPI_OK) {
	fprintf( stderr, "Error starting PAPI counters: %s\n", 
                 PAPI_strerror(rc) );
    }
}
static void OutputPAPI( FILE *pf, int llrank, int nprocs )
{
    long_long values[MAX_PAPI_EVENTS];
    long long v[MAX_PAPI_EVENTS], vmax[MAX_PAPI_EVENTS], vmin[MAX_PAPI_EVENTS],
	vsum[MAX_PAPI_EVENTS];
    int i, rc;

    if (numValidEvents == 0) return;

    /* Stop the counters and read their values */
    rc = PAPI_stop_counters( values, numValidEvents );
    if (rc != PAPI_OK ) {
	fprintf( stderr, "[%d] Unable to stop and read counters: %s\n", 
                 llrank, PAPI_strerror(rc) );
	return;
    }

    for (i=0; i<numValidEvents; i++) {
	/* In case long_long is not the same as long long */
	v[i] = values[i];
    }
    
    PMPI_Reduce( v, vsum, numValidEvents, MPI_LONG_LONG, MPI_SUM, 0, 
		 MPI_COMM_WORLD );
    PMPI_Reduce( v, vmin, numValidEvents, MPI_LONG_LONG, MPI_MIN, 0, 
		 MPI_COMM_WORLD );
    PMPI_Reduce( v, vmax, numValidEvents, MPI_LONG_LONG, MPI_MAX, 0, 
		 MPI_COMM_WORLD );
    
    if (llrank == 0) {
	fprintf( pf, "\nPAPI Data:\n" );
	for (i=0; i<numValidEvents; i++) {
	    char ename[PAPI_MAX_STR_LEN+1];
	    PAPI_event_code_to_name( validEvents[i], ename );
	    fprintf( pf, "%s: average = %.2f, max = %lld, min = %lld\n", 
		     ename, (double)vsum[i] / nprocs, vmax[i], vmin[i] );
	}
    }
}
#endif

#if defined(USE_PROCSTAT) && ! defined(FOUND_USAGE)
#define FOUND_USAGE
#include <string.h>
#include <fcntl.h>

typedef struct procstat {
    int pid;         /* Process id */
    char *comm;      /* The filename of the executable, in
			parentheses.  This is visible
			whether or not the executable is
			swapped out. */

    char state;      /* One character from the string
			"RSDZT" where R is running, S is
			sleeping in an interruptible wait, D
			is sleeping in an uninterruptible
			wait or swapping, Z is zombie, and T
			is traced or stopped (on a signal). */
    int ppid;        /* The PID of the parent. */
    int pgrp;        /* The process group ID of the process. */
    int session;     /* The session ID of the process. */
    int tty;         /* The tty the process uses. */
    int tpgid;       /* The process group ID of the process
			which currently owns the tty that
			the process is connected to. */
    unsigned int flags;  /* The flags of the process.
			Currently, every flag has the math
			bit set, because crt0.s checks for
			math emulation, so this is not
			included in the output.  This is
			probably a bug, as not every process
			is a compiled C program.  The math
			bit should be a decimal 4, and the
			traced bit is decimal 10. */
    unsigned int minflt; /* The number of minor faults the
			process has made, those which have
			not required loading a memory page
			from disk. */
    unsigned int cminflt;/* The number of minor faults that the
			process and its children have made. */
    unsigned int majflt; /* The number of major faults the
			process has made, those which have
			required loading a memory page from
			disk. */
    unsigned int cmajflt;/* The number of major faults that the
			process and its children have made. */
    int utime;       /* The number of jiffies that this
			process has been scheduled in user
			mode. */
    int stime;       /* The number of jiffies that this
			process has been scheduled in kernel
			mode. */
    int cutime;      /* The number of jiffies that this
			process and its children have been
			scheduled in user mode. */
    int cstime;      /* The number of jiffies that this
                        process and its children have been
			scheduled in kernel mode. */
    int counter;     /* The current maximum size in jiffies
			of the process's next timeslice, or
			what is currently left of its
			current timeslice, if it is the
			currently running process. */
    int priority;    /* The standard nice value, plus
			fifteen.  The value is never
			negative in the kernel. */
    int timeout;     /* The time in jiffies of the process's
			next timeout. */
    unsigned int itrealvalue; /* The time (in jiffies) before the
				 next SIGALRM is sent to the process
				 due to an interval timer. */
    int starttime;   /* Time the process started in
			jiffies after system boot. */
    unsigned int vsize; /* Virtual memory size */
    unsigned int rss;   /* Resident Set Size: number of pages
			   the process has in real memory,
			   minus 3 for administrative purposes.
			   This is just the pages which count
			   towards text, data, or stack space.
			   This does not include pages which
			   have not been demand-loaded in, or
			   which are swapped out. */
    unsigned int rlim; /* Current limit in bytes on the rss of
			  the process (usually 2,147,483,647). */
    unsigned int startcode; /* The address above which program text
			       can run. */
    unsigned int endcode; /* The address below which program text
                             can run.*/
    unsigned int startstack; /* The address of the start of the stack. */
    unsigned int kstkesp; /* The current value of esp (32-bit
                             stack pointer), as found in the
                             kernel stack page for the process. */
    unsigned int kstkeip; /* The current EIP (32-bit instruction
                             pointer). */
    int signal; /* The bitmap of pending signals (usually 0). */
    int blocked; /* The bitmap of blocked signals
		    (usually 0, 2 for shells). */
    int sigignore; /* The bitmap of ignored signals. */
    int sigcatch; /* The bitmap of catched signals. */
    unsigned int wchan; /* This is the "channel" in which the
                           process is waiting.  This is the
                           address of a system call, and can be
                           looked up in a namelist if you need
                           a textual name.  (If you have an up-
                           to-date /etc/psdatabase, then try ps
                           -l to see the WCHAN field in action)  */
  } procstat_t;


static int ReadProcStat( procstat_t *); /* Reads the /proc/(pid)/stat file */
/* 
   This subroutine takes a pointer to a procstat structure as input. It 
   then determines the process id and fills in the fields of the procstat 
   structure with info from the /proc/pid/stat file.
*/
#define GET_NEXT_WORD(name) word = strtok(name, " ")

#define WORD_NOT_NULL (word != NULL)

static int ReadProcStat( procstat_t *pstats )
{
  int mypid;
  int nBytes;
  char fname[25];
  int fp;
  char buffer[BUFSIZ];
  char *word;

  mypid = getpid();
  sprintf(fname, "/proc/%d/stat", mypid);

  if ( (fp = open(fname, O_RDONLY) ) > -1 ) {
    nBytes = read(fp, buffer, BUFSIZ);
    close(fp);
  }
  else {
    fprintf(stderr, "Error reading procstat file %s.\n", fname);
    return -1;
  }
  /* Parse the buffer containing space-separated stat field values */
  if ( nBytes > 0 ) {
    GET_NEXT_WORD(buffer);
    if WORD_NOT_NULL pstats->pid = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->comm = word;
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->state = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->ppid = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->pgrp = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->session = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->tty = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->tpgid = atoi(word);
    GET_NEXT_WORD(NULL); 
    if WORD_NOT_NULL pstats->flags = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->minflt = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->cminflt = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->majflt = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->cmajflt = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->utime = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->stime = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->cutime = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->cstime = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->counter = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->priority = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->timeout = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->itrealvalue = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->starttime = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->vsize = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->rss = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->rlim = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->startcode = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->endcode = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->startstack = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->kstkesp = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->kstkeip = strtoul(word, (char **) NULL, 10);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->signal = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->blocked = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->sigignore = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->sigcatch = atoi(word);
    GET_NEXT_WORD(NULL);
    if WORD_NOT_NULL pstats->wchan = strtoul(word, (char **) NULL, 10);
  }
  else {
    fprintf(stderr, "No data read from %s.\n", fname);
    return -2;
  }
  return 0;
}

int fpmpi_GetResourceUsage( ProgramResourceUsage *usage, int llrank )
{
  int rc;
  procstat_t pstats;

  rc = ReadProcStat( &pstats );
  if (!rc) {
    usage->minorPageFaults = pstats.minflt;
    usage->majorPageFaults = pstats.majflt;
    usage->residentSetSize = pstats.rss;

    /* pstats.utime and pstats.stime are the # of "jiffies" in user and
       system mode.  Need the time of a "jiffy" to set the user/sys time */
    usage->validFields = FPMPI_PRU_MINOR_PAGE_FAULTS | 
                         FPMPI_PRU_MAJOR_PAGE_FAULTS |
                         FPMPI_PRU_RSS;
  }
  else {
      usage->validFields = 0;
  }
  return rc;
}
#endif /* USE_PROCSTAT */

#if defined(HAVE_GETRUSAGE) && !defined(FOUND_USAGE)
#define FOUND_USAGE
int fpmpi_GetResourceUsage( ProgramResourceUsage *usage, int llrank )
{
  struct rusage myusage;

  /* Get Resource usage */
  if ( getrusage(RUSAGE_SELF, &myusage) < 0 ) {
    fprintf(stderr, "[%d] getrusage error\n", llrank);
    usage->validFields = 0;
    return 1;
  }

  usage->userTime = (double) myusage.ru_utime.tv_sec +
    myusage.ru_utime.tv_usec / 1000000.0;
  usage->systemTime = (double) myusage.ru_stime.tv_sec +
    myusage.ru_stime.tv_usec / 1000000.0;
  usage->validFields = FPMPI_PRU_USER_TIME | FPMPI_PRU_SYS_TIME;

#ifdef GETRUSAGE_HAS_MAXRSS
  usage->residentSetSize = myusage.ru_maxrss;
  usage->validFields |= FPMPI_PRU_RSS;
#endif
#ifdef GETRUSAGE_HAS_MINFLT
  usage->minorPageFaults = myusage.ru_minflt;
  usage->majorPageFaults = myusage.ru_majflt;
  usage->validFields |= FPMPI_PRU_MINOR_PAGE_FAULTS | 
                        FPMPI_PRU_MAJOR_PAGE_FAULTS;
#endif
  
  /* Other fields in myusage of interest may include inblock, oublock, 
     nswap */

  return 0;
}
#endif
