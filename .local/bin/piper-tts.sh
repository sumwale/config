#!/bin/bash

set -e

VOICE_PATH="$HOME/software/piper-tts"

if [[ ${VOICE: -3} = low ]]; then
  ADJ_RATE=16000
else
  ADJ_RATE=22050
fi
if [[ ${#RATE} -gt 3 ]]; then
  ADJ_RATE=$((${RATE::-3} * 30 + $ADJ_RATE))
fi
if type piper-tts 2>/dev/null >/dev/null; then
  PIPER=piper-tts
else
  PIPER=piper
fi

rawfile=$(mktemp)
trap '/bin/rm -f "$rawfile"' EXIT INT HUP TERM
printf '%s' "$DATA" | sed -z 's/\\n/ /g' \
  | $PIPER -q -m "$VOICE_PATH/$VOICE.onnx" --output-raw > "$rawfile"
/usr/bin/pw-play --rate=$ADJ_RATE --format=s16 --channel-map=LE --raw "$rawfile"
