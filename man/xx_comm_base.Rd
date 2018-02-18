\name{global base}
\alias{comm.length}
\alias{comm.sum}
\alias{comm.mean}
\alias{comm.var}
\alias{comm.sd}
\title{ Global Base Functions }
\description{
  These functions are global base functions applying on
  distributed data for all ranks.
}
\usage{
comm.length(x, comm = .pbd_env$SPMD.CT$comm)
comm.sum(..., na.rm = TRUE, comm = .pbd_env$SPMD.CT$comm)
comm.mean(x, na.rm = TRUE, comm = .pbd_env$SPMD.CT$comm)
comm.var(x, na.rm = TRUE, comm = .pbd_env$SPMD.CT$comm)
comm.sd(x, na.rm = TRUE, comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{a vector.}
  \item{...}{as in \code{sum()}.}
  \item{na.rm}{logical, if remove \code{NA} and \code{NaN}.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply globally \code{length()}, \code{sum()},
  \code{mean()}, \code{var()}, and \code{sd()}. 
}
\value{
  The global values are returned to all ranks.
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
if(comm.size() != 2){
  comm.cat(\"2 processors are requried.\\n\", quiet = TRUE)
  finalize()
}

### Examples.
a <- 1:(comm.rank() + 1)

b <- comm.length(a)
comm.print(b)
b <- comm.sum(a)
comm.print(b)
b <- comm.mean(a)
comm.print(b)
b <- comm.var(a)
comm.print(b)
b <- comm.sd(a)
comm.print(b)

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{utility}
