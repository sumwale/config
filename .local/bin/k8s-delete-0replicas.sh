#!/bin/sh

kubectl delete `kubectl get all | grep replicaset.apps | grep '0         0         0' | cut -d' ' -f 1`
