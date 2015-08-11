### For alltoall and basic types.
spmd.alltoall.integer <- function(x, x.buffer, comm = .SPMD.CT$comm){
  .Call("spmd_alltoall_integer", x, x.buffer,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoall.double().

spmd.alltoall.double <- function(x, x.buffer, comm = .SPMD.CT$comm){
  .Call("spmd_alltoall_double", x, x.buffer,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoall.double().

spmd.alltoall.raw <- function(x, x.buffer, comm = .SPMD.CT$comm){
  .Call("spmd_alltoall_raw", x, x.buffer,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoall.raw().


### For alltoallv and basic types.
spmd.alltoallv.integer <- function(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm){
  .Call("spmd_alltoallv_integer", x, x.buffer, x.count, sdispls, rdispls,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoallv.integer().

spmd.alltoallv.double <- function(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm){
  .Call("spmd_alltoallv_double", x, x.buffer, x.count, sdispls, rdispls,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoallv.double().

spmd.alltoallv.raw <- function(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm){
  .Call("spmd_alltoallv_raw", x, x.buffer, x.count, sdispls, rdispls,
        as.integer(comm), PACKAGE = "pbdMPI")
} # End of spmd.alltoallv.raw().

