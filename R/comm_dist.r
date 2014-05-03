### Distributed distance.

comm.dist <- function(X.gbd, method = "euclidean", diag = FALSE, upper = FALSE,
    p = 2, comm = .SPMD.CT$comm){
  COMM.RANK <- spmd.comm.rank(comm)
  COMM.SIZE <- spmd.comm.size(comm)

  # Check.
  N.gbd <- nrow(X.gbd)
  N.allgbd <- spmd.allgather.integer(as.integer(N.gbd), integer(COMM.SIZE),
                                     comm = comm)
  N <- sum(N.allgbd)
  N.cumsum <- c(0, cumsum(N.allgbd))

  # Allocate a full distance matrix.
  ret <- matrix(0.0, nrow = N, ncol = N)

  # Obtain the local rank distance.
  if(nrow(X.gbd) != 0){
    tmp <- as.matrix(dist(X.gbd, method = method, diag = diag,
                          upper = upper, p = p))
    # Replace the diagonal block.
    ret[(N.cumsum[COMM.RANK + 1] + 1):N.cumsum[COMM.RANK + 2],
        (N.cumsum[COMM.RANK + 1] + 1):N.cumsum[COMM.RANK + 2]] <- tmp
  }

  # Obtain all other ranks distance.
  for(i.rank in 0:(COMM.SIZE - 1)){
    if(N.allgbd[i.rank + 1] != 0){
      X.other <- bcast(X.gbd, rank.source = i.rank, comm = comm)

      if(COMM.RANK != i.rank){
        tmp <- as.matrix(dist(rbind(X.other, X.gbd), method = method,
                              diag = diag, upper = upper, p = p))

        # Replace the other diagonal block.
        ret[(N.cumsum[i.rank + 1] + 1):N.cumsum[i.rank + 2],
            (N.cumsum[i.rank + 1] + 1):N.cumsum[i.rank + 2]] <-
          tmp[1:nrow(X.other), 1:nrow(X.other)]

        # Replace the off-diagonal block.
        if(COMM.RANK > i.rank){
          ret[(N.cumsum[COMM.RANK + 1] + 1):N.cumsum[COMM.RANK + 2],
              (N.cumsum[i.rank + 1] + 1):N.cumsum[i.rank + 2]] <-
            tmp[(nrow(X.other) + 1):nrow(tmp), 1:nrow(X.other)]
        } else{
          ret[(N.cumsum[i.rank + 1] + 1):N.cumsum[i.rank + 2],
              (N.cumsum[COMM.RANK + 1] + 1):N.cumsum[COMM.RANK + 2]] <-
            tmp[(nrow(X.other) + 1):nrow(tmp), 1:nrow(X.other)]
        }
      }
    }
  }

  # Return.
  ret <- as.dist(ret, diag = diag, upper = upper)
  ret
} # End of comm.dist().
