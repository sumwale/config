#!/bin/sh -e

borgmatic mount --mount-point ~/mnt --archive "$1" --options allow_other
