#!/bin/sh

set -e

# set a random wallpaper on awesome and gnome

wallpaper_dir="$HOME/Pictures/wallpapers"
if [ "$DESKTOP_SESSION" = "awesome" ]; then
  nitrogen --random --set-zoom-fill "$wallpaper_dir"
elif [ "$DESKTOP_SESSION" != "plasma" ]; then
  selected="`/bin/ls "$wallpaper_dir" | shuf | head -n1`"
  selected_uri="file://$wallpaper_dir/$selected"
  gsettings set org.gnome.desktop.background picture-uri "$selected_uri"
  gsettings set org.gnome.desktop.background picture-uri-dark "$selected_uri"
fi
