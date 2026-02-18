from import_export.resources import ModelResource
from project.models import Project, Preference, Assignment, Attachment


class ProjectResource(ModelResource):
    class Meta:
        model = Project


class PreferenceResource(ModelResource):
    class Meta:
        model = Preference


class AssignmentResource(ModelResource):
    class Meta:
        model = Assignment


class AttachmentResource(ModelResource):
    class Meta:
        model = Attachment
