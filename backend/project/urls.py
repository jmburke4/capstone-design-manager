from django.urls import include, path
from rest_framework.routers import DefaultRouter
from .views import ProjectViewSet

app_name = 'project'

router = DefaultRouter()

# The first parameter is the route used to access the resource
# The third field is the name of the Python class that you added
router.register(r'projects', ProjectViewSet, basename='project')

urlpatterns = [
    path('', include(router.urls)),
]
