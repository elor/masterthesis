#!/bin/bash
#
# return an ordered list of included .tex files

depth=0

getmainfile(){
    local dir="$1"
    [ -z "$dir" ] && dir=.

    grep -l '\\documentclass' *.tex | head -1
}

getsubfiles(){
    local file="$1"

    sed 's/%.*$//' "$file" | grep -hPo '\\in(put|clude)\{[^}]*\}' | sed -r 's/\\in(put|clude)\{|}//g' | grep -v '\.pdf_tex$'
}

processfile(){
    local file="$1"
    [ -f "$file" ] || { echo "'$1' is not a file">&2; return; }
    [ -r "$file" ] || { echo "'$1' cannot be opened for reading">&2; return; }
    (( depth > 100 )) && { echo "maximum nesting depth reached"; return; }

    let depth++
    echo "$file"
    getsubfiles "$file" | while IFS= read subfile; do
        [ -n "$subfile" ] && processfile "$subfile.tex"
    done
    let depth--
}

input="$1"
[ -z "$input" ] && input=`getmainfile .`
[ -z "$input" ] && { echo "cannot find top-level file in the current directory (i.e. the one containing '\documentclass')">&2; exit; }

processfile "$input"
