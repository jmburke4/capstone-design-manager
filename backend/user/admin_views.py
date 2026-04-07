"""
API views for admin authorization using Auth0 JWT tokens.
"""
from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .authentication import Auth0Authentication
import logging

logger = logging.getLogger(__name__)


@api_view(['POST'])
@permission_classes([AllowAny])
def admin_authorize(request):
    """
    Create a temporary session for admin panel access.
    
    Validates Auth0 JWT token and checks for 'admin' role.
    If valid, creates a 5-minute session for admin access.
    
    Expects:
        POST /api/v1/admin/authorize/
        Headers: Authorization: Bearer <token>
        
    Returns:
        200: { "success": true, "message": "...", "expiresIn": 300 }
        401: { "error": "Unauthorized", "message": "..." }
        403: { "error": "Forbidden", "message": "Admin role required" }
    """
    auth0 = Auth0Authentication()
    
    try:
        result = auth0.authenticate(request)
        
        if not result:
            return Response(
                {'error': 'Unauthorized', 'message': 'Invalid token'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        user_wrapper, _ = result
        
        # Check if user has admin role
        if not user_wrapper.has_role('admin'):
            logger.warning(f'User {user_wrapper.email} attempted admin access without admin role')
            return Response(
                {'error': 'Forbidden', 'message': 'Admin role required'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # User has admin role - create temporary authorization session
        request.session['admin_authorized'] = True
        request.session['admin_email'] = user_wrapper.email
        request.session.set_expiry(300)  # 5 minutes
        
        logger.info(f'Admin authorization granted for {user_wrapper.email}')
        
        return Response({
            'success': True,
            'message': 'Admin access authorized',
            'expiresIn': 300
        })
        
    except Exception as e:
        logger.error(f'Admin authorization failed: {str(e)}')
        return Response(
            {'error': 'Unauthorized', 'message': str(e)},
            status=status.HTTP_401_UNAUTHORIZED
        )


@api_view(['GET'])
@authentication_classes([Auth0Authentication])
@permission_classes([IsAuthenticated])
def admin_check(request):
    """
    Check if the current user has admin role.
    
    Used by frontend to show/hide the admin panel button.
    
    Expects:
        GET /api/v1/admin/check/
        Headers: Authorization: Bearer <token>
        
    Returns:
        200: { "isAdmin": true/false, "email": "..." }
        401: { "error": "Unauthorized" } (handled by DRF)
    """
    try:
        # Auth0Authentication has already run and populated request.user
        user_wrapper = request.user
        is_admin = user_wrapper.has_role('admin')
        
        return Response({
            'isAdmin': is_admin,
            'email': user_wrapper.email
        })
        
    except Exception as e:
        logger.error(f'Admin check failed: {str(e)}')
        return Response(
            {'error': 'Internal error', 'message': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
