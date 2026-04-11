#!/bin/bash
#############################################################################
# Deploy Application to VM
#
# This script:
# - Copies .env files to VM
# - Pulls latest code from GitHub
# - Builds Docker images
# - Starts containers with docker-compose
# - Runs migrations and collectstatic
#
# Usage: ./scripts/03-deploy-app.sh
#
# Prerequisites:
#   Firewall rule allowing SSH via IAP (run once):
#   gcloud compute firewall-rules create allow-ssh-iap \
#     --project=capstone-design-app-prod \
#     --allow=tcp:22 \
#     --source-ranges=35.235.240.0/20 \
#     --description="Allow SSH via IAP tunnel only"
#############################################################################
set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"
APP_DIR="capstone"

# All SSH/SCP is routed through IAP — port 22 does not need to be open to the internet
SSH_FLAGS="--zone=$ZONE --project=$PROJECT_ID --tunnel-through-iap"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Deploying Application to VM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify .env files exist
echo "Checking environment files..."
if [ ! -f ".env.production" ]; then
        echo " ✗ .env.production not found"
        echo " Run: ./scripts/generate-secrets.sh first"
        exit 1
fi
if [ ! -f ".env.production.db" ]; then
        echo " ✗ .env.production.db not found"
        echo " Run: ./scripts/generate-secrets.sh first"
        exit 1
fi
if [ ! -f "frontend/.env.production" ]; then
        echo " ✗ frontend/.env.production not found"
        echo " Run: ./scripts/generate-secrets.sh first"
        exit 1
fi
echo " ✓ All environment files found"

# Fetch VM external IP and auto-configure DJANGO_ALLOWED_HOSTS
echo ""
echo "Fetching VM external IP..."
EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME \
        --zone=$ZONE \
        --project=$PROJECT_ID \
        --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

if [ -z "$EXTERNAL_IP" ]; then
        echo " ✗ Could not fetch external IP — is the VM running?"
        echo " Check: gcloud compute instances list --project=$PROJECT_ID"
        exit 1
fi
echo " ✓ VM external IP: $EXTERNAL_IP"

# Patch DJANGO_ALLOWED_HOSTS in .env.production (handles CHANGE_ME placeholder or stale IP)
if grep -q "DJANGO_ALLOWED_HOSTS" .env.production; then
        sed -i.bak "s|^DJANGO_ALLOWED_HOSTS=.*|DJANGO_ALLOWED_HOSTS=$EXTERNAL_IP|" .env.production
        echo " ✓ DJANGO_ALLOWED_HOSTS set to $EXTERNAL_IP in .env.production"
else
        echo "DJANGO_ALLOWED_HOSTS=$EXTERNAL_IP" >>.env.production
        echo " ✓ DJANGO_ALLOWED_HOSTS appended to .env.production"
fi
echo " ✓ Environment files validated"

# Ensure repository exists and is up-to-date BEFORE copying .env files
echo ""
echo "Ensuring application repository exists and is up-to-date on VM..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --quiet --command='
set -e
cd ~/
if [ -d capstone/.git ]; then
    echo "  Repository exists — pulling latest changes..."
    cd capstone
    git fetch origin
    git checkout Cloud-V2
    git pull origin Cloud-V2
else
    echo "  Cloning repository for the first time..."
    git clone -b Cloud-V2 https://github.com/jmburke4/capstone-design-manager.git capstone
fi
echo " ✓ Repository ready"
'

# Copy .env files to VM (directory now guaranteed to exist)
echo ""
echo "Copying environment files to VM..."
gcloud compute scp .env.production ${VM_NAME}:~/${APP_DIR}/ $SSH_FLAGS --quiet
gcloud compute scp .env.production.db ${VM_NAME}:~/${APP_DIR}/ $SSH_FLAGS --quiet
gcloud compute scp frontend/.env.production ${VM_NAME}:~/${APP_DIR}/frontend/ $SSH_FLAGS --quiet
echo " ✓ Environment files copied"

# Fix permissions on copied files (SCP doesn't preserve 600 permissions)
echo ""
echo "Setting secure permissions on environment files..."
gcloud compute ssh $VM_NAME $SSH_FLAGS --command="chmod 600 ~/${APP_DIR}/.env.production ~/${APP_DIR}/.env.production.db ~/${APP_DIR}/frontend/.env.production"
echo " ✓ Permissions set (600)"

# Deploy on VM
echo ""
echo "Deploying application on VM..."
echo ""

gcloud compute ssh $VM_NAME $SSH_FLAGS --command="bash -s" <<'ENDSSH'
set -e
cd ~/capstone
echo "=== Deployment on VM ==="
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1/7 — Pulling latest code from GitHub (branch: Cloud-V2)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git fetch origin
git checkout Cloud-V2
git pull origin Cloud-V2
echo " ✓ Code updated"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2/7 — Stopping existing containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml down 2>/dev/null || echo " ℹ No containers to stop"
echo " ✓ Containers stopped"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3/7 — Building Docker images (live output)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Each '#N' line below is one Dockerfile instruction completing."
echo ""
DOCKER_BUILDKIT=1 $HOME/bin/docker compose -f docker-compose.prod.yml build \
    --no-cache \
    --progress plain
