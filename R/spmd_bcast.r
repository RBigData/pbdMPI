### S4 functions.

### Default method.
spmd.bcast.default <- function(x,
    rank.source = .SPMD.CT$rank.source, comm = .SPMD.CT$comm){
  rank.source <- as.integer(rank.source)
  comm <- as.integer(comm)
  if(spmd.comm.rank(comm) == rank.source){
    is.array <- spmd.bcast.integer(as.integer(is.array(x)), comm = comm)
  } else{
    is.array <- spmd.bcast.integer(integer(1), comm = comm)
  }

  if(is.array){
    spmd.bcast.array(x, rank.source = rank.source, comm = comm)
  } else{
    spmd.bcast.object(x, rank.source = rank.source, comm = comm)
  }
} # End of spmd.bcast.default().

### For bcast and basic types.
spmd.bcast.integer <- function(x,
    rank.source = .SPMD.CT$rank.source, comm = .SPMD.CT$comm){
  .Call("spmd_bcast_integer", x, rank.source, comm, PACKAGE = "pbdMPI")
} # End of spmd.bcast.integer().

spmd.bcast.double <- function(x,
    rank.source = .SPMD.CT$rank.source, comm = .SPMD.CT$comm){
  .Call("spmd_bcast_double", x, rank.source, comm, PACKAGE = "pbdMPI")
} # End of spmd.bcast.double().

spmd.bcast.raw <- function(x,
    rank.source = .SPMD.CT$rank.source, comm = .SPMD.CT$comm){
  .Call("spmd_bcast_raw", x, rank.source, comm, PACKAGE = "pbdMPI")
} # End of spmd.bcast.raw().


### S4 methods.
setGeneric(
  name = "bcast",
  useAsDefault = spmd.bcast.default
)

### For bcast.
setMethod(
  f = "bcast",
  signature = signature(x = "ANY"),
  definition = spmd.bcast.default
)
setMethod(
  f = "bcast",
  signature = signature(x = "integer"),
  definition = spmd.bcast.integer
)
setMethod(
  f = "bcast",
  signature = signature(x = "numeric"),
  definition = spmd.bcast.double
)
setMethod(
  f = "bcast",
  signature = signature(x = "raw"),
  definition = spmd.bcast.raw
)

