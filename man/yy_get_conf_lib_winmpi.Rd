\name{Get Configures Used at Compiling Time}
\alias{get.conf}
\alias{get.lib}
\alias{get.sysenv}
\title{Functions to Get MPI and/or pbdMPI Configures Used at Compiling Time}
\description{
  These functions are designed to get MPI and/or pbdMPI configures that
  were usually needed at the time of pbdMPI installation. In particular,
  to configure, link, and compile with `libmpi*.so` or so.
}
\usage{
get.conf(arg, arch = '', package = "pbdMPI", return = FALSE)
get.lib(arg, arch, package = "pbdPROF")
get.sysenv(flag)
}
\arguments{
  \item{arg}{an argument to be searched in the configuration file}
  \item{arch}{system architecture}
  \item{package}{pakge name}
  \item{return}{to return (or print if FALSE) the search results or not}
  \item{flag}{a system flag that is typically used in windows environment
              \code{set}.}
}
\details{
  \code{get.conf()} and \code{get.lib()}
  are typically used by `pbd*/configure.ac`,
  `pbd*/src/Makevars.in`, and/or `pbd*/src/Makevar.win` to find
  the default configurations from `pbd*/etc${R_ARCH}/Makconf`.

  \code{get.sysenv()}
  is only called by `pbdMPI/src/Makevars.win` to obtain
  possible MPI dynamic/static library from the environment variable
  `MPI_ROOT` preset by users.
}
\value{
  Typically, there are no return values, but the values are \code{cat()} to
  scrrn or stdin.
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
\dontrun{
library(pbdMPI)
if(Sys.info()["sysname"] != "Windows"){
  get.conf("MPI_INCLUDE_PATH"); cat("\n")
  get.conf("MPI_LIBPATH"); cat("\n")
  get.conf("MPI_LIBNAME"); cat("\n")
  get.conf("MPI_LIBS"); cat("\n")
} else{
  get.conf("MPI_INCLUDE", "/i386"); cat("\n")
  get.conf("MPI_LIB", "/i386"); cat("\n")

  get.conf("MPI_INCLUDE", "/x64"); cat("\n")
  get.conf("MPI_LIB", "/x64"); cat("\n")
}
}
}
\keyword{utility}
