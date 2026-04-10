"""
Health check endpoint for deployment verification
"""
from django.http import JsonResponse
from django.db import connection
import sys

def health_check(request):
    """
    Simple health check endpoint
    Returns 200 if service is healthy, 503 otherwise
    """
    health_status = {
        'status': 'healthy',
        'python_version': f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
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
