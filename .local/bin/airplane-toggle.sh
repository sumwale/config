#!/bin/sh

if [ -n "$1" ]; then
  devs="`rfkill 2>/dev/null | awk "/$1/"' { print $2 }'`"
  if rfkill 2>/dev/null | fgrep "$1" | fgrep -q ' blocked'; then
    rfkill unblock $devs && echo enabled
  else
    rfkill block $devs && echo disabled
  fi
elif rfkill 2>/dev/null | fgrep -q ' blocked'; then
  rfkill unblock all && echo disabled
else
  rfkill block all && echo enabled
fi
