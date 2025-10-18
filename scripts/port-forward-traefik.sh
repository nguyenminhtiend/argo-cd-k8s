#!/bin/bash

set -e

echo "🌐 Port-forwarding Traefik..."
echo ""
echo "Access services at:"
echo "  - http://localhost:8080/service1"
echo "  - http://localhost:8080/service2"
echo ""
echo "Press Ctrl+C to stop"
echo ""

kubectl port-forward -n traefik svc/traefik 8080:80

