#!/bin/sh -e

# delay in keystrokes is to avoid missing keys in some rare cases
#if [ -n "$WAYLAND_DISPLAY" ]; then
  sleep 0.5
  ydotool type -d 10 "`secret-tool lookup "$@"`"
#else
#  activeWindow="`xdotool getactivewindow 2>/dev/null || /bin/true`"
#  sleep 0.5
#  if [ -n "$activeWindow" ]; then
#    xdotool type --delay 20 --window "$activeWindow" "`secret-tool lookup "$@"`"
#    #xdotool windowactivate "$activeWindow"
#  else
#    xdotool type --delay 20 "`secret-tool lookup "$@"`"
#  fi
#fi
