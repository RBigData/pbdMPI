\name{global match.arg}
\alias{comm.match.arg}
\title{ Global Argument Matching }
\description{
  A binding for \code{match.arg()} that uses \code{comm.stop()} rather
  so that the error message (if there is one) is managed according
  to the rules of \code{.pbd_env$SPMD.CT}.
}
\usage{
comm.match.arg(arg, choices, several.ok=FALSE, ..., 
               all.rank = .pbd_env$SPMD.CT$print.all.rank,
               rank.print = .pbd_env$SPMD.CT$rank.source,
               comm = .pbd_env$SPMD.CT$comm,
               mpi.finalize = .pbd_env$SPMD.CT$mpi.finalize,
               quit = .pbd_env$SPMD.CT$quit)
}
\arguments{
  \item{arg,choices,several.ok}{see match.arg()}
  \item{...}{ignored.}
  \item{all.rank}{if all ranks print (default = FALSE).}
  \item{rank.print}{rank for printing if not all ranks print (default = 0).}
  \item{comm}{communicator for printing (default = 1).}
  \item{mpi.finalize}{if MPI should be shutdown.}
  \item{quit}{if quit R when errors happen.}
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\keyword{utility}
