#!/bin/bash

#############################################################################
# GCP Project Setup Script
# 
# This script:
# - Creates or verifies GCP project
# - Enables required APIs
# - Configures default settings
#
# Usage: ./scripts/00-setup-gcp-project.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  GCP Project Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if project exists
echo "Checking if project exists..."
if gcloud projects describe $PROJECT_ID &>/dev/null; then
    echo "✓ Project $PROJECT_ID already exists"
else
    echo "⚠ Project $PROJECT_ID does not exist"
    echo ""
    echo "Please create the project manually:"
    echo "  1. Visit: https://console.cloud.google.com/projectcreate"
    echo "  2. Project name: Capstone Design Manager Production"
    echo "  3. Project ID: $PROJECT_ID"
    echo "  4. Link billing account (required for Cloud Run, Cloud SQL)"
    echo ""
    echo "After creating the project, run this script again."
    exit 1
fi

# Set current project
echo ""
echo "Setting active project..."
gcloud config set project $PROJECT_ID
echo "✓ Active project set to $PROJECT_ID"

# Enable required APIs
echo ""
echo "Enabling required GCP APIs (this may take a few minutes)..."
echo ""

APIS=(
    "run.googleapis.com"                      # Cloud Run
    "sql-component.googleapis.com"            # Cloud SQL
    "sqladmin.googleapis.com"                 # Cloud SQL Admin
    "secretmanager.googleapis.com"            # Secret Manager
    "artifactregistry.googleapis.com"         # Artifact Registry
    "cloudbuild.googleapis.com"               # Cloud Build
    "compute.googleapis.com"                  # Compute (for networking)
    "logging.googleapis.com"                  # Cloud Logging
    "monitoring.googleapis.com"               # Cloud Monitoring
    "cloudresourcemanager.googleapis.com"     # Resource Manager
    "iam.googleapis.com"                      # IAM
)

for api in "${APIS[@]}"; do
    echo "  Enabling $api..."
    gcloud services enable $api --project=$PROJECT_ID --quiet
done

echo ""
echo "✓ All required APIs enabled"

# Set default region
echo ""
echo "Setting default region to $REGION..."
gcloud config set run/region $REGION
gcloud config set compute/region $REGION
echo "✓ Default region configured"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Project Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/03-setup-artifact-registry.sh"
echo "  2. Run: ./scripts/01-setup-cloud-sql.sh"
echo "  3. Run: ./scripts/02-setup-secrets.sh"
echo ""
