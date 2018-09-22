### mpiexec -np 2 Rscript mpi_comm_ptr.r
suppressPackageStartupMessages(library(pbdMPI, quietly=TRUE))
init()

cs <- comm.size()
if(cs < 1){
  comm.cat("Need more than one rank.\n")
} else{
  comm.cat("Original:\n")
  a.ptr <- pbdMPI:::get.mpi.comm.ptr(show.msg = TRUE)

  comm.cat("New rank via R:\n")
  pbdMPI:::addr.mpi.comm.ptr(a.ptr)

### The above should return something like below:
#
# COMM.RANK = 0
# Original:
# rank: 0, comm: f6b11ba0, MPI_COMM_WORLD: f6b11ba0.
# rank: 1, comm: c0a60ba0, MPI_COMM_WORLD: c0a60ba0.
###              ********
#
# COMM.RANK = 0
# After via R:
# rank: 1, comm: c0a60ba0, MPI_COMM_WORLD: c0a60ba0, rank_new: 1.
# rank: 0, comm: f6b11ba0, MPI_COMM_WORLD: f6b11ba0, rank_new: 0.
# ^^^^^^^        ********                            ^^^^^^^^^^^
#
### Note: rank (within after via R) should be the same indicated by ^^^^^
### Note: comm address (across original and after via R) should be the same
###       indicated by "*******". Because this is comm[0], so that it should
###       also has the same address as MPI_COMM_WORLD.
}

finalize()
