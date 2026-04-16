#!/bin/bash

#############################################################################
# Main Deployment Orchestrator
#
# Runs all deployment steps in sequence
#
# Usage: ./scripts/deploy.sh
#############################################################################

set -e

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_header "Capstone Design Manager - Deployment"

echo "This script will guide you through the complete deployment process."
echo ""
echo "Steps:"
echo "  1. Create GCE VM"
echo "  2. Setup VM with Docker"
echo "  3. Generate secrets"
echo "  4. Deploy application"
echo "  5. (Optional) Setup SSL"
echo "  6. (Optional) Setup backups"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Step 1: Create VM
print_header "Step 1: Create VM"
./scripts/01-create-vm.sh

# Step 2: Setup VM
print_header "Step 2: Setup VM"
./scripts/02-setup-vm.sh

# Step 3: Generate secrets
print_header "Step 3: Generate Secrets"
./scripts/generate-secrets.sh
echo ""
echo "✓ Secrets generated with VM IP automatically configured"
echo ""

# Step 4: Deploy application
print_header "Step 4: Deploy Application"
./scripts/03-deploy-app.sh

# Get VM IP
VM_IP=$(gcloud compute instances describe capstone-prod-vm \
    --zone=us-central1-b \
    --project=capstone-design-app-prod \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)')

print_header "Deployment Complete!"

echo -e "${GREEN}✓${NC} Application deployed successfully"
echo ""
echo "Application URL: http://$VM_IP"
echo ""
echo "Next steps:"
echo "  1. Test: http://$VM_IP"
echo "  2. Create Django superuser (see docs/VM_QUICKSTART.md)"
echo "  3. Setup domain & SSL: ./scripts/04-setup-ssl.sh yourdomain.com"
echo "  4. Setup backups: ./scripts/05-setup-backups.sh"
echo ""
