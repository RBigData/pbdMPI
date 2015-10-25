### Tool functions.

spmd.hostinfo <- function(comm = .mpiopt_get("SPMD.CT", "comm")){
  if(spmd.comm.size(comm) == 0){
    stop(paste("It seems no members running on comm", comm))
  }
  HOST.NAME <- spmd.get.processor.name()
  COMM.RANK <- spmd.comm.rank(comm)
  COMM.SIZE <- spmd.comm.size(comm)
  cat("\tHost:", HOST.NAME, "\tRank(ID):", COMM.RANK, "\tof Size:", COMM.SIZE,
      "on comm", comm, "\n")
  invisible()
} # End of spmd.hostinfo().

spmd.comm.print <- function(x, all.rank = .mpiopt_get("SPMD.CT", "print.all.rank"),
    rank.print = .mpiopt_get("SPMD.CT", "rank.source"), comm = .mpiopt_get("SPMD.CT", "comm"),
    quiet = .mpiopt_get("SPMD.CT", "print.quiet"),
    flush = .mpiopt_get("SPMD.CT", "msg.flush"),
    barrier = .mpiopt_get("SPMD.CT", "msg.barrier"), con = stdout(), ...){
  COMM.RANK <- spmd.comm.rank(comm)

  # Don't print "COMM.RANK = " even if verbose=TRUE in the case 'x' is invalid
  if (!exists(deparse(substitute(x))))
    quiet <- TRUE

  if(barrier){
    spmd.barrier(comm)
  }

  if(all.rank){
    for(i.rank in 0:(spmd.comm.size(comm) - 1)){
      if(i.rank == COMM.RANK){
        if(! quiet){
          cat("COMM.RANK = ", COMM.RANK, "\n", sep = "")
          if(flush){
            flush(con)
          }
        }
        print(x, ...)
        if(flush){
          flush(con)
        }
      }
      if(barrier){
        spmd.barrier(comm)
      }
    }
  } else{
    for(i.rank in rank.print){
      if(i.rank == COMM.RANK){
        if(! quiet){
          cat("COMM.RANK = ", COMM.RANK, "\n", sep = "")
          if(flush){
            flush(con)
          }
        }
        print(x, ...)
        if(flush){
          flush(con)
        }
      }
      if(barrier){
        spmd.barrier(comm)
      }
    }
  }

  invisible()
} # End of spmd.comm.print().

comm.print <- spmd.comm.print

spmd.comm.cat <- function(..., all.rank = .mpiopt_get("SPMD.CT", "print.all.rank"),
    rank.print = .mpiopt_get("SPMD.CT", "rank.source"), comm = .mpiopt_get("SPMD.CT", "comm"),
    quiet = .mpiopt_get("SPMD.CT", "print.quiet"), sep = " ", fill = FALSE,
    labels = NULL, append = FALSE, flush = .mpiopt_get("SPMD.CT", "msg.flush"),
    barrier = .mpiopt_get("SPMD.CT", "msg.barrier"), con = stdout()){
  COMM.RANK <- spmd.comm.rank(comm)

  if(barrier){
    spmd.barrier(comm)
  }

  if(all.rank){
    for(i.rank in 0:(spmd.comm.size(comm) - 1)){
      if(i.rank == COMM.RANK){
        if(! quiet){
          cat("COMM.RANK = ", COMM.RANK, "\n", sep = "")
          if(flush){
            flush(con)
          }
        }
        cat(..., sep = sep, fill = fill, labels = labels, append = append)
        if(flush){
          flush(con)
        }
      }
      if(barrier){
        spmd.barrier(comm)
      }
    }
  } else{
    for(i.rank in rank.print){
      if(i.rank == COMM.RANK){
        if(! quiet){
          cat("COMM.RANK = ", COMM.RANK, "\n", sep = "")
          if(flush){
            flush(con)
          }
        }
        cat(..., sep = sep, fill = fill, labels = labels, append = append)
        if(flush){
          flush(con)
        }
      }
      if(barrier){
        spmd.barrier(comm)
      }
    }
  }

  invisible()
} # End of spmd.comm.cat().

comm.cat <- spmd.comm.cat

