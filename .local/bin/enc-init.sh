#!/bin/bash

set -e

# Encrypt listed directories making a copy of those. This can be usually done while
# logged into GUI (close all other apps to ensure files being copied are not being
#   changed while being copied). To replace the originals use enc-finish.sh script
# which should only be run either by root when the user is not logged in, or in
# text-mode login by user ensuring that no other processes are running (kill -9 -1).

login_protector=
login_pass_read=0
other_pass_read=0
login_pass_file=/tmp/fscrypt-enc-init1.gpg
other_pass_file=/tmp/fscrypt-enc-init2.gpg
gpg_id=sumwale@gmail.com

trap "stty echo; shred -u $login_pass_file $other_pass_file 2>/dev/null" \
  0 1 2 3 4 5 6 7 8 10 11 12 14 15

if [ "$1" = --tty ]; then
  decrypt_opts="--decrypt --pinentry-mode loopback --quiet" # ask password from the terminal
else
  decrypt_opts="--decrypt --quiet"
fi

ENC_PREFIX="enc-init"
for dir in $(cat enc.dirs); do
  if [ ! -e $dir.$ENC_PREFIX ] && ! fscrypt status $dir >/dev/null 2>/dev/null; then
    if [ $login_pass_read -eq 0 ]; then
      [ -f $login_pass_file ] && shred -u $login_pass_file
      echo -n "Enter the login passphrase for $USER: "
      stty -echo
      head -n1 | gpg -r $gpg_id --encrypt --batch -o $login_pass_file
      stty echo
      echo
      echo "Encrypted the passphrase using 'gpg -r $gpg_id' (gpg passphrase may be asked later)"
      login_pass_read=1
    fi
    if [ -z "$login_protector" ]; then
      login_protector=$(fscrypt status / | sed -n 's/^\(\S*\).*login protector.*$/\1/p')
      if [ -z "$login_protector" ]; then
        protector_arg="--source=pam_passphrase"
      fi
    fi
    if [ -n "$login_protector" ]; then
      protector_arg="--protector=/:$login_protector"
    fi
    echo Encrypting $dir...
    mkdir -p $dir $dir.$ENC_PREFIX
    gpg $decrypt_opts $login_pass_file |
      fscrypt encrypt $dir.$ENC_PREFIX --quiet --no-recovery $protector_arg
    cp -a -T $dir $dir.$ENC_PREFIX
  fi
done

# create an additional protector that can be used when login protector
# is not available (e.g. root filesystem has changed)
dir_mnt=$(findmnt -n -o TARGET -T .)
if ! fscrypt status $dir_mnt | grep -qF 'custom protector'; then
  fscrypt metadata create protector $dir_mnt
fi
custom_protector=($(fscrypt status $dir_mnt |
  sed -n 's/^\(\S*\).*custom protector\s*"\(\S*\)".*$/\1 \2/p'))

if [ ${#custom_protector[@]} -eq 2 ]; then
  for dir in $(cat enc.dirs); do
    if [ -d $dir.$ENC_PREFIX ]; then
      policy_id=$(fscrypt status $dir.$ENC_PREFIX | sed -n 's/^.*Policy:\s*\(\S*\).*$/\1/p')
      if [ -n "$policy_id" ]; then
        if [ $other_pass_read -eq 0 ]; then
          [ -f $other_pass_file ] && shred -u $other_pass_file
          echo -n "Enter the passphrase for protector with name '${custom_protector[1]}': "
          stty -echo
          head -n1 | gpg -r $gpg_id --encrypt --batch -o $other_pass_file
          stty echo
          echo
          other_pass_read=1
        fi
        echo Adding additional protector to $dir...
        { gpg $decrypt_opts $other_pass_file && gpg $decrypt_opts $login_pass_file; } |
          fscrypt metadata add-protector-to-policy --quiet \
            --protector=$dir_mnt:${custom_protector[0]} --policy=$dir_mnt:$policy_id
      fi
    fi
  done
fi
