from import_export import resources, fields
from project import models


class ProjectResource(resources.ModelResource):
    class Meta:
        model = models.Project


class PreferenceResource(resources.ModelResource):
    class Meta:
        model = models.Preference


class AssignmentResource(resources.ModelResource):
    class Meta:
        model = models.Assignment
