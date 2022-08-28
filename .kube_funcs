export K8S_SERVICES="tds-alpine tds-rconnector tds-notebooks tds-chorus nfs-subdir-external-provisioner"

function klogs() {
  deployName="$1"
  shift
  kubectl logs "deployment/$deployName" "$@"
}

function kexecProc() {
  deployName="$1"
  shift
  if [ -n "$1" ]; then
    kubectl exec -it "deployment/$deployName" "$@"
  else
    kubectl exec -it "deployment/$deployName" -- /bin/bash
  fi
}

function kcleanReplicas() {
  emptyReplicasets="`kubectl get replicasets | grep '0[ ]\+0[ ]\+0' | cut -d' ' -f 1`"
  if [ -n "$emptyReplicasets" ]; then
    kubectl delete replicasets $emptyReplicasets
  fi
}

function kstopAll() {
  for d in $K8S_SERVICES; do
    kubectl scale --replicas=0 "deployment/$d"
  done
}

function kstartAll() {
  if systemctl status dnsmasq 2>/dev/null >/dev/null; then
    sudo systemctl restart dnsmasq
  fi
  for d in $K8S_SERVICES; do
    kubectl scale --replicas=1 "deployment/$d"
  done
}

function kswitchNS() {
  kubectl config set-context --current --namespace=$1
}
