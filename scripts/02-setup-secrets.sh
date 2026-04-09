#!/bin/bash

#############################################################################
# Secret Manager Setup Script
#
# Creates and populates secrets in Google Cloud Secret Manager
# Prompts user for sensitive values
#
# Usage: ./scripts/02-setup-secrets.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Secret Manager Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script will create secrets in Google Cloud Secret Manager."
echo "You will be prompted to enter sensitive values."
echo ""

# Function to create or update secret
create_or_update_secret() {
    local secret_name=$1
    local secret_value=$2
    
    # Check if secret exists
    if gcloud secrets describe $secret_name --project=$PROJECT_ID &>/dev/null; then
        echo "  Updating existing secret: $secret_name"
        echo -n "$secret_value" | gcloud secrets versions add $secret_name \
            --project=$PROJECT_ID \
            --data-file=- \
            --quiet
    else
        echo "  Creating new secret: $secret_name"
        echo -n "$secret_value" | gcloud secrets create $secret_name \
            --project=$PROJECT_ID \
            --data-file=- \
            --replication-policy="automatic" \
            --quiet
    fi
    echo "  ✓ Secret saved"
}

# 1. Django Secret Key
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  1/4: Django Secret Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Generating random Django SECRET_KEY..."
DJANGO_SECRET=$(python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
create_or_update_secret "django-secret-key" "$DJANGO_SECRET"
echo ""

# 2. Auth0 Domain
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  2/4: Auth0 Domain"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enter your Auth0 domain (e.g., dev-qjyd077ykn3qqq7v.us.auth0.com):"
echo "(Find this in Auth0 Dashboard → Applications → Your App → Settings)"
read -p "> " AUTH0_DOMAIN
create_or_update_secret "auth0-domain" "$AUTH0_DOMAIN"
echo ""

# 3. Auth0 Client ID
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  3/4: Auth0 Client ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enter your Auth0 Client ID:"
echo "(Find this in Auth0 Dashboard → Applications → Your App → Settings)"
read -p "> " AUTH0_CLIENT_ID
create_or_update_secret "auth0-client-id" "$AUTH0_CLIENT_ID"
echo ""

# 4. Auth0 Audience
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  4/4: Auth0 API Audience"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enter your Auth0 API Audience (e.g., https://backend-api-capstone/):"
echo "(Find this in Auth0 Dashboard → APIs → Your API → Settings)"
read -p "> " AUTH0_AUDIENCE
create_or_update_secret "auth0-audience" "$AUTH0_AUDIENCE"
echo ""

# Check database password
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Database Password"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if gcloud secrets describe db-password --project=$PROJECT_ID &>/dev/null; then
    echo "✓ Database password already exists (created by Cloud SQL setup)"
else
    echo "⚠ Database password not found"
    echo "  Run: ./scripts/01-setup-cloud-sql.sh first"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Secret Manager Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Secrets created/updated:"
echo "  • django-secret-key (auto-generated)"
echo "  • auth0-domain"
echo "  • auth0-client-id"
echo "  • auth0-audience"
echo "  • db-password (from Cloud SQL setup)"
echo ""
echo "View secrets in console:"
echo "  https://console.cloud.google.com/security/secret-manager?project=$PROJECT_ID"
echo ""
echo "Grant Cloud Run access to secrets:"
echo "  This will be done automatically during deployment"
echo ""
