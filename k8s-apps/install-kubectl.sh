#!/bin/bash

kubectl_ver="v1.35.0"

sudo curl -L "https://dl.k8s.io/release/${kubectl_ver}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
sudo chmod +x /usr/local/bin/kubectl
