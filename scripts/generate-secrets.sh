#!/bin/bash

#############################################################################
# Generate Secure Secrets for Production
#
# Creates .env.production files with secure random passwords
#
# Usage: ./scripts/generate-secrets.sh your-domain
#############################################################################

set -e

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

DOMAIN=DEFAULT_DOMAIN # pulls from config.sh

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Generating Production Secrets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get VM IP if VM exists
echo "Checking for VM external IP..."
EXTERNAL_IP=$(gcloud compute instances describe ${VM_NAME} \
    --zone=${ZONE} \
    --project=${PROJECT_ID} \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)' 2>/dev/null || echo "")

if [ -z "$EXTERNAL_IP" ]; then
    echo "  ⚠ WARNING: VM not found yet"
    echo "  Run ./scripts/01-create-vm.sh first"
    exit 1
fi

echo "  ✓ VM found with IP: $EXTERNAL_IP"

# Build ALLOWED_HOSTS based on domain parameter
echo "  ✓ Using domain: $DOMAIN"
ALLOWED_HOSTS="$DOMAIN www.$DOMAIN $EXTERNAL_IP localhost 127.0.0.1 backend"
APP_BASE_URL="https://$DOMAIN"

echo "  ✓ APP_BASE_URL set to: $APP_BASE_URL"

echo ""

# Check if .env.production already exists
if [ -f ".env.production" ]; then
    echo "⚠ .env.production already exists"
    read -p "Overwrite? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled. Existing files not modified."
        exit 0
    fi
fi

# Generate random secrets
echo "Generating secure random secrets..."
DJANGO_SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe(50))')
DB_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')

echo "  ✓ Secrets generated"

# Create .env.production for backend
echo ""
echo "Creating .env.production for backend..."

cat > .env.production << EOF
# Django Configuration
DEBUG=0
SECRET_KEY=${DJANGO_SECRET}
DJANGO_ALLOWED_HOSTS=${ALLOWED_HOSTS}

# Frontend Application Base URL
# Used for redirects (e.g., unauthorized admin access)
APP_BASE_URL=${APP_BASE_URL}

# Auth0 Configuration
AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com
AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3
AUTH0_AUDIENCE=https://backend-api-capstone/

# Database Configuration (Docker network)
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=capstone_production
SQL_USER=capstone_user
SQL_PASSWORD=${DB_PASSWORD}
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres

# Email Configuration (console backend - no SMTP)
EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
EOF

echo "  ✓ .env.production created"

# Create .env.production.db for PostgreSQL
echo ""
echo "Creating .env.production.db for PostgreSQL..."

cat > .env.production.db << EOF
POSTGRES_USER=capstone_user
POSTGRES_PASSWORD=${DB_PASSWORD}
POSTGRES_DB=capstone_production
EOF

echo "  ✓ .env.production.db created"

# Create frontend/.env.production
echo ""
echo "Creating frontend/.env.production..."

cat > frontend/.env.production << EOF
# Auth0 Configuration for Frontend
VITE_AUTH0_DOMAIN=dev-qjyd077ykn3qqq7v.us.auth0.com
VITE_AUTH0_CLIENT_ID=WMPr5zJLNFI0j9A8iUymDfAsP2mUXsn3
VITE_AUTH0_AUDIENCE=https://backend-api-capstone/
EOF

echo "  ✓ frontend/.env.production created"

# Set restrictive permissions
chmod 600 .env.production .env.production.db frontend/.env.production

# Validate generated files
echo ""
echo "Validating generated environment files..."

# Check for placeholder values
VALIDATION_ERRORS=0

if grep -q "REPLACE_" .env.production 2>/dev/null; then
    echo "  ✗ ERROR: .env.production contains placeholder values (REPLACE_)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Check APP_BASE_URL is set and not empty
