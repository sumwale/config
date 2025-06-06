#!/bin/sh

set -e

sudo rsync -aHSA --info=progress2 --delete --zc=zstd --zl=6 "$1" "$2"
