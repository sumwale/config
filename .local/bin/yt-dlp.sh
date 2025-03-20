#!/bin/sh

exec yt-dlp --format 'bv*+ba[format_id$=-drc]/b' "$@"
