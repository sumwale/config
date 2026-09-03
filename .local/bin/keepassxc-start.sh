#!/bin/sh

set -e

PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.local/bin"
export PATH

while [ "`podman container inspect cachy-apps --format={{.State.Status}} 2>/dev/null`" != running ]; do
  sleep 1
done
sleep 1
exec keepassxc "$@"
