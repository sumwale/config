#!/bin/sh

set -e

output_dir=$3
[ -z "$output_dir" ] && output_dir=`pwd`

# top-level directories are created with default root ownership and need to have read
# and execute access to the users
sudo /bin/sh -c "cd $output_dir && PATH=$PATH:/root/.local/bin borg extract --progress --sparse $HOME/backup::$1 $2; chown sumedh:sumedh home/sumedh/.config/*; chmod 755 * etc boot boot/grub home home/sumedh opt usr/share usr/share/* usr/share/libdvd-pkg/debian var var/opt 2>/dev/null"
