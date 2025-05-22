#!/bin/bash
# demo-helm-lifecycle.sh - Script to demonstrate Helm lifecycle hooks and rollback

set -e

echo "Demonstrating Helm Lifecycle Hooks and Rollback..."

# Step 1: Install the Chart
echo -e "\n\033[1mStep 1: Installing Backstage Chart (Version 0.1.0)\033[0m"
helm install backstage ./backstage-helm-chart --namespace irembo --create-namespace
echo "Waiting for pre-install hooks to complete..."
sleep 15

# Check for pre-install hook job completion
echo "Checking pre-install hook job status:"
kubectl get jobs -n irembo -l app.kubernetes.io/instance=backstage

# Step 2: Wait for deployment to complete
echo -e "\n\033[1mStep 2: Waiting for deployment to complete\033[0m"
kubectl wait --for=condition=available --timeout=300s deployment/backstage -n irembo
echo "Backstage deployed successfully!"

# Step 3: Upgrade the Chart with a new version
echo -e "\n\033[1mStep 3: Upgrading Backstage Chart to simulate a new version\033[0m"
# First, let's modify the version in values.yaml
sed -i 's/appVersion: "1.0.0"/appVersion: "1.1.0"/' backstage-helm-chart/Chart.yaml
helm upgrade backstage ./backstage-helm-chart --namespace irembo

# Check for post-upgrade hook job
echo "Waiting for post-upgrade hooks to complete..."
sleep 15
echo "Checking post-upgrade hook job status:"
kubectl get jobs -n irembo -l app.kubernetes.io/instance=backstage

# Step 4: Check revision history
echo -e "\n\033[1mStep 4: Checking Helm revision history\033[0m"
helm history backstage -n irembo

# Step 5: Perform a rollback
echo -e "\n\033[1mStep 5: Performing a rollback to version 1\033[0m"
helm rollback backstage 1 -n irembo

# Check for pre-rollback hook job
echo "Waiting for pre-rollback hooks to complete..."
sleep 15
echo "Checking pre-rollback hook job status:"
kubectl get jobs -n irembo -l app.kubernetes.io/instance=backstage

# Step 6: Verify the rollback
echo -e "\n\033[1mStep 6: Verifying rollback\033[0m"
helm history backstage -n irembo
kubectl get deployment backstage -n irembo -o jsonpath='{.metadata.labels.app\.kubernetes\.io\/version}'

echo -e "\n\033[1mDemonstration Complete!\033[0m"
echo "The Helm lifecycle hooks (pre-install, post-upgrade, pre-rollback) were executed during these operations."
echo "You can inspect the hook jobs in namespace 'irembo' to see their execution details."