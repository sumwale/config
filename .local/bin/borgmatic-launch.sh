#!/bin/bash

set -e

# simple script to launch borgmatic with given options using notify-send to show
# success/failure popups
#
# script assumes no spaces or weird characters in $USER and $HOME

# switch HOME and DBUS_SESSION_BUS_ADDRESS etc to the given user, if provided
if [ "$1" = "--user" ]; then
  shift
  export USER=$1
  shift
  export HOME=$(getent passwd $USER | cut -d: -f6)
  # notify-send won't work as root and has to be executed as the provided user
  do_sudo="sudo -E -u $USER"
fi

uid=$(id -u $USER)
export SSH_AUTH_SOCK=/run/user/$uid/keyring/ssh
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus
export PATH="$PATH:$HOME/.local/bin"
[ -e $HOME/.sh_env.local ] && source $HOME/.sh_env.local

if ! ping -q -c 1 8.8.8.8 >/dev/null && ! ping -q -c 1 8.8.4.4 >/dev/null; then
  echo -e '\033[31mAborting backup due to unreachable network\033[00m'
  $do_sudo notify-send -i document-save -u critical -t 0 "Backup aborted" "Network is unreachable"
  exit 1
fi

echo -e '\033[32mRunning pre-backup actions\033[00m'
borgmatic-setup.sh

start=$(date +'%s.%N')
$do_sudo notify-send -i document-save -u normal -t 10000 "Backup started" "Started on $(date +'%b %d %H:%M:%S'). Status can be seen with 'systemctl --user status borgmatic-backup.service'"

#if systemd-inhibit --who="borgmatic" --what="sleep:shutdown" --why="Prevent interrupting backup" borgmatic -c $HOME/.config/borgmatic/config.yaml "$@" check; then
if borgmatic -c $HOME/.config/borgmatic/config.yaml "$@" check; then
  end=$(date +'%s.%N')
  elapsed=$(bc -l <<< "scale=2; ($end - $start + 0.005) / 1")
  $do_sudo notify-send -i document-save -u normal -t 10000 "Backup finished" "Finished on $(date +'%b %d %H:%M:%S') in $elapsed secs. Detailed logs can be seen with 'journalctl -t borgmatic'"
else
  $do_sudo notify-send -i document-save -u critical -t 0 "Backup failed" "Check 'journalctl -t borgmatic' for details: $(journalctl -t borgmatic | tail -n5)"
  exit 1
fi
