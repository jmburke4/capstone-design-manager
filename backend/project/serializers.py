from rest_framework.serializers import ModelSerializer, CharField, ListSerializer, ValidationError
from .models import Semester, Preference, Project, Assignment
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
        """
        Update a list of preferences using bulk_update for better performance.
        instance is a list of Preference objects
        validated_data is a list of dictionaries
        """
        # Create a mapping of preference IDs to validated data
        updates_by_id = {item['id']: item for item in validated_data if 'id' in item}

        # Collect instances to update and fields that changed
        instances_to_update = []

        for preference in instance:
            if preference.id in updates_by_id:
                update_data = updates_by_id[preference.id]
                preference.rank = update_data.get('rank', preference.priority)
                instances_to_update.append(preference)

        # Use bulk_update for efficient database update
        if instances_to_update:
            Preference.objects.bulk_update(
                instances_to_update,
                fields=['rank'],
                batch_size=1000  # Adjust batch size based on your needs
            )

        return instance

    def validate(self, attrs):
        logger.debug(f'self.partial: {self.partial}')
        logger.debug(f'Validating: {attrs}')
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
