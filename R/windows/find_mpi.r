### This function is only called by "pbdMPI/src/Makevars.win" to obtain
### possible MPI dynamic/static library from the environment variable
### "MPI_ROOT" preset by users.
find.mpilib <- function(arch){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 
  lib.file <- try(paste(Sys.getenv(mpi.root),
                        c("/bin/libmpi.dll", "/lib/libmpi.a"), sep = ""))

  ret <- ""
  for(i.file in lib.file){
    if(file.exists(i.file)){
      ret <- gsub("(.*)(/libmpi.*)", "\\1", i.file)
      break
    }
  }

  ret
} # End of find.mpilib().
