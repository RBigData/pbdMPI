### S4 functions.

### Default method.
spmd.sendrecv.default <- function(x, x.buffer = NULL,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  x.raw <- serialize(x, NULL)
  total.new <- spmd.sendrecv.integer(length(x.raw), integer(1),
                 rank.dest = as.integer(rank.source),
                 send.tag =  as.integer(send.tag),
                 rank.source = as.integer(rank.dest),
                 recv.tag =  as.integer(recv.tag),
                 comm = as.integer(comm), status = as.integer(status))
  unserialize(spmd.sendrecv.raw(x.raw, raw(total.new),
                rank.dest = as.integer(rank.dest),
                send.tag = as.integer(send.tag),
                rank.source = as.integer(rank.source),
                recv.tag = as.integer(recv.tag),
                comm = as.integer(comm), status = as.integer(status)))
} # End of spmd.sendrecv.default().


### For sendrecv.
spmd.sendrecv.integer <- function(x, x.buffer,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_integer", x, x.buffer,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.integer().

spmd.sendrecv.double <- function(x, x.buffer,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_double", x, x.buffer,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.double().

spmd.sendrecv.raw <- function(x, x.buffer,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_raw", x, x.buffer,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.raw().


### S4 methods for recv.
setGeneric(
  name = "sendrecv",
  useAsDefault = spmd.sendrecv.default
)
setMethod(
  f = "sendrecv",
  signature = signature(x = "ANY", x.buffer = "ANY"),
  definition = spmd.sendrecv.default
)
setMethod(
  f = "sendrecv",
  signature = signature(x = "integer", x.buffer = "integer"),
  definition = spmd.sendrecv.integer
)
setMethod(
  f = "sendrecv",
  signature = signature(x = "numeric", x.buffer = "numeric"),
  definition = spmd.sendrecv.double
)
setMethod(
  f = "sendrecv",
  signature = signature(x = "raw", x.buffer = "raw"),
  definition = spmd.sendrecv.raw
)

