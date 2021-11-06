\name{global timer}
\alias{comm.timer}
\title{ A Timing Function for SPMD Routines }
\description{
  A timing function for use with parallel codes executed in the batch
  SPMD style.
}
\usage{
comm.timer(timed, comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{timed}{expression to be timed.}
  \item{comm}{a communicator number.}
}
\details{
  Finds the min, mean, and max execution time across all independent 
  processes executing the operation \code{timed}.
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Drew Schmidt.
}
\keyword{utility}
