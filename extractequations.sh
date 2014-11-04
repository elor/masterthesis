#!/bin/bash
#
# lists all words of every tex file in this folder

###############################################
# method:                                     #
# 1. extract the equation block               #
# 2. remove the opening and closing statement #
# 3. remove the label                         #
# 4. remove leading spaces                    #
###############################################

getequations(){
    sed -n '/\\begin{equation}/,/\\end{equation}/{/{equation}/!{/\\label{/!p}};/\$/p' *.tex | sed -r -e 's/[^$]*\$([^$]*)\$[^$]*/\1\n/g' | sed -e '/#/d' -e 's/^\s*(\\q?quad)?\s*//' -e '/^$/d'
}

formatequations(){
    getequations | uniq | sed -e 'i\\\\begin{equation}' -e 'a\\\\end{equation}'
}

preparetexcode(){
    cat <<EOF
\documentclass{scrreprt}

\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage[range-phrase={\,bis\,},binary-units,retain-explicit-plus]{siunitx}

\begin{document}

`formatequations`

\end{document}

EOF
}

compiletexfile(){
    mkdir -p equations
    preparetexcode | tee equations/equations.tex | pdflatex --output-directory equations/ --halt-on-error --
}

compiletexfile
#getequations
