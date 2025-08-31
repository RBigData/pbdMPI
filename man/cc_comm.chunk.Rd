\name{comm.chunk}
\alias{comm.chunk}
\title{comm.chunk}
\usage{
comm.chunk(
  N,
  form = "number",
  type = "balance",
  lo.side = "right",
  rng = FALSE,
  all.rank = FALSE,
  p = NULL,
  rank = NULL,
  comm = .pbd_env$SPMD.CT$comm,
  ...
)
}
\arguments{
  \item{N}{The number of items to split into chunks.}

  \item{form}{Output a chunk as a single "number", as a "vector" of items from 1:N,
  or as a "seq" three parameters `c(from, to, by)` of the base `seq()` function
  (replaced deprecated "iopair" for offset and length in a file). Forms "ldim"
  and "bldim" are available only with type "equal" and are intended for setting
  "ddmatrix" (see package pbdDMAT) slots.}

  \item{type}{Is the primary load and location balance specification. The choices are:
  "balance" the chunks so they differ by no more than 1 item (used most
  frequently and default); "cycle" is the same as "balance" in terms of
  load but differs on location in that chunks are not contiguous, rather are
  assigned in a cycled way to ranks (note that "balance" and "cycle" are the
  same if `form` is "number");  "equal" maximizes the number of same size
  chunks resulting in one or more smaller or even zero size chunks carrying
  the leftover (required by pbdDMAT block-cyclic layouts).}

  \item{lo.side}{If exact balance is not possible, put the smaller chunks on the 
  "left"  (low ranks) or on the "right" (high ranks).}

  \item{rng}{If TRUE, set up different L'Ecuyere random number generator streams. 
    \itemize{
      \item If \code{form = "vector"}, N random streams are set up, one for each 
      item in the vector and only those needed by the local chunk are kept 
      locally by each rank. Switch to stream \code{i} with 
      \code{\link{comm.set.stream}(i)}, where \code{i} is a global index.
      \item If \code{form = "number"}, each rank will use a different stream, set
      by default (so \code{\link{comm.set.stream}} does not need to be used).
      \item Additional ... parameter \code{seed}, passed to
      \code{\link{comm.set.seed}}, can be set for reproducibility.
    }
  }

  \item{all.rank}{FALSE returns only the chunk for rank r. TRUE returns a vector of
  length p (when form="number"), and a list of length p (when form="vector")
  each containing the output for the corresponding rank.}

  \item{p}{The number of processors (chunks), normally left as the default NULL, which
  assigns comm.size(comm), the number of MPI ranks. Normally, this is NOT
  specified unless testing in serial mode.}

  \item{rank}{The rank of the returned chunk, normally left as NULL, which
  assigns comm.rank(comm)), the assigned MPI rank. Note that ranks are numbered
  from 0 to p-1, whereas the list elements for all.rank=TRUE are numbered 1 to p.}

  \item{comm}{The communicator that determines MPI rank numbers.}
  
  \item{...}{If \code{rng = TRUE}, then a \code{seed} parameter should be
  provided for \link{comm.set.seed}.}
}
\value{
A numeric value from 0:N or a vector giving a subset of 1:N (depending on
form) for the rank. If all.rank is TRUE, a vector or a list of
vectors, respectively.
}
\description{
Given a total number of items, N, comm.chunk splits the number into
chunks. Tailored especially for situations in SPMD style
programming, potentially returning different results to each rank.
Optionally, results for all ranks can be returned to all.
}
\details{
Various chunking options are possible when the number does not
split evenly into equal chunks. The output form can be a number,
a vector of items, or a few other special forms intended for pbdR components.
}
\examples{
\dontrun{
## Note that the p and rank parameters are provided by comm.size() and
## comm.rank(), respectively, when running SPMD in parallel. Normally, they
## are not specified unless testing in serial mode (as in this example).
library(pbdIO)

comm.chunk(16, all.rank = TRUE, p = 5)
comm.chunk(16, type = "equal", all.rank = TRUE, p = 5)
comm.chunk(16, type = "equal", lo.side = "left", all.rank = TRUE, p = 5)
comm.chunk(16, p = 5, rank = 0)
comm.chunk(16, p = 5, lo.side = "left", rank = 0)
}

}
