#!/bin/sh

rclone -v sync "${HOME}/Documents/" gdrive:Documents/
