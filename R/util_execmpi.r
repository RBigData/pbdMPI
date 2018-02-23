### Utility

execmpi <- function(spmd.code = NULL, spmd.file = NULL, mpicmd = "mpiexec",
    nranks = 2L, intern = FALSE, ignore.stdout = TRUE,
    ignore.stderr = TRUE, wait = FALSE){
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

  ### Make a cmd.
  log.file <- tempfile()
  cmd <- paste(mpicmd, "-np", nranks, "Rscript", spmd.file, sep = " ")
  # print(cmd)
  system(cmd, intern = intern, ignore.stdout = ignore.stdout,
         ignore.stderr = ignore.stderr, wait = wait)
} # End of execmpi().

