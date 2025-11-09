#!/bin/sh

set -e

source_dir=$1
[ -z "$source_dir" ] && source_dir=/
output_dir=$2
[ -z "$output_dir" ] && output_dir=`pwd`

# top-level directories are created with default root ownership and need to have read
# and execute access to the users
sudo /bin/sh -c "borgmatic extract --repository local --archive latest --progress --path $source_dir --destination $output_dir && chown sumedh:sumedh home/sumedh/.config/* && chmod 755 * etc boot boot/grub home home/sumedh opt usr/share usr/share/* usr/share/libdvd-pkg/debian var var/opt 2>/dev/null"
