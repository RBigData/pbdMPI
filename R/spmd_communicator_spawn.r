spmd.comm.spawn <- function(worker, worker.arg, n.workers,
    info = .pbdEnv$SPMD.CT$info,
    rank.source = .pbdEnv$SPMD.CT$rank.source,
    intercomm = .pbdEnv$SPMD.CT$intercomm){
  if(! is.loaded("spmd_comm_spawn", PACKAGE = "pbdMPI")){
    stop("spmd_comm_spawn is not supported.")
  }

  if(! is.character(worker)){
    stop("Character argument (worker) expected.")
  } else if(n.workers < 1){
    stop("Choose a positive number of workers.")
  }

  ret <- .Call("spmd_comm_spawn", as.character(worker),
               as.character(worker.arg), as.integer(n.workers),
               as.integer(info), as.integer(rank.source),
               as.integer(intercomm), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.comm.spawn().
