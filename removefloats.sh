#!/bin/bash
#
# remove all floats

floats="equation table align gather figure algorithm"

confirm(){
    [ -z "$USER" ] && { echo "cannot read \$USER environment variable">&2; return 1; }
    su -c 'which sed' $USER >/dev/null
}

removefloat(){
    local type=$1
    [ -z "$type" ] && return 1
    sed -i '/\\begin{'$type'}/,/\\end{'$type'}/ d' *.tex
}

removefloats(){
    for type in $floats; do
        removefloat $type
    done
}

echo "This script overwrites all .tex files in this directory. To continue, please confirm your password"
confirm || exit 1
#removefloats
