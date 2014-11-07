#!/bin/bash

# overkill, but it should work

pdflatex masterthesis.tex
pdflatex masterthesis.tex
bibtex masterthesis.tex
pdflatex masterthesis.tex
bibtex masterthesis.tex
pdflatex masterthesis.tex
