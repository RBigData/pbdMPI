\name{communicator}
\alias{barrier}
\alias{comm.is.null}
\alias{comm.rank}
\alias{comm.size}
\alias{comm.dup}
\alias{comm.free}
\alias{init}
\alias{finalize}
\alias{comm.abort}
\alias{comm.disconnect}
\alias{comm.connect}
\alias{comm.accept}
\alias{port.open}
\alias{port.close}
\alias{serv.publish}
\alias{serv.unpublish}
\alias{serv.lookup}
\alias{COMM.SIZE}
\alias{COMM.RANK}
\alias{comm.c2f}
\title{ Communicator Functions }
\description{
  The functions provide controls to communicators.
}
\usage{
  barrier(comm = .SPMD.CT$comm)
  comm.is.null(comm = .SPMD.CT$comm)
  comm.rank(comm = .SPMD.CT$comm)
  comm.size(comm = .SPMD.CT$comm)
  comm.dup(comm, newcomm)
  comm.free(comm = .SPMD.CT$comm)
  init(set.seed = TRUE)
  finalize(mpi.finalize = .SPMD.CT$mpi.finalize)
  comm.abort(errorcode = 1, comm = .SPMD.CT$comm)
  comm.disconnect(comm = .SPMD.CT$comm)
  comm.connect(port.name, info = .SPMD.CT$info,
               rank.root = .SPMD.CT$rank.root, comm = .SPMD.CT$comm,
               newcomm = .SPMD.CT$newcomm)
  comm.accept(port.name, info = .SPMD.CT$info,
              rank.root = .SPMD.CT$rank.root, comm = .SPMD.CT$comm,
              newcomm = .SPMD.CT$newcomm)
  port.open(info = .SPMD.CT$info)
  port.close(port.name)
  serv.publish(port.name, serv.name = .SPMD.CT$serv.name,
               info = .SPMD.CT$info)
  serv.unpublish(port.name, serv.name = .SPMD.CT$serv.name,
                 info = .SPMD.CT$info)
  serv.lookup(serv.name = .SPMD.CT$serv.name, info = .SPMD.CT$info)
  comm.c2f(comm = .SPMD.CT$comm)
}
\arguments{
  \item{comm}{a communicator number.}
  \item{mpi.finalize}{if MPI should be shutdown.}
  \item{set.seed}{if a random seed preset.}
  \item{port.name}{a port name with default maximum length
                   1024 characters for OpenMPI.}
  \item{info}{a info number.}
  \item{rank.root}{a root rank.}
  \item{newcomm}{a new communicator number.}
  \item{serv.name}{a service name.}
  \item{errorcode}{an error code to abort MPI.}
}
\details{
  Another functions are direct calls to MPI library.

  \code{barrier} blocks all processors until everyone call this.

  \code{comm.is.null} returns \code{-1} if the array of communicators is not
  allocated, i.e. \code{init} is not called yet. It returns \code{1}
  if the communicator is not initialized, i.e. \code{NULL}. It
  returns \code{0} if the communicator is initialized.

  \code{comm.rank} returns the processor's rank for the given \code{comm}.

  \code{comm.size} returns the total processes for the given \code{comm}.

  \code{comm.dup} duplicate a \code{newcomm} from \code{comm}.

  \code{comm.free} free a \code{comm}.

  \code{init} initializes a MPI world, and set two global variables
  \code{.comm.size} and \code{.comm.rank} in \code{.GlobalEnv}. A random seed
  will be preset by default (\code{Sys.getpid() + Sys.time()}) to the package
  \pkg{rlecuyer}.

  \code{finalize} frees memory and finishes a MPI world if
  \code{mpi.finalize = TRUE}.

  \code{comm.abort} aborts MPI.

  \code{comm.disconnect} frees a \code{comm}.

  \code{comm.connect} connects a \code{newcomm}.

  \code{comm.accept} accepts a \code{newcomm}.

  \code{port.open} opens a port and returns the port name.

  \code{port.close} closes a port by name.

  \code{serv.publish} publishs a service via \code{port.name}.

  \code{serv.unpublish} unpublishs a service via \code{port.name}.

  \code{serv.lookup} lookup the \code{serv.name} and returns the port name.

  \code{comm.c2f} returns an integer for Fortran MPI support.
}
\value{
  Most function return an invisible state of MPI call.
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
# Save code in a file "demo.r" and run with 2 processors by
# > mpiexec -np 2 Rscript demo.r

### Initial
library(pbdMPI, quiet = TRUE)
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples 
comm.print(.comm.size)
comm.print(.comm.rank, all.rank = TRUE)
comm.print(comm.rank(), rank.print = 1)
comm.print(comm.c2f())

### Finish
finalize()
}
}
\keyword{programming}

