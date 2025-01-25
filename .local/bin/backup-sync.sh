#!/bin/sh -e

sudo rsync -aHSA --info=progress2 --delete --zc=zstd --zl=6 $HOME/mnt/ $HOME/backup.sync/
