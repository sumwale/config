#!/bin/sh

set -e

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

umask 022
if [ "$1" = "add" ]; then
  mkdir -p "$3"
  cp -a "$2" "$3"/`basename "$2"`
elif [ "$1" = "remove" ]; then
  rm -f "$3"/`basename "$2"`
fi
