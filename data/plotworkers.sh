#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

mean="Mittelwert"
max="Maximum"

#awk '{print $1,$8}' parsivald_scalability.txt  | grep -v / | sed '1s/^/#/' > "$mean"
#awk '{print $1,$9}' parsivald_scalability.txt  | grep -v / | sed '1s/^/#/' > "$max"

./bedeckungsplot.py -f --style 's' -x1 -y2 --xlog --ylog --xlabel 'Substratbreite (\AA)' --ylabel 'Parallele Prozesse' "$max" "$mean" || exit 1

mv -v plot.png workers.png
mv -v plot.pdf workers.pdf