echo ""
echo " ✓ Images built"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4/7 — Starting containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml up -d
echo " ✓ Containers started"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5/7 — Waiting for services to be healthy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Wait for database to be healthy first (backend depends on it)
echo ""
echo "  Waiting for database..."
DB_HEALTHY=false
for i in {1..30}; do
    if $HOME/bin/docker compose -f docker-compose.prod.yml ps db | grep -q "healthy"; then
        echo "  ✓ Database is healthy (attempt $i/30)"
        DB_HEALTHY=true
        break
    fi
    echo "    [$i/30] Database not ready yet..."
    sleep 2
done

if [ "$DB_HEALTHY" = false ]; then
    echo "  ✗ ERROR: Database failed to become healthy after 60 seconds"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=30 db
    exit 1
fi

# Wait for backend to complete migrations and become healthy
echo ""
echo "  Waiting for backend..."
BACKEND_HEALTHY=false
for i in {1..30}; do
    if $HOME/bin/docker compose -f docker-compose.prod.yml ps backend | grep -q "healthy"; then
        echo "  ✓ Backend is healthy (attempt $i/30)"
        BACKEND_HEALTHY=true
        break
    fi
    echo "    [$i/30] Backend not ready yet..."
    sleep 2
done

if [ "$BACKEND_HEALTHY" = false ]; then
    echo "  ✗ ERROR: Backend failed to become healthy after 60 seconds"
    echo ""
    echo "  Recent backend logs:"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=30 backend
    exit 1
fi

echo ""
echo " ✓ All services are healthy"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 6/7 — Verifying container health"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$HOME/bin/docker compose -f docker-compose.prod.yml ps

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 7/7 — Testing health endpoint"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HEALTH_OK=false
for i in {1..10}; do
    # Test through nginx on port 8080 (backend is not exposed on host directly)
    if curl -s http://localhost:8080/api/v1/health/ > /dev/null 2>&1; then
        echo " ✓ Health check passed (attempt $i/10)"
        HEALTH_OK=true
        break
    fi
    echo " [$i/10] Backend not yet ready — retrying in 3 seconds..."
    sleep 3
done

if [ "$HEALTH_OK" = false ]; then
    echo ""
    echo " ✗ Health check did not pass after 10 attempts."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Backend Container Logs (last 50 lines):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    $HOME/bin/docker compose -f docker-compose.prod.yml logs --tail=50 backend
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "All Container Status:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    $HOME/bin/docker compose -f docker-compose.prod.yml ps
    echo ""
    echo "To debug further:"
    echo "  gcloud compute ssh $VM_NAME --zone=$ZONE"
    echo "  cd ~/capstone"
    echo "  docker compose -f docker-compose.prod.yml logs backend"
    echo ""
    exit 1
fi

echo ""
echo "=== Deployment on VM Complete ==="
ENDSSH

# Test external connectivity from local machine
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing External Connectivity..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

EXTERNAL_ACCESS=false
for i in {1..10}; do
    if curl -sS --max-time 5 "http://$EXTERNAL_IP/" >/dev/null 2>&1; then
        echo " ✓ Application accessible externally at http://$EXTERNAL_IP"
        EXTERNAL_ACCESS=true
        break
    fi
    echo "  [$i/10] Waiting for external access... retrying in 3s"
    sleep 3
done

if [ "$EXTERNAL_ACCESS" = false ]; then
    echo ""
    echo " ⚠ WARNING: Application not responding on external IP"
    echo ""
    echo "This is likely due to rootless Docker networking issues."
    echo "To fix, SSH to the VM and run:"
    echo "  sudo iptables -t nat -F PREROUTING"
    echo "  sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080"
    echo "  sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443"
    echo ""
    echo "Or check if nginx is running:"
    echo "  gcloud compute ssh $VM_NAME $SSH_FLAGS --command='docker compose -f docker-compose.prod.yml ps'"
    echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✓ Deployment Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Application URL: http://$EXTERNAL_IP"
echo ""
echo "Test health check:"
echo " curl http://$EXTERNAL_IP/api/v1/health/"
echo ""
echo "View logs on VM:"
echo " gcloud compute ssh $VM_NAME $SSH_FLAGS"
echo " cd ~/capstone"
echo " \$HOME/bin/docker compose -f docker-compose.prod.yml logs -f"
echo ""
echo "Next steps:"
echo " 1. Test application at: http://$EXTERNAL_IP"
echo " 2. Create Django superuser (see docs)"
echo " 3. Setup SSL with: ./scripts/04-setup-ssl.sh yourdomain.com"
echo ""
