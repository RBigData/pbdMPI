\name{reduce-method}
\docType{methods}

\alias{reduce-method}

\alias{reduce,ANY,missing-method}
\alias{reduce,integer,integer-method}
\alias{reduce,numeric,numeric-method}
\alias{reduce,logical,logical-method}
\alias{reduce,float32,float32-method}

\alias{reduce}

\title{ A Rank Receive a Reduction of Objects from Every Rank }
\description{
  This method lets a rank receive a reduction of objects from every rank
  in the same communicator based on a given operation. The default return
  is an object as the input.
}
\usage{
reduce(x, x.buffer = NULL, op = .pbd_env$SPMD.CT$op,
       rank.dest = .pbd_env$SPMD.CT$rank.source,
       comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{x}{an object to be gathered from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  \code{x} with the same type of \code{x}.}
  \item{op}{a reduction operation applied on combine all \code{x}.}
  \item{rank.dest}{a rank of destination where all \code{x} reduce to.}
  \item{comm}{a communicator number.}
}
\details{
  By default, the object is reduced to \code{.pbd_env$SPMD.CT$rank.source},
  i.e. \emph{rank 0L}.

  All \code{x} on all ranks are likely presumed to have the same size and type.

  \code{x.buffer} can be \code{NULL} or unspecified. If specified, the type
  should be either integer or double specified correctly according to the
  type of \code{x}.
}
\value{
  The reduced object of the same type as \code{x} is returned by default.
}
\section{Methods}{
For calling \code{spmd.reduce.*()}:
\describe{
\item{\code{signature(x = "ANY", x.buffer = "missing")}}{}
\item{\code{signature(x = "integer", x.buffer = "integer")}}{}
\item{\code{signature(x = "numeric", x.buffer = "numeric")}}{}
\item{\code{signature(x = "logical", x.buffer = "logical")}}{}
\item{\code{signature(x = "float32", x.buffer = "float32")}}{}
}}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{allgather}()}, \code{\link{gather}()}, \code{\link{reduce}()}.
}
\examples{
%\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
y <- reduce(matrix(x, nrow = 1), op = \"sum\")
comm.print(y)

y <- reduce(x, double(N), op = \"prod\")
comm.print(y)

x <- as.logical(round(runif(N)))
y <- reduce(x, logical(N), op = \"land\")
comm.print(y)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)
%}
}
\keyword{methods}
\keyword{collective}
