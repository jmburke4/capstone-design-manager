#!/bin/bash
#############################################################################
# Deploy Application to VM (Updated for consolidated nginx + static SPA)
#
# This script:
# - Copies .env files to VM
# - Pulls latest code from GitHub
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

# Patch DJANGO_ALLOWED_HOSTS — preserve domain + add IP if missing
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

# Ensure repository exists and is up-to-date on VM
echo ""
echo "Ensuring application repository exists and is up-to-date on VM..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --quiet --command='
set -e
cd ~/
if [ -d capstone/.git ]; then
    echo " Repository exists — pulling latest changes..."
    cd capstone
    git fetch origin
    git checkout Cloud-V2
    git pull origin Cloud-V2
else
    echo " Cloning repository for the first time..."
    git clone -b Cloud-V2 https://github.com/jmburke4/capstone-design-manager.git capstone
fi
echo " ✓ Repository ready"
'

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
echo ""
echo "Deploying application on VM..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --command="bash -s" <<'ENDSSH'
set -e
cd ~/capstone
echo "=== Deployment on VM ==="

# Ensure clean nginx config directory
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 0/9 — Preparing nginx configs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
rm -f nginx/conf.d/default.conf nginx/conf.d/redirect.conf nginx/conf.d/https.conf
mkdir -p nginx/conf.d
echo " ✓ Clean nginx config directory prepared"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/9 — Pulling latest code from GitHub (branch: Cloud-V2)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git fetch origin
git checkout Cloud-V2
git pull origin Cloud-V2
echo " ✓ Code updated"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/9 — Building frontend (Vue.js) for production"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd frontend
npm ci --no-audit --no-fund
npm run build
cd ..
echo " ✓ Frontend built (dist/ directory created)"

# Verify dist exists for nginx volume mount
if [ ! -d "frontend/dist" ]; then
    echo " ✗ ERROR: frontend/dist directory not found after build"
    exit 1
fi
echo " ✓ Frontend dist directory verified"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/9 — Stopping existing containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml down 2>/dev/null || echo " ℹ No containers to stop"
echo " ✓ Containers stopped"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/9 — Building Docker images"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DOCKER_BUILDKIT=1 $HOME/bin/docker compose -f docker-compose.prod.yml build --no-cache --progress plain
echo " ✓ Images built"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/9 — Starting containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml up -d
echo " ✓ Containers started"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6/9 — Waiting for database to be ready"
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
echo "Step 7/9 — Running Django migrations and collectstatic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T backend python manage.py migrate --noinput
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T backend python manage.py collectstatic --noinput
echo " ✓ Migrations and static files complete"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 8/9 — Health checks"
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

# Check nginx
if $HOME/bin/docker compose -f docker-compose.prod.yml exec -T nginx curl -sf http://localhost:8080/ >/dev/null 2>&1; then
    echo " ✓ Nginx health check passed"
else
    echo " ⚠ Nginx health check failed — check logs"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=20 nginx || true
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 9/9 — Final nginx config check"
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
for i in {1..10}; do
    if curl -sS --max-time 10 "http://$EXTERNAL_IP/" >/dev/null 2>&1; then
        echo " ✓ Application reachable on HTTP (attempt $i/10)"
        break
    fi
    echo " [$i/10] Retrying in 5s..."
    sleep 5
done

echo ""
echo " ✓ Deployment Complete"
echo ""
echo "🌐 Application URL: http://$EXTERNAL_IP   (and https://ua-capstone-projects.com after SSL setup)"
echo ""
echo "Next step: ./scripts/04-setup-ssl.sh ua-capstone-projects.com your-email@example.com"
echo ""
