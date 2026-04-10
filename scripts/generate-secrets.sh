#!/bin/bash

#############################################################################
# Generate Secure Secrets for Production
#
# Creates .env.production files with secure random passwords
#
# Usage: ./scripts/generate-secrets.sh
#############################################################################

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Generating Production Secrets"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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
DJANGO_ALLOWED_HOSTS=CHANGE_ME_TO_YOUR_DOMAIN_OR_IP localhost 127.0.0.1

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
echo "⚠ IMPORTANT: Update DJANGO_ALLOWED_HOSTS in .env.production"
echo ""
echo "Before deployment, edit .env.production and replace:"
echo "  DJANGO_ALLOWED_HOSTS=CHANGE_ME_TO_YOUR_DOMAIN_OR_IP"
echo ""
echo "With your VM IP or domain:"
echo "  DJANGO_ALLOWED_HOSTS=yourdomain.com www.yourdomain.com 34.XX.XX.XX"
echo ""
echo "Next step:"
echo "  ./scripts/03-deploy-app.sh"
echo ""
