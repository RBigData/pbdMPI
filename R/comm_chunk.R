#' comm.chunk
#'
#' Given a total number of items, N, comm.chunk splits the number into
#' chunks. Tailored especially for situations in SPMD style
#' programming, potentially returning different results to each rank.
#' Optionally, results for all ranks can be returned to all.
#'
#' Various chunking options are possible when the number does not
#' split evenly into equal chunks. The output form can be a number,
#' a vector of items, or a few other special forms intended for pbdR components.
#'
#' @param N
#' The number of items to split into chunks.
#' @param form
#' Output a chunk as a single "number", as a "vector" of items from 1:N,
#' or as an "iopair" giving offset and length in a file. Forms "ldim" and
#' "bldim" are available only with type "equal" and are intended for setting
#' "ddmatrix" (see package pbdDMAT) slots.
#' @param type
#' Either "balance" the chunks so they differ by no more than 1 item (used most
#' frequently for best balance) or force as many as possible to be "equal" with
#' possibly one or more smaller or even zero size chunks (required by ScaLAPACK's
#' block-cyclic layouts).
#' @param lo.side
#' If exact balance is not possible, put the smaller chunks on the "left" (low
#' ranks) or on the "right" (high ranks).
#' @param all.rank
#' FALSE returns only the chunk for rank r. TRUE returns a vector of
#' length p (when form="number"), and a list of length p (when form="vector")
#' each containing the output for the corresponding rank.
#' @param p
#' The number of chunks (processors). Normally, it is NOT specified and defaults
#' to NULL, which assigns comm.size(comm). 
#' @param rank
#' The rank of returned chunk. Normally, it is NOT specified and defaults to
#' NULL, which assigns comm.rank(comm)). Note that ranks are numbered from 0 to
#' p-1, whereas the list elements for all.rank=TRUE are numbered 1 to p.
#'
#' @return
#' A numeric value from 0:N or a vector giving a subset of 1:N (depending on
#' form) for the rank. If all.rank is TRUE, a vector or a list of
#' vectors, respectively.
#'
#' @examples
#' \dontrun{
#' ## Note that the p and rank parameters are provided by comm.size() and
#' ## comm.rank(), respectively, when running SPMD in parallel. Normally, they
#' ## are not specified unless testing in serial mode.
#' library(pbdIO)
#'
#' comm.chunk(16, all.rank = TRUE, p = 5)
#' comm.chunk(16, type = "equal", all.rank = TRUE, p = 5)
#' comm.chunk(16, type = "equal", lo.side = "left", all.rank = TRUE, p = 5)
#' comm.chunk(16, p = 5, rank = 0)
#' comm.chunk(16, p = 5, lo.side = "left", rank = 0)
#' }
#'
#' @export
comm.chunk = function(N, form="number", type="balance", lo.side="right",
                      all.rank=FALSE, p = NULL, rank = NULL,
                      comm = .pbd_env$SPMD.CT$comm) {
  
  ## Normally, these are input NULL and assigned from comm
  if(is.null(p)) p = comm.size(comm)
  if(is.null(rank)) rank = comm.rank(comm)
  
  form = comm.match.arg(form, c("number", "vector", "iopair", "ldim", "bldim"),
                        comm = comm)
  type = comm.match.arg(type, c("balance", "equal", "cycle"), comm = comm)
  lo.side = comm.match.arg(lo.side, c("right", "left"), comm = comm)
  if (!is.logical(all.rank) || length(all.rank) != 1 || is.na(all.rank))
    comm.stop("argument 'all.rank' must be a bool")
  if (!is.numeric(p) || p < 1)
    comm.stop("argument 'p' must be a positive integer")
  if (!is.numeric(rank) || rank < 0 || rank >= p)
    comm.stop("argument 'rank' must be an integer from 0 to p-1")
  if (form == "ldim" | form == "bldim") {
    if(type != "equal")
      comm.stop(paste0("form ", form, " only available for type 'equal'"))
  }
  if(type == "cycle" & form == "number")
    comm.stop("type 'cycle' only available with form 'vector'")
  
  base = N %/% p
  rem = N - base*p
  items = rep(base, p)
  
  ## if distributing among less than comm.size() pad with 0
  if(p < comm.size(comm)) items = c(items, rep(0, comm.size(comm) - p))
  
  ## options differ only if remainder! Makes adjustments for remainder.
  if(rem) {
    if(type == "balance" | type == "cycle") {
      if(lo.side == "right") {
        items[1:rem] = base + 1
      } else if(lo.side == "left") {
        items[(p - rem + 1):p] = base + 1
      }
    } else if(type == "equal") {
      items = items + 1
      rem = p*(base + 1) - N
      if(lo.side == "right") {
        i = p
        increment = -1
      } else if(lo.side == "left") {
        i = 1
        increment = 1
      }
      while(rem) {
        if(rem > base) {
          items[i] = 0
          rem = rem - base - 1
        } else {
          items[i] = items[i] - rem
          rem = 0
        }
        i = i + increment
      }
    }
  }
  
  ## check if all allocated
  if(sum(items) != N) cat("warning: comm.chunk rank", comm.rank(comm),
                          "split does not add up!\n")
  
  ## now output in correct form
  if(form == "number" | form == "ldim") {
    if(all.rank) ret = items
    else ret = items[rank + 1]
  } else if(form == "bldim") {
    items = rep(max(items), length(items))
    if(all.rank) ret = items
    else ret = items[rank + 1]
  } else if(form == "vector") {
    if(type == "cycle") {
      if(all.rank) {
        ret = lapply(1:length(items), function(i) seq(i, N, p))
      } else ret = if(rank < N) seq(rank + 1, N, p) else NULL
    } else {
      items_base = c(0, cumsum(items)[-p])
      if(all.rank) {
        ret = lapply(1:length(items_base),
                     function(i) lapply(items, seq_len)[[i]] +
                       items_base[i])
      } else ret = items_base[rank + 1] + seq_len(items[rank + 1])
    }
  } else if(form == "iopair") {
    offset = c(0, cumsum(items)[-p])
    ret = c(offset[rank + 1], items[rank + 1])
  } else ret = NULL
  ret
}
