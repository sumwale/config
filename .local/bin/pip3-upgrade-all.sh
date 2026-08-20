#!/bin/sh

USER_ARG=--user
if [ "$1" = "--sys" ]; then
  shift
  USER_ARG=
fi

PIP=pip
if type pip3 2>/dev/null >/dev/null; then
  PIP=pip3
fi

$PIP list $USER_ARG --format=freeze | sed 's/==.*//' | xargs -n 1 $PIP install $USER_ARG --upgrade

# install packages listed in python-packages.txt to ensure they are proper versions
if [ -r "$HOME/python-packages.txt" ]; then
  $PIP install $USER_ARG --upgrade -r "$HOME/python-packages.txt"
fi
