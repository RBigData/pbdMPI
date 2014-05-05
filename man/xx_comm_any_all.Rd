\name{global any and all}
\alias{comm.any}
\alias{comm.all}
\alias{comm.allcommon}
\title{ Global Any and All Functions }
\description{
  These functions are global any and all applying on distributed data
  for all ranks.
}
\usage{
  comm.any(x, na.rm = FALSE, comm = .SPMD.CT$comm)
  comm.all(x, na.rm = FALSE, comm = .SPMD.CT$comm)

  comm.allcommon(x, comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{a vector.}
  \item{na.rm}{if \code{NA} removed or not.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply \code{any()} and \code{all()} locally, and
  apply allgather to get all local results from other ranks, then
  apply \code{any()} and \code{all()} on all local results.

  \code{comm.allcommon()} is to check if \code{x} is exactly the same
  across all ranks.
}
\value{
  The global check values (TRUE, FALSE, NA) are returned to all ranks.
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
library(pbdMPI, quietly = TRUE)
init()

### Examples.
if(comm.rank() == 0){
  a <- c(T, F, NA)
} else{
  a <- T
}

comm.any(a)
comm.all(a)
comm.any(a, na.rm = TRUE)
comm.all(a, na.rm = TRUE)

comm.allcommon(a)
comm.allcommon(1:3)

### Finish.
finalize()
}
}
\keyword{utility}
