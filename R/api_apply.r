### These functions are supposed to run in SPMD, even when pbd.model = "mw".

pbdApply <- function(X, MARGIN, FUN, ..., pbd.mode = c("mw", "spmd"),
    rank.source = .SPMD.CT$rank.root, comm = .SPMD.CT$comm){
  if(is.character(MARGIN)){
    MARGIN <- match(MARGIN, dimnames(X))
  }

  if(length(MARGIN) == 1){
    ret <- pbdApply.RC(X, MARGIN, FUN, ..., pbd.mode = pbd.mode,
                       rank.source = rank.source, comm = comm)
  } else{
    ret <- pbdApply.general(X, MARGIN, FUN, ..., pbd.mode = pbd.mode,
                          rank.source = rank.source, comm = comm)
  }
} # End of pbdApply().

