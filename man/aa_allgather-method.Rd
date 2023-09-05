\name{allgather-methods}
\docType{methods}

\alias{allgather-methods}

\alias{allgather,ANY,missing,missing-method}
\alias{allgather,integer,integer,missing-method}
\alias{allgather,numeric,numeric,missing-method}
\alias{allgather,raw,raw,missing-method}

\alias{allgather,ANY,missing,integer-method}
\alias{allgather,ANY,ANY,integer-method}
\alias{allgather,integer,integer,integer-method}
\alias{allgather,numeric,numeric,integer-method}
\alias{allgather,raw,raw,integer-method}

\alias{allgather}
\alias{allgatherv}

\title{ All Ranks Gather Objects from Every Rank }
\description{
  This method lets all ranks gather objects from every rank in the same
  communicator. The default return is a list of length equal to
  \code{comm.size(comm)}.
}
\usage{
allgather(x, x.buffer = NULL, x.count = NULL, displs = NULL,
          comm = .pbd_env$SPMD.CT$comm,
          unlist = .pbd_env$SPMD.CT$unlist)
}
\arguments{
  \item{x}{an object to be gathered from all ranks.}
  \item{x.buffer}{a buffer to hold the return object which probably has
                  `size of \code{x}' times `\code{comm.size(comm)}'
                  with the same type as \code{x}.}
  \item{x.count}{a vector of length `\code{comm.size(comm)}' containing all object lengths.}
  \item{displs}{\code{c(0L, cumsum(x.count))} by default.}
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
    
  The \code{allgather} is efficient due to the underlying MPI parallel
  communication and recursive doubling gathering algorithm that results in
  a sublinear (\code{log2(comm.size(comm))}) number of communication steps.
  Also, serialization is applied only locally and in parallel.
  
  See \code{methods{"allgather"}} for S4 dispatch cases and the source code for
  further details.
}
\value{
  A list of length \code{comm.size(comm)}, containing the gathered objects from
  each rank, is returned to all ranks by default. An exception is for atomic
  vectors, when
  \code{x.buffer} is specified, where a list is never formed and a single
  vector is returned. In other cases, the \code{unlist = TRUE} parameter
  simply applies the \code{unlist()} function to this list before returning.
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
  \code{\link{gather}()}, \code{\link{allreduce}()}, \code{\link{reduce}()}.
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

### Examples
N <- 5
x <- (1:N) + N * .comm.rank
y <- allgather(matrix(x, nrow = 1))
comm.print(y)

y <- allgather(x, double(N * .comm.size))
comm.print(y)

### Finish
finalize()
"
pbdMPI::execmpi(spmd.code, nranks = 2L)
}
}
\keyword{methods}
\keyword{collective}
