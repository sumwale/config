#!/bin/sh

touchpad="SynPS/2 Synaptics TouchPad"
xinput set-prop "$touchpad" "libinput Tapping Enabled" 1
xinput set-prop "$touchpad" "libinput Natural Scrolling Enabled" 1
xinput set-prop "$touchpad" "libinput Disable While Typing Enabled" 1
( sleep 5 && xbacklight -set 60 ) &
#xgamma -gamma 0.90
