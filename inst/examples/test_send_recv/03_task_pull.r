### SHELL> mpiexec -np 4 Rscript --vanilla [...].r

suppressMessages(library(pbdMPI, quietly = TRUE))

### Examples.
FUN <- function(jid){
  Sys.sleep(0.5)
  jid * 10
}

ret <- task.pull(1:20, FUN)
comm.print(ret)

if(comm.rank() == 0){
  ret.jobs <- unlist(ret)
  ret.jobs <- ret.jobs[names(ret.jobs) == "ret"]
  print(ret.jobs)
}

### Finish.
finalize()

