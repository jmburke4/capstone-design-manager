from rest_framework import serializers
from .models import Project

class ProjectSerializer(serializers.ModelSerializer):

    class Meta:
        model = Project
        # fields = ['id', 'name', 'description', 'sponsor_id', 'website', 'year_began', 'created_at']
        fields = ['id', 'name', 'description', 'sponsor_id', 'website', 'created_at']
