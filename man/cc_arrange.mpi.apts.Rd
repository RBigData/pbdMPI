\name{MPI array pointers}
\alias{arrange.mpi.apts}
\title{ Set or Get MPI Array Pointers in R }
\description{
  The function set/get a point address in R where the point point to
  a structure containing MPI arrays.
}
\usage{
arrange.mpi.apts()
}
\details{
  Since Rmpi/pbdMPI use pre-allocate memory to store comm, status,
  datatype, info, request, this function provides a variable in \R
  to let different APIs share the same memory address.

  If the package loads first, then this sets `\code{.__MPI_APTS__}'
  in the \code{.GlobalEnv} of \R. If the package does not load before other
  MPI APIs, then this points an structure point to the external memory
  according to `\code{.__MPI_APTS__}', i.e. pre-set by other MPI APIs.

  \code{pbdMPI/R/arrange.mpi.apts} provides the \R code, and
  \code{pbdMPI/src/pkg_*.*} provides the details of this call.
}
\value{
  `\code{.__MPI_APTS__}' is set in the \code{.GlobalEnv} of \R.
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
### See source code for the details.
}
}
\keyword{programming}
