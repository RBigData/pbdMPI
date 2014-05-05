### SHELL> mpiexec -np 4 Rscript --vanilla [...].r

### Initial.
library(pbdMPI, quietly = TRUE)

### Get a gbd row-block matrix.
X <- matrix(0, nrow = 0, ncol = 4)
if(comm.rank() == 0){
  X <- matrix(unlist(iris[, -5]), ncol = 4)
}
X.gbd <- comm.as.gbd(X)

### Get a common distance matrix.
X.dist <- comm.dist(X.gbd)

### Get a distributed distance object.
N <- allreduce(nrow(X.gbd))
pairs.gbd <- comm.allpairs(N)
# X.dist.obj <- comm.pairwise(X.gbd, pairs.gbd)
# X.dist.obj <- comm.pairwise(X.gbd)    ### The other way

### Verify.
# comm.print(all(X.dist.obj[, 3] == as.vector(X.dist)))

### Finish.
finalize()
