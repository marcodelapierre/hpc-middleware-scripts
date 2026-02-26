#!/bin/bash

VOLCANO_VERSION="1.14.1"

kubectl apply -f "https://raw.githubusercontent.com/volcano-sh/volcano/refs/tags/v${VOLCANO_VERSION}/installer/volcano-development.yaml"
