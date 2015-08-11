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
  spmd.alltoall.integer(x, x.buffer, comm = .SPMD.CT$comm)
  spmd.alltoall.double(x, x.buffer, comm = .SPMD.CT$comm)
  spmd.alltoall.raw(x, x.buffer, comm = .SPMD.CT$comm)

  spmd.alltoallv.integer(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm)
  spmd.alltoallv.double(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm)
  spmd.alltoallv.raw(x, x.buffer, x.count,
    sdispls = c(0L, cumsum(x)), rdispls = c(0L, cumsum(x.count)),
    comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be toalled from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  `size of \code{x}' times `\code{comm.size(comm)}'
                  with the same type of \code{x}.}
  \item{x.count}{a vector of length `comm size' containing all object lengths.}
  \item{sdispls}{\code{c(0L, cumsum(x))} by default.}
  \item{rdispls}{\code{c(0L, cumsum(x.count))} by default.}
  \item{comm}{a communicator number.}
}
\details{
  These are very raw functions. Use with cautions. Neigher S4 method nor
  long vector is supported.
}
\value{
  These are very raw functions. Use with cautions. Neigher S4 method nor
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
}
}
\keyword{methods}
\keyword{collective}
