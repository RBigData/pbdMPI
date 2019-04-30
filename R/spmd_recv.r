### S4 functions.
### Note: See note in "spmd_send.r" first.

### Default method.
spmd.recv.default <- function(x.buffer = NULL,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type){
  ### TODO: implement array/matrix as the way done in allreduce.
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = NA,
                                rank.source = rank.source, tag = tag,
                                comm = comm, status = status) 
    if(is.raw(x.buffer)){
      tmp <- attr(x.buffer, "type")
      if(!is.null(x.buffer) && tmp == "raw.object"){
        .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
              as.integer(tag), as.integer(comm), as.integer(status),
              PACKAGE = "pbdMPI")
        x.buffer <- unserialize(x.buffer)
      } else{
        .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
              as.integer(tag), as.integer(comm), as.integer(status),
              PACKAGE = "pbdMPI")
      }
    } else if(is.integer(x.buffer)){
      .Call("spmd_recv_integer", x.buffer, as.integer(rank.source),
            as.integer(tag), as.integer(comm), as.integer(status),
            PACKAGE = "pbdMPI")
    } else if(is.double(x.buffer)){
      .Call("spmd_recv_double", x.buffer, as.integer(rank.source),
            as.integer(tag), as.integer(comm), as.integer(status),
            PACKAGE = "pbdMPI")
    } else{
      stop("recv method is not implemented.")
    }
  } else{
    ### Original way to guess buffer size and get buffer.
    spmd.probe(rank.source, tag, comm, status)
    source.tag <- spmd.get.sourcetag(status)
    total.length <- spmd.get.count(.pbd_env$SPMD.DT$raw, status)
    x.buffer <- raw(total.length)
    .Call("spmd_recv_raw", x.buffer, as.integer(source.tag[1]),
          as.integer(source.tag[2]), as.integer(comm), as.integer(status),
          PACKAGE = "pbdMPI")
    x.buffer <- unserialize(x.buffer)
  }

  x.buffer
} # End of spmd.recv.default().


### For handshaking and allocating buffer only.
spmd.check.type <- function(x.buffer = NULL, type = NA,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status){
  ct.buffer <- c(0, 0)
  ct.buffer <- .Call("spmd_recv_double", ct.buffer, as.integer(rank.source),
                     as.integer(tag), as.integer(comm), as.integer(status),
                     PACKAGE = "pbdMPI")

  # Preamble: check.type is TRUE before calling this.
  #
  # --- Deal lazy first:
  # Case 1: x.buffer is NULL, type is NA.
  #         => lazy from default method.
  # Case 2: x.buffer is an object, type is NA.
  #         => lazy from default method.
  # Case 3: x.buffer is integer/double/raw, type is NA.
  #         => lazy from individual method.
  #
  # --- Deal advance second:
  # Case 4: x.buffer is NULL, type is not NA.
  #         => advance from individual function call.
  # Case 5: x.buffer is an object, type is not NA.
  #         => (mistake) advance from individual function call.
  # Case 6: x.buffer is integer/double/raw, type is not NA.
  #         => advance from individual function call.
  if(is.na(type)){
    # Deal lazy first.
    if(is.null(x.buffer)){
      # Case 1: buffer is empty.
      #         => allocate new buffer.
      x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
    } else if(!is.integer(x.buffer) &&
              !is.double(x.buffer) &&
              !is.raw(x.buffer)){
      # Case 2: buffer is probably an object so that is wrong for a buffer.
      #         => allocate new buffer.
      x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
    } else{
      # Case 3: check if buffer consistent with being received.
      #         => allocate buffer if not.
      if(!.pbd_env$SPMD.DT$is.func[[ct.buffer[1]]](x.buffer) ||
         length(x.buffer) != ct.buffer[2]){
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    }
  } else{
    # Deal advance second.
    if(is.null(x.buffer)){
      # Case 4: check if the call matchs with being received.
      #         => force to allocate buffer if match.
      if(ct.buffer[1] != type){
        stop(paste("Asked type is ", type, ", received type is ", ct.buffer[1],
                   " (Case 4).", sep = ""))
      } else{
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    } else if(!is.integer(x.buffer) &&
              !is.double(x.buffer) &&
              !is.raw(x.buffer)){
      # Case 5: check if the call matchs with being received.
      #         => force to allocate buffer if match.
      if(ct.buffer[1] != type){
        stop(paste("Asked type is ", type, ", received type is ", ct.buffer[1],
                   " (Case 5).", sep = ""))
      } else{
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    } else{
      # Case 6: check if the call matchs with being received.
      #         => check if type and length of buffer are correct.
      #         => allocate buffer if it is not correct o.w. do nothing.
      if(ct.buffer[1] != type){
        stop(paste("Asked type is ", type, ", received type is ", ct.buffer[1],
                   " (Case 6).", sep = ""))
      } else if(!.pbd_env$SPMD.DT$is.func[[ct.buffer[1]]](x.buffer) ||
                length(x.buffer) != ct.buffer[2]){
        x.buffer <- .pbd_env$SPMD.DT$alc.func[[ct.buffer[1]]](ct.buffer[2])
      }
    }
  }

  ### Add attribute to buffer only if serialize/unserialize is needed.
  if(.pbd_env$SPMD.DT$type[ct.buffer[1]] == "raw.object"){
    attr(x.buffer, "type") <- "raw.object" 
  }
  x.buffer
}


### For recv.
spmd.recv.integer <- function(x.buffer,
    rank.source = .pbd_env$SPMD.CT$rank.source, tag = .pbd_env$SPMD.CT$tag,
    comm = .pbd_env$SPMD.CT$comm, status = .pbd_env$SPMD.CT$status,
    check.type = .pbd_env$SPMD.CT$check.type){
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = .pbd_env$SPMD.DT$integer,
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
    check.type = .pbd_env$SPMD.CT$check.type){
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
    check.type = .pbd_env$SPMD.CT$check.type){
  if(check.type){
    x.buffer <- spmd.check.type(x.buffer, type = .pbd_env$SPMD.DT$raw,
                                rank.source = rank.source, tag = tag,
                                comm = comm, status = status) 
  }
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

