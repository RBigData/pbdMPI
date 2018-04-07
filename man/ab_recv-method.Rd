\name{recv-method}
\docType{methods}

\alias{recv-method}

\alias{recv,ANY-method}
\alias{recv,integer-method}
\alias{recv,numeric-method}
\alias{recv,raw-method}

\alias{recv}

\title{ A Rank Receives (Blocking) an Object from the Other Rank }
\description{
  This method lets a rank receive (blocking) an object from the other
  rank in the same communicator. The default return is the object sent from
  the other rank.
}
\usage{
recv(x.buffer = NULL, rank.source = .pbd_env$SPMD.CT$rank.source,
     tag = .pbd_env$SPMD.CT$tag, comm = .pbd_env$SPMD.CT$comm,
     status = .pbd_env$SPMD.CT$status)
}
\arguments{
  \item{x.buffer}{a buffer to store \code{x} sent from the other rank.}
  \item{rank.source}{a source rank where \code{x} sent from}
  \item{tag}{a tag number.}
  \item{comm}{a communicator number.}
  \item{status}{a status number.}
}
\details{
  A corresponding \code{send()} should be evoked at the corresponding rank
  \code{rank.source}.
}
\value{
  An object is returned by default.
}
\section{Methods}{
For calling \code{spmd.recv.*()}:
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
  \code{\link{irecv}()}, \code{\link{send}()}, \code{\link{isend}()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
if(.comm.rank == 0){
  y <- send(matrix(x, nrow = 1))
} else if(.comm.rank == 1){
  y <- recv()
}
comm.print(y, rank.print = 1)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{methods}
\keyword{collective}
