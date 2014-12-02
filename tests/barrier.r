suppressPackageStartupMessages(library(pbdMPI, quietly=TRUE))
init()

sleeptime <- 3

time <- system.time({
  if (comm.rank()==0)
    Sys.sleep(sleeptime)
  
  barrier()
})

test <- comm.all(time > sleeptime)
comm.print(test)

finalize()
