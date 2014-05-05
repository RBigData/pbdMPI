#!/bin/sh

FILES=./*.r
NP=2

cat 01_setting
echo "=============================="

for f in $FILES
do
  echo ">> Test $f"
  mpiexec -np $NP Rscript --vanilla $f
  echo "=============================="
done
