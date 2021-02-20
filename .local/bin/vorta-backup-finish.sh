#!/bin/sh

CONFIG_EXCLUDES="JetBrains libreoffice"

for dir in $CONFIG_EXCLUDES; do
  rm -rf $HOME/.config-$dir
done
