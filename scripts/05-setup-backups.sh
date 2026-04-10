#!/bin/bash

#############################################################################
# Setup Automated Database Backups
#
# This script:
# - Creates backup script on VM
# - Sets up daily cron job
# - (Optional) Configures Cloud Storage for off-site backups
# - Tests backup process
#
# Usage: ./scripts/05-setup-backups.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setting Up Automated Backups"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Setup backup script on VM
echo "Creating backup script on VM..."

gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command="bash -s" << 'ENDSSH'

set -e

cd ~/capstone

# Create backup script
cat > ~/capstone/backup-db.sh << 'EOF'
#!/bin/bash

# Daily PostgreSQL backup script

set -e

APP_DIR="$HOME/capstone"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql"

cd $APP_DIR

echo "Starting database backup: $BACKUP_FILE"

# Create backup using pg_dump (rootless Docker)
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T db pg_dump \
    -U capstone_user \
    -d capstone_production \
    > "${BACKUP_DIR}/${BACKUP_FILE}"

# Compress backup
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

echo "✓ Backup created: ${BACKUP_FILE}.gz"

# Delete backups older than 7 days
find "${BACKUP_DIR}" -name "backup_*.sql.gz" -mtime +7 -delete

echo "✓ Old backups cleaned up (keeping last 7 days)"

# Optional: Upload to Cloud Storage (uncomment if using Cloud Storage)
# BUCKET_NAME="capstone-backups-${PROJECT_ID}"
# gsutil cp "${BACKUP_DIR}/${BACKUP_FILE}.gz" "gs://${BUCKET_NAME}/"
# echo "✓ Backup uploaded to Cloud Storage"

EOF

chmod +x ~/capstone/backup-db.sh

echo "✓ Backup script created"

# Add to cron (daily at 3 AM)
echo ""
echo "Setting up daily cron job..."

# Remove existing cron job if any
crontab -l 2>/dev/null | grep -v "backup-db.sh" | crontab - || true

# Add new cron job
(crontab -l 2>/dev/null; echo "0 3 * * * $HOME/capstone/backup-db.sh >> $HOME/capstone/logs/backup.log 2>&1") | crontab -

echo "✓ Cron job configured (daily at 3 AM UTC)"

# Create logs directory
mkdir -p ~/capstone/logs

# Test backup
echo ""
echo "Running test backup..."
cd ~/capstone
./backup-db.sh

echo "✓ Test backup successful"

# List backups
echo ""
echo "Current backups:"
ls -lh ~/capstone/backups/

ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Backup Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Backup configuration:"
echo "  Schedule: Daily at 3:00 AM UTC"
echo "  Location: ~/capstone/backups/"
echo "  Retention: 7 days (local)"
echo "  Format: PostgreSQL dump (compressed)"
echo ""
echo "Manual backup:"
echo "  SSH to VM and run: ~/capstone/backup-db.sh"
echo ""
echo "Restore from backup:"
echo "  See docs/BACKUP_RESTORE.md"
echo ""
echo "Optional: Setup Cloud Storage for off-site backups"
echo "  See backup-db.sh comments for instructions"
echo ""
