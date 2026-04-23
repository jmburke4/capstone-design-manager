#!/bin/bash
#############################################################################
# Deploy Application to VM (Updated for consolidated nginx + static SPA)
#
# This script:
# - Copies .env files to VM
# - Builds frontend (Vue) for production on the VM
# - Builds Docker images
# - Starts containers with docker-compose
# - Runs migrations and collectstatic
#
# Usage: ./scripts/03-deploy-app.sh
#############################################################################
set -e

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# All SSH/SCP is routed through IAP
SSH_FLAGS="--zone=$ZONE --project=$PROJECT_ID --tunnel-through-iap"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Deploying Application to VM (Consolidated Nginx)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify .env files exist
echo "Checking environment files..."
if [ ! -f ".env.production" ]; then
        echo " ✗ .env.production not found"
        echo " Run: ./scripts/generate-secrets.sh ua-capstone-projects.com first"
        exit 1
fi
if [ ! -f ".env.production.db" ]; then
        echo " ✗ .env.production.db not found"
        exit 1
fi
if [ ! -f "frontend/.env.production" ]; then
        echo " ✗ frontend/.env.production not found"
        exit 1
fi
echo " ✓ All environment files found"

# Fetch VM external IP
echo ""
echo "Fetching VM external IP..."
EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME \
        --zone=$ZONE \
        --project=$PROJECT_ID \
        --format='value(networkInterfaces[0].accessConfigs[0].natIP)')
if [ -z "$EXTERNAL_IP" ]; then
        echo " ✗ Could not fetch external IP"
        exit 1
fi
echo " ✓ VM external IP: $EXTERNAL_IP"

# DJANGO_ALLOWED_HOSTS — preserve domain + add IP if missing (this fixed a specific issue I was u)
echo ""
echo "Updating DJANGO_ALLOWED_HOSTS (preserves domain)..."
if grep -q "^DJANGO_ALLOWED_HOSTS=" .env.production; then
        CURRENT_HOSTS=$(grep "^DJANGO_ALLOWED_HOSTS=" .env.production | cut -d'=' -f2-)
        if ! echo "$CURRENT_HOSTS" | grep -q "$EXTERNAL_IP"; then
                NEW_HOSTS="$CURRENT_HOSTS $EXTERNAL_IP"
        else
                NEW_HOSTS="$CURRENT_HOSTS"
        fi
        sed -i.bak "s|^DJANGO_ALLOWED_HOSTS=.*|DJANGO_ALLOWED_HOSTS=$NEW_HOSTS|" .env.production
        echo " ✓ DJANGO_ALLOWED_HOSTS updated: $NEW_HOSTS (domain preserved)"
else
        echo "DJANGO_ALLOWED_HOSTS=ua-capstone-projects.com www.ua-capstone-projects.com $EXTERNAL_IP localhost 127.0.0.1 backend" >>.env.production
        echo " ✓ DJANGO_ALLOWED_HOSTS appended"
fi

# Copy .env files
echo ""
echo "Copying environment files to VM..."
gcloud compute scp .env.production ${VM_NAME}:~/${APP_DIR}/ $SSH_FLAGS --quiet
gcloud compute scp .env.production.db ${VM_NAME}:~/${APP_DIR}/ $SSH_FLAGS --quiet
gcloud compute scp frontend/.env.production ${VM_NAME}:~/${APP_DIR}/frontend/ $SSH_FLAGS --quiet
echo " ✓ Environment files copied"

# Fix permissions
echo ""
echo "Setting secure permissions on environment files..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --command="chmod 600 ~/${APP_DIR}/.env.production ~/${APP_DIR}/.env.production.db ~/${APP_DIR}/frontend/.env.production"
echo " ✓ Permissions set (600)"

# Deploy on VM
# NOTE: The heredoc marker is QUOTED ('ENDSSH') to prevent local shell expansion
# of variables like $HOME, $i, etc. inside the remote script.
echo ""
echo "Deploying application on VM..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --command="bash -s" <<'ENDSSH'
set -e
cd ~/capstone
echo "=== Deployment on VM ==="

# Ensure nginx config directory exists with valid config
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 0/8 — Preparing nginx configs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify default.conf exists (committed in repo, required for initial HTTP serving)
if [ ! -f nginx/conf.d/default.conf ]; then
    echo " ✗ ERROR: nginx/conf.d/default.conf not found!"
    echo "   This file should be in the repository. It is required for nginx to serve HTTP."
    echo "   Check: git status nginx/conf.d/"
    exit 1
fi
echo " ✓ Nginx config ready (default.conf present)"

# Verify we have at least one valid server config
if [ ! -f nginx/conf.d/default.conf ] && [ ! -f nginx/conf.d/https.conf ]; then
    echo " ✗ ERROR: No nginx server configuration files found in nginx/conf.d/"
    echo "   nginx will fail without a valid config. Ensure default.conf is committed."
    exit 1
fi

# Verify iptables port forwarding is still active
echo ""
echo "Verifying iptables port forwarding..."
if sudo iptables -t nat -L PREROUTING -n | grep -q "REDIRECT.*8080"; then
    echo " ✓ Port 80→8080 forwarding active"
