#!/bin/bash

#############################################################################
# Setup SSL with Let's Encrypt (with pre-checks and diagnostics)
#
# Usage: ./scripts/04-setup-ssl.sh yourdomain.com [email]
#
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"
DOMAIN=${1:-""}
EMAIL=${2:-"admin@${DOMAIN}"}

if [ -z "$DOMAIN" ]; then
        echo "Error: Domain name required"
        echo "Usage: $0 <domain-name> [email]"
        exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setting Up SSL for $DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

VM_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --format='value(networkInterfaces[0].accessConfigs[0].natIP)') || {
        echo " ✗ Could not fetch VM IP. Check project/zone/VM name."
        exit 1
}
echo "  VM IP: $VM_IP"
echo ""

# DNS checks
echo "Checking DNS for $DOMAIN and www.$DOMAIN ..."
DOMAIN_IP=$(dig +short "$DOMAIN" @8.8.8.8 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 || true)
WWW_IP=$(dig +short "www.$DOMAIN" @8.8.8.8 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 || true)
echo "  $DOMAIN -> ${DOMAIN_IP:-<not resolved>}"
echo "  www.$DOMAIN -> ${WWW_IP:-<not resolved>}"
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
        read -p "Create cert for www.$DOMAIN anyway? (yes/no): " include_www
        if [ "$include_www" != "yes" ]; then
                INCLUDE_WWW=no
        else
                INCLUDE_WWW=yes
        fi
else
        INCLUDE_WWW=yes
fi
echo ""

# Check firewall rule for TCP:80 (check for both existing naming conventions)
echo "Checking GCP firewall rules for TCP:80 ..."
HTTP_RULE=$(gcloud compute firewall-rules list --project="$PROJECT_ID" --format="table(name,allowed)" | grep -E "tcp:80|http" | head -n1 || true)
if [ -n "$HTTP_RULE" ]; then
        echo " ✓ Found a firewall rule that allows tcp:80 (see below):"
        gcloud compute firewall-rules list --project="$PROJECT_ID" --filter="allowed:(tcp:80)" --format="table(name,network,sourceRanges,targetTags)"
else
        echo " ⚠ No firewall rule found that allows TCP:80 to your project."
        read -p "Create a firewall rule to allow HTTP (tcp:80) targeting VM tag '$VM_NAME'? (yes/no): " create_fw
        if [ "$create_fw" = "yes" ]; then
                # Use the same naming convention as 01-create-vm.sh
                gcloud compute firewall-rules create ${VM_NAME}-allow-http \
                        --project="$PROJECT_ID" \
                        --allow=tcp:80 \
                        --source-ranges=0.0.0.0/0 \
                        --target-tags="$VM_NAME" \
                        --description="Allow HTTP traffic for certbot validation" || {
                        echo " ✗ Failed to create firewall rule. Please create manually and retry."
                        exit 1
                }
                echo " ✓ Firewall rule created."
        else
                echo "Please ensure port 80 is reachable from the internet and re-run this script."
        fi
fi
echo ""

# Quick reachability check to VM IP
echo "Testing HTTP reachability to VM IP ($VM_IP) ..."
if curl -sS --max-time 10 "http://$VM_IP/" >/dev/null 2>&1; then
        echo " ✓ VM HTTP reachable at $VM_IP (port 80)."
else
        echo " ⚠ VM did not respond on port 80. This may be firewall, iptables, or nginx not running."
        read -p "Continue to run checks on VM anyway? (yes/no): " proceed_checks
        if [ "$proceed_checks" != "yes" ]; then
                echo "Aborting."
                exit 1
        fi
fi
echo ""

# Create a test ACME challenge file via certbot container on the VM and verify public reachability
echo "Verifying nginx serves ACME webroot via certbot webroot volume..."

gcloud compute ssh "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --command="bash -s" <<'ENDSSH'
set -e
cd ~/capstone || { echo " ✗ ~/capstone not found on VM"; exit 1; }

