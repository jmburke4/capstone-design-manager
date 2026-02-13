from django.contrib import admin
from project.models import Project, Preference, Assignment
from import_export.admin import ImportExportModelAdmin

# Register your models here.

@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    pass

@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    pass

@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    pass
