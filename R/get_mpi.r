### This function is only called by "pbdMPI/src/Makevars.win" to obtain
### possible MPI dynamic/static library from the environment variable
### "MPI_ROOT" preset by users.
get.mpi <- function(arch = c("32", "64")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 
  lib.file <- try(paste(Sys.getenv(mpi.root),
                        c("/bin/libmpi.dll", "/lib/libmpi.a"), sep = ""))
  for(i.file in lib.file){
    if(file.exists(i.file)){
      cat(gsub("(.*)(/libmpi.*)", "\\1", i.file))
      break
    }
  }
  invisible()
} # End of get.mpi().
