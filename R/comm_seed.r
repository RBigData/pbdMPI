#' Parallel random number generation with reproducible results
#' 
#' These functions control the parallel-capable L'Ecuyer-CMRG pseudo-random 
#' number generator (RNG) on clusters and in multicore parallel applications for 
#' reproducible results. Reproducibility is possible across different node and
#' core configurations by associating the RNG streams with an application 
#' vector. 
#' 
#' @param seed
#' A single value, interpreted as an integer.
#' @param diff 
#' Logical indicating if the parallel instances should have different random
#' streams.
#' @param state 
#' In function \code{comm.set.seed}, this parameter is deprecated. In function 
#' \code{comm.set.stream}, it restarts 
#' a stream from a previously saved \code{state <- comm.set.stream()}.
#' @param streams 
#' An vector of sequential integers specifying the streams to be prepared on
#' the current rank. Typically, this is used by `comm.chunk()` to prepare
#' correct streams for each rank, which are aligned with the vector being
#' chunk-ed. 
#' @param comm
#' The communicator that determines MPI rank numbers.
#' 
#' @return 
#' \code{comm.set.seed} engages the L'Ecuyer-CMRG RNG and invisibly returns
#' the previous RNG in use (Output of RNGkind()[1]). Capturing it, enables 
#' the restoration of the
#' previous RNG with \code{\link{RNGkind}}. See examples of use in 
#' \code{demo/seed_rank.r} and \code{demo/seed_vec.r}.
#' 
#' 
#' @details
#' This implementation uses the function \code{\link{parallel::nextRNGStream}}
#' in package \code{parallel} to set up streams appropriate for working on a
#' cluster system with MPI. The main difference from \code{parallel} is
#' that it adds a reproducibility capability with vector-based
#' streams that works across different numbers of nodes or cores by associating
#' streams with an application vector.
#' 
#' Vector-based streams are best set up with the higher level function 
#' \code{\link{comm.chunk}} instead of using \code{comm.set.stream} directly.
#' \code{\link{comm.chunk}} will set up only the streams that each rank needs 
#' and provides the information necessary to use them.
#' 
#' The function uses \code{parallel}'s
#' \code{nextRNGStream()} and sets up the parallel stream seeds in the
#' \code{.pbd_env$RNG} environment, which are then managed with
#' \code{\link{comm.set.stream}}. There is only one communication broadcast in
#' this implementation that ensures all ranks have the same seed as rank 0.
#' 
#' When rank-based streams are set up, \code{\link{comm.chunk}} with 
#' \code{form = "number"} and \code{rng = TRUE} parameters, streams are 
#' different for each rank and switching is not needed. Vector-based streams
#' are obtained with \code{form = "vector"} and \code{rng = TRUE} parameters.
#' In this latter case, the vector returned to each
#' rank contains the stream numbers (and vector components) that the rank owns.
#' Switch with \code{comm.set.stream(v)}, where v is one of the stream numbers.
#' Switching back and forth is allowed, with each stream continuing where it
#' left off.
#' 
#' ## RNG Notes
#' R sessions connected by MPI begin like other R sessions as discussed in
#' \code{\link{base::Random}}. On first use of random number generation, 
#' each rank computes its own seed from a combination of clock time and process
#' id (unless it reads a previously saved workspace, which is not recommended). 
#' Because of asynchronous execution, imperfectly synchronized node clocks,
#' and likely different process ids, this
#' almost guarantees unique seeds and most likely results in independent 
#' streams. However, this is not reproducible and not guaranteed. Both 
#' reproducibility and guarantee are brought by the use of the L'Ecuyer-CMRG 
#' generator implementation in \code{\link{parallel::nestRNGStream}} and the
#' use of \code{comm.set.seed} and \code{\link{comm.set.stream}} adaptation for
#' parallel computing on cluster systems.
#' 
#' At a high level, the L'Ecuyer-CMRG pseudo-random number generator can 
#' take jumps (advance the seed) in its 
#' stream (about 2^191 long) so that distant substreams can be assigned. The 
#' \code{\link{parallel::nestRNGStream}} implementation takes jumps of 2^127 
#' (about 1.7e38) to provide up to 2^64 (about 1.8e19) independent streams. See
#' \link{https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf}
#' for more details.
#' 
#' In situations that require the same stream on all ranks, a simple 
#' \code{\link{set.seed}} from base R and the default RNG will suffice. 
#' \code{comm.set.seed} will also accomplish this with the \code{diff = FALSE}
#' parameter if switching between same and different streams is needed.
#' 
#' @export
comm.set.seed <- function(seed = NULL, diff = TRUE, state = NULL,
                          streams = NULL, comm = .pbd_env$SPMD.CT$comm) {
  if(!is.null(state)) 
    warning("comm.set.seed parameter state is deprecated. Now ignored.")

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

      ## Enables resource-independent reproducibility for \code{parallel} 
      ## package. See
      ## https://stackoverflow.com/questions/67662603/parallel-processing-in-r-using-parallel-package-not-reproducible-with-differen 
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

#' Switching streams, getting and setting states of RNG set up by 
#' \code{comm.set.seed} for the L'Ecuyer-CMRG generator
#' 
#' @param name
#' Stream number that is coercible to character, indicating to continue 
#' generating from that stream.
#' @param reset 
#' If true, reset the requested stream back to its beginning.
#' @param state
#' If non-NULL, a stream state (a list with one named element, which is the
#' 6-element L'Ecuyer-CMRG \code{.Random.seed}, probably captured earlier
#' with \code{state <- comm.set.stream()}). The stream name, if different from
#' a provided parameter \code{name}, has precedence, but a warning is produced.
#' Further, the requesting rank must own the stream.
#' @param comm
#' The communicator that determines MPI rank numbers.
#' 
#' @return 
#' Invisibly returns the current stream number as character.
#' 
#' @details
#' Saves current state and stream number in the .pbd_env$RNG environment and 
#' starts the requested stream or continues it from where it left off.
#' 
#' If no parameters are given, no stream change is made and the current stream
#' named state is invisibly returned as a list with one named (by stream 
#' number) element, giving the 6-element integer vector of its current 
#' \code{.Random.seed}.
#' 
#' See examples of use in 
#' \code{demo/seed_rank.r} and \code{demo/seed_vec.r}.
#' 
#' @export
comm.set.stream <- function(name = NULL, reset = FALSE, state = NULL,
                            comm = .pbd_env$SPMD.CT$comm) {
  if(exists("RNG", envir = .pbd_env, inherits = FALSE)) {
    RNG = get("RNG", envir = .pbd_env, inherits = FALSE)
    
    if(!is.null(state)) {
      if(!is.null(name) && name != names(state)) 
        warning("name conflicts with names(state). names(state) wins.")
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
 

