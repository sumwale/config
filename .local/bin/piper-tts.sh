#!/bin/bash -e

VOICE_PATH="$HOME/software/piper-tts"

if [[ ${VOICE: -3} = low ]]; then
  ADJ_RATE=16000
else
  ADJ_RATE=22050
fi
if [[ ${#RATE} -gt 3 ]]; then
  ADJ_RATE=$((${RATE::-3} * 30 + $ADJ_RATE))
fi
mkdir -p "$VOICE_PATH"
echo "$DATA" | piper --model $VOICE_PATH/$VOICE.onnx  --output-raw | \
  aplay -q -r $ADJ_RATE -f S16_LE -t raw -

wait
