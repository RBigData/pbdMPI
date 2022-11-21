### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
N <- 5
x <- (1:N) + N * .comm.rank
comm.cat("Original x:\n", quiet = TRUE)
comm.print(x, all.rank = TRUE)

y <- reduce(matrix(x, nrow = 1), op = "sum")
comm.cat("\nReduce sum:\n", quiet = TRUE)
comm.print(y)

y <- reduce(x, op = "prod")
comm.cat("\nReduce prod:\n", quiet = TRUE)
comm.print(y)

y <- reduce(x, op = "max")
comm.cat("\nReduce max:\n", quiet = TRUE)
comm.print(y)

y <- reduce(x, op = "min")
comm.cat("\nReduce min:\n", quiet = TRUE)
comm.print(y)

comm.cat("\n-- Print from rank 1:\n", rank.print = 1, quiet = TRUE)
comm.print(y, rank.print = 1)

comm.set.seed(1234, diff = TRUE)
x <- as.logical(round(runif(N)))
comm.print(x, all.rank = TRUE)

y <- reduce(x, op = "land")
comm.cat("\nReduce land:\n", quiet = TRUE)
comm.print(y)

y <- reduce(x, op = "lor")
comm.cat("\nReduce lor:\n", quiet = TRUE)
comm.print(y)


### Finish.
finalize()
