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

  ### Only local diagonal block.
  if(N.gbd > 0){
    ret.local <- matrix(0.0, nrow = N.gbd, ncol = N.gbd)
    for(i in 1:N.gbd){
      for(j in 1:N.gbd){
        ### Check.
        flag <- FALSE
        if(i > j){                      ### lower-triangular.
          flag <- TRUE
        }
        if((!symmetric) && (i < j)){    ### Upper-triangular.
          flag <- TRUE
        }
        if(diag && (i == j)){           ### Diagonals.
          flag <- TRUE
        }
        if(flag){                       ### Compute.
          ret.local[i, j] <- FUN(X.gbd[i,], X.gbd[j,], ...)
        }
      }
    }
  }

  #### Obtain all other ranks.
  if(COMM.SIZE > 1){
    ret.lower <- NULL
    ret.upper <- NULL

    for(i.rank in 0:(COMM.SIZE - 1)){
      if(N.allgbd[i.rank + 1] != 0){
        X.other <- bcast(X.gbd, rank.source = i.rank, comm = comm)

        if(N.gbd > 0){
          ### Lower-triangular block.
          if(COMM.RANK < i.rank){
            tmp <- matrix(0.0, nrow = N.allgbd[i.rank + 1], ncol = N.gbd)
            for(i in 1:N.allgbd[i.rank + 1]){
              for(j in 1:N.gbd){
                ret[i, j] <- FUN(X.other[i,], X.gbd[j,], ...)
              }
            }
            ret.lower <- rbind(ret.lower, tmp)
          }

          ### Upper-triangular block.
          if(COMM.RANK > i.rank && !symmetric){
            tmp <- matrix(0.0, nrow = N.allgbd[i.rank + 1], ncol = N.gbd)
            for(i in 1:N.allgbd[i.rank + 1]){
              for(j in 1:N.gbd){
                ret[i, j] <- FUN(X.other[i,], X.gbd[j,], ...)
              }
            }
            ret.upper <- rbind(ret.upper, tmp)
          }
        }
      }
    }

    ### Combine all blocks.
    if(N.gbd > 0){
      ret <- rbind(ret.upper, ret.local, ret.lower)
    }
  }

  ### WCC TODO: finish indexing for a gbd matrix.
  ### Check symmetric, drop upper-triangular parts if TRUE.
  ### Check diag, drop diagonals if TRUE.
  ### Build the i-j-value matrix.

  ### Return.
  dim(ret) <- c(length(ret) / 3, 3)
  colnames(ret) <- c("i", "j", "value")
  rownames(ret) <- NULL
  ret
} # End of comm.pairwise().

