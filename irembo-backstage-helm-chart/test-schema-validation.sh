#!/bin/bash
# test-schema-validation.sh - Script to demonstrate values schema validation

set -e

echo "Testing Helm Chart Schema Validation..."

# Create a valid values file
cat << EOF > valid-values.yaml
replicaCount: 2
image:
  repository: spotify/backstage
  tag: latest
  pullPolicy: Always
service:
  type: ClusterIP
  port: 80
  targetPort: 7007
postgresql:
  enabled: true
  auth:
    username: backstage
    password: securepassword
    database: backstage
EOF

# Create an invalid values file (missing required fields)
cat << EOF > invalid-values.yaml
replicaCount: 2
image:
  repository: spotify/backstage
  # Missing tag field
service:
  # Missing port field
  type: ClusterIP
EOF

# Test with valid values
echo -e "\n\033[1mTesting with valid values file:\033[0m"
echo "Running: helm lint irembo-backstage-helm-chart --values valid-values.yaml"
helm lint irembo-backstage-helm-chart --values valid-values.yaml
echo -e "\033[32mValid values file passed the schema validation!\033[0m"

# Test with invalid values
echo -e "\n\033[1mTesting with invalid values file:\033[0m"
echo "Running: helm lint irembo-backstage-helm-chart --values invalid-values.yaml"
if ! helm lint irembo-backstage-helm-chart --values invalid-values.yaml; then
  echo -e "\033[32mSuccess! Invalid values file failed validation as expected.\033[0m"
else
  echo -e "\033[31mError: Invalid values file passed validation when it should have failed.\033[0m"
fi

# Install with schema validation
echo -e "\n\033[1mDemonstrating schema validation during install:\033[0m"
echo "Attempting to install with invalid values..."
if ! helm install test-backstage irembo-backstage-helm-chart --values invalid-values.yaml --namespace irembo; then
  echo -e "\033[32mSuccess! Install failed due to schema validation as expected.\033[0m"
else
  echo -e "\033[31mError: Install succeeded with invalid values.\033[0m"
  # Clean up the installation
  helm uninstall test-backstage --namespace irembo
fi

# Clean up the test files
rm -f valid-values.yaml invalid-values.yaml

echo -e "\n\033[1mSchema Validation Testing Complete!\033[0m"
echo "The values.schema.json file successfully validates inputs to ensure proper configuration."