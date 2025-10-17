#!/bin/bash

set -e

echo "🚀 Installing ArgoCD via Helm..."

# Add Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=30081 \
  --set server.insecure=true \
  --wait \
  --timeout 5m

echo "✅ ArgoCD installed successfully!"
echo ""
echo "📝 Get admin password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo"
echo ""
echo "🌐 Access ArgoCD UI:"
echo "minikube service argocd-server -n argocd"

