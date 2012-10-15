### Info functions.

spmd.info.create <- function(info = .SPMD.CT$info){
  ret <- .Call("spmd_info_create", as.integer(info), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.info.create().

info.create <- spmd.info.create

spmd.info.set <- function(info = .SPMD.CT$info, key, value){
  ret <- .Call("spmd_info_set", as.integer(info), as.character(key),
               as.character(value), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.info.set().

info.set <- spmd.info.set

spmd.info.free <- function(info = .SPMD.CT$info){
  ret <- .Call("spmd_info_free", as.integer(info), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.info.free().

info.free <- spmd.info.free

