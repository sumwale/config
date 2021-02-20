#!/bin/sh

if [ -z "$@" ]; then
  LS_ARGS="-t"
else
  LS_ARGS="$1"
  shift
fi

ls ${LS_ARGS} | sed 's/^/"/;s/$/"/;' | xargs cvlc "$@"
