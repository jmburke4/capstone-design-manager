from rest_framework.serializers import ModelSerializer, CharField
from rest_framework_bulk import BulkListSerializer, BulkSerializerMixin
from .models import Preference, Project, Assignment


class ProjectSerializer(ModelSerializer):

    status = CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Project
        fields = ['id', 'name', 'description', 'sponsor', 'website', 'created_at', 'status']


class PreferenceSerializer(BulkSerializerMixin, ModelSerializer):

    class Meta:
        model = Preference
        fields = ['id', 'created_at', 'student', 'project', 'rank']
        list_serializer_class = BulkListSerializer


class AssignmentSerializer(ModelSerializer):

    class Meta:
        model = Assignment
        fields = "__all__"
