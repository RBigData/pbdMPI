### These functions are supposed to run in SPMD, even when pbd.mode = "mw".

pbdSapply <- function(X, FUN, ..., simplify = TRUE, USE.NAMES = TRUE,
    pbd.mode = c("mw", "spmd", "dist"),
    rank.source = .pbdMPIEnv$SPMD.CT$rank.root,
    comm = .pbdMPIEnv$SPMD.CT$comm, bcast = FALSE, barrier = TRUE){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)

  ### Redistribute data for MW.
  if(pbd.mode[1] == "mw"){
    new.X <- NULL 
    if(COMM.RANK == rank.source){
      if(! is.vector(X) || is.object(X)){
        X <- as.list(X)
      }

      alljid <- get.jid(length(X), comm = comm, all = TRUE)
      new.X <- lapply(alljid, list.to.list, X) 
    }

    if(length(new.X) < COMM.SIZE){
      new.X <- c(new.X, rep(list(NULL), COMM.SIZE - length(new.X)))
    }

    new.X <- spmd.scatter.object(new.X, rank.source = rank.source, comm = comm)
  } else if(pbd.mode[1] == "spmd"){
    alljid <- get.jid(length(X), comm = comm)
    new.X <- sapply(alljid, list.to.list, X) 
  } else if(pbd.mode[1] == "dist"){
    nex.X <- X
  } else{
    comm.stop("pbd.mode is not found.")
  }

  ### Run as SPMD.
  ret <- sapply(new.X, FUN, ..., simplify = simplify, USE.NAMES = USE.NAMES)

  ### Gather data for MW.
  if(pbd.mode[1] == "mw"){
    ret <- spmd.gather.object(ret, rank.dest = rank.source, comm = comm)
    if(COMM.RANK != rank.source){
      ret <- NULL
    }

    if(bcast){
      ret <- spmd.bcast.object(ret, rank.source = rank.source, comm = comm)
    }
  } else{
    if(bcast){
      ret <- spmd.allgather.object(ret, comm = comm, unlist = FALSE)
      tmp <- list()
      for(i in 1:length(ret)){
        tmp <- c(tmp, ret[[i]])
      }
      ret <- tmp
    }
  }

  if(barrier){
    spmd.barrier(comm = comm)
  }

  ret
} # End of pbdSapply().

