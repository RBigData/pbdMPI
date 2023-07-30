### Seed functions for random number generators.

## comm.set.stream
## 
## Instead of associating streams with ranks, we can now associate them with
## a vector, bringing reproducibility that is independent of the number of
## ranks. Typically, the vector is the same one that was chunked across ranks.
## Further, this enables the same reproducibility in the \pkg{parallel} 
## package, bringing independence of the number of cores used and full 
## reproducibility across two levels of parallelism. See 
## https://stackoverflow.com/questions/67662603/parallel-processing-in-r-using-parallel-package-not-reproducible-with-differen ## 
## Independent streams are user-enabled at the start of each vector element 
## processing with this function. Numbering of streams starts from 1 and is
## global, corresponding to the global indices of the relevant chunked vector.
## Switching between streams on the same rank continues each stream from where
## it left off. Ranks are not aware of streams set by other ranks.
## 
## Internally, all ranks set up all streams for the relevant vector. If 
## extremely long vectors are concerned, resource-independent reproducibility
## can be managed with a utility vector that is as long as the maximum 
## parallelism anticipated.
## 
## The main memory requirement is of order 6*length(vector) for the RNG state.
##
comm.set.stream <- function(name, save.last = TRUE, comm = .pbd_env$SPMD.CT$comm) {
  ## to be used when independent streams were set in comm.set.seed
  if(.lec.StreamExists(as.character(name))) {
    invisible(eval(.lec.CurrentStreamEnd(), envir = .GlobalEnv)) # save current stream state
    invisible(eval(.lec.CurrentStream(as.character(name)), envir = .GlobalEnv)) # set new stream where it left off
  } else {
    comm.stop(paste("Stream", name, "does not exist"), comm = comm)
  }
  invisible()
} # End of comm.set.stream().

## state is is now deprecated. Use get.stream.state and set.stream.state.
## streams is the number of streams needed. Typically, this is length(vector),
## where vector is the same one that was chunked with comm.chunk().
## To restore RNG after old = comm.set.seed(...), use RNGkind(old).
## 
## (TODO Allow creation of only required streams - by comm.chunk() - rather 
## than all from the beginning. This will reduce the memory footprint 
## in distributed computing. This is possible because streams are named in
## .lec.Random.seed.table.)
## 
comm.set.seed <- function(seed, diff = FALSE, state = NULL, streams = NULL,
                          comm = .pbd_env$SPMD.CT$comm){
  if(!is.null(state)) comm.stop("comm.set.seed parameter state is deprecated")
  if(exists(".lec.Random.seed.table", envir = .GlobalEnv)){
    names <- get(".lec.Random.seed.table", envir = .GlobalEnv)$name
    if(length(names) > 0) .lec.DeleteStream(names)
  } else {
    comm.stop(paste(".lec.Random.seed.table does not exist"), comm = comm)
  }
  if(length(seed) == 1){
    seed <- rep(seed, 6)
  }
  seed <- as.integer(seed[1:6])
  ## Ensure that all ranks have same seed by broadcasting from rank 0
  seed <- spmd.bcast.integer(seed, rank.source = 0L, comm = comm)

  ## If different seeds needed, set streams with names
  if(diff){
    if(is.null(streams)) { # set streams by ranks
      names <- as.character(0:(comm.size(comm) - 1))
      name <- as.character(comm.rank(comm))
    } else { # set numbered streams 1:streams
      names <- as.character(1:as.integer(streams)) # vector of stream names
      name <- as.character(1)  # current stream will be set to 1
    }
  } else{ # Same stream for all
    names <- "0"
    name <- "0"
  }

  invisible(eval(.lec.SetPackageSeed(seed), envir = .GlobalEnv)) # set seed
  invisible(eval(.lec.CreateStream(names), envir = .GlobalEnv)) # create streams
  old.kind <- .lec.CurrentStream(name)[1]
  invisible(old.kind)  # return previous RNGkind
} # End of comm.set.seed().

comm.reset.seed <- function(comm = .pbd_env$SPMD.CT$comm){
  comm.stop(paste("comm.reset.seed is deprecated."), comm = comm)
  invisible()
} # End of comm.reset.seed().
comm.end.seed <- function(comm = .pbd_env$SPMD.CT$comm){
  comm.stop(paste("comm.end.seed is deprecated."), comm = comm)
  invisible()
} # End of comm.end.seed().

set.stream.state <- function(state){
  ### Terminate current stream first to get the current state.
  name = .lec.CurrentStreamEnd(RNGkind())
  old.state <- list(seed = .lec.GetState(name), name = name)
  
  ### Set the requested state.
  invisible(.lec.SetSeed(state$name, state$seed))
  invisible(.lec.CurrentStream(state$name))

  invisible(old.state)
} # End of set.stream.state().

get.stream.state <- function(){
  ### Terminate the stream first to get the current state.
  name = .lec.CurrentStreamEnd(RNGkind())
  state <- list(seed = .lec.GetState(name), name = name)

  ### Set the state back to stream as though nothing happened.
  invisible(.lec.SetSeed(name, state$seed))
  invisible(.lec.CurrentStream(name))

  state
} # End of get.stream.state().

