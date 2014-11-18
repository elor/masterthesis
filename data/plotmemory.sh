#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

file="Parsivald"
filter(){
    grep -Pv '0$' | sed '1s/^/#/' | column -t
#    grep -Pv '/|102374|381588|10356031' | column -t
}

awk '{print $5,$19/1024}' parsivald_scalability.txt | filter | sort -n > "$file"

./memoryplot.py -f --style '^' --xlog --ylog --xlabel 'Atome' --xrange 1e5:3e9 --yrange 100:3e5 --ylabel 'RAM (MiB)' "$file" || exit 1

mv -v plot.png memory.png
mv -v plot.pdf memory.pdf 
