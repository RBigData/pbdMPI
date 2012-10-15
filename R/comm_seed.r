### Seed functions for random number generators.

comm.set.seed <- function(seed = rep(12345, 6), diff = FALSE,
    comm = .SPMD.CT$comm){
  if(exists(".lec.Random.seed.table", envir = .GlobalEnv)){
    name <- get(".lec.Random.seed.table", envir = .GlobalEnv)$name
    if(! is.null(name)){
      eval(.lec.DeleteStream(name), envir = .GlobalEnv)
    }
  }

  if(diff){
    names <- as.character(0:(comm.size() - 1))
    name <- as.character(comm.rank(comm))
  } else{
    names <- "0"
    name <- "0"
  }

  invisible(eval(.lec.SetPackageSeed(seed), envir = .GlobalEnv))
  eval(.lec.CreateStream(names), envir = .GlobalEnv)
  eval(.lec.CurrentStream(name), envir = .GlobalEnv)
  invisible()
} # End of comm.set.seed().

comm.end.seed <- function(comm = .SPMD.CT$comm){
  eval(.lec.CurrentStreamEnd(), envir = .GlobalEnv)
  invisible()
} # End of comm.end.seed().

comm.reset.seed <- function(comm = .SPMD.CT$comm){
  seed.table <- get(".lec.Random.seed.table", envir = .GlobalEnv)

  if(length(seed.table$name) == comm.size(comm)){
    name <- as.character(comm.rank(comm))
  } else{
    name <- "0"
  }

  eval(.lec.CurrentStreamEnd(), envir = .GlobalEnv)
  eval(.lec.ResetStartStream(name), envir = .GlobalEnv)
  eval(.lec.CurrentStream(name), envir = .GlobalEnv)
  invisible()
} # End of comm.reset.seed().

