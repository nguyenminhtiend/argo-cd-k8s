# ArgoCD on Minikube

Testing ArgoCD with microservices on local Kubernetes.

## Prerequisites

```bash
# Start minikube
minikube start --memory=4096 --cpus=2

# Verify
kubectl cluster-info
```

## Install ArgoCD via Helm

```bash
# Add ArgoCD Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd

# Install ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.service.type=NodePort \
  --set server.insecure=true

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

## Access ArgoCD UI

```bash
# Get the NodePort
kubectl get svc argocd-server -n argocd

# Access via minikube
minikube service argocd-server -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

**Login:** `admin` / (password from above)

## Deploy Applications

### Deploy Apps Root (Application of Applications)

```bash
# Deploy application root - manages all app deployments
./scripts/deploy-apps.sh

# This will create service1 and service2
```

### Deploy Infrastructure Root (Traefik Ingress)

```bash
# Deploy infrastructure root - manages Traefik and routing
./scripts/deploy-infra.sh

# This will install Traefik and configure routing to services
```

### Manual Deployment (Alternative)

```bash
# Apps
kubectl apply -f apps-root.yaml

# Infrastructure
kubectl apply -f infra-root.yaml
```

## Verify Deployment

```bash
# Check ArgoCD app status
kubectl get application -n argocd

# Check services
kubectl get all -n service1
kubectl get all -n service2

# Check Traefik
kubectl get all -n traefik
kubectl get ingressroute -n traefik
```

## Access Services via Traefik

### Option 1: Via Path-based routing

```bash
# Get Traefik LoadBalancer IP/Port
minikube service traefik -n traefik

# Access services:
# http://localhost/service1
# http://localhost/service2
```

### Option 2: Via Host-based routing

```bash
# Add to /etc/hosts
echo "127.0.0.1 service1.local service2.local" | sudo tee -a /etc/hosts

# Access services:
# http://service1.local
# http://service2.local
```

## Test Auto-Sync + Self-Heal

1. **Auto-sync test:** Change `replicas` in `apps/nginx/deployment.yaml`, commit & push

   - ArgoCD will automatically deploy the change

2. **Self-heal test:** Manually scale the deployment
   ```bash
   kubectl scale deployment nginx-deployment -n nginx-app --replicas=5
   ```
   - ArgoCD will automatically revert to git state (3 replicas)

## Cleanup

```bash
# Delete applications
kubectl delete -f argocd-apps/

# Uninstall ArgoCD
helm uninstall argocd -n argocd
kubectl delete namespace argocd

# Stop minikube
minikube stop
```

## Repository Structure

```
├── apps/                    # Application values
│   ├── service1/
│   └── service2/
├── argocd-apps/            # ArgoCD app manifests (apps)
│   ├── service1.yaml
│   └── service2.yaml
├── argocd-infra/           # ArgoCD app manifests (infrastructure)
│   ├── traefik.yaml
│   └── traefik-routes.yaml
├── charts/                 # Helm charts
│   └── microservice-common/
├── infra/                  # Infrastructure configs
│   └── traefik-routes/     # Traefik IngressRoutes
├── scripts/                # Deployment scripts
│   ├── start-minikube.sh
│   ├── install-argocd.sh
│   ├── deploy-apps.sh
│   └── deploy-infra.sh
├── apps-root.yaml          # App of Apps for services
├── infra-root.yaml         # App of Apps for infrastructure
└── README.md
```
