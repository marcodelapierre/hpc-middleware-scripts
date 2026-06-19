#!/bin/bash

skaffold_ver="v2.22.0"

curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/${skaffold_ver}/skaffold-linux-amd64
sudo install skaffold /usr/local/bin/
rm skaffold
