#!/bin/sh

set -e

in="$1"
shift
/usr/bin/gpg --import --import-options restore "$@" "$in"
