\name{Package Tools}
\alias{get.mpi.comm.ptr}
\alias{addr.mpi.comm.ptr}
\title{Functions for Get/Print MPI_COMM Pointer (Address)}
\description{
  These functions are designed to get or print MPI_COMM pointer and
  its address when the SPMD code in R be a foreign application of
  other applications.
}
\usage{
get.mpi.comm.ptr(comm = .pbd_env$SPMD.CT$comm)
addr.mpi.comm.ptr(comm.ptr)
}
\arguments{
  \item{comm}{a communicator number.}
  \item{comm.ptr}{a communicator pointer.}
}
\details{
  \code{get.mpi.comm.ptr()} returns an R external pointer that points
  to the address of the comm.

  \code{addr.mpi.comm.ptr()} takes the R external points, and
  prints the address of the comm. This function is mainly for debugging.
}
\value{
  \code{get.mpi.comm.ptr()} returns an R external pointer.

  \code{addr.mpi.comm.ptr()} prints the comm pointer address and the
  address of MPI_COMM_WORLD.
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
% \dontrun{
### Save code in a file "demo.r" and run with 4 processors by
### SHELL> mpiexec -np 4 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

ptr1 <- get.mpi.comm.ptr(1)
addr.mpi.comm.ptr(ptr1)

comm.split(color = as.integer(comm.rank()/2), key = comm.rank())

ptr1.new <- get.mpi.comm.ptr(1)
addr.mpi.comm.ptr(ptr1.new)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 4L)
%}
}
\keyword{utility}
