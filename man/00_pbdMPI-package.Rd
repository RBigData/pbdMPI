\name{pbdMPI-package}
\alias{pbdMPI-package}
\alias{pbdMPI}
\docType{package}
\title{Programming with Big Data -- Interface to MPI}
\description{
  pbdMPI provides an efficient interface to MPI by utilizing S4
  classes and methods with a focus on Single Program/Multiple Data (SPMD)
  parallel programming style, which is intended for batch parallel
  execution.
}
\details{
\tabular{ll}{
  Package: \tab pbdMPI\cr
  Type: \tab Package\cr
%  Version: \tab 0.1-2\cr
%  Date: \tab 2010-02-18\cr
  License: \tab Mozilla Public License 2.0\cr
  LazyLoad: \tab yes\cr
}

  This package requires an MPI library (OpenMPI, MPICH2, or LAM/MPI).
  The install command (with OpenMPI library) is \cr
  \cr
  \code{> tar zxvf pbdMPI_0.1-0.tar.gz } \cr
  \code{> R CMD INSTALL pbdMPI } \cr
  \cr
  Other arguments include
\tabular{ll}{
  Argument \tab Default \cr
  \code{--with-mpi-type}    \tab \code{OPENMPI} \cr
  \code{--with-mpi-include} \tab \code{${MPI_ROOT}/include} \cr
  \code{--with-mpi-libpath} \tab \code{${MPI_ROOT}/lib} \cr
  \code{--with-mpi}         \tab \code{${MPI_ROOT}} \cr
}
  where \code{${MPI_ROOT}} is the path to the MPI root.
  See the package source file \code{pbdMPI/configure} for details.

  After loading \code{library(pbdMPI)}, the standard process starts from
  \code{\link{init}} which set two global variables \code{.comm.size}
  and \code{.comm.rank}. The standard process should end
  with \code{\link{finalize}}.

  Most functions are assumed to run in SPMD, i.e.
  in batch mode. Ideally, most codes run with \code{mpiexec} and \code{Rscript},
  together, such as \cr \cr
  \code{> mpiexec -np 2 Rscript some_code.r} \cr \cr
  where \code{some_code.r} contains whole SPMD program.  

  The package source files provide several examples based on \pkg{pbdMPI},
  such as
\tabular{ll}{
  Directory \tab Examples \cr
  \code{pbdMPI/inst/examples/test_spmd/}        \tab major SPMD functions \cr
  \code{pbdMPI/inst/examples/test_rmpi/}        \tab analog to \pkg{Rmpi} \cr
  \code{pbdMPI/inst/examples/test_parallel/}    \tab analog to \pkg{parallel} \cr
  \code{pbdMPI/inst/examples/test_performance/} \tab performance tests \cr
  \code{pbdMPI/inst/examples/test_s4/}          \tab S4 extension \cr
  \code{pbdMPI/inst/examples/test_cs/}          \tab client/server examples \cr
  \code{pbdMPI/inst/examples/test_long_vector/} \tab long vector examples \cr
}
  where \code{test_long_vector} needs to recompile with setting

  \code{#define MPI_LONG_DEBUG 1}

  in \code{pbdMPI/src/pkg_constant.h}.

  The current version is mainly written and tested under OpenMPI
  environments in Linux system (xubuntu-11.04). Also, it is tested
  under MPICH2 environments in Windows 7 system.
  It is expected to be fine for other MPI libraries and other OS platforms.
}
\references{
  Programming with Big Data in R Website:
  \url{http://r-pbd.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{allgather}},
  \code{\link{allreduce}},
  \code{\link{bcast}},
  \code{\link{gather}},
  \code{\link{reduce}},
  \code{\link{scatter}}.
}
\examples{
\dontrun{
### Under command mode, run the demo with 2 processors by
### (Use Rscript.exe for windows system)
mpiexec -np 2 Rscript -e "demo(allgather,'pbdMPI',ask=F,echo=F)"
mpiexec -np 2 Rscript -e "demo(allreduce,'pbdMPI',ask=F,echo=F)"
mpiexec -np 2 Rscript -e "demo(bcast,'pbdMPI',ask=F,echo=F)"
mpiexec -np 2 Rscript -e "demo(gather,'pbdMPI',ask=F,echo=F)"
mpiexec -np 2 Rscript -e "demo(reduce,'pbdMPI',ask=F,echo=F)"
mpiexec -np 2 Rscript -e "demo(scatter,'pbdMPI',ask=F,echo=F)"
}
}
\keyword{package}

