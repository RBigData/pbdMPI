### Modified from Rserve/src/install.libs.R
### For libs
libsarch <- if (nzchar(R_ARCH)) paste("libs", R_ARCH, sep='') else "libs"
dest <- file.path(R_PACKAGE_DIR, libsarch)
files <- if (WINDOWS) "pbdMPI.dll" else c("pbdMPI.so", "pbdMPI.dylib")
files <- files[file.exists(files)]
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
file.copy(files, dest, overwrite = TRUE)
### For etc
etcarch <- if (nzchar(R_ARCH)) paste("etc", R_ARCH, sep='') else "etc"
dest <- file.path(R_PACKAGE_DIR, etcarch)
file <- "Makeconf"
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
file.copy(file, dest, overwrite = TRUE)
