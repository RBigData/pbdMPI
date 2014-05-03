### Distributed all pair-wise functions.
### Assume gbd.major = 1.

comm.allpairs <- function(N, diag = TRUE, symmetric = TRUE,
    comm = .SPMD.CT$comm){
  # Check.
  if(!all(comm.allcommon(N))){
    comm.stop("N should be all the same.")
  }

  # Generate index.matrix.
  jid <- get.jid(N * N)
  ret <- cbind(rep(1:N, each = N)[jid], rep(1:N, N)[jid])
  if(length(ret) > 0 && symmetric){
    ret <- matrix(ret, ncol = 2)
    ret <- ret[ret[, 1] <= ret[, 2],]
  }
  if(length(ret) > 0 && !diag){
    ret <- matrix(ret, ncol = 2)
    ret <- ret[ret[, 1] != ret[, 2],]
  }

  # Check.
  if(length(ret) > 0){
    ret <- matrix(ret, ncol = 2)
  } else{
    ret <- matrix(0, nrow = 0, ncol = 2)
  }

  # Return.
  ret <- comm.load.balance(ret)
  colnames(ret) <- c("i", "j")
  ret
} # End of comm.allpairs().


comm.pairwise <- function(X.gbd, pairs.gbd = NULL, diag = FALSE,
    symmetric = TRUE, comm = .SPMD.CT$comm){
  # Check.
  if(!comm.allcommon(!is.null(pairs.gbd))){
  }

  # Return.
  ret
} # End of comm.pairwise().

