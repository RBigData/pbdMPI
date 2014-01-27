### This file contains some useful tools.

divide.job <- function(n, method = .SPMD.CT$divide.method[1],
    comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)

  jid <- NULL
  if(n > COMM.SIZE){
    if(method[1] == "block"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE
      if(n.residual == 0){
        jid <- 1:n.job + COMM.RANK * n.job
      } else{
        if(COMM.RANK < (COMM.SIZE - n.residual)){
          jid <- 1:n.job + COMM.RANK * n.job
        } else{
          jid <- 1:(n.job + 1) + COMM.RANK * (n.job + 1) -
                 (COMM.SIZE - n.residual)
        }
      }
    } else if(method[1] == "block0"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE
      if(COMM.RANK < n.residual){
        jid <- 1:(n.job + 1) + COMM.RANK * (n.job + 1)
      } else{
        jid <- 1:n.job + n.residual * (n.job + 1) +
               (COMM.RANK - n.residual) * n.job
      }
    } else if(method[1] == "cycle"){
      jid <- which((0:(n - 1)) %% COMM.SIZE == COMM.RANK)
    }
  } else{
    if(COMM.RANK < n){
      jid <- COMM.RANK + 1
    }
  }

  jid
} # End of divide.job().

divide.job.all <- function(n, method = .SPMD.CT$divide.method[1],
    comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)

  alljid <- rep(list(NULL), COMM.SIZE)
  if(n > COMM.SIZE){
    if(method[1] == "block"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE

      for(i.rank in 1:COMM.SIZE){
        if(n.residual == 0){
          alljid[[i.rank]] <- 1:n.job + (i.rank - 1) * n.job
        } else{
          if((i.rank - 1) < (COMM.SIZE - n.residual)){
            alljid[[i.rank]] <- 1:n.job + (i.rank - 1) * n.job
          } else{
            alljid[[i.rank]] <- 1:(n.job + 1) + (i.rank - 1) * (n.job + 1) -
                                (COMM.SIZE - n.residual)
          }
        }
      }
    } else if(method[1] == "block0"){
      n.job <- floor(n / COMM.SIZE)
      n.residual <- n %% COMM.SIZE

      for(i.rank in 1:COMM.SIZE){
        if((i.rank - 1) < n.residual){
          alljid[[i.rank]] <- 1:(n.job + 1) + (i.rank - 1) * (n.job + 1)
        } else{
          alljid[[i.rank]] <- 1:n.job + n.residual * (n.job + 1) +
                              ((i.rank - 1) - n.residual) * n.job
        }
      }
    } else if(method[1] == "cycle"){
      for(i.rank in 1:COMM.SIZE){
        alljid[[i.rank]] <- which((0:(n - 1)) %% COMM.SIZE == (i.rank - 1))
      }
    }
  } else{
    for(i.rank in 1:COMM.SIZE){
      if(i.rank <= n){
        alljid[i.rank] <- list(i.rank)
      }
    }
  }

  alljid
} # End of divide.job.all().

get.jid <- function(n, method = .SPMD.CT$divide.method[1], all = FALSE,
    comm = .SPMD.CT$comm){
  if(! method[1] %in% .SPMD.CT$divide.method){
    stop("The method for dividing jobs is not found.")
  }

  if(all){
    ret <- divide.job.all(n, method = method, comm = comm)
  } else{
    ret <- divide.job(n, method = method, comm = comm)
  }

  ret
} # End of get.jid().

