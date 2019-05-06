pkgname <- "pbdMPI"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('pbdMPI')


base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')


### A lot of examples are removed from this file.
### See "pbdMPI-Ex.R" from the "R CMD check" for all examples.


cleanEx()
nameEx("aa_allreduce-method")
### * aa_allreduce-method

flush(stderr()); flush(stdout())

### Name: allreduce-method
### Title: All Ranks Receive a Reduction of Objects from Every Rank
### Aliases: allreduce-method allreduce,ANY,missing-method
###   allreduce,integer,integer-method allreduce,numeric,numeric-method
###   allreduce,logical,logical-method allreduce,float32,float32-method
###   allreduce
### Keywords: methods collective

### ** Examples

### Save code in a file "demo.r" and run with 2 processors by
### SHELL> mpiexec -np 2 Rscript demo.r

spmd.code <- "
### Initial.
suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
y <- allreduce(matrix(x, nrow = 1), op = \"sum\")
comm.print(y)

y <- allreduce(x, double(N), op = \"prod\")
comm.print(y)

comm.set.seed(1234, diff = TRUE)
x <- as.logical(round(runif(N)))
y <- allreduce(x, logical(N), op = \"land\")
comm.print(y)

### Finish.
finalize()
"
pbdMPI::execmpi(spmd.code = spmd.code, nranks = 2L)


### To force free memory of some MPI stuffs in "zz_spmd_internal".
finalize(mpi.finalize = TRUE)


### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
