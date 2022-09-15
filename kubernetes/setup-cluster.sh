#!/usr/bin/env -S bash -e

MANAGER=cluster-manager
MANAGER_IP=192.168.122.1
WORKERS="cluster-node1.internal.hosting cluster-node2.internal.hosting"

SCRIPT_DIR="`dirname "$0"`"
SERVICES_PRE_SETUP_FILE=k8s-setup-services-pre.sh
SERVICES_POST_SETUP_FILE=k8s-setup-services-post.sh
KUBEADM_WORKER_FLAGS="--cri-socket=unix:/run/containerd/containerd.sock --ignore-preflight-errors=Swap"
KUBEADM_FLAGS="$KUBEADM_WORKER_FLAGS --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$MANAGER_IP --node-name=$MANAGER"
KUBEADM_CONFIG=kubeadm-crio.yaml
#KUBEADM_WORKER_FLAGS="--cri-socket=/var/run/crio/crio.sock"
#KUBEADM_FLAGS="--config $KUBEADM_CONFIG"

source "$SCRIPT_DIR/common-functions.sh"

PROXY_PID=$(ps -ef | awk '/[0-9] kubectl proxy/ { print $2 }')
if [ -n "$PROXY_PID" ]; then
  kill $PROXY_PID
  sleep 2
  if kill -0 $PROXY_PID; then
    kill -9 $PROXY_PID
  fi
fi

echo Applying required service modifications
"$SCRIPT_DIR/$SERVICES_PRE_SETUP_FILE"
for worker in $WORKERS; do
  scp "$SCRIPT_DIR/$SERVICES_PRE_SETUP_FILE" $worker:.
  ssh -t $worker $HOME/$SERVICES_PRE_SETUP_FILE
  ssh $worker rm -f $HOME/$SERVICES_PRE_SETUP_FILE
done

if [ "$1" = "--only-services" ]; then
  exit 0
fi

if [ "$1" = "--cni" ]; then
  if [ "$2" = "weave" ]; then
    USE_CALICO=
    USE_FLANNEL=
  elif [ "$2" = "calico" ]; then
    USE_CALICO=true
    USE_FLANNEL=
  elif [ "$2" = "flannel" ]; then
    USE_CALICO=
    USE_FLANNEL=true
  else
    echo "Expected weave, calico or flannel as CNI implementation but found: $2"
  fi
fi

echo
echo
echo =====================================================================================
echo "INTIALIZING K8S CLUSTER WITH $MANAGER AS CONTROL PLANE AND WORKERS = $WORKERS"
echo =====================================================================================
echo
echo

yq -i eval 'select(.nodeRegistration.name) |= .nodeRegistration.name= "'$MANAGER'"' "$KUBEADM_CONFIG"
sudo kubeadm init $KUBEADM_FLAGS "$@" > kubeadm-init.log

JOIN_CMD=$(awk '/kubeadm join/ { if ($0 ~ /\\$/) { gsub(/\\$/, ""); printf $0; getline; print } else print }' kubeadm-init.log)
JOIN_CMD="$JOIN_CMD $KUBEADM_WORKER_FLAGS"

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo Applying required post service modifications
"$SCRIPT_DIR/$SERVICES_POST_SETUP_FILE"

if ! sudo grep -q service-node-port-range /etc/kubernetes/manifests/kube-apiserver.yaml; then
  sudo perl -pi -e 's/(--service-cluster-ip-range=[^\n]*\n)/$1    - --service-node-port-range=8000-10767\n/' /etc/kubernetes/manifests/kube-apiserver.yaml
fi
if ! sudo grep -q pod-eviction-timeout /etc/kubernetes/manifests/kube-controller-manager.yaml; then
  sudo perl -pi -e 's/(--port=[^\n]*\n)/$1    - --node-monitor-grace-period=30s\n    - --pod-eviction-timeout=2m\n/' /etc/kubernetes/manifests/kube-controller-manager.yaml
  if [ -e /run/containerd/containerd.sock ]; then
    sudo systemctl restart containerd
  fi
  if [ -e /var/run/crio/crio.sock ]; then
    sudo systemctl restart crio
  fi
  if [ -e /var/run/dockershim.sock -o -e /run/docker.sock ]; then
    sudo systemctl restart docker
  fi
  sleep 10
fi
sudo systemctl restart kubelet

echo
if [ -n "$USE_CALICO" ]; then
  echo Applying Calico
  echo NOTE: You must turn off any firewall on the nodes
  CNI_CONF=https://docs.projectcalico.org/manifests/calico.yaml
  POD_PATTERN="calico-.*"
elif [ -n "$USE_FLANNEL" ]; then
  echo Applying Flannel
  echo NOTE: You must turn off any firewall on the nodes
  CNI_CONF=https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  POD_PATTERN="flannel-.*"
else
  echo Applying Weave Net
  CNI_CONF="https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  POD_PATTERN="weave-net-.*"
fi
echo

sleep 10
if ! kubectl apply -f "$CNI_CONF"; then
  sleep 10
  kubectl apply -f "$CNI_CONF"
fi
sleep 5
waitForPods "$POD_PATTERN" -n kube-system

echo
echo Starting workers on $WORKERS
echo

for worker in $WORKERS; do
  echo Setting up worker on $worker with: $JOIN_CMD
  workerName="`echo $worker | sed 's/\..*//'`"
  scp "$SCRIPT_DIR/$SERVICES_POST_SETUP_FILE" $worker:.
  ssh -t $worker "$HOME/$SERVICES_POST_SETUP_FILE --join $JOIN_CMD"
  ssh $worker rm -f $HOME/$SERVICES_POST_SETUP_FILE
done
sleep 5
for worker in $WORKERS; do
  kubectl wait --for=condition=Ready --timeout=180s node/$(echo $worker | sed 's/\..*//')
done

echo
echo Waiting for networking to be up
echo

sleep 5
waitForPods "$POD_PATTERN" -n kube-system

echo
echo Starting NFS service
echo

#kubectl label nodes $MANAGER nfs-host=true
#kubectl apply -f "$SCRIPT_DIR/nfs-ganesha"
#sleep 5
#waitForPods "nfs-provisioner-.*"

helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=$MANAGER_IP --set nfs.path=/home/nfs/k8s --set image.pullPolicy=Always --set storageClass.onDelete=delete
# mark StorageClass as default
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
sleep 5
waitForPods "nfs-subdir-.*"

echo
echo Starting NGINX Ingress Controller
echo

kubectl apply -f "$SCRIPT_DIR/ingress"
sleep 5
waitForPods "ingress-nginx-controller-.*" -n ingress-nginx

echo
echo Creating the TLS secret for Chorus service
echo

gpg --decrypt virt-key.pem.gpg > virt-key.pem
gpg --decrypt virt-cert.pem.gpg > virt-cert.pem
kubectl create secret tls tds-tls --key "$SCRIPT_DIR/virt-key.pem" --cert "$SCRIPT_DIR/virt-cert.pem"

"$SCRIPT_DIR/setup-dashboard.sh"
