#!/bin/bash

echo "Creating a new project in OpenShift..."
oc new-project triton-vllm-inference-server --display-name "Triton vLLM Inference Server"
oc project triton-vllm-inference-server

#model-cache

echo "Creating the deployment..."
oc create deployment triton-vllm-inference-server2 --image quay.io/carl_mes/triton-vllm-inference-server:latest --port=8000

echo "Creating the model cache PVC..."
oc set volume deployment/triton-vllm-inference-server --add --claim-name='model-cache' --claim-mode='ReadWriteMany' --mount-path /opt/app-root/models -t pvc --claim-size=100G --overwrite

echo "Creating the model repository PVC..."
oc set volume deployment/triton-vllm-inference-server --add --claim-name='model-repository' --claim-mode='ReadWriteMany' --mount-path /opt/app-root/model_repository -t pvc --claim-size=100G --overwrite