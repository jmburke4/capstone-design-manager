from django.contrib import admin
from project.models import Project, Preference, Assignment, Attachment
from project.resources import ProjectResource, PreferenceResource, AssignmentResource, AttachmentResource
from import_export.admin import ImportExportModelAdmin

# Register your models here.


@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    resource_classes = [ProjectResource]
    pass


@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    resource_classes = [PreferenceResource]
    pass


@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    resource_classes = [AssignmentResource]
    pass


@admin.register(Attachment)
class AttachmentAdmin(ImportExportModelAdmin):
    resource_classes = [AttachmentResource]
    pass