else
    echo " ⚠ WARNING: iptables port forwarding not detected!"
    if [ -f /etc/iptables/rules.v4 ]; then
        echo "   Restoring from saved rules..."
        sudo iptables-restore < /etc/iptables/rules.v4
        sleep 1
        if sudo iptables -t nat -L PREROUTING -n | grep -q "REDIRECT.*8080"; then
            echo " ✓ Port forwarding restored"
        else
            echo " ✗ ERROR: Could not restore port forwarding. Port 80 will NOT be reachable."
        fi
    else
        echo " ✗ ERROR: iptables rules file not found. Run 02-setup-vm.sh first."
    fi
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1.5/8 —  Building Frontend (Static Files)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"  

cd $HOME/capstone/frontend
echo "Building frontend to serv to Nginx.."
npm ci --no-audit --no-fund          # clean install for production
npm run build              # creates /dist folder
cd ..
echo " ✓ Frontend successfully built → ./frontend/dist"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/8 — Stopping existing containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml down 2>/dev/null || echo " ℹ No containers to stop"
echo " ✓ Containers stopped"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/8 — Building Docker images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DOCKER_BUILDKIT=1 $HOME/bin/docker compose -f docker-compose.prod.yml build --no-cache --progress plain
echo " ✓ Images built"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/8 — Starting containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml up -d
echo " ✓ Containers started"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/8 — Waiting for database to be ready"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for i in {1..30}; do
    if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T db pg_isready -U postgres 2>/dev/null | grep -q "accepting connections"; then
        echo " ✓ Database is ready (attempt $i/30)"
        break
    fi
    echo " [$i/30] Waiting for database..."
    sleep 2
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6/8 — Running Django migrations and collectstatic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run migrations with error handling (don't let set -e kill the whole script)
echo "Running migrations..."
if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T backend python manage.py migrate --noinput; then
    echo " ✓ Migrations completed"
else
    echo " ⚠ WARNING: Migrations had errors (showing last 30 lines of backend logs):"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=30 backend || true
    echo ""
    echo "   Deployment will continue, but application may have database issues."
fi

# Run collectstatic with error handling
echo ""
echo "Collecting static files..."
if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T backend python manage.py collectstatic --noinput; then
    echo " ✓ Static files collected"
else
    echo " ⚠ WARNING: collectstatic had errors"
    echo "   Static assets (CSS/JS/admin styling) may not work properly."
fi

echo " ✓ Step 6 complete"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 7/8 — Health checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml ps

# Check backend health
for i in {1..10}; do
    if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T backend curl -sf http://localhost:8000/api/v1/health/ >/dev/null 2>&1; then
        echo " ✓ Backend health check passed (attempt $i/10)"
        break
    fi
    echo " [$i/10] Backend health check pending..."
    sleep 3
done

# Check nginx with retries (it may need time to start)
echo ""
echo "Checking nginx health..."
sleep 3
NGINX_HEALTHY=false
for i in {1..10}; do
    if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx curl -sf http://localhost:8080/ >/dev/null 2>&1; then
        echo " ✓ Nginx health check passed (attempt $i/10)"
        NGINX_HEALTHY=true
        break
    fi
    echo " [$i/10] Waiting for nginx to be ready..."
    sleep 2
done

if [ "$NGINX_HEALTHY" = false ]; then
    echo " ✗ Nginx health check failed — diagnosing:"
    echo ""
    echo "Container status:"
    $HOME/bin/docker compose -f docker-compose.prod.yml ps nginx || true
    echo ""
    echo "Nginx logs (last 50 lines):"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=50 nginx || true
    echo ""
    echo "Checking nginx configuration:"
    $HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx nginx -t 2>&1 || true
    echo ""
    echo "Checking for config files in /etc/nginx/conf.d/:"
    $HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx ls -la /etc/nginx/conf.d/ 2>&1 || true
    echo ""
    echo " ✗ WARNING: Nginx is not responding. Application will not be reachable."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 8/8 — Final nginx config check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx nginx -t || echo " ⚠ Nginx config test failed"

echo ""
echo "=== Deployment on VM Complete ==="
ENDSSH

# External connectivity test
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing External Connectivity..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
REACHED=false
for i in {1..10}; do
        if curl -sS --max-time 10 "http://$EXTERNAL_IP/" >/dev/null 2>&1; then
                echo " ✓ Application reachable on HTTP (attempt $i/10)"
                REACHED=true
                break
        fi
        echo " [$i/10] Retrying in 5s..."
        sleep 5
done

if [ "$REACHED" = false ]; then
        echo " ⚠ Application not reachable after 10 attempts — check firewall rules and nginx logs"
fi

echo ""
echo " ✓ Deployment Complete"
echo ""
echo "🌐 Application URL: http://$EXTERNAL_IP   (and https://ua-capstone-projects.com after SSL setup)"
echo ""
echo "Next step: ./scripts/04-setup-ssl.sh"
echo ""
