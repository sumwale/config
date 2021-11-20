#!/bin/bash

set -euo pipefail

KUBEADM_CONFIG="${1-kubeadm-crio.yaml}"
echo "Printing to $KUBEADM_CONFIG"

if [ -d "$KUBEADM_CONFIG" ]; then
    echo "$KUBEADM_CONFIG is a directory!"
    exit 1
fi

if [ ! -d $(dirname "$KUBEADM_CONFIG") ]; then
    echo "please create directory $(dirname $KUBEADM_CONFIG)"
    exit 1
fi

if [ ! $(which yq) ]; then
    echo "please install yq"
    exit 1
fi

if [ ! $(which kubeadm) ]; then
    echo "please install kubeadm"
    exit 1
fi

kubeadm config print init-defaults --component-configs=KubeletConfiguration > "$KUBEADM_CONFIG"
yq -i eval 'select(.localAPIEndpoint.advertiseAddress) |= .localAPIEndpoint.advertiseAddress= "'"`hostname -i`"'"' "$KUBEADM_CONFIG"
yq -i eval 'select(.nodeRegistration.criSocket) |= .nodeRegistration.criSocket = "unix:///var/run/crio/crio.sock"' "$KUBEADM_CONFIG"
yq -i eval 'select(.nodeRegistration.imagePullPolicy) |= .nodeRegistration.imagePullPolicy = "Always"' "$KUBEADM_CONFIG"
yq -i eval 'select(.nodeRegistration.name) |= .nodeRegistration.name= "'"`hostname`"'"' "$KUBEADM_CONFIG"
yq -i eval 'select(.networking) |= .networking.podSubnet = "10.244.0.0/16"' "$KUBEADM_CONFIG"
#yq -i eval 'select(di == 1) |= .cgroupDriver = "systemd"' "$KUBEADM_CONFIG"
