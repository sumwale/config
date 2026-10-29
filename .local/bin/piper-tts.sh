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

# for surround sound output, use sox to remap to 4 channels
if type -p sox > /dev/null && /usr/bin/pactl get-default-sink | grep -q surround-; then
  channel_map=$(/usr/bin/pactl get-default-sink | sed 's/^.*\(surround-[0-9]*\).*$/\1/')
  printf '%s' "$DATA" | sed -z 's/\\n/ /g' \
    | $PIPER -q -m "$VOICE_PATH/$VOICE.onnx" --output-raw \
    | sox -t raw -r $ADJ_RATE -e signed -b 16 -c 1 - -t raw -c 4 - \
    | /usr/bin/paplay --raw --rate=$ADJ_RATE --format=s16le --channels=4 --channel-map=$channel_map
else
  printf '%s' "$DATA" | sed -z 's/\\n/ /g' \
    | $PIPER -q -m "$VOICE_PATH/$VOICE.onnx" --output-raw \
    | /usr/bin/paplay --raw --rate=$ADJ_RATE --format=s16le --channels=1
fi
