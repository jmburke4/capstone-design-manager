# Getting Started

## Prerequisites

- Docker and Docker Compose
- Git

## Clone the Repository

```bash
git clone https://github.com/your-repo/capstone-design-manager.git
cd capstone-design-manager
```

## Local Development Setup

### 1. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.dev .env
```

Edit `.env` with your configuration:

```env
# Django Settings
DEBUG=1
SECRET_KEY=your-secret-key-here
DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1] backend:8000 backend

# Database
SQL_ENGINE=django.db.backends.postgresql
SQL_DATABASE=DB_BACKEND
SQL_USER=your_db_user
SQL_PASSWORD=your_db_password
SQL_HOST=db
SQL_PORT=5432

# Email (Gmail with App Password)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# MinIO / S3 Storage
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_STORAGE_BUCKET_NAME=capstone-attachments
AWS_S3_ENDPOINT_URL=http://minio:9000
MINIO_ACCESS_URL=http://localhost:9000

# Auth0
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_AUDIENCE=https://your-api-audience/
```

### 2. Start the Application

Using Docker Compose:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

This starts:
- **Backend**: http://localhost:8000
- **Frontend**: http://localhost:5173
- **Admin Panel**: http://localhost:8000/admin
- **Mailhog**: http://localhost:8025 (email testing)
- **MinIO Console**: http://localhost:9000

### 3. Run Database Migrations

```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py migrate
```

### 4. Create a Superuser

```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py createsuperuser
```

### 5. Access the Application

- **Admin Panel**: http://localhost:8000/admin
- **Frontend**: http://localhost:5173

## Creating Sample Data

To populate the database with test data:

```bash
docker-compose -f docker-compose.dev.yml exec backend python manage.py create_sample_data
```

This creates:
- 5 sample sponsors
- 8 sample students
- 1 semester (Fall 2026)
- 5 sample projects
- Sample preferences and assignments
