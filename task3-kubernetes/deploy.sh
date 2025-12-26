#!/bin/bash

# Task 3: Deploy applications to Minikube

set -e

NAMESPACE="flask-app"

echo "================================"
echo "Deploying to Minikube"
echo "================================"

# Create namespace
echo "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE || echo "Namespace already exists"

# Apply configurations
echo "Applying ConfigMap..."
kubectl apply -f 01-configmap.yaml

echo "Applying RBAC..."
kubectl apply -f 04-rbac.yaml

echo "Applying Network Policies..."
kubectl apply -f 05-network-policy.yaml

echo "Deploying Flask Application..."
kubectl apply -f 02-flask-app-deployment.yaml

echo "Deploying Nginx Proxy..."
kubectl apply -f 03-nginx-proxy-deployment.yaml

echo "Deploying HPA and PDB..."
kubectl apply -f 06-hpa-pdb.yaml

echo "Deploying Prometheus..."
kubectl apply -f 07-prometheus.yaml

# Wait for deployments
echo ""
echo "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/flask-app -n $NAMESPACE || true
kubectl wait --for=condition=available --timeout=300s \
  deployment/nginx-proxy -n $NAMESPACE || true

# Display deployment status
echo ""
echo "================================"
echo "Deployment Status"
echo "================================"
kubectl get deployments -n $NAMESPACE
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

# Get the service endpoint
echo ""
echo "================================"
echo "Service Information"
echo "================================"
echo "To access the application:"
echo "  kubectl port-forward -n $NAMESPACE svc/nginx-service 8080:80"
echo "  Then open: http://localhost:8080"
echo ""
echo "To view logs:"
echo "  kubectl logs -n $NAMESPACE -l app=flask-app -f"
echo "  kubectl logs -n $NAMESPACE -l app=nginx-proxy -f"
echo ""
echo "To scale the deployment:"
echo "  kubectl scale deployment flask-app -n $NAMESPACE --replicas=5"
echo ""
