\name{alltoall}
\alias{alltoall}
\alias{spmd.alltoall.integer}
\alias{spmd.alltoall.double}
\alias{spmd.alltoall.raw}
\alias{spmd.alltoallv.integer}
\alias{spmd.alltoallv.double}
\alias{spmd.alltoallv.raw}

\title{ All to All }
\description{
  These functions make calls to \code{MPI_Alltoall()} and
  \code{MPI_Alltoallv()}.
}
\usage{
spmd.alltoall.integer(x.send, x.recv, send.count, recv.count,
                      comm = .pbdEnv$SPMD.CT$comm)
spmd.alltoall.double(x.send, x.recv, send.count, recv.count,
                    comm = .pbdEnv$SPMD.CT$comm)
spmd.alltoall.raw(x.send, x.recv, send.count, recv.count,
                  comm = .pbdEnv$SPMD.CT$comm)

spmd.alltoallv.integer(x.send, x.recv, send.count, recv.count,
                       sdispls, rdispls, comm = .pbdEnv$SPMD.CT$comm)
spmd.alltoallv.double(x.send, x.recv, send.count, recv.count,
                      sdispls, rdispls, comm = .pbdEnv$SPMD.CT$comm)
spmd.alltoallv.raw(x.send, x.recv, send.count, recv.count,
                   sdispls, rdispls, comm = .pbdEnv$SPMD.CT$comm)
}
\arguments{
  \item{x.send}{an object to send.}
  \item{x.recv}{an object to receive}
  \item{send.count}{send counter}
  \item{recv.count}{recv counter}
  \item{sdispls}{send dis pls}
  \item{rdispls}{recv dis pls}
  \item{comm}{a communicator number.}
}
\details{
  These are very low level functions. Use with cautions. Neigher S4 method nor
  long vector is supported.
}
\value{
  These are very low level functions. Use with cautions. Neigher S4 method nor
  long vector is supported.
}
\seealso{
  \code{\link{allgather}()}, \code{\link{allgatherv}()}.
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
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
n <- as.integer(2)
x <- 1:(.comm.size * n)
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x, all.rank = TRUE)

x <- as.integer(x)
y <- spmd.alltoall.integer(x, integer(length(x)), n, n)
comm.cat("\nAlltoall y:\n", quiet = TRUE)
comm.print(y, all.rank = TRUE)

### Finish.
finalize()
}
}
\keyword{methods}
\keyword{collective}
