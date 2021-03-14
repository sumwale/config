#!/bin/sh

scriptName="`basename "$0"`"

if [ "$1" = "-h" -o "$1" = "--help" -o -z "$1" ]; then
  echo "$scriptName [--microphone] ([+|-]<PERCENT>|<INTEGER>|<INTEGER>dB)|toggle|mute|unmute"
  echo
  exit 0
fi

if [ "$1" = "--microphone" ]; then
  shift
  DEV=microphone
  PA_DEV=@DEFAULT_SOURCE@
  PA_CMD_PART=source
  ALSA_DEV=Capture
  MAX_PCT=100
else
  DEV=speaker
  PA_DEV=@DEFAULT_SINK@
  PA_CMD_PART=sink
  ALSA_DEV=Master
  MAX_PCT=150
fi

case "$1" in
  toggle)
    PA_CMD=set-$PA_CMD_PART-mute
    PA_ARGS=toggle
    MAX_PCT=
    ;;
  mute)
    PA_CMD=set-$PA_CMD_PART-mute
    PA_ARGS=1
    MAX_PCT=
    ;;
  unmute)
    PA_CMD=set-$PA_CMD_PART-mute
    PA_ARGS=0
    MAX_PCT=
    ;;
  *)
    PA_CMD=set-$PA_CMD_PART-volume
    PA_ARGS="$@"
    ;;
esac

# Change the volume using pulse
pactl $PA_CMD $PA_DEV $PA_ARGS

# Query amixer for the current volume and whether or not the speaker is muted
query_mixer() {
  state="`amixer -D pulse get $ALSA_DEV | tail -1`"
  volume="`echo $state | sed -n 's/.*\[\([0-9]\+\)%\].*/\1/gp'`"
  mute="`echo $state | sed -n 's/.*\[\([a-z]\+\)\].*/\1/gp'`"
}

query_mixer

if [ -n "$MAX_PCT" ]; then
  if [ $volume -gt $MAX_PCT ]; then
    # reduce volume back to MAX_PCT
    pactl $PA_CMD $PA_DEV ${MAX_PCT}%
    query_mixer
  fi
fi

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "$scriptName"

echo $DEV $volume $mute
