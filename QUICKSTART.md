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

## Step 5: Deploy nginx App

```bash
./scripts/deploy-apps.sh
```

Or manually via ArgoCD UI:

- Click "+ New App"
- Application Name: `nginx-app`
- Project: `default`
- Sync Policy: `Automatic` (check "Self Heal" and "Prune")
- Repository URL: `https://github.com/nguyenminhtiend/argo-cd-k8s.git`
- Revision: `main`
- Path: `apps/nginx`
- Cluster: `https://kubernetes.default.svc`
- Namespace: `nginx-app`
- Click "Create"

## Step 6: Verify

```bash
# Check ArgoCD app
kubectl get application -n argocd

# Check nginx pods
kubectl get all -n nginx-app

# Access nginx
minikube service nginx-service -n nginx-app
# Or: curl http://$(minikube ip):30080
```

## Test Auto-Sync + Self-Heal

### Test 1: Auto-Sync (Git → K8s)

```bash
# Edit replicas in apps/nginx/deployment.yaml (change 3 to 5)
# Commit and push
git add apps/nginx/deployment.yaml
git commit -m "Scale nginx to 5 replicas"
git push

# Watch ArgoCD sync automatically
kubectl get pods -n nginx-app -w
```

### Test 2: Self-Heal (K8s → Git)

```bash
# Manually change k8s (will be reverted)
kubectl scale deployment nginx-deployment -n nginx-app --replicas=10

# Watch ArgoCD revert it back to git state
kubectl get pods -n nginx-app -w
```

## Troubleshooting

```bash
# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Check application details
kubectl describe application nginx-app -n argocd

# Force sync
kubectl patch app nginx-app -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
```

## Done! 🎉

Your ArgoCD is now managing nginx with auto-sync and self-heal enabled.
