#!/bin/bash

#############################################################################
# Main Deployment Script for Capstone Design Manager
# 
# This script orchestrates the deployment process
# 
# Usage:
#   ./scripts/deploy.sh [staging|production] [--skip-build]
#
#############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Parse arguments
ENVIRONMENT=${1:-staging}
SKIP_BUILD=${2:-""}

if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [staging|production] [--skip-build]"
    exit 1
fi

print_header "Deploying Capstone Design Manager to $ENVIRONMENT"

# Verify gcloud is authenticated
print_info "Verifying gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    print_error "Not authenticated with gcloud"
    echo "Run: gcloud auth login"
    exit 1
fi
print_success "Authenticated"

# Set project
print_info "Setting GCP project..."
gcloud config set project $PROJECT_ID --quiet
print_success "Project set to $PROJECT_ID"

# Build and push Docker image (unless skipped)
if [[ "$SKIP_BUILD" != "--skip-build" ]]; then
    print_header "Building and Pushing Docker Image"
    ./scripts/10-build-and-push.sh $ENVIRONMENT
else
    print_warning "Skipping Docker build (--skip-build flag)"
fi

# Deploy to Cloud Run
print_header "Deploying to Cloud Run ($ENVIRONMENT)"
if [[ "$ENVIRONMENT" == "staging" ]]; then
    ./scripts/20-deploy-staging.sh
else
    ./scripts/30-deploy-production.sh
fi

# Get service URL
SERVICE_NAME="capstone-manager-${ENVIRONMENT}"
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --project=$PROJECT_ID \
    --region=$REGION \
    --format='value(status.url)')

print_header "Deployment Complete!"
print_success "Service deployed successfully"

echo ""
echo "🌐 Service URL: $SERVICE_URL"
echo ""
echo "Quick commands:"
echo "  View logs:    gcloud run services logs read ${SERVICE_NAME} --region=$REGION --project=$PROJECT_ID"
echo "  Describe:     gcloud run services describe ${SERVICE_NAME} --region=$REGION --project=$PROJECT_ID"
echo "  Update:       gcloud run services update ${SERVICE_NAME} --region=$REGION --project=$PROJECT_ID"
echo ""

if [[ "$ENVIRONMENT" == "staging" ]]; then
    echo "Next steps for staging:"
    echo "  1. Test the application: $SERVICE_URL"
    echo "  2. Configure Auth0 with this URL (see docs/AUTH0_SETUP.md)"
    echo "  3. Validate all functionality"
    echo "  4. Deploy to production: ./scripts/deploy.sh production"
else
    echo "Next steps for production:"
    echo "  1. Setup custom domain: ./scripts/40-setup-custom-domain.sh yourdomain.com"
    echo "  2. Update Auth0 with production domain"
    echo "  3. Monitor the service for any issues"
fi
echo ""
