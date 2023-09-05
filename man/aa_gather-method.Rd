\name{gather-methods}
\docType{methods}

\alias{gather-methods}

\alias{gather,ANY,missing,missing-method}
\alias{gather,integer,integer,missing-method}
\alias{gather,numeric,numeric,missing-method}
\alias{gather,raw,raw,missing-method}

\alias{gather,ANY,missing,integer-method}
\alias{gather,ANY,ANY,integer-method}
\alias{gather,integer,integer,integer-method}
\alias{gather,numeric,numeric,integer-method}
\alias{gather,raw,raw,integer-method}

\alias{gather}
\alias{gatherv}

\title{ A Rank Gathers Objects from Every Rank }
\description{
  This method lets one rank gather objects from every rank in the same
  communicator. The default return is a list of length equal to \code{comm size}.
}
\usage{
gather(x, x.buffer = NULL, x.count = NULL, displs = NULL,
       rank.dest = .pbd_env$SPMD.CT$rank.root,
       comm = .pbd_env$SPMD.CT$comm,
       unlist = .pbd_env$SPMD.CT$unlist)
}
\arguments{
  \item{x}{an object to be gathered from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  `size of \code{x}' times `\code{comm.size(comm)}' 
                  with the same type of \code{x}.}
  \item{x.count}{a vector of length `\code{comm.size(comm)}' containing all
  object lengths.}
  \item{displs}{\code{c(0L, cumsum(x.count))} by default.}
  \item{rank.dest}{a rank of destination where all \code{x} gather to.}
  \item{comm}{a communicator number.}
  \item{unlist}{apply \code{unlist} function to the gathered list before
  return.}
}
\details{
  The arguments \code{x.buffer}, \code{x.count}, and \code{displs} can be 
  left unspecified or \code{NULL} and are computed for you. 
  
  If \code{x.buffer} is specified, its type should be one of integer, double,
  or raw according to the type of \code{x}. Serialization and unserialization
  is avoided for atomic vectors if they are
  all the same size and \code{x.buffer} is specified, or if different sizes and
  both \code{x.buffer} and \code{x.count} are specified. A single vector 
  instead of a list is returned in these cases.
  
  Class \code{array} objects are gathered without serialization.
  
  Complex objects can be gathered as serialization and unserialization is used
  on objects that are not of class "array" or atomic vectors.
    
  The \code{gather} is efficient due to the underlying MPI parallel
  communication and recursive doubling gathering algorithm that results in
  a sublinear (\code{log2(comm.size(comm))}) number of communication steps.
  Also, serialization is applied only locally and in parallel.
  
  See \code{methods{"gather"}} for S4 dispatch cases and the source code for
  further details.
}
\value{
  Only \code{rank.dest} (by default rank 0) receives the gathered object. All
  other ranks receive \code{NULL}.
  See \code{\link{allgather}()} for a description of the gathered object.
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
  \code{\link{allgather}()}, \code{\link{allreduce}()}, \code{\link{reduce}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
y <- gather(matrix(x, nrow = 1))
comm.print(y)

y <- gather(x, double(N * .comm.size))
comm.print(y)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code, nranks = 2L)
}
}
\keyword{methods}
\keyword{collective}
