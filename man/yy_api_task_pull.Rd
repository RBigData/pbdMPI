\name{Task Pull}
\alias{task.pull}
\alias{task.pull.workers}
\alias{task.pull.manager}
\title{Functions for Task Pull Parallelism}
\description{
  These functions are designed for SPMD but assume that rank 0 is a manager and
  the rest are workers.
}
\usage{
task.pull(jids, FUN, ..., rank.manager = .pbd_env$SPMD.CT$rank.root,
          comm = .pbd_env$SPMD.CT$comm, bcast = .pbd_env$SPMD.TP$bcast,
          barrier = .pbd_env$SPMD.TP$barrier,
          try = .pbd_env$SPMD.TP$try,
          try.silent = .pbd_env$SPMD.TP$try.silent)

task.pull.workers(FUN = function(jid, ...){ return(jid) }, ...,
                  rank.manager = .pbd_env$SPMD.CT$rank.root,
                  comm = .pbd_env$SPMD.CT$comm,
                  try = .pbd_env$SPMD.TP$try,
                  try.silent = .pbd_env$SPMD.TP$try.silent)
task.pull.manager(jids, rank.manager = .pbd_env$SPMD.CT$rank.root,
                 comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{jids}{all job ids (a vector of positive integers).}
  \item{FUN}{a function to be evaluated by workers.}
  \item{...}{extra parameters for \code{FUN}.}
  \item{rank.manager}{rank of the manager from where \code{jid} is sent.}
  \item{comm}{a communicator number.}
  \item{bcast}{if bcast to all ranks.}
  \item{barrier}{if barrier for all ranks.}
  \item{try}{wheter to use \code{try()} to avoid crashes. CAUTION: 
             \code{try = FALSE} is not safe and can crash all MPI/R jobs.}
  \item{try.silent}{turn off error messages from \code{try()}.}
}
\details{
  All of these functions are designed to emulate a manager/workers paradigm in 
  an SPMD environment. If your chunk workloads are known and similar, consider
  a direct SPMD solution.

  \code{FUN} is a user defined function which has \code{jid} as
  its first argument and other variables are given in \code{...}.

  The manager will be queried by workers whenever a worker finishes a job to
  see if more jobs are available.
}
\value{
  A list with length \code{comm.size() - 1}
  will be returned to the manager and \code{NULL} to the workers.
  Each element of the list contains the returns \code{ret} of their \code{FUN}
  results.
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
  \code{\link{get.jid}()}.
}
\examples{
\dontrun{
### Under command mode, run the demo with 2 processors by
### (Use Rscript.exe for windows system)
# mpiexec -np 2 Rscript -e "demo(task_pull,'pbdMPI',ask=F,echo=F)"
### Or
# execmpi("demo(task_pull,'pbdMPI',ask=F,echo=F)", nranks = 2L)
}
}
\keyword{utility}
