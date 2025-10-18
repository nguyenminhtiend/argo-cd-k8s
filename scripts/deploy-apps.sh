#!/bin/bash

set -e

echo "📦 Deploying root apps to ArgoCD (App of Apps pattern)..."

kubectl apply -f apps-root.yaml
# kubectl apply -f infra-root.yaml  # Uncomment when ready

echo "✅ Root apps deployed! They will automatically deploy all services."
echo ""
echo "📊 Check status:"
echo "kubectl get application -n argocd"
echo ""
echo "🔍 Watch sync:"
echo "kubectl get application -n argocd -w"

