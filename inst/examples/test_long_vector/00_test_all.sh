#!/bin/sh

FILES=./*.r
NP=2

for f in $FILES
do
  echo ">> Test $f"
  mpiexec -np $NP Rscript --vanilla $f
  echo "=============================="
done
