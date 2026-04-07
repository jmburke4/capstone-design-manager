from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from django.http import HttpResponse
from project.models import Project, Preference, Assignment, Attachment
from project.serializers import ProjectSerializer, PreferenceSerializer, AssignmentSerializer, AttachmentSerializer


class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer


class PreferenceViewSet(viewsets.ModelViewSet):
    queryset = Preference.objects.all()
    serializer_class = PreferenceSerializer


class AssignmentViewSet(viewsets.ModelViewSet):
    queryset = Assignment.objects.all()
    serializer_class = AssignmentSerializer


class AttachmentViewSet(viewsets.ModelViewSet):
    queryset = Attachment.objects.all()
    serializer_class = AttachmentSerializer

    @action(detail=True, methods=['get'])
    def download(self, request, pk=None):
        attachment = self.get_object()
        
        if attachment.content:
            content = attachment.content
            content_type = 'text/html'
            filename = f"{attachment.title or 'email'}.html"
        elif attachment.file:
            content = attachment.file.read()
            content_type = 'application/octet-stream'
            filename = attachment.file.name.split('/')[-1]
        else:
            return Response({'error': 'No content or file available'}, status=404)
        
        response = HttpResponse(content, content_type=content_type)
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        return response
