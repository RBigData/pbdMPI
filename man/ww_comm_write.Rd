\name{global writing}
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
           append = FALSE, sep = " ", comm = .pbd_env$SPMD.CT$comm)
comm.write.table(x, file = "", append = FALSE, quote = TRUE, sep = " ",
                 eol = "\n", na = "NA", dec = ".", row.names = TRUE,
                 col.names = TRUE, qmethod = c("escape", "double"),
                 fileEncoding = "", comm = .pbd_env$SPMD.CT$comm)

comm.write.csv(..., comm = .pbd_env$SPMD.CT$comm)
comm.write.csv2(..., comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{as in \code{write()} or \code{write.table()}.}
  \item{file}{as in \code{write()} or \code{write.table()}.}
  \item{ncolumns}{as in \code{write*()}.}
  \item{append}{as in \code{write*()}.}
  \item{sep}{as in \code{write*()}.}
  \item{quote}{as in \code{write*()}.}
  \item{eol}{as in \code{write*()}.}
  \item{na}{as in \code{write*()}.}
  \item{dec}{as in \code{write*()}.}
  \item{row.names}{as in \code{write*()}.}
  \item{col.names}{as in \code{write*()}.}
  \item{qmethod}{as in \code{write*()}.}
  \item{fileEncoding}{as in \code{write*()}.}
  \item{...}{as in \code{write*()}.}
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
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{comm.load.balance}()} and
  \code{\link{comm.read.table}()}
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
if(comm.size() != 2){
  comm.cat(\"2 processors are requried.\\n\", quiet = TRUE)
  finalize()
}

### Examples.
comm.write((1:5) + comm.rank(), file = \"test.txt\")

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
