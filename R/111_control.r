### MPI control.
SPMD.CT <- function(
  comm = 0L,
  intercomm = 2L,
  newcomm = 1L,
  comm.within = 3L,
  comm.between = 4L,
  op = "sum",
  port.name = "spmdport",
  serv.name = "spmdserv",
  print.all.rank = FALSE,
  print.quiet = FALSE,
  rank.root = 0L,
  rank.source = 0L,
  rank.dest = 1L,
  request = 0L,
  info = 0L,
  status = 0L,
  tag = 0L,
  unlist = FALSE,
  divide.method = c("block",
                    "block0",
                    "cycle"),
  mpi.finalize = TRUE,
  quit = TRUE,
  msg.flush = TRUE,
  msg.barrier = TRUE,
  Rprof.all.rank = FALSE,
  lazy.check = FALSE,
  check.type = TRUE,
  unserialize.raw = NA
){
  list(
    comm = comm,                      # As default COMM_WORLD.
    intercomm = intercomm,            # As Rmpi default inter comm.
    newcomm = newcomm,                # As Rmpi default new comm.
    comm.within = comm.within,        # Within host comm.
    comm.between = comm.between,      # Between host comm.
    op = op,                          # For reduce/allreduce.
    port.name = port.name,            # For clinet/sever.
    serv.name = serv.name,            # For client/sever.
    print.all.rank = print.all.rank,  # For comm.print() and comm.cat().
    print.quiet = print.quiet,        # For comm.print() and comm.cat().
    rank.root = rank.root,            # Default root.
    rank.source = rank.source,        # Default source.
    rank.dest = rank.dest,            # Default desitnation.
    request = request,                # For send() and recv().
    info = info,                      # For send() and recv().
    status = status,                  # For send() and recv().
    tag = tag,                        # For send() and recv().
    unlist = unlist,                  # For gather() and allgather().
    divide.method = divide.method,    # gbd stuffs.
    mpi.finalize = mpi.finalize,      # MPI finalization.
    quit = quit,                      # R quit.
    msg.flush = msg.flush,            # For comm.print() and comm.cat().
    msg.barrier = msg.barrier,        # For comm.print() and comm.cat().
    Rprof.all.rank = Rprof.all.rank,  # For Rprof().
    lazy.check = lazy.check,          # For comm.allcommon().
    check.type = check.type,          # For send() and recv().
    unserialize.raw = unserialize.raw # For recv(), if unserialize raw data.
  )
} # End of SPMD.CT().

### For reduce() and allreduce().
SPMD.OP <- function(
  OP = c("sum", "prod", "max", "min", "land", "band",
         "lor", "bor", "lxor", "bxor")
){
  OP
} # End of SPMD.OP().

### To be consistent with SPMD_DT in "spmd_constant.h".
SPMD.DT <- function(
){
  list(
    integer = 1L,
    double = 2L,
    raw = 3L,
    character = 4L,
    alc.func = c(base::integer, base::double, base::raw, base::character),
    is.func = c(base::is.integer, base::is.double, base::is.raw,
                  base::is.character)
  )
} # End of SPMD.DT().

