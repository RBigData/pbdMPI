\name{isend-method}
\docType{methods}

\alias{isend-method}

\alias{isend,ANY-method}
\alias{isend,integer-method}
\alias{isend,numeric-method}
\alias{isend,raw-method}

\alias{isend}

\title{ A Rank Send (Nonblocking) an Object to the Other Rank }
\description{
  This method lets a rank send (nonblocking) a object to the other
  rank in the same communicator. The default return is \code{NULL}.
}
\usage{
  isend(x, rank.dest = .SPMD.CT$rank.dest, tag = .SPMD.CT$tag,
        comm = .SPMD.CT$comm, request = .SPMD.CT$request)
}
\arguments{
  \item{x}{an object to be sent from a rank.}
  \item{rank.dest}{a rank of destination where \code{x} send to.}
  \item{tag}{a tag number.}
  \item{comm}{a communicator number.}
  \item{request}{a request number.}
}
\details{
  A corresponding \code{recv} or \code{irecv} should be evoked at the
  corresponding rank \code{rank.dest}.
}
\value{
  A \code{NULL} is returned by default.
}
\section{Methods}{
For calling \code{spmd.isend.*}:
\describe{
\item{\code{signature(x = "ANY")}}{}
\item{\code{signature(x = "integer")}}{}
\item{\code{signature(x = "numeric")}}{}
\item{\code{signature(x = "raw")}}{}
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
  \code{\link{send}}, \code{\link{recv}}, \code{\link{irecv}}.
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
x <- (1:N) + N * .comm.rank
if(.comm.rank == 0){
  y <- isend(matrix(x, nrow = 1))
} else if(.comm.rank == 1){
  y <- recv()
}
comm.print(y, rank.print = 1)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}
