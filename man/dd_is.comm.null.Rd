\name{is.comm.null}
\alias{is.comm.null}
\title{ Check if a MPI_COMM_NULL }
\description{
  The functions check MPI_COMM_NULL.
}
\usage{
  is.comm.null(comm = .SPMD.CT$comm)
}
\arguments{
  \item{comm}{a comm number.}
}
\details{
  These functions are for internal uses.
}
\value{
  TRUE if input comm is MPI_COMM_NULL, otherwise FALSE.
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
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
is.comm.null(0L)
is.comm.null(1L)

### Finish.
finalize()
}
}
\keyword{programming}
