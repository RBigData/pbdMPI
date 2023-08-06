### SHELL> mpiexec -np 4 Rscript chunk.r
### Check reproducibility for RNG with -np 2

### Initialize
suppressMessages(library(pbdMPI, quietly = TRUE))

comm.cat("\ncomm.chunk(13):\n", quiet = TRUE)
my_chunk = comm.chunk(13)
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\ncomm.chunk(13, all.rank = TRUE):\n", quiet = TRUE)
my_chunk = comm.chunk(13, all.rank = TRUE)
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\ncomm.chunk(13, form = 'vector'):\n", quiet = TRUE)
my_chunk = comm.chunk(13, form = 'vector')
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\ncomm.chunk(13, form = 'vector', all.rank = TRUE):\n", quiet = TRUE)
my_chunk = comm.chunk(13, form = 'vector', all.rank = TRUE)
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\ncomm.chunk(13, type = 'equal'):\n", quiet = TRUE)
my_chunk = comm.chunk(13, type = 'equal')
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\ncomm.chunk(13, type = 'equal', lo.side = 'left'):\n", quiet = TRUE)
my_chunk = comm.chunk(13, type = 'equal', lo.side = 'left')
comm.print(my_chunk, "\n", all.rank = TRUE)

comm.cat("\nRank-independent RNG streams:\n", quiet = TRUE)
my_chunk = comm.chunk(13, form = 'vector', rng = TRUE, seed = 1357)
comm.print(my_chunk, all.rank = TRUE)

rn = vector("list", length(my_chunk))
for(i in 1:length(my_chunk)) {
  comm.set.stream(my_chunk[i])
  rn[[i]] = runif(5)
}
comm.print(rn, all.rank = TRUE)
## Note above: comm.print() cannot be inside the for loop because it is
##             a collective operation in which all ranks must participate.
##             But rank 0 has a longer loop, causing a hangup wait!

comm.cat("\nReproducible with different numbers of parallel ranks.\n",
         "Repeat with a different number of ranks to check reproducibility.\n",
         quiet = TRUE)

finalize()
