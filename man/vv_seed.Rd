\name{seed for RNG}
\alias{comm.set.seed}
\alias{comm.seed.state}
\alias{comm.end.seed}
\alias{comm.reset.seed}
\title{ Seed Functions for Random Number Generators }
\description{
  These functions set/end/reset seeds to all ranks.
  By default, these functions are wrappers of \pkg{rlecuyer} which implements
  the random number generator with multiple independent streams
  developed by L'Ecuyer et al (2002).
}
\usage{
comm.set.seed(seed, diff = FALSE, state = NULL,
              comm = .pbd_env$SPMD.CT$comm)
comm.seed.state(comm = .pbd_env$SPMD.CT$comm)
comm.end.seed(comm = .pbd_env$SPMD.CT$comm)
comm.reset.seed(comm = .pbd_env$SPMD.CT$comm)
}
\arguments{
  \item{seed}{one integer or six integers as in \pkg{rlecuyer}.}
  \item{diff}{if all ranks use the same stream. (default = FALSE)}
  \item{state}{a new state to overwrite seed.}
  \item{comm}{a communicator number.}
}
\details{
  \code{comm.set.seed()} sets the given \code{seed} to all ranks.
  If \code{diff = FALSE}, then all ranks generate one stream and use that
  stream. Otherwise, all ranks generate \code{\link{COMM.SIZE}} streams and
  use the stream named by \code{\link{COMM.RANK}}.

  Also, \code{comm.set.seed()} can assign to arbitrarily \code{state}
  obtained from \code{comm.seed.state()}.

  \code{comm.seed.state()} obtains current state of \code{seed} which ends the
  stream first (update state), gets the state, and continues the stream
  (pretend as nothing happens).

  \code{comm.end.seed()} ends and deletes \code{seed} from all ranks.

  \code{comm.reset.seed()} resets \code{seed} to initial start steps which
  end the current \code{seed} and reset everything back to the start stream.
  Use this function with caution.
}
\value{
  Several hidden objects are set in the \code{.GlobalEnv}, see
  \pkg{rlecuyer} package for details.
}
\references{
  Pierre L'Ecuyer, Simard, R., Chen, E.J., and Kelton, W.D. (2002)
  An Object-Oriented Random-Number Package with Many Long Streams and
  Substreams. Operations Research, 50(6), 1073-1075.

  \url{http://www.iro.umontreal.ca/~lecuyer/myftp/papers/streams00.pdf}

  Sevcikova, H. and Rossini, T. (2012) rlecuyer: R interface to RNG with
  multiple streams. R Package, URL https://cran.r-project.org/package=rlecuyer

  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{.lec.SetPackageSeed()},
  \code{.lec.CreateStream()},
  \code{.lec.CurrentStream()},
  \code{.lec.CurrentStreamEnd()},
  \code{.lec.DeleteStream()},
  \code{.lec.SetSeed()}, and
  \code{.lec.GetState()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

### Examples.
comm.set.seed(123456)
comm.print(runif(5), all.rank = TRUE)
comm.reset.seed()
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Obtain the seed state.
comm.set.seed(123456, diff = TRUE)
comm.print(runif(5), all.rank = TRUE)
saved.seed <- comm.seed.state()   ### save the state.
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Start from a saved state.
comm.set.seed(123456, state = saved.seed) ### rewind to the state.
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Finish.
finalize()
"
execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
