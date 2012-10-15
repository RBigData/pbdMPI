### S4 functions.

### Default method.
spmd.sendrecv.replace.default <- function(x,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  x.raw <- serialize(x, NULL)
  total.org <- length(x.raw)
  total.new <- spmd.sendrecv.replace.integer(as.integer(total.org),
                 rank.dest = as.integer(rank.source),
                 send.tag = as.integer(send.tag),
                 rank.source = as.integer(rank.dest),
                 recv.tag = as.integer(recv.tag),
                 comm = as.integer(comm), status = as.integer(status))
  if(total.org == total.new){
    unserialize(spmd.sendrecv.replace.raw(x.raw,
                  rank.dest = as.integer(rank.dest),
                  send.tag = as.integer(send.tag),
                  rank.source = as.integer(rank.source),
                  recv.tag = as.integer(recv.tag),
                  comm = as.integer(comm), status = as.integer(status)))
  } else{
    stop("Objects are not consistent.")
  }
} # End of spmd.sendrecv.replace.default().


### For sendrecv.replace.
spmd.sendrecv.replace.integer <- function(x,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_replace_integer", x,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.replace.integer().

spmd.sendrecv.replace.double <- function(x,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_replace_double", x,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.replace.double().

spmd.sendrecv.replace.raw <- function(x,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) %%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) %%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  .Call("spmd_sendrecv_replace_raw", x,
        rank.dest, send.tag, rank.source, recv.tag,
        comm, status, PACKAGE = "pbdMPI")
} # End of spmd.sendrecv.replace.raw().


### S4 methods for recv.
setGeneric(
  name = "sendrecv.replace",
  useAsDefault = spmd.sendrecv.replace.default
)
setMethod(
  f = "sendrecv.replace",
  signature = signature(x = "ANY"),
  definition = spmd.sendrecv.replace.default
)
setMethod(
  f = "sendrecv.replace",
  signature = signature(x = "integer"),
  definition = spmd.sendrecv.replace.integer
)
setMethod(
  f = "sendrecv.replace",
  signature = signature(x = "numeric"),
  definition = spmd.sendrecv.replace.double
)
setMethod(
  f = "sendrecv.replace",
  signature = signature(x = "raw"),
  definition = spmd.sendrecv.replace.raw
)

