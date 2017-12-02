### Median level functions for R objects. These should not be in S3/S4.

### For general types.
spmd.allreduce.object <- function(x, op = .pbd_env$SPMD.CT$op,
    comm = .pbd_env$SPMD.CT$comm){
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

  ### Call allreduce by data type.
  if(all.check[4]){
    ret <- spmd.allreduce.float32(x, float32(integer(length(x))), op = op[1],
                                  comm = comm)
  } else if(all.check[1] || all.check[3]){
    ret <- spmd.allreduce.integer(x, integer(length(x)), op = op[1],
                                  comm = comm)
  } else if(all.check[2]){
    ret <- spmd.allreduce.double(x, double(length(x)), op = op[1], comm = comm)
  } else{
    x <- try(as.double(x), silent = TRUE)
    if(class(x) == "try-error"){
      stop(x, comm = comm)
    }
    ret <- spmd.allreduce.double(x, double(length(x)), op = op[1], comm = comm)
  }

  ### Reset logical as needed.
  if(all.check[3] || op[1] %in% c("land", "lor", "lxor")){
    ret <- as.logical(ret)
  }

  return(ret)
} # End of spmd.allreduce.object().

### For array only.
spmd.allreduce.array <- function(x, op = .pbd_env$SPMD.CT$op,
    comm = .pbd_env$SPMD.CT$comm){
  ### Call allreduce.
  ret <- spmd.allreduce.object(x, op = op, comm = comm)

  ### Reset dimension.
  dim(ret) <- dim(x)
  return(ret)
} # End of spmd.allreduce.array().

