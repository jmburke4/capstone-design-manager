#!/bin/bash

#############################################################################
# Custom Domain Setup Script
#
# Maps a custom domain to Cloud Run service
#
# Usage: ./scripts/40-setup-custom-domain.sh <domain-name>
#        Example: ./scripts/40-setup-custom-domain.sh capstone.example.com
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"
SERVICE_NAME="capstone-manager-production"
DOMAIN=${1:-""}

if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name required"
    echo "Usage: $0 <domain-name>"
    echo "Example: $0 capstone.example.com"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Custom Domain Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Domain: $DOMAIN"
echo "Service: $SERVICE_NAME"
echo ""

# Verify domain ownership
echo "Step 1: Verify domain ownership"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "Before mapping a domain, you must verify ownership."
echo ""
echo "Manual steps required:"
echo "  1. Go to: https://console.cloud.google.com/run/domains?project=$PROJECT_ID"
echo "  2. Click 'Add Mapping' or 'Verify Domain'"
echo "  3. Follow the verification process (add TXT record to DNS)"
echo "  4. Wait for verification to complete (can take up to 24 hours)"
echo ""
read -p "Have you verified domain ownership? (yes/no): " verified

if [[ "$verified" != "yes" ]]; then
    echo "Please verify domain ownership first, then run this script again."
    exit 0
fi

# Map domain to service
echo ""
echo "Step 2: Mapping domain to service"
echo "─────────────────────────────────────────────────────────────"
echo ""

gcloud run domain-mappings create \
    --project=$PROJECT_ID \
    --service=$SERVICE_NAME \
    --domain=$DOMAIN \
    --region=$REGION \
    --quiet || echo "  ℹ Domain mapping may already exist"

echo "✓ Domain mapping created"

# Get DNS records
echo ""
echo "Step 3: Configure DNS records"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "Add these DNS records to your domain registrar:"
echo ""

# Get the record from Cloud Run
DNS_RECORD=$(gcloud run domain-mappings describe $DOMAIN \
    --project=$PROJECT_ID \
    --region=$REGION \
    --format='value(status.resourceRecords[0].rrdata)' 2>/dev/null || echo "ghs.googlehosted.com")

echo "  Type: CNAME"
echo "  Name: $DOMAIN (or @ for root domain)"
echo "  Value: $DNS_RECORD"
echo ""
echo "Note: DNS propagation can take 10-60 minutes"
echo ""

# Update service with custom domain
echo "Step 4: Updating service configuration..."
gcloud run services update $SERVICE_NAME \
    --project=$PROJECT_ID \
    --region=$REGION \
    --update-env-vars="CUSTOM_DOMAIN=${DOMAIN}" \
    --quiet

echo "✓ Service updated with custom domain"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Custom Domain Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Domain: https://$DOMAIN"
echo ""
echo "⏱ Waiting for:"
echo "  1. DNS propagation (10-60 minutes)"
echo "  2. SSL certificate provisioning (5-15 minutes after DNS)"
echo ""
echo "Check status:"
echo "  gcloud run domain-mappings describe $DOMAIN --region=$REGION --project=$PROJECT_ID"
echo ""
echo "Next steps:"
echo "  1. Wait for DNS propagation"
echo "  2. Test: https://$DOMAIN"
echo "  3. Update Auth0 with production domain"
echo "  4. Update ALLOWED_HOSTS if needed"
echo ""
