#!/bin/bash

INTERVAL=28800
STAMP_FILE_NAME=.update-notifier.sh.stamp
STAMP_FILE="$HOME/$STAMP_FILE_NAME"
APT_SYSTEM=

if [ -x /usr/lib/update-notifier/apt-check ]; then
  APT_SYSTEM=1
  if ! type update-manager 2>/dev/null >/dev/null; then
    echo "update-manager not available"
    exit 1
  fi
  if ! type notify-send 2>/dev/null >/dev/null; then
    echo "notify-send not available"
    exit 1
  fi
else
  if ! type pamac 2>/dev/null >/dev/null; then
    echo "pamac not available"
    exit 1
  fi
  if ! type dunstify 2>/dev/null >/dev/null; then
    echo "dunstify not available"
    exit 1
  fi
fi

force=false

show_help() {
  echo "$(basename "$0") [--interval=<SECS> | --session=<SESSION> | --no-session=<SESSION> | --force | --help]"
  echo
  echo "--interval=<SECS>      run only if at least <SECS> seconds have elapsed since last"
  echo "                       successful run as noted in $STAMP_FILE_NAME in user's HOME"
  echo "                       (default is 28800 i.e. 8 hours)"
  echo "--session=<SESSION>    run only if \$DESKTOP_SESSION equals <SESSION>"
  echo "--no-session=<SESSION> skip if \$DESKTOP_SESSION equals <SESSION>"
  echo "--force                force the run ignoring when the last run was successful"
  echo "--help                 this message"
  echo
}

for arg in "$@"; do
  case "$arg" in
    --interval=*)
      INTERVAL="$(echo $arg | sed 's/--interval=//')"
      ;;
    --session=*)
      session="$(echo $arg | sed 's/--session=//')"
      if [ "$DESKTOP_SESSION" != "$session" ]; then
        echo "Skipping updates for DESKTOP_SESSION=$DESKTOP_SESSION"
        exit 0
      fi
      ;;
    --no-session=*)
      session="$(echo $arg | sed 's/--no-session=//')"
      if [ "$DESKTOP_SESSION" = "$session" ]; then
        echo "Skipping updates for DESKTOP_SESSION=$DESKTOP_SESSION"
        exit 0
      fi
      ;;
    --force)
      force=true
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $arg"
      echo
      show_help
      exit 1
      ;;
  esac
done

# check if INTERVAL seconds have elapsed since the last check
current_time=$(date "+%s")
if [ "$force" != "true" -a -r "$STAMP_FILE" ]; then
  elapsed=$(expr $current_time "-" $(cat "$STAMP_FILE") 2>/dev/null)
  if [ -n "$elapsed" -a $elapsed -lt $INTERVAL ]; then
    echo "Elapsed ${elapsed}s less than ${INTERVAL}s, updates check skipped."
    exit 0
  fi
fi

if [ -n "$APT_SYSTEM" ]; then
  avail_updates="$(/usr/lib/update-notifier/apt-check 2>&1)"
  num_updates="$(echo $avail_updates | sed 's/;.*//')"
  security_updates="$(echo $avail_updates | sed 's/.*;//')"
  if [ "$num_updates" != 0 ]; then
    msg="There are $num_updates updates available"
    if [ "$security_updates" != 0 ]; then
      notify-send -u critical -t 10000 "$msg with $security_updates security updates."
      sleep 5
      update-manager
    else
      notify-send -u normal -t 1200000 "$msg. Update with apt/aptitude/update-manager."
    fi
  fi
elif ping -q -c 1 8.8.8.8 >/dev/null 2>&1 || ping -q -c 1 8.8.4.4 >/dev/null 2>&1; then
  num_updates=$(pamac checkupdates --aur --quiet 2>/dev/null | wc -l | awk '{ print $1 }')
  if [ $num_updates -gt 0 ]; then
    answer=$(dunstify "There are $num_updates updates available" -t 30000 -A Y,"Update now" -A N,Later)
    case $answer in
      Y)
        pamac-manager --updates
        echo $current_time > "$STAMP_FILE"
        ;;
      *) ;;
    esac
  else
    echo $current_time > "$STAMP_FILE"
  fi
else
  dunstify "No internet connection, updates check skipped." -t 10000
fi

exit 0
