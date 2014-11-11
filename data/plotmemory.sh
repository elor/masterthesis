#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

file="Parsivald"
func="Analytisch"

awk '{print $5,$19/1024}' parsivald_scalability.txt  | grep -v ' 0$' | sed '1s/^/#/' | sort -n > "$file"
echo {1..9}{,0}{,0}{,0}{,0}{,0}{,0}{,0}{,0}{,0} | xargs -n1 | sort -nu | awk '{print $1,253+$1*94/1024/1024}' > "$func"

./memoryplot.py -f --xlog --ylog --xlabel 'Atome' --xrange 1e5:3e9 --yrange 100:3e5 --ylabel 'RAM (MiB)' "$func" "$file" || exit 1

mv -v plot.png memory.png
mv -v plot.pdf memory.pdf 
