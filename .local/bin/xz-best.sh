#!/bin/sh

#7z a -txz -mx=9 -mmt=8 "$1.xz" "$1"
# below gives full CPU utilization
7z a -m0=lzma2 -mx=16 -mmt=on "$1.xz" "$1"
