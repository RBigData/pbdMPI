suppressPackageStartupMessages(library(pbdMPI, quietly=TRUE))

cs <- comm.size()

testval <- allreduce(comm.rank())
trueval <- cs*(cs-1)/2

if (comm.rank()==0) testval == trueval

finalize()
