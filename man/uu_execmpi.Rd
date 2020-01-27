\name{Utility execmpi}
\alias{execmpi}
\alias{runmpi}
\title{ Execute MPI code in system }
\description{
  This function basically saves code in a spmd.file and executes
  MPI via R's system call e.g.
  \code{system("mpiexec -np 1 Rscript spmd.file")}.
}
\usage{
execmpi(spmd.code = NULL, spmd.file = NULL,
    mpicmd = NULL, nranks = 1L, rscmd = NULL, verbose = TRUE,
    disable.current.mpi = TRUE)
runmpi(spmd.code = NULL, spmd.file = NULL,
    mpicmd = NULL, nranks = 1L, rscmd = NULL, verbose = TRUE,
    disable.current.mpi = TRUE)
}
\arguments{
  \item{spmd.code}{SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{spmd.file}{a file contains SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{mpicmd}{MPI executable command. If \code{NULL}, system default will be searched.}
  \item{nranks}{number of processes to run the SPMD code envoked by mpicmd.}
  \item{rscmd}{\code{Rscript} executable command. If \code{NULL}, system default will be searched.}
  \item{verbose}{print SPMD code outputs and MPI messages.}
  \item{disable.current.mpi}{force to finalize the current MPI comm if any, for unix-alike system only.}
}
\details{
  When the \code{spmd.code} is \code{NULL}: The code should be already
  saved in the file named \code{spmd.file} for using.

  When the \code{spmd.code} is not \code{NULL}:
  The \code{spmd.code} will be dumped to a temp file (\code{spmd.file}) via the
  call \code{writeLines(spmd.code, conn)} where
  \code{conn <- file(spmd.file, open = "wt")}. The file will be closed after
  the dumping.

  When \code{spmd.file} is ready (either dumped from \code{spmd.code} or
  provided by the user), the steps below will be followed:
  If \code{spmd.file = NULL}, then a temporary file will be generated and
  used to dump \code{spmd.code}.

  For Unix-alike systems, the command
  \code{cmd <- paste(mpicmd, "-np", nranks, rscmd, spmd.file, ">", log.file, " 2>&1 & echo \"PID=$!\" &")}
  is executed via \code{system(cmd, intern = TRUE, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)}. The \code{log.file} is a temporary file to
  save the outputs from the \code{spmd.code}. The results saved to the
  \code{log.file} will be read back in and \code{cat} and \code{return}
  to R.

  For Windows, the \code{cmd} will be
  \code{paste(mpicmd, "-np", nranks, rscmd, spmd.file)}
  and is executed via
  \code{system(cmd, intern = TRUE, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)}.
}
\value{
  Basically, only the PID of the MPI job (in background) will be returned
  in Linux-alike systems. For Windows, the MPI job is always wait until
  it is complete.
}
\note{
  For Unix-alike systems,
  in new R and MPI, the \code{pbdMPI::execmpi(...)} may
  carry the current MPI \code{comm} into \code{system(cmd, ...)} calls.
  Because the \code{comm} has been established/loaded by the
  \code{init()} call because of \code{::},
  the \code{mpiexec} inside the \code{system(cmd, ...)} calls
  will be confused with the exist \code{comm}.

  Consider that \code{pbdMPI::execmpi(...)} is typically called in
  interactive mode (or actually only done for CRAN check in most case),
  an argument \code{disable.current.mpi = TRUE} is added/needed to finalize
  the existing \code{comm} first before \code{system(cmd, ...)} be executed.

  This function is NOT recommended for running SPMD programs.
  The recommended way is to run under shell command.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com} and Drew Schmidt.
}
\seealso{
  \code{pbdCS::pbdRscript()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(1)
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)

spmd.file <- tempfile()
cat("
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(2)
finalize()
", file = spmd.file)
pbdMPI::execmpi(spmd.file = spmd.file, nranks = 2L)
%}
}
\keyword{utility}
