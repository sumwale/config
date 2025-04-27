#!/bin/sh

set -e

# Script that uses either brightnessctl or xbacklight to set the screen brightness

if type brightnessctl 2>/dev/null >/dev/null; then
  while [ -n "$1" ]; do
    case "$1" in
      -get) exec brightnessctl g ;;
      -steps) shift; shift ;;
      -time) shift; shift ;;
      -inc) exec brightnessctl -q s "$2%+" ;;
      -dec) exec brightnessctl -q s "$2%-" ;;
      -set) exec brightnessctl -q s "$2%" ;;
      *) echo "Unexpected arguments: $@"; exit 1 ;;
    esac
  done
  exec brightnessctl g
else
  if [ -z "$1" ]; then
    exec xbacklight -get
  else
    exec xbacklight "$@"
  fi
fi
