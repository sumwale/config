#!/bin/sh

USERID=gemfire1
[ -n "$1" ] && USERID="$1" && shift

ldapsearch -x -LLL -D "uid=${USERID},ou=ldapTesting,dc=pune,dc=gemstone,dc=com" -b "ou=ldapTesting,dc=pune,dc=gemstone,dc=com" -w "${USERID}" "$@"
