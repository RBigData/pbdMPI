\name{seed for RNG}
\alias{comm.set.seed}
\alias{comm.end.seed}
\alias{comm.reset.seed}
\title{ Seed Functions for Random Number Generators }
\description{
  These functions set/end/reset seeds to all ranks.
}
\usage{
  comm.set.seed(seed = rep(12345, 6), diff = FALSE,
                comm = .SPMD.CT$comm)
  comm.end.seed(comm = .SPMD.CT$comm)
  comm.reset.seed(comm = .SPMD.CT$comm)
}
\arguments{
  \item{seed}{six integers.}
  \item{diff}{if all ranks use the same stream. (default = FALSE)}
  \item{comm}{a communicator number.}
}
\details{
  \code{comm.set.seed} set the given \code{seed} to all ranks.
  If \code{diff = FALSE}, then all ranks generate one stream and use that
  stream. Otherwise, all ranks generate \code{\link{COMM.SIZE}} streams and
  use the stream according to \code{\link{COMM.RANK} + 1}.
}
\value{
  Several hidden objects are set in the \code{.GlobalEnv}, see
  ``rlecuyer'' package for details.
}
\references{
  Pierre L'Ecuyer, Simard, R., Chen, E.J., and Kelton, W.D. (2002)
  An Object-Oriented Random-Number Package with Many Long Streams and
  Substreams. Operations Research, 50(6), 1073-1075.

  Sevcikova, H. and Rossini, T. (2012) rlecuyer: R interface to RNG with
  multiple streams. R Package, URL http://cran.r-project.org/package=rlecuyer

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
library(pbdMPI, quiet = TRUE)
init()

### Examples
comm.set.seed()
comm.print(rnorm(5), all.rank = TRUE)
comm.reset.seed()
comm.print(rnorm(5), all.rank = TRUE)
comm.end.seed()

comm.set.seed(diff = TRUE)
comm.print(rnorm(5), all.rank = TRUE)
comm.end.seed()

### Finish
finalize()
}
}
\keyword{utility}

