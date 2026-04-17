#!/bin/bash
#############################################################################
# Setup SSL with Let's Encrypt - Final Reliable Version
#############################################################################
set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"

DOMAIN=${1:-""}
EMAIL=${2:-"admin@${DOMAIN}"}

if [ -z "$DOMAIN" ]; then
        echo "Usage: $0 <domain> [email]"
        exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Setting Up SSL for $DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

VM_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" \
        --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

echo "VM IP: $VM_IP"
echo ""

# DNS + Firewall checks (simplified)
if ! gcloud compute firewall-rules describe "${VM_NAME}-allow-http" --project="$PROJECT_ID" &>/dev/null; then
        echo "Creating HTTP firewall rule..."
        gcloud compute firewall-rules create "${VM_NAME}-allow-http" \
                --project="$PROJECT_ID" --allow=tcp:80 --source-ranges=0.0.0.0/0 \
                --target-tags="$VM_NAME" --quiet
fi

# Test ACME challenge (quick version)
echo "Testing ACME challenge..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --tunnel-through-iap --command="bash -s" <<'TEST'
cd ~/capstone
DOCKER_BIN="$HOME/bin/docker"
run_compose() { "$DOCKER_BIN" compose -f docker-compose.prod.yml "$@"; }

run_compose run --rm --entrypoint sh certbot -c '
    mkdir -p /var/www/certbot/.well-known/acme-challenge &&
    echo "test-file-$$" > /var/www/certbot/.well-known/acme-challenge/test-file
'
echo "Test file created"
TEST

# Get certificate
echo "Requesting Let's Encrypt certificate..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --tunnel-through-iap \
        --command="DOMAIN=${DOMAIN} EMAIL=${EMAIL} bash -s" <<'CERTBOT'
set -e
cd ~/capstone

ARGS=(--non-interactive --webroot --webroot-path=/var/www/certbot \
      --email "$EMAIL" --agree-tos --no-eff-email -d "$DOMAIN" -d "www.$DOMAIN")

$HOME/bin/docker compose -f docker-compose.prod.yml run --rm --entrypoint certbot certbot certonly "${ARGS[@]}"
echo "Certificate obtained successfully"
CERTBOT

# Configure nginx
echo "Configuring nginx for HTTPS..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --tunnel-through-iap \
        --command="DOMAIN=${DOMAIN} bash -s" <<'SSL_CONFIG'
set -e
cd ~/capstone

echo "Creating redirect.conf (with ACME exception)..."
cat > nginx/conf.d/redirect.conf << 'REDIRECT'
server {
    listen 8080 default_server;
    server_name _;

    # ACME challenge must be served over HTTP - no redirect
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
        try_files $uri =404;
    }

    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}
REDIRECT
echo " ✓ redirect.conf created"

echo "Generating https.conf from template..."
if [ -f nginx/conf.d/https.conf.template ]; then
    sed "s/DOMAIN_NAME/${DOMAIN}/g" nginx/conf.d/https.conf.template > nginx/conf.d/https.conf
    echo " ✓ https.conf generated"
else
    echo " ✗ https.conf.template not found!"
    exit 1
fi

echo "Moving nginx files to prevent conflicts..."
if [ -f nginx/conf.d/default.conf ]; then
    mv nginx/conf.d/default.conf nginx/conf.d/backup.default.conf
    echo " ✓ Renamed default.conf → backup.default.conf"
fi


echo "Reloading nginx..."
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx nginx -s reload || {
    echo "Reload failed, restarting nginx..."
    $HOME/bin/docker compose -f docker-compose.prod.yml restart nginx
}
echo " ✓ Nginx reloaded with SSL"
SSL_CONFIG

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " SSL Setup Completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Test your site now:"
echo "   https://$DOMAIN"
echo ""
echo "If you still see issues, run:"
echo "   gcloud compute ssh $VM_NAME --tunnel-through-iap --command='cd ~/capstone && \$HOME/bin/docker compose -f docker-compose.prod.yml logs nginx'"
