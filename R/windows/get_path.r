### This file provodes information of making processes.

spmd.system.file <- function(...){
  tools:::file_path_as_absolute(base:::system.file(..., package = "pbdMPI"))
} # End of spmd.system.file().


### Make Configure.
spmd.mkconf <- function(arch){
  file <- spmd.system.file(paste("Makeconf.", arch, sep = ""))
  ret <- scan(file, what = "character", sep = "\n", quiet = TRUE)
  invisible(ret)
} # End of spmd.mkdonf().

MkConf <- function(arch){
  cat(spmd.mkconf(arch), sep = "\n")
} # End of MkConf().


### MPI_ROOT and MPI_LIB
spmd.pkg.cppflags <- function(arch){
   ret <- spmd.mkconf(arch)
   i <- grep("^MPI_ROOT = ", ret)
   if(length(i) > 0){
     ret <- gsub("^MPI_ROOT = (.*)$", "\\1", ret[i])
   } else{
     ret <- ""
   }
   invisible(ret)
} # End of spmd.pkg.cppflags().

PKG.MPI.ROOT <- function(arch){
  cat(spmd.pkg.cppflags(arch))
} # End of PKG.MPI.ROOT().

spmd.pkg.ldflags <- function(arch){
   ret <- spmd.mkconf(arch)
   i <- grep("^MPI_LIB = ", ret)
   if(length(i) > 0){
     ret <- gsub("^MPI_LIB = (.*)$", "\\1", ret[i])
   } else{
     ret <- ""
   } 
   invisible(ret)
} # End of spmd.pkg.ldflags().

PKG.MPI.LIB <- function(arch){
  cat(spmd.pkg.ldflags(arch))
} # End of PKG.MPI.LIB().


### Header files
spmd.cflags <- function(){
  ret <- spmd.system.file("include")
  cflags <- paste("-I", ret, " ", sep = "") 
  invisible(cflags)
} # End of spmd.cflags().

CFlags <- function(){
  cat(spmd.cflags())
} # End of CFlags().
