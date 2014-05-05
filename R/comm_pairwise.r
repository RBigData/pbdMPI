### Distributed all pair-wise functions.
### Assume gbd.major = 1.

comm.pairwise <- function(X.gbd,
    FUN = function(x, y, ...){ return(as.vector(dist(rbind(x, y), ...))) },
    ..., diag = FALSE, symmetric = TRUE, comm = .SPMD.CT$comm){
  ### FUN <- function(x, y, ...) is a user defined function.

  ### Check X.gbd.
  if(!comm.allcommon(length(dim(X.gbd)), comm = comm)){
    comm.stop("Dimension of X.gbd should all equal to 2.", comm = comm)
  }
  if(!comm.allcommon(ncol(X.gbd), comm = comm)){
    comm.stop("X.gbd should have the same # of columns.", comm = comm)
  }

  ### Get info.
  COMM.RANK <- spmd.comm.rank(comm)
  COMM.SIZE <- spmd.comm.size(comm)

  N.gbd <- nrow(X.gbd)
  N.allgbd <- spmd.allgather.integer(as.integer(N.gbd), integer(COMM.SIZE),
                                     comm = comm)
  N <- sum(N.allgbd)
  N.cumsum <- c(1, cumsum(N.allgbd) + 1)

  ### Check pairs.gbd.
  if(!comm.allcommon(is.null(pairs.gbd), comm = comm)){
    comm.stop("pairs.gbd is not common.", comm = comm)
  }
  if(!is.null(pairs.gbd)){
    if(!comm.allcommon(ncol(pairs.gbd) == 2, comm = comm)){
      comm.stop("pairs.gbd should have 2 columns.", comm = comm)
    }
  } else{
    ### Initial pairs.gbd if NULL.
    pairs.gbd <- comm.allpairs(N, diag = diag, symmetric = symmetric,
                               comm = comm)
  }

  ### Allocate values for all given pairs (i, j).
  pairs <- do.call("rbind", allgather(pairs.gbd, comm = comm))
  value <- rep(0.0, nrow(pairs))

  ### Compute.
  local.id <- N.cumsum[COMM.RANK + 1]:(N.cumsum[COMM.RANK + 2] - 1)
  for(i.rank in 0:(COMM.SIZE - 1)){
    other.id <- N.cumsum[i.rank + 1]:(N.cumsum[i.rank + 2] - 1)
    X.other <- bcast(X.gbd, rank.source = i.rank, comm = comm)

    id.sub <- which(pairs[, 1] %in% local.id & pairs[, 2] %in% other.id)
    if(length(id.sub) > 0){
      for(i.id in id.sub){
        x <- X.gbd[local.id == pairs[i.id, 1],]
        y <- X.other[other.id == pairs[i.id, 2],]

        value[i.id] <- FUN(x, y, ...)
      }
    }
  }

  ### Return.
  value <- spmd.allreduce.double(value, op = "sum", comm = comm)
  ret <- cbind(pairs, value)
  colnames(ret) <- c("i", "j", "value")
  rownames(ret) <- NULL
  ret
} # End of comm.pairwise().