# Determine docker / docker-compose CLI on the VM
DOCKER_BIN=""
if [ -x "$HOME/bin/docker" ]; then
    DOCKER_BIN="$HOME/bin/docker"
elif command -v docker >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker)"
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker-compose)"
fi

SUDO_PREFIX=""
if [ -z "$DOCKER_BIN" ]; then
    # Try sudo docker (non-interactive sudo)
    if sudo -n true 2>/dev/null && command -v docker >/dev/null 2>&1; then
        DOCKER_BIN="$(command -v docker)"
        SUDO_PREFIX="sudo "
    else
        echo " ✗ docker or docker-compose not found on VM. Install Docker or ensure \$HOME/bin/docker exists."
        exit 1
    fi
fi

run_compose() {
    # Accepts the docker-compose arguments after -f
    if [ "$(basename "$DOCKER_BIN")" = "docker-compose" ]; then
        $SUDO_PREFIX "$DOCKER_BIN" -f docker-compose.prod.yml "$@"
    else
        $SUDO_PREFIX "$DOCKER_BIN" compose -f docker-compose.prod.yml "$@"
    fi
}

echo "Using Docker binary: $DOCKER_BIN (sudo prefix: '$SUDO_PREFIX')"

# Create test acme challenge file inside certbot webroot (using certbot container to ensure volume is used)
run_compose run --rm --entrypoint sh certbot -c "mkdir -p /var/www/certbot/.well-known/acme-challenge && echo 'certbot-test' > /var/www/certbot/.well-known/acme-challenge/test-file && ls -la /var/www/certbot/.well-known/acme-challenge"

echo "Created test challenge file inside certbot webroot (volume)."

# Verify nginx can see the file by testing from inside the nginx container
echo ""
echo "Verifying nginx can serve the ACME challenge file..."
NGINX_READY=false
for i in {1..5}; do
    if run_compose exec -T nginx curl -sf http://localhost:8080/.well-known/acme-challenge/test-file 2>/dev/null | grep -q "certbot-test"; then
        echo "  ✓ Nginx serving ACME file correctly (attempt $i/5)"
        NGINX_READY=true
        break
    fi
    echo "  [$i/5] Nginx not ready yet, waiting 2s..."
    # Reload nginx to pick up the certbot webroot
    run_compose exec nginx nginx -s reload 2>/dev/null || true
    sleep 2
done

if [ "$NGINX_READY" = false ]; then
    echo "  ✗ WARNING: Nginx cannot serve ACME file from inside container"
    echo "  Continuing anyway, but SSL certificate acquisition may fail..."
fi

# Show nginx container status and recent logs (helpful for debugging)
echo ""
echo "Docker Compose services status:"
run_compose ps || true

echo ""
echo "Last 20 lines of nginx logs (if available):"
run_compose logs --no-color --tail=20 nginx || true

ENDSSH

echo ""
echo "Attempting to fetch the test ACME file from the public internet..."
ACME_REACHABLE=false
for i in {1..15}; do
    if curl -sS --max-time 10 "http://$DOMAIN/.well-known/acme-challenge/test-file" 2>/dev/null | grep -q "certbot-test"; then
        echo " ✓ ACME test file reachable at http://$DOMAIN/.well-known/acme-challenge/test-file (attempt $i/15)"
        ACME_REACHABLE=true
        break
    fi
    echo "  [$i/15] ACME file not reachable yet, retrying in 3s..."
    sleep 3
done

if [ "$ACME_REACHABLE" = false ]; then
    echo ""
    echo " ✗ Could not fetch the test ACME file at http://$DOMAIN/.well-known/acme-challenge/test-file"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Verify iptables rules: sudo iptables -t nat -L PREROUTING -n"
    echo "  2. Check nginx is running: docker compose -f docker-compose.prod.yml ps nginx"
    echo "  3. Check nginx logs: docker compose -f docker-compose.prod.yml logs nginx"
    echo "  4. Test locally on VM: curl http://localhost:8080/.well-known/acme-challenge/test-file"
    echo "  5. Verify GCP firewall allows port 80: gcloud compute firewall-rules list"
    echo ""
    exit 1
