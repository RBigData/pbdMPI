\name{scatter-method}
\docType{methods}

\alias{scatter-method}

\alias{scatter,ANY,missing,missing-method}
\alias{scatter,integer,integer,missing-method}
\alias{scatter,numeric,numeric,missing-method}
\alias{scatter,raw,raw,missing-method}

\alias{scatter,ANY,missing,integer-method}
\alias{scatter,ANY,ANY,integer-method}
\alias{scatter,integer,integer,integer-method}
\alias{scatter,numeric,numeric,integer-method}
\alias{scatter,raw,raw,integer-method}

\alias{scatter}

\title{ A Rank Scatter Objects to Every Rank }
\description{
  This method lets a rank scatter objects to every rank in the same
  communicator. The default input is a list of length equal to `comm size'
  and the default return is an element of the list.
}
\usage{
  scatter(x, x.buffer = NULL, x.count = NULL, displs = NULL,
         rank.source = .SPMD.CT$rank.source, comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{an object of length `comm size' to be scattered to all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  `size of element of \code{x}' with the same type
                  of the element of \code{x}.}
  \item{x.count}{a vector of length `comm size' containing all object lengths.}
  \item{displs}{\code{c(0L, cumsum(x.count))} by default.}
  \item{rank.source}{a rank of source where elements of \code{x} scatter from.}
  \item{comm}{a communicator number.}
}
\details{
  All elements of \code{x} are likely presumed to have the same size and type.

  \code{x.buffer}, \code{x.count}, and \code{displs} can be \code{NULL} or
  unspecified. If specified, the type should be one of integer, double, or
  raw specified correctly according to the type of \code{x}.

  If \code{x.count} is specified, then the \code{spmd.scatterv.*} is 
  called.
}
\value{
  An element of \code{x} is returned according to the rank id.
}
\section{Methods}{
For calling \code{spmd.scatter.*}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing", x.count = "missing")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer", x.count = "missing")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric", x.count = "missing")}}{}
\item{\code{signature(x = "raw", x.buffer = "raw", x.count = "missing")}}{}
}

For calling \code{spmd.scatterv.*}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing", x.count = "integer")}}{}
\item{\code{signature(x = "ANY", x.buffer = "ANY", x.count = "integer")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer", x.count = "integer")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric", x.count = "integer")}}{}
\item{\code{signature(x = "raw", x.buffer = "raw", x.count = "integer")}}{}
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
  \code{\link{bcast}}.
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
N <- 5
x <- split(1:(N * .comm.size), rep(1:.comm.size, N))
y <- scatter(lapply(x, matrix, nrow = 1))
comm.print(y)
y <- scatter(x, double(N))
comm.print(y)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}
