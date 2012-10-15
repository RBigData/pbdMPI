### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

library(pbdMPI, quiet = TRUE)
init()

N <- 5
x <- 1:(.comm.rank + 1)
x.total <- (.comm.size + 1) * .comm.size / 2
x.count <- 1:.comm.size
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x, all.rank = TRUE)

y <- allgather(matrix(x, nrow = 1))
comm.cat("\nAllgather matrix:\n", quiet = TRUE)
comm.print(y)

y <- allgather(as.integer(x), integer(x.total), as.integer(x.count))
comm.cat("\nAllgather integer:\n", quiet = TRUE)
comm.print(y)

y <- allgather(as.double(x), double(x.total), as.integer(x.count))
comm.cat("\nAllgather double:\n", quiet = TRUE)
comm.print(y)

finalize()

