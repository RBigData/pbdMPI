\name{global all pairs}
\alias{comm.allpairs}
\title{ Global All Pairs }
\description{
  This function provide global all pairs.
}
\usage{
comm.allpairs(N, diag = FALSE, symmetric = TRUE,
              comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{N}{number of elements for matching, \code{(i, j)} for all
           \code{1 <= i,j <= N}.}
  \item{diag}{if matching the same elements, \code{(i, i)} for all \code{i}.}
  \item{symmetric}{if matching upper triangular elements. TRUE for
                   \code{i >= j} only, otherwise for all \code{(i, j)}.}
  \item{comm}{a communicator number.}
}
\details{
  The function generates all combinations of \code{N} elements.
}
\value{
  The function returns a gbd matrix in row blocks with 2 columns
  named \code{i} and \code{j}. The number of rows is dependent
  on the options \code{diag} and \code{symmetric}. If \code{diag = TRUE} and
  \code{symmetric = FALSE}, then this case has the maximum number of rows,
  \code{N^2}.
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
  \code{\link{comm.dist}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

### Examples.
id.matrix <- comm.allpairs(comm.size() + 1)
comm.print(id.matrix, all.rank = TRUE)

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
