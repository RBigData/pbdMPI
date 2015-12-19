\name{SPMD Control}
\alias{.pbd_env}
\docType{data}
\title{Sets of controls in pbdMPI.}
\description{
  These sets of controls are used to provide default values in this package.
}
\format{
  Objects contain several parameters for communicators and methods.
}
\details{
  The elements of \code{.pbd_env$SPMD.CT} are default values for controls
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

  The elements of \code{.pbd_env$SPMD.OP} list the implemented operations for
  \code{reduce()} and \code{allreduce()}. Currently, four operations are
  implemented "sum", "prod", "max", and "min".

  The elements of \code{.SPMD.IO} are default values for input and output
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

  The elements of \code{.pbd_env$SPMD.TP} are default values mainly for
  task pull including
\tabular{lcl}{
  Elements          \tab Default \tab Usage \cr
  \code{bcast}      \tab FALSE   \tab if \code{bcase()} objects to all ranks \cr
  \code{barrier}    \tab TRUE    \tab if call \code{barrier()} for all ranks \cr
  \code{try}        \tab TRUE    \tab if use \code{try()} in works \cr
  \code{try.silent} \tab FALSE   \tab if silent the \code{try()} message \cr
  See \code{\link{task.pull}()} for details.
}
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
