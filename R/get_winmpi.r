### This function is only called by "pbdMPI/src/Makevars.win" to obtain
### possible MPI dynamic/static library from the environment variable
### "MPI_ROOT" preset by users.
get.winlib <- function(arch = c("32", "64")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 

  lib.file <- try(paste(Sys.getenv(mpi.root),
                        c("/bin/libmpi.dll", "/lib/libmpi.a"), sep = ""))
  flag.found <- FALSE
  for(i.file in lib.file){
    if(file.exists(i.file)){
      mpi.lib <- gsub("(.*)(/libmpi.*)", "\\1", i.file)
      mpi.lib <- paste("-L\"", mpi.lib, "\" -lmpi", sep = "")
      cat(mpi.lib)
      flag.found <- TRUE
      break
    }
  }

  # Try to find MS-MPI
  if(!flag.found){
    if(arch == "32"){
      arch <- "i386"
    } else if(arch == "64"){
      arch <- "amd64"
    } else{
      stop("arch is not found.")
    }

    lib.file <- try(paste(Sys.getenv(mpi.root), "/Lib/", arch,
                          "/msmpi.lib", sep = ""))
    for(i.file in lib.file){
      if(file.exists(i.file)){
        mpi.lib <- paste("\"", i.file, "\"", sep = "")
        cat(mpi.lib)
        break
      }
    }
  }

  invisible()
} # End of get.winlib().


get.wininc <- function(arch = c("32", "64")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 

  lib.file <- try(paste(Sys.getenv(mpi.root), "/include/mpi.h", sep = ""))
  flag.found <- FALSE
  for(i.file in lib.file){
    if(file.exists(i.file)){
      mpi.inc <- gsub("(.*)(/mpi.h)", "\\1", i.file)
      cat(mpi.inc)
      flag.found <- TRUE
      break
    }
  }

  # Try to find MS-MPI
  if(!flag.found){
    lib.file <- try(paste(Sys.getenv(mpi.root), "/Inc/mpi.h", sep = ""))
    for(i.file in lib.file){
      if(file.exists(i.file)){
        mpi.inc <- gsub("(.*)(/mpi.h)", "\\1", i.file)
        cat(mpi.inc)
        break
      }
    }
  }

  invisible()
} # End of get.wininc().

