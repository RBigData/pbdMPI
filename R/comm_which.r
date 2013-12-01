# For computing global which ...

comm.which <- function(x, arr.ind = FALSE, useNames = TRUE,
                       comm = .SPMD.CT$comm){
  tmp <- which(x, arr.ind = arr.ind, useNames = useNames)
  if(length(tmp) > 0){
    tmp <- cbind(comm.rank(), tmp)
  } else{
    tmp <- NULL
  }

  ret <- allgather(tmp)
  ret <- do.call("rbind", ret)
  if(!is.null(ret)){
    dim(ret) <- c(length(ret) / 2, 2)
    colnames(ret) <- c("comm.rank", "which")
  }

  ret
} # End of comm.which().

comm.which.max <- function(x, comm = .SPMD.CT$comm){
  id.max <- which.max(x)
  x.max <- x[id.max] 
  global.x.max <- max(do.call("c", allgather(x.max)),
                      na.rm = TRUE, comm = comm)

  if(!is.null(global.x.max)){
    rank.max <- comm.size()
    if(x.max == global.x.max){
      rank.max <- comm.rank()
    }
    global.rank.max <- allreduce(rank.max, op = "min", comm = comm)
    global.id.max <- bcast(id.max, comm = comm)
    
    ret <- c(global.rank.max, global.id.max, global.x.max)
    names(ret) <- c("comm.rank", "which.max", "max")
  } else{
    ret <- NULL
  }

  ret
} # End of comm.which.max().

comm.which.min <- function(x, comm = .SPMD.CT$comm){
  id.min <- which.min(x)
  x.min <- x[id.min] 
  global.x.min <- min(do.call("c", allgather(x.min)),
                      na.rm = TRUE, comm = comm)

  if(!is.null(global.x.min)){
    rank.min <- comm.size()
    if(x.min == global.x.min){
      rank.min <- comm.rank()
    }
    global.rank.min <- allreduce(rank.min, op = "min", comm = comm)
    global.id.min <- bcast(id.min, comm = comm)
    
    ret <- c(global.rank.min, global.id.min, global.x.min)
    names(ret) <- c("comm.rank", "which.min", "min")
  } else{
    ret <- NULL
  }

  ret
} # End of comm.which.min().

