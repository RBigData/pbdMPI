### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial
library(pbdMPI, quiet = TRUE)
init()

### Examples
comm.set.seed(diff = TRUE)
 x <- c(rnorm(5 + .comm.rank * 2), NA)
# x <- sample(1:5, 5 + .comm.rank * 2, replace = TRUE)
comm.end.seed()
x <- c(x, NA)

if(.comm.rank == 1){
  x <- NULL    ### Test for NULL or 0 vector.
}

y <- allgather(x)
comm.print(y)

y <- g.sort(x)
y <- allgather(y)
comm.print(y)

### Finish
finalize()
