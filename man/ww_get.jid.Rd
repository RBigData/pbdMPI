\name{get job id}
\alias{get.jid}
\title{ Divide Job ID by Ranks }
\description{
  This function obtains job id which can be used to divide jobs.
}
\usage{
  get.jid(n, method = .SPMD.CT$divide.method, all = FALSE,
          comm = .SPMD.CT$comm)
}
\arguments{
  \item{n}{total number of jobs.}
  \item{method}{a way to divide jobs.}
  \item{all}{indicate if return all id for each processor.}
  \item{comm}{a communicator number.}
}
\details{
  \code{n} is total number of jobs needed to be divided into all processors
  (\code{comm.size(comm)}, i.e. \code{1:n} will be split according to
  the rank of processor (\code{comm.rank(comm)}) and \code{method}.
  Job id will be returned. Currently, three possible methods are provided.

  \code{"block"} will use return id's which are nearly equal size blocks.
  For example,
  7 jobs in 4 processors will have \code{jid=1} for rank 0, \code{jid=2,3}
  for rank 1, \code{jid=4,5} for rank 2, and \code{jid=6,7} for rank 3.

  \code{"cycle"} will use return id's which are nearly equal size in cycle.
  For example, 7 jobs in 4 processors will have \code{jid=1,5} for rank 0,
  \code{jid=2,6} for rank 1, \code{jid=3,7} for rank 2, and \code{jid=4}
  for rank 3.
}
\value{
  \code{get.id} returns a vector containing job id for each individual
  processor if \code{all = FALSE}. While it returns a list containing all
  job id for all processor if \code{all = TRUE}. The list has length equal
  to \code{\link{COMM.SIZE}}.
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
# Save code in a file "demo.r" and run with 4 processors by
# > mpiexec -np 4 Rscript demo.r

### Initial
library(pbdMPI, quiet = TRUE)
init()

### Examples
comm.cat(">>> block\n", quiet = TRUE)
jid <- get.jid(7, method = "block")
comm.print(jid, all.rank = TRUE)

comm.cat(">>> cycle\n", quiet = TRUE)
jid <- get.jid(7, method = "cycle")
comm.print(jid, all.rank = TRUE)

comm.cat(">>> block (all)\n", quiet = TRUE)
alljid <- get.jid(7, method = "block", all = TREU)
comm.print(alljid)

comm.cat(">>> cycle (all)\n", quiet = TRUE)
alljid <- get.jid(7, method = "cycle", all = TREU)
comm.print(alljid)

### Finish
finalize()
}
}
\keyword{utility}

