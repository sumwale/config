#!/bin/sh

CMD=
if [ "$INTERACTIVE_SHELL_IS_FISH" = "true" ]; then
  if [ -x /bin/fish ]; then
    CMD='-- /bin/fish'
  elif [ -x /usr/bin/fish ]; then
    CMD='-- /usr/bin/fish'
  elif [ -x /usr/local/bin/fish ]; then
    CMD='-- /usr/local/bin/fish'
  fi
fi

exec kitty --session "$HOME/.config/kitty/custom.session" $CMD
