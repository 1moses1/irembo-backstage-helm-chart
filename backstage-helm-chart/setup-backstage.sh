#!/bin/bash
# setup-backstage.sh - Script to set up Backstage with ArgoCD in Minikube

set -e

echo "Setting up Backstage with ArgoCD in Minikube..."

# Step 1: Ensure Minikube is running
if ! minikube status | grep -q "Running"; then
  echo "Starting Minikube..."
  minikube start
fi

# Step 2: Create the irembo namespace
kubectl create namespace irembo || true
echo "Namespace 'irembo' created or already exists."

# Step 3: Check if ArgoCD is running
if ! kubectl get namespace argocd &>/dev/null; then
  echo "Installing ArgoCD..."
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
  
  # Wait for ArgoCD to be ready
  echo "Waiting for ArgoCD server to be ready..."
  kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
fi

# Step 4: Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# Step 5: Clone the GitHub repository
echo "Cloning Backstage Helm Chart repository..."
if [ ! -d "irembo-backstage-helm-chart" ]; then
  git clone https://github.com/1moses1/irembo-backstage-helm-chart.git
else
  cd backstage-helm-chart && git pull && cd ..
fi

# Step 6: Apply the ArgoCD application
echo "Applying ArgoCD application for Backstage..."
kubectl apply -f irembo-backstage-helm-chart/argocd-backstage-app.yaml

# Step 7: Set up port forwarding for services
echo "Setting up port forwarding..."
# Stop any existing port forwarding
pkill -f "kubectl port-forward -n argocd" || true
pkill -f "kubectl port-forward -n irembo" || true

# Start port forwarding for ArgoCD
kubectl port-forward -n argocd svc/argocd-server 8083:443 &
echo "ArgoCD is available at https://localhost:8083"

# Wait a moment for the Backstage deployment to be created by ArgoCD
echo "Waiting for Backstage deployment to be created..."
sleep 30

# Start port forwarding for Backstage
kubectl port-forward -n irembo svc/backstage 7007:80 &
echo "Backstage will be available at http://localhost:7007"

echo "Setup complete!"
echo ""
echo "Access information:"
echo "- ArgoCD: https://localhost:8083 (admin / $ARGOCD_PASSWORD)"
echo "- Backstage: http://localhost:7007"
echo ""
echo "To stop port forwarding: pkill -f 'kubectl port-forward'"