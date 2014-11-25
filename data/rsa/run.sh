#!/bin/bash
#
#PBS -q default
#PBS -l nodes=1:ppn=16

for f in {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536}; do
    ./rsa.py $f > $f.txt &
done

wait
