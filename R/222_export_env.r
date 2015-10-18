### Export control to new env.
.pbdEnv <- new.env()
.pbdEnv$SPMD.CT <- SPMD.CT()
.pbdEnv$SPMD.OP <- SPMD.OP()
.pbdEnv$SPMD.IO <- SPMD.IO()
.pbdEnv$SPMD.TP <- SPMD.TP()

### For non-blocking calls.
.pbdEnv$SPMD.NB.BUFFER <- list()
