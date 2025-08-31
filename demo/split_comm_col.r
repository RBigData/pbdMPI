### SHELL> mpiexec -np 4 Rscript --vanilla [...].r

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))
.comm.size <- comm.size()
.comm.rank <- comm.rank()

### Examples
comm_world <- .pbd_env$SPMD.CT$comm  # world communicator
my_rank <- comm.rank(comm_world)     # my rank in world communicator
comm_new <- 5L                       # new communicator (0-4 are taken)

my_partition <- my_rank %/% 2L           # set my partition and split
comm.split(comm_world, color = my_partition, key = my_rank, newcomm = comm_new)

barrier()

my_newrank <- comm.rank(comm_new)     # my rank in new communicator
comm.cat("comm_world:", comm_world, "comm_new", comm_new, "my_partition:",
         my_partition, "my_rank:", my_rank, "my_newrank", my_newrank, "\n",
         all.rank = TRUE, comm = comm_world)

comm.cat("\nAssign unique values:\n", quiet = TRUE)
x <- my_rank + 1
comm.cat("x =", x, "\n", all.rank = TRUE)
comm.cat("\nNow allreduce to xw on comm_world and to xn on comm_new.\n", quiet = TRUE)
xw <- allreduce(x, comm = comm_world)
xn <- allreduce(x, comm = comm_new)

comm.cat("\nPrinted with my_rank labels (comm_world):\n", quiet = TRUE)
comm.cat("xw =", xw, "xn =", xn, "\n", all.rank = TRUE, quiet = FALSE, comm = comm_world)
comm.cat("\nPrinted with my_rank colors (comm_world):\n", quiet = TRUE)
comm.cat("xw =", xw, "xn =", xn, "\n", all.rank = TRUE, quiet = comm_world, comm = comm_world)
comm.cat("\nPrinted with my_newrank colors (comm_new):\n", quiet = TRUE)
comm.cat("xw =", xw, "xn =", xn, "\n", all.rank = TRUE, quiet = comm_new, comm = comm_world)

### Finish
comm.free(comm_new)
finalize()
