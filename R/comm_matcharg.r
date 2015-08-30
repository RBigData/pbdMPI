comm.match.arg <- function(arg, choices, several.ok=FALSE, ..., 
    all.rank = .pbdMPIEnv$SPMD.CT$print.all.rank,
    rank.print = .pbdMPIEnv$SPMD.CT$rank.source,
    comm = .pbdMPIEnv$SPMD.CT$comm,
    mpi.finalize = .pbdMPIEnv$SPMD.CT$mpi.finalize,
    quit = .pbdMPIEnv$SPMD.CT$quit){
  arg <- try(
    match.arg(arg=arg, choices=choices, several.ok=several.ok), 
    silent=TRUE
  )
  
  if (inherits(arg, "try-error"))
    comm.stop(arg, call.=FALSE, all.rank=all.rank, rank.print=rank.print, comm=comm, 
              mpi.finalize=mpi.finalize, quit=quit)
  
  return(arg)
} # End of comm.match.arg().
