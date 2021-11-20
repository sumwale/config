#!/bin/sh -e

if ! [ -f /run/systemd/resolve/resolv.conf ]; then
  KADM_CONFS='/lib/systemd/system/kubelet.service.d/*kubeadm.conf /etc/systemd/system/kubelet.service.d/*kubeadm.conf'
  for conf in $KADM_CONFS; do
    if [ -f $conf ]; then
      KADM_CONF=$conf
    fi
  done
  if ! sudo grep -q /etc/resolv.conf $KADM_CONF 2>/dev/null; then
    echo Setting correct resolv.conf in kubelet service
    sudo perl -pi -e 's#(Environment="KUBELET_CONFIG_ARGS=.*)"#$1 --resolv-conf=/etc/resolv.conf"#' $KADM_CONF
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet.service
  fi
fi

if [ "$1" = "--join" ]; then
  echo
  echo Initializing this node as a worker
  echo
  shift
  sudo "$@"
fi
