### S3 tool function for writing.

comm.read.table <- function(file, header = FALSE, sep = "", quote = "\"'",
    dec = ".", col.names, 
    na.strings = "NA", colClasses = NA, nrows = -1, skip = 0,
    check.names = TRUE, fill = !blank.lines.skip, strip.white = FALSE,
    blank.lines.skip = TRUE, comment.char = "#", allowEscapes = FALSE,
    flush = FALSE,
    fileEncoding = "", encoding = "unknown", text,
    max.read.size = .SPMD.IO$max.read.size,
    read.method = .SPMD.IO$read.method,
    comm = .SPMD.CT$comm){
  # Read by method.
  ret <- NULL
  if(read.method[1] == "gbd"){
    ret <- read.table.gbd(
             file, header = header, sep = sep, quote = quote,
             dec = dec, col.names,
             na.strings = na.strings, colClasses = colClasses,
             nrows = nrows, skip = skip,
             check.names = check.names, fill = fill,
             strip.white = strip.white,
             blank.lines.skip = blank.lines.skip,
             comment.char = comment.char,
             allowEscapes = allowEscapes, flush = flush,
             fileEncoding = fileEncoding, encoding = encoding, text,
             max.read.size = max.read.size,
             comm = comm)
  } else if(read.method[1] == "common"){
    ret <- read.table.common(
             file, header = header, sep = sep, quote = quote,
             dec = dec, col.names,
             na.strings = na.strings, colClasses = colClasses,
             nrows = nrows, skip = skip,
             check.names = check.names, fill = fill,
             strip.white = strip.white,
             blank.lines.skip = blank.lines.skip,
             comment.char = comment.char,
             allowEscapes = allowEscapes, flush = flush,
             fileEncoding = fileEncoding, encoding = encoding, text,
             max.read.size = max.read.size,
             comm = comm)
  } else{
    comm.stop("read.method is undefined.")
  }

  attr(ret, 'read.method') <- read.method
  ret
} # End of comm.read.table().


read.table.gdb <- function(file, header = FALSE, sep = "",
    quote = "\"'", dec = ".", col.names,
    na.strings = "NA", colClasses = NA, nrows = -1, skip = 0,
    check.names = TRUE, fill = !blank.lines.skip, strip.white = FALSE,
    blank.lines.skip = TRUE, comment.char = "#", allowEscapes = FALSE,
    flush = FALSE,
    fileEncoding = "", encoding = "unknown", text,
    max.read.size = .SPMD.IO$max.read.size,
    comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm = comm)
  COMM.RANK <- spmd.comm.rank(comm = comm)

  ### All ranks should read from the same file.
  file.source <- spmd.bcast.object(file, comm = comm)
  if(comm.any(file != file.source)){
    comm.stop("All file should be the same, otherwise use read.table().")
  }

  # Find file size first.
  file.size <- 0.0
  if(COMM.RANK == 0){
    file.size <- as.double(file.info(file)$size)
  }
  file.size <- spmd.bcast.double(file.size, comm = comm)
  if(file.size > max.read.size){
    comm.cat("Caution: file size exceeds max.read.size.\n")
  }

  # Read start.
  if(comm.all(nrows == -1) && comm.all(skip == 0)){
    if(file.size < max.read.size){
      if(COMM.RANK == 0){
        tmp <- read.table(file, header = header, sep = sep, quote = quote,
                          dec = dec, col.names, as.is = TRUE,
                          na.strings = na.strings, colClasses = colClasses,
                          nrows = nrows, skip = skip,
                          check.names = check.names, fill = fill,
                          strip.white = strip.white,
                          blank.lines.skip = blank.lines.skip,
                          comment.char = comment.char,
                          allowEscapes = allowEscapes, flush = flush,
                          stringsAsFactors = FALSE,
                          fileEncoding = fileEncoding, encoding = encoding,
                          text)

        # Get divided indices.
        alljid <- get.jid(nrow(ret), all = TRUE)

        # Divide data into chunks in list format.
        ret <- rep(list(NULL), COMM.SIZE)
        for(i in 1:COMM.SIZE){
          if(! is.null(alljid[[i]])){
            ret[[i]] <- tmp[alljid[[i]],]
          } else{
            # Return an empty data.frame.
            ret[[i]] <- tmp[0,]
          }
        }
      }

      # Scatter chunks to other ranks.
      ret <- spmd.scatter.object(ret, comm = comm)
    } else{
      # Predict total lines.
      tl.pred <- 0L
      if(COMM.RANK == 0){
        tmp <- read.table(file, header = header, sep = sep, quote = quote,
                          dec = dec, col.names, as.is = TRUE,
                          na.strings = na.strings, colClasses = colClasses,
                          nrows = .SPMD.IO$max.test.lines, skip = skip,
                          check.names = check.names, fill = fill,
                          strip.white = strip.white,
                          blank.lines.skip = blank.lines.skip,
                          comment.char = comment.char,
                          allowEscapes = allowEscapes, flush = flush,
                          stringsAsFactors = FALSE,
                          fileEncoding = fileEncoding, encoding = encoding,
                          text)
        tl.pred <- floor(file.size / object.size(tmp) *
                         .SPMD.IO$max.test.lines)
      }
      tl.pred <- spmd.bcast.double(as.integer(tl.pred), comm = comm)
      jid <- get.jid(tl.pred)

      # Set the read start and how much to read.
      nrows <- length(jid)
      skip <- jid - 1
      if(COMM.RANK == (COMM.SIZE - 1)){
        # The last rank needs to read all of rest no matter what.
        nrows <- -1
      }

      # Read.
      for(i.rank in 0:(COMM.SIZE - 1)){
        if(COMM.RANK == i.rank){
          ret <- read.table(file, header = header, sep = sep, quote = quote,
                            dec = dec, col.names, as.is = TRUE,
                            na.strings = na.strings, colClasses = colClasses,
                            nrows = .SPMD.IO$max.test.lines, skip = skip,
                            check.names = check.names, fill = fill,
                            strip.white = strip.white,
                            blank.lines.skip = blank.lines.skip,
                            comment.char = comment.char,
                            allowEscapes = allowEscapes, flush = flush,
                            stringsAsFactors = FALSE,
                            fileEncoding = fileEncoding, encoding = encoding,
                            text)
        }
        spmd.barrier(comm = comm)
      }

      ret <- load.balance(ret, comm = comm)
    }
  } else{
    # Suppose nrows and skip are provided.
    comm.cat("Caution: nrows and skip are provided and rows may overlap.")

    for(i.rank in 0:(COMM.SIZE - 1)){
      if(i.rank == COMM.RANK){
        ret <- read.table(file, header = header, sep = sep, quote = quote,
                          dec = dec, col.names, as.is = TRUE,
                          na.strings = na.strings, colClasses = colClasses,
                          nrows = nrows, skip = skip,
                          check.names = check.names, fill = fill,
                          strip.white = strip.white,
                          blank.lines.skip = blank.lines.skip,
                          comment.char = comment.char,
                          allowEscapes = allowEscapes, flush = flush,
                          stringsAsFactors = FALSE,
                          fileEncoding = fileEncoding, encoding = encoding,
                          text)
      }
      spmd.barrier(comm = comm)
    }
  }

  # Sychronize colnames.
  colnames(ret) <- spmd.bcast.object(colnames(ret), comm = comm)

  ret
} # End of read.table.gbd().


