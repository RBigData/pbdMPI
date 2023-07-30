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
#' or as a "seq" three parameters `c(from, to, by)` of the base `seq()` function
#' (replaced deprecated "iopair" for offset and length in a file). Forms "ldim"
#' and "bldim" are available only with type "equal" and are intended for setting
#' "ddmatrix" (see package pbdDMAT) slots.
#' @param type
#' Is the primary load and location balance specification. The choices are:
#' "balance" the chunks so they differ by no more than 1 item (used most
#' frequently and default); "cycle" is the same as "balance" in terms of
#' load but differs on location in that chunks are not contiguous, rather are
#' assigned in a cycled way to ranks (note that "balance" and "cycle" are the
#' same if `form` is "number");  "equal" maximizes the number of same size
#' chunks resulting in one or more smaller or even zero size chunks carrying
#' the leftover (required by pbdDMAT block-cyclic layouts).
#' @param lo.side
#' If exact balance is not possible, put the smaller chunks on the "left" (low
#' ranks) or on the "right" (high ranks).
#' @param rng
#' If TRUE, engage the L'Ecuyere parallel random number generator from package
#' \pkg{rlecuyer}. This requires providing additional ... parameters `seed` and 
#' `diff` used by \code{\link{comm.set.seed()}}. `seed` is an integer and 
#' `diff` is a logical indicating whether the streams should be different. 
#' If `diff = TRUE` the `streams` parameter of \code{\link{set.stream.state}} 
#' is set to `N`, setting up `N` independent streams, each engaged with 
#' \code{\link{set.stream.state}}. This requires `form = "vector"` so that each 
#' rank knows which of the `N` streams it owns. Switch to stream `i` with
#' `set.stream.state(i)`, where `i` is a global index.
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
#' ## are not specified unless testing in serial mode (as in this example).
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
                      rng = FALSE, all.rank=FALSE, p = NULL, rank = NULL,
                      comm = .pbd_env$SPMD.CT$comm, ...) {
  xargs = list(...)
  
  ## Normally, these are input NULL and assigned from comm
  if(is.null(p)) p = comm.size(comm = comm)
  if(is.null(rank)) rank = comm.rank(comm = comm)
  
  ## Check arguments
  form = comm.match.arg(form, c("number", "vector", "seq", "ldim", "bldim"),
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
  if (type == "cycle" & lo.side == "left") {
      comm.stop(paste0("lo.side ", lo.side, " not available type 'cycle'"))
      ## due to last increment different from p (inconsistent)
  }
  if (rng) { # also set up parallel random number generation
    if(form == "vector") { # must be "vector"
      if(is.null(xargs$seed) || is.null(xargs$diff))
        comm.stop("Missing additional parameters seed or diff for rng")
      if(xargs$diff) { # expecting seed and diff additional args
        comm.set.seed(as.integer(xargs$seed), diff = TRUE, streams = N)
      } else comm.set.seed(as.integer(xargs$seed), diff = FALSE)
    } else comm.stop("rng.seed requires form == 'vector'")
  }
  
  ## compute base chunk sizes
  base = N %/% p
  rem = N - base*p
  items = rep(base, p)
  
  ## Option results differ only if remainder! Adjust for remainder.
  if(rem) {
    if(type == "balance" | type == "cycle") {
      if(lo.side == "right") {
        items[1:rem] = base + 1L
      } else if(lo.side == "left") {
        items[(p - rem + 1):p] = base + 1L
      }
    } else if(type == "equal") {
      items = items + 1L
      rem = p*(base + 1L) - N
      if(lo.side == "right") {
        i = p
        increment = -1L
      } else if(lo.side == "left") {
        i = 1
        increment = 1L
      }
      while(rem) {
        if(rem > base) {
          items[i] = 0L
          rem = rem - base - 1L
        } else {
          items[i] = items[i] - rem
          rem = 0L
        }
        i = i + increment
      }
    }
  }
  
  ## Check if all allocated. Uncomment for debugging:
  ## if(sum(items) != N) cat("warning: comm.chunk rank", comm.rank(comm),
  ##                         "chunks do not add up!\n")
  
  ## Chunk allocation done, now output items in correct form.
  ##
  ## A single number
  ##
  if(form == "number" | form == "ldim") {
    if(all.rank) ret = items
    else ret = items[rank + 1]
  ##
  ## The largest number to all
  ##
  } else if(form == "bldim") {
    if(all.rank) ret = rep(max(items), length(items))
    else ret = max(items)
  ##  
  ## As vector. Empty vectors are integer(0).
  ##
  } else if(form == "vector") {
    if(type == "cycle") {
      items_base = cumsum(items > 0)
      if(all.rank) {
        ret = lapply(1:length(items),
                     function(i) seq(from = items_base[i], by = p, 
                                     length.out = items[i]))
      } else ret = seq(from = items_base[rank + 1], by = p,
                       length.out = items[rank + 1])
    } else {
      items_base = c(0L, cumsum(items)[-p])
      if(all.rank) {
        ret = lapply(1:length(items_base),
                     function(i) lapply(items, seq_len)[[i]] +
                       items_base[i])
      } else ret = items_base[rank + 1] + seq_len(items[rank + 1])
    }
  ##  
  ## As seq parameters to generate the vector (always lo.side = "right").
  ##    Note: N<p returns from > to for the empty ranks (seq will error).
  ##
  } else if(form == "seq") {
    if(type == "cycle") {
      if(all.rank) {
        ret = lapply(1L:length(items), function(i) c(i, max(N, i + ((N - i)%/%p)*p), p))
      } else ret = if(rank < N) c(rank + 1L,
                                  max(N, rank + 1L + ((N - rank - 1L)%/%p)*p),
                                  p) else integer(0)
    } else {
      offset = c(0L, cumsum(items))
      if(all.rank) {
        ret = lapply(1L:length(items), function(i) c(offset[i] + 1L, 
                                                    offset[i + 1], 1L))
      } else {
        ret = c(offset[rank + 1] + 1L, offset[rank + 2], 1L)
      }
    }
  ##
  ##
  } else ret = NULL
  
  ret
}
