# This is a test script for pbdMPI
print("About to load pbdMPI")
library(pbdMPI)
print("Loaded pbdMPI")
sessionInfo()
print("Size and Rank")
print(comm.size())
print(comm.rank())
print("About to finalize pbdMPI")
# finalize()
print("NOT Finalized pbdMPI")
print("About to reload pbdMPI")

pkg <- as.package("pbdMPI")
if (is_attached(pkg)) {
  if (!quiet) {
    cli::cli_inform(c(i = "Reloading attached {.pkg {pkg$package}}"))
  }
  pkgload::unload(pkg$package)
  require(pkg$package, character.only = TRUE, quietly = TRUE)
}
else
if (is_loaded(pkg)) {
  if (!quiet) {
    cli::cli_inform(c(i = "Reloading loaded {.pkg {pkg$package}}"))
  }
  pkgload::unload(pkg$package)
  requireNamespace(pkg$package, quietly = TRUE)
}

print("Reloaded pbdMPI")
# test unloading of pbdMPI?
