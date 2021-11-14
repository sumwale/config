#!/bin/sh -e

# Script that uses either xbacklight or light to set the screen brightness

if type xbacklight 2>/dev/null >/dev/null; then
  if [ -z "$1" ]; then
    exec xbacklight -get
  else
    exec xbacklight "$@"
  fi
else
  while [ -n "$1" ]; do
    case "$1" in
      -get) exec printf "%.0f\n" `light -G` ;;
      -steps) shift; shift ;;
      -time) shift; shift ;;
      -inc) exec light -A "$2" ;;
      -dec) exec light -U "$2" ;;
      -set) exec light -S "$2" ;;
      *) echo "Unexpected arguments: $@"; exit 1 ;;
    esac
  done
  exec light -G
fi
