#!/bin/sh

FILES=./*_par.r
NP=2

echo "=============================="

for f in $FILES
do
  echo ">> Test $f"
  Rscript --vanilla $f

  f=`echo $f | sed -e "s/_par.r$/_spmd.r/"`
  echo ">> Test $f"
  mpiexec -np $NP Rscript --vanilla $f

  echo "=============================="
done
