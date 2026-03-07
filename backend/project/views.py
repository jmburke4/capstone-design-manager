from rest_framework import viewsets
from rest_framework_bulk import ListBulkCreateUpdateDestroyAPIView
from .models import Project, Assignment, Preference
from .serializers import ProjectSerializer, AssignmentSerializer, PreferenceSerializer
import logging

logger = logging.getLogger(__name__)


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer


class PreferenceAPIView(ListBulkCreateUpdateDestroyAPIView):
    queryset = Preference.objects.all()
    serializer_class = PreferenceSerializer


class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer
