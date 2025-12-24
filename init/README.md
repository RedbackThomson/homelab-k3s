# `init`

This directory contains the initialization files for the homelab-k3s
environment. These files are used to initialize the cluster for the first time.

## Gateway API

The Gateway API is a Kubernetes API for managing network traffic. It is used to manage the network traffic for the cluster.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
```