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
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS XAUTHORITY DISPLAY WAYLAND_DISPLAY SSH_ASKPASS SSH_ASKPASS_REQUIRE
#systemctl --user restart gcr-ssh-agent.service
systemctl --user restart ssh-agent.service

# brighter colors using nvibrant if NVIDIA card is the active one
if glxinfo | grep -iq "OpenGL renderer string.*NVIDIA"; then
  nvibrant_cmd="nvibrant 64 64"
  # set on both the own monitor and the external one, if attached
  if [ -x /usr/bin/nvibrant ]; then
    /usr/bin/$nvibrant_cmd
  elif [ -x $HOME/.local/bin/nvibrant -a -x /usr/bin/podman ]; then
    # need to wait for podman container to be available
    nohup /bin/sh -c "while [ \"\`podman inspect --type=container --format='{{ .State.Status }}' archbox-apps 2>/dev/null\`\" != running ]; do sleep 5; done; sleep 5 && $HOME/.local/bin/$nvibrant_cmd" 2>/dev/null >/dev/null &
  fi
fi

# override pulseaudio settings with those of alsa that unmute both internal
# speaker and headphone allowing one to switch between the two seemlessly

alsa_state="$HOME/.asound.state"
if [ -f "$alsa_state" ]; then
  nohup /bin/sh -c "sleep 5 && alsactl restore -f \"$alsa_state\"" 2>/dev/null >/dev/null &
fi
