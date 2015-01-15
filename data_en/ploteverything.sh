#!/bin/bash
#
# plots everything in this directory

./plotbedeckung.sh
./plotmemory.sh
./plotruntime.sh
./plotworkers.sh

./maxsizeplot.py
./runtimeplot.py
#./Si_rdfplot.py
./densityplot.py
