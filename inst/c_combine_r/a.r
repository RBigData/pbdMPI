### To disable "rlecuyer" loading in "pbdMPI::.onLoad()" because
### an spmd_bcast() call is needed to get the parallel RNG working in the
### "pbdMPI::.onLoad()" function.
.Random.seed <- NULL

library(pbdMPI, quietly = TRUE)

### To be consistent with "a.c".
cat("[R] size: ", comm.size(), ", rank: ", comm.rank(), "\n", sep = "")

finalize()
