\name{Utility execmpi}
\alias{execmpi}
\title{ Execute MPI code in system }
\description{
  This function basically saves code in a spmd.file and executes
  MPI via R's system call e.g.
  \code{system("mpiexec -np 2 Rscript spmd.file")}.
}
\usage{
execmpi(spmd.code = NULL, spmd.file = NULL, mpicmd = "mpiexec",
    nranks = 2L, intern = FALSE, ignore.stdout = FALSE,
    ignore.stderr = FALSE, wait = TRUE)
}
\arguments{
  \item{spmd.code}{SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{spmd.file}{a file contains SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{mpicmd}{MPI executable command.}
  \item{nranks}{number of processes to run the SPMD code envoked by mpicmd.}
  \item{intern}{as in \code{\link[base]{system}()}.}
  \item{ignore.stdout}{as in \code{\link[base]{system}()}.}
  \item{ignore.stderr}{as in \code{\link[base]{system}()}.}
  \item{wait}{as in \code{\link[base]{system}()}.}
}
\details{
  When the \code{spmd.code} is \code{NULL}: The code should be already
  saved in the file named \code{spmd.file} for using.

  When the \code{spmd.code} is not \code{NULL}:
  The \code{spmd.code} will be dumped to a temp file (\code{spmd.file}) via the
  call \code{writeLines(spmd.code, conn)} where
  \code{conn <- file(spmd.file, open = "wt")}. The file will be closed after
  the dumping.
  Then, the command
  \code{cmd <- paste(mpicmd, "-np", nranks, "Rscript", spmd.file)}
  is executed via \code{system(cmd, ...)}.
}
\value{
  As what \code{system(cmd, ...)} returns.
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
# execmpi(spmd.code = spmd.code, nranks = 2L)

spmd.file <- tempfile()
cat("
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(2)
finalize()
", file = spmd.file)
# execmpi(spmd.file = spmd.file, nranks = 2L)
%}
}
\keyword{utility}
