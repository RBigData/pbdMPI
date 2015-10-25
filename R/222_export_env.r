### Export control to new env.
.pbd_env <- new.env()
.pbd_env$SPMD.CT <- SPMD.CT()
.pbd_env$SPMD.OP <- SPMD.OP()
.pbd_env$SPMD.IO <- SPMD.IO()
.pbd_env$SPMD.TP <- SPMD.TP()

### For non-blocking calls.
.pbd_env$SPMD.NB.BUFFER <- list()

### Get MPI options.
.mpiopt_get <- function(main, sub = NULL, envir = .GlobalEnv){
  if(!is.null(sub)){
    envir$.pbd_env[[main]][[sub]]
  } else{
    envir$.pbd_env[[main]]
  }
} # End of .mpiopt_get().

### Set MPI options.
.mpiopt_set <- function(val, main, sub = NULL, envir = .GlobalEnv){
  if(!is.null(sub)){
    envir$.pbd_env[[main]][[sub]] <- val
  } else{
    envir$.pbd_env[[main]] <- val
  }

  invisible()
} # End of .mpiopt_set().

### Initial MPI options.
.mpiopt_init <- function(envir = .GlobalEnv){
  if(!exists(".pbd_env", envir = envir)){
    envir$.pbd_env <- new.env()
  } 
  envir$.pbd_env$SPMD.CT <- SPMD.CT()
  envir$.pbd_env$SPMD.OP <- SPMD.OP()
  envir$.pbd_env$SPMD.IO <- SPMD.IO()
  envir$.pbd_env$SPMD.TP <- SPMD.TP()
  envir$.pbd_env$SPMD.NB.BUFFER <- list()

  invisible()
} # End of .mpiopt_init().

