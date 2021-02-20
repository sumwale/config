#!/bin/sh

#vnstat -i ppp0 -d --xml | grep '^[ ]*<day ' | mawk -F '<' 'BEGIN { rx = 0; tx = 0; end = 0; } { if (end == 0 && $0 ~ /<day>21</) end = 1; if (end == 0) { gsub(/^..>/, "", $11); gsub(/^..>/, "", $13); rx += $11; tx += $13; } } END { printf "rx = %d Kb, tx = %d Kb, total = %d Kb,%g Gb\n", rx, tx, tx+rx, (tx+rx)/(1024.0*1024.0) }'

# get from router
ssh 192.168.150.1 vnstat-getusage.sh
