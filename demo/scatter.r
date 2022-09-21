### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x.total <- (.comm.size + 1) * .comm.size / 2
x <- 1:x.total
x.count <- 1:.comm.size
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x)

y <- scatter(split(x, rep(x.count, x.count)))    ### return elements of list.
comm.cat("\nScatter list:\n", quiet = TRUE)
comm.print(y)

y <- scatter(as.integer(x), integer(.comm.rank + 1), as.integer(x.count))
comm.cat("\nScatterv integer:\n", quiet = TRUE)
comm.print(y, rank.print = 1)

y <- scatter(as.double(x), double(.comm.rank + 1), as.integer(x.count))
comm.cat("\nScatterv double:\n", quiet = TRUE)
comm.print(y, rank.print = 1)

### Finish.
finalize()
