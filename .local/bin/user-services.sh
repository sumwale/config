#!/bin/bash

systemctl --user start borgmatic-backup.timer
systemctl --user start borgmatic-check.timer

if [ "$DESKTOP_SESSION" = "gnome" ]; then
  systemctl --user stop nm-applet.service
else
  systemctl --user start nm-applet.service
fi

# run ibus explicitly if required (ibus preferences from GUI)
ibus exit 2>/dev/null

# override pulseaudio settings with those of alsa that unmute both internal
# speaker and headphone allowing one to switch between the two seemlessly

alsa_state="$HOME/.asound.state"
if [ -f "$alsa_state" ]; then
  # use the newer of $HOME/.asound.state and /var/lib/asound.state
  if [ -f /var/lib/alsa/asound.state -a /var/lib/alsa/asound.state -nt "$alsa_state" ]; then
    alsa_state=/var/lib/alsa/asound.state
  fi
  nohup /bin/bash -c "sleep 5 && alsactl restore -f \"$alsa_state\"" >/dev/null 2>/dev/null &
fi
