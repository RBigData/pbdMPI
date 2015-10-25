comm.match.arg <- function(arg, choices, several.ok=FALSE, ..., 
    all.rank = .mpiopt_get("SPMD.CT", "print.all.rank"),
    rank.print = .mpiopt_get("SPMD.CT", "rank.source"),
    comm = .mpiopt_get("SPMD.CT", "comm"),
    mpi.finalize = .mpiopt_get("SPMD.CT", "mpi.finalize"),
    quit = .mpiopt_get("SPMD.CT", "quit")){
  arg <- try(
    match.arg(arg=arg, choices=choices, several.ok=several.ok), 
    silent=TRUE
  )
  
  if (inherits(arg, "try-error"))
    comm.stop(arg, call.=FALSE, all.rank=all.rank, rank.print=rank.print, comm=comm, 
              mpi.finalize=mpi.finalize, quit=quit)
  
  return(arg)
} # End of comm.match.arg().
