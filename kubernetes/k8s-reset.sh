#!/bin/sh

kubectl delete -f https://docs.projectcalico.org/manifests/calico.yaml 2>/dev/null
sudo kubeadm reset --cri-socket=/run/containerd/containerd.sock "$@" && sudo sh -c 'rm -rf /etc/cni/net.d/*weave*; rm -rf /etc/cni/net.d/*calico*; rm -rf /etc/cni/net.d/*flannel*; rm -rf /var/lib/etcd/calico*' && rm -f ~/.kube/config; kill $(ps -ef | awk '/[0-9] kubectl proxy/ { print $2 }') 2>/dev/null || true
