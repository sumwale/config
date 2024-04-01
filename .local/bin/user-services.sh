#!/bin/sh

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
  nohup /bin/sh -c "sleep 5 && alsactl restore -f \"$alsa_state\"" >/dev/null 2>/dev/null &
fi
