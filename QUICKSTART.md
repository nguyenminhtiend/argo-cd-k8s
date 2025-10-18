# Quick Start Guide

## Step 1: Push to GitHub

```bash
git remote add origin https://github.com/nguyenminhtiend/argo-cd-k8s.git
git branch -M main
git push -u origin main
```

## Step 2: Install ArgoCD

```bash
./scripts/install-argocd.sh
```

## Step 3: Get ArgoCD Credentials

```bash
# Username: admin
# Password:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Step 4: Access ArgoCD UI

```bash
minikube service argocd-server -n argocd
```

## Step 5: Deploy Applications

### Deploy Apps Root (service1 & service2)

```bash
./scripts/deploy-apps.sh
```

### Deploy Infrastructure (Traefik)

```bash
./scripts/deploy-infra.sh
```

Or manually:

```bash
kubectl apply -f apps-root.yaml
kubectl apply -f infra-root.yaml
```

## Step 6: Verify

```bash
# Check ArgoCD apps
kubectl get application -n argocd

# Check services
kubectl get all -n service1
kubectl get all -n service2

# Check Traefik
kubectl get all -n traefik
kubectl get ingressroute -n traefik

# Port-forward Traefik (in separate terminal)
kubectl port-forward -n traefik svc/traefik 8080:80

# Test services:
curl http://localhost:8080/service1
curl http://localhost:8080/service2
```

## Test Auto-Sync + Self-Heal

### Test 1: Auto-Sync (Git → K8s)

```bash
# Edit replicas in apps/service1/values.yaml (change 1 to 3)
# Commit and push
git add apps/service1/values.yaml
git commit -m "Scale service1 to 3 replicas"
git push

# Watch ArgoCD sync automatically
kubectl get pods -n service1 -w
```

### Test 2: Self-Heal (K8s → Git)

```bash
# Manually change k8s (will be reverted)
kubectl scale deployment service1 -n service1 --replicas=10

# Watch ArgoCD revert it back to git state
kubectl get pods -n service1 -w
```

## Troubleshooting

```bash
# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Check application details
kubectl describe application service1 -n argocd
kubectl describe application traefik -n argocd

# Check Traefik logs
kubectl logs -n traefik -l app.kubernetes.io/name=traefik

# Force sync
kubectl patch app service1 -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
```

## Done! 🎉

Your ArgoCD is now managing:

- **Apps Root**: service1 and service2 microservices
- **Infra Root**: Traefik ingress controller with routing to both services

Access your services via Traefik:

1. Port-forward: `kubectl port-forward -n traefik svc/traefik 8080:80`
2. Access at: `http://localhost:8080/service1` and `http://localhost:8080/service2`
