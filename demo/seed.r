### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial
library(pbdMPI, quietly = TRUE)
init()

### Examples
comm.set.seed()
comm.print(runif(5), all.rank = TRUE)
comm.reset.seed()
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Obtain the seed state
comm.set.seed(diff = TRUE)
comm.print(runif(5), all.rank = TRUE)
saved.seed <- comm.seed.state()   # save the state
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Start from a saved status
comm.set.seed(state = saved.seed) # rewind to the state
comm.print(runif(5), all.rank = TRUE)
comm.end.seed()

### Finish
finalize()
