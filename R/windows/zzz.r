### Lastest load into a package.

# .First.lib <- function(lib, pkg){
# } # End of .First.lib().

# .Last.lib <- function(libpath){
# } # End of .Last.lib().

.onLoad <- function(libname, pkgname){
  library.dynam("pbdMPI", pkgname, libname)

  # if(! is.loaded("spmd_initialize", PACKAGE = "pbdMPI")){
  #   stop("pbdMPI is not loaded.")
  # }

  # if(! exists(".__DISABLE_MPI_INIT__", envir = .GlobalEnv)){
  #   assign(".__DISABLE_MPI_INIT__", FALSE, envir = .GlobalEnv)
  # }

  if(exists(".__MPI_APTS__", envir = .GlobalEnv)){
    rm(list = c(".__MPI_APTS__"), envir = .GlobalEnv)
  }

  .Call("spmd_initialize", PACKAGE = "pbdMPI")

  ### For seed.
  # if(! exists(".lec.Random.seed.table", envir = .GlobalEnv) &&
  #    ! exists(".Random.seed", envir = .GlobalEnv)){
  #GO if(! exists(".Random.seed", envir = .GlobalEnv)){
  #GO   # seed <- as.integer(Sys.getpid() + Sys.time())
  #GO   seed <- as.integer(runif(6, 1L, 2147483647L))
  #GO   seed <- .Call("spmd_bcast_integer", seed, 0L, 0L, PACKAGE = "pbdMPI")
  #GO   # seed <- rep(seed, 6)
  #GO 
  #GO   comm.size <- .Call("spmd_comm_size", 0L, PACKAGE = "pbdMPI")
  #GO   comm.rank <- .Call("spmd_comm_rank", 0L, PACKAGE = "pbdMPI")
  #GO   names <- as.character(0:(comm.size - 1))
  #GO   name <- as.character(comm.rank)
  #GO 
  #GO   invisible(eval(.lec.old.kind <- RNGkind(), envir = .GlobalEnv))
  #GO   invisible(eval(.lec.SetPackageSeed(seed), envir = .GlobalEnv))
  #GO   invisible(eval(.lec.CreateStream(names), envir = .GlobalEnv))
  #GO   invisible(eval(.lec.CurrentStream(name), envir = .GlobalEnv))
  #GO }

  ### Preload to global environment.
  invisible(eval(parse(text = "pbdMPI:::.mpiopt_init()")))

  invisible()
} # End of .onLoad().

.onUnload <- function(libpath){
  pbdMPI::spmd.finalize()
  library.dynam.unload("pbdMPI", libpath)

  invisible()
} # End of .onUnload().

.onAttach <- function(libname, pkgname){
#   if(interactive()){
#     pbdR.msg <-
# "
#     pbdR is mainly designed for batch environment or in SPMD programming.
#     Please utilize High Performance Computing Resource or consider an
#     allociation via ``http://www.nics.tennessee.edu/getting-an-allocation''
#     with XSEDE at ``http://www.xsede.org/overview''.
# "
#   } else{
#     pbdR.msg <-
# "
#     High Performance Computing Resource is available via
#     ``http://www.nics.tennessee.edu/getting-an-allocation''
#     with XSEDE at ``http://www.xsede.org/overview''.
# "
#   }
#   if(spmd.comm.rank(0L) == 0){
#     packageStartupMessage(pbdR.msg)
#   }
  invisible()
} # End of .onAttach().
