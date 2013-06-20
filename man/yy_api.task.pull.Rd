\name{Task Pull}
\alias{task.pull}
\alias{task.pull.workers}
\alias{task.pull.master}
\title{Functions for Task Pull Parallelism}
\description{
  These functions are designed in SPMD but assuming rank 0 is a master and
  rests are workers.
}
\usage{
  task.pull(jids, FUN, ..., rank.master = .SPMD.CT$rank.root,
            comm = .SPMD.CT$comm)

  task.pull.workers(FUN = function(jid, ...){ return(jid) }, ...,
                    rank.master = .SPMD.CT$rank.root, comm = .SPMD.CT$comm)
  task.pull.master(jids, rank.master = .SPMD.CT$rank.root,
                   comm = .SPMD.CT$comm)
}
\arguments{
  \item{jids}{all job ids.}
  \item{FUN}{a function to be evaluated in workers.}
  \item{...}{extra variables for \code{FUN}.}
  \item{rank.master}{a rank of master where \code{jid} sent from.}
  \item{comm}{a communicator number.}
}
\details{
  All of these functions are for SPMD, NOT for master/workers.

  \code{FUN} is a user defined function which has \code{jid} as
  the first argument and other variables are given in \code{...}.

  The \code{jids} will be asked by workers when jobs are available and
  workers are no job in hand.
}
\value{
  A list with length \code{comm.size() - 1}
  will be returned for mater, but \code{NULL} for workers.
  Each element of the list contains job id \code{jid} and
  returns \code{ret} of the \code{FUN} call.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{get.jid}}.
}
\examples{
\dontrun{
### Under command mode, run the demo with 4 processors by
### (Use Rscript.exe for windows system)
mpiexec -np 4 Rscript -e "demo(task_pull,'pbdMPI',ask=F,echo=F)"
}
}
\keyword{utility}
