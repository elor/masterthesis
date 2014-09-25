#!/bin/bash
#
# lists all words of every tex file in this folder

cat *.tex | sed -e 's/%.*$//' -e 's/\\[a-z]\+/ /g' -e 's/\[[^]]*\]/ /g' -e 's/[{][a-z_0-9:-]*[}]/ /g' -e 's/[^a-zA-Z_-:]/ /g' -e 's/\([a-z]\)[,.?:]\(\s\|$\)/\1 /g' | xargs -n1 | grep -v '^.$' | grep -v '_$' | grep -v '^_' | sort -u
