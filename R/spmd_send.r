### S4 functions.
### - default is for objects which need to be serialized.
### - raw is for vectors of type raw which are not intended to be serialized.
### Note: send/recv divides data in segments for data are too long.
###       probe/count may not get the correct length if data are too long.

### Default method.
spmd.send.default <- function(x,
    rank.dest = .pbd_env$SPMD.CT$rank.dest, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm,
    check.type = .pbd_env$SPMD.CT$check.type){
  ### TODO: implement array/matrix as the way done in allreduce.

  ### Use tag = 4L to force unserializing after receiving.
  spmd.send.raw(serialize(x, NULL), rank.dest = rank.dest,
                tag = tag, comm = comm, check.type = check.type)
  invisible()
} # End of spmd.send.default().


### For send.
spmd.send.integer <- function(x,
    rank.dest = .pbd_env$SPMD.CT$rank.dest, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm,
    check.type = .pbd_env$SPMD.CT$check.type){
  if(check.type){
    ct <- c(.pbd_env$SPMD.DT$integer, length(x))
    .Call("spmd_send_integer", ct, as.integer(rank.dest),
          as.integer(tag), as.integer(comm), PACKAGE = "pbdMPI")
  }
  .Call("spmd_send_integer", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.send.integer().

spmd.send.double <- function(x,
    rank.dest = .pbd_env$SPMD.CT$rank.dest, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm,
    check.type = .pbd_env$SPMD.CT$check.type){
  if(check.type){
    ct <- c(.pbd_env$SPMD.DT$double, length(x))
    .Call("spmd_send_integer", ct, as.integer(rank.dest),
          as.integer(tag), as.integer(comm), PACKAGE = "pbdMPI")
  }
  .Call("spmd_send_double", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.send.double().

spmd.send.raw <- function(x,
    rank.dest = .pbd_env$SPMD.CT$rank.dest, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm,
    check.type = .pbd_env$SPMD.CT$check.type){
  if(check.type){
    ct <- c(.pbd_env$SPMD.DT$raw, length(x))
    .Call("spmd_send_integer", ct, as.integer(rank.dest),
          as.integer(tag), as.integer(comm), PACKAGE = "pbdMPI")
  }
  .Call("spmd_send_raw", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.send.raw().


### S4 methods.
setGeneric(
  name = "send",
  useAsDefault = spmd.send.default
)

### For send.
setMethod(
  f = "send",
  signature = signature(x = "ANY"),
  definition = spmd.send.default
)
setMethod(
  f = "send",
  signature = signature(x = "integer"),
  definition = spmd.send.integer
)
setMethod(
  f = "send",
  signature = signature(x = "numeric"),
  definition = spmd.send.double
)
setMethod(
  f = "send",
  signature = signature(x = "raw"),
  definition = spmd.send.raw
)

