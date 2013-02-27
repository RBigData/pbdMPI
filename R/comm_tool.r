### S3 tool function except print() and cat() see "spmd_tool.r".

comm.any <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(any(x, na.rm = na.rm),
                                integer(comm.size(comm)), comm = comm)
  any(ret, na.rm = na.rm)
} # End of comm.any().

comm.all <- function(x, na.rm = FALSE, comm = .SPMD.CT$comm){
  ret <- spmd.allgather.integer(all(x, na.rm = na.rm),
                                integer(comm.size(comm)), comm = comm)
  all(ret, na.rm = na.rm)
} # End of comm.all().

comm.stop <- function(..., call. = TRUE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm){
  options(error = expression(NULL))
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    stop(...)
    cat("Execution halted\n")
  }
  finalize()
  quit(save = "no", status = 1, runLast = FALSE)
} # End of comm.stop().

comm.warning <- function(..., call. = TRUE, immediate. = FALSE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm){
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    warning(..., call. = call., immediate. = immediate., domain = domain)
  }
  invisible()
} # End of comm.warning().

comm.warnings <- function(...,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm, quiet = TRUE){
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    warnings(...)
  }
} # End of comm.warnings().

