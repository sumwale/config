#!/bin/sh

systemctl --user start borgmatic-backup.timer
systemctl --user start borgmatic-check.timer

if [ "$DESKTOP_SESSION" = "gnome" ]; then
  systemctl --user stop nm-applet.service
else
  systemctl --user start nm-applet.service
fi

# override pulseaudio settings with those of alsa
sudo alsactl restore
