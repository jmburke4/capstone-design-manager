from django import forms
from django.contrib import admin
from django.db.models import Count, Exists, IntegerField, OuterRef, Subquery
from django.db.models.functions import Coalesce
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from django_admin_action_forms import AdminActionForm, action_with_form
from import_export.admin import ImportExportModelAdmin
from project.models import Project, Semester, Preference, Assignment, Feedback
from project.resources import ProjectResource, SemesterResource, PreferenceResource, AssignmentResource, FeedbackResource
import logging

logger = logging.getLogger(__name__)


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

    # TODO Add count of preferences, average rank of preferences
    list_display = ['name', 'sponsor_link', 'status', 'semesters']
    list_filter = ['status', SemesterFilter, 'sponsor']
    search_fields = ['name', 'sponsor', 'description']
    # TODO Order by rank of preferences
    ordering = ['-status', 'name']

    class ChangeProjectStatusActionForm(AdminActionForm):
        status = forms.ChoiceField(
            label="Status",
            choices=Project.StatusChoices,
            required=True
        )

    class AssignProjectToSemesterActionForm(AdminActionForm):
        semester = forms.ModelMultipleChoiceField(
            queryset=Semester.objects.all(),
            required=True
        )

        class Meta:
            autocomplete_fields = filter_horizontal = ['semester']

    class RemoveProjectFromSemesterActionForm(AdminActionForm):
        class Meta:
            list_objects = True
            help_text = 'Are you sure you want to remove these projects from this semester?'

    @admin.display(description='Sponsor')
    def sponsor_link(self, obj):
        url = reverse('admin:user_sponsor_change', args=[obj.sponsor.id])
        return format_html(f'<a href="{url}">{obj.sponsor}</a>')

    @action_with_form(ChangeProjectStatusActionForm, description='Change status')
    def change_project_status_action(self, request, queryset, data):
        for project in queryset:
            project.status = data['status']
            project.save()
        self.message_user(request, f'Status changed to {data["status"].upper()} for {queryset.count()} projects.')

    @action_with_form(AssignProjectToSemesterActionForm, description='Assign to a semester')
    def assign_project_to_semester(self, request, queryset, data):
        for semester in data['semester']:
            semester.projects.add(*queryset)
            semester.save()
        self.message_user(request, f'Assigned {queryset.count()} projects to {len(data["semester"])} semesters.')

    @action_with_form(RemoveProjectFromSemesterActionForm, description='Remove from semester')
    def remove_project_from_semester(self, request, queryset, data):
        semester_id = request.GET.get('semester')
        if semester_id:
            semester = Semester.objects.filter(id=semester_id).first()
            if semester:
                semester.projects.remove(*queryset)
                semester.save()
            self.message_user(request, f'Removed {queryset.count()} projects from {semester}.')
        else:
            self.message_user(request, 'Filter the projects by a semester first', level='error')

    def semesters(self, obj):
        return Semester.objects.filter(projects=obj).count()

    actions = [change_project_status_action, assign_project_to_semester, remove_project_from_semester]


@admin.register(Semester)
class SemesterAdmin(ImportExportModelAdmin):
    resource_classes = [SemesterResource]

    # TODO Add total preferences submitted and number of students with preferences submitted
    list_display = ['semester', 'year', 'assignment_date', 'projects_count']
    list_filter = search_fields = ['year', 'semester']

    @admin.display(description='Projects')
    def projects_count(self, obj):
        url = (reverse('admin:project_project_changelist') + '?' + urlencode({'semester': obj.id}))
        count = obj.projects.count()
        return format_html(f'<a href="{url}">{count}</a>')


