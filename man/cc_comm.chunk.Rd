\name{comm.chunk}
\alias{comm.chunk}
\title{comm.chunk}
\usage{
comm.chunk(
  N,
  form = "number",
  type = "balance",
  lo.side = "right",
  all.rank = FALSE,
  p = NULL,
  rank = NULL,
  comm = .pbd_env$SPMD.CT$comm
)
}
\arguments{
\item{N}{The number of items to split into chunks.}

\item{form}{Output a chunk as a single "number", as a "vector" of items from 1:N,
or as an "iopair" giving offset and length in a file. Forms "ldim" and
"bldim" are available only with type "equal" and are intended for setting
"ddmatrix" (see package pbdDMAT) slots.}

\item{type}{Either "balance" the chunks so they differ by no more than 1 item (used most
frequently for best balance) or force as many as possible to be "equal" with
possibly one or more smaller or even zero size chunks (required by ScaLAPACK's
block-cyclic layouts).}

\item{lo.side}{If exact balance is not possible, put the smaller chunks on the "left" (low
ranks) or on the "right" (high ranks).}

\item{all.rank}{FALSE returns only the chunk for rank r. TRUE returns a vector of
length p (when form="number"), and a list of length p (when form="vector")
each containing the output for the corresponding rank.}

\item{p}{The number of chunks (processors). Normally, it is NOT specified and defaults
to NULL, which assigns comm.size(comm).}

\item{rank}{The rank of returned chunk. Normally, it is NOT specified and defaults to
NULL, which assigns comm.rank(comm)). Note that ranks are numbered from 0 to
p-1, whereas the list elements for all.rank=TRUE are numbered 1 to p.}

\item{comm}{The communicator across which the split will be taken.}
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

If the communicator was divided with comm.split(), the chunking is done 
within all sub-communicators respective to their size. This is useful for 
setting up collective operations that take place on disjoint subsets of 
ranks.
}
\examples{
\dontrun{
## Note that the p and rank parameters are provided by comm.size() and
## comm.rank(), respectively, when running SPMD in parallel. Normally, they
## are not specified unless testing in serial mode.
library(pbdIO)

comm.chunk(16, all.rank = TRUE, p = 5)
comm.chunk(16, type = "equal", all.rank = TRUE, p = 5)
comm.chunk(16, type = "equal", lo.side = "left", all.rank = TRUE, p = 5)
comm.chunk(16, p = 5, rank = 0)
comm.chunk(16, p = 5, lo.side = "left", rank = 0)
}

}
