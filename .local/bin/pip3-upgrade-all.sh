#!/bin/sh

PIP=pip
if type pip3 >/dev/null 2>/dev/null; then
  PIP=pip3
fi

$PIP list --user --format=freeze | sed 's/==.*//' | xargs -n 1 $PIP install --user --upgrade

# install packages listed in python-packages.txt to ensure they are proper versions
if [ -r "$HOME/python-packages.txt" ]; then
  $PIP install --user --upgrade -r "$HOME/python-packages.txt"
fi
