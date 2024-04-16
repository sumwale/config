#!/bin/sh

if [ "$1" = "temp" ]; then
  /usr/bin/sensors | sed -n 's/^Package id [0-9]*:[[:space:]]*+\?\([0-9\.]*\).*/\1/p' | head -n1
elif [ "$1" = "fan" ]; then
  /usr/bin/sensors | sed -n 's/^.*\(\b\|_\)fan[0-9:]*[[:space:]][^0-9]*\([0-9]\+[[:space:]]\+rpm\)\b.*/\2/pi' | head -n1
fi
