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
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"
APP_DIR="capstone"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Deploying Application to VM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify .env files exist
echo "Checking environment files..."
if [ ! -f ".env.production" ]; then
    echo "  ✗ .env.production not found"
    echo "  Run: ./scripts/generate-secrets.sh first"
    exit 1
fi

if [ ! -f ".env.production.db" ]; then
    echo "  ✗ .env.production.db not found"
    echo "  Run: ./scripts/generate-secrets.sh first"
    exit 1
fi

if [ ! -f "frontend/.env.production" ]; then
    echo "  ✗ frontend/.env.production not found"
    echo "  Run: ./scripts/generate-secrets.sh first"
    exit 1
fi

echo "  ✓ All environment files found"

# Verify DJANGO_ALLOWED_HOSTS is configured
if grep -q "CHANGE_ME_TO_YOUR_DOMAIN_OR_IP" .env.production; then
    echo ""
    echo "  ✗ ERROR: DJANGO_ALLOWED_HOSTS not configured in .env.production"
    echo "  Please edit .env.production and update DJANGO_ALLOWED_HOSTS"
    exit 1
fi

echo "  ✓ Environment files validated"

# Copy .env files to VM
echo ""
echo "Copying environment files to VM..."

gcloud compute scp .env.production ${VM_NAME}:~/${APP_DIR}/ --zone=$ZONE --project=$PROJECT_ID --quiet
gcloud compute scp .env.production.db ${VM_NAME}:~/${APP_DIR}/ --zone=$ZONE --project=$PROJECT_ID --quiet
gcloud compute scp frontend/.env.production ${VM_NAME}:~/${APP_DIR}/frontend/ --zone=$ZONE --project=$PROJECT_ID --quiet

echo "  ✓ Environment files copied"

# Deploy on VM
echo ""
echo "Deploying application on VM..."
echo "  ⏱ This will take 10-15 minutes (building images)..."
echo ""

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="bash -s" << 'ENDSSH'

set -e

cd ~/capstone

echo "=== Deployment on VM ==="
echo ""

# Pull latest code
echo "1. Pulling latest code from GitHub (branch: Cloud-V2)..."
git fetch origin
git checkout Cloud-V2
git pull origin Cloud-V2
echo "  ✓ Code updated"

# Stop existing containers (if any)
echo ""
echo "2. Stopping existing containers..."
docker compose -f docker-compose.prod.yml down 2>/dev/null || echo "  ℹ No containers to stop"

# Build images
echo ""
echo "3. Building Docker images..."
echo "  ⏱ This will take 10-15 minutes on first run..."
cd ~/capstone
$HOME/bin/docker compose -f docker-compose.prod.yml build --no-cache

echo "  ✓ Images built"

# Start containers
echo ""
echo "4. Starting containers..."
cd ~/capstone
$HOME/bin/docker compose -f docker-compose.prod.yml up -d

echo "  ✓ Containers started"

# Wait for backend to be healthy
echo ""
echo "5. Waiting for backend to be ready..."
sleep 15

# Check container status
echo ""
echo "6. Verifying container health..."
cd ~/capstone
$HOME/bin/docker compose -f docker-compose.prod.yml ps

# Test health endpoint
echo ""
echo "7. Testing health endpoint..."
for i in {1..10}; do
    if curl -s http://localhost/api/v1/health/ > /dev/null 2>&1; then
        echo "  ✓ Health check passed"
        break
    fi
    echo "  Waiting for backend... (attempt $i/10)"
    sleep 3
done

echo ""
echo "=== Deployment on VM Complete ==="

ENDSSH

# Get VM external IP
EXTERNAL_IP=$(gcloud compute instances describe $VM_NAME --zone=$ZONE --project=$PROJECT_ID --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Deployment Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Application URL: http://$EXTERNAL_IP"
echo ""
echo "Test health check:"
echo "  curl http://$EXTERNAL_IP/api/v1/health/"
echo ""
echo "View logs on VM:"
echo "  gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID"
echo "  cd ~/capstone"
echo "  docker compose -f docker-compose.prod.yml logs -f"
echo ""
echo "Next steps:"
echo "  1. Test application at: http://$EXTERNAL_IP"
echo "  2. Create Django superuser (see docs)"
echo "  3. Setup SSL with: ./scripts/04-setup-ssl.sh yourdomain.com"
echo ""
