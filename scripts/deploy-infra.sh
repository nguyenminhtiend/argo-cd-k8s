#!/bin/bash

set -e

echo "🚀 Deploying Infrastructure Root App..."

# Apply infra root app
kubectl apply -f infra-root.yaml

echo "✅ Infrastructure root app deployed!"
echo ""
echo "📋 To check status:"
echo "   kubectl get applications -n argocd | grep -E '(infra|traefik)'"
echo ""
echo "⚠️  Note: Ingress routes are deployed with each service"
echo "   They'll appear once apps are deployed via deploy-apps.sh"
echo ""
echo "🌐 To access services via Traefik:"
echo "   kubectl port-forward -n traefik svc/traefik 8080:80"
echo ""
echo "   Then access:"
echo "   service1: http://localhost:8080/service1 or http://service1.local:8080"
echo "   service2: http://localhost:8080/service2 or http://service2.local:8080"
echo ""
echo "💡 Add to /etc/hosts for domain routing:"
echo "   127.0.0.1 service1.local service2.local"

