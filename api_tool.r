### This file contains some useful tools.

get.jid.internal <- function(n, method, COMM.SIZE, COMM.RANK, reduced)
{
  jid <- NULL
  if(n > COMM.SIZE){
    if(method[1] == "block"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE
      if(n.residual == 0){
        if (reduced){
          jid <- list(start=1 + COMM.RANK * n.job, length=n.job)
        } else {
          jid <- 1:n.job + COMM.RANK * n.job
        }
      } else{
        if(COMM.RANK < (COMM.SIZE - n.residual)){
          if (reduced){
            jid <- list(start=1 + COMM.RANK * n.job, length=n.job)
          } else {
            jid <- 1:n.job + COMM.RANK * n.job
          }
        } else{
          if (reduced){
            jid <- list(start=1 + COMM.RANK * (n.job + 1) - (COMM.SIZE - n.residual), length=n.job+1)
          } else {
            jid <- 1:(n.job + 1) + COMM.RANK * (n.job + 1) -
                   (COMM.SIZE - n.residual)
          }
        }
      }
    } else if(method[1] == "block0"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE
      if(COMM.RANK < n.residual){
        if (reduced){
          jid <- list(start=1 + COMM.RANK * (n.job + 1), length=n.job + 1)
        } else {
          jid <- 1:(n.job + 1) + COMM.RANK * (n.job + 1)
        }
      } else{
        if (reduced){
          jid <- list(start=1 + n.residual * (n.job + 1) + (COMM.RANK - n.residual) * n.job, length=n.job)
        } else {
          jid <- 1:n.job + n.residual * (n.job + 1) +
                 (COMM.RANK - n.residual) * n.job
        }
      }
    } else if(method[1] == "cycle"){
      ### FIXME reduced?
      jid <- which((0:(n - 1)) %% COMM.SIZE == COMM.RANK)
    }
  } else{
    if(COMM.RANK < n){
      ### FIXME reduced?
      jid <- COMM.RANK + 1
    }
  }

  jid
}


divide.job <- function(n, method = .SPMD.CT$divide.method[1],
    comm = .SPMD.CT$comm, reduced = FALSE){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)
  
  jid <- get.jid.internal(n=n, method=method, COMM.SIZE=COMM.SIZE, COMM.RANK=COMM.RANK, reduced=reduced)
  
  jid
}


divide.job.all <- function(n, method = .SPMD.CT$divide.method[1],
    comm = .SPMD.CT$comm, reduced = FALSE){
  COMM.SIZE <- spmd.comm.size(comm)

  alljid <- rep(list(NULL), COMM.SIZE)
  
  for(i.rank in 1:COMM.SIZE){
    alljid[[i.rank]] <- get.jid.internal(n=n, method=method, COMM.SIZE=COMM.SIZE, COMM.RANK=i.rank-1, reduced=reduced)
  }
  
  alljid
} # End of divide.job.all().

get.jid <- function(n, method = .SPMD.CT$divide.method[1], all = FALSE,
    comm = .SPMD.CT$comm, reduced = FALSE){
  if(! method[1] %in% .SPMD.CT$divide.method){
    stop("The method for dividing jobs is not found.")
  }

  if(all){
    ret <- divide.job.all(n, method = method, comm = comm)
  } else{
    ret <- divide.job(n, method = method, comm = comm, reduced=reduced)
  }

  ret
} # End of get.jid().

