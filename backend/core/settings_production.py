"""
Production Django settings for Cloud Run deployment

This file is a complete settings file for production, not an extension.
"""
import os
import sys
import logging
from pathlib import Path

# Build paths
BASE_DIR = Path(__file__).resolve().parent.parent

# Google Cloud Project Configuration
GCP_PROJECT_ID = os.environ.get('GCP_PROJECT_ID', 'capstone-design-manager-prod')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'production')

# Helper function to get secrets from Secret Manager
def get_secret(secret_id, version='latest'):
    """
    Retrieve secret from Google Cloud Secret Manager
    """
    try:
        from google.cloud import secretmanager
        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{GCP_PROJECT_ID}/secrets/{secret_id}/versions/{version}"
        response = client.access_secret_version(request={"name": name})
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        logging.error(f"Error fetching secret {secret_id}: {e}")
        # Fallback to environment variable for local testing
        return os.environ.get(secret_id.upper().replace('-', '_'), '')

# SECURITY SETTINGS
SECRET_KEY = os.environ.get('SECRET_KEY') or get_secret('django-secret-key')
DEBUG = False  # Always False in production

# Allowed hosts - Cloud Run service URLs
ALLOWED_HOSTS = [
    '.run.app',  # All Cloud Run services
    'localhost',  # For health checks
    '127.0.0.1',
]

# Add custom domain when configured
CUSTOM_DOMAIN = os.environ.get('CUSTOM_DOMAIN', '')
if CUSTOM_DOMAIN:
    ALLOWED_HOSTS.append(CUSTOM_DOMAIN)
    ALLOWED_HOSTS.append(f'www.{CUSTOM_DOMAIN}')

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'django_filters',
    'corsheaders',
    'import_export',
    'django_admin_action_forms',
    'project',
    'user',
    'emails',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Serve static files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'user.admin_middleware.Auth0AdminMiddleware',  # Auth0 admin protection
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR.parent / 'frontend-dist'],  # Vue.js templates
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# Database - Cloud SQL PostgreSQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'capstone_production'),
        'USER': os.environ.get('DB_USER', 'capstone_user'),
        'PASSWORD': os.environ.get('DB_PASSWORD') or get_secret('db-password'),
        'HOST': '/cloudsql/' + os.environ.get(
            'CLOUD_SQL_CONNECTION_NAME',
            f'{GCP_PROJECT_ID}:us-central1:capstone-db-prod'
        ),
    }
}

# Connection pooling for Cloud SQL
DATABASES['default']['CONN_MAX_AGE'] = 60
DATABASES['default']['OPTIONS'] = {
    'connect_timeout': 10,
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static Files Configuration
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Serve Vue.js frontend files
STATICFILES_DIRS = [
    BASE_DIR.parent / 'frontend-dist',
]

# WhiteNoise configuration
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ]
}

# Auth0 Configuration from Secret Manager
AUTH0_DOMAIN = os.environ.get('AUTH0_DOMAIN') or get_secret('auth0-domain')
AUTH0_CLIENT_ID = os.environ.get('AUTH0_CLIENT_ID') or get_secret('auth0-client-id')
AUTH0_AUDIENCE = os.environ.get('AUTH0_AUDIENCE') or get_secret('auth0-audience')

# CORS Configuration for production
SERVICE_URL = os.environ.get('SERVICE_URL', '')
CORS_ALLOWED_ORIGINS = []

if SERVICE_URL:
    CORS_ALLOWED_ORIGINS.append(SERVICE_URL)
if CUSTOM_DOMAIN:
    CORS_ALLOWED_ORIGINS.append(f'https://{CUSTOM_DOMAIN}')
    CORS_ALLOWED_ORIGINS.append(f'https://www.{CUSTOM_DOMAIN}')

CORS_ALLOW_CREDENTIALS = True

# CSRF Configuration
CSRF_TRUSTED_ORIGINS = CORS_ALLOWED_ORIGINS.copy()

# Security Settings for HTTPS
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'

# Session configuration
SESSION_COOKIE_AGE = 1200  # 20 minutes
SESSION_SAVE_EVERY_REQUEST = True
SESSION_EXPIRE_AT_BROWSER_CLOSE = True
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_NAME = 'capstone_sessionid'

# Email Configuration (console backend - no SMTP setup)
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# Logging Configuration for Cloud Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'json': {
            'format': '{levelname} {name} {message} {pathname} {lineno}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
            'stream': sys.stdout,
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
        'user': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'project': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Admin site configuration
ADMIN_URL = 'admin/'

# Performance optimizations
DATA_UPLOAD_MAX_MEMORY_SIZE = 5242880  # 5MB

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

print(f"✓ Production settings loaded")
print(f"  Environment: {ENVIRONMENT}")
print(f"  Debug: {DEBUG}")
print(f"  Allowed hosts: {ALLOWED_HOSTS}")
print(f"  Database: Cloud SQL via {DATABASES['default']['HOST']}")
