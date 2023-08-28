suppressPackageStartupMessages(library(pbdMPI, quietly=TRUE))

testval <- length(allgather(comm.rank()))
trueval <- comm.size()

if (comm.rank()==0) testval == trueval

finalize()
