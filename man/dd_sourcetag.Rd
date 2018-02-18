\name{sourcetag}
\alias{anysource}
\alias{anytag}
\alias{get.sourcetag}
\title{ Functions to Obtain source and tag }
\description{
  The functions extract MPI_ANY_SOURCE, MPI_ANY_TAG,
  MPI_status.source and MPI_status.tag.
}
\usage{
anysource()
anytag()
get.sourcetag(status = .pbd_env$SPMD.CT$status)
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
%\dontrun{
### Save code in a file 'demo.r' and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()
if(.comm.size < 2)
  comm.stop(\"At least two processors are requried.\")

### Examples.
if(.comm.rank != 0){
  send(as.integer(.comm.rank * 10), rank.dest = 0L,
       tag = as.integer(.comm.rank + 10))
}
if(.comm.rank == 0){
  for(i in 1:(.comm.size - 1)){
    ret <- recv(x.buffer = integer(1),
                rank.source = anysource(), tag = anytag())
    sourcetag <- get.sourcetag()
    print(c(sourcetag, ret))
  }
}

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{programming}
