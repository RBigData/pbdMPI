### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples.
N <- 5
x <- (1:N) + N * .comm.rank
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x, all.rank = TRUE)

y <- allreduce(matrix(x, nrow = 1), op = "sum")
comm.cat("\nAllreduce sum:\n", quiet = TRUE)
comm.print(y)

y <- allreduce(x, op = "prod")
comm.cat("\nAllreduce prod:\n", quiet = TRUE)
comm.print(y)

y <- allreduce(x, op = "max")
comm.cat("\nAllreduce max:\n", quiet = TRUE)
comm.print(y)

y <- allreduce(x, op = "min")
comm.cat("\nAllreduce min:\n", quiet = TRUE)
comm.print(y)

comm.set.seed(1234, diff = TRUE)
x <- as.logical(round(runif(N)))
comm.print(x, all.rank = TRUE)

y <- allreduce(x, op = "land")
comm.cat("\nAllreduce land:\n", quiet = TRUE)
comm.print(y)

y <- allreduce(x, op = "lor")
comm.cat("\nAllreduce lor:\n", quiet = TRUE)
comm.print(y)

### Finish.
finalize()
