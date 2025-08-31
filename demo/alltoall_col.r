### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()
COMM <- .pbd_env$SPMD.CT$comm

### Examples.
n <- as.integer(2)
x <- 1:(.comm.size * n)
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x, all.rank = TRUE)
comm.print(x, all.rank = TRUE, quiet = COMM)

x <- as.integer(x)
y <- spmd.alltoall.integer(x, integer(length(x)), n, n)
comm.cat("\nAlltoall y:\n", quiet = TRUE)
comm.print(y, all.rank = TRUE)
comm.print(y, all.rank = TRUE, quiet = COMM)

comm.print("Alltoall is like a block-tranpose!")
### Finish.
finalize()