read.table.common <- function(file, header = FALSE, sep = "",
    quote = "\"'", dec = ".", col.names,
    na.strings = "NA", colClasses = NA, nrows = -1, skip = 0,
    check.names = TRUE, fill = !blank.lines.skip, strip.white = FALSE,
    blank.lines.skip = TRUE, comment.char = "#", allowEscapes = FALSE,
    flush = FALSE,
    fileEncoding = "", encoding = "unknown", text,
    max.read.size = .SPMD.IO$max.read.size,
    comm = .SPMD.CT$comm){
  COMM.SIZE <- spmd.comm.size(comm = comm)
  COMM.RANK <- spmd.comm.rank(comm = comm)

  ### All ranks should read from the same file.
  file.source <- spmd.bcast.object(file, comm = comm)
  if(comm.any(file != file.source)){
    comm.stop("All file should be the same, otherwise use read.table().")
  }

  # Find file size first.
  file.size <- 0.0
  if(COMM.RANK == 0){
    file.size <- as.double(file.info(file)$size)
  }
  file.size <- spmd.bcast.double(file.size, comm = comm)
  if(file.size > max.read.size){
    comm.cat("Performance Warning: File size exceeds max.read.size.\n")
  }

  # Check nrows.
  nrows.source <- spmd.bcast.integer(as.integer(nrows), comm = comm)
  if(comm.any(nrows != nrows.source)){
    comm.stop("All nrows should be the same for read.method = common.")
  }

  # Check skip.
  skip.source <- spmd.bcast.integer(as.integer(skip), comm = comm)
  if(comm.any(skip != skip.source)){
    comm.stop("All skip should be the same for read.method = common.")
  }

  # Read start.
  if(file.size < max.read.size){
    # Ths file is small, so we read from rank 0 and bcast to all.
    if(COMM.RANK == 0){
      ret <- read.table(file, header = header, sep = sep, quote = quote,
                        dec = dec, col.names, as.is = TRUE,
                        na.strings = na.strings, colClasses = colClasses,
                        nrows = nrows, skip = skip,
                        check.names = check.names, fill = fill,
                        strip.white = strip.white,
                        blank.lines.skip = blank.lines.skip,
                        comment.char = comment.char,
                        allowEscapes = allowEscapes, flush = flush,
                        stringsAsFactors = FALSE,
                        fileEncoding = fileEncoding, encoding = encoding,
                        text)
    }
    ret <- spmd.bcast.object(ret, comm = comm)
  } else{
    # The file is too large to communicate across processors, so read it
    # sequentially. This will take very long to finish.
    for(i.rank in 0:(COMM.SIZE - 1)){
      if(i.rank == COMM.RANK){
        ret <- read.table(file, header = header, sep = sep, quote = quote,
                          dec = dec, col.names, as.is = TRUE,
                          na.strings = na.strings, colClasses = colClasses,
                          nrows = nrows, skip = skip,
                          check.names = check.names, fill = fill,
                          strip.white = strip.white,
                          blank.lines.skip = blank.lines.skip,
                          comment.char = comment.char,
                          allowEscapes = allowEscapes, flush = flush,
                          stringsAsFactors = FALSE,
                          fileEncoding = fileEncoding, encoding = encoding,
                          text)
      }
      spmd.barrier(comm = comm)
    }
  }

  ret
} # End of read.table.common().
