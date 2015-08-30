\name{SPMD Control Functions}
\alias{SPMD.CT}
\alias{SPMD.OP}
\alias{SPMD.IO}
\alias{SPMD.TP}

\title{Sets of controls in pbdMPI.}
\description{
  These sets of controls are used to provide default values in this package.
}
\usage{
SPMD.CT(
  comm = 0L,
  intercomm = 2L,
  newcomm = 1L,
  comm.within = 3L,
  comm.between = 4L,
  op = "sum",
  port.name = "spmdport",
  serv.name = "spmdserv",
  print.all.rank = FALSE,
  print.quiet = FALSE,
  rank.root = 0L,
  rank.source = 0L,
  rank.dest = 1L,
  request = 0L,
  info = 0L,
  status = 0L,
  tag = 0L,
  unlist = FALSE,
  divide.method = c("block",
                    "block0",
                    "cycle"),
  mpi.finalize = TRUE,
  quit = TRUE,
  msg.flush = TRUE,
  msg.barrier = TRUE,
  Rprof.all.rank = FALSE,
  lazy.check = FALSE)

SPMD.OP(
  OP = c("sum", "prod", "max", "min", "land", "band",
         "lor", "bor", "lxor", "bxor"))

SPMD.IO(
  max.read.size = 5.2e6,
  max.test.lines = 500,
  read.method = c("gbd", "common"),
  balance.method = c("block", "block0", "block.cyclic"))

SPMD.TP(
  bcast = FALSE,
  barrier = TRUE,
  try = TRUE,
  try.silent = FALSE)
}
\arguments{
  \item{comm}{see details}
  \item{intercomm}{see details}
  \item{newcomm}{see details}
  \item{comm.within}{see details}
  \item{comm.between}{see details}
  \item{op}{see details}
  \item{port.name}{see details}
  \item{serv.name}{see details}
  \item{print.all.rank}{see details}
  \item{print.quiet}{see details}
  \item{rank.root}{see details}
  \item{rank.source}{see details}
  \item{rank.dest}{see details}
  \item{request}{see details}
  \item{info}{see details}
  \item{status}{see details}
  \item{tag}{see details}
  \item{unlist}{see details}
  \item{divide.method}{see details}
  \item{mpi.finalize}{see details}
  \item{quit}{see details}
  \item{msg.flush}{see details}
  \item{msg.barrier}{see details}
  \item{Rprof.all.rank}{see details}
  \item{lazy.check}{see details}

  \item{OP}{see details}

  \item{max.read.size}{see details}
  \item{max.test.lines}{see details}
  \item{read.method}{see details}
  \item{balance.method}{see details}

  \item{bcast}{see details}
  \item{barrier}{see details}
  \item{try}{see details}
  \item{try.silent}{see details}
}
\details{
  The elements of \code{SPMD.CT()} are default values for controls
  including
\tabular{lcl}{
  Elements              \tab Default    \tab Usage \cr
  \code{comm}           \tab 0L         \tab a communicator index \cr
  \code{intercomm}      \tab 2L         \tab an inter communicator index \cr
  \code{info}           \tab 0L         \tab an info index \cr
  \code{newcomm}        \tab 1L         \tab a new communicator index \cr
  \code{op}             \tab "sum"      \tab an operation \cr
  \code{port.name}      \tab "spmdport" \tab an operation \cr
  \code{print.all.rank} \tab FALSE      \tab if all ranks print message \cr
  \code{print.quiet}    \tab FALSE      \tab if print/cat rank information \cr
  \code{rank.root}      \tab 0L         \tab a rank of root \cr
  \code{rank.source}    \tab 0L         \tab a rank of source \cr
  \code{rank.dest}      \tab 1L         \tab a rank of destination \cr
  \code{request}        \tab 0L         \tab a request index \cr
  \code{serv.name}      \tab "spmdserv" \tab a service name \cr
  \code{status}         \tab 0L         \tab a status index \cr
  \code{tag}            \tab 0L         \tab a tag number \cr
  \code{unlist}         \tab FALSE      \tab if unlist returning \cr
  \code{divide.method}  \tab "block"    \tab a way to divide jobs or data \cr
  \code{mpi.finalize}   \tab TRUE       \tab if shutdown MPI \cr
  \code{quit}           \tab TRUE       \tab if quit when errors occur \cr
  \code{msg.flush}      \tab TRUE       \tab if flush message for comm.cat/comm.print \cr
  \code{msg.barrier}    \tab TRUE       \tab if barrier message for comm.cat/comm.print \cr
  \code{Rprof.all.rank} \tab FALSE      \tab if call Rprof on all ranks \cr
  \code{lazy.check}     \tab TRUEE      \tab if use lazy check on all ranks \cr
}

  The elements of \code{SPMD.OP()} list the implemented operations for
  \code{reduce()} and \code{allreduce()}. Currently, four operations are
  implemented "sum", "prod", "max", and "min".

  The elements of \code{SPMD.IO()} are default values for input and output
  including
\tabular{lcl}{
  Elements              \tab Default    \tab Usage \cr
  \code{max.read.size}  \tab 5.2e6      \tab max of reading size (5 MB) \cr
  \code{max.test.lines} \tab 500        \tab max of testing lines \cr
  \code{read.method}    \tab "gbd"      \tab default reading method \cr
  \code{balance.method} \tab "block"    \tab default load balance method \cr
}
  where \code{balance.method} is only used for "gbd" reading method when
  \code{nrows = -1} and \code{skip = 0} are set.

  The elements of \code{SPMD.TP()} are default values mainly for task pull
  including
\tabular{lcl}{
  Elements          \tab Default \tab Usage \cr
  \code{bcast}      \tab FALSE   \tab if \code{bcase()} objects to all ranks \cr
  \code{barrier}    \tab TRUE    \tab if call \code{barrier()} for all ranks \cr
  \code{try}        \tab TRUE    \tab if use \code{try()} in works \cr
  \code{try.silent} \tab FALSE   \tab if silent the \code{try()} message \cr
  See \code{\link{task.pull}()} for details.
}
}
\value{
  A list with controlling parameters and values is returns.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\keyword{global variables}
