#!/bin/sh

systemctl --user start borgmatic-backup.timer
systemctl --user start borgmatic-check.timer

if [ "$DESKTOP_SESSION" = "gnome" ]; then
  systemctl --user stop nm-applet.service
else
  systemctl --user start nm-applet.service
fi

# override pulseaudio settings with those of alsa that unmute both internal
# speaker and headphone allowing one to switch between the two seemlessly
( sleep 5 && alsactl restore -f $HOME/.asound.state ) &
