### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))

seed = 123456

comm.cat("Default:\n", quiet = TRUE)
comm.set.seed(seed)
comm.print(runif(5), all.rank = TRUE)
comm.print(runif(5), all.rank = TRUE)

comm.cat("Reset:\n", quiet = TRUE)
comm.set.seed(seed)
comm.print(runif(5), all.rank = TRUE)

comm.cat("diff = TRUE:\n", quiet = TRUE)
comm.set.seed(seed, diff = TRUE)
comm.print(runif(5), all.rank = TRUE)

comm.cat("Save state and continue:\n", quiet = TRUE)
state <- get.stream.state()   ### save the state
comm.print(runif(5), all.rank = TRUE)

comm.cat("Restart from the saved state:\n", quiet = TRUE)
state2 <- set.stream.state(state) ### rewind to the state
comm.print(runif(5), all.rank = TRUE)

finalize()
