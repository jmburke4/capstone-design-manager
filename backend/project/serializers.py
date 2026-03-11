from rest_framework.serializers import ModelSerializer, CharField
from .models import Preference, Project, Assignment


class ProjectSerializer(ModelSerializer):

    status = CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Project
        fields = '__all__'


class PreferenceSerializer(ModelSerializer):

    class Meta:
        model = Preference
        fields = '__all__'


class AssignmentSerializer(ModelSerializer):

    class Meta:
        model = Assignment
        fields = '__all__'
