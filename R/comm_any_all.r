### Distributed quick sort.

### S3 functions.
comm.any <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(any(x, na.rm),
                                integer(comm.size(comm)), comm = comm)
  any(ret, na.rm)
} # End of comm.any().

comm.all <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(all(x, na.rm),
                                integer(comm.size(comm)), comm = comm)
  all(ret, na.rm)
} # End of comm.all().
