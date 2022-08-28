#!/bin/sh

/bin/sleep 2
if /bin/systemctl -q is-active thinkfan; then
  echo Reloading thinkfan
  /usr/bin/pkill -x -usr2 thinkfan
else
  echo Restarting thinkfan
  tries=0
  while [ "$tries" -lt 15 ]; do
    if /bin/systemctl start thinkfan.service; then
      break
    else
      /bin/sleep 2
      tries="`/usr/bin/expr "$tries" + 1`"
    fi
  done
fi
