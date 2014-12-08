\name{global balanc}
\alias{comm.balance.info}
\alias{comm.load.balance}
\alias{comm.unload.balance}
\title{ Global Balance Functions }
\description{
  These functions are global balance methods for gbd \code{data.frame} (or
  \code{matrix}) distributed in row blocks.
}
\usage{
  comm.balance.info(X.gbd, balance.method = .SPMD.IO$balance.method[1],
                    comm = .SPMD.CT$comm)
  comm.load.balance(X.gbd, bal.info = NULL,
                    balance.method = .SPMD.IO$balance.method,
                    comm = .SPMD.CT$comm)
  comm.unload.balance(new.X.gbd, bal.info, comm = .SPMD.CT$comm)
}
\arguments{
  \item{X.gbd}{a gbd \code{data.frame} (or \code{matrix}).}
  \item{balance.method}{a balance method.}
  \item{bal.info}{a balance information returned from
                  \code{comm.balance.info()}. If \code{NULL}, then
                  this will be generated inside \code{comm.load.balance()}.}
  \item{new.X.gbd}{a new gbd of \code{X.gbd} (may be generated from
                   \code{comm.load.balance()}.}
  \item{comm}{a communicator number.}
}
\details{
   A typical use is to balance an input dataset \code{X.gbd} from
  \code{\link{comm.read.table}()}.  Since by default, a two dimension
  \code{data.frame} is distributed in row blocks, but each processor (rank)
  may not (or closely) have the same number of rows.
  These functions redistribute the \code{data.frame} (and maybe
  \code{matrix}) according to the specified way in \code{bal.info}.

  Currently, there are three balance methods are supported, \code{block}
  (uniform distributed but favor higher ranks), \code{block0}
  (as \code{block} but favor lower ranks), and \code{block.cyclic}
  (as block cyclic with one big block in one cycle).
}
\value{
  \code{comm.balance.info()} returns a \code{list} containing
  balance information based on the input \code{X.gbd} and \code{balance.method}.

  \code{comm.load.balance()} returns a new gbd \code{data.frame} (or
  \code{matrix}).

  \code{comm.unload.balance()} also returns the new gbd \code{data.frame} back
  to the original \code{X.gbd}.
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
  \code{\link{comm.read.table}()},
  \code{\link{comm.write.table}()}, and
  \code{\link{comm.as.gbd}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 4 processors by
### SHELL> mpiexec -np 4 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))

### Get two gbd row-block data.frame.
da.block <- iris[get.jid(nrow(iris), method = "block"),]
da.block0 <- iris[get.jid(nrow(iris), method = "block0"),]

### Load balance one and unload it.
bal.info <- comm.balance.info(da.block0)
da.new <- comm.load.balance(da.block0)
da.org <- comm.unload.balance(da.new, bal.info)

### Check if all are equal.
comm.print(c(sum(da.new != da.block), sum(da.org != da.block0)),
           all.rank = TRUE)

### Finish.
finalize()
}
}
\keyword{utility}
