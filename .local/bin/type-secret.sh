#!/bin/sh

sleep 1

activeWindow="`xdotool getactivewindow`"
xdotool type --window "$activeWindow" "`secret-tool lookup "$@"`"
#xdotool windowactivate "$activeWindow" && \
