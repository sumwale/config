#!/bin/sh

if rfkill 2>/dev/null | fgrep -q ' blocked'; then
  rfkill unblock all && echo disabled
else
  rfkill block all && echo enabled
fi
