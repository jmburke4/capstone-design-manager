from django.urls import include, path
from rest_framework.routers import DefaultRouter
from project.views import ProjectViewSet, PreferenceViewSet, AssignmentViewSet, AttachmentViewSet

app_name = 'project'

router = DefaultRouter()

# The first parameter is the route used to access the resource
# The third field is the name of the Python class that you added
router.register(r'projects', ProjectViewSet, basename='project')
router.register(r'preferences', PreferenceViewSet, basename='preference')
router.register(r'assignments', AssignmentViewSet, basename='assignment')
router.register(r'attachments', AttachmentViewSet, basename='attachment')

urlpatterns = [
    path('', include(router.urls)),
]
