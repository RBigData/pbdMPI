\name{bcast-method}
\docType{methods}

\alias{bcast-method}

\alias{bcast,ANY-method}
\alias{bcast,integer-method}
\alias{bcast,numeric-method}
\alias{bcast,raw-method}

\alias{bcast}

\title{ A Rank Broadcast an Object to Every Rank }
\description{
  This method lets a rank broadcast an object to every rank in the same
  communicator. The default return is the object.
}
\usage{
bcast(x, rank.source = .pbd_env$SPMD.CT$rank.source,
      comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be broadcast from all ranks.}
  \item{rank.source}{a rank of source where \code{x} broadcast from.}
  \item{comm}{a communicator number.}
}
\details{
  The same copy of \code{x} is sent to all ranks.
  
  See \code{methods{"bcast"}} for S4 dispatch cases and the source code for
  further details.
}
\value{
  Every rank has \code{x} returned.
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
  \code{\link{scatter}()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))

### Examples.
x <- matrix(1:5, nrow = 1)
y <- bcast(x)
comm.print(y)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{methods}
\keyword{collective}
