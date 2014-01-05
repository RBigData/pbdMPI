\name{sendrecv.replace-method}
\docType{methods}

\alias{sendrecv.replace-method}

\alias{sendrecv.replace,ANY-method}
\alias{sendrecv.replace,integer-method}
\alias{sendrecv.replace,numeric-method}
\alias{sendrecv.replace,raw-method}

\alias{sendrecv.replace}

\title{ Send and Receive an Object to and from Other Ranks }
\description{
  This method lets a rank send an object to the other rank and
  receive an object from another rank in the same communicator.
  The default return is \code{x}.
}
\usage{
  sendrecv.replace(x,
    rank.dest = as.integer((comm.rank(.SPMD.CT$comm) + 1) \%\%
                           comm.size(.SPMD.CT$comm)),
    send.tag = .SPMD.CT$tag,
    rank.source = as.integer((comm.rank(.SPMD.CT$comm) - 1) \%\%
                             comm.size(.SPMD.CT$comm)),
    recv.tag = .SPMD.CT$tag,
    comm = .SPMD.CT$comm, status = .SPMD.CT$status)
}
\arguments{
  \item{x}{an object to be sent from a rank.}
  \item{rank.dest}{a rank of destination where \code{x} send to.}
  \item{send.tag}{a send tag number.}
  \item{rank.source}{a source rank where \code{x} sent from.}
  \item{recv.tag}{a receive tag number.}
  \item{comm}{a communicator number.}
  \item{status}{a status number.}
}
\details{
  A corresponding \code{sendrecv.replace()} should be evoked at the
  corresponding ranks \code{rank.dest} and \code{rank.source}.

  \code{rank.dest} and \code{rank.source} can be \code{as.integer(NULL)} to
  create a silent sendrecv operation which is more efficient than setting
  \code{rank.dest} and \code{rank.source} to be equal.

  \strong{Warning:} \code{sendrecv.replace()} is not safe for \R since \R is
  not a thread safe package that a dynamic returning object requires certain
  blocking or barrier at some where. The replaced object or memory address
  `MUST' return correctly. This is almost equivalent to \code{sendrecv()}.
}
\value{
  A \code{x} is returned by default.
}
\section{Methods}{
For calling \code{spmd.sendrecv.replace.*()}:
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
  \code{\link{sendrecv}()}.
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
x <- (1:N) + N * .comm.size
x <- sendrecv.replace(matrix(x, nrow = 1))
comm.print(x, rank.print = 1)

### Finish
finalize()
}
}
\keyword{methods}
\keyword{collective}
