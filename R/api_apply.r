### These functions are supposed to run in SPMD, even when pbd.model = "mw"

array.to.list <- function(jid, X, dim.X, MARGIN){
  tl <- length(dim.X)
  text.X <- "X["
  for(i in 1:tl){
    if(i == MARGIN){
      text.X <- paste(text.X, "c(jid)", sep = "")
    }
    if(i < tl){
      text.X <- paste(text.X, ",", sep = "")
    }
  }
  text.X <- paste(text.X, "]", sep = "")
  ret <- eval(parse(text = text.X))

  dim.X[MARGIN] <- length(jid)
  dim(ret) <- dim.X
  ret
} # End of array.to.list().

pbdApply <- function(X, MARGIN, FUN, ..., pbd.mode = c("mw", "spmd"),
    rank.source = .SPMD.CT$rank.root, comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm)
  COMM.RANK <- spmd.comm.rank(comm)

  ### Redistributing data for MW.
  if(pbd.mode[1] == "mw"){
    MARGIN <- as.integer(MARGIN)
    new.X <- NULL 
    if(COMM.RANK == rank.source){
      if(! is.array(X)){
        stop("X should be an array")
      }
      alljid <- get.jid(dim(X)[MARGIN], comm = comm, all = TRUE)
      new.X <- lapply(alljid, array.to.list, X, dim(X), MARGIN) 
    }

    if(length(new.X) < COMM.SIZE){
      new.X <- c(new.X, rep(list(NULL), COMM.SIZE - length(new.X)))
    }

    X <- spmd.scatter.array(new.X, rank.source = rank.source, comm = comm)
  }

  ### Run as SPMD.
  ret <- apply(X, MARGIN, FUN, ...)

  ### Gather data for MW.
  if(pbd.mode[1] == "mw"){
    ret <- spmd.gather.object(ret, rank.dest = rank.source, comm = comm)
    if(COMM.RANK != rank.source){
      ret <- NULL
    }
  }

  ret
} # End of pbdApply().

