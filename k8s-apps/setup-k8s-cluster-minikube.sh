#!/bin/bash

# Clean previous cluster
#minikube stop
#minikube delete

minikube start

for a in volumesnapshots csi-hostpath-driver registry ingress ingress-dns metrics-server ; do
  minikube addons enable $a
done

