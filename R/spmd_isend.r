### S4 functions.

### Default method.
spmd.isend.default <- function(x,
    rank.dest = .pbdMPIEnv$SPMD.CT$rank.dest, tag = .pbdMPIEnv$SPMD.CT$tag,
    comm = .pbdMPIEnv$SPMD.CT$comm, request = .pbdMPIEnv$SPMD.CT$request){
  ### WCC: This isend() should go with wait(), otherwise the new R object,
  ###      "serialize(x, NULL)", is NOT sent correctly since it is not
  ###      protected by R when the call "spmd.isend.default()" is returned.
  ###      Add wait() is equivalent to use send() function.
  # spmd.isend.raw(serialize(x, NULL), rank.dest = as.integer(rank.dest),
  #                tag = as.integer(tag), comm = as.integer(comm),
  #                request = as.integer(request))
  ### This implementation is the same as spmd.send.default(), because
  ### a blocking wait should be evoked to make sure buffer is sent completely.
  ### But this can cause dead lock.
  # spmd.send.raw(serialize(x, NULL), rank.dest = rank.dest,
  #               tag = tag, comm = comm)
  ### Use non-blocking buffer to avoid dead lock and use non-block send.
  if(is.null(.pbdMPIEnv$nb.buffer)){
    .pbdMPIEnv$nb.buffer <- list()
  }
  .pbdMPIEnv$nb.buffer[[length(.pbdMPIEnv$nb.buffer) + 1]] <- serialize(x, NULL)
  spmd.isend.raw(.pbdMPIEnv$nb.buffer[[length(.pbdMPIEnv$nb.buffer)]],
                 rank.dest = as.integer(rank.dest),
                 tag = as.integer(tag), comm = as.integer(comm),
                 request = as.integer(request))
  invisible()
} # End of spmd.isend.default().

### For isend.
spmd.isend.integer <- function(x,
    rank.dest = .pbdMPIEnv$SPMD.CT$rank.dest, tag = .pbdMPIEnv$SPMD.CT$tag,
    comm = .pbdMPIEnv$SPMD.CT$comm, request = .pbdMPIEnv$SPMD.CT$request){
  .Call("spmd_isend_integer", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), as.integer(request), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.isend.integer().

spmd.isend.double <- function(x,
    rank.dest = .pbdMPIEnv$SPMD.CT$rank.dest, tag = .pbdMPIEnv$SPMD.CT$tag,
    comm = .pbdMPIEnv$SPMD.CT$comm, request = .pbdMPIEnv$SPMD.CT$request){
  .Call("spmd_isend_double", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), as.integer(request), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.isend.double().

spmd.isend.raw <- function(x,
    rank.dest = .pbdMPIEnv$SPMD.CT$rank.dest, tag = .pbdMPIEnv$SPMD.CT$tag,
    comm = .pbdMPIEnv$SPMD.CT$comm, request = .pbdMPIEnv$SPMD.CT$request){
  .Call("spmd_isend_raw", x, as.integer(rank.dest), as.integer(tag),
        as.integer(comm), as.integer(request), PACKAGE = "pbdMPI")
  invisible()
} # End of spmd.isend.double().


### S4 methods.
setGeneric(
  name = "isend",
  useAsDefault = spmd.isend.default
)

### For isend.
setMethod(
  f = "isend",
  signature = signature(x = "ANY"),
  definition = spmd.isend.default
)
setMethod(
  f = "isend",
  signature = signature(x = "integer"),
  definition = spmd.isend.integer
)
setMethod(
  f = "isend",
  signature = signature(x = "numeric"),
  definition = spmd.isend.double
)
setMethod(
  f = "isend",
  signature = signature(x = "raw"),
  definition = spmd.isend.raw
)

