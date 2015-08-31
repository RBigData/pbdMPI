\name{global reading}
\alias{comm.read.table}
\alias{comm.read.csv}
\alias{comm.read.csv2}
\title{ Global Reading Functions }
\description{
  These functions are global reading from specified file.
}
\usage{
comm.read.table(file, header = FALSE, sep = "", quote = "\"'",
                dec = ".", col.names,
                na.strings = "NA", colClasses = NA, nrows = -1, skip = 0,
                check.names = TRUE, fill = !blank.lines.skip,
                strip.white = FALSE,
                blank.lines.skip = TRUE, comment.char = "#",
                allowEscapes = FALSE,
                flush = FALSE,
                fileEncoding = "", encoding = "unknown", text,
                read.method = .pbdMPIEnv$SPMD.IO$read.method[1],
                balance.method = .pbdMPIEnv$SPMD.IO$balance.method[1],
                comm = .pbdMPIEnv$SPMD.CT$comm)

comm.read.csv(file, header = TRUE, sep = ",", quote = "\"",
              dec = ".", fill = TRUE, comment.char = "", ...,
              read.method = .pbdMPIEnv$SPMD.IO$read.method[1],
              balance.method = .pbdMPIEnv$SPMD.IO$balance.method[1],
              comm = .pbdMPIEnv$SPMD.CT$comm)
     
comm.read.csv2(file, header = TRUE, sep = ";", quote = "\"",
               dec = ",", fill = TRUE, comment.char = "", ...,
               read.method = .pbdMPIEnv$SPMD.IO$read.method[1],
               balance.method = .pbdMPIEnv$SPMD.IO$balance.method[1],
               comm = .pbdMPIEnv$SPMD.CT$comm)
}
\arguments{
  \item{file}{as in \code{read.table()}.}
  \item{header}{as in \code{read.table()}.}
  \item{sep}{as in \code{read.table()}.}
  \item{quote}{as in \code{read.table()}.}
  \item{dec}{as in \code{read.table()}.}
  \item{col.names}{as in \code{read.table()}.}
  \item{na.strings}{as in \code{read.table()}.}
  \item{colClasses}{as in \code{read.table()}.}
  \item{nrows}{as in \code{read.table()}.}
  \item{skip}{as in \code{read.table()}.}
  \item{check.names}{as in \code{read.table()}.}
  \item{fill}{as in \code{read.table()}.}
  \item{strip.white}{as in \code{read.table()}.}
  \item{blank.lines.skip}{as in \code{read.table()}.}
  \item{comment.char}{as in \code{read.table()}.}
  \item{allowEscapes}{as in \code{read.table()}.}
  \item{flush}{as in \code{read.table()}.}
  \item{fileEncoding}{as in \code{read.table()}.}
  \item{encoding}{as in \code{read.table()}.}
  \item{text}{as in \code{read.table()}.}
  \item{...}{as in \code{read.csv*()}.}
  \item{read.method}{either "gbd" or "common".}
  \item{balance.method}{balance method for \code{read.method = "gbd"}
                        as \code{nrows = -1} and \code{skip = 0} are set.}
  \item{comm}{a communicator number.}
}
\details{
  These functions will apply \code{read.table()} locally and sequentially
  from rank 0, 1, 2, ...

  By default, rank 0 reads the file only, then scatter to other ranks for
  small datasets (\code{.pbdMPIEnv$SPMD.IO$max.read.size}) in
  \code{read.method = "gbd"}.
  (bcast to others in \code{read.method = "common"}.)

  As dataset size increases, the reading is performed from each ranks and
  read portion of rows in "gbd" format as described in \pkg{pbdDEMO}
  vignettes and used in \pkg{pmclust}.

  \code{\link{comm.load.balance}()} is called for "gbd" method as
  as \code{nrows = -1} and \code{skip = 0} are set. Note that the default
  method "block" is the better way for performance in general that distributes
  equally and leaves residuals on higher ranks evenly.
  "block0" is the other way around. "block.cyclic" is only useful for
  converting to \code{ddmatrix} as in \pkg{pbdDMAT}.
}
\value{
  A distributed data.frame is returned.

  All factors are disable and read as characters or as what data should be.
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
  \code{\link{comm.load.balance}()} and
  \code{\link{comm.write.table}()}
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 4 processors by
### SHELL> mpiexec -np 4 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))

### Check.
if(comm.size() != 4){
  comm.stop("4 processors are requried.")
}

### Manually distributed iris.
da <- iris[get.jid(nrow(iris)),]

### Dump data.
comm.write.table(da, file = "iris.txt", quote = FALSE, sep = "\t",
                 row.names = FALSE)

### Read back in.
da.gbd <- comm.read.table("iris.txt", header = TRUE, sep = "\t",
                          quote = "")
comm.print(c(nrow(da), nrow(da.gbd)), all.rank = TRUE)

### Read in common.
da.common <- comm.read.table("iris.txt", header = TRUE, sep = "\t",
                             quote = "", read.method = "common")
comm.print(c(nrow(da.common), sum(da.common != iris)))

### Finish.
finalize()
}
}
\keyword{utility}
