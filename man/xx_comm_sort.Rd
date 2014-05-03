\name{global sort function}
\alias{comm.sort}
\title{ Global Quick Sort for Distributed Vectors or Matrices }
\description{
  This function globally sorts distributed data for all ranks.
}
\usage{
  comm.sort(x, decreasing = FALSE, na.last = NA,
            comm = .SPMD.CT$comm, status = .SPMD.CT$status)
}
\arguments{
  \item{x}{a vector.}
  \item{decreasing}{logical. Should the sort order be increasing or decreasing?}
  \item{na.last}{for controlling the treatment of \code{NA}s.
                 If \code{TRUE}, missing values in the data are put last;
                 if \code{FALSE}, they are put first; if \code{NA},
                 they are removed.}
  \item{comm}{a communicator number.}
  \item{status}{a status number.}
}
\details{
  The distributed quick sort is implemented for this functions.
}
\value{
  The returns are the same size of \code{x} but in global sorting order.
}
\section{Warning}{
  All ranks may not have a NULL \code{x}.
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
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quietly = TRUE)
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
comm.set.seed(123456, diff = TRUE)
x <- c(rnorm(5 + .comm.rank * 2), NA)
# x <- sample(1:5, 5 + .comm.rank * 2, replace = TRUE)
comm.end.seed()

if(.comm.rank == 1){
  x <- NULL    ### Test for NULL or 0 vector
}

y <- allgather(x)
comm.print(y)

y <- comm.sort(x)
y <- allgather(y)
comm.print(y)

### Finish
finalize()
}
}
\keyword{utility}

