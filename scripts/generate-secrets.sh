#!/bin/bash

#############################################################################
# Generate Secure Secrets for Production
#
# Creates .env.production files with secure random passwords
#
# Usage: ./scripts/generate-secrets.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"
DOMAIN=${1:-""}  # Optional domain parameter

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
if [ -n "$DOMAIN" ]; then
    echo "  ✓ Using domain: $DOMAIN"
    ALLOWED_HOSTS="$DOMAIN www.$DOMAIN $EXTERNAL_IP localhost 127.0.0.1"
else
    echo "  ℹ No domain provided - using VM IP only"
    ALLOWED_HOSTS="$EXTERNAL_IP localhost 127.0.0.1"
fi

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
echo "  📝 GENERATED CREDENTIALS (SAVE THESE!)"
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
if [ -n "$DOMAIN" ]; then
    echo "✓ DJANGO_ALLOWED_HOSTS set to: $DOMAIN (+ www.$DOMAIN + $EXTERNAL_IP)"
else
    echo "✓ DJANGO_ALLOWED_HOSTS set to: $EXTERNAL_IP"
    echo ""
    echo "ℹ To include a domain, run:"
    echo "  ./scripts/generate-secrets.sh yourdomain.com"
fi
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
