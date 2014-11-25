#!/bin/bash
#
# grabs the results from the percolation files and 

for f in percolation_*txt ; do
    [ -s "$f" ] || continue
    echo -n "$f "|grep -o '[0-9]\+'
    awk '{a+=$3} END {print a/NR}' $f
done | xargs -n2 | sort -n > results.txt

dataplot.py -f --xlog results.txt

mv plot.pdf maxdensity.pdf
mv plot.png maxdensity.png

