\name{sourcetag}
\alias{any.source}
\alias{any.tag}
\alias{get.sourcetag}
\title{ Functions to Obtain source and tag }
\description{
  The functions extract MPI_ANY_SOURCE, MPI_ANY_TAG,
  MPI_status.source and MPI_status.tag.
}
\usage{
  any.source()
  any.tag()
  get.sourcetag(status = .SPMD.CT$status)
}
\arguments{
  \item{status}{a status number.}
}
\details{
  These functions are for internal uses.
}
\value{
  Corresponding status will be returned.
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
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
if(.comm.rank == 1){
  send(1L, tag = 10)
  send(2L, tag = 11)
}
if(.comm.rank == 0){
  Sys.sleep(1)
  print(from.source <- any.source())
  print(from.tag <- any.tag())
  print(from.status <- get.sourcetag())
  ret <- recv(x.buffer = integer(1), rank.source = from.source,
              tag = from.tag)
  print(ret)

  Sys.sleep(1)
  print(from.source <- any.source())
  print(from.tag <- any.tag())
  print(from.status <- get.sourcetag())
  ret <- recv(x.buffer = integer(1), rank.source = from.source,
              tag = from.tag)
  print(ret)
}

### Finish
finalize()
}
}
\keyword{programming}

