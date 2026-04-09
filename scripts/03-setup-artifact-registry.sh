#!/bin/bash

#############################################################################
# Artifact Registry Setup Script
#
# Creates Docker repository in Google Artifact Registry
#
# Usage: ./scripts/03-setup-artifact-registry.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"
REPOSITORY="capstone-images"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Artifact Registry Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if repository exists
if gcloud artifacts repositories describe $REPOSITORY \
    --project=$PROJECT_ID \
    --location=$REGION &>/dev/null; then
    echo "✓ Repository $REPOSITORY already exists"
else
    echo "Creating Artifact Registry repository..."
    gcloud artifacts repositories create $REPOSITORY \
        --project=$PROJECT_ID \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker images for Capstone Design Manager" \
        --quiet
    
    echo "✓ Repository created"
fi

# Configure Docker authentication
echo ""
echo "Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

echo "✓ Docker configured"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Artifact Registry Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Repository details:"
echo "  Name: $REPOSITORY"
echo "  Location: $REGION"
echo "  Format: Docker"
echo ""
echo "Image path format:"
echo "  ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/capstone-manager:TAG"
echo ""
echo "View in console:"
echo "  https://console.cloud.google.com/artifacts?project=$PROJECT_ID"
echo ""
