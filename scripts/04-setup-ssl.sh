#!/bin/bash
#############################################################################
# Setup SSL with Let's Encrypt (Clean Config Creation - No Sed Mutations)
#
# This script:
# - Verifies DNS records point to the VM
# - Tests ACME challenge reachability
# - Obtains SSL certificate via certbot
# - Generates https.conf from template (no sed mutations of existing files)
# - Creates redirect.conf for HTTP→HTTPS redirect
# - Reloads nginx with new SSL configuration
#
# Usage: ./scripts/04-setup-ssl.sh yourdomain.com [email]
#############################################################################
set -e

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

DOMAIN=${1:-""}
EMAIL=${2:-"admin@${DOMAIN}"}

if [ -z "$DOMAIN" ]; then
        echo "Error: Domain name required"
        echo "Usage: $0 <domain-name> [email]"
        echo "Example: $0 ua-capstone-projects.com admin@ua-capstone-projects.com"
        exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Setting Up SSL for $DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get VM IP
VM_IP=$(gcloud compute instances describe "$VM_NAME" \
        --zone="$ZONE" \
        --project="$PROJECT_ID" \
        --format='value(networkInterfaces[0].accessConfigs[0].natIP)') || {
        echo " ✗ Could not fetch VM IP. Check project/zone/VM name."
        exit 1
}
echo " VM IP: $VM_IP"
echo ""

# DNS checks
echo "Checking DNS for $DOMAIN and www.$DOMAIN..."
DOMAIN_IP=$(dig +short "$DOMAIN" @8.8.8.8 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 || true)
WWW_IP=$(dig +short "www.$DOMAIN" @8.8.8.8 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 || true)

echo " $DOMAIN -> ${DOMAIN_IP:-<not resolved>}"
echo " www.$DOMAIN -> ${WWW_IP:-<not resolved>}"
echo ""

if [ -z "$DOMAIN_IP" ]; then
        echo " ✗ ERROR: $DOMAIN does not resolve. Point an A record to $VM_IP and retry."
        exit 1
fi

if [ "$DOMAIN_IP" != "$VM_IP" ]; then
        echo " ⚠ WARNING: DNS for $DOMAIN resolves to $DOMAIN_IP (expected $VM_IP)."
        read -p "Continue anyway? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
                echo "Aborting."
                exit 1
        fi
else
        echo " ✓ DNS for $DOMAIN resolves to VM IP"
fi

if [ -z "$WWW_IP" ]; then
        echo " ⚠ NOTE: www.$DOMAIN does not resolve."
        read -p "Include www.$DOMAIN in the certificate anyway? (yes/no): " include_www
        INCLUDE_WWW=${include_www:-no}
else
        INCLUDE_WWW=yes
fi
echo ""

# Check firewall for port 80
echo "Checking GCP firewall rules for TCP:80..."
if gcloud compute firewall-rules describe "${VM_NAME}-allow-http" \
        --project="$PROJECT_ID" &>/dev/null; then
        echo " ✓ Firewall rule allowing tcp:80 found"
else
        echo " ⚠ No firewall rule found that allows TCP:80."
        read -p "Create ${VM_NAME}-allow-http rule now? (yes/no): " create_fw
        if [ "$create_fw" = "yes" ]; then
                gcloud compute firewall-rules create "${VM_NAME}-allow-http" \
                        --project="$PROJECT_ID" \
                        --allow=tcp:80 \
                        --source-ranges=0.0.0.0/0 \
                        --target-tags="$VM_NAME" \
                        --description="Allow HTTP traffic for certbot validation" \
                        --quiet
                echo " ✓ Firewall rule created."
        else
                echo "Please ensure port 80 is reachable and retry."
                exit 1
        fi
fi

# Quick reachability check
echo "Testing HTTP reachability to VM IP ($VM_IP)..."
if curl -sS --max-time 10 "http://$VM_IP/" >/dev/null 2>&1; then
        echo " ✓ VM is reachable on port 80 via public IP."
else
        echo " ⚠ VM did not respond on port 80 (firewall / iptables / nginx issue possible)."
        read -p "Continue anyway? (yes/no): " proceed
        if [ "$proceed" != "yes" ]; then
                echo "Aborting."
                exit 1
        fi
fi
echo ""

# Test ACME challenge setup
echo "Testing that nginx can serve Let's Encrypt challenge files..."
gcloud compute ssh "$VM_NAME" \
        --zone="$ZONE" \
        --project="$PROJECT_ID" \
        --tunnel-through-iap \
        --command="bash -s" <<'ENDSSH'

set -e
cd ~/capstone || { echo " ✗ ~/capstone directory not found"; exit 1; }

# Determine Docker binary (rootless)
DOCKER_BIN="$HOME/bin/docker"
if [ ! -x "$DOCKER_BIN" ]; then
    echo " ✗ Rootless Docker not found at $HOME/bin/docker"
    exit 1
fi

run_compose() {
    "$DOCKER_BIN" compose -f docker-compose.prod.yml "$@"
}

echo "Using Docker binary: $DOCKER_BIN"

# Create test challenge file
run_compose run --rm --entrypoint sh certbot -c '
    mkdir -p /var/www/certbot/.well-known/acme-challenge &&
    echo "certbot-test-$$" > /var/www/certbot/.well-known/acme-challenge/test-file &&
    ls -la /var/www/certbot/.well-known/acme-challenge
'

echo " ✓ Test file created in certbot webroot volume"

