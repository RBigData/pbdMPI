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

    if(attr(x.buffer, "type") == "raw.object"){
      .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
            as.integer(tag), as.integer(comm), as.integer(status),
            PACKAGE = "pbdMPI")
      x.buffer <- unserialize(x.buffer)
    } else{
      if(is.raw(x.buffer)){
        .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
              as.integer(tag), as.integer(comm), as.integer(status),
              PACKAGE = "pbdMPI")
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
    }
  } else{
    ### Original way to guess buffer size.
    spmd.probe(rank.source, tag, comm, status)
    source.tag <- spmd.get.sourcetag(status)
    total.length <- spmd.get.count(4L, status)
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
  ct.buffer <- c(0L, 0L)
  ct.buffer <- .Call("spmd_recv_integer", ct.buffer, as.integer(rank.source),
                     as.integer(tag), as.integer(comm), as.integer(status),
                     PACKAGE = "pbdMPI")
  # Preamble: check.type is TRUE before calling this.
  #
  # --- Deal lazy first:
  # Case 1: x.buffer is NULL, type is NA.
  #         => lazy from default method.
  # Case 2: x.buffer is an object, type is NA.
  #         => lazy from default method.
  # Case 3: x.buffer is integer/double/raw, type is not NA.
  #         => lazy from individual method.
  #
  # --- Deal advance second:
  # Case 4: x.buffer is NULL, type is not NA.
  #         => advance from individual function call.
  # Case 5: x.buffer is an object, type is not NA.
  #         => (mistake) advance from individual function call.
  # Case 6: x.buffer is integer/double/raw, type is NA.
  #         => advance from individual function call.

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
  ret <- .Call("spmd_recv_raw", x.buffer, as.integer(rank.source),
               as.integer(tag), as.integer(comm), as.integer(status),
               PACKAGE = "pbdMPI")
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

