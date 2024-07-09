#!/bin/sh -e

ws_znum="`wmctrl -d | awk '{ if ($2 == "*") print $1 }'`"
if [ -n "$ws_znum" ]; then
  input_key_num="`expr "$ws_znum" + 2 2>/dev/null`"
  if [ -n "$input_key_num" ]; then
    # simulate <Alt>+{num} keypress (somehow single cmd with -d does not work reliably)
    ydotool key 56:1 && sleep 0.5 && \
      ydotool key -d 50 $input_key_num:1 $input_key_num:0 56:0
  fi
fi
