from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html
from django.utils.http import urlencode
from import_export.admin import ImportExportModelAdmin
from project.models import Project
from user.models import Sponsor, Student
from user.resources import SponsorResource, StudentResource

# Register your models here.


@admin.register(Sponsor)
class SponsorAdmin(ImportExportModelAdmin):
    resource_classes = [SponsorResource]
    list_display = ['name', 'projects', 'email', 'organization']
    list_filter = ['organization']
    search_fields = ['last_name', 'first_name', 'organization']
    ordering = ['last_name', 'first_name', 'organization', 'id']

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
    list_display = ['id', 'name', 'cwid', 'email']