if ! grep -q "^APP_BASE_URL=" .env.production 2>/dev/null || grep -q "^APP_BASE_URL=$" .env.production 2>/dev/null; then
    echo "  ✗ ERROR: APP_BASE_URL is not set or is empty (required for redirects)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if grep -q "CHANGE_ME" .env.production 2>/dev/null; then
    echo "  ✗ ERROR: .env.production contains placeholder values (CHANGE_ME)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Check SECRET_KEY length (should be 50+ chars)
SECRET_KEY_LENGTH=$(grep "SECRET_KEY=" .env.production | cut -d'=' -f2 | tr -d '\n' | wc -c)
if [ "$SECRET_KEY_LENGTH" -lt 50 ]; then
    echo "  ✗ WARNING: SECRET_KEY is only $SECRET_KEY_LENGTH characters (should be 50+)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Check DJANGO_ALLOWED_HOSTS has required values
if ! grep -q "backend" .env.production; then
    echo "  ✗ ERROR: DJANGO_ALLOWED_HOSTS missing 'backend' (required for Docker networking)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if ! grep -q "localhost" .env.production; then
    echo "  ✗ ERROR: DJANGO_ALLOWED_HOSTS missing 'localhost' (required for health checks)"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

# Verify database credentials match
DB_USER=$(grep "POSTGRES_USER=" .env.production.db | cut -d'=' -f2)
DB_PASS=$(grep "POSTGRES_PASSWORD=" .env.production.db | cut -d'=' -f2)
DB_NAME=$(grep "POSTGRES_DB=" .env.production.db | cut -d'=' -f2)

if ! grep -q "SQL_USER=${DB_USER}" .env.production; then
    echo "  ✗ ERROR: Database user mismatch between .env.production and .env.production.db"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if ! grep -q "SQL_PASSWORD=${DB_PASS}" .env.production; then
    echo "  ✗ ERROR: Database password mismatch between .env.production and .env.production.db"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if ! grep -q "SQL_DATABASE=${DB_NAME}" .env.production; then
    echo "  ✗ ERROR: Database name mismatch between .env.production and .env.production.db"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
fi

if [ $VALIDATION_ERRORS -eq 0 ]; then
    echo "  ✓ All environment files validated successfully"
else
    echo ""
    echo "⚠ Found $VALIDATION_ERRORS validation error(s). Please review and fix before deploying."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Secrets Generated Successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files created:"
echo "  • .env.production (backend)"
echo "  • .env.production.db (database)"
echo "  • frontend/.env.production (frontend)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📝 GENERATED CREDENTIALS "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Django Secret Key:"
echo "  ${DJANGO_SECRET}"
echo ""
echo "Database Password (for PostgreSQL user 'capstone_user'):"
echo "  ${DB_PASSWORD}"
echo ""
echo "Django Allowed Hosts:"
echo "  ${ALLOWED_HOSTS}"
echo ""
echo "⚠️  IMPORTANT: Save these credentials securely!"
echo ""
echo "✓ DJANGO_ALLOWED_HOSTS set to: $DOMAIN (+ www.$DOMAIN + $EXTERNAL_IP)"
echo ""
echo "Next step:"
echo "  ./scripts/03-deploy-app.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 DATABASE CREDENTIALS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "PostgreSQL user and database will be created automatically by Docker."
echo ""
echo "Database: capstone_production"
echo "User: capstone_user"
echo "Password: ${DB_PASSWORD}"
echo ""
echo "These credentials are stored in .env.production and .env.production.db"
echo "PostgreSQL container reads these and creates the user/database on first startup."
echo ""
echo "No manual database setup needed!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋 DJANGO SUPERUSER (Manual Step Required)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Django superuser is NOT created automatically."
echo ""
echo "After deploying, create it with:"
echo "  gcloud compute ssh ${VM_NAME} --zone=${ZONE} --project=${PROJECT_ID}"
echo "  cd ~/capstone"
echo "  docker compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser"
echo ""
echo "You'll be prompted for:"
echo "  - Username (e.g., admin)"
echo "  - Email (your email)"
echo "  - Password (choose a secure password)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
