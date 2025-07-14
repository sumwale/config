#!/bin/bash

# script to setup a mounted root appropriate for most chroot operations

set -e

all_binds=("/dev" "/dev/pts" "/proc" "/sys" "/etc/resolv.conf")
if [ -d /sys/firmware/efi/efivars ]; then
  all_binds+=("/sys/firmware/efi/efivars")
fi

dest="$2"
if [ "$1" = "--umount" ]; then
  for ((i=${#all_binds[@]}-1; i>=0; i--)); do
    sudo umount "$dest${all_binds[$i]}"
  done
  sudo umount "$dest"
else
  sudo mount "$1" "$dest"
  for bind in ${all_binds[@]}; do
    sudo mount -o bind $bind "$dest$bind"
  done
fi
