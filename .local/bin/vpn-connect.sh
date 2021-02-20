#!/bin/sh

nmcli --ask connection up Colo

#server=sslvpn-blr.vmware.com
#cert=./vmware.cert
#
#if [ -n "$1" ]; then
#  server="$1"
#  # assume US server
#  cert=./vmware-us.cert
#fi
#
#echo -n "User: "
#read user
#
#trap "stty echo; exit 2" 1 2 3 4 6 8 11 13 14 15
#
#echo -n "Password: "
#stty -echo
#read passwd
#stty echo
#echo
#
#( cd $HOME/.juniper_networks/network_connect && ./ncsvc -h "${server}" -u "${user}" -p "${passwd}" -f "${cert}" )
