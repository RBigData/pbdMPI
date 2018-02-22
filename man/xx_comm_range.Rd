\name{global range, max, and min}
\alias{comm.range}
\alias{comm.max}
\alias{comm.min}
\title{ Global Range, Max, and Min Functions }
\description{
  These functions are global range, max and min applying on distributed data
  for all ranks.
}
\usage{
comm.range(..., na.rm = FALSE, comm = .pbd_env$SPMD.CT$comm)
comm.max(..., na.rm = FALSE, comm = .pbd_env$SPMD.CT$comm)
comm.min(..., na.rm = FALSE, comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{...}{an 'numeric' objects.}
  \item{na.rm}{if \code{NA} removed or not.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply \code{range()}, \code{max()} and \code{min()}
  locally, and apply allgather to get all local results from other ranks,
  then apply \code{range()}, \code{max()} and \code{min()} on all local
  results.
}
\value{
  The global values (range, max, or min) are returned to all ranks.
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

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
if(comm.size() != 2){
  comm.cat(\"2 processors are requried.\\n\", quiet = TRUE)
  finalize()
}

### Examples.
a <- 1:(comm.rank() + 1)

b <- comm.range(a)
comm.print(b)
b <- comm.max(a)
comm.print(b)
b <- comm.min(a)
comm.print(b)

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
