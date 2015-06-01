comm.match.arg <- function(arg, choices, several.ok=FALSE, ..., 
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm, mpi.finalize = .SPMD.CT$mpi.finalize,
    quit = .SPMD.CT$quit)
{
  arg <- try(
    match.arg(arg=arg, choices=choices, several.ok=several.ok), 
    silent=TRUE
  )
  
  if (inherits(arg, "try-error"))
    comm.stop(arg, call.=FALSE, all.rank=all.rank, rank.print=rank.print, comm=comm, 
              mpi.finalize=mpi.finalize, quit=quit)
  
  return(arg)
}
