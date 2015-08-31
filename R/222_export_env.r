### Export control to new env.
.pbdMPIEnv <- new.env()
.pbdMPIEnv$SPMD.CT <- SPMD.CT()
.pbdMPIEnv$SPMD.OP <- SPMD.OP()
.pbdMPIEnv$SPMD.IO <- SPMD.IO()
.pbdMPIEnv$SPMD.TP <- SPMD.TP()

### For non-blocking calls.
.pbdMPIEnv$nb.buffer <- list()
