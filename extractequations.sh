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

envs='equation\|gather\|align'

getequations(){
    sed -n '/\\begin{\('$envs'\)}/,/\\end{\('$envs'\)}/p;/\$/p' *.tex \
        | sed -r -e 's/[^$]*\$([^$]*)\$[^$]*/\\begin{equation}\n\1\n\\end{equation}\n/g' \
        | sed -e '/#/d' -e 's/^\s*(\\q?quad)?\s*//' -e '/^$/d'
}

preparetexcode(){
    cat <<EOF
\documentclass{scrreprt}

\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage[range-phrase={\,bis\,},binary-units,retain-explicit-plus]{siunitx}

\begin{document}

`getequations`

\end{document}

EOF
}

compiletexfile(){
    mkdir -p equations
    preparetexcode | tee equations/equations.tex | pdflatex --output-directory equations/ --halt-on-error --
}

compiletexfile
#getequations
