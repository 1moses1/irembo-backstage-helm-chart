#!/bin/bash
# Helm plugin to check Backstage health status
# Save this file at $HELM_PLUGINS/backstage/backstage.sh

RELEASE_NAME=$2
NAMESPACE=$3

if [ -z "$RELEASE_NAME" ] || [ -z "$NAMESPACE" ]; then
  echo "Usage: helm backstage-health RELEASE_NAME NAMESPACE"
  exit 1
fi

echo "Checking Backstage health for release $RELEASE_NAME in namespace $NAMESPACE..."

# Get the service name
SERVICE_NAME=$(kubectl get deployment -n $NAMESPACE -l "app.kubernetes.io/instance=$RELEASE_NAME" -o jsonpath="{.items[0].metadata.name}")

if [ -z "$SERVICE_NAME" ]; then
  echo "Error: Could not find Backstage deployment"
  exit 1
fi

# Set up port forwarding to the service
echo "Setting up port forwarding to Backstage service..."
kubectl port-forward -n $NAMESPACE service/$SERVICE_NAME 9191:80 &
PORT_FORWARD_PID=$!

# Give port forwarding time to establish
sleep 3

# Make the health check request
echo "Making health check request..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9191/api/health)

# Cleanup port forwarding
kill $PORT_FORWARD_PID

# Check the response
if [ "$HTTP_STATUS" == "200" ]; then
  echo "✅ Backstage is healthy! (HTTP Status: $HTTP_STATUS)"
  exit 0
else
  echo "❌ Backstage health check failed! (HTTP Status: $HTTP_STATUS)"
  exit 1
fi