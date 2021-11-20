waitForPods() {
  PATTERN="$1"
  shift
  for pod in `kubectl get pods "$@" | awk "/$PATTERN/"' { print $1 }'`; do
    kubectl wait --for=condition=Ready pod/$pod --timeout=180s "$@"
  done
}
