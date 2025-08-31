### All common functions.

#' Check if all elements are the same across all ranks.
#' 
#' Uses a cute trick that substitutes `reduce` for `gather`!
comm.allcommon <- function(x, comm = .pbd_env$SPMD.CT$comm,
    lazy.check = .pbd_env$SPMD.CT$lazy.check){
  if(lazy.check){
    ### Faster but dangerous.
    ret <- allreduce(x, comm = comm) / spmd.comm.size(comm) == x
  } else{ 
    ### Much slower but safer.
    tmp <- do.call("cbind", allgather(x, comm = comm))
    ret <- apply(tmp, 1, function(x){ length(unique(x)) }) == 1
  }
  ret 
} # End of comm.allcommon().


### Internal only.
#' A `band` is a bitwise AND operation. This collective returns TRUE if `x` are 
#' all same across ranks. At least one rank returns FALSE if they are not. 
#' The rank pattern of FALSE depends on the bit values: one errant 0 bit on 
#' a rank produces FALSE for all but that rank, an errant 1 does the opposite 
#' by producing a FALSE on only that rank. Same can be done with a `min` or `max`
#' operation.
#' 
#' Reaction to FALSE is not collective unless another collective is issued!
#' 
comm.allcommon.integer <- function(x, comm = .pbd_env$SPMD.CT$comm){
  x <- as.integer(x)
  spmd.allreduce.integer(x, integer(length(x)), comm = comm, op = "band") == x
} # End of comm.allcommon.integer().
