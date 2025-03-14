#!/bin/sh

# Adapted from https://gist.github.com/vorstrelok/3b7a2b43c85e2b8b6cd3f81abe7a93fa

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin
DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/`id -u`/bus"
export PATH DBUS_SESSION_BUS_ADDRESS

keyctl watch @u | \
  while read -r from type key; do
    if [ "$key" = "`keyctl id %user:keepassxc:password`" ]; then
      for i in `seq 90`; do
        if dbus-send --session --print-reply --dest=org.keepassxc.KeePassXC.MainWindow /keepassxc org.keepassxc.KeePassXC.MainWindow.openDatabase string:.config/keepassxc/passwords.kdbx "string:`keyctl pipe "$key"`" string:.config/keepassxc/passwords.key 2>/dev/null; then
          keyctl revoke "$key"
          break
        fi
        sleep 1
      done
    fi
  done
