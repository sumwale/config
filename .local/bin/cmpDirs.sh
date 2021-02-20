#!/bin/sh

if [ $# != 2 ]; then
  echo "Usage <script> <dir1> <dir2>"
fi

dir1=$1
dir2=$2
for f in `find $dir1 -type f`; do if [ ! -f `echo $f | sed "s,^$dir1,$dir2,"` ]; then echo "Missing file $f"; fi; done
