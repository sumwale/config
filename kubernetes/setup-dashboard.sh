#!/bin/sh -e

SCRIPT_DIR="`dirname "$0"`"

. $SCRIPT_DIR/common-functions.sh

echo
echo Starting dashboard
echo

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml
sleep 2
# increase the dashboard timeout
kubectl patch deployment kubernetes-dashboard -n kubernetes-dashboard --type json -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--token-ttl=86400" }]'
sleep 2
waitForPods "kubernetes-dashboard-.*" -n kubernetes-dashboard
kubectl apply -f "$SCRIPT_DIR/dashboard"
if ! ps -ef | grep -q '[0-9] kubectl proxy'; then
  echo
  echo Staring kubectl proxy
  kubectl proxy > kubectl-proxy.log 2> kubectl-proxy.err &
  sleep 2
fi

echo
echo Use the token below to login to dasboard at: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
echo

kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
echo
