#!/bin/sh

set -e

archive_name=$1
[ -z "$archive_name" ] && archive_name=latest
source_dir=$2
[ -n "$source_dir" ] && source_dir_suffix=":$source_dir"
output_dir=$3
[ -z "$output_dir" ] && output_dir=`pwd`

# top-level directories are created with default root ownership and need to have read
# and execute access to the users
sudo /bin/sh -c "resticprofile --name local restore "$archive_name$source_dir_suffix" --target $output_dir"
