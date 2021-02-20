#!/bin/sh

for f in */*.tar.gz; do
  (cd `dirname $f` && tar xfz `basename $f`)
done
