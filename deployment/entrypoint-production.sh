#!/bin/bash
set -e

echo "=== Starting Production Deployment ==="
echo "Environment: ${ENVIRONMENT:-production}"
echo "Django Settings: ${DJANGO_SETTINGS_MODULE}"

# Wait for database to be ready
echo "Checking database connection..."
max_attempts=30
attempt=0

until python manage.py check --database default > /dev/null 2>&1 || [ $attempt -eq $max_attempts ]; do
    attempt=$((attempt + 1))
    echo "  Waiting for database... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: Could not connect to database after $max_attempts attempts"
    exit 1
fi

echo "✓ Database connection established"

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "=== Startup complete, launching Gunicorn ==="

# Execute the CMD (gunicorn)
exec "$@"
