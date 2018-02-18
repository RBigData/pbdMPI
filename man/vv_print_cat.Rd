\name{global print and cat}
\alias{comm.print}
\alias{comm.cat}
\title{ Global Print and Cat Functions }
\description{
  The functions globally print or cat a variable from specified processors,
  by default messages is shown on screen.
}
\usage{
comm.print(x, all.rank = .pbd_env$SPMD.CT$print.all.rank,
           rank.print = .pbd_env$SPMD.CT$rank.source,
           comm = .pbd_env$SPMD.CT$comm,
           quiet = .pbd_env$SPMD.CT$print.quiet,
           flush = .pbd_env$SPMD.CT$msg.flush,
           barrier = .pbd_env$SPMD.CT$msg.barrier,
           con = stdout(), ...)

comm.cat(..., all.rank = .pbd_env$SPMD.CT$print.all.rank,
         rank.print = .pbd_env$SPMD.CT$rank.source,
         comm = .pbd_env$SPMD.CT$comm,
         quiet = .pbd_env$SPMD.CT$print.quiet, sep = " ", fill = FALSE,
         labels = NULL, append = FALSE, flush = .pbd_env$SPMD.CT$msg.flush,
         barrier = .pbd_env$SPMD.CT$msg.barrier, con = stdout())
}
\arguments{
  \item{x}{a variable to be printed.}
  \item{...}{variables to be cat.}
  \item{all.rank}{if all ranks print (default = FALSE).}
  \item{rank.print}{rank for printing if not all ranks print (default = 0).}
  \item{comm}{communicator for printing (default = 1).}
  \item{quiet}{FALSE for printing rank number.}
  \item{sep}{sep argument as in the \code{cat()} function.}
  \item{fill}{fill argument as in the \code{cat()} function.}
  \item{labels}{labels argument as in the \code{cat()} function.}
  \item{append}{labels argument as in the \code{cat()} function.}
  \item{flush}{if flush \code{con}.}
  \item{barrier}{if barrier \code{con}.}
  \item{con}{\code{stdout()} is the default to print message.}
}
\details{
  \strong{Warning:} These two functions use \code{barrier()} to make sure
  the well printing process on screen, so should be called by all processors
  to avoid a deadlock. A typical misuse is called inside a condition check,
  such as \code{if(.comm.rank == 0) comm.cat(...)}.

  \code{rank.print} can be a integer vector containing the ranks of
  processors which print messages.
}
\value{
  A \code{print()} or \code{cat()} is called for the specified processors
  and the messages of the input variables is shown on screen by default.
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
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

### Example.
comm.print(comm.rank(), rank.print = 1)

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
