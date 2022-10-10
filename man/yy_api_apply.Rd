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

  If \code{pbd.mode = "mw"}, the \code{X} in \code{rank.source} (manager)
  will be distributed to the workers, then \code{FUN} will be applied to
  the new data, and results gathered to \code{rank.source}.
  ``In SPMD, the manager is one of workers.''
  \code{...} is also \code{scatter()} from \code{rank.source}.

  If \code{pbd.mode = "spmd"}, the same copy of \code{X} is expected
  on all ranks, and the original \code{apply()}, \code{lapply()},
  or \code{sapply()} will operate on part of
  \code{X}. An explicit \code{allgather()} or \code{gather()} will be needed to
  aggregate the results.

  If \code{pbd.mode = "dist"}, different \code{X} are expected on
  all ranks, i.e. `distinct or distributed' \code{X},
  and original \code{apply()}, \code{lapply()}, or \code{sapply()} will operate
  on the distinct \code{X}. An explicit \code{allgather()} or \code{gather()} 
  will be needed to aggregate the results.

  In SPMD, it is better to split data into pieces, so that \code{X} is a local
  piece of a global matrix. If the "apply" dimension is local, the base 
  \code{apply()} function can be used. 
}
\value{
  A list or a matrix will be returned.
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
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
pbdMPI::execmpi(spmd.code, nranks = 2L)
%}
}
\keyword{utility}
