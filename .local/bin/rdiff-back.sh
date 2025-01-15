#!/bin/bash -e

[ "$#" -ne 1 ] && { echo "Usage: $0 <backup destination>"; exit 1; }

if ping -q -c 1 8.8.8.8 >/dev/null || ping -q -c 1 8.8.4.4 >/dev/null; then
  borgmatic-setup.sh
  rdiff_common_args="--api-version 201 --ssh-compression -v4"
  rdiff-backup $rdiff_common_args backup --print-statistics --include-globbing-filelist \
    "$HOME/.config/rdiff-back-includes.list" / "$1"
  rdiff-backup $rdiff_common_args remove increments --older-than 8D "$1"
fi