# Verify nginx can serve it internally
echo ""
echo "Verifying nginx serves the challenge file internally..."
NGINX_READY=false
for i in {1..8}; do
    if run_compose exec -T nginx curl -sf http://localhost:8080/.well-known/acme-challenge/test-file 2>/dev/null | grep -q "certbot-test"; then
        echo " ✓ Nginx serving ACME file correctly (attempt $i/8)"
        NGINX_READY=true
        break
    fi
    echo " [$i/8] Retrying in 2s..."
    run_compose exec nginx nginx -s reload 2>/dev/null || true
    sleep 2
done

if [ "$NGINX_READY" = false ]; then
    echo " ✗ WARNING: Nginx could not serve the test file internally."
    echo "   SSL issuance will likely fail."
fi

echo ""
echo "Nginx container status:"
run_compose ps nginx || true
echo ""
echo "Recent nginx logs:"
run_compose logs --no-color --tail=30 nginx || true
ENDSSH

echo ""
echo "Attempting to fetch the test ACME file from the public internet ($DOMAIN)..."
ACME_REACHABLE=false
for i in {1..15}; do
        if curl -sS --max-time 10 "http://$DOMAIN/.well-known/acme-challenge/test-file" 2>/dev/null | grep -q "certbot-test"; then
                echo " ✓ ACME test file is publicly reachable (attempt $i/15)"
                ACME_REACHABLE=true
                break
        fi
        echo " [$i/15] Not reachable yet... retrying in 3s"
        sleep 3
done

if [ "$ACME_REACHABLE" = false ]; then
        echo ""
        echo " ✗ CRITICAL: Test ACME file is NOT reachable from the internet."
        echo "   Let's Encrypt will fail to validate the domain."
        echo ""
        echo "Troubleshooting steps on the VM:"
        echo "   sudo iptables -t nat -L PREROUTING -n -v"
        echo "   docker compose -f docker-compose.prod.yml ps"
        echo "   docker compose -f docker-compose.prod.yml logs nginx"
        echo "   curl -I http://localhost:8080/.well-known/acme-challenge/test-file"
        echo ""
        exit 1
fi

echo ""
echo " ✓ ACME challenge test passed successfully!"
echo ""

# Obtain the certificate
echo "Obtaining SSL certificate from Let's Encrypt..."
gcloud compute ssh "$VM_NAME" \
        --zone="$ZONE" \
        --project="$PROJECT_ID" \
        --tunnel-through-iap \
        --command="DOMAIN=${DOMAIN} EMAIL=${EMAIL} INCLUDE_WWW=${INCLUDE_WWW} bash -s" <<'ENDSSH2'

set -e
cd ~/capstone || { echo " ✗ ~/capstone not found"; exit 1; }

DOCKER_BIN="$HOME/bin/docker"
run_compose() {
    "$DOCKER_BIN" compose -f docker-compose.prod.yml "$@"
}

echo "Using Docker binary: $DOCKER_BIN"

ARGS=(--non-interactive --webroot --webroot-path=/var/www/certbot \
      --email "$EMAIL" --agree-tos --no-eff-email)

ARGS+=(-d "$DOMAIN")
if [ "${INCLUDE_WWW}" = "yes" ]; then
    ARGS+=(-d "www.$DOMAIN")
fi

echo "Running certbot with domains: $DOMAIN $( [ "${INCLUDE_WWW}" = "yes" ] && echo "www.$DOMAIN" )"

run_compose run --rm --entrypoint certbot certbot certonly "${ARGS[@]}"

echo " ✓ Certificate obtained successfully"
ENDSSH2

echo ""
echo "Configuring nginx for HTTPS..."
gcloud compute ssh "$VM_NAME" \
        --zone="$ZONE" \
        --project="$PROJECT_ID" \
        --tunnel-through-iap \
        --command="DOMAIN=${DOMAIN} bash -s" <<'ENDSSH3'
set -e
cd ~/capstone

# Verify certificate exists
if ! $HOME/bin/docker compose -f docker-compose.prod.yml exec -T certbot test -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" 2>/dev/null; then
    echo " ✗ Certificate not found"
    exit 1
fi
echo " ✓ Certificate verified"

# Create redirect.conf (HTTP → HTTPS)
cat > nginx/conf.d/redirect.conf << 'EOF'
server {
    listen 8080 default_server;
    server_name _;

    # Allow Let's Encrypt ACME challenges
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}
EOF
echo " ✓ redirect.conf created (HTTP → HTTPS)"

# Generate https.conf from template (clean & reliable)
if [ -f nginx/conf.d/https.conf.template ]; then
    echo " Generating https.conf from template..."
    sed "s/DOMAIN_NAME/${DOMAIN}/g" nginx/conf.d/https.conf.template > nginx/conf.d/https.conf
    echo " ✓ https.conf generated successfully"
else
    echo " ✗ ERROR: https.conf.template not found"
    exit 1
fi

# Remove any old conflicting files
rm -f nginx/conf.d/default.conf

# Reload nginx
echo " Reloading nginx..."
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx nginx -s reload || {
    echo "   Reload failed, restarting nginx..."
    $HOME/bin/docker compose -f docker-compose.prod.yml restart nginx
    sleep 3
}

echo " ✓ Nginx reloaded with new HTTPS + Admin proxy configuration"
ENDSSH3

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " SSL Setup Completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo " • Test your site at https://$DOMAIN"
echo " • Test HTTP→HTTPS redirect: curl -I http://$DOMAIN"
echo " • Check nginx logs if needed:"
echo "   gcloud compute ssh $VM_NAME --tunnel-through-iap --command='cd ~/capstone && \$HOME/bin/docker compose -f docker-compose.prod.yml logs nginx'"
echo ""
