### SHELL> mpiexec -np 4 Rscript --vanilla [...].r

suppressMessages(library(pbdMPI, quietly = TRUE))
init()
.comm.size <- comm.size()
.comm.rank <- comm.rank()

N <- 5
x <- (1:N) + N * .comm.rank

if(.comm.rank == 0){
  send(list(x))
} else if(.comm.rank == 1){
  y <- recv()
}
comm.print(y, rank.print = 1)

if(.comm.rank == 0){
  send(as.integer(x), rank.dest = 2)
} else if(.comm.rank == 2){
  y <- recv()
}
comm.print(y, rank.print = 2)

if(.comm.rank == 0){
  send(as.double(x), rank.dest = 3)
} else if(.comm.rank == 3){
  y <- recv()
}
comm.print(y, rank.print = 3)

xx <- as.raw(x)
comm.print(xx, rank.print = 0)
if(.comm.rank == 0){
  send(xx)
  send(xx)
} else if(.comm.rank == 1){
  y <- recv()
  z <- recv(xx)
}
comm.print(y, rank.print = 1)
comm.print(z, rank.print = 1)

xx <- serialize(x, NULL)
comm.print(xx, rank.print = 0)
if(.comm.rank == 0){
  send(xx)
} else if(.comm.rank == 1){
  y <- recv()
}
comm.print(y, rank.print = 1)

finalize()
