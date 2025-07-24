# This is a test script for pbdMPI
print("About to load pbdMPI")
library(pbdMPI)
print("Loaded pbdMPI")
sessionInfo()
print("Size and Rank")
print(comm.size())
print(comm.rank())
print("About to finalize pbdMPI")
finalize()
print("Finalized pbdMPI")
# test unloading of pbdMPI?
