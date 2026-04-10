#!/bin/sh

# Production entrypoint script for Django backend

echo "=== Starting Production Backend ==="

# Wait for PostgreSQL to be ready
if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for PostgreSQL..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.5
    done

    echo "✓ PostgreSQL is ready"
fi

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "✓ Backend startup complete"
echo "=== Launching Gunicorn ==="

# Execute the command passed to the container (gunicorn)
exec "$@"
