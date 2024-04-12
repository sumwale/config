#!/bin/bash -e

# install binaries for paru from paru-bin (paru takes too long to compile)
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg --noconfirm -si
cd ..
PARU="paru --noconfirm"
$PARU -Rs paru-bin-debug
$PARU -S neovim-symlinks
yes | paru -Sccd
$PARU -Syu
rm -rf .cache paru-bin
sudo rm -rf /root/.cache

# add self to realtime group
sudo usermod -aG realtime $(id -un)
