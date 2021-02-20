#!/bin/sh

PIP=pip
if type pip3 >/dev/null 2>/dev/null; then
  PIP=pip3
fi

$PIP list --user --format=freeze | sed 's/==.*//' | xargs -n 1 $PIP install --upgrade
