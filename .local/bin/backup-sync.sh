#!/bin/sh -e

sudo rsync -aHSAXX --filter='-x security.selinux' --info=progress2 --delete --zc=zstd --zl=6 ~/mnt/. ~/backup.sync/.
