\name{global pairwise}
\alias{comm.pairwise}
\title{ Global Pairwise Evaulations }
\description{
  This function provides global pairwise evaulations.
}
\usage{
  comm.pairwise(X.gbd,
    FUN = function(x, y, ...){ return(as.vector(dist(rbind(x, y), ...))) },
    ..., diag = FALSE, symmetric = TRUE, comm = .SPMD.CT$comm)
}
\arguments{
  \item{X.gbd}{a gbd matrix.}
  \item{FUN}{a function to be evaluated for given pairs.}
  \item{...}{extra variables for \code{FUN}.}
  \item{diag}{if matching the same elements, \code{(i, i)} for all \code{i}.}
  \item{symmetric}{if matching upper triangular elements. TRUE for
                   \code{i >= j} only, otherwise for all \code{(i, j)}.}
  \item{comm}{a communicator number.}
}
\details{
  This function evaluates the objective function
  \code{FUN(X[i,], X[j, ])} (usually distance of two elements)
  on any given pair \code{(i, j)} of a global matrix \code{X} which 
  is composed by all \code{X.gbd}'s. i.e. \code{(i, j)} are global indices
  as in a distance matrix for i-th row and j-th columns.
}
\value{
  This function returns a common matrix with 3 columns
  named \code{i}, \code{j}, and \code{value}. Each \code{value} is the
  returned value and computed by \code{FUN(X[i,], X[j,])} where
  \code{(i, j)} is the global index as ordered in a distance matrix
  for i-th row and j-th columns.
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
  \code{\link{comm.dist}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

### Initial.
library(pbdMPI, quietly = TRUE)
init()

### Examples.
id.matrix <- comm.allpairs(comm.size() + 1)
comm.print(id.matrix, all.rank = TRUE)

### Finish.
finalize()
}
}
\keyword{utility}
