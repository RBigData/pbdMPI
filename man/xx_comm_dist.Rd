\name{global distance function}
\alias{comm.dist}
\title{ Global Distance for Distributed Matrices }
\description{
  These functions globally compute distance for all ranks.
}
\usage{
comm.dist(X.gbd, method = "euclidean", diag = FALSE, upper = FALSE,
          p = 2, comm = .pbd_opts$SPMD.CT$comm,
          return.type = c("common", "gbd"))
}
\arguments{
  \item{X.gbd}{a gbd matrix.}
  \item{method}{as in \code{dist()}.}
  \item{diag}{as in \code{dist()}.}
  \item{upper}{as in \code{dist()}.}
  \item{p}{as in \code{dist()}.}
  \item{comm}{a communicator number.}
  \item{return.type}{returning type for the distance.}
}
\details{
  The distance function is implemented for a distributed matrix.

  The return type \code{common} is only useful when the number
  of rows of the matrix is small since the returning matrix is \code{N * N}
  for every rank where \code{N} is the total number of rows of \code{X.gbd}
  of all ranks.

  The return type \code{gbd} returns a gbd matrix (distributed across
  all ranks, and the gbd matrix has 3 columns, named "i", "j", and "value",
  where \code{(i, j)} is the global indices of the
  i-th and j-th rows of \code{X.gbd}, and \code{value} is the corresponding
  distance. The \code{(i, j)} is ordered as a distance matrix.
}
\value{
  A full distance matrix is returned from the \code{common} return type.
  Suppose \code{N.gbd} is total rows of \code{X.gbd}, then
  the distance will have \code{N.gbd * (N.gbd - 1) / 2} elements
  and the distance matrix will have \code{N.gbd^2} elements.

  A gbd distance matrix with 3 columns is returned from the
  \code{gbd} return type.
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
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

### Examples.
comm.set.seed(123456, diff = TRUE)

X.gbd <- matrix(runif(6), ncol = 3)
dist.X.common <- comm.dist(X.gbd)
dist.X.gbd <- comm.dist(X.gbd, return.type = "gbd")

### Verify.
dist.X <- dist(do.call("rbind", allgather(X.gbd)))
comm.print(all(dist.X == dist.X.common))

### Verify 2.
dist.X.df <- do.call("rbind", allgather(dist.X.gbd))
comm.print(all(dist.X == dist.X.df[, 3]))
comm.print(dist.X)
comm.print(dist.X.df)

### Finish.
finalize()
}
}
\keyword{utility}
