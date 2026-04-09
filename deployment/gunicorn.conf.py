"""
Gunicorn configuration for production Cloud Run deployment
"""
import multiprocessing
import os

# Server socket
bind = f"0.0.0.0:{os.getenv('PORT', '8080')}"
backlog = 2048

# Worker processes
# Cloud Run typically provides 1 vCPU, so 2-3 workers is optimal
workers = int(os.getenv('GUNICORN_WORKERS', '2'))
worker_class = 'sync'
worker_connections = 1000
max_requests = 1000  # Restart worker after this many requests
max_requests_jitter = 50  # Add randomness to max_requests
timeout = 60  # Worker timeout in seconds
keepalive = 5

# Logging
accesslog = '-'  # stdout
errorlog = '-'   # stderr
loglevel = os.getenv('LOG_LEVEL', 'info')
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'capstone-manager'

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# Preload app for better memory usage
preload_app = True

# Graceful timeout
graceful_timeout = 30
