\name{global Rprof}
\alias{comm.Rprof}
\title{ A Rprof Function for SPMD Routines }
\description{
  A Rprof function for use with parallel codes executed in the batch
  SPMD style.
}
\usage{
comm.Rprof(filename = "Rprof.out", append = FALSE, interval = 0.02,
           memory.profiling = FALSE, gc.profiling = FALSE,
           line.profiling = FALSE, numfiles = 100L, bufsize = 10000L,
           all.rank = .pbdMPIEnv$SPMD.CT$Rprof.all.rank,
           rank.Rprof = .pbdMPIEnv$SPMD.CT$rank.source,
           comm = .pbdMPIEnv$SPMD.CT$comm)
}
\arguments{
  \item{filename}{as in \code{\link[utils]{Rprof}()}.}
  \item{append}{as in \code{\link[utils]{Rprof}()}.}
  \item{interval}{as in \code{\link[utils]{Rprof}()}.}
  \item{memory.profiling}{as in \code{\link[utils]{Rprof}()}.}
  \item{gc.profiling}{as in \code{\link[utils]{Rprof}()}.}
  \item{line.profiling}{as in \code{\link[utils]{Rprof}()}.}
  \item{numfiles}{as in \code{\link[utils]{Rprof}()}.}
  \item{bufsize}{as in \code{\link[utils]{Rprof}()}.}
  \item{all.rank}{if calling Rprof on all ranks (default = FALSE).}
  \item{rank.Rprof}{rank for calling Rprof if
                    \code{all.rank = FALSE} (default = 0).}
  \item{comm}{a communicator number.}
}
\details{
  as in \code{\link[utils]{Rprof}()}.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\keyword{utility}
