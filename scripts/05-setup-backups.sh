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

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

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

# Daily PostgreSQL backup script with validation

set -e

APP_DIR="$HOME/capstone"
BACKUP_DIR="$APP_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql"

cd $APP_DIR

echo "Starting database backup: $BACKUP_FILE"

# Verify database container is running and healthy
echo "  Checking database container status..."
if ! $HOME/bin/docker compose -f docker-compose.prod.yml ps db | grep -q "healthy"; then
    echo "  ✗ ERROR: Database container is not running or not healthy"
    echo "  Check status: docker compose -f docker-compose.prod.yml ps db"
    exit 1
fi

# Create backup using pg_dump (rootless Docker)
echo "  Running pg_dump..."
$HOME/bin/docker compose -f docker-compose.prod.yml exec -T db pg_dump \
    -U capstone_user \
    -d capstone_production \
    > "${BACKUP_DIR}/${BACKUP_FILE}"

# Verify backup file was created and is not empty
if [ ! -s "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
    echo "  ✗ ERROR: Backup file is empty or was not created"
    rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
    exit 1
fi

BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
echo "  ✓ Raw backup created: ${BACKUP_SIZE}"

# Compress backup
echo "  Compressing backup..."
gzip "${BACKUP_DIR}/${BACKUP_FILE}"

# Verify compressed backup
if [ ! -s "${BACKUP_DIR}/${BACKUP_FILE}.gz" ]; then
    echo "  ✗ ERROR: Compressed backup file is empty"
    exit 1
fi

COMPRESSED_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}.gz" | cut -f1)
echo "✓ Backup created: ${BACKUP_FILE}.gz (${COMPRESSED_SIZE})"

# Delete backups older than 7 days
echo "  Cleaning up old backups..."
DELETED_COUNT=$(find "${BACKUP_DIR}" -name "backup_*.sql.gz" -mtime +7 -delete -print | wc -l)
echo "✓ Old backups cleaned up (${DELETED_COUNT} files removed, keeping last 7 days)"

# Optional: Upload to Cloud Storage (uncomment if using Cloud Storage)
# BUCKET_NAME="capstone-backups-${PROJECT_ID}"
# gsutil cp "${BACKUP_DIR}/${BACKUP_FILE}.gz" "gs://${BUCKET_NAME}/"
# echo "✓ Backup uploaded to Cloud Storage"

# Log backup completion with timestamp
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed: ${BACKUP_FILE}.gz (${COMPRESSED_SIZE})" >> "$APP_DIR/logs/backup.log"

echo "✓ Backup process completed successfully"

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

# Run the backup script and capture output
if ! ./backup-db.sh; then
    echo ""
    echo "✗ Test backup FAILED"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check database container: docker compose -f docker-compose.prod.yml ps db"
    echo "  2. Check database logs: docker compose -f docker-compose.prod.yml logs db"
    echo "  3. Verify environment variables in .env.production.db"
    exit 1
fi

# Verify backup file was actually created
BACKUP_COUNT=$(ls -1 ~/capstone/backups/backup_*.sql.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -eq 0 ]; then
    echo ""
    echo "✗ No backup files found after test backup"
    exit 1
fi

echo "✓ Test backup successful (${BACKUP_COUNT} backup file(s) found)"

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
