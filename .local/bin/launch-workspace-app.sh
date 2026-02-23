#!/bin/bash

set -e

if [ "$DESKTOP_SESSION" = plasma ] && type -p qdbus6 >/dev/null; then
  ws_znum=$(qdbus6 org.kde.KWin /KWin currentDesktop)
else
  ws_znum=$(wmctrl -d | awk '{ if ($2 == "*") print $1 }')
  if [ -z "$ws_znum" ]; then
    notify-send -i tools -u normal -t 2000 "Failed workspace app launch" \
      "Failed in launching workspace app due to unknown desktop"
    exit 1
  fi
  ((ws_znum++))
fi
notify-send -i tools -u normal -t 2000 "Launching workspace app" \
  "Launching workspace app for desktop $ws_znum"

if [ "$DESKTOP_SESSION" = plasma ] && type -p gtk-launch >/dev/null; then
  # ydotool/xdotool are not that reliable, so this path for KDE plasma reads the
  # task manager applet configuration and launches the application configured
  launchers=$(sed -n 's/^launchers=//p' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc")
  if [ -n "$launchers" ]; then
    IFS="," read -ra launcher_arr <<< "$launchers"
    launcher=$(echo "${launcher_arr[$((ws_znum - 1))]}" | sed 's/^applications://;s/\?.*$//')
    if [ -n "$launcher" ]; then
      exec gtk-launch "$launcher"
    fi
  fi
fi
if type -p ydotool >/dev/null; then
  input_key_num=$((ws_znum + 1))
  # simulate <Alt>+{num} keypress (somehow single cmd with -d does not work reliably)
  ydotool key 56:1 && sleep 0.5 && \
    ydotool key -d 80 $input_key_num:1 $input_key_num:0 56:0
else
  xdotool key --clearmodifiers --delay 100 "alt+$ws_znum"
fi
