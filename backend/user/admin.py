from django.contrib import admin
from user.models import Sponsor, Student
from import_export.admin import ImportExportModelAdmin

# Register your models here.

@admin.register(Sponsor)
class SponsorAdmin(ImportExportModelAdmin):
    pass

@admin.register(Student)
class StudentAdmin(ImportExportModelAdmin):
    pass
