#!/bin/bash
#
# print the table of contents, according to texorder.sh

files=$(./texorder.sh) || exit 1

{
    grep -hP '^\\(chapter|section|subsection){' $files
} | {
    sed -r 's/\\texorpdfstring\{\$[^$]+\$\}\{(.*)\}/\1/g'
} | {
    sed 's/\}$//'
} | {
    sed 's/\\chapter{//' | awk 'BEGIN { c=0 } /^[^\\]/ { print c,$0; c+=1 } /^\\/ {print $0 }'
} | {
    sed 's/\\section{//' | awk '/^[0-9]+ / { c=$1; s=1; print $0 } /^[^\\0-9]/ { print c"."s,$0; s+=1 } /^\\/ {print $0 }'
} | {
    sed 's/\\subsection{//' | awk '/^[0-9]+\.[0-9]+ / { s=$1; u=1; print $0 } /^[^\\0-9]/ { print s"."u,$0; u+=1 } /^[0-9]+ / {print $0 }'
}
