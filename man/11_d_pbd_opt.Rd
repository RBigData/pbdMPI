\name{Set global pbd options}
\alias{pbd_opt}
\title{ Set Global pbdR Options }
\description{
  This is an advanced function to set pbdR options.
}
\usage{
pbd_opt(..., bytext = "", envir = .GlobalEnv)
}
\arguments{
  \item{...}{in argument format \code{option = value} to set
             \code{.pbd_env$option <- value} inside the \code{envir}.}
  \item{bytext}{in text format \code{"option = value"} to set
             \code{.pbd_env$option <- value} inside the \code{envir}.}
  \item{envir}{by default the global environment is used.}
}
\details{
  \code{...} allows multiple options in
  \code{envir$.pbd_env}, but only in a simple way.

  \code{bytext} allows to assign options by text in
  \code{envir$.pbd_env}, but can assign advanced objects. For example,
  \code{"option$suboption <- value"} will set
  \code{envir$.pbd_env$option$suboption <- value}.
}
\value{
  No value is returned.
}
\references{
  Programming with Big Data in R Website:
  \url{https://pbdr.org/}
}
\author{
  Wei-Chen Chen \email{wccsnow@gmail.com} and Drew Schmidt.
}
\seealso{
  \code{\link{.pbd_env}},
  \code{\link{SPMD.CT}()},
  \code{\link{SPMD.OP}()},
  \code{\link{SPMD.IO}()},
  \code{\link{SPMD.TP}()}, and
  \code{\link{.mpiopt_init}()}.
}
\examples{
\dontrun{
### Save code in a file "demo.r" and run with 4 processors by
### SHELL> mpiexec -np 4 Rscript demo.r

### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()

### Examples.
ls(.pbd_env)
pbd_opt(ICTXT = c(2, 2))
pbd_opt(bytext = "grid.new <- list(); grid.new$ICTXT <- c(4, 4)")
pbd_opt(BLDIM = c(16, 16), bytext = "grid.new$BLDIM = c(8, 8)")
ls(.pbd_env)
.pbd_env$ICTXT
.pbd_env$BLDIM
.pbd_env$grid.new

### Finish.
finalize()
}
}
\keyword{global variables}
