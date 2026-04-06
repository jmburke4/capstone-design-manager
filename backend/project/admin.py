from django import forms
from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from django_admin_action_forms import AdminActionForm, action_with_form
from import_export.admin import ImportExportModelAdmin
from project.models import Project, Semester, Preference, Assignment, Feedback
from project.resources import ProjectResource, SemesterResource, PreferenceResource, AssignmentResource, FeedbackResource
import logging

logger = logging.getLogger(__name__)


class ChangeProjectStatusActionForm(AdminActionForm):
    status = forms.ChoiceField(
        label="Status",
        choices=Project.StatusChoices,
        required=True
    )


@admin.register(Project)
class ProjectAdmin(ImportExportModelAdmin):
    class SemesterFilter(admin.SimpleListFilter):
        """This filter class is needed because the of the MtM relationship between semesters and projects"""

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

    resource_classes = [ProjectResource]

    list_display = ['name', 'sponsor_link', 'status']
    list_filter = ['status', 'sponsor', SemesterFilter]
    search_fields = ['name', 'sponsor', 'description']
    ordering = ['-status', 'name']

    @admin.display(description='Sponsor')
    def sponsor_link(self, obj):
        url = reverse('admin:user_sponsor_change', args=[obj.sponsor.id])
        return format_html(f'<a href="{url}">{obj.sponsor}</a>')

    @action_with_form(ChangeProjectStatusActionForm, description='Change status for selected projects')
    def change_project_status_action(self, request, queryset, data):
        for project in queryset:
            project.status = data['status']
            project.save()
        self.message_user(request, f'Status changed to {data["status"].upper()} for {queryset.count()} projects.')

    actions = [change_project_status_action]


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


@admin.register(Feedback)
class FeedbackAdmin(ImportExportModelAdmin):
    resource_classes = [FeedbackResource]

    list_display = search_fields = ordering = ['id', 'sponsor', 'project']
    list_filter = ['sponsor', 'project', 'semester']
