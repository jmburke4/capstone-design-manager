"""
Health check endpoints for Cloud Run
"""
from django.http import JsonResponse
from django.db import connection
from django.conf import settings
import sys

def health_check(request):
    """
    Health check endpoint for Cloud Run
    Returns 200 if service is healthy, 503 otherwise
    """
    health_status = {
        'status': 'healthy',
        'environment': getattr(settings, 'ENVIRONMENT', 'unknown'),
        'python_version': sys.version,
    }
    
    # Check database connection
    try:
        connection.ensure_connection()
        health_status['database'] = 'connected'
    except Exception as e:
        health_status['status'] = 'unhealthy'
        health_status['database'] = f'error: {str(e)}'
        return JsonResponse(health_status, status=503)
    
    return JsonResponse(health_status, status=200)
