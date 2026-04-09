#!/bin/bash

#############################################################################
# Cloud SQL Setup Script
#
# Creates Cloud SQL PostgreSQL instance for production
#
# Usage: ./scripts/01-setup-cloud-sql.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"
INSTANCE_NAME="capstone-db-prod"
DB_VERSION="POSTGRES_17"
TIER="db-f1-micro"  # Free tier eligible
DB_NAME="capstone_production"
DB_USER="capstone_user"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Cloud SQL Instance Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if instance exists
if gcloud sql instances describe $INSTANCE_NAME --project=$PROJECT_ID &>/dev/null; then
    echo "✓ Cloud SQL instance $INSTANCE_NAME already exists"
    echo ""
    echo "Instance details:"
    gcloud sql instances describe $INSTANCE_NAME --project=$PROJECT_ID --format="table(name,databaseVersion,gceZone,state)"
else
    echo "Creating Cloud SQL instance $INSTANCE_NAME..."
    echo "⏱ This will take 5-10 minutes..."
    echo ""
    
    gcloud sql instances create $INSTANCE_NAME \
        --project=$PROJECT_ID \
        --database-version=$DB_VERSION \
        --tier=$TIER \
        --region=$REGION \
        --root-password=$(openssl rand -base64 32) \
        --storage-type=SSD \
        --storage-size=10GB \
        --storage-auto-increase \
        --backup-start-time=03:00 \
        --maintenance-window-day=SUN \
        --maintenance-window-hour=04 \
        --enable-bin-log=false \
        --quiet
    
    echo ""
    echo "✓ Cloud SQL instance created"
fi

# Create database
echo ""
echo "Creating database $DB_NAME..."
gcloud sql databases create $DB_NAME \
    --instance=$INSTANCE_NAME \
    --project=$PROJECT_ID \
    --charset=UTF8 \
    --quiet 2>/dev/null || echo "  ℹ Database already exists"

echo "✓ Database ready"

# Create user
echo ""
echo "Creating database user $DB_USER..."
DB_PASSWORD=$(openssl rand -base64 32)

gcloud sql users create $DB_USER \
    --instance=$INSTANCE_NAME \
    --project=$PROJECT_ID \
    --password=$DB_PASSWORD \
    --quiet 2>/dev/null || {
    echo "  ℹ User already exists, resetting password..."
    gcloud sql users set-password $DB_USER \
        --instance=$INSTANCE_NAME \
        --project=$PROJECT_ID \
        --password=$DB_PASSWORD \
        --quiet
}

echo "✓ Database user configured"

# Store password in Secret Manager
echo ""
echo "Storing database password in Secret Manager..."
echo -n "$DB_PASSWORD" | gcloud secrets create db-password \
    --project=$PROJECT_ID \
    --data-file=- \
    --replication-policy="automatic" \
    --quiet 2>/dev/null || \
    echo -n "$DB_PASSWORD" | gcloud secrets versions add db-password \
    --project=$PROJECT_ID \
    --data-file=- \
    --quiet

echo "✓ Database password stored in Secret Manager"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Cloud SQL Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Instance details:"
echo "  Instance name: $INSTANCE_NAME"
echo "  Database name: $DB_NAME"
echo "  Database user: $DB_USER"
echo "  Version: PostgreSQL 17"
echo "  Tier: $TIER (Free tier eligible)"
echo ""
echo "Connection string for Cloud Run:"
echo "  $PROJECT_ID:$REGION:$INSTANCE_NAME"
echo ""
echo "View in console:"
echo "  https://console.cloud.google.com/sql/instances/$INSTANCE_NAME?project=$PROJECT_ID"
echo ""
