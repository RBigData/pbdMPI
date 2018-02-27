# pbdMPI

* **Version:** 0.3-4
* **License:** [![License](http://img.shields.io/badge/license-MPL%202-orange.svg?style=flat)](https://www.mozilla.org/MPL/2.0/)
* **Download:** [![Download](http://cranlogs.r-pkg.org/badges/pbdMPI)](https://cran.r-project.org/package=pbdMPI)
* **Status:** [![Build Status](https://travis-ci.org/snoweye/pbdMPI.png)](https://travis-ci.org/snoweye/pbdMPI) [![Appveyor Build status](https://ci.appveyor.com/api/projects/status/32r7s2skrgm9ubva?svg=true)](https://ci.appveyor.com/project/snoweye/pbdMPI)
* **Author:** See section below.


With few exceptions (ff, bigalgebra, etc.), R does computations in memory.
When data becomes too large to handle in the memory of a single node, or
when more processors than those offered in commodity hardware (~16) are needed
for a job, a typical strategy is to add more nodes.  MPI, or the
"Message Passing Interface", is the standard for managing multi-node
communication.  pbdMPI is a package that greatly simplifies the use of MPI from
R.

In pbdMPI, we make extensive use of R's S4 system to simplify the interface
significantly.  Instead of needing to specify the type (e.g., integer or double)
of the data via function name (as in C implementations) or in an argument (as 
in Rmpi), you need only call the generic function on your data and we will 
always "do the right thing".

In pbdMPI, we write programs in the "Single Program/Multiple Data" or SPMD
style.  Contrary to the way much of the R world is aquainted with parallelism,
there is no "master" or "manager".  Each process (MPI rank) gets runs the same
copy of the program as every other process, but operates on its own data.  This
is arguably one of the simplest extensions of serial to massively parallel
programming, and has been the standard way of doing things in the HPC community
for over 20 years.



## Usage

If you are comfortable with MPI concepts, you should find pbdMPI very agreeable
and simple to use.  Below is a basic "hello world" program:

```r
# load the package
suppressMessages(library(pbdMPI, quietly = TRUE))

# initialize the MPI communicators
init()

# Hello world
message <- paste("Hello from rank", comm.rank(), "of", comm.size())
comm.print(message, all.rank=TRUE, quiet=TRUE)

# shut down the communicators and exit
finalize()
```

Save this as, say, `mpi_hello_world.r` and run it via:

```
mpirun -np 4 Rscript mpi_hello_world.r
```

The function `comm.print()` is a "sugar" function custom to pbdMPI that makes it
simple to print in a distributed environment.  The argument `all.rank=TRUE`
specifies that all MPI ranks should print, and the `quiet=TRUE` argument
tells each rank not to "announce" itself when it does its printing.

Numerous other examples can be found in both the
[pbdMPI vignette](https://cran.r-project.org/package=pbdMPI)
as well as the [pbdDEMO package](https://github.com/RBigData/pbdDEMO)
and its corresponding [vignette](https://cran.r-project.org/package=pbdDEMO).



## Installation

pbdMPI requires
* R version 3.0.0 or higher
* A system installation of MPI:
  - SUN HPC 8.2.1 (OpenMPI) for Solaris.
  - OpenMPI for Linux.
  - OpenMPI for Mac OS X.
  - MS-MPI for Windows.

The package can be installed from the CRAN via the usual
`install.packages("pbdMPI")`, or via the devtools package:

```r
library(devtools)
install_github("RBigData/pbdMPI")
```

For additional installation information, see: 
  - see "INSTALL" for Solaris, Linux and Mac OS.
  - see "INSTALL.win.*" for Windows.


More information about pbdMPI, including installation troubleshooting,
can be found in:

1. pbdMPI vignette at 'pbdMPI/inst/doc/pbdMPI-guide.pdf'.
2. 'http://r-pbd.org/'.



## Authors

pbdMPI is authored and maintained by the pbdR core team:
* Wei-Chen Chen
* George Ostrouchov
* Drew Schmidt
* Pragneshkumar Patel

With additional contributions from:
* Hao Yu
* Christian Heckendorf
* Brian Ripley (Windows HPC Pack 2012)
* The R Core team (some functions are modified from the base packages)

