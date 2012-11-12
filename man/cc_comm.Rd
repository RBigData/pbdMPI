\name{communicator}
\alias{.comm.size}
\alias{.comm.rank}
\alias{barrier}
\alias{comm.is.null}
\alias{comm.rank}
\alias{comm.size}
\alias{comm.dup}
\alias{comm.free}
\alias{init}
\alias{finalize}
\alias{comm.disconnect}
\alias{COMM.SIZE}
\alias{COMM.RANK}
\alias{comm.c2f}
\title{ Communicator Functions }
\description{
  The functions provide controls to communicators.
}
\usage{
  .comm.size
  .comm.rank
  barrier(comm = .SPMD.CT$comm)
  comm.is.null(comm = .SPMD.CT$comm)
  comm.rank(comm = .SPMD.CT$comm)
  comm.size(comm = .SPMD.CT$comm)
  comm.dup(comm, newcomm)
  comm.free(comm = .SPMD.CT$comm)
  init()
  finalize(mpi.finalize = .SPMD.CT$mpi.finalize)
  comm.disconnect(comm = .SPMD.CT$comm)
  comm.c2f(comm = .SPMD.CT$comm)
}
\arguments{
  \item{comm}{a communicator number.}
  \item{newcomm}{a new communicator number.}
  \item{mpi.finalize}{if MPI should be shutdown.}
}
\details{
  \code{.comm.size} (integer) is the default size of MPI world for the initial
  communicator indicated by \code{comm = 0}. This is different to \pkg{Rmpi}
  which uses \code{comm = 1} as the default. This variable is set in
  \code{.GlobalEnv} when \code{init} is evoked.

  \code{.comm.rank} (integer) is the default rank of each processor in the
  initial communicator \code{comm = 0}. This variable is set in
  \code{.GlobalEnv} when \code{init} is evoked.

  Another functions are direct calls to MPI library.

  \code{barrier} blocks all processors until everyone call this.

  \code{comm.is.null} returns \code{-1} if the array of communicators is not
  allocated, i.e. \code{init} is not called yet. It returns \code{1}
  if the communicator is not initialized, i.e. \code{NULL}. It
  returns \code{0} if the communicator is initialized.

  \code{comm.rank} returns the processor's rank for the given \code{comm}.

  \code{comm.size} returns the total processes for the given \code{comm}.

  \code{comm.dup} duplicate a \code{newcomm} from \code{comm}.

  \code{comm.free} free a \code{comm}.

  \code{init} initializes a MPI world, and set two global variables
  \code{.comm.size} and \code{.comm.rank} in \code{.GlobalEnv}.

  \code{finalize} frees memory and finishes a MPI world if
  \code{mpi.finalize = TRUE}.

  \code{comm.disconnect} frees a \code{comm}.

  \code{comm.c2f} returns an integer for Fortran MPI support.
}
\value{
  Most function return an invisible state of MPI call.
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
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quiet = TRUE)
init()

### Examples 
comm.print(.comm.size)
comm.print(.comm.rank, all.rank = TRUE)
comm.print(comm.rank(), rank.print = 1)
comm.print(comm.c2f())

### Finish
finalize()
}
}
\keyword{programming}

