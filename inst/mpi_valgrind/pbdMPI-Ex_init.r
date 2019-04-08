pkgname <- "pbdMPI"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('pbdMPI')


### A lot of examples are removed from this file.
### See "pbdMPI-Ex.R" from the "R CMD check" for all examples.
### See "pbdMPI-Ex_allreduce.r" in this director for one example.


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
