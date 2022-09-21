### These functions are modified from "task_pull.R" originally provided
### at "http://math.acadiau.ca/ACMMaC/Rmpi/examples.html".
###
### The "task_pull.R" is mainly designed to mimic Rmpi's legacy manager/workers
### parallel environment. However, the following functions are aiming
### for SPMD and presuming one of ranks (default 0) has the role of manager.

# e.g. Suppose everyone knows FUN and ..., then the code should like
#
#   if(comm.rank() != 0){
#     ret <- task.pull.workers(FUN)
#   } else{
#     ret <- task.pull.manager(jids = 1:100, FUN)
#   }
#
# where ret is the results in manager, and NULL in all workers.

task.pull.workers <- function(FUN = function(jid, ...){ return(jid) },
    ..., rank.manager = .pbd_env$SPMD.CT$rank.root,
    comm = .pbd_env$SPMD.CT$comm,
    try = .pbd_env$SPMD.TP$try, try.silent = .pbd_env$SPMD.TP$try.silent){
  ### FUN <- function(jid, ...) is a user defined function.

  ### Note the use of the tag for sent messages:
  ###     1 = ready_for_job, 2 = done_job, and 3 = exiting.
  ### Note the use of the tag for received messages:
  ###     1 = job, and 2 = done_jobs.
  done <- 0L
  while(done != 1L){
    ### Signal being ready to receive a new job.
    spmd.send.default(0L, rank.dest = rank.manager, tag = 1L, comm = comm,
                      check.type = FALSE)

    ### Receive a job id.
    jid <- spmd.recv.default(rank.source = rank.manager,
                             tag = spmd.anytag(), comm = comm,
                             check.type = FALSE)
    sourcetag <- spmd.get.sourcetag()
    tag <- sourcetag[2]

    if(tag == 1){
      if(try){
        tmp <- try(FUN(jid, ...), silent = try.silent)
      } else{
        tmp <- FUN(jid, ...)
      }
      ret <- list(jid = jid, ret = tmp)

      ### Send a results message back to the manager.
      spmd.send.default(ret, rank.dest = rank.manager, tag = 2L, comm = comm,
                        check.type = FALSE)
    } else if(tag == 2){
      done <- 1L
    }
    ### We'll just ignore any unknown messages.
  }

  spmd.send.default(0L, rank.dest = rank.manager, tag = 3L, comm = comm,
                    check.type = FALSE)
  invisible()
} # End of task.pull.workers().


task.pull.manager <- function(jids, rank.manager = .pbd_env$SPMD.CT$rank.root,
    comm = .pbd_env$SPMD.CT$comm){
  ### Check.
  if(spmd.comm.rank(comm) != rank.manager){
    comm.stop("Wrong manager id.")
  }
  if(spmd.comm.size(comm) == 1){
    comm.stop("Comm size >= 2 is required.")
  }

  ### Note the use of the tag for received messages:
  ###     1 = ready_for_job, 2 = done_job, and 3 = exiting.
  ### Note the use of the tag for sent messages:
  ###     1 = job, and 2 = done_jobs.

  closed.workers <- 0L
  n.workers <- spmd.comm.size(comm) - 1
  # ret <- vector("list", n.workers)
  # for(i in 1:n.workers){
  #   ret[[i]] <- list()
  # }
  if(! all(jids > 0) || ! is.integer(jids)){
    comm.stop("jids should be all positive integers.")
  }
  ret <- vector("list", max(jids))

  while(closed.workers < n.workers){
    ### Receive a message from a worker.
    ret.worker <- spmd.recv.default(rank.source = spmd.anysource(),
                                    tag = spmd.anytag(), comm = comm,
                                    check.type = FALSE)
    sourcetag <- spmd.get.sourcetag()
    worker.id <- sourcetag[1]
    tag <- sourcetag[2]

    if(tag == 1L){
      ### The worker is ready for a job.
      ### Give the next job to the worker if there is any available.
      ### Or, tell the worker that it's works are all done if there is none.
      if(length(jids) > 0){
        ### Send a job, and then remove it from the job list.
        spmd.send.default(jids[1], rank.dest = worker.id, tag = 1L, comm = comm,
                          check.type = FALSE)
        jids <- jids[-1]
      } else{
        spmd.send.default(0L, rank.dest = worker.id, tag = 2L, comm = comm,
                          check.type = FALSE)
      }
    } else if (tag == 2L){
      ### The message contains results. Do something with the results.
      ### Store them in the data structure.
      # ret[[worker.id]][[length(ret[[worker.id]]) + 1]] <- ret.worker
      ret[[ret.worker$jid]] <- ret.worker$ret
    } else if(tag == 3L){
      ### A worker has closed down.
      closed.workers <- closed.workers + 1
    }
  }

  ret
} # End of task.pull.manager().


task.pull <- function(jids, FUN, ...,
    rank.manager = .pbd_env$SPMD.CT$rank.root,
    comm = .pbd_env$SPMD.CT$comm, bcast = .pbd_env$SPMD.TP$bcast,
    barrier = .pbd_env$SPMD.TP$barrier,
    try = .pbd_env$SPMD.TP$try, try.silent = .pbd_env$SPMD.TP$try.silent){

  if(spmd.comm.rank(comm) != rank.manager){
    ret <- task.pull.workers(FUN, ..., rank.manager = rank.manager, comm = comm,
                             try = try, try.silent = try.silent)
  } else{
    ret <- task.pull.manager(jids, rank.manager = rank.manager, comm = comm)
  }

  if(bcast){
    ret <- spmd.bcast.object(ret, rank.source = rank.manager, comm = comm)
  }

  if(barrier){
    spmd.barrier(comm = comm)
  }

  ret
} # End of task.pull().

