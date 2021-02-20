#!/bin/sh

[ "$#" -lt "2" ] && { echo "Usage: `basename "$0"` <input file> <output file>"; exit 1; }

#ffmpeg -threads 2 -i "$1" -f mp4 -vcodec libx264 -acodec libfaac "$2"
#ffmpeg -threads 4 -i "$1" -f mp4 -vcodec libx264 -acodec mp2 "$2"

FNAME="$1"
shift
#avconv -threads 4 -i "${FNAME}" -vcodec libx264 -acodec mp3 "$@"
ffmpeg -threads 12 -i "${FNAME}" -vcodec libx264 -acodec mp3 "$@"