fi
echo ""
echo "Docker Compose services status:"
run_compose ps || true

echo ""
echo "Last 20 lines of nginx logs (if available):"
run_compose logs --no-color --tail=20 nginx || true

ENDSSH

echo ""
echo "Attempting to fetch the test ACME file from the public internet..."
if curl -sS --max-time 10 "http://$DOMAIN/.well-known/acme-challenge/test-file" | grep -q "certbot-test"; then
        echo " ✓ ACME test file reachable at http://$DOMAIN/.well-known/acme-challenge/test-file"
else
        echo ""
        echo " ✗ Could not fetch the ACME test file at http://$DOMAIN/.well-known/acme-challenge/test-file"
        echo "Diagnose with the suggested commands printed earlier and fix firewall/nginx/iptables issues."
        exit 1
fi
echo ""

# Prepare certbot domains list
CERTBOT_DOMAINS=("-d" "$DOMAIN")
if [ "$INCLUDE_WWW" = "yes" ]; then
        CERTBOT_DOMAINS+=("-d" "www.$DOMAIN")
fi

# Run certbot to obtain certificates (pass DOMAIN and EMAIL into remote environment)
echo "Obtaining SSL certificate from Let's Encrypt..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --project="$PROJECT_ID" --command="DOMAIN=${DOMAIN} EMAIL=${EMAIL} bash -s" <<'ENDSSH2'
set -e
cd ~/capstone || { echo " ✗ ~/capstone not found on VM"; exit 1; }

# Determine docker / docker-compose CLI on the VM
DOCKER_BIN=""
if [ -x "$HOME/bin/docker" ]; then
    DOCKER_BIN="$HOME/bin/docker"
elif command -v docker >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker)"
elif command -v docker-compose >/dev/null 2>&1; then
    DOCKER_BIN="$(command -v docker-compose)"
fi

SUDO_PREFIX=""
if [ -z "$DOCKER_BIN" ]; then
    if sudo -n true 2>/dev/null && command -v docker >/dev/null 2>&1; then
        DOCKER_BIN="$(command -v docker)"
        SUDO_PREFIX="sudo "
    else
        echo " ✗ docker or docker-compose not found on VM. Install Docker or ensure \$HOME/bin/docker exists."
        exit 1
    fi
fi

run_compose() {
    if [ "$(basename "$DOCKER_BIN")" = "docker-compose" ]; then
        $SUDO_PREFIX "$DOCKER_BIN" -f docker-compose.prod.yml "$@"
    else
        $SUDO_PREFIX "$DOCKER_BIN" compose -f docker-compose.prod.yml "$@"
    fi
}

echo "Using Docker binary: $DOCKER_BIN (sudo prefix: '$SUDO_PREFIX')"

# Build certbot domain args using the DOMAIN and optionally www.DOMAIN env passed in
ARGS=()
ARGS+=(--non-interactive --webroot --webroot-path=/var/www/certbot --email "$EMAIL" --agree-tos --no-eff-email)
ARGS+=( -d "$DOMAIN" )
# If include www was requested, check if DNS exists for it locally (the outer script set INCLUDE_WWW variable)
# For safety, try adding www domain if DNS exists; otherwise skip
if dig +short "www.$DOMAIN" | grep -q .; then
    ARGS+=( -d "www.$DOMAIN" )
fi

# Use run_compose with entrypoint override to run certbot binary
run_compose run --rm --entrypoint certbot certbot certonly "${ARGS[@]}"

echo "✓ Certificate obtained (if no errors above)"
ENDSSH2

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SSL script completed — check certbot output above"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If certbot succeeded, certificates live in the letsencrypt volume and nginx config (https.conf) should be created by your deploy/templating step."
