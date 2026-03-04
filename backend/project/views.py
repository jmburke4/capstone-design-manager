from rest_framework import viewsets
from .models import Project, Assignment, Preference
from .serializers import ProjectSerializer, AssignmentSerializer, PreferenceSerializer, PreferenceBulkSerializer
from django.db.models import Q
import logging

logger = logging.getLogger(__name__)


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

    def list(self, request, *args, **kwargs):
        logger.debug("Listing projects")
        return super().list(request, *args, **kwargs)


class PreferenceViewSet(viewsets.ModelViewSet):
    queryset = Preference.objects.all()
    serializer_class = PreferenceSerializer


class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer
