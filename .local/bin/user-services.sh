#!/bin/sh

#systemctl --user start borgmatic-backup.timer
#systemctl --user start borgmatic-check.timer

if [ "$DESKTOP_SESSION" = "awesome" ]; then
  systemctl --user start nm-applet.service
  # run ibus explicitly if required (ibus preferences from GUI)
  if type ibus 2>/dev/null >/dev/null; then
    ibus exit 2>/dev/null
  fi
fi

# update environment for D-Bus and user systemd services
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS XAUTHORITY DISPLAY WAYLAND_DISPLAY

# override pulseaudio settings with those of alsa that unmute both internal
# speaker and headphone allowing one to switch between the two seemlessly

alsa_state="$HOME/.asound.state"
if [ -f "$alsa_state" ]; then
  nohup /bin/sh -c "sleep 5 && alsactl restore -f \"$alsa_state\"" 2>/dev/null >/dev/null &
fi
