#!/bin/sh

set -e

# search utilities in only the standard paths
export PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin"

VOICE_PATH="$HOME/software/piper-tts"
[ -f "$VOICE_PATH/$VOICE.onnx" ] || { echo "$0: voice $VOICE not found" >&2; exit 1; }

# kill whole process group
trap "trap - INT TERM; kill 0" INT TERM

process_text() {
  printf '%s' "$DATA" | sed -zE 's/\\n/ /g; s/([.!?])[[:space:]]+/\1\n/g'
}

AWK=awk
PIPER=piper
PIPE_SZ="pipesz --fd 0 --set 1M --"
command -v mawk >/dev/null 2>&1 && AWK=mawk
command -v piper-tts >/dev/null 2>&1 && PIPER=piper-tts

ADJ_RATE=$(sed -n 's/.*"sample_rate": *\([0-9]\+\).*/\1/p' "$VOICE_PATH/$VOICE.onnx.json" 2>/dev/null | head -n1)
: "${ADJ_RATE:=22050}"
LS=$($AWK -v RATE="$RATE" 'BEGIN { \
  if (RATE != RATE + 0) exit 1; printf "%.3f", exp(-RATE / 100 * log(2)) }') || LS=1

# for surround sound output, use sox to remap to required channels
if command -v sox >/dev/null 2>&1 && surround_type=$(pactl get-default-sink | \
    sed -n 's/^.*surround-\([0-9]\+\).*$/\1/p;tx;q1;:x'); then
  cmap="surround-$surround_type"
  case "$surround_type" in
    21) nch=3 ;;
    40) nch=4 ;;
    41|50) nch=5 ;;
    51) nch=6 ;;
    71) nch=8 ;;
    *) nch=2; cmap=stereo ;;
  esac
  process_text \
    | $PIPER -q -m "$VOICE_PATH/$VOICE.onnx" --length_scale "$LS" --output-raw \
    | $PIPE_SZ sox -q -t raw -r $ADJ_RATE -e signed -b 16 -c 1 - -t raw -e signed -b 16 -c $nch - \
    | $PIPE_SZ pw-play --raw --rate=$ADJ_RATE --format=s16 --channels=$nch --channel-map=$cmap -
else
  process_text \
    | $PIPER -q -m "$VOICE_PATH/$VOICE.onnx" --length_scale "$LS" --output-raw \
    | $PIPE_SZ pw-play --raw --rate=$ADJ_RATE --format=s16 --channels=1 -
fi
