#!/bin/bash

# Generate cryptographically secure secrets
JWT_SECRET=$(openssl rand -base64 32)
API_KEY=$(openssl rand -hex 16)
DB_PASSWORD=$(openssl rand -base64 20)

echo "Generated secrets:"
echo "JWT_SECRET: $JWT_SECRET"
echo "API_KEY: $API_KEY"
echo "DB_PASSWORD: $DB_PASSWORD"
echo ""

# Create database secrets
aws secretsmanager create-secret \
  --name "eks-app/database" \
  --description "Database credentials for EKS application" \
  --secret-string "{
    \"POSTGRES_USER\":\"appuser\",
    \"POSTGRES_PASSWORD\":\"$DB_PASSWORD\",
    \"POSTGRES_DB\":\"appdb\"
  }" \
  --region eu-central-1

# Create application secrets
aws secretsmanager create-secret \
  --name "eks-app/application" \
  --description "Application secrets for EKS application" \
  --secret-string "{
    \"JWT_SECRET\":\"$JWT_SECRET\",
    \"API_KEY\":\"$API_KEY\",
    \"NODE_ENV\":\"production\"
  }" \
  --region eu-central-1

echo "Secrets created in AWS Secrets Manager"
echo "Verifying secrets..."

# Verify secrets were created
aws secretsmanager list-secrets --region eu-central-1 --query 'SecretList[?contains(Name, `eks-app`)].{Name:Name,Description:Description}'