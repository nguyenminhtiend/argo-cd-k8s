#!/bin/bash

# Start minikube with persistent configuration
# Data persists in ~/.minikube/profiles/minikube (or your profile name)
# Even after stopping minikube or rebooting machine

PROFILE_NAME="${MINIKUBE_PROFILE:-minikube}"

echo "Starting minikube with profile: $PROFILE_NAME"

minikube start \
  --profile="$PROFILE_NAME" \
  --cpus=4 \
  --memory=4096 \
  --disk-size=30g \
  --kubernetes-version=stable \
  --driver=docker \
  --keep-context

# Wait for cluster to be ready
echo ""
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s


echo ""
echo "Minikube status:"
minikube status -p "$PROFILE_NAME"

echo ""
echo "Enabled addons:"
minikube addons list -p "$PROFILE_NAME" | grep enabled

echo ""
echo "Your cluster is persistent at: ~/.minikube/profiles/$PROFILE_NAME"
echo "To stop: minikube stop -p $PROFILE_NAME"
echo "To restart: minikube start -p $PROFILE_NAME"
echo "To delete: minikube delete -p $PROFILE_NAME"

