\name{seed for RNG}
\alias{comm.set.seed}
\alias{comm.set.stream}
\alias{comm.get.streams}
\alias{comm.seed.state} %defunct
\alias{comm.end.seed} %defunct
\alias{comm.reset.seed} %defunct
\title{Parallel random number generation with reproducible results}
\description{
These functions control the parallel-capable L'Ecuyer-CMRG pseudo-random 
number generator (RNG) on clusters and in multicore parallel applications for 
reproducible results. Reproducibility is possible across different node and
core configurations by associating the RNG streams with an application 
vector.
}
\usage{
comm.set.seed(
  seed = NULL,
  diff = TRUE,
  state = NULL,
  streams = NULL,
  comm = .pbd_env$SPMD.CT$comm
)
comm.set.stream(
  name = NULL,
  reset = FALSE,
  state = NULL,
  comm = .pbd_env$SPMD.CT$comm
)
comm.get.streams(
  comm = .pbd_env$SPMD.CT$comm, 
  seed = FALSE
)
}
\arguments{
  \item{seed}{In \code{comm.set.seed}, a single value interpreted as an 
  integer. In \code{comm.get.streams}, a logical if TRUE, return includes the
  current local \code{.Random.seed}.
}

  \item{diff}{Logical indicating if the parallel instances should have different
  random streams.}

  \item{state}{In function \code{comm.set.seed}: This parameter is deprecated. 
  In function \code{comm.set.stream}: If non-NULLit restarts a stream from a
  previously saved \code{state <- comm.set.stream()}. A stream state is a list 
  with one named element, which is the 6-element L'Ecuyer-CMRG 
  \code{.Random.seed}, probably captured earlier with 
  \code{state <- comm.set.stream()}). The stream name, if 
  different from a provided parameter \code{name}, has precedence, but a 
  warning is produced. Further, the requesting rank must own the stream.}

  \item{streams}{An vector of sequential integers specifying the streams to be
  prepared on the current rank. Typically, this is used by `comm.chunk()` to 
  prepare correct streams for each rank, which are aligned with the vector 
  being chunk-ed.}
  
  \item{name}{Stream number that is coercible to character, indicating to 
  start or continue generating from that stream.}

  \item{reset}{If true, reset the requested stream back to its beginning.}

  \item{comm}{The communicator that determines MPI rank numbers.}
}
\details{
This implementation uses the function \code{\link{nextRNGStream}}
in package \code{parallel} to set up streams appropriate for working on a
cluster system with MPI. The main difference from \code{parallel} is
that it adds a reproducibility capability with vector-based
streams that works across different numbers of nodes or cores by associating
streams with an application vector.

Vector-based streams are best set up with the higher level function 
\code{\link{comm.chunk}} instead of using \code{comm.set.stream} directly.
\code{\link{comm.chunk}} will set up only the streams that each rank needs 
and provides the stream numbers necessary to switch between them with 
\code{comm.set.stream}.

The function uses \code{parallel}'s
\code{nextRNGStream()} and sets up the parallel stream seeds in the
\code{.pbd_env$RNG} environment, which are then managed with
\code{\link{comm.set.stream}}. There is only one communication broadcast in
this implementation that ensures all ranks have the same seed as rank 0. 
Subsequently, each rank maintains only its own streams.

When rank-based streams are set up, \code{\link{comm.chunk}} with 
\code{form = "number"} and \code{rng = TRUE} parameters, streams are 
different for each rank and switching is not needed. Vector-based streams
are obtained with \code{form = "vector"} and \code{rng = TRUE} parameters.
In this latter case, the vector returned to each
rank contains the stream numbers (and vector components) that the rank owns.
Switch with \code{comm.set.stream(v)}, where v is one of the stream numbers.
Switching back and forth is allowed, with each stream continuing where it
left off.

## RNG Notes
R sessions connected by MPI begin like other R sessions as discussed in
\code{\link{Random}}. On first use of random number generation, 
each rank computes its own seed from a combination of clock time and process
id (unless it reads a previously saved workspace, which is not recommended). 
Because of asynchronous execution, imperfectly synchronized node clocks,
and likely different process ids, this
almost guarantees unique seeds and most likely results in independent 
streams. However, this is not reproducible and not guaranteed. Both 
reproducibility and guarantee are brought by the use of the L'Ecuyer-CMRG 
generator implementation in \code{\link{nextRNGStream}} and the
use of \code{comm.set.seed} and \code{\link{comm.set.stream}} adaptation for
parallel computing on cluster systems.

At a high level, the L'Ecuyer-CMRG pseudo-random number generator can 
take jumps (advance the seed) in its 
stream (about 2^191 long) so that distant substreams can be assigned. The 
\code{\link{nextRNGStream}} implementation takes jumps of 2^127 
(about 1.7e38) to provide up to 2^64 (about 1.8e19) independent streams. See
\url{https://stat.ethz.ch/R-manual/R-devel/library/parallel/doc/parallel.pdf}
for more details.

In situations that require the same stream on all ranks, a simple 
\code{\link{set.seed}} from base R and the default RNG will suffice. 
\code{comm.set.seed} will also accomplish this with the \code{diff = FALSE}
parameter if switching between same and different streams is needed.
}
\value{
\code{comm.set.seed} engages the L'Ecuyer-CMRG RNG and invisibly returns
the previous RNG in use (Output of RNGkind()[1]). Capturing it, enables 
the restoration of the previous RNG with \code{\link{RNGkind}}. See examples
of use in \code{demo/seed_rank.r} and \code{demo/seed_vec.r}.

\code{comm.set.stream} invisibly returns the current stream number as character.

\code{comm.get.streams} returns the current stream name and other stream names available to the rank as a character string. Optionally, the local 
\code{.Random.seed} is included. This function is a debugging aid for 
distributed random streams.

All three functions manage and use the environment \code{.pbd_env$RNG}.
}
\references{
  Pierre L'Ecuyer, Simard, R., Chen, E.J., and Kelton, W.D. (2002)
  An Object-Oriented Random-Number Package with Many Long Streams and
  Substreams. Operations Research, 50(6), 1073-1075.

  \url{https://www.iro.umontreal.ca/~lecuyer/myftp/papers/streams00.pdf}

  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{comm.chunk()}
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
suppressMessages(library(pbdMPI, quietly = TRUE))     

comm.print(RNGkind())
comm.print(runif(5), all.rank = TRUE)

set.seed(1357)
comm.print(runif(5), all.rank = TRUE)

old.kind = comm.set.seed(1357)
comm.print(RNGkind())
comm.print(runif(5), all.rank = TRUE)

comm.set.stream(reset = TRUE)
comm.print(runif(5), all.rank = TRUE)

comm.set.seed(1357, diff = TRUE)
comm.print(runif(5), all.rank = TRUE)

state <- comm.set.stream()   ### save each rank's stream state
comm.print(runif(5), all.rank = TRUE)

comm.set.stream(state = state) ### set current RNG to state
comm.print(runif(5), all.rank = TRUE)

RNGkind(old.kind)
set.seed(1357)
comm.print(RNGkind())
comm.print(runif(5), all.rank = TRUE)

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
