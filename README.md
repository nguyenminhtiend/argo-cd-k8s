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

### Option 1: Via kubectl
```bash
kubectl apply -f argocd-apps/nginx-app.yaml
```

### Option 2: Via ArgoCD UI
1. Click "New App"
2. Fill in details from `argocd-apps/nginx-app.yaml`
3. Click "Create"

## Verify Deployment

```bash
# Check ArgoCD app status
kubectl get application -n argocd

# Check nginx deployment
kubectl get all -n nginx-app

# Access nginx
minikube service nginx-service -n nginx-app
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
├── apps/
│   ├── nginx/              # Simple nginx microservice
│   └── nodejs/             # Node.js microservice (coming soon)
├── argocd-apps/            # ArgoCD Application manifests
└── README.md
```

