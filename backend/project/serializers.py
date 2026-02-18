from rest_framework.serializers import ModelSerializer
from project.models import Project, Preference, Assignment, Attachment


class ProjectSerializer(ModelSerializer):

    class Meta:
        model = Project
        fields = ['id', 'name', 'description',
                  'sponsor', 'website', 'created_at', 'status']


class PreferenceSerializer(ModelSerializer):

    class Meta:
        model = Preference
        fields = ['id', 'created_at', 'student', 'project', 'rank']


class AssignmentSerializer(ModelSerializer):

    class Meta:
        model = Assignment
        fields = "__all__"


class AttachmentSerializer(ModelSerializer):

    class Meta:
        model = Attachment
        fields = "__all__"
