### This function is only called by "pbdMPI/src/Makevars.win" to obtain
### possible MPI dynamic/static library from the environment variable
### "MPI_ROOT" preset by users.
get.winlib <- function(arch = c("32", "64"), type = c("MS-MPI", "MPICH2")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 
  mpi.root <- Sys.getenv(mpi.root)

  if(type[1] == "MS-MPI"){
    if(arch[1] == "32"){
      arch.c <- "i386"
    } else{
      arch.c <- "amd64"
    }

    lib.file <- try(paste(mpi.root, "/Lib/", arch.c,
                          "/msmpi.lib", sep = ""))
    if(file.exists(lib.file)){
      # mpi.lib <- paste("\"", lib.file, "\"", sep = "")
      mpi.lib <- shortPathName(lib.file)
      mpi.lib <- gsub("\\\\", "/", mpi.lib)
      cat(mpi.lib)
    }
  } else{
    lib.file <- try(paste(mpi.root,
                          c("/bin/libmpi.dll", "/lib/libmpi.a"), sep = ""))
    for(i.file in lib.file){
      if(file.exists(i.file)){
        mpi.lib <- gsub("(.*)(/libmpi.*)", "\\1", i.file)
        mpi.lib <- paste("-L\"", mpi.lib, "\" -lmpi", sep = "")
        cat(mpi.lib)
        break
      }
    }
  }

  invisible()
} # End of get.winlib().

get.wininc <- function(arch = c("32", "64"), type = c("MS-MPI", "MPICH2")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 
  mpi.root <- gsub("\\\\", "/", Sys.getenv(mpi.root))

  if(type[1] == "MS-MPI"){
    lib.file <- try(paste(mpi.root, "/Inc/mpi.h", sep = ""))
  } else{
    lib.file <- try(paste(mpi.root, "/include/mpi.h", sep = ""))
  }

  if(file.exists(lib.file)){
    mpi.inc <- gsub("(.*)(/mpi.h)", "\\1", lib.file)
    cat(mpi.inc)
  }

  invisible()
} # End of get.wininc().
