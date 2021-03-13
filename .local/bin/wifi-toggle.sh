#!/bin/sh

if nmcli r wifi | fgrep -q enabled; then
  nmcli r wifi off && echo disabled
else
  nmcli r wifi on && echo enabled
fi
