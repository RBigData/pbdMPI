library(pbdDEMO, quiet = TRUE)

FUN <- function(jid){
  Sys.sleep(1)
  jid * 10
}

ret <- task.pull(1:10, FUN)

comm.print(ret)

finalize()
