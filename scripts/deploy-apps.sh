#!/bin/bash

set -e

echo "📦 Deploying applications to ArgoCD..."

kubectl apply -f argocd-apps/nginx-app.yaml

echo "✅ Applications deployed!"
echo ""
echo "📊 Check status:"
echo "kubectl get application -n argocd"
echo ""
echo "🔍 Watch sync:"
echo "kubectl get application -n argocd -w"

