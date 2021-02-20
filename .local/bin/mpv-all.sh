#!/bin/sh

RND=
if [ -z "$@" ]; then
  LS_ARGS="-t"
elif [ "$1" = "-R" ]; then
  RND=1
  shift
  if [ -n "$1" ]; then
    LS_ARGS="$1"
    shift
  fi
else
  LS_ARGS="$1"
  shift
fi

if [ -z "${RND}" ]; then
  ls ${LS_ARGS} | sed 's/^/"/;s/$/"/;' | xargs mpv "$@"
else
  ls ${LS_ARGS} | sort -R | sed 's/^/"/;s/$/"/;' | xargs mpv "$@"
fi
