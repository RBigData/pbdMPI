\name{allreduce-method}
\docType{methods}

\alias{allreduce-method}

\alias{allreduce,ANY,missing-method}
\alias{allreduce,integer,integer-method}
\alias{allreduce,numeric,numeric-method}

\alias{allreduce}

\title{ All Ranks Receive a Reduction of Objects from Every Rank }
\description{
  This method lets all ranks receive a deduction of  objects from every
  rank in the same communicator based on a given operation. The default
  return is an object like the input.
}
\usage{
  allreduce(x, x.buffer = NULL, op = .SPMD.CT$op,
            comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be gathered from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  \code{x} with the same type of \code{x}.}
  \item{op}{a reduction operation applied to combine all \code{x}.}
  \item{comm}{a communicator number.}
}
\details{
  All \code{x} on all ranks are likely presumed to have the same size and type.

  \code{x.buffer} can be \code{NULL} or unspecified. If specified, the type
  should be one of integer, double, or raw specified correctly according to
  the type of \code{x}.
}
\value{
  The reduced object of the same type as \code{x} is returned by default.
}
\section{Methods}{
For calling \code{spmd.allreduce.*}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric")}}{}
}}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{allgather}}, \code{\link{gather}}, \code{\link{reduce}}.
}
\examples{
\dontrun{
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quietly = TRUE)
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
N <- 5
x <- (1:N) + N * .comm.rank
y <- allreduce(matrix(x, nrow = 1), op = "sum")
comm.print(y)
y <- allreduce(x, double(N), op = "prod")
comm.print(y)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}
