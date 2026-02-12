from rest_framework import serializers
from .models import Project, Assignment

class ProjectSerializer(serializers.ModelSerializer):

    class Meta:
        model = Project
        fields = ['id', 'name', 'description', 'sponsor', 'website', 'created_at', 'status']

class AssignmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assignment
        fields = "__all__"