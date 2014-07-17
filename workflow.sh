#!/bin/bash

setsid emacs masterthesis.tex &
setsid evince *.pdf &
latexrefre.sh

