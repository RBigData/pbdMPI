### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial
library(pbdMPI, quietly = TRUE)
init()

### Examples
comm.set.seed()
comm.print(rnorm(5), all.rank = TRUE)
comm.reset.seed()
comm.print(rnorm(5), all.rank = TRUE)
comm.end.seed()

comm.set.seed(diff = TRUE)
comm.print(rnorm(5), all.rank = TRUE)
comm.end.seed()

### Finish
finalize()
