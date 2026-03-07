from django.urls import include, path
from rest_framework.routers import DefaultRouter
from .views import ProjectViewSet, AssignmentViewSet, PreferenceAPIView

app_name = 'project'

router = DefaultRouter()

# The first parameter is the route used to access the ViewSet
# The third field is the name of the Python class that you added
router.register(r'projects', ProjectViewSet, basename='project')
router.register(r'assignments', AssignmentViewSet, basename='assignment')

urlpatterns = [
    path('', include(router.urls)),
    path('preferences/', PreferenceAPIView.as_view(), name='preference-list')
]
