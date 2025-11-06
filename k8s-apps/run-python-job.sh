#!/bin/bash

kubectl create configmap hello-py --from-file=./files/hello.py
kubectl apply -f python-job.yaml
