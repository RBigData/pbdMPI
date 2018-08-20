### S4 functions.
### Note: See note in "spmd_send.r" first.

### Default method.
spmd.recv.default <- function(x.buffer = NULL,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type,
    unserialize.raw = .pbd_env$SPMD.CT$unserialize.raw){
  ### TODO: implement array/matrix as the way done in allreduce.

  ### Use type = 0L to force allocating/overwritting x.buffer based on source.
  if(is.raw(x.buffer)){
    unserialize.raw <- FALSE
  }
  x.buffer <- spmd.check.type(x.buffer, type = 0L, rank.source = rank.source,
                              tag = tag, comm = comm, status = status)
  if(is.raw(x.buffer)){
    spmd.recv.raw(x.buffer, rank.source = rank.source,
                  tag = tag, comm = comm, status = status,
                  check.type = FALSE, unserialize.raw = unserialize.raw)
  } else if(is.integer(x.buffer)){
    spmd.recv.integer(x.buffer, rank.source = rank.source,
                  tag = tag, comm = comm, status = status,
                  check.type = FALSE)
  } else if(is.double(x.buffer)){
    spmd.recv.double(x.buffer, rank.source = rank.source,
                     tag = tag, comm = comm, status = status,
                     check.type = FALSE)
  } else{
    stop("recv method is not implemented.")
  }
} # End of spmd.recv.default().

### Rename original spmd.recv.default() to spmd.recv.object().
spmd.recv.object <- function(x.buffer = NULL,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type,
    unserialize.raw = .pbd_env$SPMD.CT$unserialize.raw){
  spmd.probe(rank.source, tag, comm, status)
  source.tag <- spmd.get.sourcetag(status)
  total.length <- spmd.get.count(4L, status)
  spmd.recv.raw(raw(total.length),
                rank.source = source.tag[1],
                tag = source.tag[2],
                comm = comm,
                status = status,
                check.type = FALSE,
                unserialize = unserialize)
} # End of spmd.recv.object().


### For handshaking.
spmd.check.type <- function(x.buffer = NULL, type = 0L,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status){
  ct.buffer <- c(0L, 0L)
  ct.buffer <- .Call("spmd_recv_integer", ct.buffer, as.integer(rank.source),
                     as.integer(tag), as.integer(comm), as.integer(status),
                     PACKAGE = "pbdMPI")

  if(is.null(x.buffer)){
    ### Always allocate buffer for NULL.
    x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
  } else{
    ### Check prespecified buffer type.
    if(type == 0L){
      if(!.pbd_env$SPMD.DT$is.func[[ct.buffer[1]]](x.buffer) ||
         length(x.buffer) != ct.buffer[2]){
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    } else{
      ### Check if receive wrong data by chance.
      if(ct.buffer[1] != type){
        stop(paste("Asked type is ", type, ", received type is ", ct.buffer[1],
                   sep = ""))
      }
      if(!.pbd_env$SPMD.DT$is.func[[ct.buffer[1]]](x.buffer) ||
         length(x.buffer) != ct.buffer[2]){
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    }
  }
  x.buffer
}

### For recv.
spmd.recv.integer <- function(x.buffer,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type,
    unserialize.raw = .pbd_env$SPMD.CT$unserialize.raw){
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = .pbd_env$SPMD.DT$intege,
                                rank.source = rank.source, tag = tag,
                                comm = comm, status = status) 
  }
  .Call("spmd_recv_integer", x.buffer, as.integer(rank.source),
        as.integer(tag), as.integer(comm), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.recv.integer().

spmd.recv.double <- function(x.buffer,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type,
    unserialize.raw = .pbd_env$SPMD.CT$unserialize.raw){
  if(is.raw(x.buffer)){
    unserialize.raw <- FALSE
  }
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = .pbd_env$SPMD.DT$double,
                                rank.source = rank.source, tag = tag,
                                comm = comm, status = status) 
  }
  .Call("spmd_recv_double", x.buffer, as.integer(rank.source),
        as.integer(tag), as.integer(comm), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.recv.double().

spmd.recv.raw <- function(x.buffer,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type,
    unserialize.raw = .pbd_env$SPMD.CT$unserialize.raw){
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = .pbd_env$SPMD.DT$raw,
                                rank.source = rank.source, tag = tag,
                                comm = comm, status = status) 
  }
  ret <- .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
               as.integer(tag), as.integer(comm), as.integer(status),
               PACKAGE = "pbdMPI")
  if(unserialize.raw){
    ret <- unserialize(ret)
  }
  ret
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

