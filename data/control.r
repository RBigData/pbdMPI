### MPI control.
.SPMD.CT <- list(
  comm = 0L,                   # As default COMM_WORLD.
  intercomm = 2L,              # As Rmpi default inter comm.
  newcomm = 1L,                # As Rmpi default new comm.
  comm.within = 3L,            # Within host comm.
  comm.between = 4L,           # Between host comm.
  op = "sum",                  # For reduce/allreduce.
  port.name = "spmdport",      # For clinet/sever.
  serv.name = "spmdserv",      # For client/sever.
  print.all.rank = FALSE,      # For comm.print() and comm.cat().
  print.quiet = FALSE,         # For comm.print() and comm.cat().
  rank.root = 0L,              # Default root.
  rank.source = 0L,            # Default source.
  rank.dest = 1L,              # Default desitnation.
  request = 0L,                # For send() and recv().
  info = 0L,                   # For send() and recv().
  status = 0L,                 # For send() and recv().
  tag = 0L,                    # For send() and recv().
  unlist = FALSE,              # For gather() and allgather().
  divide.method = c("block",
                    "block0",
                    "cycle"),  # gbd stuffs.
  mpi.finalize = TRUE,         # MPI finalization.
  quit = TRUE,                 # R quit.
  msg.flush = TRUE,            # For comm.print() and comm.cat().
  msg.barrier = TRUE,          # For comm.print() and comm.cat().
  Rprof.all.rank = FALSE,      # For Rprof().
  lazy.check = FALSE           # For comm.allcommon().
) # End of .SPMD.CT

### For reduce() and allreduce().
.SPMD.OP <- c("sum", "prod", "max", "min", "land", "band", "lor", "bor",
              "lxor", "bxor")

# .SPMD.DT <- data.frame(
#   name = c("int", "double", "char", "raw"),
#   id = as.integer(1:4)
# ) # End of .SPMD.DT
