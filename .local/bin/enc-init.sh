#!/bin/sh -e

# Encrypt listed directories making a copy of those. This can be usually done while
# logged into GUI (close all other apps to ensure files being copied are not being
#   changed while being copied). To replace the originals use enc-finish.sh script
# which should only be run either by root when the user is not logged in, or in
# text-mode login by user ensuring that no other processes are running (kill -9 -1).

ENC_PREFIX="enc-init"
for dir in `cat enc.dirs`; do
  if [ -d $dir -a ! -e $dir.$ENC_PREFIX ]; then
    mkdir $dir.$ENC_PREFIX && \
      fscrypt encrypt $dir.$ENC_PREFIX --no-recovery && \
      cp -a -T $dir $dir.$ENC_PREFIX
  fi
done

# create an additional protector that can be used when login protector
# is not available (e.g. root filesystem has changed)
if findmnt /home 2>/dev/null >/dev/null; then
  HOME_MNT=/home
else
  HOME_MNT=/
fi

NEW_PROTECTOR="`fscrypt status $HOME_MNT | sed -n 's/^\([^ \t]*\).*custom protector.*$/\1/p'`"
if [ -z "$NEW_PROTECTOR" ]; then
  fscrypt metadata create protector $HOME_MNT
fi
NEW_PROTECTOR="`fscrypt status $HOME_MNT | sed -n 's/^\([^ \t]*\).*custom protector.*$/\1/p'`"

if [ -n "$NEW_PROTECTOR" ]; then
  for dir in `cat enc.dirs`; do
    if [ -d $dir.$ENC_PREFIX ]; then
      POLICY="`fscrypt status $dir.$ENC_PREFIX | sed -n 's/^.*Policy:[ ]*\([^ \t]*\).*$/\1/p'`"
      if [ -n "$POLICY" ]; then
        fscrypt metadata add-protector-to-policy --protector=$HOME_MNT:$NEW_PROTECTOR --policy=$HOME_MNT:$POLICY
      fi
    fi
  done
fi
