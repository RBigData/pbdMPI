\name{info}
\alias{info.create}
\alias{info.set}
\alias{info.free}
\alias{info.c2f}
\title{ Info Functions }
\description{
  The functions call MPI info functions.
}
\usage{
info.create(info = .pbd_env$SPMD.CT$info)
info.set(info = .pbd_env$SPMD.CT$info, key, value)
info.free(info = .pbd_env$SPMD.CT$info)
info.c2f(info = .pbd_env$SPMD.CT$info)
}
\arguments{
  \item{info}{a info number.}
  \item{key}{a character string to be set.}
  \item{value}{a character string to be set associate with \code{key}.}
}
\details{
  These functions are for internal functions. Potentially, they set
  info for initialization of master and workers.
}
\value{
  An invisible state of MPI call is returned.
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
%\dontrun{
### Save code in a file 'demo.r' and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
info.create(0L)
info.set(0L, \"file\", \"appschema\")
info.free(0L)

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{programming}
