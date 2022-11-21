\name{global pairwise}
\alias{comm.pairwise}
\title{ Global Pairwise Evaluations }
\description{
  This function provides global pairwise evaluations.
}
\usage{
comm.pairwise(X, pairid.gbd = NULL,
    FUN = function(x, y, ...){ return(as.vector(dist(rbind(x, y), ...))) },
    ..., diag = FALSE, symmetric = TRUE, comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{X}{a common matrix across ranks, or a gbd matrix. (See details.)}
  \item{pairid.gbd}{a pair-wise id in a gbd format. (See details.)}
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
  on any given pair \code{(i, j)} of a matrix \code{X}.

  The input \code{X} should be in common across all ranks if \code{pairid.gbd}
  is provided, e.g. from \code{comm.pairwise()}.
  i.e. \code{X} is exactly the same in every ranks, but
  \code{pairid.gbd} is different and in gbd format indicating the row pair
  \code{(i, j)} should be evaluated. The returning gbd matrix is ordered
  and indexed by \code{pairid.gbd}.

  Note that checking consistence of \code{X} across all ranks is not
  implemented within this function since that drops performance and
  may be not accurate.

  The input \code{X} should be a gbd format in row major blocks
  (i.e. \code{X.gbd}) if \code{pairid.gbd} is \code{NULL}. A internal
  pair indices will be built implicitly for evaluation. The returning
  gbd matrix is ordered and indexed by \code{X.gbd}.
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
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{comm.pairwise}()}, and
  \code{\link{comm.dist}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))

### Examples.
comm.set.seed(123456, diff = FALSE)
X <- matrix(rnorm(10), ncol = 2)
id.matrix <- comm.allpairs(nrow(X))

### Method original.
dist.org <- dist(X)

### Method 1.
dist.common <- comm.pairwise(X, pairid.gbd = id.matrix)

### Method 2.
# if(comm.rank() != 0){
#   X <- matrix(0, nrow = 0, ncol = 4)
# }
X.gbd <- comm.as.gbd(X)    ### The other way.
dist.gbd <- comm.pairwise(X.gbd)

### Verify.
d.org <- as.vector(dist.org)
d.1 <- do.call(\"c\", allgather(dist.common[, 3]))
d.2 <- do.call(\"c\", allgather(dist.gbd[, 3]))
comm.print(all(d.org == d.1))
comm.print(all(d.org == d.2))

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
