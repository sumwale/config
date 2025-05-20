#!/bin/sh

set -e

in="$1"
out="$2"
shift
shift
/usr/bin/gpg --output "$out" --export-secret-keys --export-options export-backup "$@" "$in"
