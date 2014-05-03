\name{global pairing function}
\alias{comm.allpairs}
\alias{comm.pairwise}
\title{ Global Pairing and Matching }
\description{
  These functions provide global pairing and matching.
}
\usage{
  comm.allpairs(N, diag = FALSE, symmetric = TRUE,
                comm = .SPMD.CT$comm)
  comm.pairwise(X.gbd, pairs.gbd = NULL, diag = FALSE, symmetric = TRUE,
                comm = .SPMD.CT$comm)
}
\arguments{
  \item{N}{number of elements for matching, \code{(i, j)} for all
           \code{1 <= i,j <= N}.}
  \item{diag}{if matching the same elements, \code{(i, i)} for all \code{i}.}
  \item{symmetric}{if upper diagonal elements, \code{i <= j} for all
                   \code{i,j}.}
  \item{comm}{a communicator number.}

  \item{X.gbd}{a gbd matrix.}
  \item{pairs.gbd}{a two-columns gbd matrix containing pairing ids.}
}
\details{
  The function \code{comm.allpairs()} generates all combination of
  \code{N} elements.

  The function \code{comm.pairwise()} evaluates the objective function
  \code{fn(i, j)} (usually distance of two elements)
  on any given pair \code{(i, j)} of a gbd matrix \code{X.gbd}.
  If \code{pairs.gbd} is provided, then only the specified pairs will
  be evaluated by the objective function. 
}
\value{
  The function \code{comm.allpairs()} returns a gbd matrix with 2 columns
  named \code{i} and \code{j}. The number of rows is dependent on the
  options \code{diag} and \code{symmetric}. If \code{diag = TRUE} and
  \code{symmetric = FALSE}, the it will have the maximum number of rows,
  \code{N^2}.

  The function \code{comm.pairwise()} returns a gbd matrix with 3 columns
  named \code{i}, \code{j}, and \code{value} of \code{fn()}.
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
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quietly = TRUE)
init()

### Examples
id.matrix <- comm.allpairs(comm.size())
comm.print(id.matrix, all.rank = TRUE)

### Finish
finalize()
}
}
\keyword{utility}

