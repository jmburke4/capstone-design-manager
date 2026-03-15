from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from import_export.admin import ImportExportModelAdmin
from project.models import Project
from user.models import Sponsor, Student
from user.resources import SponsorResource, StudentResource


@admin.register(Sponsor)
class SponsorAdmin(ImportExportModelAdmin):
    resource_classes = [SponsorResource]

    list_display = ['name', 'email', 'projects', 'organization']
    list_display_links = ['name']
    list_filter = ['organization']
    search_fields = ['last_name', 'first_name', 'organization', 'email']
    ordering = ['last_name', 'first_name', 'organization', 'id']

    # Allows for custom computed field
    def projects(self, obj):
        url = (
            reverse('admin:project_project_changelist')
            + '?'
            + urlencode({'sponsor__id__exact': obj.id})
        )
        count = Project.objects.filter(sponsor=obj).count()
        return format_html(f'<a href="{url}">{count}</a>')


@admin.register(Student)
class StudentAdmin(ImportExportModelAdmin):
    resource_classes = [StudentResource]

    list_display = ['cwid', 'name', 'email', 'major_code', 'class_code', 'semester_year']
    list_display_links = ['cwid', 'name']
    list_filter = ['major_code', 'class_code', 'semester', 'year']
    search_fields = ['last_name', 'first_name', 'cwid', 'email']
    ordering = ['last_name', 'first_name', 'cwid']

    def semester_year(self, obj):
        return f'{obj.semester} {obj.year % 100}'
