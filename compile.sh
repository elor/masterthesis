#!/bin/bash

pdflatex masterarbeit*.tex
bibtex masterarbeit*.tex
pdflatex masterarbeit*.tex
