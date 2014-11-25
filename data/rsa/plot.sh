#!/bin/bash
#
# grabs the results from the percolation files and 

mean='Mittelwert'
max='Maximum'

for f in *txt ; do
    [ -s "$f" ] || continue
    echo -n "$f "|grep -o '[0-9]\+'
    grep -v '#' $f | awk '{a+=$3; if ($3>b) {b=$3}} END {print a/NR,b}'
done | xargs -n3 | sort -n | column -t > results.txt

awk '{print $1,$2}' results.txt | column -t > "$mean"
awk '{print $1,$3}' results.txt | column -t > "$max"

dataplot.py --yrange 0:0.32 -f --xlabel 'Versuche' --ylabel 'Dichte' --xlog "$max" "$mean" || exit 1

mv -v plot.pdf rsa_maxdensity.pdf
mv -v plot.png rsa_maxdensity.png
