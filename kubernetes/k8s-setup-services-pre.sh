#!/bin/sh -e

DOCKER_REGISTRY="docker-registry.hosting:5000"

sudo tee /etc/modules-load.d/99-kubernetes-cri.conf << EOF > /dev/null
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
sudo tee /etc/sysctl.d/99-kubernetes-cri.conf << EOF > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.netfilter.nf_conntrack_max      = 1000000
EOF
# Apply sysctl params without reboot
sudo sysctl --system > /dev/null

# Allow swap
KADM_CONFS='/lib/systemd/system/kubelet.service.d/*kubeadm.conf /etc/systemd/system/kubelet.service.d/*kubeadm.conf'
for conf in $KADM_CONFS; do
  if [ -f $conf ]; then
    KADM_CONF=$conf
  fi
done
if ! sudo grep -q fail-swap-on $KADM_CONF 2>/dev/null; then
  echo Allow swap in kubelet service
  sudo perl -pi -e 's#(Environment="KUBELET_CONFIG_ARGS=.*)"#$1 --fail-swap-on=false"#' $KADM_CONF
  sudo systemctl daemon-reload
  sudo systemctl restart kubelet.service
fi

if [ -e /run/containerd/containerd.sock ]; then
  sudo mkdir -p /etc/containerd
  containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
  if grep -q SystemdCgroup /etc/containerd/config.toml; then
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  else
    sudo sed -i 's|^\( [ ]*\).*containerd.runtimes.runc.options.*|\0\n\1  SystemdCgroup = true|' /etc/containerd/config.toml
  fi
  if ! grep -q "$DOCKER_REGISTRY" /etc/containerd/config.toml; then
    grep -v 'registry.configs' /etc/containerd/config.toml | awk '{
      if ($0 ~ /.*plugins.*registry.mirrors].*/) {
        print
        sub(/.plugins.*/, "") # get the indentation
        indent = $0
        while (true) {
          getline
          if ($0 ~ /^.*docker.io.*$/) {
            print
          } else {
            lastLine = $0
            break
          }
        }
        print indent "  [plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"docker-registry.hosting:5000\"]"
        print indent "    endpoint = [\"http://docker-registry.hosting:5000\"]"
        print indent "[plugins.\"io.containerd.grpc.v1.cri\".registry.configs]"
        print indent "  [plugins.\"io.containerd.grpc.v1.cri\".registry.configs.\"docker-registry.hosting:5000\".tls]"
        print indent "    insecure_skip_verify = true"
        print lastLine
      } else {
        print
      }
    }' | sudo tee /etc/containerd/config.toml.tmp > /dev/null
    sudo rm -f /etc/containerd/config.toml
    sudo mv -f /etc/containerd/config.toml.tmp /etc/containerd/config.toml
  fi

  sudo sed -i 's/KillMode=process/KillMode=mixed/' /lib/systemd/system/containerd.service 2>/dev/null || /bin/true
  sudo systemctl daemon-reload
  sudo systemctl restart containerd
fi

if [ -e /var/run/crio/crio.sock ]; then
  if [ -d /etc/sysconfig ]; then
    confFile=/etc/sysconfig/crio
  else
    confFile=/etc/default/crio
  fi
  if ! grep -q docker-registry.hosting:5000 $confFile; then
    echo 'CRIO_CONFIG_OPTIONS="--insecure-registry=docker-registry.hosting:5000"' | sudo tee -a $confFile > /dev/null
    sudo systemctl restart crio
  fi
fi

if [ -e /var/run/dockershim.sock -o -e /run/docker.sock ]; then
  DOCKER_CONF_EXISTING=
  if [ -f /etc/docker/daemon.json ]; then
    DOCKER_CONF_EXISTING=`grep -v '[{}]' /etc/docker/daemon.json`
    if [ -n "$DOCKER_CONF_EXISTING" ]; then
      DOCKER_CONF_EXISTING="
  $DOCKER_CONF_EXISTING,"
    fi
  fi
  if ! [ -f /etc/docker/daemon.json ] ||
     ! grep -q native.cgroupdriver=systemd /etc/docker/daemon.json ||
     ! grep -q log-opts /etc/docker/daemon.json ||
     ! grep -q insecure-registries /etc/docker/daemon.json; then
    echo Updating /etc/docker/daemon.json
    sudo tee /etc/docker/daemon.json << EOF > /dev/null
{$DOCKER_CONF_EXISTING
  "containerd": "/run/containerd/containerd.sock",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "insecure-registries" : ["docker-registry.hosting:5000"]
}
EOF
    sudo systemctl restart docker.service
  fi
fi

if [ -d /etc/NetworkManager/conf.d ]; then
  confFile=
  sudo tee /etc/NetworkManager/conf.d/99-calico.conf << EOF > /dev/null
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico
EOF
  sudo systemctl reload NetworkManager
fi
