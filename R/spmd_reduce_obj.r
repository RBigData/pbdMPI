### Median level functions for R objects. These should not be in S3/S4.

### For general types.
spmd.reduce.object <- function(x, op = .pbd_env$SPMD.CT$op,
    rank.dest = .pbd_env$SPMD.CT$rank.source, comm = .pbd_env$SPMD.CT$comm){
  ### Check op.
  op <- match.arg(tolower(op[1]), .pbd_env$SPMD.OP)
  if(op %in% c("land", "band", "lor", "bor", "lxor", "bxor")){
    if(!is.integer(x)){
      x <- try(as.integer(x), silent = TRUE)
    }
    if(class(x) == "try-error"){
      stop(x, comm = comm)
    }
  }

  ### Check if all are in common.
  comm <- as.integer(comm)
  COMM.SIZE <- spmd.comm.size(comm)
  check.integer <- is.integer(x)
  check.double <- is.double(x)
  check.logical <- is.logical(x)
  check.float32 <- is(x, "float32")
  all.check <- spmd.allreduce.integer(
                 c(check.integer, check.double, check.logical, check.float32),
                 integer(4), op = "sum", comm = comm) == COMM.SIZE

  ### Call reduce by data type.
  rank.dest <- as.integer(comm)
  if(all.check[4]){
    ret <- spmd.reduce.float32(x, float32(integer(length(x))), op = op[1],
                               rank.dest = rank.dest, comm = comm)
  } else if(all.check[1] || all.check[3]){
    ret <- spmd.reduce.integer(x, integer(length(x)), op = op[1],
                               rank.dest = rank.dest, comm = comm)
  } else if(all.check[2]){
    ret <- spmd.reduce.double(x, double(length(x)), op = op[1],
                              rank.dest = rank.dest, comm = comm)
  } else{
    x <- try(as.double(x), silent = TRUE)
    if(class(x) == "try-error"){
      stop(x, comm = comm)
    }
    ret <- spmd.reduce.double(x, double(length(x)), op = op[1],
                              rank.dest = rank.dest, comm = comm)
  }

  ### For return.
  if(spmd.comm.rank(comm) != rank.dest){
    return(invisible())
  } else{
    ### Reset logical as needed.
    if(all.check[3] || op[1] %in% c("land", "lor", "lxor")){
      ret <- as.logical(ret)
    }
  }
  ret
} # End of spmd.reduce.object().

### For array only.
spmd.reduce.array <- function(x, op = .pbd_env$SPMD.CT$op,
    rank.dest = .pbd_env$SPMD.CT$rank.source, comm = .pbd_env$SPMD.CT$comm){
  ### Call reduce.
  ret <- spmd.reduce.object(x, op = op, rank.dest = rank.dest, comm = comm)

  ### Reset dimension.
  if(spmd.comm.rank(as.integer(comm)) == rank.dest){
    dim(ret) <- dim(x)
  }
  return(ret)
} # End of spmd.reduce.array().

