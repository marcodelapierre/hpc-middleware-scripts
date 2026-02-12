#!/bin/bash

KUEUE_VERSION="0.14.4"

helm install kueue oci://registry.k8s.io/kueue/charts/kueue \
  --version=${KUEUE_VERSION} \
  --namespace  kueue-system \
  --create-namespace \
  --wait --timeout 300s
