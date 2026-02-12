#!/bin/bash

HELM_VERSION="4.1.1"

wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz
tar xzf helm-v${HELM_VERSION}-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin/

rm -r helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64/
