# pbdMPI

* **License:** [![License](http://img.shields.io/badge/license-MPL%202-orange.svg?style=flat)](https://www.mozilla.org/MPL/2.0/)
* **Download:** [![Download](http://cranlogs.r-pkg.org/badges/pbdMPI)](https://cran.r-project.org/package=pbdMPI)
* **Status:** [![Appveyor Build status](https://ci.appveyor.com/api/projects/status/32r7s2skrgm9ubva?svg=true)](https://ci.appveyor.com/project/snoweye/pbdMPI)
* **Author:** See section below.

This package provides a simplified, efficient, interface to MPI for HPC 
clusters. This derivation and rethinking of the Rmpi package embraces
the prevalent parallel programming style on HPC clusters. It is based on S4
classes and methods. 

If you don't have access to an HPC cluster, consider applying for an allocation
at an HPC facility in your country. For example,
[US ACCESS](https://access-ci.org/),
[US INCITE](https://science.osti.gov/ascr/Facilities/Accessing-ASCR-Facilities/INCITE/About-incite),
[EU PRACE](https://prace-ri.eu/),
[Czechia IT4I](https://www.it4i.cz/en/for-users/computing-resources-allocation),
[India NSM](https://nsmindia.in/),
[Japan HPCI](https://www.hpci-office.jp/for_users/procedure_project_start/start_representative), or
[Other Please contribute your country-specific information to add in this list.].
Applying for a startup allocation can be easier than most would expect,
sometimes as little as a paragraph describing your application and software.
Large allocations require a full proposal.

With few exceptions, R does computations in memory.
When data becomes too large to handle in the memory of a single node, or
when more processors than those offered in commodity hardware are needed
for a job, a typical strategy is to add more nodes.  MPI, or the
"Message Passing Interface", is the standard for managing multi-node
computing. pbdMPI is a package that greatly simplifies the use of MPI from
R.

In pbdMPI, we make extensive use of R's S4 system to simplify the interface.
Instead of needing to specify the type (e.g., integer or double)
of the data via function name (as in C implementations) or in an argument (as 
in Rmpi), you need only call the generic function on your data and we will 
always "do the right thing".

In pbdMPI, we write programs in the "Single Program/Multiple Data" or SPMD
style, which is the prevalent style on HPC clusters.  Contrary to the way much
of the R world is aquainted with parallelism, there is no "manager".  Each
process (MPI rank) runs the same program as every other process, but operates
on its own data or its own section of a global parameter space.  This
is arguably one of the simplest extensions of serial to massively parallel
programming, and has been the standard way of doing things in the large-scale 
HPC community for decades. The "single program" can be viewed as a 
generalization of the serial program.


## Installation

Installation with `install.packages("pbdMPI")` from CRAN or with
`remotes::install_github("RBigData/pbdMPI")` from GitHub works on systems with
MPI installed in a standard location. This is usually true on 
HPC Cluster Systems and also if you follow the 
Linux, MacOS, or Windows Notes below for MPI installation.


## Usage

If you are comfortable with MPI concepts, you should find pbdMPI very agreeable
and simple to use.  Below is a basic "hello world" program:

```r
# load the package and initialize MPI
suppressMessages(library(pbdMPI, quietly = TRUE))

# Hello world
message <- paste("Hello from rank", comm.rank(), "of", comm.size())
comm.print(message, all.rank = TRUE, quiet = TRUE)

# shut down the communicators and exit
finalize()
```

Save this as, say, `mpi_hello_world.r` and run it via:

```
mpirun -np 4 Rscript mpi_hello_world.r
```

The function `comm.print()` is a "sugar" function custom to pbdMPI that makes
it simple to print in a distributed environment.  The argument `all.rank = TRUE`
specifies that all MPI ranks should print, and the `quiet = TRUE` argument
tells each rank not to "announce" itself when it does its printing. This 
function and its companion `comm.cat()` automatically cooperate across the
parallel instances of the single program to control printing.

Numerous other examples can be found in both the
[pbdMPI vignette](https://cran.r-project.org/package=pbdMPI)
as well as the 
[pbdDEMO package](https://github.com/RBigData/pbdDEMO)
and its corresponding 
[vignette](https://cran.r-project.org/package=pbdDEMO). While these were written
for version 0.3-0 of pbdMPI, they are still highly relevant.


## HPC Cluster Systems Notes
HPC clusters are Linux systems and use [Environment
Modules](https://modules.readthedocs.io/en/latest/) to manage software. Consult
your local cluster documentation as specifics with respect to R and MPI can
differ. Usually, an MPI version is installed and should work with pbdMPI
standard install, although sometime a `module load openmpi` might be needed to
get OpenMPI.

Some common module commands are:
```sh
module list  # lists currently loaded software modules
module avail # lists available software modules
module load <module_name> # loads module <module_name>
```

Available R modules are typically loaded via `module load r` or 
`module load R`, possibly with directory and version information. On some
systems,
this needs to be preceded by selecting a programming environment, which may be
gnu, pgi, etc., while on others loading R automatically selects the correct
programming environment. Please consult your HPC cluster documentation.
Typically, software installations are done on login
nodes and parallel debugging and production runs on compute nodes. 

A resource manager, usually 
[Slurm](https://en.wikipedia.org/wiki/Slurm_Workload_Manager),
[PBS](https://en.wikipedia.org/wiki/Portable_Batch_System),
[LSF](https://en.wikipedia.org/wiki/IBM_Spectrum_LSF), or
[SGE](https://en.wikipedia.org/wiki/Oracle_Grid_Engine) is used to allocate
compute nodes for a job. Consult your cluster 
documentation, as defaults tend to be site-specific.

Scripts are usually submitted as batch jobs but interactive allocations are
possible too. For batch submission, we recommend writing a shell script. Here
we give a shell script example for Slurm and note that a 
[translation table](https://slurm.schedmd.com/rosetta.pdf)  is available to 
other resource managers.
```sh
#!/bin/bash
#SBATCH -J <my_job>
#SBATCH -A <my_account>
#SBATCH --nodes=4
#SBATCH --exclusive
#SBATCH -t 00:20:00
#SBATCH --mem=0

module load gcc
module load openmpi
module load r

mpirun --map-by ppr:4:node Rscript <your_r_script> 
```

This example runs asynchronously 16 copies (4 per node) of `<your_r_script>` in
separate R sessions, communicating with each other via OpenMPI. If 128 cores are
available on a node, further parallelism (32 per R session) is available for
shared-memory parallel approaches (such as `mclapply()` or multithreaded
libraries, like OpenBLAS, possibly via FlexiBLAS). The parameter `--exclusive`
requests exclusive access to all cores on the nodes, `--mem=0` requests all
memory, and `-t 00:20:00` asks for 20 minutes of time. Save this Slurm script in
a file `<your_script.sh>` and submit with `sbatch <your_script.sh>`. To quickly
troubleshoot a Slurm script at your location, replace `Rscript <your_r_script>`
with `hostname`.

  
## Linux Notes
See `INSTALL` file for details.


## Mac OS Notes

MacOS does not provide MPI, so first install a recent version of OpenMPI. This
is best done via [`Homebrew`](https://brew.sh/). Homebrew will automatically ask
to install Xcode Command Line Tools (CLT) if you have not yet done so (You don't
need all of Xcode, just the CLT), see [Homebrew
installation](https://docs.brew.sh/Installation). After installing Homebrew,
```sh
brew install openmpi
```
will install OpenMPI in a location that pbdMPI can find. Then, follow standard R
package installation for pbdMPI.

Parallelizing with distributed-memory concepts (like MPI) on shared-memory
platforms (like a single node or a laptop) does produce excellent speedups but
does not extend available memory for larger data objects. Chunking of larger
objects does not extend available memory but does prevent duplication of the
objects in memory when running several R sessions in shared memory of a laptop.


## Windows Notes

Windows does not provide MPI, so first an MPI installation (binary, header,
and libraries) is needed. We recommend installing 
[Microsoft MPI](https://learn.microsoft.com/en-us/message-passing-interface/microsoft-mpi)
which is based on MPICH.

Download MS-MPI v10.1.3 and SDK from the 
[Microsoft Download Center](https://learn.microsoft.com/en-us/message-passing-interface/microsoft-mpi#ms-mpi-downloads).
See `INSTALL` file for details and for the usage of `mpiexec.exe`.


## Authors

pbdMPI is authored and maintained by the pbdR core team:
* Wei-Chen Chen
* George Ostrouchov
* Drew Schmidt

With additional contributions from:
* Pragneshkumar Patel
* Hao Yu
* Christian Heckendorf
* Brian Ripley (Windows HPC Pack 2012)
* The R Core team (some functions are modified from the base packages)

