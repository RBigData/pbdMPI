\name{pbdMPI-package}
\alias{pbdMPI-package}
\alias{pbdMPI}
\docType{package}
\title{R Interface to MPI (Programming with Big Data in R Project)}
\description{
  A simplified, efficient, interface to MPI for HPC clusters. It is
  a derivation and rethinking of the Rmpi package that embraces the
  prevalent parallel programming style on HPC clusters. It is based on S4
  classes and methods.
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

  This package requires an MPI library (OpenMPI, MPICH2, or LAM/MPI). Standard
  installation in an R session with
  \cr
  \code{> install.packages("pbdMPI")} \cr
  should work in most cases. To install on the Unix command line after
  downloading the source file, use \cr
  \code{> tar zxvf pbdMPI_0.1-0.tar.gz } \cr
  \code{> R CMD INSTALL pbdMPI } \cr
  \cr
  If the MPI library is not found, the following arguments can be used to
  specify its non-standard location on your system
\tabular{ll}{
  Argument \tab Default \cr
  \code{--with-mpi-type}    \tab \code{OPENMPI} \cr
  \code{--with-mpi-include} \tab \code{${MPI_ROOT}/include} \cr
  \code{--with-mpi-libpath} \tab \code{${MPI_ROOT}/lib} \cr
  \code{--with-mpi}         \tab \code{${MPI_ROOT}} \cr
}
  where \code{${MPI_ROOT}} is the path to the MPI root.
  See the package source file \code{pbdMPI/configure} for details.

  Loading \code{library(pbdMPI)}, sets two global variables \code{.comm.size}
  and \code{.comm.rank}. All codes must end
  with \code{\link{finalize}()} to cleanly exit MPI.

  Most functions are assumed to run as SPMD, i.e.
  in batch mode. On most clusters, codes run with \code{mpirun} or 
  \code{mpiexec} (The MPI Standard 4.0 recommends \code{mpiexec}. Some
  MPI implementations have minor differences between the two but under
  OpenMPI 5.0 they are synonyms that produce the same behavior.) and
  \code{Rscript}, together, such as \cr \cr
  \code{> mpiexec -np 2 Rscript some_code.r} \cr \cr
  where \code{some_code.r} contains the entire SPMD program.  

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
  environments on Linux systems (CentOS 7, RHEL 8, Xubuntu). Also, it is tested
  on macOS with Homebrew-installed OpenMPI and under MPICH2 environments on 
  Windows systems, although the primary target systems are HPC clusters running
  Linux OS.
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com}, George Ostrouchov,
  Drew Schmidt, Pragneshkumar Patel, and Hao Yu.
}
\seealso{
  \code{\link{allgather}()},
  \code{\link{allreduce}()},
  \code{\link{bcast}()},
  \code{\link{gather}()},
  \code{\link{reduce}()},
  \code{\link{scatter}()}.
}
\examples{
\dontrun{
### On command line, run each demo with 2 processors by
### (Use Rscript.exe on Windows systems)
# mpiexec -np 2 Rscript -e "demo(allgather,'pbdMPI',ask=F,echo=F)"
# mpiexec -np 2 Rscript -e "demo(allreduce,'pbdMPI',ask=F,echo=F)"
# mpiexec -np 2 Rscript -e "demo(bcast,'pbdMPI',ask=F,echo=F)"
# mpiexec -np 2 Rscript -e "demo(gather,'pbdMPI',ask=F,echo=F)"
# mpiexec -np 2 Rscript -e "demo(reduce,'pbdMPI',ask=F,echo=F)"
# mpiexec -np 2 Rscript -e "demo(scatter,'pbdMPI',ask=F,echo=F)"
### Or
# execmpi("demo(allgather,'pbdMPI',ask=F,echo=F)", nranks = 2L)
# execmpi("demo(allreduce,'pbdMPI',ask=F,echo=F)", nranks = 2L)
# execmpi("demo(bcast,'pbdMPI',ask=F,echo=F)", nranks = 2L)
# execmpi("demo(gather,'pbdMPI',ask=F,echo=F)", nranks = 2L)
# execmpi("demo(reduce,'pbdMPI',ask=F,echo=F)", nranks = 2L)
# execmpi("demo(scatter,'pbdMPI',ask=F,echo=F)", nranks = 2L)
}
}
\keyword{package}
