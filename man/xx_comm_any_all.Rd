\name{global any and all functions}
\alias{comm.any}
\alias{comm.all}
\title{ Global Any and All Functions }
\description{
  These functions are global any and all applying on distributed data
  for all ranks.
}
\usage{
  comm.any(x, na.rm = FALSE, comm = .SPMD.CT$comm)
  comm.all(x, na.rm = FALSE, comm = .SPMD.CT$comm)
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
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quiet = TRUE)
init()
if(comm.size() != 2){
  comm.cat("2 processors are requried.\n", quiet = TRUE)
  finalize()
}

### Examples
if(comm.rank() == 0){
  a <- c(T, F, NA)
} else{
  a <- T
}

comm.print(comm.any(a))
comm.print(comm.all(a))
comm.print(comm.any(a, na.rm = TRUE))
comm.print(comm.all(a, na.rm = TRUE))

### Finish
finalize()
}
}
\keyword{utility}

