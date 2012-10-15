\name{apply and lapply}
\alias{pbdApply}
\alias{pbdLapply}
\alias{pbdSapply}
\title{ Parallel Apply and Lapply Functions }
\description{
  The functions are parallel versions of apply and lapply functions..
}
\usage{
  pbdApply(X, MARGIN, FUN, ..., pbd.mode = c("mw", "spmd"),
           rank.source = .SPMD.CT$rank.root, comm = .SPMD.CT$comm)
  pbdLapply(X, FUN, ..., pbd.mode = c("mw", "spmd"),
            rank.source = .SPMD.CT$rank.root, comm = .SPMD.CT$comm)
  pbdSapply(X, FUN, ..., simplify = TRUE, USE.NAMES = TRUE,
            pbd.mode = c("mw", "spmd"), rank.source = .SPMD.CT$rank.root,
            comm = .SPMD.CT$comm)
}
\arguments{
  \item{X}{a matrix in \code{pbdApply} or a list in \code{pbdLapply} and
           \code{pbdSapply}.}
  \item{MARGIN}{\code{MARGIN = 1, 2} as in the \code{apply}.}
  \item{FUN}{as in the \code{apply}.}
  \item{...}{optional arguments to \code{FUN}.}
  \item{simplify}{as in the \code{sapply}.}
  \item{USE.NAMES}{as in the \code{sapply}.}
  \item{pbd.mode}{mode of distributed data \code{X}.}
  \item{rank.source}{a rank of source where \code{X} broadcast from.}
  \item{comm}{a communicator number.}
}
\details{
  All functions are majorly called in manager/workers mode, and just
  work the same as their serial version. For SPMD mode, these are redundant
  even.

  If \code{pbd.mode = "mw"}, the \code{X} in \code{rank.source} will be
  redistributed to all processors, then apply \code{FUN} on the new data.

  If \code{pbd.mode = "spmd"}, the \code{X} is supposed to exist in all
  processors and just acting as normal apply in SPMD.
}
\value{
  A list will be returned.
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
library(pbdMPI, quiet = TRUE)
init()

### Example for pbdApply
N <- 100
x <- matrix((1:N) + N * .comm.rank, ncol = 10)
y <- pbdApply(x, 1, sum)
comm.print(y)

y <- pbdApply(x, 1, sum, pbd.mode = "mw")
comm.print(y)

### Example for pbdLapply
N <- 100
x <- split((1:N) + N * .comm.rank, rep(1:10, each = 10))
y <- pbdLapply(x, sum)
comm.print(unlist(y))

y <- pbdLapply(x, sum, pbd.mode = "mw")
comm.print(unlist(y))

### Finish
finalize()
}
}
\keyword{utility}

