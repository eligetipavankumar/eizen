#!/bin/bash

# Task 3: Minikube Kubernetes Cluster Setup

set -e

echo "================================"
echo "Minikube Kubernetes Setup"
echo "================================"

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "Installing Minikube..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install minikube
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -LO https://github.com/kubernetes/minikube/releases/download/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    else
        echo "Please install Minikube manually from https://minikube.sigs.k8s.io/"
        exit 1
    fi
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install kubectl
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
fi

# Start minikube with reduced memory for Windows systems
echo "Starting Minikube cluster..."
minikube start --driver=docker --cpus=2 --memory=2200 --disk-size=30g

# Check status
echo ""
echo "Cluster Status:"
minikube status

# Get kubeconfig
echo ""
echo "Setting up kubeconfig..."
minikube update-context

# Enable required addons
echo ""
echo "Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Display cluster info
echo ""
echo "Kubernetes Cluster Information:"
kubectl cluster-info
kubectl get nodes

# Build Flask image in Minikube
echo ""
echo "Building Flask application image in Minikube..."
eval $(minikube docker-env)
docker build -t flask-app:latest ./minimal-flask-example/ || echo "Build with current directory"

echo ""
echo "================================"
echo "Minikube Setup Complete!"
echo "================================"
echo ""
echo "To access Kubernetes Dashboard:"
echo "  minikube dashboard"
echo ""
echo "To access Minikube IP:"
echo "  minikube ip"
echo ""
echo "Next: Deploy services using:"
echo "  kubectl apply -f kubernetes/"
echo ""
