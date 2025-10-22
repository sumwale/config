#!/bin/sh

set -e

if [ "$DESKTOP_SESSION" = plasma ]; then
  ws_znum="`qdbus6 org.kde.KWin /KWin currentDesktop`"
else
  ws_znum="`wmctrl -d | awk '{ if ($2 == "*") print $1 }'`"
  ws_znum="`expr "$ws_znum" + 1 2>/dev/null`"
fi
if [ -n "$ws_znum" ]; then
  if type ydotool 2>/dev/null >/dev/null; then
    input_key_num="`expr "$ws_znum" + 1 2>/dev/null`"
    # simulate <Alt>+{num} keypress (somehow single cmd with -d does not work reliably)
    if [ -n "$input_key_num" ]; then
      ydotool key 56:1 && sleep 0.5 && \
        ydotool key -d 50 $input_key_num:1 $input_key_num:0 56:0
    fi
  else
    input_key_num="`expr "$ws_znum" + 1 2>/dev/null`"
    if [ -n "$input_key_num" ]; then
      xdotool key --clearmodifiers --delay 100 "alt+$input_key_num"
    fi
  fi
fi
