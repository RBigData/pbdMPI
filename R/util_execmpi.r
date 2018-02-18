### Utility

execmpi <- function(spmd.code, mpicmd = "mpiexec", nranks = 2L,
    temp = tempfile(),
    intern = FALSE, ignore.stdout = FALSE, ignore.stderr = FALSE,
    wait = TRUE){
  ### Input checks
  if(!is.character(spmd.code)){
    stop("argument 'spmd.code' must be a character string")
  } else if(length(spmd.code) == 0){
    stop("argument 'spmd.code' must be a non-empty character string")
  } else if (length(spmd.code) > 1){
    warning("spmd.code has length > 1; only the first element will be used")
    spmd.code <- spmd.code[1L]
  }
  nranks <- as.integer(nranks)
  if(nranks <= 0){
    stop("argument 'nranks' must be a integer and greater than 0.")
  }

  ### Dump spmd.code to temp file, execute
  # cat(spmd.code, file = temp)
  conn <- file(temp, open="wt")
  writeLines(spmd.code, conn)
  close(conn)

  ### Make a cmd.
  cmd <- paste(mpicmd, "-np", nranks, "Rscript", temp)
  print(cmd)
  system(cmd, intern = intern, ignore.stdout = ignore.stdout,
         ignore.stderr = ignore.stderr, wait = wait)
} # End of execmpi().

