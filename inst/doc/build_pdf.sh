#!/bin/sh

rm *.aux *.bbl *.blg *.log *.out *.toc
pdflatex pbdMPI-guide.Rnw
bibtex pbdMPI-guide
pdflatex pbdMPI-guide.Rnw
pdflatex pbdMPI-guide.Rnw
pdflatex pbdMPI-guide.Rnw
rm *.aux *.bbl *.blg *.log *.out *.toc
