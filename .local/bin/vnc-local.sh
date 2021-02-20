#!/bin/sh

xtigervncviewer -passwd "$HOME/.vnc/passwd" -FullScreen -FullColour -PreferredEncoding Tight -QualityLevel 8 -CompressLevel 2 -SecurityTypes None,VncAuth,Plain :1 &
