#!/bin/sh

# delay in keystrokes is to avoid missing keys in some rare cases
if [ -n "$WAYLAND_DISPLAY" ]; then
  sleep 0.5
  wtype -d 50 "`secret-tool lookup "$@"`"
else
  activeWindow="`xdotool getactivewindow 2>/dev/null`"
  sleep 0.5
  if [ -n "$activeWindow" ]; then
    xdotool type --delay 50 --window "$activeWindow" "`secret-tool lookup "$@"`"
    #xdotool windowactivate "$activeWindow"
  else
    xdotool type --delay 50 "`secret-tool lookup "$@"`"
  fi
fi
