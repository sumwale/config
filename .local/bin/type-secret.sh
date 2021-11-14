#!/bin/sh

#xdotool type "`secret-tool lookup "$@"`"

activeWindow="`xdotool getactivewindow`"
sleep 0.5
xdotool type --window "$activeWindow" "`secret-tool lookup "$@"`"
##xdotool windowactivate "$activeWindow"
