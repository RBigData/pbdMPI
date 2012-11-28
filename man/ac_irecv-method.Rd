\name{irecv-method}
\docType{methods}

\alias{irecv-method}

\alias{irecv,ANY-method}
\alias{irecv,integer-method}
\alias{irecv,numeric-method}
\alias{irecv,raw-method}

\alias{irecv}

\title{ A Rank Receives (Nonblocking) an Object from the Other Rank }
\description{
  This method lets a rank receive (nonblocking) an object from the
  other rank in the same communicator. The default return is the object
  sent from the other rank.
}
\usage{
  irecv(x.buffer = NULL, rank.source = .SPMD.CT$rank.source,
        tag = .SPMD.CT$tag, comm = .SPMD.CT$comm,
        request = .SPMD.CT$request, status = .SPMD.CT$status)
}
\arguments{
  \item{x.buffer}{a buffer to store \code{x} sent from the other rank.}
  \item{rank.source}{a source rank where \code{x} sent from}
  \item{tag}{a tag number.}
  \item{comm}{a communicator number.}
  \item{request}{a request number.}
  \item{status}{a status number.}
}
\details{
  A corresponding \code{send}/\code{isend} should be evoked at the
  corresponding rank \code{rank.source}.

  \strong{Warning:} \code{irecv} is not safe for \R since \R is not a thread
  safe package that a dynamic returning object requires certain blocking or
  barrier at some where. Current, the default method is equivalent to the
  default method of \code{recv}.
}
\value{
  An object is returned by default.
}
\section{Methods}{
For calling \code{spmd.irecv.*}:
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
  \code{\link{recv}}, \code{\link{send}}, \code{\link{isend}}.
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
  y <- irecv()
}
comm.print(y, rank.print = 1)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}

