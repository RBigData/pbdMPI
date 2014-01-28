### S4 functions.

### Default method.
spmd.recv.default <- function(x.buffer = NULL,
    rank.source = .SPMD.CT$rank.source, tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  spmd.probe(rank.source, tag, comm, status)
  source.tag <- spmd.get.sourcetag(status)
  total.length <- spmd.get.count(4L, status)
  unserialize(spmd.recv.raw(raw(total.length),
                            rank.source = source.tag[1],
                            tag = source.tag[2],
                            comm = comm,
                            status = status))
} # End of spmd.recv.default().


### For recv.
spmd.recv.integer <- function(x.buffer,
    rank.source = .SPMD.CT$rank.source, tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_recv_integer", x.buffer, as.integer(rank.source),
        as.integer(tag), as.integer(comm), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.recv.integer().

spmd.recv.double <- function(x.buffer,
    rank.source = .SPMD.CT$rank.source, tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_recv_double", x.buffer, as.integer(rank.source),
        as.integer(tag), as.integer(comm), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.recv.double().

spmd.recv.raw <- function(x.buffer,
    rank.source = .SPMD.CT$rank.source, tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
        as.integer(tag), as.integer(comm), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.recv.raw().


### S4 methods.
setGeneric(
  name = "recv",
  useAsDefault = spmd.recv.default
)

### For recv.
setMethod(
  f = "recv",
  signature = signature(x.buffer = "ANY"),
  definition = spmd.recv.default
)
setMethod(
  f = "recv",
  signature = signature(x.buffer = "integer"),
  definition = spmd.recv.integer
)
setMethod(
  f = "recv",
  signature = signature(x.buffer = "numeric"),
  definition = spmd.recv.double
)
setMethod(
  f = "recv",
  signature = signature(x.buffer = "raw"),
  definition = spmd.recv.raw
)

