#!/bin/bash
#
# from the extracted equations, takes every single one and draws it

index=1
createfile(){
    mkdir -p equations/each
    (
        cd equations/each
        cat <<EOF > $index.tex
\documentclass{scrreprt}

\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage[range-phrase={\,bis\,},binary-units,retain-explicit-plus]{siunitx}

\begin{document}

$1

\end{document}

EOF
        pdflatex $index.tex
        pdf2png.sh $index.pdf
    )

    let index++
}

equation=''

cat equations/equations.tex | while IFS= read -r line; do
    if [ -z "$equation" ]; then
        if grep -qP '\\begin\{(equation|gather|align)\}' <<< "$line"; then
            equation="$line"
            echo "$line" does match
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
