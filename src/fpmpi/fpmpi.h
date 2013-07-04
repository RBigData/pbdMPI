#ifndef FPMPI_H_INCLUDED
#define FPMPI_H_INCLUDED

/* timing control */
extern int fpmpi_ProfControl;
extern int fpmpi_ProfControlSync;
extern int fpmpi_ProfControlDests;
extern int fpmpi_ProfControlWait;
extern int fpmpi_ProfControlWaitSize;
extern int fpmpi_ProfControlSyncAlt;
extern int fpmpi_ProfControlDestVol;

/* Hook for internal debugging */
extern int fpmpi_ProfControlDebug;

/* These values may be passed to MPI_Pcontrol and may be or'ed together */
#define FPMPI_PROF_ON 0x1
#define FPMPI_PROF_COLLSYNC 0x2
#define FPMPI_PROF_DESTS 0x4
#define FPMPI_PROF_WAITTIME 0x8
#define FPMPI_PROF_WAITTIME_SIZE 0x10
#define FPMPI_PROF_COLLSYNC_ALT 0x20
#define FPMPI_PROF_DESTVOL 0x40
#define FPMPI_PROF_DESTVOL_DETAIL 0x80

#endif
