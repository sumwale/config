#!/bin/bash -e

[ "$#" -ne 2 ] && { echo "Usage: $0 <source> <destination>"; exit 1; }

rsync -aAXHv --zc=zstd --zl=8 --exclude-from="$HOME/.config/rdiff-sync-excludes.list" "$1/." "$2/."
