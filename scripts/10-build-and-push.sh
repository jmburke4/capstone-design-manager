#!/bin/bash

#############################################################################
# Docker Build and Push Script
#
# Builds production Docker image and pushes to Artifact Registry
#
# Usage: ./scripts/10-build-and-push.sh [staging|production]
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"
REPOSITORY="capstone-images"
IMAGE_NAME="capstone-manager"
ENVIRONMENT=${1:-staging}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Building and Pushing Docker Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Set image tag based on environment
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
IMAGE_TAG="${ENVIRONMENT}-${TIMESTAMP}-${GIT_SHA}"
LATEST_TAG="${ENVIRONMENT}-latest"

# Full image path
IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}"

echo "Build configuration:"
echo "  Environment: $ENVIRONMENT"
echo "  Image tag: $IMAGE_TAG"
echo "  Latest tag: $LATEST_TAG"
echo "  Image path: $IMAGE_PATH"
echo ""

# Configure Docker to use gcloud credentials
echo "Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
echo "✓ Docker authenticated"

# Build Docker image
echo ""
echo "Building Docker image (this may take 5-10 minutes)..."
echo "⏱ Please wait..."
echo ""

docker build \
    -f deployment/Dockerfile.production \
    -t ${IMAGE_PATH}:${IMAGE_TAG} \
    -t ${IMAGE_PATH}:${LATEST_TAG} \
    --platform linux/amd64 \
    --progress=plain \
    .

echo ""
echo "✓ Docker image built successfully"

# Push to Artifact Registry
echo ""
echo "Pushing images to Artifact Registry..."
docker push ${IMAGE_PATH}:${IMAGE_TAG}
docker push ${IMAGE_PATH}:${LATEST_TAG}

echo "✓ Images pushed successfully"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Build Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Images pushed:"
echo "  • ${IMAGE_PATH}:${IMAGE_TAG}"
echo "  • ${IMAGE_PATH}:${LATEST_TAG}"
echo ""
echo "Next step:"
echo "  Deploy to Cloud Run with: ./scripts/20-deploy-staging.sh"
echo ""
