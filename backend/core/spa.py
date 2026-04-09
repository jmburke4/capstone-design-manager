"""
Single Page Application (SPA) view for serving Vue.js frontend
"""
from django.views.generic import View
from django.http import HttpResponse, HttpResponseNotFound
from django.conf import settings
from pathlib import Path
import os

class SPAView(View):
    """
    Serves the Vue.js index.html for all non-API, non-admin routes
    This allows Vue Router to handle frontend routing
    """
    
    def get(self, request, *args, **kwargs):
        # Path to the built Vue.js frontend
        frontend_dist = Path(settings.BASE_DIR).parent / 'frontend-dist'
        index_path = frontend_dist / 'index.html'
        
        if index_path.exists():
            with open(index_path, 'r', encoding='utf-8') as f:
                return HttpResponse(f.read(), content_type='text/html')
        else:
            return HttpResponseNotFound('Frontend files not found. Run npm build.')
