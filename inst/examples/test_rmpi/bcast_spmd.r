### SHELL> mpiexec -np 2 Rscript --vanilla [...]_spmd.r

suppressMessages(library(pbdMPI, quietly = TRUE))

source("./01_setting")

x <- (1:N) + N * .comm.rank

time.proc <- list()

time.proc$default <- system.time({
  for(i in 1:iter.total){
    y <- bcast(list(x))
  }
  barrier()
})

time.proc$array <- system.time({
  for(i in 1:iter.total){
    y <- bcast(matrix(x, nrow = sqrt(N)))
  }
  barrier()
})

time.proc$integer <- system.time({
  for(i in 1:iter.total){
    y <- bcast(as.integer(x))
  }
  barrier()
})

time.proc$double <- system.time({ 
  for(i in 1:iter.total){
    y <- bcast(as.double(x))
  }
  barrier()
})

comm.print(time.proc, quiet = TRUE)

finalize()
