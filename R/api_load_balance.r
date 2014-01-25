### This file contains functions to load balance of data X.gbd.
### gbd.major = 1 is used as default.

balance.info <- function(X.gbd, comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)

  N.gbd <- nrow(X.gbd)
  N.allgbd <- spmd.allgather.integer(as.integer(N.gbd), integer(COMM.SIZE),
                                     comm = comm)
  N <- sum(N.allgbd)

  ### Try block0 method which is a better way to balance data. However,
  ### this is not necessary in block-cyclic, so useless for ddmatrix.
  n <- floor(N / COMM.SIZE)
  n.residual <- N %% COMM.SIZE
  new.N.allgbd <- rep(n, COMM.SIZE) +
                   rep(c(1, 0), c(n.residual, COMM.SIZE - n.residual))
  rank.org <- rep(0:(COMM.SIZE - 1), N.allgbd)
  rank.belong <- rep(0:(COMM.SIZE - 1), new.N.allgbd)

  ### Build send and recv information if any.
  send.info <- data.frame(org = rank.org[rank.org == COMM.RANK],
                          belong = rank.belong[rank.org == COMM.RANK])
  recv.info <- data.frame(org = rank.org[rank.belong == COMM.RANK],
                          belong = rank.belong[rank.belong == COMM.RANK])

  list(send = send.info, recv = recv.info, N.allgbd = N.allgbd,
       new.N.allgbd = new.N.allgbd)
} # End of balance.info()


load.balance <- function(X.gbd, bal.info = NULL, comm = .SPMD.CT$comm){
  COMM.RANK <- spmd.comm.rank(comm)
  if(is.null(bal.info)){
    bal.info <- balance.info(X.gbd, comm = comm)
  }

  send.to <- as.integer(unique(bal.info$send$belong))
  if(length(send.to) > 0){
    for(i in send.to){
      if(i != COMM.RANK){
        tmp <- X.gbd[bal.info$send$belong == i,]
        spmd.isend.default(tmp, rank.dest = i, tag = COMM.RANK, comm = comm)
      }
    }
  }

  recv.from <- as.integer(unique(bal.info$recv$org))
  if(length(recv.from) > 0){
    ret <- NULL
    for(i in recv.from){
      if(i != COMM.RANK){
        total.row <- sum(bal.info$recv$org == i)
        tmp <- spmd.recv.default(rank.source = i, tag = i, comm = comm)
      } else{
        tmp <- X.gbd[bal.info$send$belong == i,]
      }
      ret <- base:::rbind(ret, tmp)
    }
  }

  if(bal.info$new.N.allgbd[spmd.comm.rank(comm) + 1] == 0){
    ret <- ret[0,]
  }

  spmd.wait()

  ret
} # End of load.balance().


unload.balance <- function(new.X.gbd, bal.info, comm = .SPMD.CT$comm){
  rev.bal.info <- list(send = data.frame(org = bal.info$recv$belong,
                                         belong = bal.info$recv$org),
                       recv = data.frame(org = bal.info$send$belong,
                                         belong = bal.info$send$org),
                       N.allgbd = bal.info$new.N.allgbd,
                       new.N.allgbd = bal.info$N.allgbd)
  load.balance(new.X.gbd, bal.info = rev.bal.info, comm = comm)
} # End of unload.balance().

