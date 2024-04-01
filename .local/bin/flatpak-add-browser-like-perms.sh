#!/bin/sh -e

dir_perms="$HOME/software:ro $HOME/config:ro $HOME/.icons:ro $HOME/.themes:ro $HOME/.local/share/icons:ro $HOME/.config/speech-dispatcher:ro $HOME/.local/bin:ro"

app="$1"

if [ -z "$app" ]; then
  echo Usage: `basename "$0"` "<flatpak-app-id> [--mail]"
  exit 1
fi

shift
if [ "$1" != "--mail" ]; then
  dir_perms="$dir_perms $HOME/dwhelper"
fi

for perm in $dir_perms; do
  flatpak override "$app" --filesystem="$perm" --user
  echo "Added access permission to $perm"
done
