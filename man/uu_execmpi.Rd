\name{Utility execmpi}
\alias{execmpi}
\title{ Execute MPI code in system }
\description{
  This function basically saves code in a spmd.file and executes
  MPI via R's system call e.g.
  \code{system("mpiexec -np 2 Rscript spmd.file")}.
}
\usage{
execmpi(spmd.code = NULL, spmd.file = NULL, log.file = NULL,
    mpicmd = NULL, nranks = 2L, wait = TRUE, verbose = TRUE)
}
\arguments{
  \item{spmd.code}{SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{spmd.file}{a file contains SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{log.file}{a file to save SPMD code outputs.}
  \item{mpicmd}{MPI executable command. If \code{NULL}, system default will be searched.}
  \item{nranks}{number of processes to run the SPMD code envoked by mpicmd.}
  \item{wait}{if wait for MPI job to finish.}
  \item{verbose}{print SPMD code outputs and MPI messages.}
}
\details{
  When the \code{spmd.code} is \code{NULL}: The code should be already
  saved in the file named \code{spmd.file} for using.

  When the \code{spmd.code} is not \code{NULL}:
  The \code{spmd.code} will be dumped to a temp file (\code{spmd.file}) via the
  call \code{writeLines(spmd.code, conn)} where
  \code{conn <- file(spmd.file, open = "wt")}. The file will be closed after
  the dumping.

  When \code{spmd.file} is ready (either dumpped from \code{spmd.code} or
  provided by the user), the command
  \code{cmd <- paste(mpicmd, "-np", nranks, "Rscript", spmd.file, ">", log.file, " 2>&1 & echo \"PID=$!\" &")}
  is executed via \code{system(cmd, intern = TRUE, wait = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE, ...)}.

  For Windows, the \code{cmd} will be
  \code{paste(mpicmd, "-np", nranks, "Rscript", spmd.file, ">", log.file)}
  and is executed via
  \code{system(cmd, intern = FALSE, wait = wait, ignore.stdout = TRUE, ignore.stderr = TRUE, ...)}.
}
\value{
  Basically, only the PID of the MPI job (in background) will be returned
  in Linux-alike systems. For Windows, the MPI job is always wait unitl
  it is complete regardless \code{wait} is \code{TRUE} or \code{FALSE}.

  All systems will dump the SPMD code (or MPI) resluts to the
  \code{log.file} regardless \code{wait} is \code{TRUE} or \code{FALSE}.

  If \code{wait = TRUE}, then the outputs will be read from the \code{log.file}
  and \code{cat} in R.

  If \code{code.file = NULL}, then a temporary file will be generated and
  used.

  One may get the SPMD code outputs by providing a \code{log.file} and
  manually read the \code{log.file} file when the MPI job is complete.
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
