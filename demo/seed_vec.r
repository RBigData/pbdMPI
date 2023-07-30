### For resource-independent reproducibility, set vector-based streams.
### run as:
### SHELL> mpiexec -np 2 Rscript --vanilla [...].r
### and compare with:
### SHELL> mpiexec -np 4 Rscript --vanilla [...].r
### 
### Note: comm.set.stream will work in mclapply for same reproducibility
### 
### Note2: only lines with #RNG comment are RNG-relevant all others manage
###        pretty printing
### Question for deeper understanding:
###          Why do we show 6 numbers for vector-based and only 3 for 
###          rank-based results? (Hint: where does "v 2" of rank-based 
###          result show up in "v 1" of vector-based result?)

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))  #RNG
rank = comm.rank()
size = comm.size()

vector = 1:8  #RNG
my_vector = comm.chunk(length(vector), form = "vector")  #RNG
comm.cat("rank", rank, "my_vector:", my_vector, "\n", all.rank = TRUE, quiet = TRUE)

comm.cat("\n", size, "ranks: using rank-based streams:\n", quiet = TRUE)
comm.cat("v Reproducibility depends on resources:\n", quiet = TRUE)
comm.set.seed(123456, diff = TRUE)  #RNG
for(v in my_vector) {
  rn = runif(3)  #RNG
  comm.cat("rank", rank, "v", v, "generates:", rn, "\n", all.rank = TRUE, quiet = TRUE)
}

comm.cat("\n", size, "ranks: using vector-based streams:\n", quiet = TRUE)
comm.cat("v Reproducibility independent of resources:\n", quiet = TRUE)
comm.set.seed(123456, diff = TRUE, streams = length(vector))  #RNG
for(v in my_vector) {
  comm.set.stream(v)  #RNG
  rn = runif(6)  #RNG
  comm.cat("rank", rank, "v", v, "generates:", rn, "\n", all.rank = TRUE, quiet = TRUE)
}

finalize()
