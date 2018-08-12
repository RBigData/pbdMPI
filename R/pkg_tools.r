### This contains some tools in "src/pkg_tools.c"

get.mpi.comm.ptr <- function(comm = .pbd_env$SPMD.CT$comm){
  ret <- .Call("get_MPI_COMM_PTR", as.integer(comm),
               PACKAGE = "pbdMPI")
  return(invisible(ret))
} # get.mpi.comm.ptr().

addr.mpi.comm.ptr <- function(comm.ptr){
  if(is(comm.ptr, "externalptr")){
    ret <- .Call("addr_MPI_COMM_PTR", comm.ptr,
                 PACKAGE = "pbdMPI")
    return(invisible(ret))
  } else{
    stop("comm.ptr needs to be an external point from get.mpi.comm.ptr().") 
  }
} # addr.mpi.comm.ptr().

