"""
Gunicorn configuration for production deployment on VM
"""
import multiprocessing
import os

# Server socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker processes
# For e2-micro VM (1GB RAM, 1 vCPU): use 2 workers
workers = int(os.getenv('GUNICORN_WORKERS', '2'))
worker_class = 'sync'
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 50
timeout = 60
keepalive = 5

# Logging
accesslog = '-'  # stdout
errorlog = '-'   # stderr
loglevel = 'info'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'capstone-backend'

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

# Graceful timeout for worker shutdown
graceful_timeout = 30

# Restart workers periodically
max_requests = 1000
max_requests_jitter = 100
