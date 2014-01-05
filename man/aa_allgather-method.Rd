\name{allgather-method}
\docType{methods}

\alias{allgather-method}

\alias{allgather,ANY,missing,missing-method}
\alias{allgather,integer,integer,missing-method}
\alias{allgather,numeric,numeric,missing-method}
\alias{allgather,raw,raw,missing-method}

\alias{allgather,ANY,missing,integer-method}
\alias{allgather,ANY,ANY,integer-method}
\alias{allgather,integer,integer,integer-method}
\alias{allgather,numeric,numeric,integer-method}
\alias{allgather,raw,raw,integer-method}

\alias{allgather}

\title{ All Ranks Gather Objects from Every Rank }
\description{
  This method lets all ranks gather objects from every rank in the same
  communicator. The default return is a list of length equal to
  \code{comm.size(comm)}.
}
\usage{
  allgather(x, x.buffer = NULL, x.count = NULL, displs = NULL,
            comm = .SPMD.CT$comm, unlist = .SPMD.CT$unlist)
}
\arguments{
  \item{x}{an object to be gathered from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  `size of \code{x}' times `\code{comm.size(comm)}'
                  with the same type of \code{x}.}
  \item{x.count}{a vector of length `comm size' containing all object lengths.}
  \item{displs}{\code{c(0L, cumsum(x.count))} by default.}
  \item{comm}{a communicator number.}
  \item{unlist}{if unlist the return.}
}
\details{
  All \code{x} on all ranks are likely presumed to have the same size and type.

  \code{x.buffer}, \code{x.count}, and \code{displs} can be \code{NULL} or
  unspecified. If specified, the type should be one of integer, double, or
  raw specified correctly according to the type of \code{x}.

  If \code{x.count} is specified, then the \code{spmd.allgatherv.*()} is 
  called.
}
\value{
  A list of length \code{comm.size(comm)} is returned by default.
}
\section{Methods}{
For calling \code{spmd.allgather.*()}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing", x.count = "missing")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer", x.count = "missing")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric", x.count = "missing")}}{}
\item{\code{signature(x = "raw", x.buffer = "raw", x.count = "missing")}}{}
}

For calling \code{spmd.allgatherv.*}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing", x.count = "integer")}}{}
\item{\code{signature(x = "ANY", x.buffer = "ANY", x.count = "integer")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer", x.count = "integer")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric", x.count = "integer")}}{}
\item{\code{signature(x = "raw", x.buffer = "raw", x.count = "integer")}}{}
}}
\seealso{
  \code{\link{gather}()}, \code{\link{allreduce}()}, \code{\link{reduce}()}.
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
library(pbdMPI, quietly = TRUE)
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
N <- 5
x <- (1:N) + N * .comm.rank
y <- allgather(matrix(x, nrow = 1))
comm.print(y)
y <- allgather(x, double(N * .comm.size))
comm.print(y)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}
