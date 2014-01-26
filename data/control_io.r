### IO control.

.SPMD.IO <- list(
  max.read.size = 5.2e6,                                 # 5 MB
  max.test.lines = 500,                                  # test lines
  read.method = c("gbd", "common"),                      # read methods
  balance.method = c("block", "block0", "block.cyclic")  # for gbd only
) # End of .SPMD.IO.

