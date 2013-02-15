\name{global stop and warning functions}
\alias{comm.stop}
\alias{comm.warning}
\title{ Global Stop and Warning Functions }
\description{
  These functions are global stop and warning applying on distributed data
  for all ranks.
}
\usage{
  comm.stop(..., call. = TRUE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm, quiet = TRUE, sep = " ",
    fill = FALSE, labels = NULL, append = FALSE, flush = TRUE,
    con = stdout())

  comm.warning(..., call. = TRUE, immediate. = FALSE, domain = NULL,
    all.rank = .SPMD.CT$print.all.rank, rank.print = .SPMD.CT$rank.source,
    comm = .SPMD.CT$comm, quiet = TRUE, sep = " ",
    fill = FALSE, labels = NULL, append = FALSE, flush = TRUE,
    con = stdout())
}
\arguments{
  \item{...}{variables to be cat.}
  \item{call.}{see stop() and warnings().}
  \item{domain}{see stop() and warnings().}
  \item{immediate.}{see stop() and warnings().}
  \item{all.rank}{if all ranks print (default = FALSE).}
  \item{rank.print}{rank for printing if not all ranks print (default = 0).}
  \item{comm}{communicator for printing (default = 1).}
  \item{quiet}{TRUE to disable printing rank number.}
  \item{sep}{sep argument as in the \code{cat} function.}
  \item{fill}{fill argument as in the \code{cat} function.}
  \item{labels}{labels argument as in the \code{cat} function.}
  \item{append}{labels argument as in the \code{cat} function.}
  \item{flush}{if flush \code{con}.}
  \item{con}{\code{stdout()} is the default to print message.}
}
\details{
  These functions will apply \code{stop()} and \code{warning()} locally.
}
\value{
  \code{stop()} terminates all ranks, and \code{warning()} returns
  messages.
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
if(comm.size() != 2){
  comm.cat("2 processors are requried.\n", quiet = TRUE)
  finalize()
}

### Examples
comm.warning("test warning.\n")
comm.stop("test stop.\n")

### Finish
finalize()
}
}
\keyword{utility}

