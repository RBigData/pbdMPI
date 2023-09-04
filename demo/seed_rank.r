### SHELL> mpiexec -np 2 Rscript --vanilla [...].r
### 
### Examples for parallel use of multi-stream L'Ecuyer-CMRG random number 
### generation with rank-based reproducibility. See file seed_vec.r for
### examples of vector-based reproducibility that is independent of parallelism
### levels.

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.pbd_env$SPMD.CT$print.quiet = TRUE  # set global print.quiet (no rank info)

comm.cat("\nR RNG default Mersenne-Twister, no seed:\n")
comm.print(RNGkind())
comm.cat("\n")
comm.cat("Different streams on ranks, probably (but not guaranteed) non-overlapping, not reproducible.\n")
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nNow add set.seed(1357):\n")
set.seed(1357)
comm.cat("Same streams on ranks, reproducible.\n")
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nSwitch to parallel L'Ecuyere-CMRG\n")
old.kind = comm.set.seed(1357)
comm.print(RNGkind())
comm.cat("\n")
comm.cat("Same streams on ranks, reproducible.\n")
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nReset streams with comm.set.stream(reset = TRUE):\n")
comm.set.stream(reset = TRUE)
comm.print(runif(5), all.rank = TRUE)

comm.cat("\ncomm.set.seed(1357, diff = TRUE):\n")
comm.cat("Different streams on ranks, guaranteed non-overlapping, reproducible with same number of ranks:\n")
comm.set.seed(1357, diff = TRUE)
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nSave state and continue:\n")
state <- comm.set.stream()   ### save each rank's stream state
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nStart from the saved state:\n")
comm.set.stream(state = state) ### set current RNG to state
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nRestore R default Mersenne-Twister and set.seed(1357):\n")
RNGkind(old.kind)
set.seed(1357)
comm.print(RNGkind())
comm.print(runif(5), all.rank = TRUE)

comm.cat("\nFor rank-number-independent reproducibility, see demo seed_vec.r\n")

finalize()
