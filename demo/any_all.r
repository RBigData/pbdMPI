### SHELL> mpiexec -np 2 Rscript --vanilla [...].r

### Initial
library(pbdMPI, quiet = TRUE)
init()
if(comm.size() != 2){
  warning("2 processors is requried to run this demo.")
  finalize()
}

### Examples
if(comm.rank() == 0){
  a <- c(T, F, NA)
} else{
  a <- T
}

tmp <- comm.any(a)
comm.print(tmp)
tmp <- comm.all(a)
comm.print(tmp)
tmp <- comm.any(a, na.rm = TRUE)
comm.print(tmp)
tmp <- comm.all(a, na.rm = TRUE)
comm.print(tmp)

### Finish
finalize()
