\name{recv-method}
\docType{methods}

\alias{recv-method}

\alias{recv,ANY-method}
\alias{recv,integer-method}
\alias{recv,numeric-method}
\alias{recv,raw-method}

\alias{recv}

\title{ A Rank Receives (Blocking) an Object from the Other Rank }
\description{
  This method lets a rank receive (blocking) an object from the other
  rank in the same communicator. The default return is the object sent from
  the other rank.
}
\usage{
recv(x.buffer = NULL, rank.source = .pbd_env$SPMD.CT$rank.source,
     tag = .pbd_env$SPMD.CT$tag, comm = .pbd_env$SPMD.CT$comm,
     status = .pbd_env$SPMD.CT$status,
     check.type = .pbd_env$SPMD.CT$check.type)
}
\arguments{
  \item{x.buffer}{a buffer to store \code{x} sent from the other rank.}
  \item{rank.source}{a source rank where \code{x} sent from}
  \item{tag}{a tag number.}
  \item{comm}{a communicator number.}
  \item{status}{a status number.}
  \item{check.type}{if checking data type first for handshaking.}
}
\details{
  A corresponding \code{send()} should be evoked at the corresponding rank
  \code{rank.source}.

  These are high level S4 methods. By default, \code{check.type} is \code{TRUE}
  and an additional \code{send()/recv()} will make a handshaking call first,
  then deliver the data next.
  i.e. an integer vector of length two (type and length)
  will be deliver first between \code{send()} and \code{recv()} to ensure
  a buffer (of right type and right size/length) is properly allocated at
  the \code{rank.dest} side.

  Currently, four data types are considered: \code{integer}, \code{double},
  \code{raw/byte}, and \code{default/raw.object}. The default method will
  make a \code{serialize()} call first to convert the general R object into
  a \code{raw} vector before sending it away. After the \code{raw} vector
  is received at the \code{rank.dest} side, the vector will be
  \code{unserialize()} back to the R object format.

  \code{check.type} set as \code{FALSE} will stop the additional
  handhsaking call, but the buffer should be prepared carefully
  by the user self. This is typically for the advanced users and
  more specifically calls are needed. i.e. calling those
  \code{spmd.send.integer} with \code{spmd.recv.integer} correspondingly.

  \code{check.type} also needs to be set as \code{FALSE} for more efficient
  calls such as \code{isend()/recv()} or \code{send()/irecv()}. Currently,
  no check types are implemented in those mixed calls.
}
\value{
  An object is returned by default and the buffer will be overwritten
  implicitely.
}
\section{Methods}{
For calling \code{spmd.recv.*()}:
\describe{
\item{\code{signature(x = "ANY")}}{}
\item{\code{signature(x = "integer")}}{}
\item{\code{signature(x = "numeric")}}{}
\item{\code{signature(x = "raw")}}{}
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
  \code{\link{irecv}()}, \code{\link{send}()}, \code{\link{isend}()}.
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
if(.comm.rank == 0){
  y <- send(matrix(x, nrow = 1))
} else if(.comm.rank == 1){
  y <- recv()
}
comm.print(y, rank.print = 1)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code, nranks = 2L)
}
}
\keyword{methods}
\keyword{collective}
