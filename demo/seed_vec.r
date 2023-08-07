### SHELL> mpiexec -np 2 Rscript --vanilla [...].r
###  compare with:
### SHELL> mpiexec -np 4 Rscript --vanilla [...].r
### 
### Note: comm.set.stream() will work in mclapply for same vector-based
###       reproducibility
### Note: Only lines with #RNG comment are RNG-relevant all others manage
###       pretty printing
### 
### Question for deeper understanding:
###          Why do we show 6 numbers for vector-based and only 3 for 
###          rank-based results? (Hint: where does "v 2" of rank-based 
###          result show up in "v 1" of vector-based result?)

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))        #RNG
rank = comm.rank()
size = comm.size()
.pbd_env$SPMD.CT$print.quiet = TRUE  # set global print.quiet (no rank info)

vector = 1:8                                             #RNG
my_vector = comm.chunk(length(vector), form = "vector")  #RNG
comm.cat("rank", rank, "my_vector:", my_vector, "\n", all.rank = TRUE)

comm.cat("\n", size, "ranks: using rank-based streams:\n")
comm.cat("v Reproducibility depends on resources:\n")
comm.set.seed(123456, diff = TRUE)                       #RNG
for(v in my_vector) {
  rn = runif(3)                                          #RNG
  comm.cat("rank", rank, "v", v, "generates:", rn, "\n", all.rank = TRUE)
}

comm.cat("\n", size, "ranks: using vector-based streams:\n")
comm.cat("v Reproducibility independent of resources:\n")
comm.set.seed(123456, diff = TRUE, streams = vector)     #RNG
for(v in my_vector) {
  comm.set.stream(v)                                     #RNG
  rn = runif(6)                                          #RNG
  comm.cat("rank", rank, "v", v, "generates:", rn, "\n", all.rank = TRUE)
}

comm.cat("\n", size, "ranks and 2 forked cores: using vector-based streams:\n")
comm.cat("v Reproducibility independent of resources, even with mclapply():\n")
comm.set.seed(123456, diff = TRUE, streams = vector)     #RNG
res = parallel::mclapply(my_vector, function(v) {
  comm.set.stream(v)                                     #RNG
  runif(6)                                               #RNG
  }, mc.cores = 2) 
for(i in 1:length(res)) {
  comm.cat("rank", rank, "mc", i, "v", my_vector[i], "generates:", res[[i]],
           "\n", all.rank = TRUE)
}

finalize()
