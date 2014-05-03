\name{global distance function}
\alias{comm.dist}
\title{ Global Distance for Distributed Matrices }
\description{
  This function globally compute distance for all ranks.
}
\usage{
  comm.dist(X.gbd, method = "euclidean", diag = FALSE, upper = FALSE,
            p = 2, comm = .SPMD.CT$comm)
}
\arguments{
  \item{X.gbd}{a gbd matrix.}
  \item{method}{as in \code{dist()}.}
  \item{diag}{as in \code{dist()}.}
  \item{upper}{as in \code{dist()}.}
  \item{p}{as in \code{dist()}.}
  \item{comm}{a communicator number.}
}
\details{
  The distance function is implemented for a distributed matrix.

  This function is only useful when the number of rows of the
  matrix is small.
}
\value{
  A full distance or distance matrix is returned.

  Suppose \code{N.gbd} is total rows of \code{X.gbd}, then
  the distance will have \code{N.gbd * (N.gbd - 1) / 2} elements
  and the distance matrix will have \code{N.gbd^2} elements.
}
\section{Warning}{
  The distance or distance matrix could be huge.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{comm.allpairs}()} and
  \code{\link{comm.pairwise}()}.
}
\examples{
\dontrun{
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quietly = TRUE)
init()

### Examples
comm.set.seed(123456, diff = TRUE)

X.gbd <- matrix(runif(6), ncol = 3)
dist.X.gbd <- comm.dist(X.gbd)

### Verify
dist.X <- dist(do.call("rbind", allgather(X.gbd)))
comm.print(all(dist.X.gbd == dist.X))

### Finish
finalize()
}
}
\keyword{utility}

