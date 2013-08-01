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
