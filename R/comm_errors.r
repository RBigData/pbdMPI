### Similar to stop(), warning(), warnings().

comm.stop <- function(..., call. = TRUE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm){
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    args <- list(...)
    if(length(args) == 1L && inherits(args[[1L]], "condition")){
      cond <- args[[1L]]
      if(nargs() > 1L){
        warning("additional arguments ignored in comm.stop()")
      }
      message <- conditionMessage(cond)
      call <- conditionCall(cond)
      ### This is not allowed by "R CMD check".
      # .Internal(.signalCondition(cond, message, call))
      # .Internal(.dfltStop(message, call))

      ### WCC: I don't know what this if() for. The next should work,
      ###      but may not fit the original purpose.
      .External("api_R_stop", call, as.logical(call.), message,
                PACKAGE = "pbdMPI")
    } else{
      ### This is not allowed by "R CMD check".
      # .Internal(stop(as.logical(call.), .makeMessage(..., 
      #           domain = domain)))

      .External("api_R_stop", sys.call(-1), as.logical(call.),
                .makeMessage(..., domain = domain),
                PACKAGE = "pbdMPI")
    }
  }
} # End of comm.stop().

comm.warning <- function(..., call. = TRUE, immediate. = FALSE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm){
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    args <- list(...)
    if(length(args) == 1L && inherits(args[[1L]], "condition")){
      cond <- args[[1L]]
      if(nargs() > 1L) 
        cat(gettext("additional arguments ignored in comm.warning()"), 
            "\n", sep = "", file = stderr())
        message <- conditionMessage(cond)
        call <- conditionCall(cond)
        withRestarts({
            ### This is not allowed by "R CMD check".
            # .Internal(.signalCondition(cond, message, call))
            # .Internal(.dfltWarn(message, call))

            ### WCC: I don't know what this if() for. The next should work,
            ###      but may not fit the original purpose.
            .External("api_R_warning", call, as.logical(call.),
                      as.logical(immediate.), message,
                      PACKAGE = "pbdMPI")
        }, muffleWarning = function() NULL)
        invisible(message)
    } else{
      ### This is not allowed by "R CMD check".
      # .Internal(warning(as.logical(call.), as.logical(immediate.), 
      #           .makeMessage(..., domain = domain)))

      ret <- .External("api_R_warning", sys.call(-1), as.logical(call.),
                       as.logical(immediate.),
                       .makeMessage(..., domain = domain),
                       PACKAGE = "pbdMPI")
      invisible(ret)
    }
  }
} # End of comm.warning().

comm.warnings <- function(...,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm){
  if(spmd.comm.rank(comm) == rank.print || all.rank == TRUE){
    if (!exists("last.warning", envir = baseenv())) 
        return()
    last.warning <- get("last.warning", envir = baseenv())
    if (!(n <- length(last.warning))) 
        return()
    structure(last.warning, dots = list(...), class = "warnings")
  }
} # End of comm.warnings().

