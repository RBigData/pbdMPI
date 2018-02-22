\name{apply and lapply}
\alias{pbdApply}
\alias{pbdLapply}
\alias{pbdSapply}
\title{ Parallel Apply and Lapply Functions }
\description{
  The functions are parallel versions of apply and lapply functions.
}
\usage{
pbdApply(X, MARGIN, FUN, ..., pbd.mode = c("mw", "spmd", "dist"),
         rank.source = .pbd_env$SPMD.CT$rank.root,
         comm = .pbd_env$SPMD.CT$comm,
         barrier = TRUE)
pbdLapply(X, FUN, ..., pbd.mode = c("mw", "spmd", "dist"),
          rank.source = .pbd_env$SPMD.CT$rank.root,
          comm = .pbd_env$SPMD.CT$comm,
          bcast = FALSE, barrier = TRUE)
pbdSapply(X, FUN, ..., simplify = TRUE, USE.NAMES = TRUE,
          pbd.mode = c("mw", "spmd", "dist"),
          rank.source = .pbd_env$SPMD.CT$rank.root,
          comm = .pbd_env$SPMD.CT$comm,
          bcast = FALSE, barrier = TRUE)
}
\arguments{
  \item{X}{a matrix or array in \code{pbdApply()} or a list in
           \code{pbdLapply()} and \code{pbdSapply()}.}
  \item{MARGIN}{\code{MARGIN} as in the \code{apply()}.}
  \item{FUN}{as in the \code{apply()}.}
  \item{...}{optional arguments to \code{FUN}.}
  \item{simplify}{as in the \code{sapply()}.}
  \item{USE.NAMES}{as in the \code{sapply()}.}
  \item{pbd.mode}{mode of distributed data \code{X}.}
  \item{rank.source}{a rank of source where \code{X} broadcast from.}
  \item{comm}{a communicator number.}
  \item{bcast}{if bcast to all ranks.}
  \item{barrier}{if barrier for all ranks.}
}
\details{
  All functions are majorly called in manager/workers mode
  (\code{pbd.model = "mw"}), and just work the same as their
  serial version.

  If \code{pbd.mode = "mw"}, the \code{X} in \code{rank.source} (master)
  will be redistributed to processors (workers), then apply \code{FUN}
  on the new data, and results are gathered to \code{rank.source}.
  ``In SPMD, master is one of workers.''
  \code{...} is also \code{scatter()} from \code{rank.source}.

  If \code{pbd.mode = "spmd"}, the same copy of \code{X} is supposed to
  exist in all processors, and original \code{apply()}, \code{lapply()},
  or \code{sapply()} is operated on part of
  \code{X}. An \code{allgather()} or \code{gather()} call is required to
  aggregate results manually.

  If \code{pbd.mode = "dist"}, the different \code{X} is supposed to
  exists in all processors, i.e. `distinct or distributed' \code{X},
  and original \code{apply()}, \code{lapply()}, or \code{sapply()} is operated
  on the all \code{X}. An \code{allgather()} or \code{gather()} call is
  required to aggregate results manually.

  In SPMD, it is better to split data into pieces, and \code{X} is a local
  matrix in all processors. Originally, \code{apply()} should be sufficient
  in this case. 
}
\value{
  A list or matrix will be returned.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Example for pbdApply.
N <- 100
x <- matrix((1:N) + N * .comm.rank, ncol = 10)
y <- pbdApply(x, 1, sum, pbd.mode = \"mw\")
comm.print(y)

y <- pbdApply(x, 1, sum, pbd.mode = \"spmd\")
comm.print(y)

y <- pbdApply(x, 1, sum, pbd.mode = \"dist\")
comm.print(y)


### Example for pbdApply for 3D array.
N <- 60
x <- array((1:N) + N * .comm.rank, c(3, 4, 5))
dimnames(x) <- list(lat = paste(\"lat\", 1:3, sep = \"\"),
                    lon = paste(\"lon\", 1:4, sep = \"\"),
                    time = paste(\"time\", 1:5, sep = \"\"))
comm.print(x[,, 1:2])

y <- pbdApply(x, c(1, 2), sum, pbd.mode = \"mw\")
comm.print(y)

y <- pbdApply(x, c(1, 2), sum, pbd.mode = \"spmd\")
comm.print(y)

y <- pbdApply(x, c(1, 2), sum, pbd.mode = \"dist\")
comm.print(y)


### Example for pbdLapply.
N <- 100
x <- split((1:N) + N * .comm.rank, rep(1:10, each = 10))
y <- pbdLapply(x, sum, pbd.mode = \"mw\")
comm.print(unlist(y))

y <- pbdLapply(x, sum, pbd.mode = \"spmd\")
comm.print(unlist(y))

y <- pbdLapply(x, sum, pbd.mode = \"dist\")
comm.print(unlist(y))

### Finish.
finalize()
"
# execmpi(spmd.code, nranks = 2L)
}
}
\keyword{utility}
