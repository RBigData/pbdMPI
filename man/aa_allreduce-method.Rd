\name{allreduce-method}
\docType{methods}

\alias{allreduce-method}

\alias{allreduce,ANY,missing-method}
\alias{allreduce,integer,integer-method}
\alias{allreduce,numeric,numeric-method}
\alias{allreduce,logical,logical-method}
\alias{allreduce,float32,float32-method}

\alias{allreduce}

\title{ All Ranks Receive a Reduction of Objects from Every Rank }
\description{
  This method lets all ranks receive a reduction of objects from every
  rank in the same communicator based on a given operation. The default
  return is an object like the input and the default operation is the sum.
}
\usage{
allreduce(x, x.buffer = NULL, op = .pbd_env$SPMD.CT$op,
          comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be reduced from all ranks.}
  \item{x.buffer}{for atomic vectors, a buffer to hold the return object which
  has the same size and the same type as \code{x}.}
  \item{op}{the reduction operation to apply to \code{x} across all \code{comm}
  ranks. The default is normally sum.} 
  \item{comm}{a communicator number.}
}
\details{
  All ranks are presumed to have \code{x} of the same size and type.

  Normally, \code{x.buffer} is \code{NULL} or unspecified, and is computed
  for you. If specified for atomic vectors, the type should be one of integer,
  double, or raw and be the same type as \code{x}. 
  
  The \code{allgather} is efficient due to the underlying MPI parallel
  communication and recursive doubling reduction algorithm that results in
  a sublinear (\code{log2(comm.size(comm))}) number of reduction and 
  communication steps.
  
  See \code{methods{"allreduce"}} for S4 dispatch cases and the source code for
  further details.
}
\value{
  The reduced object of the same type as \code{x} is returned to all ranks
  by default.
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{allgather}()}, \code{\link{gather}()}, \code{\link{reduce}()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
y <- allreduce(matrix(x, nrow = 1), op = \"sum\")
comm.print(y)

y <- allreduce(x, double(N), op = \"prod\")
comm.print(y)

comm.set.seed(1234, diff = TRUE)
x <- as.logical(round(runif(N)))
y <- allreduce(x, logical(N), op = \"land\")
comm.print(y)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)
%}
}
\keyword{methods}
\keyword{collective}
