### Utilities.

spmd.probe <- function(rank.source = .SPMD.CT$rank.source,
    tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  ret <- .Call("spmd_probe", as.integer(rank.source), as.integer(tag),
               as.integer(comm), as.integer(status), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.probe().

probe <- spmd.probe

spmd.iprobe <- function(rank.source = .SPMD.CT$rank.source,
    tag = .SPMD.CT$tag, comm = .SPMD.CT$comm, status = .SPMD.CT$status){
  ret <- .Call("spmd_iprobe", as.integer(rank.source), as.integer(tag),
               as.integer(comm), as.integer(status), PACKAGE = "pbdMPI")
  invisible(ret)
} # End of spmd.iprobe().

iprobe <- spmd.iprobe

spmd.any.source <- function(){
  .Call("spmd_any_source", PACKAGE = "pbdMPI")
} # End of spmd.any.source().

any.source <- spmd.any.source()

spmd.any.tag <- function(){
  .Call("spmd_any_tag", PACKAGE = "pbdMPI")
} # End of spmd.any.tag().

any.tag <- spmd.any.tag()

spmd.get.sourcetag <- function(status = .SPMD.CT$status){
  .Call("spmd_get_sourcetag", as.integer(status), PACKAGE = "pbdMPI")
} # End of spmd.get.sourcetag().

get.sourcetag <- spmd.get.sourcetag

spmd.get.count <- function(data.type, status = .SPMD.CT$status){
  .Call("spmd_get_count", as.integer(data.type), as.integer(status),
        PACKAGE = "pbdMPI")
} # End of spmd.get.count().

get.count <- spmd.get.count

