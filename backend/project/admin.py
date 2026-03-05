from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html
from import_export.admin import ImportExportModelAdmin
from project.models import Assignment, Preference, Project
from project.resources import (AssignmentResource, PreferenceResource, ProjectResource)


@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    resource_classes = [ProjectResource]
    list_display = ['name', 'sponsor_link', 'status']
    list_filter = ['status', 'sponsor']
    search_fields = ['name', 'sponsor', 'description']
    ordering = ['status', 'name']

    @admin.display(description='Sponsor')
    def sponsor_link(self, obj):
        url = reverse('admin:user_sponsor_change', args=[obj.sponsor.id])
        return format_html(f'<a href="{url}">{obj.sponsor}</a>')


@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    resource_classes = [PreferenceResource]


@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    resource_classes = [AssignmentResource]
