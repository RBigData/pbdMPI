### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

library(pbdMPI, quiet = TRUE)
init()

N <- 100
x <- split((1:N) + N * .comm.rank, rep(1:10, each = 10))
y <- pbdLapply(x, sum, pbd.mode = "spmd")
comm.print(unlist(y))

y <- pbdLapply(x, sum)
comm.print(unlist(y))

finalize()

