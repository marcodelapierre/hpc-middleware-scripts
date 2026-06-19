#!/bin/bash

kubectl_ver="v1.35.0"

curl -L "https://dl.k8s.io/release/${kubectl_ver}/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/
rm kubectl
