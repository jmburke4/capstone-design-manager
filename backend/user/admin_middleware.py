"""
Middleware to protect Django admin routes.
Only allows access via session created by admin authorization endpoint.
Blocks manual navigation - users must use the admin panel button.
"""
from django.http import HttpResponseRedirect
import logging

logger = logging.getLogger(__name__)


class Auth0AdminMiddleware:
    """
    Middleware that protects /admin/* routes.
    
    Access is granted ONLY if:
    1. User has an active Django admin session (is_staff=True), OR
    2. User has a valid temporary admin authorization session
    
    Manual navigation is blocked - users must use the sidebar button
    which creates the authorization session.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Check if this is an admin route
        if request.path.startswith('/admin'):
            # Skip protection for static files and i18n
            if request.path.startswith('/admin/static/') or \
               request.path.startswith('/admin/jsi18n/'):
                return self.get_response(request)
            
            # Allow if user is already logged into Django admin
            if request.user.is_authenticated and request.user.is_staff:
                logger.debug(f'Admin access: Django session for {request.user.username}')
                return self.get_response(request)
            
            # Check for temporary admin authorization session
            if request.session.get('admin_authorized'):
                logger.debug(f'Admin access: Auth0 session for {request.session.get("admin_email")}')
                return self.get_response(request)
            
            # No valid authorization - silently redirect to home
            logger.warning(f'Unauthorized admin access attempt from {request.META.get("REMOTE_ADDR")}')
            return HttpResponseRedirect('http://localhost:5173/')
        
        # Not an admin route, continue normally
        return self.get_response(request)
