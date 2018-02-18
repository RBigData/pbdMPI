\name{Utility execmpi}
\alias{execmpi}
\title{ Execute MPI code in system }
\description{
  This function basically saves code in a temp file and executes
  MPI via R's system call e.g. \code{system("mpiexec -np 2 Rscript temp")}.
}
\usage{
execmpi(spmd.code, mpicmd = "mpiexec", nranks = 2L, temp = tempfile(),
    intern = FALSE, ignore.stdout = FALSE, ignore.stderr = FALSE,
    wait = TRUE)
}
\arguments{
  \item{spmd.code}{SPMD code to be run via mpicmd and \code{Rscript}.}
  \item{mpicmd}{MPI executable command.}
  \item{nranks}{number of processes to run the SPMD code envoked by mpicmd.}
  \item{temp}{tempory file to store the SPMD code.}
  \item{intern}{as passed to \code{system()}.}
  \item{ignore.stdout}{as passed to \code{system()}.}
  \item{ignore.stderr}{as passed to \code{system()}.}
  \item{wait}{as passed to \code{system()}.}
}
\details{
  The \code{spmd.code} will be dumped to a text file (\code{temp}) via the
  call \code{writeLines(spmd.code, conn)} where
  \code{conn <- file(temp, open = "wt")}. The file will be closed after
  the dumping.
  Then, the command
  \code{cmd <- paste(mpicmd, "-np", nranks, "Rscript", temp)}
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
execmpi("sessionInfo()", nranks = 1L)

spmd.code <- "
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
allreduce(1)
finalize()
"
execmpi(spmd.code, nranks = 2L)
}
\keyword{utility}
