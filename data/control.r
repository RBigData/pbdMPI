### MPI control.

.SPMD.CT <- list(
  comm = 0L,
  info = 0L,
  intercomm = 2L,
  op = "sum",
  print.all.rank = FALSE,
  rank.root = 0L,
  rank.source = 0L,
  rank.dest = 1L,
  request = 0L,
  status = 0L,
  tag = 0L,
  unlist = FALSE,
  divide.method = c("block", "cycle"),
  mpi.finalize = TRUE
) # End of .SPMD.CT

.SPMD.OP <- c("sum", "prod", "max", "min")

# .SPMD.DT <- data.frame(
#   name = c("int", "double", "char", "raw"),
#   id = as.integer(1:4)
# ) # End of .SPMD.DT

