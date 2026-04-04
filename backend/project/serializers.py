from rest_framework.serializers import ModelSerializer, CharField, ListSerializer, ValidationError
from .models import Semester, Preference, Project, Assignment, Feedback
import logging

logger = logging.getLogger(__name__)


class ProjectSerializer(ModelSerializer):
    status = CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Project
        fields = '__all__'


class SemesterSerializer(ModelSerializer):
    class Meta:
        model = Semester
        fields = '__all__'


class PreferenceListSerializer(ListSerializer):
    def create(self, validated_data):
        preferences = [Preference(**item) for item in validated_data]
        for preference in preferences:
            preference.id = preference.generate_id()

        return Preference.objects.bulk_create(preferences)

    def update(self, instance, validated_data):
        updates = [Preference(**item) for item in validated_data]
        for update in updates:
            for pref in instance:
                if pref.student == update.student and pref.project == update.project:
                    pref.rank = update.rank
                    break

        return Preference.objects.bulk_update(instance, fields=['rank'], batch_size=100)

    def validate(self, attrs):
        if not self.partial:
            # Only allow submitting one students preferences at a time
            student = [item.get('student') for item in attrs]
            if len(set(student)) != 1:
                raise ValidationError(f'Only 1 student may be updated at a time. Students submitted: {set(student)}')

            # Ensure unique projects
            projects = [item.get('project') for item in attrs]
            if len(projects) != len(set(projects)):
                raise ValidationError(f'Only 1 preference per project may be submitted. Projects submitted: {projects}')

        return attrs


class PreferenceSerializer(ModelSerializer):
    class Meta:
        model = Preference
        fields = '__all__'
        # Instantiating with many=True routes to the PreferenceListSerializer
        list_serializer_class = PreferenceListSerializer


class AssignmentSerializer(ModelSerializer):
    class Meta:
        model = Assignment
        fields = '__all__'


class FeedbackSerializer(ModelSerializer):
    class Meta:
        model = Feedback
        fields = '__all__'
