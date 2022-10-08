library(pbdMPI)
## This script tests the ability of comm.chunk() to provide 
## all get.jid() settings.
## Run with: mpirun -np 4 Rscript comm_chunk_test.R
## Check other -np settings.
##

## Use comm.chunk() to provide get.jid() results. Formatting may differ.
jid2chunk = function(n, method, reduced, all, comm) {
  form = "vector"
  if(reduced) form = "seq"
  if(method == "block") {
    lo = "left"
    if(n < comm.size()) lo = "right"
    ret = comm.chunk(n, form = form, type = "balance", lo.side = lo, all.rank = all, comm = comm)
  } else if(method == "block0") {
    ret = comm.chunk(n, form = form, type = "balance", lo.side = "right", all.rank = all, comm = comm)
  } else if(method == "cycle") {
    ret = comm.chunk(n, form = form, type = "cycle", lo.side = "right", all.rank = all, comm = comm)
  }
  ret
}

## Convert an seq triple to a jid form of (from, to, by, length).
seq2reduced = function(x) { # trim seq form to jid reduced form
  vec = seq(x[1], x[2], x[3])
  x[1] = min(vec)
  x[2] = max(vec)
  if(length(vec) == 1) x[3] = 0
  x[4] = length(vec)
  x
}

get.jid2 = function(n, method = .pbd_env$SPMD.CT$divide.method[1],
                    all = FALSE,
                    comm = .pbd_env$SPMD.CT$comm, reduced = FALSE) {
  if(! method[1] %in% .pbd_env$SPMD.CT$divide.method) {
    stop("The method for dividing jobs is not found.")
  }
  
  ## Get comm.chunk result with jid options.
  ret = jid2chunk(n, method, reduced, all, comm)
  
  ## Reformat to jid list form if reduced
  if(reduced) {
    if(all) {
      ret = lapply(ret, function(x) {
        if(length(x) == 0 | x[1] > x[2]) {
          rt = list(start = integer(0), end = integer(0), by = 0, length = 0)
        } else {
          x = seq2reduced(x)
          rt = list(start = x[1], end = x[2], by = x[3], length = x[4])
        }
        rt
      })
    } else {
      if(length(ret) == 0 | ret[1] > ret[2]) {
        ret = list(start = integer(0), end = integer(0), by = 0, length = 0)
      } else {
        ret = seq2reduced(ret)
        ret = list(start = ret[1], end = ret[2], by = ret[3], length = ret[4])
      }
    }
  }
  ret
}


## check equivalence over many combinations
vars = list(method = c("cycle", "block", "block0"), # method
            reduced = c(TRUE, FALSE), # reduce
            all = c(TRUE, FALSE), # all
            n = 7:100) # n
comb = expand.grid(vars)

comm.cat(names(comb), "\n")

for(c in 1:nrow(comb)) {
  jid = get.jid(n = comb$n[c], method = comb$method[c], all = comb$all[c],
                reduced = comb$reduced[c])

  ## Sometimes jid returns NULL where comm.chunk returns integer(0).
  ## Replace the NULLs with integer(0).
  if(is.null(jid)) jid = integer(0)
  rep_null = function(x) { # recursive NULL replace with integer(0)
    if(is.null(x)) x = integer(0)
    if(is.list(x)) x = lapply(x, rep_null)
    x
  }                             
  if(is.list(jid)) jid = lapply(jid, rep_null)
  
  ## The above NULLs result in short all.ranks lists in get.jid.
  ## Extend them to comm.size().
  if(comb$all[c]) {
    if(is.list(jid) & length(jid) < comm.size()) 
      jid = c(jid, rep(list(integer(0)), comm.size() - length(jid)))
  }
  
  jid2 = get.jid2(n = comb$n[c], method = comb$method[c], all = comb$all[c],
                  reduced = comb$reduced[c])
  
  ## Check if results are all.equal(). Using identical() fails because typing
  ## as integer or as numeric varies with options.
  res = unlist(allgather(all.equal(jid, jid2)))
  comm.cat(unlist(comb[c, ]), res, "\n", quiet = TRUE)
  if(!all(class(res) == "logical") | !all(res)) {
    ## print results if not all.equal
    all.rank = FALSE
    if(!comb$all[c]) all.rank = TRUE
    comm.cat("jid: ")
    comm.cat(" ", class(jid), all.rank = all.rank, quiet = TRUE)
    comm.cat("\n")
    comm.print(jid, all.rank = all.rank)
    comm.cat("jid2:")
    comm.cat(" ", class(jid2), all.rank = all.rank, quiet = TRUE)
    comm.cat("\n")
    comm.print(jid2, all.rank = all.rank)
  }
}

finalize()