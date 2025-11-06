#!/bin/bash

KUEUE_VERSION="0.14.4"

kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/v${KUEUE_VERSION}/manifests.yaml

kubectl wait deploy/kueue-controller-manager -n kueue-system --for=condition=available --timeout=5m

#kubectl delete -f https://github.com/kubernetes-sigs/kueue/releases/download/v${KUEUE_VERSION}/manifests.yaml
