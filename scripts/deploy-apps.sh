#!/bin/bash

set -e

echo "📦 Deploying Helm-based applications to ArgoCD..."

kubectl apply -f argocd-apps/service1.yaml
kubectl apply -f argocd-apps/service2.yaml

echo "✅ Applications deployed!"
echo ""
echo "📊 Check status:"
echo "kubectl get application -n argocd"
echo ""
echo "🔍 Watch sync:"
echo "kubectl get application -n argocd -w"

