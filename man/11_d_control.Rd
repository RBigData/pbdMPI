\name{SPMD Control}
\alias{.pbd_env}
\docType{data}
\title{Default control in pbdMPI.}
\description{
  These variables provide default values for most functions in the package.
}
\format{
  The environment \code{.pbd_env} contains several objects with parameters for
  communicators and methods.
}
\details{
  The elements of \code{.pbd_env$SPMD.CT} are default values for various 
  controls
\tabular{lcl}{
  Elements              \tab Default    \tab Meaning \cr
  \code{comm}           \tab 0L         \tab communicator index \cr
  \code{intercomm}      \tab 2L         \tab inter communicator index \cr
  \code{info}           \tab 0L         \tab info index \cr
  \code{newcomm}        \tab 1L         \tab new communicator index \cr
  \code{op}             \tab "sum"      \tab the operation \cr
  \code{port.name}      \tab "spmdport" \tab the operation \cr
  \code{print.all.rank} \tab FALSE      \tab whether all ranks print message \cr
  \code{print.quiet}    \tab FALSE      \tab whether rank is added to print/cat \cr
  \code{rank.root}      \tab 0L         \tab the rank of root \cr
  \code{rank.source}    \tab 0L         \tab the rank of source \cr
  \code{rank.dest}      \tab 1L         \tab the rank of destination \cr
  \code{request}        \tab 0L         \tab the request index \cr
  \code{serv.name}      \tab "spmdserv" \tab the service name \cr
  \code{status}         \tab 0L         \tab the status index \cr
  \code{tag}            \tab 0L         \tab the tag number \cr
  \code{unlist}         \tab FALSE      \tab whether to unlist a return \cr
  \code{divide.method}  \tab "block"    \tab default method for jid \cr
  \code{mpi.finalize}   \tab TRUE       \tab shutdown MPI on \code{finalize()} \cr
  \code{quit}           \tab TRUE       \tab quit when errors occur \cr
  \code{msg.flush}      \tab TRUE       \tab flush each comm.cat/comm.print\cr
  \code{msg.barrier}    \tab TRUE       \tab include barrier in comm.cat/comm.print \cr
  \code{Rprof.all.rank} \tab FALSE      \tab call Rprof on all ranks \cr
  \code{lazy.check}     \tab TRUE      \tab use lazy check on all ranks \cr
}

  The elements of \code{.pbd_env$SPMD.OP} list the implemented operations for
  \code{reduce()} and \code{allreduce()}. Currently, implemented operations are
  "sum", "prod", "max", "min", "land", "band", "lor", "bor", "lxor", "bxor".

  The elements of \code{.SPMD.IO} are default values for functions in
  \code{comm_read.r} and \code{comm_balance.r}.
\tabular{lcl}{
  Elements              \tab Default    \tab Meaning \cr
  \code{max.read.size}  \tab 5.2e6      \tab max of reading size (5 MB) \cr
  \code{max.test.lines} \tab 500        \tab max of testing lines \cr
  \code{read.method}    \tab "gbd"      \tab default reading method \cr
  \code{balance.method} \tab "block"    \tab default load balance method \cr
}
  where \code{balance.method} is only used for "gbd" reading method when
  \code{nrows = -1} and \code{skip = 0} are set.

  The elements of \code{.pbd_env$SPMD.TP} are default values for
  task pull settings
\tabular{lcl}{
  Elements          \tab Default \tab Meaning \cr
  \code{bcast}      \tab FALSE   \tab whether to \code{bcast()} objects to all ranks \cr
  \code{barrier}    \tab TRUE    \tab if call \code{barrier()} for all ranks \cr
  \code{try}        \tab TRUE    \tab if use \code{try()} in works \cr
  \code{try.silent} \tab FALSE   \tab if silent the \code{try()} message \cr
  See \code{\link{task.pull}()} for details.
}
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\keyword{global variables}
