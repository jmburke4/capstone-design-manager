from rest_framework import viewsets
from .models import Project
from .serializers import ProjectSerializer
from .models import Preference
from .serializers import PreferenceSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer


class PreferenceViewSet(viewsets.ModelViewSet):
    queryset = Preference.objects.all()
    serializer_class = PreferenceSerializer