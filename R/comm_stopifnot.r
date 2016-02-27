### Similar to stopifnot().

comm.stopifnot <- function(..., call. = TRUE, domain = NULL,
    all.rank = .pbd_env$SPMD.CT$print.all.rank,
    rank.print = .pbd_env$SPMD.CT$rank.source,
    comm = .pbd_env$SPMD.CT$comm,
    mpi.finalize = .pbd_env$SPMD.CT$mpi.finalize,
    quit = .pbd_env$SPMD.CT$quit){

  n <- length(ll <- list(...))
  if(comm.all(n == 0L, comm = comm)){
    return(invisible())
  }

  ch.id <- NULL 
  if(n > 0){
    mc <- match.call()
    for(i in 1L:n){
      if(!(is.logical(r <- ll[[i]]) && !anyNA(r) && all(r))){
        ch.id <- i
        break
      }
    }
  }
  n.ch <- spmd.allreduce.integer(length(ch.id), integer(1), comm = comm)

  if(n.ch > 0){
    ch <- ""
    if(length(ch.id) > 0){
      ch <- deparse(mc[[ch.id + 1]], width.cutoff = 60L)
      ch <- paste(ch, "...")
    }
    comm.stop(ch, call. = call., domain = domain,
              all.rank = all.rank, rank.print = rank.print, comm = comm,
              mpi.finalize = mpi.finalize, quit = quit)
  } else{
    return(invisible())
  }
} # End of comm.stopifnot().

