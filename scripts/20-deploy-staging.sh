#!/bin/bash

#############################################################################
# Deploy to Staging Environment
#
# Deploys the application to Cloud Run staging environment
#
# Usage: ./scripts/20-deploy-staging.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-manager-prod"
REGION="us-central1"
SERVICE_NAME="capstone-manager-staging"
REPOSITORY="capstone-images"
IMAGE_NAME="capstone-manager"
SQL_INSTANCE="capstone-db-prod"
SERVICE_ACCOUNT="${SERVICE_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Full image path
IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}:staging-latest"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Deploying to Staging Environment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if service account exists, create if not
echo "Setting up service account..."
if gcloud iam service-accounts describe $SERVICE_ACCOUNT --project=$PROJECT_ID &>/dev/null; then
    echo "  ✓ Service account exists"
else
    echo "  Creating service account..."
    gcloud iam service-accounts create $SERVICE_NAME \
        --project=$PROJECT_ID \
        --display-name="Capstone Manager Staging Service Account" \
        --quiet
    echo "  ✓ Service account created"
fi

# Grant permissions to service account
echo ""
echo "Granting permissions to service account..."

# Cloud SQL Client role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/cloudsql.client" \
    --quiet &>/dev/null

# Secret Manager Secret Accessor role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/secretmanager.secretAccessor" \
    --quiet &>/dev/null

echo "  ✓ Permissions granted"

# Deploy to Cloud Run
echo ""
echo "Deploying to Cloud Run..."
echo "⏱ This may take 2-3 minutes..."
echo ""

gcloud run deploy $SERVICE_NAME \
    --project=$PROJECT_ID \
    --image=$IMAGE_PATH \
    --region=$REGION \
    --platform=managed \
    --allow-unauthenticated \
    --min-instances=1 \
    --max-instances=10 \
    --memory=1Gi \
    --cpu=1 \
    --timeout=300 \
    --port=8080 \
    --set-env-vars="ENVIRONMENT=staging,GCP_PROJECT_ID=${PROJECT_ID},DB_NAME=capstone_production,DB_USER=capstone_user,CLOUD_SQL_CONNECTION_NAME=${PROJECT_ID}:${REGION}:${SQL_INSTANCE}" \
    --set-secrets="SECRET_KEY=django-secret-key:latest,AUTH0_DOMAIN=auth0-domain:latest,AUTH0_CLIENT_ID=auth0-client-id:latest,AUTH0_AUDIENCE=auth0-audience:latest,DB_PASSWORD=db-password:latest" \
    --add-cloudsql-instances="${PROJECT_ID}:${REGION}:${SQL_INSTANCE}" \
    --service-account="${SERVICE_ACCOUNT}" \
    --quiet

echo ""
echo "✓ Deployment successful"

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --project=$PROJECT_ID \
    --region=$REGION \
    --format='value(status.url)')

# Update service with its own URL for CORS
echo ""
echo "Updating service with CORS configuration..."
gcloud run services update $SERVICE_NAME \
    --project=$PROJECT_ID \
    --region=$REGION \
    --update-env-vars="SERVICE_URL=${SERVICE_URL}" \
    --quiet

echo "✓ CORS configured"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Staging Deployment Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Staging URL: $SERVICE_URL"
echo ""
echo "Next steps:"
echo "  1. Test the staging URL: $SERVICE_URL"
echo "  2. Configure Auth0 with this URL:"
echo "     • Allowed Callback URLs: ${SERVICE_URL}"
echo "     • Allowed Logout URLs: ${SERVICE_URL}"
echo "     • Allowed Web Origins: ${SERVICE_URL}"
echo "  3. Test authentication and all features"
echo "  4. View logs: gcloud run services logs read $SERVICE_NAME --region=$REGION"
echo ""
