#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

listfiles(){
    find * -name '*.tex' -print0
}

listlonglines(){
    local maxchars=$1
    [ -z "$maxchars" ] && maxchars=300
    lines=$(
        listfiles|xargs -0n1 | while IFS= read file; do
            sed -r 's/\{[^{}]+(\{[^{}]*\}[^{}]*)*\}//g' $file | sed 's/\$[^$]\+\$//' | awk '{if (length > 20) print length}'
        done | sort -n | uniq -c | awk '{print $2,$1}'
    )
    [ -n "$lines" ] && echo -e "$lines"
}

listlonglines > linelengthhistogram.txt
dataplot.py -f --bar linelengthhistogram.txt
mv -v plot.pdf linelengthhistogram.pdf
mv -v plot.png linelengthhistogram.png
