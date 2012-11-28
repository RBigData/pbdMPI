\name{send-method}
\docType{methods}

\alias{send-method}

\alias{send,ANY-method}
\alias{send,integer-method}
\alias{send,numeric-method}
\alias{send,raw-method}

\alias{send}

\title{ A Rank Send (blocking) an Object to the Other Rank }
\description{
  This method lets a rank send (blocking) an object to the other rank
  in the same communicator. The default return is \code{NULL}.
}
\usage{
  send(x, rank.dest = .SPMD.CT$rank.dest, tag = .SPMD.CT$tag,
       comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be sent from a rank.}
  \item{rank.dest}{a rank of destination where \code{x} send to.}
  \item{tag}{a tag number.}
  \item{comm}{a communicator number.}
}
\details{
  A corresponding \code{recv} should be evoked at the corresponding rank
  \code{rank.dest}.
}
\value{
  A \code{NULL} is returned by default.
}
\section{Methods}{
For calling \code{spmd.send.*}:
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
  \code{\link{isend}}, \code{\link{recv}}, \code{\link{irecv}}.
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
  y <- send(matrix(x, nrow = 1))
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
