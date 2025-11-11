#!/bin/sh

set -e

mutt -e "my_hdr Reply-To:sumwale@yahoo.com" "$@"