@admin.register(Preference)
class PreferenceAdmin(ImportExportModelAdmin):
    class IsAssignedFilter(admin.SimpleListFilter):
        title = 'Student Assigned'
        parameter_name = 'is_assigned'

        def lookups(self, request, model_admin):
            return [('true', 'Assigned'), ('false', 'Not Assigned')]

        def queryset(self, request, queryset):
            assignment_qs = Assignment.objects.filter(
                student=OuterRef('student'),
                semester=OuterRef('semester')
            )
            queryset = queryset.annotate(_is_assigned=Exists(assignment_qs))

            if self.value() == 'true':
                return queryset.filter(_is_assigned=True)
            elif self.value() == 'false':
                return queryset.filter(_is_assigned=False)
            return queryset

    class ProjectFilter(admin.SimpleListFilter):
        title = 'Project'
        parameter_name = 'project'

        def lookups(self, request, model_admin):
            semester_id = request.GET.get('semester')
            if semester_id:
                semester = Semester.objects.filter(id=semester_id).first()
                projects = semester.projects.all() if semester else Project.objects.none()
            else:
                projects = Project.objects.all()

            return [(project.id, project.name) for project in projects.order_by('name')]

        def queryset(self, request, queryset):
            if self.value():
                return queryset.filter(project_id=self.value())
            return queryset

    class NumAssignedToProjectFilter(admin.SimpleListFilter):
        title = 'Number Assigned to Project'
        parameter_name = 'num_assigned_to_project'

        def lookups(self, request, model_admin):
            return [
                (f'lt:{number}', f'Less than {number}')
                for number in range(3, 6)
            ] + [
                (f'gt:{number}', f'More than {number}')
                for number in range(3, 5)
            ]

        def queryset(self, request, queryset):
            assignment_count_qs = Assignment.objects.filter(
                project=OuterRef('project'),
                semester=OuterRef('semester')
            ).values('project').annotate(count=Count('*')).values('count')

            queryset = queryset.annotate(
                num_assigned_to_project=Coalesce(
                    Subquery(assignment_count_qs, output_field=IntegerField()),
                    0,
                )
            )

            value = self.value()
            if not value:
                return queryset

            operator, _, number = value.partition(':')
            try:
                threshold = int(number)
            except ValueError:
                return queryset

            if operator == 'lt':
                return queryset.filter(num_assigned_to_project__lt=threshold)
            if operator == 'gt':
                return queryset.filter(num_assigned_to_project__gt=threshold)
            return queryset

    resource_classes = [PreferenceResource]
    readonly_fields = ['student', 'project', 'semester']

    list_display = ['student', 'project', 'rank', 'semester', 'is_assigned', 'num_assigned_to_project']
    ordering = ['created_at']
    list_filter = ['semester', IsAssignedFilter, NumAssignedToProjectFilter, 'rank', ProjectFilter]

    # TODO Search fields by semester, project, student
    search_fields = ['student', 'project']

    class AssignStudentToProject(AdminActionForm):
        project = forms.ModelChoiceField(
            queryset=Project.objects.all(),  # TODO add filter to only include projects on current semester (can grab from preference records)
            required=True
        )

        def __init__(self, modeladmin, action, request, queryset, *args, **kwargs):
            super().__init__(modeladmin, action, request, queryset, *args, **kwargs)

            project_ids = list(queryset.values_list('project_id', flat=True).distinct())
            if len(project_ids) == 1:
                self.fields['project'].initial = Project.objects.filter(id=project_ids[0]).first()

    @action_with_form(AssignStudentToProject, description='Assign to project')
    def assign_to_project(self, request, queryset, data):
        selected_project = data['project']

        created_count = 0
        updated_count = 0
        unchanged_count = 0
        missing_semester_count = 0
        seen = set()

        for preference in queryset.select_related('student', 'semester'):
            if preference.student_id in seen:
                self.message_user(
                    request,
                    'Select each student only once before assigning them to a project.',
                    level='error'
                )
                return

            seen.add(preference.student_id)

            if preference.semester is None:
                missing_semester_count += 1
                continue

            assignment, created = Assignment.objects.get_or_create(
                student=preference.student,
                semester=preference.semester,
                defaults={'project': selected_project}
            )

            if created:
                created_count += 1
            elif assignment.project_id != selected_project.id:
                assignment.project = selected_project
                assignment.save()
                updated_count += 1
            else:
                unchanged_count += 1

        self.message_user(
            request,
            (
                f'Assigned selected students to {selected_project}. '
                f'Created: {created_count}, Updated: {updated_count}, '
                f'Already on project: {unchanged_count}, '
                f'Skipped (no semester): {missing_semester_count}.'
            )
        )

    actions = [assign_to_project]

    def is_assigned(self, obj):
        count = Assignment.objects.filter(student=obj.student, semester=obj.semester).count()
        if count == 1:
            return True
        elif count == 0:
            return False
        else:
            logger.error(f'Student {obj.student} has multiple assignments ({count}) for semester {obj.semester}')
            return None

    def num_assigned_to_project(self, obj):
        return Assignment.objects.filter(project=obj.project, semester=obj.semester).count()


@admin.register(Assignment)
class AssignmentAdmin(ImportExportModelAdmin):
    resource_classes = [AssignmentResource]
    readonly_fields = ['student', 'project', 'semester']

    list_display = ['project', 'student', 'semester']
    list_filter = ordering = ['semester', 'project']
    search_fields = ['student', 'project']


@admin.register(Feedback)
class FeedbackAdmin(ImportExportModelAdmin):
    resource_classes = [FeedbackResource]
    readonly_fields = ['sponsor', 'project', 'semester']

    list_display = search_fields = ordering = ['id', 'sponsor', 'project']
    list_filter = ['sponsor', 'project', 'semester']
