#!/bin/sh

FILES=./*.r
NP=2

for f in $FILES
do
  # f_out=`echo $f | sed "s/demo_/time_/" | sed "s/\.r/\.txt/"`
  
  echo ">> Test $f"
  # echo "> mpirun -np $NP Rscript --vanilla $f" > $f_out
  # mpiexec -np $NP Rscript --vanilla $f >> $f_out
  mpiexec -np $NP Rscript --vanilla $f
  echo "=============================="
done
