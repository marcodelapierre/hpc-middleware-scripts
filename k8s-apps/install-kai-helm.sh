#!/bin/bash

KAI_VERSION="0.12.12"

helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler \
  --create-namespace \
  --version v${KAI_VERSION}
