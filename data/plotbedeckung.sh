#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

mean="Mittelwerte"
max="Maxima"

#awk '{print $1,$17}' parsivald_scalability.txt  | grep -v / | sed '1s/^/#/' > "$mean"
#awk '{print $1,$18}' parsivald_scalability.txt  | grep -v / | sed '1s/^/#/' > "$max"

./bedeckungsplot.py -f --style 's' -x1 -y2 --xlog --ylog --xlabel 'Substratbreite (\AA)' --yrange 0:1 --ylabel 'Workerdichte (1)' "$max" "$mean" || exit 1

mv -v plot.png workerdichte.png
mv -v plot.pdf workerdichte.pdf 
