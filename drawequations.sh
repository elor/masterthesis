#!/bin/bash
#
# from the extracted equations, takes every single one and draws it

rm -rf equations/each/*

ncpus=`grep proc /proc/cpuinfo | wc -l`
[ -z "$ncpus" ] && ncpus=8

checksums=""
index=1
createfile(){
    mkdir -p equations/each
    pushd equations/each || return
    cat <<EOF | sed -r 's/(begin|end)\{(equation|gather|align)/&*/' >  $index.tex
\documentclass{scrreprt}

\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage[range-phrase={\,bis\,},binary-units,retain-explicit-plus]{siunitx}
\usepackage[paperwidth=200pt,paperheight=100pt]{geometry}

\begin{document}

\pagenumbering{gobble}

$1

\end{document}

EOF

    local sum=`cat $index.tex | md5sum`
    if ! grep -q $sum <<< "$checksums"; then
        checksums="$checksums
$sum"
        
        while (( `jobs -rp | wc -l` >= $ncpus )) ; do sleep 0.1; done
        { pdflatex $index.tex && pdf2png.sh $index.pdf; } &
        
    fi
    popd
    let index++
}

equation=''

cat equations/equations.tex | while IFS= read -r line; do
    if [ -z "$equation" ]; then
        if grep -qP '\\begin\{(equation|gather|align)\}' <<< "$line"; then
            equation="$line"
            #        else
            #            echo "$line" doesnt match
        fi
    else
        equation="$equation
$line"

        if grep -qP '\\end\{(equation|gather|align)\}' <<< "$line"; then
            createfile "$equation"
            equation=''
        fi        
    fi
done

wait

echo "done"
