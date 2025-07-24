# This is a test script for pbdMPI
library(pbdMPI)
sessionInfo()
print("Size and Rank")
print(comm.size())
print(comm.rank())
finalize()
# test unloading of pbdMPI?
