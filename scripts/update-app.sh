#!/bin/bash

#############################################################################
# Update Application
#
# Pulls latest code and rebuilds/restarts containers
# Zero-downtime deployment
#
# Usage: ./scripts/update-app.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Updating Application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="bash -s" << 'ENDSSH'

set -e

cd ~/capstone

echo "=== Updating Application ==="
echo ""

# Pull latest code
echo "1. Pulling latest code from GitHub (branch: Cloud-V2)..."
git fetch origin
git checkout Cloud-V2
git pull origin Cloud-V2
echo "  ✓ Code updated"

# Rebuild and restart containers
echo ""
echo "2. Rebuilding containers..."
cd ~/capstone
$HOME/bin/docker compose -f docker-compose.prod.yml build
$HOME/bin/docker compose -f docker-compose.prod.yml up -d --no-deps --build

echo "  ✓ Containers rebuilt and restarted"

# Wait for health check
echo ""
echo "3. Waiting for services to be ready..."
sleep 10

for i in {1..10}; do
    if curl -s http://localhost/api/v1/health/ > /dev/null 2>&1; then
        echo "  ✓ Application is healthy"
        break
    fi
    echo "  Waiting... (attempt $i/10)"
    sleep 3
done

# Show container status
echo ""
echo "4. Container status:"
cd ~/capstone
$HOME/bin/docker compose -f docker-compose.prod.yml ps

echo ""
echo "=== Update Complete ==="

ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Application Updated"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
