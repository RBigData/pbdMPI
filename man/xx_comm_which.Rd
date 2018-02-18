\name{global which, which.max, and which.min}
\alias{comm.which}
\alias{comm.which.max}
\alias{comm.which.min}
\title{ Global Which Functions }
\description{
  These functions are global which, which.max and which.min applying on
  distributed data for all ranks.
}
\usage{
comm.which(x, arr.ind = FALSE, useNames = TRUE,
           comm = .pbd_env$SPMD.CT$comm)
comm.which.max(x, comm = .pbd_env$SPMD.CT$comm)
comm.which.min(x, comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{a 'logical' vector or array as in \code{which()},
           or an 'numeric' objects in \code{which.max()} and
           \code{which.min()}.}
  \item{arr.ind}{logical, as in \code{which()}.}
  \item{useNames}{logical, as in \code{which()}.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply \code{which()}, \code{which.max()} and
  \code{which.min()} locally, and apply \code{allgather()} to get all local
  results from other ranks.
}
\value{
  The global values (\code{which()}, \code{which.max()}, or \code{which.min()})
  are returned to all ranks.

  \code{comm.which()} returns with two columns, 'rank id' and 'index of
  \code{TRUE}'.

  \code{comm.which.max()} and \code{comm.which.min()} return with three
  values, 'the _smallest_ rank id', 'index of the _first_ maximum or minimum',
  and 'max/min value of \code{x}'.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{comm.read.table}()}
}
\examples{
%\dontrun{
### Save code in a file 'demo.r' and run with 2 processors by
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

b <- comm.which(a == 2)
comm.print(b)
b <- comm.which.max(a)
comm.print(b)
b <- comm.which.min(a)
comm.print(b)

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{utility}
