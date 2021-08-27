#!/bin/sh

jps | egrep -vw '(Main|Jps|eclipse)' | awk '{ print $1 }' | xargs -r kill
sleep 5
jps | egrep -vw '(Main|Jps|eclipse)' | awk '{ print $1 }' | xargs -r kill -9
