#!/bin/sh

if [ -z "$1" ]; then
  touchpad="`xinput list | sed -n 's/^.*touchpad.*id=\([[:digit:]]*\).*$/\1/ip' | head -n 1`"
else
  touchpad="$1"
fi

xinput set-prop "$touchpad" "libinput Tapping Enabled" 1
xinput set-prop "$touchpad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "$touchpad" "libinput Disable While Typing Enabled" 1

nohup /bin/sh -c "sleep 5 && xbacklight.sh -set 80" >/dev/null 2>/dev/null &
#xgamma -gamma 0.90
