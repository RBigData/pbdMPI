### S3 tool function except print() and cat() see "spmd_tool.r".

comm.any <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(any(x, na.rm = na.rm),
                                integer(comm.size(comm)), comm = comm)
  any(ret, na.rm = na.rm)
} # End of comm.any().

comm.all <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(all(x, na.rm = na.rm),
                                integer(comm.size(comm)), comm = comm)
  all(ret, na.rm = na.rm)
} # End of comm.all().

comm.timer <- function(timed, comm = .SPMD.CT$comm){
  ltime <- system.time(timed)[3]

  mintime <- allreduce(ltime, op = 'min')
  maxtime <- allreduce(ltime, op = 'max')

  meantime <- allreduce(ltime, op = 'sum') / comm.size(comm)

  return(c(min = mintime, mean = meantime, max = maxtime) )
} # End of comm.timer().

comm.Rprof <- function(filename = "Rprof.out", append = FALSE, interval = 0.02,
    memory.profiling = FALSE, gc.profiling = FALSE, line.profiling = FALSE,
    numfiles = 100L, bufsize = 10000L, all.rank = .SPMD.CT$Rprof.all.rank,
    rank.Rprof = .SPMD.CT$rank.source, comm = .SPMD.CT$comm){
  COMM.RANK <- spmd.comm.rank(comm)
  COMM.SIZE <- spmd.comm.size(comm)

  if(!is.null(filename)){
    filename <- paste(filename, ".", COMM.RANK, sep = "")
  }

  if(all.rank){
    rank.Rprof <- 0:(COMM.SIZE - 1)
  }

  for(i.rank in rank.Rprof){
    if(i.rank == COMM.RANK){
      Rprof(filename = filename, append = append, interval = interval,
            memory.profiling = memory.profiling, gc.profiling = gc.profiling,
            line.profiling = line.profiling, numfiles = numfiles,
            bufsize = bufsize)
    }
  }

  invisible()
} # End of comm.Rprof().
