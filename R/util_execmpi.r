### Utility

execmpi <- function(spmd.code = NULL, spmd.file = NULL,
    mpicmd = NULL, nranks = 2L, verbose = TRUE){
  ### Check # of ranks.
  nranks <- as.integer(nranks)
  if(nranks <= 0){
    stop("argument 'nranks' must be a integer and greater than 0.")
  }

  ### Input checks
  if(! is.null(spmd.code)){
    if(!is.character(spmd.code)){
      stop("argument 'spmd.code' must be a character string")
    } else if(length(spmd.code) == 0){
      stop("argument 'spmd.code' must be a non-empty character string")
    } else if (length(spmd.code) > 1){
      warning("spmd.code has length > 1; only the first element will be used")
      spmd.code <- spmd.code[1L]
    }

    ### Dump spmd.code to a temp file, execute
    spmd.file <- tempfile()
    on.exit(unlink(spmd.file))
    conn <- file(spmd.file, open = "wt")
    writeLines(spmd.code, conn)
    close(conn)
  } else{
    if(is.null(spmd.file)){
      stop("Either spmd.code or spmd.file should be provided.")
    }
  }
  if(! file.exists(spmd.file)){
    stop("spmd.file does not exist.")
  }

  ### Find MPI executable.
  if(is.null(mpicmd)){
    if(Sys.info()[['sysname']] == "Windows"){
      mpicmd <- try(system("mpiexec", intern = TRUE), silent = TRUE)
      if(class(mpicmd) == "try-error"){
        warning("No MPI executable can be found from PATH.")
        return(invisible(NULL))
      } else{
        mpicmd <- "mpiexec"
      }
    } else{
      mpicmd <- suppressWarnings(system("which mpiexec",
                                 ignore.stderr = TRUE, intern = TRUE))
      if(! is.null(attr(mpicmd, "status"))){
        mpicmd <- suppressWarnings(system("which mpirun",
                                   ignore.stderr = TRUE, intern = TRUE))
        if(! is.null(attr(mpicmd, "status"))){
          mpicmd <- suppressWarnings(system("which orterun",
                                     ignore.stderr = TRUE, intern = TRUE))
          if(! is.null(attr(mpicmd, "status"))){
            mpicmd <- get.conf("MPIEXEC", return = TRUE)
            if(mpicmd == ""){
              mpicmd <- get.conf("MPIRUN", return = TRUE)
              if(mpicmd == ""){
                mpicmd <- get.conf("ORTERUN", return = TRUE)
                if(mpicmd == ""){
                  warning("No MPI executable can be found.")
                  return(invisible(NULL))
                }
              }
            }
          }
        }
      }
    }
  }

  ### Find Rscript.
  if(Sys.info()[['sysname']] == "Windows"){
    rscmd <- paste(Sys.getenv("R_HOME"), "/bin", Sys.getenv("R_ARCH_BIN"),
                   "/Rscript", sep = "")
  } else{
    rscmd <- paste(Sys.getenv("R_HOME"), "/bin/Rscript", sep = "")
  }

  ### Make a cmd.
  if(Sys.info()[['sysname']] == "Windows"){
    cmd <- paste(mpicmd, "-np", nranks, rscmd, spmd.file, sep = " ")
    ### Redirect to log.file will get the message below and fail.
        ### The process cannot access the file because it is being used by
        ### another process.
  } else{
    log.file <- tempfile()
    on.exit(unlink(log.file), add = TRUE)
    cmd <- paste(mpicmd, "-np", nranks, rscmd, spmd.file,
                 ">", log.file, "2>&1 & echo \"PID=$!\" &", sep = " ")
  }
  if(verbose){
    cat(">>> MPI command:\n", cmd, "\n", sep = "")
  }

  ### Run the cmd.
  if(Sys.info()[['sysname']] == "Windows"){
    ret <- system(cmd, intern = TRUE, ignore.stdout = FALSE,
                  ignore.stderr = FALSE, wait = TRUE)
  } else{
    tmp <- system(cmd, intern = TRUE, ignore.stdout = FALSE,
                  ignore.stderr = FALSE, wait = FALSE)
    if(verbose){
      cat(">>> MPI PID:\n", paste(tmp, collapse = "\n"), "\n", sep = "")
    }

    ### Check if the job is finished, otherwise wait for it.
    pid <- gsub("^PID=(.*)$", "\\1", tmp)
    cmd.pid <- paste("ps -p", pid, sep = " ")
    while(TRUE){
      tmp.pid <- suppressWarnings(system(cmd.pid, intern = TRUE))
      if(is.null(attr(tmp.pid, "status"))){
        Sys.sleep(1)
      } else{
        break
      }
    }
  }

  ### Get the output from the log file.
  if(Sys.info()[['sysname']] != "Windows"){
    ret <- readLines(log.file)
  }
  if(verbose){
    cat(">>> MPI results:\n", paste(ret, collapse = "\n"), "\n", sep = "")
  }

  ### Return
  invisible(ret)
} # End of execmpi().

runmpi <- execmpi
