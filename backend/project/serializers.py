from rest_framework import serializers
from .models import Project
from .models import Preference

class ProjectSerializer(serializers.ModelSerializer):

    class Meta:
        model = Project
        fields = ['id', 'name', 'description', 'sponsor', 'website', 'created_at', 'status']


class PreferenceSerializer(serializers.ModelSerializer):

    class Meta:
        model = Preference
        fields = ['id', 'created_at', 'student', 'project', 'rank']