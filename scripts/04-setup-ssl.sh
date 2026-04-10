#!/bin/bash

#############################################################################
# Setup SSL with Let's Encrypt
#
# This script:
# - Obtains SSL certificate from Let's Encrypt
# - Configures Nginx for HTTPS
# - Sets up automatic renewal
#
# Usage: ./scripts/04-setup-ssl.sh yourdomain.com
#
# Prerequisites:
# - Domain DNS must point to VM IP
# - Application must be running
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"
DOMAIN=${1:-""}
EMAIL=${2:-"admin@${DOMAIN}"}

if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name required"
    echo "Usage: $0 <domain-name> [email]"
    echo "Example: $0 capstone.example.com admin@example.com"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setting Up SSL for $DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify DNS is pointing to VM
echo "Verifying DNS configuration..."
VM_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

echo "  VM IP: $VM_IP"
echo "  Checking DNS for $DOMAIN..."

# Check if DNS is configured
DOMAIN_IP=$(dig +short $DOMAIN | tail -n1)

if [ -z "$DOMAIN_IP" ]; then
    echo ""
    echo "  ✗ ERROR: DNS not configured for $DOMAIN"
    echo ""
    echo "Please configure DNS first:"
    echo "  1. Go to your domain registrar (e.g., Google Domains)"
    echo "  2. Add A record:"
    echo "     Type: A"
    echo "     Name: @ (or subdomain)"
    echo "     Value: $VM_IP"
    echo "     TTL: 3600"
    echo "  3. Wait for DNS propagation (10-60 minutes)"
    echo "  4. Run this script again"
    echo ""
    exit 1
fi

if [ "$DOMAIN_IP" != "$VM_IP" ]; then
    echo "  ⚠ WARNING: DNS points to $DOMAIN_IP but VM IP is $VM_IP"
    echo "  SSL certificate may fail to validate"
    read -p "Continue anyway? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        exit 0
    fi
else
    echo "  ✓ DNS correctly configured"
fi

# Obtain SSL certificate via Certbot on VM
echo ""
echo "Obtaining SSL certificate from Let's Encrypt..."

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="bash -s" << ENDSSH

set -e

cd ~/capstone

echo "Running Certbot to obtain certificate..."

# Run certbot via Docker
newgrp docker << 'DOCKERCMD'
cd ~/capstone

# Request certificate
docker compose -f docker-compose.prod.yml run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email ${EMAIL} \
    --agree-tos \
    --no-eff-email \
    -d ${DOMAIN} \
    -d www.${DOMAIN}

DOCKERCMD

echo "✓ Certificate obtained"

# Update Nginx configuration for HTTPS
echo "Updating Nginx configuration..."

# Create HTTPS config from template
cd ~/capstone
sed "s/DOMAIN_NAME/${DOMAIN}/g" nginx/conf.d/https.conf.template > nginx/conf.d/https.conf

# Rename default.conf to disable HTTP-only config
mv nginx/conf.d/default.conf nginx/conf.d/default.conf.disabled || true

# Reload Nginx
echo "Reloading Nginx..."
newgrp docker << 'DOCKERCMD'
cd ~/capstone
docker compose -f docker-compose.prod.yml exec nginx nginx -s reload
DOCKERCMD

echo "✓ Nginx reloaded with HTTPS configuration"

ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ SSL Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Application now accessible at: https://$DOMAIN"
echo ""
echo "Certificate details:"
echo "  Domain: $DOMAIN, www.$DOMAIN"
echo "  Issuer: Let's Encrypt"
echo "  Expires: 90 days (auto-renews)"
echo "  Renewal: Automatic (certbot container checks every 12 hours)"
echo ""
echo "Test HTTPS:"
echo "  curl -I https://$DOMAIN/api/v1/health/"
echo ""
echo "Next steps:"
echo "  1. Update .env.production DJANGO_ALLOWED_HOSTS with: $DOMAIN www.$DOMAIN"
echo "  2. Redeploy: ./scripts/update-app.sh"
echo "  3. Update Auth0 with: https://$DOMAIN"
echo "  4. Setup backups: ./scripts/05-setup-backups.sh"
echo ""
