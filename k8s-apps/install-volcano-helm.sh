#!/bin/bash

VOLCANO_VERSION="1.14.1"

helm repo add volcano-sh https://volcano-sh.github.io/helm-charts
helm repo update

helm install volcano volcano-sh/volcano \
  -n volcano-system \
  --create-namespace \
  --version=${VOLCANO_VERSION}

