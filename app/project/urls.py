from django.urls import include, path
from rest_framework.views import APIView
from rest_framework.response import Response
from .views import ProjectCreate, ProjectList, ProjectDetail, ProjectUpdate, ProjectDelete

class APIRoot(APIView):
    """
    API Root that provides links to all available endpoints.
    """
    def get(self, request):
        return Response({
            'projects': request.build_absolute_uri('/api/projects/'),})

urlpatterns = [
    path('', APIRoot.as_view(), name='api-root'),
    path('projects/', ProjectList.as_view(), name='project-list'),
    path('projects/create/', ProjectCreate.as_view(), name='project-create'),
    path('projects/<int:pk>/', ProjectDetail.as_view(), name='project-detail'),
    path('projects/<int:pk>/update/', ProjectUpdate.as_view(), name='project-update'),
    path('projects/<int:pk>/delete/', ProjectDelete.as_view(), name='project-delete'),
]
