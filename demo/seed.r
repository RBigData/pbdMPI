### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial
library(pbdMPI, quietly = TRUE)
init()

### Examples
comm.set.seed()
comm.print(runif(3), all.rank = TRUE)
comm.reset.seed()
comm.print(runif(3), all.rank = TRUE)
comm.end.seed()

comm.set.seed(diff = TRUE)
comm.print(runif(3), all.rank = TRUE)
saved.seed <- comm.get.seed()  # save status.
comm.print(runif(3), all.rank = TRUE)
comm.end.seed()

### Start from a saved status.
comm.set.seed(saved.seed)		# bug here!!!
comm.print(runif(3), all.rank = TRUE)
comm.end.seed()

### Finish
finalize()
