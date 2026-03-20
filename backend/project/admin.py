from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from import_export.admin import ImportExportModelAdmin
from project.models import Project, Semester, Preference, Assignment
from project.resources import ProjectResource, SemesterResource, PreferenceResource, AssignmentResource


class SemesterFilter(admin.SimpleListFilter):
    title = 'Semester'
    parameter_name = 'semester'

    def lookups(self, request, model_admin):
        # Get unique semesters
        semesters = Semester.objects.distinct()
        return [(semester.id, semester) for semester in semesters]

    def queryset(self, request, queryset):
        # Filter projects by the selected semester
        if self.value():
            return Semester.objects.filter(id=self.value()).first().projects.all()
        return queryset


@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    resource_classes = [ProjectResource]

    list_display = ['name', 'sponsor_link', 'status']
    list_filter = ['status', 'sponsor', SemesterFilter]
    search_fields = ['name', 'sponsor', 'description']
    ordering = ['status', 'name']

    @admin.display(description='Sponsor')
    def sponsor_link(self, obj):
        url = reverse('admin:user_sponsor_change', args=[obj.sponsor.id])
        return format_html(f'<a href="{url}">{obj.sponsor}</a>')


@admin.register(Semester)
class SemesterAdmin(ImportExportModelAdmin):
    resource_classes = [SemesterResource]

    list_display = ['semester', 'year', 'assignment_date', 'projects_count']
    list_filter = search_fields = ['semester', 'year', 'assignment_date']
    ordering = ['year', 'semester']

    @admin.display(description='Projects')
    def projects_count(self, obj):
        url = (
            reverse('admin:project_project_changelist')
            + '?'
            + urlencode({'semester': obj.id})
        )
        count = obj.projects.count()
        return format_html(f'<a href="{url}">{count}</a>')


@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    resource_classes = [PreferenceResource]

    list_display = search_fields = ordering = ['id', 'student', 'rank', 'project', 'created_at']
    list_display_links = ['id']
    list_filter = ['rank', 'project', 'created_at']


@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    resource_classes = [AssignmentResource]
