### This function is only called by "pbdMPI/src/Makevars.win" to obtain
### possible MPI dynamic/static library from the environment variable
### "MPI_ROOT" preset by users.
get.winlib <- function(arch = c("32", "64"), type = c("MS-MPI", "MPICH2")){
  mpi.root <- paste("MPI_ROOT_", arch[1], sep = "") 
  mpi.root <- Sys.getenv(mpi.root)

  if(type[1] == "MS-MPI"){
    ### MS-MPI
    if(arch[1] == "32"){
      arch.c <- "i386"
    } else{
      arch.c <- "amd64"
    }

    lib.file <- try(paste(mpi.root, "/Lib/", arch.c, "/msmpi.lib", sep = ""))
    if(file.exists(lib.file)){
      mpi.lib <- shortPathName(lib.file)
      mpi.lib <- gsub("\\\\", "/", mpi.lib)
      cat(mpi.lib)
    } else{
      ### Try Winbuilder
      mpi.root <- Sys.getenv("MPI_HOME")
      lib.file <- try(paste(mpi.root, "/Lib/", arch.c, "/msmpi.lib", sep = ""))
      if(file.exists(lib.file)){
        mpi.lib <- shortPathName(lib.file)
        mpi.lib <- gsub("\\\\", "/", mpi.lib)
        cat(mpi.lib)
      } else{
        ### Try MS-MPI default
        if(arch[1] == "32"){
          mpi.lib <- Sys.getenv("MSMPI_LIB32")
        } else{
          mpi.lib <- Sys.getenv("MSMPI_LIB64")
        }

        lib.file <- try(paste(mpi.lib, "/msmpi.lib", sep = ""))
        if(file.exists(lib.file)){
          mpi.lib <- shortPathName(lib.file)
          mpi.lib <- gsub("\\\\", "/", mpi.lib)
          cat(mpi.lib)
        } else{
          cat("msmpi.lib is not found.\n")
        }
      }
    }
  } else{
    ### MPICH2
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

  if(type[1] == "MS-MPI"){
    ### MS-MPI
    inc.file <- try(paste(mpi.root, "/Inc/mpi.h", sep = ""))
    inc.file <- gsub("\\\\", "/", inc.file)

    if(!file.exists(inc.file)){
      ### Try Winbuilder
      mpi.root <- gsub("\\\\", "/", Sys.getenv("MPI_HOME"))
      inc.file <- try(paste(mpi.root, "/Inc/mpi.h", sep = ""))

      if(!file.exists(inc.file)){
        ### Try MS-MPI default
        mpi.inc <- gsub("\\\\", "/", Sys.getenv("MPI_INC"))
        inc.file <- try(paste(mpi.inc, "/mpi.h", sep = ""))

        if(!file.exists(lib.file)){
          cat("mpi.h is not found.\n")
        }
      }
    }

    mpi.inc <- gsub("(.*)(/mpi.h)", "\\1", inc.file)
    mpi.inc <- shortPathName(mpi.inc)
    cat(mpi.inc)
  } else{
    ## MPICH2
    inc.file <- try(paste(mpi.root, "/include/mpi.h", sep = ""))
    inc.file <- gsub("\\\\", "/", inc.file)

    if(!file.exists(inc.file)){
      cat("mpi.h is not found.\n")
    }

    mpi.inc <- gsub("(.*)(/mpi.h)", "\\1", inc.file)
    cat(mpi.inc)
  }

  invisible()
} # End of get.wininc().
