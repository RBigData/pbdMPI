### MPI control.

.SPMD.CT <- list(
  comm = 0L,
  intercomm = 2L,
  info = 0L,
  newcomm = 1L,
  op = "sum",
  port.name = "spmdport",
  print.all.rank = FALSE,
  print.quiet = FALSE,
  rank.root = 0L,
  rank.source = 0L,
  rank.dest = 1L,
  request = 0L,
  serv.name = "spmdserv",
  status = 0L,
  tag = 0L,
  unlist = FALSE,
  divide.method = c("block", "block0", "cycle"),
  mpi.finalize = TRUE,
  quit = TRUE,
  msg.flush = TRUE,
  msg.barrier = TRUE,
  Rprof.all.rank = FALSE,
  lazy.check = FALSE
) # End of .SPMD.CT

.SPMD.OP <- c("sum", "prod", "max", "min", "land", "band", "lor", "bor",
              "lxor", "bxor")

# .SPMD.DT <- data.frame(
#   name = c("int", "double", "char", "raw"),
#   id = as.integer(1:4)
# ) # End of .SPMD.DT
