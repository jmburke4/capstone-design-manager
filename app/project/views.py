from django.shortcuts import render
from .models import Project
from rest_framework import generics
from .serializers import ProjectSerializer

class ProjectCreate(generics.CreateAPIView):
    # API view to create projects
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

class ProjectList(generics.ListAPIView):
    # API view to list all projects
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
    
class ProjectDetail(generics.RetrieveAPIView):
    # API view to retrieve a specific project by ID
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

class ProjectUpdate(generics.RetrieveUpdateAPIView):
    # API view to update a specific project by ID
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

class ProjectDelete(generics.RetrieveDestroyAPIView):
    # API view to delete a specific project by ID
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer
