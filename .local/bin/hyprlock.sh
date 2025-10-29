#!/bin/sh

set -e

DBUS_SEND_LOCK_ARGS="--system --print-reply --type=method_call --dest=org.freedesktop.login1 /org/freedesktop/login1/session/auto org.freedesktop.login1.Session.SetLockedHint"

dbus-send $DBUS_SEND_LOCK_ARGS boolean:true
dbus-send --session --print-reply --dest=org.keepassxc.KeePassXC.MainWindow /keepassxc org.keepassxc.KeePassXC.MainWindow.lockAllDatabases || /bin/true

hyprlock

dbus-send $DBUS_SEND_LOCK_ARGS boolean:false
