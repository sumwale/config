#!/bin/sh -e

output_dir=$3
[ -z "$output_dir" ] && output_dir=`pwd`

# top-level directories are created with default root ownership and need to have read
# and execute access to the users
sudo /bin/sh -c "cd $output_dir && PATH=$PATH:/root/.local/bin borg extract --progress --numeric-ids --sparse $HOME/backup::$1 $2; chmod 755 * boot/grub home/sumedh usr/bin usr/share usr/share/* usr/share/libdvd-pkg/debian 2>/dev/null"
