### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

library(pbdMPI, quiet = TRUE)
init()

N <- 5
x <- (1:N) + N * .comm.rank

if(.comm.rank == 0){
  send(list(x))
} else if(.comm.rank == 1){
  y <- recv(list(x))
}
comm.print(y, rank.print = 1)

if(.comm.rank == 0){
  send(as.integer(x))
} else if(.comm.rank == 1){
  y <- recv(as.integer(x))
}
comm.print(y, rank.print = 1)

if(.comm.rank == 0){
  send(as.double(x))
} else if(.comm.rank == 1){
  y <- recv(as.double(x))
}
comm.print(y, rank.print = 1)

finalize()

