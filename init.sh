#! /bin/bash

# Utility
head -c 32 /dev/urandom | base64    # Generates a key
# TO DO
- ConfigMaps
- Secrets
- Multi container pods
- Log checking
- Deployments
- Modify app
- Rollout apply undo

# setup kubernets for learning purpose.
brew install kubernetes-cli
brew install podman
brew install kind
kubectl version --client
podman info
podman machine init ; podman machine start

# Cluster
kind create cluster --config kind.yml
kind get clusters
kubectl cluster-info --context kind-kind
kind delete cluster --name kube-cluster

# User Config [ file - $HOME/.kube/config ]
kubectl config view
kubectl config use-context <name>
kubectl proxy     # creates a proxy locally for you

# Check Access
kubectl auth can-i create pods
kubectl auth can-i delete deployments --as dev-user   # check access for others
kubectl auth can-i create deployments --as dev-user -n <ns-name>

# Configs
kubectl create -f configmap \ 
    <name> --from-literal=color=blue \
    --from-literal=enc=dev \

kubectl create -f configmap \ 
    <name> --from-file=config.properties

kubectl create secret docker-registry regcred \
    --docker-server=ghcr.io \
    --docker-username=rithik-sandron \
    --docker-password=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

# Get
kubectl get all -A 
kubectl get configmaps
kubectl get nodes -o wide
kubectl get pods -o wide
kubectl get pods --watch
kubectl get pods
kubectl get rs
kubectl get svc
kubectl get roles -n <ns-name>
kubectl get rolebindings -n <ns-name>
kubectl get csr   # for certificates
kubectl get cm -o yaml

# Describe
kubectl describe pod <name> 
kubectl describe replicaset <name>
kubectl describe svc <name>
kubectl describe rolebinding <name>
kubectl describe csr <name>
kubectl describe role <name>
kubectl describe rolebinding <name>

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>   # -f for live stream
kubectl logs -f <pod-name>  <name of the container> # for multi container pod

# deployment and rollouts
kubectl run <name> --image= --dry-run=client -o yaml > <name>.yml   # creates a template for a pod
kubectl create –f <name>.yml
kubectl get deployments
kubectl apply –f <name>.yml
kubectl set image deployment/<name> nginx=nginx:1.9.1
kubectl rollout status deployment/<name>
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name>
kubectl edit deploy <name>

# Create
kubectl create namespace <name>
kubectl create serviceaccount <name> -n <ns-name>
kubectl create -f role.yml
kubectl create -f rolebinding.yml
kubectl expose svc <name> -n <ns-name> --name --port....
kubectl create ingress <name> -n <ns-name> 
  --rule="/hello=hello-service:8080"
  --rule="/world=world-service:8080"

# Apply
kubectl apply -f pod.yml
kubectl apply -f replicaSet.yml
kubectl apply -f service.yml

# Edit
kubectl edit svc <name> in <ns-name>
kubectl edit pod <name> in <ns-name>

# Delete
kubectl delete svc <name>
kubectl delete pod <name>
kubectl delete replicaset <name>
kubectl delete svc <name>

# ssh & curl
curl http://10.89.0.6:30000
podman exec -it kube-cluster-control-plane bash
podman exec -it kube-cluster-worker bash
kubectl exec -it hello-replicaset-f7dzg -- sh

# Steps
# 1. Ingress
#   - create ns
#   - create configmap
#   - create serviceaccount
#   - check roles and rolebindings
#   - create & apply ingress-controller
#   - create & apply ingress-service
#   - create & apply ingress with rules
