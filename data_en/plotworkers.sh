#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

mean="Parsivald (Mean)"
max="Parsivald (Max)"

filter(){
    grep -Pv '/|102374|381588|10356031' | sed '1s/^/#/'| column -t
}

awk '{print $1,$8,$6}' parsivald_scalability.txt  | filter > "$mean"
awk '{print $1,$9,$6}' parsivald_scalability.txt  | filter > "$max"

./workersplot.py -f --style 's' -x1 -y2 --xlog --ylog --xlabel 'Substrate Width (\AA)' --xrange 100:3e4 --yrange 1:400 --ylabel 'Processes $p$' "$max" "$mean" || exit 1

mv -v plot.png workers.png
mv -v plot.pdf workers.pdf
