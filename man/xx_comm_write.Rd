\name{global writing functions}
\alias{comm.write}
\alias{comm.write.table}
\alias{comm.write.csv}
\alias{comm.write.csv2}
\title{ Global Writing Functions }
\description{
  These functions are global writing applying on distributed data
  for all ranks.
}
\usage{
  comm.write(x, file = "data", ncolumns = if(is.character(x)) 1 else 5,
             append = FALSE, sep = " ", comm = .SPMD.CT$comm)
  comm.write.table(x, file = "", append = FALSE, quote = TRUE, sep = " ",
                   eol = "\n", na = "NA", dec = ".", row.names = TRUE,
                   col.names = TRUE, qmethod = c("escape", "double"),
                   fileEncoding = "", comm = .SPMD$comm)
  comm.write.csv(..., comm = .SPMD.CT$comm)
  comm.write.csv2(..., comm = .SPMD.CT$comm)
}
\arguments{
  \item{x}{as in \code{write()} or \code{write.table()}.}
  \item{file}{as in \code{write()} or \code{write.table()}.}
  \item{ncolumns}{as usual in \code{write*()}.}
  \item{append}{as usual in \code{write*()}.}
  \item{sep}{as usual in \code{write*()}.}
  \item{quote}{as usual in \code{write*()}.}
  \item{eol}{as usual in \code{write*()}.}
  \item{na}{as usual in \code{write*()}.}
  \item{dec}{as usual in \code{write*()}.}
  \item{row.names}{as usual in \code{write*()}.}
  \item{col.names}{as usual in \code{write*()}.}
  \item{qmethod}{as usual in \code{write*()}.}
  \item{fileEncoding}{as usual in \code{write*()}.}
  \item{...}{as usual in \code{write*()}.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply \code{write*()} locally and sequentially
  from rank 0, 1, 2, ...

  By default, rank 0 makes the file, and rest of ranks append the data.
}
\value{
  A file will be returned.
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
comm.write((1:5) + comm.rank(), file = "test.txt")

### Finish
finalize()
}
}
\keyword{utility}

