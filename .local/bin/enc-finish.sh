#!/bin/sh

# Finish replace directories by their encrypted versions. Should be run only after
# enc-init.sh either by root when the user is not logged in, or in text-mode login
# by user ensuring that no other processes are running (e.g. using "kill -9 -1").

ENC_PREFIX="enc-init"
for dir in `cat enc.dirs`; do
  if [ -d $dir -a -d $dir.$ENC_PREFIX ]; then
    ( find $dir -type f -print0 | xargs -r -0 shred -n1 --remove=unlink )
    rm -rf $dir && mv $dir.$ENC_PREFIX $dir
  fi
done
