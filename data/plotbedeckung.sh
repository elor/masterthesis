#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

mean="Parsivald (Mittelwert)"
max="Parsivald (Maximum)"

filter(){
    grep -Pv '/|102374|381588|10356031' | column -t
}

awk '{print $1,$17,$6}' parsivald_scalability.txt | sed '1s/^/#/' | filter > "$mean"
awk '{print $1,$18,$6}' parsivald_scalability.txt | sed '1s/^/#/' | filter > "$max"

./bedeckungsplot.py -f --style 's' -x1 -y2 --xlog --ylog --xlabel 'Substratbreite (\AA)' --xrange 100:3e4 --yrange 0:1 --ylabel 'Workerdichte' "$max" "$mean" || exit 1

mv -v plot.png workerdichte.png
mv -v plot.pdf workerdichte.pdf 
