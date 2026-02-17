from django.contrib import admin
from user.models import Sponsor, Student
from user.resources import SponsorResource, StudentResource
from import_export.admin import ImportExportModelAdmin

# Register your models here.


@admin.register(Sponsor)
class SponsorAdmin(ImportExportModelAdmin):
    resource_classes = [SponsorResource]
    pass


@admin.register(Student)
class StudentAdmin(ImportExportModelAdmin):
    resource_classes = [StudentResource]
    pass
