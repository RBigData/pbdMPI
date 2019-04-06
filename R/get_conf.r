### This file is only called by
###   "pbd*/src/Makevars.in" and "pbd*/src/Makevar.win"
### to find the default configurations from
###   "pbd*/etc${R_ARCH}/Makconf".
get.conf <- function(arg, arch = '', package = "pbdMPI", return = FALSE){
  if(.Platform$OS.type == "windows"){
    if(arch != "/i386" || arch != "/x64"){
      arch <- sessionInfo()$R.version$arch
      if(arch == "i386"){
        arch <- "/i386"
      } else if(arch == "x86_64"){
        arch <- "/x64"
      } else{
        cat(arch, "is not matched.\n")
      }
    }
  }

  file.name <- paste("./etc", arch, "/Makeconf", sep = "")
  file.path <- tools::file_path_as_absolute(
                 system.file(file.name, package = package))
  ret <- scan(file.path, what = character(), sep = "\n", quiet = TRUE)

  id <- grep(paste("^", arg, " = ", sep = ""), ret)
  if(length(id) > 0){
    ret <- gsub(paste("^", arg, " = (.*)", sep = ""), "\\1", ret[id[1]])
    if(arg == "MPI_LIB" && .Platform$OS.type == "windows" &&
       length(grep("-L", ret)) == 0){
      if(length(grep(".*pbdMPI/libs/x64/libmsmpi64.a", ret[1])) == 1){
        ret <- tools::file_path_as_absolute(
                 system.file("libs/x64/libmsmpi64.a", package = "pbdMPI"))
      } else{
        ret <- gsub("\\\\", "/", utils::shortPathName(ret))
      }
    }

    if(!return){
      cat(ret)
    } else{
      return(invisible(ret))
    }
  } else{
    stop("The arg is not found.")
  }

  invisible()
} # End of get.conf().
