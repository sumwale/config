#!/bin/sh

# sign a kernel module for ubuntu/debian-like distributions

set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <module>"
  exit 1
fi

mok_cert1=/var/lib/shim-signed/mok/MOK.der
mok_cert2=/var/lib/dkms/mok.pub
if sudo test -e $mok_cert1; then
  mok_cert=$mok_cert1
  mok_key=/var/lib/shim-signed/mok/MOK.priv
elif sudo test -e $mok_cert2; then
  mok_cert=$mok_cert2
  mok_key=/var/lib/dkms/mok.key
else
  echo "Neither $mok_cert1 nor $mok_cert2 found!"
  exit 1
fi

if [ -x /usr/bin/kmodsign ]; then
  signer=/usr/bin/kmodsign
else
  kver="`uname -r`"
  signer="`find -L "/lib/modules/$kver" -name sign-file | head -n1`"
  if [ -z "$signer" ]; then
    echo "Neither /usr/bin/kmodsign nor sign-file found!"
    exit 1
  fi
fi

sudo "$signer" sha512 $mok_key $mok_cert "$1"
