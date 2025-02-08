#!/bin/sh

#systemctl --user start borgmatic-backup.timer
#systemctl --user start borgmatic-check.timer

if [ "$DESKTOP_SESSION" = "awesome" ]; then
  systemctl --user start nm-applet.service
  # run ibus explicitly if required (ibus preferences from GUI)
  if type ibus 2>/dev/null >/dev/null; then
    ibus exit 2>/dev/null
  fi
else
  systemctl --user stop nm-applet.service
fi

# override pulseaudio settings with those of alsa that unmute both internal
# speaker and headphone allowing one to switch between the two seemlessly

alsa_state="$HOME/.asound.state"
if [ -f "$alsa_state" ]; then
  nohup /bin/sh -c "sleep 5 && alsactl restore -f \"$alsa_state\"" 2>/dev/null >/dev/null &
fi
