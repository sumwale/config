#!/bin/sh

. /usr/local/etc/powerlimit.conf

sleep 5
while true; do
  sh powerlimit.sh
  if [ "$RELOAD" = "false" ]; then
    exit 0
  fi
  sleep 10
done
