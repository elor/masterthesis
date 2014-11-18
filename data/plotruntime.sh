#!/bin/bash
#
# Plot der Bedeckung der Oberfläche mit Workern

file="Parsivald"
func="Analytisch"

filter(){
    grep -Pv '/|102374|381588|10356031' | column -t
}

awk '{if ($8/2) {print $1,$6,$12,$6*0.026,$6*4.7/$8}}' parsivald_scalability.txt \
    | filter \
    | awk '{a=$4; if ($5>a) a=$5; print $1,$2,$3,a}' \
    | awk 'BEGIN {print "#size events runtime analytic"} {print $0}' | \
    { tee /dev/stderr | awk '{print $1,$2,$3}' | column -t > "$file"; } 2>&1 \
    | awk '{print $1,$2,$4}' | column -t > "$func"

./runtimedataplot.py -f -x2 -y3 --style='s' --xlog --ylog --xlabel 'Ereignisse' --ylabel 'Laufzeit (s)' "$func" "$file" || exit 1
#./runtimedataplot.py -f -x1 -y3 --style='s' --xlog --ylog --xrange 100:3e4 --xlabel 'Substratbreite (\AA)' --ylabel 'Laufzeit (s)' "$func" "$file" || exit 1

#--xrange 70:5e4 
# --yrange 100:3e5

mv -v plot.png runtime.png
mv -v plot.pdf runtime.pdf 
