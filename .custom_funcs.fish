set K8S_SERVICES tds-alpine tds-rconnector tds-notebooks tds-chorus nfs-subdir-external-provisioner

function klogs --description 'kubectl logs for a deployment'
  kubectl logs "deployment/$argv[1]" $argv[2..-1]
end

function kexecProc --description 'kubectl exec process (or bash) for a deployment'
  if [ (count $argv) -gt 1 ]
    kubectl exec -it "deployment/$argv[1]" $argv[2..-1]
  else
    kubectl exec -it "deployment/$argv[1]" -- /bin/bash
  end
end

function kcleanReplicas --description 'kubectl clean old replicasets'
  set emptyReplicasets (kubectl get replicasets | grep '0[ ]\+0[ ]\+0' | cut -d' ' -f 1)
  if [ -n "$emptyReplicasets" ]
    kubectl delete replicasets $emptyReplicasets
  end
end

function kstopAll --description 'kubectl stop all tds services'
  for d in $K8S_SERVICES
    kubectl scale --replicas=0 "deployment/$d"
  end
end

function kstartAll --description 'kubectl start all tds services'
  if systemctl status dnsmasq 2>/dev/null >/dev/null
    sudo systemctl restart dnsmasq
  end
  for d in $K8S_SERVICES
    kubectl scale --replicas=1 "deployment/$d"
  end
end

function kswitchNS --description 'change current namespace for kubectl'
  kubectl config set-context --current "--namespace=$argv[1]"
end
