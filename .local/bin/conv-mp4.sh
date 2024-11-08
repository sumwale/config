#!/bin/sh

[ "$#" -lt "2" ] && { echo "Usage: `basename "$0"` <input file> <output file>"; exit 1; }

#ffmpeg -threads 2 -i /Software/home/sumedh/Videos/Sapna-Rakhi-2007/capture2.avi -f mp4 -r 29.97 -vcodec libx264 -s 640x480 -b 1000kb -aspect 4:3 -flags +loop -cmp +chroma -deblockalpha 0 -deblockbeta 0 -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -refs 1 -bf 3 -coder 1 -me_method umh -me_range 16 -subq 7 -partitions +parti4x4+parti8x8+partp8x8+partb8x8 -g 250 -keyint_min 25 -level 30 -qmin 10 -qmax 51 -qcomp 0.6 -trellis 2 -sc_threshold 40 -i_qfactor 0.71 -acodec libfaac -ab 112kb -ar 48000 -ac 2 /Software/home/sumedh/Videos/capture2.mp4

#ffmpeg -threads 2 -i "$1" -f mp4 -vcodec libx264 -flags +loop -cmp +chroma -deblockalpha 0 -deblockbeta 0 -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -refs 1 -bf 3 -coder 1 -subq 7 -keyint_min 25 -level 30 -qmin 10 -qmax 51 -qcomp 0.6 -trellis 2 -sc_threshold 40 -acodec libfaac "$2"
#ffmpeg -threads 4 -i "$1" -f mp4 -vcodec libx264 -flags +loop -cmp +chroma -deblockalpha 0 -deblockbeta 0 -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -refs 1 -bf 3 -coder 1 -subq 7 -keyint_min 25 -level 30 -qmin 10 -qmax 51 -qcomp 0.6 -trellis 2 -sc_threshold 40 -acodec mp2 "$2"

FNAME="$1"
shift
#avconv -threads 4 -i "${FNAME}" -vcodec libx264 -flags loop -cmp chroma -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -refs 1 -bf 3 -coder 1 -subq 7 -keyint_min 25 -level 30 -qmin 10 -qmax 51 -qcomp 0.6 -trellis 2 -sc_threshold 40 -acodec mp3 "$@"
#avconv -threads 4 -i "${FNAME}" -vcodec libx264 -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -acodec mp3 "$@"
#ffmpeg -threads 8 -i "${FNAME}" -vcodec libx264 -b 1250k -maxrate 1500k -bufsize 4M -bt 256k -acodec mp3 "$@"
#ffmpeg -threads 12 -i "${FNAME}" -vcodec libx264 -b:v 2M -maxrate 2M -bufsize 4M -acodec mp3 "$@"
ffmpeg -i "${FNAME}" -c:a aac -c:v libx264 -crf 25 "$@"
