### Seed functions for random number generators.
### 
### Reworking to dependence on parallel package instead of rlecuyer
### ###############################################################
### A simpler interface that's integrated better to R
### Only nextRNGStream() and nextRNGSubStream() need to be used (probably because 
### we are only skipping with seeds. We have an ability to skip around the big
### circle of pseudo random numbers!!!!)


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

## state is now deprecated. Use get.stream.state and set.stream.state.
## streams is the number of streams needed. Typically, this is length(vector),
## where vector is the same one that was chunked with comm.chunk().
## To restore RNG after old = comm.set.seed(...), use RNGkind(old).
## 
## Example of restoring pre-L'Ecuyer RNG is in demo/seed_rank.r

#' Parallel random number generation for reproducible results, including 
#' reproducibility with parallelization. Tailored for MPI use on clusters but
#' also capable for the parallel package's multicore components.
#' 
#' @param seed
#' A single value, interpreted as an integer.
#' @param diff 
#' Logical indicating if the parallel instances should have different random
#' streams.
#' @param state 
#' In function `comm.set.stream()`, a generator state for restarts in a stream
#' produced by an earlier call to `comm.set.stream()`. In function 
#' `comm.set.seed()`, the parameter is deprecated.
#' @param streams 
#' An vector of sequential integers specifying the streams to be prepared on
#' the current rank. Typically, this is used by `comm.chunk()` to prepare
#' correct streams for each rank, which are aligned with the vector being
#' chunk-ed. 
#' @param comm
#' The communicator that determines ranks.
#' 
#' @export
comm.set.seed <- function(seed = NULL, diff = FALSE, state = NULL,
                          streams = NULL, comm = .pbd_env$SPMD.CT$comm) {
  if(!is.null(state)) comm.stop("comm.set.seed parameter state is deprecated")

  prng = "L'Ecuyer-CMRG"
  
  ## If RNG exists in .pbd_env, grab what is needed from it (original RNG)
  if(exists("RNG", envir = .pbd_env, inherits = FALSE)) {
    RNG = get("RNG", envir = .pbd_env, inherits = FALSE)
    if(RNG$kind != prng) # if exists, it has to be prng!
      comm.stop("Corrupted .pbd_env$RNG", comm = comm)
    kind.old = RNG$kind.old  # keep saved RNG
    seed.old = RNG$seed.old  # keep saved seed
  } else { # record previous RNG and engage prng RNG
    seed.old = NULL
    if(exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
      seed.old = get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    kind.old <- RNGkind(prng)[1L]  # Engage prng RNG
  }
  
  ## Force all ranks to same seed as rank 0 (should be same already anyway)
  seed <- bcast(seed, rank.source = 0L, comm = comm)
  if(!is.null(seed)) set.seed(seed) # Set main seed for prng generator
  ## At this point, all ranks have L'Ecuyer-CMRG generator and possibly same seed
  
  ## Construct new RNG structure to keep track of things
  RNG <- list(kind = prng, # current RNG
                   name = NULL,  # current stream name
                   streams = NULL, # named stream seeds
                   states = NULL, # stream states (seeds to continue)
                   kind.old = kind.old, # pre-pbd RNG
                   seed.old = seed.old) # state of pre-pbd RNG

  ## Determine RNG$streams and RNG$name, and assign .Random.seed  
  if(diff){   ## rank-based or vector-based different streams
    if(is.null(streams)) { # set rank-based streams
      my.stream <- comm.rank(comm) + 1L
      my.seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
      for(i in seq_len(my.stream - 1L)) # skip to my.stream
        my.seed <- parallel::nextRNGStream(my.seed)
      RNG$streams <- list(my.seed)
      names(RNG$streams) <- RNG$name <- as.character(my.stream)
      assign(".Random.seed", my.seed, envir = .GlobalEnv)
      ## Each rank now has own stream
    } else { # set vector-based streams
      Lseed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
      for(i in seq_len(streams[1L] - 1L)) # skip to first needed stream
        Lseed <- parallel::nextRNGStream(Lseed)
      if(all(seq(streams[1L], streams[length(streams)], 1L) == streams)) {
        ## put the required stream seeds into a named list
        RNG$streams <- vector("list", length(streams))
        names(RNG$streams) <- as.character(streams)
        RNG$streams[[as.character(streams[1L])]] <- Lseed # assign first
        for(i in streams[-1L]) { # assign the remaining requested streams
          Nseed <- parallel::nextRNGStream(Lseed)
          Lseed <- RNG$streams[[as.character(i)]] <- Nseed
        }
      } else comm.stop("Requested RNG streams are not sequential.")
      assign(".Random.seed", RNG$streams[[as.character(streams[1L])]],
             envir = .GlobalEnv)
      RNG$name = as.character(streams[1L])
      ## First stream is set as default.
      ## Manage stream switching with comm.set.stream().
    }
  } else { # all ranks use the same stream
    RNG$streams <- list(get(".Random.seed", envir = .GlobalEnv,
                            inherits = FALSE))
    names(RNG$streams) <- as.character(1L)
    RNG$name = as.character(1L) 
    ## The single and same stream is now captured in the RNG structure
  }

  ## Now save the RNG structure in .pbd_env  
  assign("RNG", RNG, envir = .pbd_env)
  
  invisible(RNG$kind.old)  # invisibly return previous RNGkind
} # End of comm.set.seed().

#' @rdname comm.set.seed
#' @export
comm.set.stream <- function(name = NULL, reset = FALSE, state = NULL,
                            comm = .pbd_env$SPMD.CT$comm) {
  if(exists("RNG", envir = .pbd_env, inherits = FALSE)) {
    RNG = get("RNG", envir = .pbd_env, inherits = FALSE)
    
    if(!is.null(state)) {
      if(!is.null(name) && name != names(state)) 
        comm.warning("name conflicts with names(state). names(state) wins.")
      name = names(state) # names(state) overrides name
      state = state[[name]] # strips name for proper integer .Random.seed
    }
    if(reset) name = RNG$name
    if(!is.null(name)) {
      name = as.character(name)
      if(!is.null(RNG$streams[[name]])) { # stream exists
        Lname = RNG$name
        if(Lname != name) # save state of Lname, since switching
          RNG$state[[Lname]] <- get(".Random.seed", envir = .GlobalEnv)
        if(is.null(RNG$state[[name]]) && is.null(state)) reset = TRUE
        if(reset) { # start new stream at its orig seed
          assign(".Random.seed", RNG$streams[[name]], envir = .GlobalEnv)
          RNG$state[[name]] <- NULL # record stream is not paused
          RNG$name = name # record current stream name
        } else { # continue new stream from RNG record or set from state
          if(is.null(state)) state = RNG$state[[name]]
          assign(".Random.seed", state, envir = .GlobalEnv)
          RNG$state[[name]] <- NULL # record stream is not paused
          RNG$name = name # record current stream name
        }
       # if same name & no reset, nothing done except current state returned
      } else comm.stop(paste("Stream", name, "does not exist"), comm = comm)
    } # Nothing to do, just return current named state
  } else comm.stop("No RNG streams are set. Use comm.set.seed().")
  
  ## save changes to RNG to .pbd_env
  assign("RNG", RNG, envir = .pbd_env)
  
  ret = list(get(".Random.seed", envir = .GlobalEnv))
  names(ret) = RNG$name
  invisible(ret) # invisibly return current named state
} # End of comm.set.stream().

comm.end.seed <- function(comm = .pbd_env$SPMD.CT$comm) {
  .Defunct("comm.set.seed", package = "pbdMPI",
           msg = paste("'comm.end.seed' is defunct. Ending L'Ecuyer streams",
                       "is included in comm.set.seed() and comm.set stream().",
                       "\n"))
} # End of comm.end.seed().
comm.reset.seed <- function(comm = .pbd_env$SPMD.CT$comm) {
  .Defunct("comm.set.stream", package = "pbdMPI",
           msg = paste("'comm.reset.seed' is defunct. Instead,",
                       "use comm.set.stream(reset = TRUE)"))
} # End of comm.reset.seed().
comm.seed.state <- function(comm = .pbd_env$SPMD.CT$comm){
  .Defunct("comm.set.stream", package = "pbdMPI",
           msg = paste("'comm.end.seed' is defunct. Instead,",
                       "use comm.set.stream()"))
} # End of comm.seed.state().
 

