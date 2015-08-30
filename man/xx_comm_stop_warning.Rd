\name{global stop and warning}
\alias{comm.stop}
\alias{comm.warning}
\alias{comm.warnings}
\title{ Global Stop and Warning Functions }
\description{
  These functions are global stop and warning applying on distributed data
  for all ranks, and are called by experts only. These functions may
  lead to potential performance degradation and system termination.
}
\usage{
comm.stop(..., call. = TRUE, domain = NULL,
          all.rank = .pbdMPIEnv$SPMD.CT$print.all.rank,
          rank.print = .pbdMPIEnv$SPMD.CT$rank.source,
          comm = .pbdMPIEnv$SPMD.CT$comm,
          mpi.finalize = .pbdMPIEnv$SPMD.CT$mpi.finalize,
          quit = .pbdMPIEnv$SPMD.CT$quit)

comm.warning(..., call. = TRUE, immediate. = FALSE, domain = NULL,
             all.rank = .pbdMPIEnv$SPMD.CT$print.all.rank,
             rank.print = .pbdMPIEnv$SPMD.CT$rank.source,
             comm = .pbdMPIEnv$SPMD.CT$comm)

comm.warnings(...,
              all.rank = .pbdMPIEnv$SPMD.CT$print.all.rank,
              rank.print = .pbdMPIEnv$SPMD.CT$rank.source,
              comm = .pbdMPIEnv$SPMD.CT$comm)
}
\arguments{
  \item{...}{variables to be cat.}
  \item{call.}{see stop() and warnings().}
  \item{immediate.}{see stop() and warnings().}
  \item{domain}{see stop() and warnings().}
  \item{all.rank}{if all ranks print (default = FALSE).}
  \item{rank.print}{rank for printing if not all ranks print (default = 0).}
  \item{comm}{communicator for printing (default = 1).}
  \item{mpi.finalize}{if MPI should be shutdown.}
  \item{quit}{if quit R when errors happen.}
}
\details{
  These functions will respectively apply \code{stop()}, \code{warning()},
  and \code{warnings()} locally.
}
\value{
  \code{comm.stop()} terminates all ranks, \code{comm.warning()} returns
  messages, and \code{comm.warnings()} print the message.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
if(comm.size() != 2){
  comm.cat("2 processors are requried.\n", quiet = TRUE)
  finalize()
}

### Examples.
comm.warning("test warning.\n")
comm.warnings()
comm.stop("test stop.\n")

### Finish.
finalize()
}
}
\keyword{utility}
