### Distributed distance.
### Assume gbd.major = 1.

comm.dist <- function(X.gbd, method = "euclidean", diag = FALSE,
    upper = FALSE, p = 2, comm = .SPMD.CT$comm){
  # Check.
  if(!comm.allcommon(length(dim(X.gbd)))){
    comm.stop("Dimension of X.gbd should all equal to 2.", comm = comm)
  }
  if(!comm.allcommon(ncol(X.gbd))){
    comm.stop("X.gbd should have the same # of columns.")
  }

  # Get Info.
  COMM.RANK <- spmd.comm.rank(comm)
  COMM.SIZE <- spmd.comm.size(comm)

  N.gbd <- nrow(X.gbd)
  N.allgbd <- spmd.allgather.integer(as.integer(N.gbd), integer(COMM.SIZE),
                                     comm = comm)
  N <- sum(N.allgbd)
  N.cumsum <- c(1, cumsum(N.allgbd) + 1)

  # Allocate a full distance matrix.
  ret <- matrix(-Inf, nrow = N, ncol = N)

  # Only local diagonal block.
  tmp <- as.matrix(dist(X.gbd, method = method,
                        diag = diag, upper = upper, p = p))
  ret[N.cumsum[COMM.RANK + 1]:(N.cumsum[COMM.RANK + 2] - 1),
      N.cumsum[COMM.RANK + 1]:(N.cumsum[COMM.RANK + 2] - 1)] <- tmp

  # Obtain all other ranks distance.
  for(i.rank in 0:(COMM.SIZE - 1)){
    if(N.allgbd[i.rank + 1] != 0){
      X.other <- bcast(X.gbd, rank.source = i.rank, comm = comm)

      if(COMM.RANK < i.rank){
        # Keep the right order.
        tmp <- as.matrix(dist(rbind(X.gbd, X.other), method = method,
                              diag = diag, upper = upper, p = p))

        # Replace the off-diagonal block.
        ret[N.cumsum[i.rank + 1]:(N.cumsum[i.rank + 2] - 1),
            N.cumsum[COMM.RANK + 1]:(N.cumsum[COMM.RANK + 2] - 1)] <-
          tmp[(nrow(X.gbd) + 1):nrow(tmp), 1:nrow(X.gbd)]
      } else if(COMM.RANK > i.rank){
        # Keep the right order.
        tmp <- as.matrix(dist(rbind(X.other, X.gbd), method = method,
                              diag = diag, upper = upper, p = p))

        # Replace the off-diagonal block.
        ret[N.cumsum[COMM.RANK + 1]:(N.cumsum[COMM.RANK + 2] - 1),
            N.cumsum[i.rank + 1]:(N.cumsum[i.rank + 2] - 1)] <-
          tmp[(nrow(X.other) + 1):nrow(tmp), 1:nrow(X.other)]
      }
    }
  }

  # Return.
  ret <- allreduce(ret, op = "max")
  ret <- as.dist(ret, diag = diag, upper = upper)
  ret
} # End of comm.dist.gbd().
