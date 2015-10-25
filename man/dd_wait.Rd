\name{wait}
\alias{wait}
\alias{waitany}
\alias{waitsome}
\alias{waitall}
\title{ Wait Functions }
\description{
  The functions call MPI wait functions.
}
\usage{
wait(request = .pbd_opts$SPMD.CT$request,
     status = .pbd_opts$SPMD.CT$status)
waitany(count, status = .pbd_opts$SPMD.CT$status)
waitsome(count)
waitall(count)
}
\arguments{
  \item{request}{a request number.}
  \item{status}{a status number.}
  \item{count}{a count number.}
}
\details{
  These functions are for internal uses. Potentially, they wait after some
  nonblocking MPI calls.
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
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
if(.comm.rank == 0){
  isend(list(x))
}
if(.comm.rank == 1){
  y <- irecv(list(x))
}
wait()
comm.print(y, rank.print = 1L)

### Finish.
finalize()
}
}
\keyword{programming}
