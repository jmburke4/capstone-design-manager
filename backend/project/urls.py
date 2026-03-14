from django.urls import include, path, re_path
from rest_framework.routers import DefaultRouter
from .views import ProjectViewSet, AssignmentViewSet, PreferenceAPIView

app_name = 'project'

router = DefaultRouter()

# For viewsets
router.register(r'projects', ProjectViewSet, basename='project')
router.register(r'assignments', AssignmentViewSet, basename='assignment')

urlpatterns = [
    path('', include(router.urls)),
    # For APIViews
    path('preferences/', PreferenceAPIView.as_view(), name='preference-list'),
    re_path(r'^preferences/(?P<pk>\d+-\d+)/$', PreferenceAPIView.as_view(), name='preference-detail')
]
